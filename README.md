# `iconv.sh`: GNU tar `--to-command` filter that converts filename encodings 

## Description

This script automatically converts filenames from one character
encoding to another as the files are extracted from archives by [GNU
tar](https://www.gnu.org/software/tar/).  It is
intended to mitigate the difficulties of unpacking archives where the
filenames are encoded in a different character set than the one used
on the extracting system.

## Usage

The script is intended to be invoked as the argument to the
`--to-command` option of GNU tar, and must be called as

```
iconv.sh FROM-ENCODING TO-ENCODING
```

where `FROM-ENCODING` and `TO-ENCODING` are character set encodings
known to [`libiconv`](https://www.gnu.org/software/libiconv/).

Example:

```
tar -x --to-command='iconv.sh ISO-8859-1 UTF-8' -f archive.tar
```

## System requirements

* [GNU
tar](https://www.gnu.org/software/tar/) 1.27+
* [GNU Bash](https://www.gnu.org/software/bash/)
* `iconv` from [GNU iconv](https://www.gnu.org/software/libiconv/)
* `touch` from [GNU coreutils](https://www.gnu.org/software/coreutils/)

## Caveats and limitations

### Working around MAC policy problems

Some GNU/Linux distributions, including openSUSE, ship with a
restrictive mandatory access control (MAC) policy (e.g., an AppArmor
profile) for tar that may prevent it from (directly) running
`iconv.sh`.  In such cases, try passing the entire `iconv.sh` command
line as the argument to `bash`:

```
tar -x --to-command='bash iconv.sh ISO-8859-1 UTF-8' -f archive.tar
```

### Metadata

GNU tar's documentation states that the `--to-command` option passes
the filter command certain metadata about each file to be extracted
(owner, group, last modification time, etc.), but the documentation
does not indicate the source of this metadata.  (The archive itself
contains file metadata, but there are various options to GNU tar, such
as `--group`, `--atime-preserve`, etc. that can be used to override
it.)  `iconv.sh` blindly attempts to apply whatever metadata GNU tar
passes it.

### File contents not converted

Note that `iconv.sh` converts the character encoding only in the
filenames, not the file contents.  If a given file has contents that
are encoded in `FROM-ENCODING`, and these contents refer to the name
of some (other) file in the archive, then this reference may no longer
be valid if `iconv.sh` ends up renaming the referent file's name
according to `TO-ENCODING`.  For example, if the archive contains an
ISO-8859-1-encoded HTML file `index.html` that hyperlinks to some
other file in the archive named `café.html` (e.g., via `<a
href="café.html">…</a>`), then this link will no longer point to
`café.html` if `iconv.sh` ends up converting the filenames to, say,
UTF-8.  If you need to change the character encoding of the contents
of (certain) files, then you should run `iconv` on them after
extraction.

## Alternatives

As an alternative to using `iconv.sh` to convert the filenames as they
are extracted, you may be able to extract the files first and then use
[`convmv`](https://www.j3e.de/linux/convmv/) to convert them later.

## License

`iconv.sh` is [Free
Software](https://www.gnu.org/philosophy/free-sw.html).  You can
redistribute it and/or modify it under the terms of the GNU General
Public License as published by the Free Software Foundation, either
version 3 of the License, or (at your option) any later version.
Please see the file `COPYING` for details.
