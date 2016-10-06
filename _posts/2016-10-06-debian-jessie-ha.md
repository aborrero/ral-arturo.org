---
layout: post
title:  "About Pacemaker HA stack in Debian Jessie"
date:   2016-10-06 16:30:00 +0200
tags:	[pacemaker, debian, ha, jessie]
---

![Debian - Pacemaker][debian-pacemaker]

People keep ignoring the status of the Pacemaker HA stack in Debian
Jessie. Most people think that they should stick to Debian Wheezy.

Why does this happen? Perhaps little or none publicity of the situation.

Since some time now, Debian contains a Pacemaker stack which is ready
to use in both Debian Jessie and in Debian Stretch.

<!--more-->

Anyway, let's see what we have so far:

 1. The pacemaker stack was updated in Debian unstable around Feb 2016.
 2. They migrated to Debian testing by that time as well.
 3. Most of the key packages were backported to jessie-backports (if not all).
 4. Therefore, Stretch is ready for the HA stack, and so is Jessie (using backports).

The packages I'm refering to are those which I consider the key components of
the stack, and by the time of this blogpost, the versions are:

| package	| jessie-backports	| stretch	| sid		| upstream	|
|---------------|-----------------------|---------------|---------------|---------------|
| corosync	| 2.3.6			| 2.3.6		| 2.3.6		| 2.4.1		|
| pacemaker	| 1.1.14		| 1.1.15	| 1.1.15	| 1.1.15	|
| crmsh		| 2.2.0			| 2.2.1		| 2.2.1		| 2.4.1		|
| libqb		| 1.0			| 1.0		| 1.0		| 1.0		|

<p/>

How can you check this by yourself? Here some pointers:

 * Debian HA packaging team overview: [link][overview]
 * Package tracker for corosync: [link][corosync]
 * Package tracker for pacemaker: [link][pacemaker]
 * Package tracker for crmsh: [link][crmsh]
 * Package tracker for libqb: [link][libqb]

I'm sure we even have the chance to improve a bit the packages before the
release of stretch. There are some packages which are a bit behind the
upstream version.

In any case: Yes! you can move from Debian Wheezy to Debian Jessie!

[debian-pacemaker]:	{{site.url}}/assets/debian-pacemaker.png
[overview]:		https://qa.debian.org/developer.php?email=debian-ha-maintainers%40lists.alioth.debian.org
[corosync]:		https://tracker.debian.org/pkg/corosync
[pacemaker]:		https://tracker.debian.org/pkg/pacemaker
[crmsh]:		https://tracker.debian.org/pkg/crmsh
[libqb]:		https://tracker.debian.org/pkg/libqb
