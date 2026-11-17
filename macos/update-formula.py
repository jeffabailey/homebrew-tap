"""Set a new version and the three SHA-256 values in Formula/aws-emulator.rb.

Usage: python3 -I update-formula.py <formula> <old-version> <new-version> <amd64-sha> <arm64-sha> <macos-sha>
"""

import re
import sys

path, old, new, amd64, arm64, macos = sys.argv[1:]
with open(path, encoding="utf-8") as file:
    text = file.read().replace(old, new)

for suffix, sha in (("_amd64.deb", amd64), ("_arm64.deb", arm64), ("-macos-arm64.tar.gz", macos)):
    pattern = r'(url "[^"]*' + re.escape(suffix) + r'"\n\s*(?:version "[^"]*"\n\s*)?sha256 ")[0-9a-f]{64}'
    text, count = re.subn(pattern, lambda match, sha=sha: match.group(1) + sha, text)
    if count != 1:
        sys.exit(f"Found {count} checksums for {suffix}, not 1.")

with open(path, "w", encoding="utf-8") as file:
    file.write(text)
