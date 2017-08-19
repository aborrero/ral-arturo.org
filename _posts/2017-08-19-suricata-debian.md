---
layout: post
title:  "Running Suricata 4.0 with Debian Stretch"
date:   2017-08-19 12:56 +0200
tags:	[debian, suricata]
---

![debian-suricata logo][logo]

Do you know what's happening in the wires of your network? There is a major
FLOSS player in the field of real time intrusion detection (IDS), inline
intrusion prevention (IPS) and network security monitoring (NSM).
I'm talking about Suricata, a mature, fast and robust network threat detection
engine. Suricata is a community driven project, supported by the
[Open InfoSec Foundation (OISF)][oisf].

For those who doesn't know how Suricata works, it usually runs by loading a set
of pre-defined rules for matching different network protocols and flow
behaviours. In this regards, Suricata has been always ruleset-compatible with
the other famous IDS: snort.

<!--more-->

The last major release of Suricata is 4.0.0, and I'm uploading the package for
Debian stretch-backports as I write this line. This means the updated package
should be available for general usage after the usual buildds processing ends
inside the Debian archive.

You might be wondering, How to start using Suricata 4.0 with Debian Stretch?
First, I would recommend reading the docs. Please checkout:

* the [Debian wiki page for Suricata][wiki]
* the official [Suricata upstream docs][docs]

My recommendation is to run Suricata from *stretch-backports* or from
*testing*, and just installing the package should be enough to get the
environment up and running:

```
% sudo aptitude install suricata
```

You can check that the installation was good:

```
% sudo systemctl status suricata
● suricata.service - Suricata IDS/IDP daemon
   Loaded: loaded (/lib/systemd/system/suricata.service; enabled; vendor preset: enabled)
   Active: active (running) since Sat 2017-08-19 12:50:49 CEST; 44min ago
     Docs: man:suricata(8)
           man:suricatasc(8)
           https://redmine.openinfosecfoundation.org/projects/suricata/wiki
 Main PID: 1101 (Suricata-Main)
    Tasks: 8 (limit: 4915)
   CGroup: /system.slice/suricata.service
           └─1101 /usr/bin/suricata -D --af-packet -c /etc/suricata/suricata.yaml --pidfile /var/run/suricata.pid

ago 19 12:50:44 nostromo systemd[1]: Starting Suricata IDS/IDP daemon...
ago 19 12:50:47 nostromo suricata[1032]: 19/8/2017 -- 12:50:47 - <Notice> - This is Suricata version 4.0.0 RELEASE
ago 19 12:50:49 nostromo systemd[1]: Started Suricata IDS/IDP daemon.
```

You can interact with Suricata using the `suricatasc` tool:

```
% sudo suricatasc -c uptime
{"message": 3892, "return": "OK"}
```

And start inspecting the generated logs at `/var/log/suricata/`

The default configuration, in file `/etc/suricata/suricata.yaml`, comes with
some preconfigured values. For a proper integration into your enviroment, you
should tune the configuration file, define your networks, network interfaces,
running modes, and so on (refer to the upstream documentation for this).

In my case, I tested suricata by inspecting the traffic of my laptop. After
installation, I only had to switch the network interface:

```
[...]
# Linux high speed capture support
af-packet:
  - interface: wlan0
[...]
```

After a restart, I started seeing some alerts:

```
% sudo systemctl restart suricata
% sudo tail -f /var/log/suricata/fast.log
08/19/2017-14:03:04.025898  [**] [1:2012648:3] ET POLICY Dropbox Client Broadcasting [**] \
	[Classification: Potential Corporate Privacy Violation] [Priority: 1] {UDP} 192.168.1.36:17500 -> 255.255.255.255:17500
```

One of the main things when running Suricata is to keep your ruleset
up-to-dated. In Debian, we have the `suricata-oinkmaster` package which comes
with some handy options to automate your ruleset updates using the Oinkmaster
software. Please note that this is a Debian-specific glue to integrate and
automate Suricata with Oinkmaster.

To get this funcionality, simply install the package:

```
% sudo aptitude install suricata-oinkmaster
```

A daily cron-job will be enabled. Check `suricata-oinkmaster-updater(8)` for
more info.

By the way, Did you know that Suricata can easily handle big loads of traffic?
(i.e, 10Gbps). And I heard some scaling works are in mind to reach 100Gpbs.

I have been in charge of the [Suricata package in Debian][tracker] for a
while, several years already, with the help of some other DD hackers:
Pierre Chifflier (pollux) and Sascha Steinbiss (satta), among others.
Due to this work, I believe the package is really well integrated into Debian,
ready to use and with some powerful features.
And, of course, we are open to suggestions and bug reports.

So, this is it, another great stuff you can do with Debian :-)

[oisf]:			https://oisf.net/
[wiki]:			https://wiki.debian.org/suricata
[docs]:			http://suricata.readthedocs.io/en/latest/
[tracker]:		https://tracker.debian.org/pkg/suricata
[logo]:			{{site.url}}/assets/debian-suricata.jpg
