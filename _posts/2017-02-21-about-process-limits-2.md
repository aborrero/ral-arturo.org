---
layout: post
title:  "About process limits, round 2"
date:   2017-02-21 10:00 +0200
tags:	[systems administration, debian wheezy, debian, openldap, slapd]
---

![htop][htop]

I was wrong. After the other blog post [About process limits][blogpost], some
people contacted me with additional data and information.
I myself continued to investigate on the issue, so I have new facts.

I read again the source code of the slapd daemon and the picture seems clearer
now.

<!--more-->

A new message appeared in the log files:

```
[...]
Feb 20 06:26:03 slapd[18506]: daemon: 1025 beyond descriptor table size 1024
Feb 20 06:26:03 slapd[18506]: daemon: 1025 beyond descriptor table size 1024
Feb 20 06:26:03 slapd[18506]: daemon: 1025 beyond descriptor table size 1024
Feb 20 06:26:03 slapd[18506]: daemon: 1025 beyond descriptor table size 1024
Feb 20 06:26:03 slapd[18506]: daemon: 1025 beyond descriptor table size 1024
[...]
```

This message is clearly produced by the daemon itself, and searching for the
string leads to this source code, in `servers/slapd/daemon.c`:

```
[...]
sfd = SLAP_SOCKNEW( s );

/* make sure descriptor number isn't too great */
if ( sfd >= dtblsize ) {
	Debug( LDAP_DEBUG_ANY,
		"daemon: %ld beyond descriptor table size %ld\n",
		(long) sfd, (long) dtblsize, 0 );

	tcp_close(s);
	ldap_pvt_thread_yield();
	return 0;
}
[...]
```

In that same file, `dtblsize` is set to:

```
[...]
#ifdef HAVE_SYSCONF
        dtblsize = sysconf( _SC_OPEN_MAX );
#elif defined(HAVE_GETDTABLESIZE)
        dtblsize = getdtablesize();
#else /* ! HAVE_SYSCONF && ! HAVE_GETDTABLESIZE */
        dtblsize = FD_SETSIZE;
#endif /* ! HAVE_SYSCONF && ! HAVE_GETDTABLESIZE */
[...]
```

If you keep pulling the string, the first two options use system limits to
know the value, `getrlimit()`, and the last one uses a fixed value of 4096 (set
at build time).

It turns out that this routine `slapd_daemon_init()` is called once, at daemon
startup (see `main()` function at `servers/slapd/main.c`). So the daemon is
limiting itself to the limit imposed by the system at daemon startup time.

That means that our previous limits settings ***at runtime***
was not being read by the slapd daemon.

Let's back to the previous approach of establishing the process limits by
setting them on the user.
The common method is to call `ulimit` in the `init.d` script (or systemd
service file). One of my concerns of this approach was that slapd runs as a
different user, usually `openldap`.

Again, reading the source code:

```
[...]
if( check == CHECK_NONE && slapd_daemon_init( urls ) != 0 ) {
	rc = 1;
        SERVICE_EXIT( ERROR_SERVICE_SPECIFIC_ERROR, 16 );
        goto stop;
}

#if defined(HAVE_CHROOT)
	if ( sandbox ) {
		if ( chdir( sandbox ) ) {
			perror("chdir");
			rc = 1;
			goto stop;
		}
		if ( chroot( sandbox ) ) {
			perror("chroot");
			rc = 1;
			goto stop;
		}
	}
#endif

#if defined(HAVE_SETUID) && defined(HAVE_SETGID)
	if ( username != NULL || groupname != NULL ) {
		slap_init_user( username, groupname );
	}
#endif
[...]
```

So, the slapd daemon first reads the limits and then change user to `openldap`,
(the `slap_init_user()` function).

We can then asume that if we set the limits to the `root` user, calling
`ulimit` in the `init.d` script, the slapd daemon will actually inherint them.

This is what is originally suggested in [debian bug #660917][bug]. Let's use
this solution for now.

Many thanks to ***John Hughes <john@atlantech.com>*** for the clarifications
via email.

[htop]:		{{site.url}}/assets/htop.png
[blogpost]:	{{site.url}}/2017/02/14/about-process-limits.html
[bug]:		https://bugs.debian.org/660917

