---
layout: post
title:  "The martian packet case in our Neutron floating IP setup"
date:   2019-03-21 10:00 +0200
tags:	[openstack, netfilter, neutron, networking]
---

![Networking][networking]

A community member opened a [bug][bug] the other day related to a weird
networking behavior in the Cloud VPS service, offered by the
[Cloud Services][WMCS] team at Wikimedia Foundation. This VPS hosting service
is based on Openstack, and we implement the networking bits by means of
Neutron.

<!--more-->

Our current setup is based on Openstack Mitaka (old, I know) and the networking
architecture we use is [extensively described in our docs][neutron_docs].
What is interesting today is our floating IP setup, which Neutron uses by means
of the [Netfilter][netfilter] NAT engine.

Neutron creates a couple of NAT rules for each floating IP, to implement both
SNAT and DNAT. In our setup, if a VM uses a floating IP, then all its traffic
to and from The Internet will use this floating IP. In our case, the floating
IP range is made of public IPv4 addresses.

![WMCS neutron setup][wmcs-neutron]

The bug/weird behavior consisted on the VM being unable to contact itself using
the floating IP. A packet is generated in the VM with destination address the
floating IP, a packet like this:

`172.16.0.148 > 185.15.56.55 ICMP echo request`

This packet reaches the neutron virtual router, and I could see it in tcpdump:

```
root@neutron-router:~# tcpdump -n -i qr-defc9d1d-40 icmp and host 172.16.0.148
11:51:48.652815 IP 172.16.0.148 > 185.15.56.55: ICMP echo request, id 32318, seq 1, length 64
```

Then, the PREROUTING NAT rules applies, translating `185.15.56.55` into
`176.16.0.148`. The corresponding conntrack NAT engine event:

```
root@neutron-router:~# conntrack -E -p icmp --src 172.16.0.148
    [NEW] icmp     1 30 src=172.16.0.148 dst=185.15.56.55 type=8 code=0 id=32395 [UNREPLIED] src=172.16.0.148 dst=172.16.0.148 type=0 code=0 id=32395
```

When this happens, the packet is put again in the wire, and I could see it
again in a tcpdump running in the Neutron server box. You can see the 2
packets, the first without NAT, the second with the NAT applied:

```
root@neutron-router:~# tcpdump -n -i qr-defc9d1d-40 icmp and host 172.16.0.148
11:51:48.652815 IP 172.16.0.148 > 185.15.56.55: ICMP echo request, id 32318, seq 1, length 64
11:51:48.652842 IP 172.16.0.148 > 172.16.0.148: ICMP echo request, id 32318, seq 1, length 64
```

The Neutron virtual router routes this packet back to the original VM, and you
can see the NATed packet reaching the interface. Note how I selected
`only incoming packets` in tcpdump using `-Q in`

```
root@vm-instance:~# tcpdump -n -i eth0 -Q in icmp
11:51:48.650504 IP 172.16.0.148 > 172.16.0.148: ICMP echo request, id 32318, seq 1, length 64
```
And here is the thing. That packet can't be routed by the VM:

```
root@vm-instance:~# ip route get 172.16.0.148 from 172.16.0.148 iif eth0
RTNETLINK answers: Invalid argument
```

This is known as a [martian packet][martian] and you can actually see the
kernel complaining if you turn on martian packet logging:

```
root@vm-instance:~# sysctl net.ipv4.conf.all.log_martians=1
root@vm-instance:~# dmesg -T | tail -2
[Tue Mar 19 12:16:26 2019] IPv4: martian source 172.16.0.148 from 172.16.0.148, on dev eth0
[Tue Mar 19 12:16:26 2019] ll header: 00000000: fa 16 3e d9 29 75 fa 16 3e ae f5 88 08 00        ..>.)u..>.....
```

The problem is that for local IP address, we recv a packet with same src/dst
IPv4, with different src/dst MAC address. That's nonsense from the network
stack if not configured otherwise. If one wants to instruct the network stack
to allow this, the fix is pretty easy:

```
root@vm-instance:~# sysctl net.ipv4.conf.all.accept_local=1
```

Now, ping from the VM to the floating IP works:

```
root@vm-intance:~# ping 185.15.56.55
PING 185.15.56.55 (185.15.56.55) 56(84) bytes of data.
64 bytes from 172.16.0.148: icmp_seq=1 ttl=64 time=0.202 ms
64 bytes from 172.16.0.148: icmp_seq=2 ttl=64 time=0.228 ms
^C
--- 185.15.56.55 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1011ms
rtt min/avg/max/mdev = 0.202/0.215/0.228/0.013 ms
```

And `ip route` reports it correctly:

```
root@vm-intance:~# ip route get 172.16.0.148 from 172.16.0.148 iif eth0
local 172.16.0.148 from 172.16.0.148 dev lo 
    cache <local>  iif eth0
```

You can read more about all the sysctl configs for network in
[the Linux kernel docs][kerneldocs]. In concrete this one:

```
accept_local - BOOLEAN
	Accept packets with local source addresses. In combination with
	suitable routing, this can be used to direct packets between two
	local interfaces over the wire and have them accepted properly.
	default FALSE
```

The Cloud VPS service offered by the Wikimedia Foundation is an open project,
open to use by anyone connected with the [Wikimedia movement][wm] and we
encourage the community to work with us in improving it. Yes, is open to
collaboration as well, also technical / engineering contributors, and you are
welcome to contribute to this or any of the many other collaborative efforts
in this global movement.

[networking]:           {{site.url}}/assets/networking.png
[bug]:			https://phabricator.wikimedia.org/T217681
[WMCS]:			https://wikitech.wikimedia.org/wiki/Help:Cloud_Services_Introduction
[neutron_docs]:		https://wikitech.wikimedia.org/wiki/Portal:Cloud_VPS/Admin/Neutron
[netfilter]:		https://netfilter.org/
[wmcs-neutron]:		{{site.url}}/assets/wmcs-neutron.png
[martian]:		https://en.wikipedia.org/wiki/Martian_packet
[kerneldocs]:		https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt
[wm]:			https://meta.wikimedia.org/wiki/Wikimedia_movement
