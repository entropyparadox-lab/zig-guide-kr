#!/usr/bin/env python3
"""
Zig Guide KR - Markdown Code Snippet Validation Harness
Extracts Zig code blocks from Markdown files and verifies compilation with `zig`.
"""

import os
import sys
import glob
import re
import tempfile
import subprocess
from pathlib import Path

ROOT_DIR = Path(__file__).parent.parent
DOCS_DIR = ROOT_DIR / "src" / "content" / "docs"

ZIG_BIN = os.environ.get("ZIG_BIN", "zig")


def extract_zig_snippets(md_path: Path):
    content = md_path.read_text(encoding="utf-8")
    # Matches ```zig ... ```
    pattern = re.compile(r"```zig\n(.*?)```", re.DOTALL)
    snippets = []
    for match in pattern.finditer(content):
        code = match.group(1).strip()
        if "// ignore" in code or "// pseudo" in code or "// zon" in code:
            continue
        snippets.append((match.start(), code))
    return snippets


def test_snippet(code: str, file_path: Path, idx: int) -> bool:
    with tempfile.TemporaryDirectory() as tmpdir:
        snippet_file = Path(tmpdir) / f"snippet_{idx}.zig"

        # Check characteristics of code
        has_std = "const std =" in code
        has_main = "pub fn main" in code or "fn main" in code
        has_build = "pub fn build" in code
        has_test = "test " in code or 'test "' in code
        is_struct_or_fn_only = (
            ("fn " in code or "const " in code or "struct {" in code or "union(" in code or "enum {" in code)
            and not ("+=\n" in code or " = undefined;\n" in code or "while (" in code or "for (" in code)
        )

        std_prefix = "" if has_std else "const std = @import(\"std\");\n"

        if has_main or has_test or has_build:
            final_code = code
        elif is_struct_or_fn_only and not ("main.zig" in code and "var " in code):
            final_code = f"""{std_prefix}
{code}
test "syntax check" {{}}
"""
        else:
            # Code containing statements to run inside a test
            final_code = f"""{std_prefix}
test "statements" {{
    {code}
}}
"""

        snippet_file.write_text(final_code, encoding="utf-8")

        # Run zig test (or zig build-obj for build.zig functions)
        if has_build:
            cmd = [ZIG_BIN, "build-obj", str(snippet_file), "-fno-emit-bin"]
        else:
            cmd = [ZIG_BIN, "test", str(snippet_file)]

        res = subprocess.run(cmd, capture_output=True, text=True)

        if res.returncode != 0:
            # Fallback check with build-obj
            cmd_obj = [ZIG_BIN, "build-obj", str(snippet_file), "-fno-emit-bin"]
            res_obj = subprocess.run(cmd_obj, capture_output=True, text=True)
            if res_obj.returncode != 0:
                print(f"❌ FAIL: {file_path.relative_to(ROOT_DIR)} (Snippet #{idx})")
                print("Generated file:\n" + final_code)
                print("Error:\n" + res_obj.stderr.strip() + "\n" + res.stderr.strip())
                return False

        print(f"✅ PASS: {file_path.relative_to(ROOT_DIR)} (Snippet #{idx})")
        return True


def main():
    try:
        ver = subprocess.run([ZIG_BIN, "version"], capture_output=True, text=True, check=True)
        print(f"Using Zig version: {ver.stdout.strip()}")
    except Exception as e:
        print(f"Error: {ZIG_BIN} not found or failed ({e})")
        sys.exit(1)

    all_files = glob.glob(str(DOCS_DIR / "**/*.md"), recursive=True) + glob.glob(
        str(DOCS_DIR / "**/*.mdx"), recursive=True
    )
    all_files.sort()

    total_snippets = 0
    passed_snippets = 0
    failed_snippets = 0

    for file_str in all_files:
        path = Path(file_str)
        snippets = extract_zig_snippets(path)
        for i, (_, code) in enumerate(snippets, 1):
            total_snippets += 1
            if test_snippet(code, path, i):
                passed_snippets += 1
            else:
                failed_snippets += 1

    print("\n" + "=" * 50)
    print(f"Results: Total={total_snippets}, Passed={passed_snippets}, Failed={failed_snippets}")
    print("=" * 50)

    if failed_snippets > 0:
        sys.exit(1)


if __name__ == "__main__":
    main()
