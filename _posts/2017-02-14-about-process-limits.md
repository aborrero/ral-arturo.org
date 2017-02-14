---
layout: post
title:  "About process limits"
date:   2017-02-14 10:24 +0200
tags:	[systems administration, debian wheezy, debian]
---

![Graphs][graphs]

The other day I had to deal with an outage in one of our LDAP servers,
which is running the old Debian Wheezy (yeah, I know, we should update it).

We are running openldap, the slapd daemon. And after searching the log files,
the cause of the outage was obvious:

<!--more-->

```
[...]
slapd[7408]: warning: cannot open /etc/hosts.allow: Too many open files
slapd[7408]: warning: cannot open /etc/hosts.deny: Too many open files
slapd[7408]: warning: cannot open /etc/hosts.allow: Too many open files
slapd[7408]: warning: cannot open /etc/hosts.deny: Too many open files
slapd[7408]: warning: cannot open /etc/hosts.allow: Too many open files
slapd[7408]: warning: cannot open /etc/hosts.deny: Too many open files
[...]
```

I couldn't believe that openldap is using tcp_wrappers (or libwrap), an ancient
software piece that hasn't been updated for years, replaced in many other ways
by more powerful tools (like nftables).
I was blinded by this and ran to open a Debian bug agains openldap:
[#854436 (openldap: please don't use tcp-wrappers with slapd)][bug].

The reply from *Steve Langasek* was clear:

```
If people are hitting open file limits trying to open two extra files,
disabling features in the codebase is not the correct solution.
```

Obvoursly, the problem was somewhere else.

I started investigating about system limits, which seems to have 2 main
componentes:
* system-wide limits (you tune these via sysctl, they live in the kernel)
* user/group/process limits (via limits.conf, ulimit and prlimit)

According to my searchings, my slapd daemon was being hit by the latter.
I reviewed the default system-wide limits and they seemed Ok.
So, let's change the other limits.

Most of the documentantion around the internet points you to a
***/etc/security/limits.conf*** file, which is then read by ***pam_limits***.
You can check current limits using the ***ulimit*** bash builtin.

In the case of my slapd:

```
arturo@debian:~% sudo su openldap -s /bin/bash
openldap@debian:~% ulimit -a
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 7915
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 1024
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 2000
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```

This seems to suggest that the ***openldap*** user is constrained to 1024
openfiles (and some more if we check the hard limit). The 1024 limit seems
low for a rather busy service.

According to most of the internet docs, I'm supposed to put this in
***/etc/security/limits.conf***:

```
[...]
#<domain>      <type>  <item>         <value>
openldap	soft	nofile		1000000
openldap	hard	nofile		1000000
[...]
```
I should check as well that pam_limits is loaded, in ***/etc/pam.d/other***:

```
[...]
session		required	pam_limits.so
[...]
```

After reloading the openldap session, you can check that, indeed, limits
are changed as reported by ulimit.
But at some point, the slapd daemon starts to drop connections again.
Thing start to turn weird here.

The changes we made until now don't work, probably because when the slapd
daemon is spawned at bootup (by root, sysvinit in this case) no pam mechanisms
are triggered.

So, I was forced to learn a new thing: process limits.

You can check the limits for a given process this way:

```
arturo@debian:~% cat /proc/$(pgrep slapd)/limits
Limit                     Soft Limit           Hard Limit           Units
Max cpu time              unlimited            unlimited            seconds
Max file size             unlimited            unlimited            bytes
Max data size             unlimited            unlimited            bytes
Max stack size            8388608              unlimited            bytes
Max core file size        0                    unlimited            bytes
Max resident set          unlimited            unlimited            bytes
Max processes             16000                16000                processes
Max open files            1024                 4096                 files
Max locked memory         65536                65536                bytes
Max address space         unlimited            unlimited            bytes
Max file locks            unlimited            unlimited            locks
Max pending signals       16000                16000                signals
Max msgqueue size         819200               819200               bytes
Max nice priority         0                    0
Max realtime priority     0                    0
Max realtime timeout      unlimited            unlimited            us
```

Good, seems we have some more limits attached to our slapd daemon process.

If we search the internet to know how to change process limits, most of the
docs points to a tool known as ***prlimit***. According to the manpage, this is
a tool to *get and set process resource limits*, which is just what I was
looking for.

According to the docs, the prlimit system call is supported since Linux 2.6.36,
and I'm running 3.2, so no problem here. Things looks promising.
But yes, more problems. The prlimit tool is not included in the Debian Wheezy
release.

A simple call a single system call was not going to stop me now, so I searched
more the web until I found this useful manpage: [getrlimit(2)][man].

There is a sample C code included in the manpage, in which we only need to
replace RLIMIT_CPU with RLIMIT_NOFILE:

```
#define _GNU_SOURCE
#define _FILE_OFFSET_BITS 64
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/resource.h>

#define errExit(msg) do { perror(msg); exit(EXIT_FAILURE); \
                        } while (0)

int
main(int argc, char *argv[])
{
    struct rlimit old, new;
    struct rlimit *newp;
    pid_t pid;

    if (!(argc == 2 || argc == 4)) {
        fprintf(stderr, "Usage: %s <pid> [<new-soft-limit> "
                "<new-hard-limit>]\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    pid = atoi(argv[1]);        /* PID of target process */

    newp = NULL;
    if (argc == 4) {
        new.rlim_cur = atoi(argv[2]);
        new.rlim_max = atoi(argv[3]);
        newp = &new;
    }

    /* Set CPU time limit of target process; retrieve and display
       previous limit */

    if (prlimit(pid, RLIMIT_NOFILE, newp, &old) == -1)
        errExit("prlimit-1");
    printf("Previous limits: soft=%lld; hard=%lld\n",
            (long long) old.rlim_cur, (long long) old.rlim_max);

    /* Retrieve and display new CPU time limit */

    if (prlimit(pid, RLIMIT_NOFILE, NULL, &old) == -1)
        errExit("prlimit-2");
    printf("New limits: soft=%lld; hard=%lld\n",
            (long long) old.rlim_cur, (long long) old.rlim_max);

    exit(EXIT_FAILURE);
}
```

And them compile it like this:

```
arturo@debian:~% gcc limits.c -o limits
```

We can then call this new binary like this:

```
arturo@debian:~% sudo limits $(pgrep slapd) 1000000 1000000
```

Finally, the limit seems OK:

```
arturo@debian:~% cat /proc/$(pgrep slapd)/limits
Limit                     Soft Limit           Hard Limit           Units
Max cpu time              unlimited            unlimited            seconds
Max file size             unlimited            unlimited            bytes
Max data size             unlimited            unlimited            bytes
Max stack size            8388608              unlimited            bytes
Max core file size        0                    unlimited            bytes
Max resident set          unlimited            unlimited            bytes
Max processes             16000                16000                processes
Max open files            1000000              1000000              files
Max locked memory         65536                65536                bytes
Max address space         unlimited            unlimited            bytes
Max file locks            unlimited            unlimited            locks
Max pending signals       16000                16000                signals
Max msgqueue size         819200               819200               bytes
Max nice priority         0                    0
Max realtime priority     0                    0
Max realtime timeout      unlimited            unlimited            us
```

Don't forget to apply this change every time the slapd daemon starts.

Nobody found this issue before? really?

[graphs]:	{{site.url}}/assets/graphs.png
[bug]:		https://bugs.debian.org/854436
[man]:		https://manpages.debian.org/wheezy/manpages-dev/getrlimit.2.en.html

