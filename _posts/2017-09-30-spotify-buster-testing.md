---
layout: post
title:  "Installing spotify-client in Debian testing (Buster)"
date:   2017-09-30 11:51 +0200
tags:	[debian, spotify]
---

![debian-spotify logo][logo]

Similar to the problem described in the post
[Google Hangouts in Debian testing (Buster)][hangout], the Spotify application
for Debian (a package called `spotify-client`) is not ready to run in 
Debian testing (Buster) as is.

<!--more-->

In this particular case, it seems there is only one problem, and is related to
openssl/libssl. The `spotify-client` package requires `libssl1.0.0` while in
Debian testing (Buster) we have an updated `libssl1.1`.

Fortunately, this is rather easy to solve, given the little additional
dependencies of both `spotify-client` and `libssl1.0.0`.

What we will do is to install `libssl1.0.0` from jessie-backports, coexisting
with `libssl1.1`.

Simple steps:

* 1) add jessie-backports repository to your `/etc/apt/sources.list` file: <br/>
`deb http://httpredir.debian.org/debian/ jessie-backports main`

* 2) update your repo database:
```
% user@debian:~ $ sudo aptitude update
```

* 3) verify we have both `libssl1.1` and `libssl1.0.0` ready to install:
```
% user@debian:~ $ aptitude search libssl
[...]
p   libssl1.0.0       - Secure Sockets Layer toolkit - shared libraries                                       
i   libssl1.1         - Secure Sockets Layer toolkit - shared libraries
[...]
```

* 4) Follow steps by Spotify to install the `spotify-client` package: <br/>
[https://www.spotify.com/uk/download/linux/]()

* 5) Run it and enjoy your music!

* 6) You can cleanup the `jessie-backports` line from `/etc/apt/sources.list`.

<br/>
_Bonus point_: Why jessie-backports?? Well, according to the
[openssl package tracker][openssl], jessie-backports contains the most recent
version of the `libssl1.0.0` package.

BTW, thanks to the openssl Debian maintainers, their work is really
appreciated :-) And thanks to Spotify for providing a Debian package :-)

[logo]:		{{site.url}}/assets/debian-logo-spotify.png
[hangout]:	{{site.url}}/2017/09/12/google-hangout-buster-testing.html
[openssl]:	https://tracker.debian.org/pkg/openssl
