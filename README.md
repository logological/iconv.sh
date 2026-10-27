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
tar -x --to-command='iconv.sh CP437 UTF-8' -f archive.tar
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
tar -x --to-command='bash iconv.sh CP437 UTF-8' -f archive.tar
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
