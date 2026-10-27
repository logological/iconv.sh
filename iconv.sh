#!/bin/bash
#
# iconv.sh - filter for GNU tar --to-command that converts the
# character encoding of each file's name
#
# Usage (as invoked by GNU tar):
#   iconv.sh FROM-ENCODING TO-ENCODING
# Or in case of a restrictive access control policy (e.g., AppArmor):
#   bash iconv.sh FROM-ENCODING TO-ENCODING
#
# Example:
#   tar -x --to-command='iconv.sh CP437 UTF-8' -f archive.tar
#   tar -x --to-command='bash iconv.sh CP437 UTF-8' -f archive.tar

set -u

if (( $# != 2 )); then
    echo "usage: ${0##*/} from-encoding to-encoding" >&2
    exit 2
fi
from_enc=$1
to_enc=$2

file=${TAR_FILENAME:?iconv.sh: TAR_FILENAME not set; run via tar --to-command}

# As of tar 1.35, only regular files are supported
[[ ${TAR_FILETYPE:-f} == f ]] || exit 0

# Convert the filename.  The trailing "x" sentinel stops command
# substitution from stripping newlines at the end of a name, and since
# printf x runs only if iconv succeeds, a conversion failure makes the
# substitution fail.
converted=$(printf '%s' "$file" | iconv -f "$from_enc" -t "$to_enc" && printf x) \
    || { echo "iconv.sh: cannot convert filename '$file' from $from_enc to $to_enc" >&2; exit 1; }
file=${converted%x}

# Ensure the parent directory exists
[[ $file == */* ]] && { mkdir -p -- "${file%/*}" || exit 1; }

# Create the file from stdin
cat > "$file" || exit 1

# Set ownership: try names first, otherwise fall back to numeric IDs
chown -- "${TAR_UNAME-}:${TAR_GNAME-}" "$file" 2>/dev/null ||
    chown -- "${TAR_UID-}:${TAR_GID-}" "$file" 2>/dev/null

# Set mode (after chown, since chown can clear setuid/setgid bits)
[[ -n ${TAR_MODE-} ]] && { chmod -- "$TAR_MODE" "$file" || exit 1; }

# Set time of last access and time of last modification
[[ -n ${TAR_ATIME-} ]] && { touch -a -d "@$TAR_ATIME" -- "$file" || exit 1; }
[[ -n ${TAR_MTIME-} ]] && { touch -m -d "@$TAR_MTIME" -- "$file" || exit 1; }
