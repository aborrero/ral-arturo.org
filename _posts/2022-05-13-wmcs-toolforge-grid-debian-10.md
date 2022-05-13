---
layout: post
title:  "Toolforge GridEngine Debian 10 Buster migration"
date:   2022-05-13 11:42 +0200
tags:	[wikimedia, toolforge]
---

![Toolforge logo, a circle with an anvil in the middle][tf-logo]

_This post was originally published in the [Wikimedia Tech blog][origin], authored by Arturo Borrero Gonzalez._

In accordance with our operating system upgrade policy, we should migrate our servers to Debian Buster. 

As discussed in [the previous post][prev], one of the most important and successful services provided by the [Wikimedia Cloud Services][wmcs] team at
the Wikimedia Foundation is [Toolforge][toolforge]. Toolforge is a platform that allows users and developers to run and use a variety of applications
with the ultimate goal of helping the Wikimedia mission from the technical side.

<!--more-->

As you may know already, all Wikimedia Foundation servers are powered by Debian, and this includes Toolforge and Cloud VPS. The Debian Project mostly
follows a two year cadence for releases, and Toolforge has been using Debian Stretch for some years now, which nowadays is considered “old-old-stable”.
In accordance with our [operating system upgrade policy][osupgrade], we should migrate our servers to Debian Buster.

Toolforge’s two different backend engines, Kubernetes and Grid Engine, are impacted by this upgrade policy. Grid Engine is notably tied to the underlying
Debian release, and the execution environment offered to tools running in the grid is limited to what the Debian archive contains for a given release.
This is unlike in Kubernetes, where tool developers can leverage container images and decouple the runtime environment selection from the base operating
system.

Since the Toolforge grid original conception, we have been doing the same operation over and over again:

* Prepare a parallel grid deployment with the new operating system.
* Ask our users (tool developers) to evaluate a newer version of their runtime and programming languages.
* Introduce a migration window and coordinate a quick migration.
* Finally, drop the old operating system from grid servers.

We’ve done this type of migration several times before.  The last few ones were Ubuntu Precise to Ubuntu Trusty and Ubuntu Trusty to Debian Stretch.
But this time around we had some special angles to consider.

####  So, you are upgrading the Debian release

* You are migrating to Debian 11 Bullseye, no?
* No, we’re migrating to Debian 10 Buster
* Wait, but Debian 11 Bullseye exists!
* Yes, we know! Let me explain…

We’re migrating the grid from Debian 9 Stretch to Debian 10 Buster, but perhaps we should be migrating from Debian 9 Stretch to Debian 11 Bullseye
directly. This is a legitimate concern, and we discussed it [in September 2021][discussion]. 

![A timeline showing Debian versions since 2014][timeline]

Back then, our reasoning was that skipping to Debian 11 Bullseye would be more difficult for our users, especially because greater jump in version
numbers for the underlying runtimes.  Additionally, all the migration work started before Debian 11 Bullseye was released. Our original intention was
for the migration to be completed before the release. For a couple of reasons the project was delayed, and when it was time to restart the project we
decided to continue with the original idea.

We had some work done to get Debian 10 Buster working correctly with the grid, and supporting Debian 11 Bullseye would require an additional effort. We
didn’t even check if Grid Engine could be installed in the latest Debian release. For the grid, in general, the engineering effort to do a N+1 upgrade is
lower than doing a N+2 upgrade. If we had tried a N+2 upgrade directly, things would have been much slower and difficult for us, and for our users.

In that sense, our conclusion was to not skip Debian 10 Buster.

#### We no longer want to run Grid Engine

In a [previous blog post][prev] we shared information about our desired future for Grid Engine in Toolforge. Our intention is to discontinue our usage of
this technology.

#### No grid? What about my tools?

![Toolforge logo, a circle with an anvil in the middle][tf-logo]

Traditionally there have been two main workflows or use cases that were supported in the grid, but not in our Kubernetes backend:

* Running jobs, long-running bots and other scheduled tasks.
* Mixing runtime environments (for example, a nodejs app that runs some python code).

The good news is that work to handle the continuity of such use cases has already started. This takes the form of two main efforts:

* The Toolforge buildpacks project — to support arbitrary runtime environments.
* The Toolforge Jobs Framework — to support jobs, scheduled tasks, etc.

In particular, the Toolforge Jobs Framework has been available for a while in an open beta phase. We did some initial design and implementation, then
deployed it in Toolforge for some users to try it and report bugs, report missing features, etc.

These are complex, and feature-rich projects, and they deserve a dedicated blog post. More information on each will be shared in the future. For now, it
is worth noting that both initiatives have some degree of development already.

The conclusion

Knowing all the moving parts, we were faced with a few hard questions when deciding how to approach the Debian 9 Stretch deprecation:

* Should we not upgrade the grid, and focus on Kubernetes instead? Let Debian 9 Stretch be the last supported version on the grid?
* What is the impact of these decisions on the technical community? What is best for our users?

The choices we made are already known in the community. A couple of weeks ago [we announced the Debian 9 Stretch Grid Engine deprecation][announce]. In
parallel to this migration, we decided to promote the new [Toolforge Jobs Framework][jobs], even if it’s still in beta phase. This new option should help
users to future-proof their tool, and reduce maintenance effort. An early migration to Kubernetes now will avoid any more future grid problems.

We truly hope that Debian 10 Buster is the last version we have for the grid, but as they say, hope is not a good strategy when it comes to engineering.
What we will do is to work really hard in bringing Toolforge to the service level we want, and that means to keep developing and enabling more
Kubernetes-based functionalities.

Stay tuned for more upcoming blog posts with additional information about Toolforge.

_This post was originally published in the [Wikimedia Tech blog][origin], authored by Arturo Borrero Gonzalez._

[logos]:	    {{site.url}}/assets/grid2k8s.png
[timeline]:     {{site.url}}/assets/os-upgrade-timeline.png
[tf-logo]:      {{site.url}}/assets/toolforge_logo.png

[origin]:	    https://techblog.wikimedia.org/2022/03/16/toolforge-gridengine-debian-10-buster-migration/

[prev]:         {{site.url}}/2022/04/04/wmcs-toolforge-grid.html
[wmcs]:         https://wikitech.wikimedia.org/wiki/Help:Cloud_Services_introduction
[toolforge]:    https://wikitech.wikimedia.org/wiki/Portal:Toolforge/About_Toolforge
[osupgrade]:    https://wikitech.wikimedia.org/wiki/Operating_system_upgrade_policy
[discussion]:   https://phabricator.wikimedia.org/T277653#7378774
[announce]:     https://lists.wikimedia.org/hyperkitty/list/cloud-announce@lists.wikimedia.org/thread/EPJFISC52T7OOEFH5YYMZNL57O4VGSPR/
[jobs]:         https://wikitech.wikimedia.org/wiki/Help:Toolforge/Jobs_framework
