---
layout: post
title:  "A better Toolforge: upgrading the Kubernetes cluster"
date:   2020-05-18 19:00 +0200
tags:	[kubernetes]
---

![Logos][logos]

_This post was originally published in the [Wikimedia Tech blog][origin], and
is authored by Arturo Borrero Gonzalez and Brooke Storm._

One of the most successful and important products provided by the [Wikimedia
Cloud Services][wmcs] team at the Wikimedia Foundation is
[Toolforge][toolforge]. Toolforge is a platform that allows users and
developers to run and use a variety of applications that help the Wikimedia
movement and mission from the technical point of view in general. Toolforge is
a hosting service commonly known in the industry as a Platform as a Service
(PaaS). Toolforge is powered by two different backend engines,
[Kubernetes][k8s] and [GridEngine][sge]. 

<!--more-->

This article focuses on how we made a better Toolforge by integrating a newer
version of Kubernetes and, along with it, some more modern workflows.

The starting point in this story is 2018. Yes, two years ago! We identified
that we could do better with our Kubernetes deployment in Toolforge. We were
using a very old version, v1.4. Using an old version of any software has more
or less the same consequences everywhere: you lack security improvements and
some modern key features.

Once it was clear that we wanted to upgrade our Kubernetes cluster, both the
engineering work and the endless chain of challenges started.

It turns out that Kubernetes is a complex and modern technology, which adds
some extra abstraction layers to add flexibility and some intelligence to a
very old systems engineering need: hosting and running a variety of
applications. 

Our first challenge was to understand what our use case for a modern Kubernetes
was. We were particularly interested in some key features:

* The increased security and controls required for a public user-facing
service, using RBAC, PodSecurityPolicies, quotas, etc.
* Native multi-tenancy support, using namespaces
* Advanced web routing, using the Ingress API

Soon enough we faced another Kubernetes native challenge: the documentation.
For a newcomer, learning and understanding how to adapt Kubernetes to a given
use case can be really challenging. We identified some baffling patterns in the
docs. For example, different documentation pages would assume you were using
different Kubernetes deployments (Minikube vs kubeadm vs a hosted service). We
are running Kubernetes like you would on bare-metal (well, in
[CloudVPS][cloudvps] virtual machines), and some documents directly referred to
ours as a corner case.

During late 2018 and early 2019, we started brainstorming and prototyping. We
wanted our cluster to be reproducible and easily rebuildable, and in the
Technology Department at the Wikimedia Foundation, we rely on [Puppet][puppet]
for that.
One of the first things to decide was how to deploy and build the cluster while
integrating with Puppet. This is not as simple as it seems because Kubernetes
itself is a collection of reconciliation loops, just like Puppet is. So we had
to decide what to put directly in Kubernetes and what to control and make
visible through Puppet. We decided to stick with kubeadm as the deployment
method, as it seems to be the more upstream-standardized tool for the task. We
had to make some interesting decisions by trial and error, like where to run
the required etcd servers, what the kubeadm init file would look like, how to
proxy and load-balance the API on our bare-metal deployment, what network
overlay to choose, etc. If you take a look at our [public notes][notes], you
can get a glimpse of the number of decisions we had to make.

Our Kubernetes wasn’t going to be a generic cluster, we needed a Toolforge
Kubernetes service. This means we don’t use some of the components, and also,
we add some additional pieces and configurations to it. By the second half of
2019, we were working full-speed on the new Kubernetes cluster. We already had
an idea of what we wanted and how to do it. 

There were a couple of important topics for discussions, for example:

* Ingress
* Validating admission controllers
* Security policies and quotas
* PKI and user management

We will describe in detail the final state of those pieces in another blog
post, but each of the topics required several hours of engineering time,
research, tests, and meetings before reaching a point in which we were
comfortable with moving forward.

By the end of 2019 and early 2020, we felt like all the pieces were in place,
and we started thinking about how to migrate the users, the workloads, from the
old cluster to the new one. This migration plan mostly materialized in a
[Wikitech page][migration] which contains concrete information for our users
and the community.

The interaction with the community was a key success element. Thanks to our
vibrant and involved users, we had several early adopters and beta testers that
helped us identify early flaws in our designs. The feedback they provided was
very valuable for us. Some folks helped solve technical problems, helped with
the migration plan or even helped make some design decisions. Worth noting that
some of the changes that were presented to our users were not easy to handle
for them, like new quotas and usage limits. [Introducing new workflows and
deprecating old ones is always a risky operation][xkcd].

Even though the migration procedure from the old cluster to the new one was
fairly simple, there were some rough edges. We helped our users navigate them.
A common issue was [a webservice not being able to run in the new cluster due
to stricter quota limiting the resources for the tool][quota]. Another example
is [the new Ingress layer failing to properly work with some webservices’s
particular options][ingress].

By March 2020, we no longer had anything running in the old Kubernetes cluster,
and the migration was completed. We then started thinking about another step
towards making a better Toolforge, which is introducing the **toolforge.org**
domain. There is plenty of information about the change to this new domain in
[Wikitech News][domain].

The community wanted a better Toolforge, and so do we, and after almost 2 years
of work, we have it!  All the work that was done represents the commitment of
the Wikimedia Foundation to support the technical community and how we really
want to pursue technical engagement in general in the Wikimedia movement. In a
follow-up post we will present and discuss more in-depth about some technical
details of the new Kubernetes cluster, stay tuned!

_This post was originally published in the [Wikimedia Tech blog][origin], and
is authored by Arturo Borrero Gonzalez and Brooke Storm._

[wmcs]:		https://wikitech.wikimedia.org/wiki/Help:Cloud_Services_Introduction
[toolforge]:	https://wikitech.wikimedia.org/wiki/Portal:Toolforge/About_Toolforge
[k8s]:		https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/
[sge]:		https://en.wikipedia.org/wiki/Oracle_Grid_Engine
[cloudvps]:	https://wikitech.wikimedia.org/wiki/Portal:Cloud_VPS
[puppet]:	https://wikitech.wikimedia.org/wiki/Puppet
[notes]:	https://wikitech.wikimedia.org/wiki/Portal:Toolforge/Admin/Kubernetes/2020_Kubernetes_cluster_rebuild_plan_notes
[migration]:	https://wikitech.wikimedia.org/wiki/News/2020_Kubernetes_cluster_migration
[xkcd]:		https://xkcd.com/1172/
[quota]:	https://phabricator.wikimedia.org/T243580
[ingress]:	https://phabricator.wikimedia.org/T245426
[domain]:	https://wikitech.wikimedia.org/wiki/News/Toolforge.org
[origin]:	https://techblog.wikimedia.org/2020/05/18/a-better-toolforge-upgrading-the-kubernetes-cluster/
[logos]:	{{site.url}}/assets/toolforge_kubernetes_post_800x400.png
