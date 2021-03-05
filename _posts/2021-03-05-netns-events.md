---
layout:	post
title:	"Openstack Neutron L3 failover issues"
date:	2021-03-05 13:47 +0200
tags:	[openstack]
---

![Networking][logo]

In the Cloud Services team at the Wikimedia Foundation we use Openstack Neutron to build our
virtual network, and in particular, we rely on the `neutron-l3-agent` for implementing all the L3
connectivity, topology and policing. This includes basic packet firewalling and NAT.

As of this writing, we are using Openstack version Train. We run the `neutron-l3-agent` on
standard linux hardware servers with 10G NICs, and in general it works really well. Our setup is
rather simple: we have a couple of servers for redundancy (note: upstream recommends having 3) and
each server runs an instance of `neutron-l3-agent`. We don't use DVR, so all ingress/egress network
traffic (or north-south traffic) flows using these servers. Today we use a flat network topology in
our cloud. This means that all of our virtual machines share the same router gateway. Therefore, we
only have one software-defined router.

<!--more-->

Neutron does a very smart thing: each software-defined router is implemented on a linux network
namespace (netns). Each router living on its own netns, the namespace contains all IP addresses,
routes, interfaces, netfilter firewalling rules, NAT configuration, etc.

Additionally, we configure the agents and software-defined routers to be deployed on an high
availability fashion. Neutron implements this by running an instance of `keepalived` (VRRP) inside
each router netns. The gateway IP is therefore a virtual address that can move between the two
instances of the `neutron-l3-agent`.

In our setup we rely very heavily on IPv4 NAT, we use it for the egress traffic (SNAT) and also for
Openstack floating IPs (SNAT/DNAT). Neutron uses Netfilter rules for configuring the whole NAT
setup. There is, however, no apparent mechanism in the `neutron-l3-agent` to ensure continuity of
NATed TCP connections when a failover happens. If all NATed TCP connections are flowing using
`neutron-l3-agent` node A, and a failover happens, node B wont be able to pick up the opened TCP
streams and therefore all connections will need to be re-established. This happens because the
conntrack information that Netfilter uses to perform NAT is not present in node B when the failover
happens. NAT is, in general, a stateful thing and should be treated that way. It seems some
folks upstream are aware of this, and there are even [some blueprints][blueprints] to introduce
`conntrackd` alongside `keepalived`. The actual implementation didn't happen so far,
[apparently][lp].

I wonder, are we the only cloud deployment suffering this issue? Our users have been experiencing
annoying connection cuts every time we failover the `neutron-l3-agent` for whatever reason: an
upgrade, server reboot, etc. After numerous incidents I opened a [ticket in our phabricator][phab]
instance and started working on it. I've been trying to improve this situation by following a
couple of strategies:

 * running `conntrackd` by hand inside the software-defined router netns.
   This deserves its own blog post and won't comment more on this today.
 * setting additional sysctl configuration on the affected nents. This is the point I will be
   covering in this post.

To help the conntrack engine deal with NATed TCP connections I decided to try setting the sysctl
key `net.netfilter.nf_conntrack_tcp_be_liberal=1`. But it turns out this sysctl key is not
inherited from the main netns when the software-defined netns is created (i.e, is per-netns). I
needed a mechanism to detect netns events (creation) and then inject the sysctl setting. Neutron
apparently doesn't have any facility to hook/call commands at netns creation time.

This felt like a very fun coding challenge, so I did it!

I learned that netns have a `/var/run/netns/<netns>` entry, so I thought it would be easy to listen
to file system events and react to them. I wanted to use some python, so I decided to go with the
`pyinotify` library.

I ended up creating a simple [netns-events.py][script] daemon/script. By using regexes it allows
matching on netns names and running arbitrary commands on certain situations:
 * inmediatly when the daemon itself starts, if a matching netns exists (`daemon_startup_actions`)
 * on inotify events (`inotify_actions`), such as `IN_CREATE`.

The daemon reads a yaml configuration file like this:

```yaml
---
# $NETNS env var is provided by the runner daemon
- netns_regex: ^qrouter-.*
  daemon_startup_actions:
    - ip netns exec $NETNS sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1
    - ip netns exec $NETNS sysctl net.netfilter.nf_conntrack_tcp_loose=1
  inotify_actions:
    - IN_CREATE:
        - ip netns exec $NETNS sysctl net.netfilter.nf_conntrack_tcp_be_liberal=1
        - ip netns exec $NETNS sysctl net.netfilter.nf_conntrack_tcp_loose=1
```
We run this daemon as a systemd service, side by side with the `neutron-l3-agent` systemd service.
Apparently the `nf_conntrack_tcp_be_liberal` sysctl key [is only read][nf] either at module load
time or netns creation time, so it is really important the `netns-events.py` daemon runs *before*
`neutron-l3-agent` starts doing its thing.

Anyway, this won't probably solve all of our problems. I'm still on a massive rabbit hole with
`conntrackd`, that I'll leave for another day. Other than this small script to set the sysctl keys
I have more questions than answers. Again, I wonder what others do, or if there is something
fundamentally wrong with our cloud network architecture.

I'll keep researching how to deploy `neutron-l3-agent` in a more realiable fashion. If you have
more hints, are in the same situation, or have any other insight, please let me know!

[blueprints]:		https://wiki.openstack.org/wiki/Neutron/L3_High_Availability_VRRP
[lp]:			https://bugs.launchpad.net/neutron/+bug/1365438
[nf]:			https://elixir.bootlin.com/linux/latest/source/net/netfilter/nf_conntrack_proto_tcp.c#L1438
[logo]:			{{site.url}}/assets/networking.png
[script]:		https://github.com/aborrero/sys-avenger/blob/master/src/netns-events.py
[phab]:			https://phabricator.wikimedia.org/T268335
