---
layout: post
title: "Wikimedia Hackathon 2023 Athens summary"
date: 2023-05-31 14:11 +0200
tags:  [wikimedia]
---

![Post logo][logo]

During the weekend of 19-23 May 2023 I attended the [Wikimedia hackathon 2023](https://www.mediawiki.org/wiki/Wikimedia_Hackathon_2023) in Athens,
Greece. The event physically reunited folks interested in the more technological aspects of the Wikimedia movement in person for the
first time [since 2019][wikimania]. The scope of the hacking projects include (but was not limited to)
tools, wikipedia bots, gadgets, server and network infrastructure, data and other technical systems.

My role in the event was two-fold: on one hand I was in the event because of my role as SRE in the Wikimedia Cloud Services team, where we provided
very valuable services to the community, and I was expected to support the technical contributors of the movement that were around. Additionally, and
because of that same role, I did some hacking myself too, which was specially augmented given I generally collaborate on a daily basis with some
community members that were present in the hacking room.

<!--more-->

The hackathon had some conference-style track and I ran a session with my coworker Bryan, called
[Past, Present and Future of Wikimedia Cloud Services (Toolforge and friends)](https://phabricator.wikimedia.org/T333939)
[(slides)](https://commons.wikimedia.org/wiki/File:Past_Present_and_Future_of_WMCS.pdf) which was very satisfying to deliver given the friendly space
that it was. I attended a bunch of other sessions, and all of them were interesting and well presented. The number of ML themes that were present in
the program schedule was exciting. I definitely learned a lot from attending those sessions, from how LLMs work, some
fascinating applications for them in the wikimedia space, to what were some industry trends for training and hosting ML models.

![Session][session]

Despite the sessions, the main purpose of the hackathon was, well, hacking. While I was in the hacking space for more than 12 hours each day, my
ability to get things done was greatly reduced by the constant conversations, help requests, and other social interactions with the folks. Don’t get
me wrong, I embraced that reality with joy, because the social bonding aspect of it is perhaps the main reason why we gathered in person instead of
virtually.

That being said, this is a rough list of what I did:

* Helped review the status of [Migrate bldrwnsch from Toolforge GridEngine to Toolforge Kubernetes](https://phabricator.wikimedia.org/T319593)
* Helped the maintainer of the [bodh Toolforge tool get it working with a reverse proxy](https://phabricator.wikimedia.org/T337190)
and started conversations about [how to facilitate the use case](https://phabricator.wikimedia.org/T337191).
* Discussed persistent storage options in Toolforge, which resulted in [some conversations within the WMCS team](https://phabricator.wikimedia.org/T337192).
* Had several debates with several folks on what computing abstractions we are providing, including Toolforge as a PaaS, raw Kubernetes access, or even if
we should continue offering virtual machines to the community.
* [Patched toolforge-weld](https://gitlab.wikimedia.org/repos/cloud/toolforge/toolforge-weld/-/commit/5ce8bb56d64d490009a39fada0293e3ed4e3ef53) to
support some stuff required by [jobs-framework-cli](https://wikitech.wikimedia.org/wiki/Portal:Toolforge/Admin/Kubernetes/Jobs_framework).
Also made a release of it.
* Started [a patch for jobs-framework-cli](https://gerrit.wikimedia.org/r/c/cloud/toolforge/jobs-framework-cli/+/921412) to
use [toolforge-weld](https://gitlab.wikimedia.org/repos/cloud/toolforge/toolforge-weld). Which is still unfinished as of this writing.
* Debated about how to host ML models, what to do with GPUs etc.
* Suggested fellow SRE Riccardo in working on [cloud-private subnet: introduce new domain](https://phabricator.wikimedia.org/T335759) to
integrate with [Netbox](https://wikitech.wikimedia.org/wiki/Netbox).
* Uncovered [a flavor definition problem in our Openstack](https://phabricator.wikimedia.org/T337010) deployment.
* Reviewed many Toolforge account requests (most of them not related to the hackathon though), some quota requests and similar things.

The hackathon was also the final days of Technical Engagement as an umbrella group for WMCS and Developer Advocacy teams within the Technology
department of the Wikimedia Foundation because of an internal reorg.. We used the chance to reflect on the pleasant time we have had together since 2019
and take a final picture of the few of us that were in person in the event.

![Technical Engagement][te]

It wasn’t the first Wikimedia Hackathon for me, and I felt the same as in previous iterations: it was a welcoming space, and I was surrounded by
friends and nice human beings. I ended the event with a profound feeling of being privileged, because I was part of the Wikimedia movement, and
because I was invited to participate in it.


[logo]:         {{site.url}}/assets/20230530-hackathon-logo.png
[wikimania]:    {{site.url}}/2019/08/28/wikimania2019.html
[session]:      {{site.url}}/assets/20230531-hackathon-session.png
[te]:           {{site.url}}/assets/20230531-hackathon-te.png

