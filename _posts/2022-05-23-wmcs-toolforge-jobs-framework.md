---
layout: post
title:  "Toolforge Jobs Framework"
date:   2022-05-23 21:19 +0200
tags:	[wikimedia, toolforge]
---

![Toolforge jobs framework diagram][diagram]

_This post was originally published in the [Wikimedia Tech blog][origin], authored by Arturo Borrero Gonzalez._

This post continues the discussion of Toolforge updates as described in a [previous post][prev]. Every non-trivial task performed in Toolforge (like
executing a script or running a bot) should be dispatched to a job scheduling backend, which ensures that the job is run in a suitable place with sufficient resources.

<!--more-->

Jobs can be scheduled synchronously or asynchronously, continuously, or simply executed once. The basic principle of running jobs is fairly straightforward:

* You create a job from a submission server (usually `login.toolforge.org`).
* The backend finds a suitable execution node to run the job on, and starts it once resources are available.
* As it runs, the job will send output and errors to files until the job completes or is aborted.

So far, if a tool developer wanted to work with jobs, the Toolforge Grid Engine backend was the only suitable choice. This is despite the fact that
Kubernetes supports this kind of workload natively. The truth is that we never prepared our Kubernetes environment to work with jobs. Luckily that has
changed.

#### We no longer want to run Grid Engine

In a [previous blog post][prev] we shared information about our desired future for Grid Engine in Toolforge. Our intention is to discontinue our usage of
this technology.

#### Convenient way of running jobs on Toolforge Kubernetes

Some advanced Toolforge users really wanted to use Kubernetes. They were aware of the lack of abstractions or helpers, so they were forced to use the raw
Kubernetes API. Eventually, they figured everything out and managed to succeed. The result of this move was in the form of [docs on Wikitech][raws] and a
few dozen jobs running on Kubernetes for the first time.

We were aware of this, and this initiative was much in sync with our ultimate goal: to promote Kubernetes over Grid Engine. We rolled up our sleeves and
started thinking of a way to abstract and make it easy to run jobs without having to deal with lots of YAML and the raw Kubernetes API.

There is a precedent: the webservice command does exactly that. It hides all the details behind a simple command line interface to start/stop a web app
running on Kubernetes. However, we wanted to go even further, be more flexible and prepare ourselves for more situations in the future: we decided to
create a complete new REST API to wrap the jobs functionality in Toolforge Kubernetes. The Toolforge Jobs Framework was born.

#### Toolforge Jobs Framework components

The new framework is a small collection of components. As of this writing, we have three:

* The REST API — responsible for creating/deleting/listing jobs on the Kubernetes system.
* A command line interface — to interact with the REST API above.
* An emailer — to notify users about their jobs activity in the Kubernetes system.

![Toolforge jobs framework diagram][diagram]

There were a couple of challenges that weren’t trivial to solve. The authentication and authorization against the Kubernetes API was one of them. The other
was deciding on the semantics of the new REST API itself. If you are curious, we invite you to take a look at
[the documentation we have in wikitech][admindocs].

#### Open beta phase

Once we gained some confidence with the new framework, in July 2021 we decided to start a beta phase. We suggested some advanced Toolforge users try out
the new framework. We tracked this phase in [Phabricator][phabbeta], where our collaborators quickly started reporting some early bugs, helping each other,
and creating new feature requests.

Moreover, when we launched the [Grid Engine migration from Debian 9 Stretch to Debian 10 Buster][migration] we took a step forward and started promoting
the new jobs framework as a viable replacement for the grid. Some official [documentation pages were created on wikitech][jobs] as well.

As of this writing the framework continues in beta phase. We have solved basically all of the most important bugs, and we already started thinking on
how to address the few feature requests that are missing.

We haven’t yet established yet the criteria for leaving the beta phase, but it would be good to have:

* Critical bugs fixed and most feature requests addressed (or at least somehow planned).
* Proper automated test coverage. We can do better on testing the different software components to ensure they are as bug free as possible. This also would make sure that contributing changes is easy.
* [REST API swagger][swagger] integration.
* Deployment automation. Deploying the REST API and the emailer is tedious. This is tracked in [Phabricator][automation].
* Documentation, documentation, documentation.

#### Limitations

One of the limitations we bear in mind [since early on in the development process][early] of this framework was the support for mixing different programming
languages or runtime environments in the same job.

Solving this limitation is currently one of the WMCS team priorities, because this is one of the key workflows that was available on Grid Engine.
The moment we address it, the framework adoption will grow, and it will pretty much enable the same workflows as in the grid, if not more advanced and
featureful.

Stay tuned for more upcoming blog posts with additional information about Toolforge.

_This post was originally published in the [Wikimedia Tech blog][origin], authored by Arturo Borrero Gonzalez._

[diagram]:      {{site.url}}/assets/toolforge_jobs_framework.png
[origin]:	    https://techblog.wikimedia.org/2022/03/18/toolforge-jobs-framework/
[prev]:         {{site.url}}/2022/04/04/wmcs-toolforge-grid.html
[jobs]:         https://wikitech.wikimedia.org/wiki/Help:Toolforge/Jobs_framework
[raw]:          https://wikitech.wikimedia.org/wiki/Help:Toolforge/raw_kubernetes_jobs
[admindocs]:    https://wikitech.wikimedia.org/wiki/Portal:Toolforge/Admin/Kubernetes/jobs#The_framework
[phabbeta]:     https://phabricator.wikimedia.org/T285944
[migration]:    https://wikitech.wikimedia.org/wiki/News/Toolforge_Stretch_deprecation
[swagger]:      https://en.wikipedia.org/wiki/Swagger_(software)
[automation]:   https://phabricator.wikimedia.org/T291915
[early]:        https://wikitech.wikimedia.org/w/index.php?title=Wikimedia_Cloud_Services_team/EnhancementProposals/Toolforge_jobs&diff=1895051&oldid=1895049
[raws]:         https://wikitech.wikimedia.org/wiki/Help:Toolforge/Raw_Kubernetes_jobs
