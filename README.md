# Simple Local Backup

This is a super simple, straightforward local backup script utilizing [`rclone sync`](https://rclone.org/commands/rclone_sync/) via the official [Docker](https://hub.docker.com/r/rclone/rclone) image.

Supplied is a default `FILTER_LIST` to get started, but be sure to modify as you see fit.

> Refer to the [official documentation](https://rclone.org/filtering/) for more information about formatting this file.

Usage:

```sh
./backup.sh [-d|--dry-run] <dest> [<src>]
```

> `dest` will attempt to be created, and gracefully fail if not possible.

It's suggested to supply `--dry-run` while tweaking the `FILTER_LIST` so as to not over/under copy files.

I've also found it useful to temporarily *exclude* files in the `FILTER_LIST` (example within) to limit output while testing as well as it can dump a lot of information.

### Troubleshooting

Filters not working quite like you expect? Perform a Dry Run and it'll also [dump out the filters](https://rclone.org/filtering/#dump-filters-dump-the-filters-to-the-output) to preview what's going on!