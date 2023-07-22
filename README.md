# sleepyzpool 💤

I have a ZFS pool with four HGST He12 harddisks.
One of those drives refused to spin down by itself, despite enabling APM.
So I wrote this script.

It watches the output of `zpool iostat` and records when there has been no activity on the pool for a given amount of time. Then it sends those drives into standby with a quick `hdparm -y`.

I got the idea from [ZFS disk spin down on fworkx.de](https://www.fworkx.de/2020/05/26/zfs-disk-spin-down/), although my script differs in a few aspects:

* monitor `zpool iostat` continuously instead of repeatedly for just one second
* don't be clever in detecting the harddisks of the pool
* no "inactive" timeframes within the script

The reason for not trying to be overly clever is that my own ZFS pool is constructed with four *LUKS encrypted* harddisks. It is possible to detect which drives are underlying a dm-crypt mapper ... but why? Just name those drives on the commandline explicitly.

### usage

There's two required arguments: `./sleepyzpool pool disks [disks ...]`

* `pool` is the name of your zpool, duh'
* `disks` is a list with all the disks you want to spin down

Additionally you can configure the timeout with two optional flags: `interval × limit`

* `--interval` is the interval in seconds; `60` might make sense
* `--limit` is the number of intervals with no I/O before issuing the standby command

And optionally:

* `--quiet` will silence the `iostat` log output when all disks are spun down

### example

This is an example with a very short timeout (6 × 10 seconds) on a zpool `tank` across four drives:

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
