---
layout: post
title:  "Wikimedia Toolforge and Grid Engine"
date:   2022-04-04 19:45 +0200
tags:	[wikimedia, toolforge]
---

![Logos][logos]

_This post was originally published in the [Wikimedia Tech blog][origin], authored by
Arturo Borrero Gonzalez._

One of the most important and successful products provided by the [Wikimedia Cloud Services][wmcs] team at the Wikimedia Foundation is
[Toolforge][toolforge], a hosting service commonly known in the industry as [Platform as a Service (PaaS)][paas]. In particular, it is a
platform that allows users and developers to run and use a variety of applications with the ultimate goal of helping the Wikimedia
mission from the technical side.

<!--more-->

Toolforge is powered by two different backend engines, [Kubernetes][k8s] and [Grid Engine][grid]. The two backends have traditionally
offered different features for tool developers. But as time moves forward we’ve learnt that Kubernetes is the future. Explaining why is
the purpose of this blog post: we want to share more information and reasoning behind this mindset.

There are a number of reasons that make Grid Engine poorly suitable to remain as execution backend in Toolforge:

* There has not been a new Grid Engine release (bug fixes, security patches, or otherwise) since 2016. This doesn’t feel like a project
being actively developed or maintained.
* The grid has poor support and controls for important aspects such as high availability, fault tolerance and self-recovery.
* Maintaining a healthy grid requires plenty of manual operations, like manual queue cleanups in case of failures, hand-crafted scripts
for pooling/depooling nodes, etc.
* There is no good or modern monitoring support for the grid, and we need to craft and maintain several monitoring pieces for proper
observability, and to be able to do proper maintenance.
* The grid is also strongly tied to the underlying operating system release version. Migrating from one Debian version to the next is
painful (a dedicated blog post about this will follow shortly).
* The grid imposes a strong dependency on NFS, another old technology. We would like to reduce dependency on NFS overall, and in the
future we will explore NFS-free approaches for Toolforge.
* In general, Grid Engine is old software, old technology, which can be replaced by more modern approaches for providing an equivalent
or better service.

As mentioned above, our desire is to cover all our grid-like needs with Kubernetes, a technology which has several benefits:

* Good high availability, fault tolerance and self-recovery semantics, constructs and facilities.
* Maintaining a running Kubernetes cluster requires little manual operations.
* There are good monitoring and observability options for Kubernetes deployments, including seamless integration with industry standards
like prometheus.
* Our current approach to deploying and upgrading Kubernetes is independent of the underlying operating system.
* While our current Kubernetes deployment uses NFS as a central component, there is support for using other, more modern, approaches for
the kind of shared storage needs we have in Toolforge.
* In general, Kubernetes is a modern technology, with a vibrant and healthy community, that enables new use cases and has enough
flexibility to adapt legacy ones.

The relationship between Toolforge and Grid Engine has been interesting over the years. The grid has been used for quite a lot of time,
we have plenty of documentation and established good practices. On the other hand, the grid is hard to maintain, imposes a heavy burden
on the WMCS team and is a technology we must eventually discontinue. How to accommodate the two realities is a refreshing challenge, one
that we hope to tackle together in the near future. A tradeoff exists here, but it is clear to us which option is best.

So we will work on deprecating and removing Grid Engine and migrating use cases into Kubernetes. This deprecation, however, will be done
with care, as we know our technical community relies on the grid for some import Toolforge tools. And some of these
workflows will need some adaptation in order to be fully supported on Kubernetes.

Stay tuned for more information on present and next works surrounding the Wikimedia Toolforge service. The next blog post will share more
concrete details.

_This post was originally published in the [Wikimedia Tech blog][origin], authored
by Arturo Borrero Gonzalez._

[logos]:	    {{site.url}}/assets/grid2k8s.png
[origin]:	    https://techblog.wikimedia.org/2022/03/14/toolforge-and-grid-engine/

[wmcs]:         https://wikitech.wikimedia.org/wiki/Help:Cloud_Services_introduction
[toolforge]:    https://wikitech.wikimedia.org/wiki/Portal:Toolforge/About_Toolforge
[paas]:         https://en.wikipedia.org/wiki/Platform_as_a_service
[k8s]:          https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
[grid]:         https://en.wikipedia.org/wiki/Oracle_Grid_Engine
