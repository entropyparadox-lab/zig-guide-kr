"""Black-box regression tests for the native snippet validator."""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

BINARY = Path(__file__).resolve().parents[1] / "zig-out/bin/test-snippets"


class SnippetValidation(unittest.TestCase):
    def validate(self, code):
        with tempfile.TemporaryDirectory(prefix="zig-snippets-", dir=os.environ.get("TMPDIR")) as tmp:
            docs = Path(tmp) / "src/content/docs"
            docs.mkdir(parents=True)
            (docs / "fixture.md").write_text(f"```zig\n{code}\n```\n")
            return subprocess.run([str(BINARY)], cwd=tmp, capture_output=True, text=True)

    def test_failed_assertion_is_not_compile_success(self):
        result = self.validate('const std = @import("std");\ntest "must fail" { try std.testing.expect(false); }')
        self.assertNotEqual(result.returncode, 0, result.stderr)

    def test_main_body_is_analyzed(self):
        result = self.validate('pub fn main() void { nonexistent(); }')
        self.assertNotEqual(result.returncode, 0, result.stderr)

    def test_valid_test(self):
        result = self.validate('const std = @import("std");\ntest "ok" { try std.testing.expect(true); }')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_build_function_is_analyzed(self):
        result = self.validate('const std = @import("std");\npub fn build(b: *std.Build) void { b.nonexistent(); }')
        self.assertNotEqual(result.returncode, 0, result.stderr)


    def test_main_with_comment_or_test_still_analyzes_body(self):
        for prefix in ['// test example\n', 'test "ok" {}\n']:
            result = self.validate(prefix + 'pub fn main() void { const x: u8 = "bad"; _ = x; }')
            self.assertNotEqual(result.returncode, 0, result.stderr)

    def test_build_with_comment_or_test_still_analyzes_body(self):
        for prefix in ['// test example\n', 'test "ok" {}\n']:
            result = self.validate(prefix + 'const std = @import("std");\npub fn build(b: *std.Build) void { b.nonexistent(); }')
            self.assertNotEqual(result.returncode, 0, result.stderr)

    def test_main_with_failing_test_runs_assertions(self):
        result = self.validate('const std = @import("std");\npub fn main() void {}\ntest "bad" { try std.testing.expect(false); }')
        self.assertNotEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main()
