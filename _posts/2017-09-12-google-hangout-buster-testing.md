---
layout: post
title:  "Google Hangouts in Debian testing (Buster)"
date:   2017-09-12 21:37 +0200
tags:	[debian, google]
---

![debian-suricata logo][logo]

Google offers a lot of software components packaged specifically for Debian and
Debian-like Linux distributions. Examples are: Chrome, Earth and the Hangouts
plugin.
Also, there are many other Internet services doing the same: Spotify, Dropbox,
etc. I'm really grateful for them, since this make our life easier.

Problem is that our ecosystem is rather complex, with many distributions and
many versions out there. I guess is not an easy task for them to keep such a
big variety of support variations.

<!--more-->

In this particular case, it seems Google doesn't support Debian testing in
their .deb packages. In this case, testing means Debian Buster.
And the same happens with the official Spotify client package.

I've identified several issues with them, to name a few:

* packages depends on `lsb-core`, no longer present in Buster testing.
* packages depends on `libpango1.0-0`, however testing contains `libpango-1.0-0`

I'm in need of using Google Hangout so I've been forced to solve this situation
by editing the .deb package provided by Google.

Simple steps:

* 1) create a temporal working directory

```
% user@debian:~ $ mkdir pkg
% user@debian:~ $ cd pkg/
```
* 2) get the original [.deb package][orig], the Google Hangout talk plugin.

```
% user@debian:~/pkg $ wget https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb
[...]
```

* 3) extract the original .deb package

```
% user@debian:~/pkg $ dpkg-deb -R google-talkplugin_current_amd64.deb google-talkplugin_current_amd64/
% user@debian:~/pkg $ dpkg -e google-talkplugin_current_amd64.deb google-talkplugin_current_amd64/DEBIAN/
```

* 4) edit the control file, replace `libpango1.0-0` with `libpango-1.0-0`

```
% user@debian:~/pkg $ nano google-talkplugin_current_amd64/DEBIAN/control
```

* 5) rebuild the package and install it!

```
% user@debian:~/pkg $ dpkg -b google-talkplugin_current_amd64
% user@debian:~/pkg $ sudo dpkg -i google-talkpluging_current_amd64.deb
```

I have yet to investigate how to workaround the `lsb-core` thing, so still I
can't use Google Earth.

[orig]:		https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb
[logo]:		{{site.url}}/assets/debian-logo-pkg.png
