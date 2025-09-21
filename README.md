# dotty

This is a super simple, straightforward local backup script utilizing `rsync`.

Supplied is a default `FILTER_LIST.common` and `FILTER_LIST.custom` to get started, but be sure to modify as you see fit.

> Refer to the [manpage](https://man.archlinux.org/man/rsync.1.en#FILTER_RULES_IN_DEPTH) for more information about formatting this file.

## Usage:

> See output of each tool for help

For dotfile and system configuration backup/restore:

```sh
./dotty 
```

For Package Manager list dumping and installing:

```sh
./packageListTool
```

It's suggested to supply `--dry-run` while tweaking the `FILTER_LIST.*` files so as to not over/under copy files.
