---
layout: post
title:  "Netfilter software in Debian Buster"
date:   2019-01-27 10:00 +0200
tags:	[debian, netfilter]
---

![Logo Debian - Netfilter][logo]

I would like to give a brief update on the status of Netfilter software
packages for Debian Buster.

Before getting into details, worth noting that [back in 2016][team_post], I
spearheaded the creation of a Debian packaging team to reunite all packaging
efforts related to Netfilter software in Debian. The team
[materialized finally][team_wiki], but in practice every maintainer works in
their own packages mostly.

<!--more-->

One of the most important changes for this release is a bump towards nftables,
the replacement of the iptables/xtables framework. This bump is just what was
decided at the [Netfilter Workshop 2018 in Berlin][workshop]: encourage users
to migrate to native nftables and promoting the nft-based version of the
iptables command line interface as a way to ease this migration.

The iptables Debian binary package now includes 2 flavours of the command line
interface, iptables-nft and iptables-legacy, and you can choose between the two
using the update-alternatives system. The default is iptables-nft.
This change affects ip6tables, arptables and ebtables as well, and all related
tools, like iptables-save and iptables-restore.
Thanks to the hard work by [Alberto Molina][alberto], both the arptables and
ebtables Debian packages, which were abandoned and in a bad shape, are now
refreshed and ready to work in this new setup. Both packages include the
-legacy version, while arptables-nft and ebtables-nft are present in the
iptables binary package.
This change goes in line with what other major Linux distributions out there
are doing, like [RedHat][rhel].

These changes took most of my available time. But just today I uploaded a new
package for the conntrack-tools suite, with a bit of refresh for Debian Buster,
with no major changes this time. Most Netfilter libraries are in shape, and
also other tools like ulogd2 or ipset (well, ipset requires a bit of refresh
yet).
My feeling is that Debian Buster is in very good shape, at least from Netfilter packages
point of view.

By the time of this writing, Debian Buster is still testing. And is meant to
get into full development [freeze in 2019-03-12][freeze]. I would expect the
release to actually happen somewhere around april to july 2019 perhaps.

[logo]:			{{site.url}}/assets/debian-netfilter.png
[freeze]:		https://wiki.debian.org/DebianBuster
[team_post]:		{{site.url}}/2016/11/30/debian-netfilter-team.html
[team_wiki]:		https://wiki.debian.org/Teams/pkg-netfilter
[rhel]:			https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8-beta/html-single/8.0_beta_release_notes/index#networking_2
[workshop]:		{{site.url}}/2018/06/16/nfws2018.html
[alberto]:		https://albertomolina.wordpress.com/
