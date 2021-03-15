---
layout: post
title:  "Distributing static routes with DHCP"
date:   2018-09-12 10:00 +0200
tags:	[dhcp, debian]
---

![Networking][networking]

This week I had to deal with a setup in which I needed to distribute additional
static network routes using DHCP.

The setup is easy but there are some caveats to take into account.
Also, DHCP clients might not behave as one would expect.

<!--more-->

The starting situation is a working DHCP client/server deployment. Some standard
virtual machines would request their network setup over the network.
Nothing new. The DHCP server is dnsmasq, and the daemon is running under
Openstack control, but this has nothing to do with the DHCP problem itself.

By default, it seems dnsmasq sends to clients the `Routers (code 3)` option,
which usually contains the default gateway for clients to use.
My situation required to distribute one additional static route for another
subnet. My idea was for DHCP clients to end with this simple routing table:

```
user@dhcpclient:~$ ip r
default via 10.0.0.1 dev eth0 
10.0.0.0/24 dev eth0  proto kernel  scope link  src 10.0.0.100 
172.16.0.0/21 via 10.0.0.253 dev eth0
^^^ extra static route
```
To distribute this extra static route, you only need to edit the dnsmasq config
file and add a line like this:

```
dhcp-option=option:classless-static-route,172.16.0.0/21,10.0.0.253
```

For the initial configuratoin tests I was simply refreshing the lease from the client DHCP side.
This got my new static route online. But, and here comes the interesting part, in the case of a
reboot, the DHCP client would not add the default route to the local configuration. The different
behaviour is documented in `dhclient-script(8)`. So, apparently refreshing the lease and doing a
full machine reboot are completely different situations from the DHCP client point of view.

To try something similar to a reboot situation, I had to use this command:
```
user@dhcpclient:~$ sudo ifup --force eth0
Internet Systems Consortium DHCP Client 4.3.1
Copyright 2004-2014 Internet Systems Consortium.
All rights reserved.
For info, please visit https://www.isc.org/software/dhcp/

Listening on LPF/eth0/xx:xx:xx:xx:xx:xx
Sending on   LPF/eth0/xx:xx:xx:xx:xx:xx
Sending on   Socket/fallback
DHCPREQUEST on eth0 to 255.255.255.255 port 67
DHCPACK from 10.0.0.1
RTNETLINK answers: File exists
bound to 10.0.0.100 -- renewal in 20284 seconds.
```

Anyway the root problem is the same: Why would the DHCP client not install the default route?
This was really surprissing at first, and led me to debug DHCP packets using `dhcpdump`:

```
  TIME: 2018-09-11 18:06:03.496
    IP: 10.0.0.1 (xx:xx:xx:xx:xx:xx) > 10.0.0.100 (xx:xx:xx:xx:xx:xx)
    OP: 2 (BOOTPREPLY)
 HTYPE: 1 (Ethernet)
  HLEN: 6
  HOPS: 0
   XID: xxxxxxxx
  SECS: 8
 FLAGS: 0
CIADDR: 0.0.0.0
YIADDR: 10.0.0.100
SIADDR: xx.xx.xx.x
GIADDR: 0.0.0.0
CHADDR: xx:xx:xx:xx:xx:xx:00:00:00:00:00:00:00:00:00:00
OPTION:  53 (  1) DHCP message type         2 (DHCPOFFER)
OPTION:  54 (  4) Server identifier         10.0.0.1
OPTION:  51 (  4) IP address leasetime      43200 (12h)
OPTION:  58 (  4) T1                        21600 (6h)
OPTION:  59 (  4) T2                        37800 (10h30m)
OPTION:   1 (  4) Subnet mask               255.255.255.0
OPTION:  28 (  4) Broadcast address         10.0.0.255
OPTION:  15 ( 13) Domainname                xxxxxxxx
OPTION:  12 ( 21) Host name                 xxxxxxxx
OPTION:   3 (  4) Routers                   10.0.0.1
OPTION: 121 (  8) Classless Static Route    xxxxxxxxxxxxxx .....D..                 
[...]
---------------------------------------------------------------------------
```
(you can use this handy command both in server and client side)

So, the DHCP server was sending both the `Routers (code 3)` and the
`Classless Static Route (code 121)` options to the clients. So, why would
fail the client to install both routes?

I obtained some help from folks on IRC and they pointed me
towards [RFC3442][rfc]:
```
DHCP Client Behavior
[...]
   If the DHCP server returns both a Classless Static Routes option and
   a Router option, the DHCP client MUST ignore the Router option.
```

So, clients are supposed to ignore the `Routers (code 3)` option if they get
an additional static route. This is very counter-intuitive, but can be easily
workarounded by just distributing the default gateway route as another
classless static route:

```
dhcp-option=option:classless-static-route,0.0.0.0/0,10.0.0.1,172.16.0.0/21,10.0.0.253
#                                         ^^ default route   ^^ extra static route 
```

Obviously this was the first time in my career dealing with this setup and situation.
My conclussion is that even old-enough protocols like DHCP can sometimes behave
in a counter-intuitive way. Reading RFCs is not always funny, but can help
understand what's going on. I wonder why the protocol is defined this way. I bet there
are valid reasons for it. Or not? Who knows.

You can read the original issue in Wikimedia Foundation's Phabricator ticket
[T202636][phab], including all the back-and-forth work I did.
Yes, is open to the public ;-)

[rfc]:			https://tools.ietf.org/html/rfc3442
[phab]:			https://phabricator.wikimedia.org/T202636
[networking]:		{{site.url}}/assets/networking.png
