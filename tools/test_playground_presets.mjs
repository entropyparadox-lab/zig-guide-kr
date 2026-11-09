// Compile the actual component's cooked template strings, not simulator output.
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import test from 'node:test';
import ts from 'typescript';

const component = readFileSync(new URL('../src/components/ZigPlayground.astro', import.meta.url), 'utf8');
const scripts = [...component.matchAll(/<script>([\s\S]*?)<\/script>/g)];
assert.equal(scripts.length, 1, 'Expected one playground script');
const source = ts.createSourceFile('playground.ts', scripts[0][1], ts.ScriptTarget.Latest, true);
const declarations = source.statements
  .filter(ts.isVariableStatement)
  .flatMap((statement) => [...statement.declarationList.declarations])
  .filter((declaration) => declaration.name.getText(source) === 'PRESETS');
assert.equal(declarations.length, 1, 'Expected one PRESETS declaration');
const initializer = declarations[0].initializer;
assert.ok(initializer && ts.isObjectLiteralExpression(initializer), 'PRESETS must be an object literal');
const presets = new Map();
for (const property of initializer.properties) {
  assert.ok(ts.isPropertyAssignment(property), 'Every preset must be a property assignment');
  assert.ok(ts.isIdentifier(property.name) || ts.isStringLiteral(property.name));
  assert.ok(ts.isNoSubstitutionTemplateLiteral(property.initializer), 'Presets must be literal Zig source');
  const name = property.name.text;
  assert.ok(!presets.has(name), `Duplicate preset: ${name}`);
  // TypeScript decodes JS escapes (\\n -> \n), preserving the exact editor source.
  presets.set(name, property.initializer.text);
}

// Independent output oracle: never derive expected values from SAMPLE_OUTPUTS.
const expected = {
  hello: 'Hello, Zig!\n  [Step 1] Formatting example.\n  [Step 2] Formatting example.\n  [Step 3] Formatting example.\n  [Step 4] Formatting example.\n  [Step 5] Formatting example.\n',
  memory: 'numbers[0] = 100\nnumbers[1] = 200\nnumbers[2] = 300\nArrayList example complete.\n',
  comptime: 'Popped: 777\nPopped: 99\nPopped: 42\nPopped from empty: null\n',
  structs: 'Circle area (r=5.0): 78.54\nRectangle area (10x4): 40.00\nPoint area: 0.00\n',
  quicksort: 'Before sort: 64 34 25 12 22 11 90 88 45 1 \nAfter sort:  1 11 12 22 25 34 45 64 88 90 \n',
  custom: 'Welcome, Zig Developer!\n42 + 58 = 100\n',
};
assert.deepEqual([...presets.keys()].sort(), Object.keys(expected).sort(), 'Every preset needs a compiler/output regression');

for (const [name, code] of presets) {
  test(`real Zig compiler: ${name}`, () => {
    const directory = mkdtempSync(join(tmpdir(), 'zig-playground-'));
    try {
      const file = join(directory, `${name}.zig`);
      writeFileSync(file, code);
      const result = spawnSync('zig', ['run', file], { encoding: 'utf8', timeout: 60_000 });
      assert.ifError(result.error);
      assert.equal(result.signal, null, `Compiler terminated by ${result.signal}`);
      assert.equal(result.status, 0, result.stderr);
      // std.debug.print writes to stderr; unexpected diagnostics must fail too.
      assert.equal(result.stdout, '');
      assert.equal(result.stderr, expected[name]);
    } finally {
      rmSync(directory, { recursive: true, force: true });
    }
  });
}
