# sleepyzpool 💤

I have a ZFS pool with four HGST He12 harddisks.
One of those drives refused to spin down by itself, despite enabling APM.
So I wrote this script.

It watches the output of `zpool iostat` and records when there has been no activity on the pool for a given amount of time. Then it sends those drives into standby with a quick `hdparm -y`.

I got the idea from [ZFS disk spin down on fworkx.de](https://www.fworkx.de/2020/05/26/zfs-disk-spin-down/), although my script differs in a few aspects:

* monitor `zpool iostat` continuously instead of repeatedly for just one second
* don't be clever in detecting the harddisks of the pool
* no "inactive" timeframes within the script; stop the service if needed

The reason for not trying to be overly clever is that my own ZFS pool is constructed with four encrypted harddisks. It is possible to detect which drives are underlying a dm-crypt mapper ... but why? Just list those drives explicitly.

### usage

There's is one semi-required argument: `./sleepyzpool [config.toml]`. By default it will try to open `/etc/sleepyzpool.toml` and this config should look like this:

```toml
# zpool to watch for activity with iostat
zpool = "tank"

# timeout without I/O in minutes before issuing standby command
timeout = 20

# list of disks to control and spin down after timeout
disks = [
  "/dev/sda",
  "/dev/sdb",
]
```

You can optionally use `--quiet` to silence the `iostat` log output when all disks are spun down.
Apart from that there are two "command" flags:

* `--check` / `-C` will output if the drives are *currently* in standby and exit
* `--now` / `-y` will issue standby commands for all disks immediately

### example

This is an example with a very short timeout on a zpool `tank` across four drives:

```
# ./sleepyzpool --interval 10 --limit 6 tank /dev/sd{a..d} | ts
Jan 25 19:43:03 iostat  ops[506, 0]     bw[31.7M, 0]    counters[0, 0, 0, 0]
Jan 25 19:43:13 iostat  ops[391, 0]     bw[24.6M, 0]    counters[0, 0, 0, 0]
Jan 25 19:43:23 iostat  ops[149, 0]     bw[9.28M, 0]    counters[0, 0, 0, 0]
Jan 25 19:43:33 iostat  ops[0, 0]       bw[0, 0]        counters[1, 1, 1, 1]
Jan 25 19:43:43 iostat  ops[0, 0]       bw[0, 0]        counters[2, 2, 2, 2]
Jan 25 19:43:53 iostat  ops[0, 0]       bw[0, 0]        counters[3, 3, 3, 3]
Jan 25 19:44:03 iostat  ops[0, 0]       bw[0, 0]        counters[4, 4, 4, 4]
Jan 25 19:44:13 iostat  ops[0, 0]       bw[0, 0]        counters[5, 5, 5, 5]
Jan 25 19:44:23 hdparm  issuing standby: /dev/sda
Jan 25 19:44:24 hdparm  issuing standby: /dev/sdb
Jan 25 19:44:25 hdparm  issuing standby: /dev/sdc
Jan 25 19:44:25 hdparm  issuing standby: /dev/sdd
Jan 25 19:44:26 iostat  ops[0, 0]       bw[0, 0]        counters[0, 0, 0, 0]
Jan 25 19:44:33 iostat  ops[0, 0]       bw[0, 0]        counters[0, 0, 0, 0]
Jan 25 19:44:43 iostat  ops[0, 0]       bw[0, 0]        counters[0, 0, 0, 0]
Jan 25 19:44:53 iostat  ops[0, 0]       bw[0, 0]        counters[0, 0, 0, 0]
```

### license

Copyright (c) 2023 Anton Semjonov

Licensed under the MIT License
