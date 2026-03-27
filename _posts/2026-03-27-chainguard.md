---
layout: post
title:  "New job at Chainguard"
date:   2026-03-27 10:00 +0200
tags:	[job, chainguard, security, linux]
---

![Chainguard logo][logo]

A few months ago, in June 2025, I joined [Chainguard][chainguard], a company focused on software supply chain security.
This post is a reflection on how I got here, what I've been doing, and why this role feels like a natural
fit for my interests in Linux and open source technology.

<!--more-->

## The company and its mission

Chainguard's mission is to make the software supply chain secure by default. The company is built around
the idea that the software we all depend on — from operating system packages to container base images — carries
hidden risk in the form of vulnerabilities, unverified provenance, and untrusted build processes.

The company is perhaps best known for [Chainguard Images][images]: a catalog of minimal, hardened container
base images that are continuously rebuilt and kept free of known CVEs. Each image is accompanied by a signed
[SBOM][sbom] (Software Bill of Materials) and a verifiable [provenance attestation][slsa], making it possible
to cryptographically verify what went into a given image and how it was built.

Chainguard has an extensive catalog of software, and maintaining it up-to-date and CVE-free is a significant
engineering challenge.

## What I do

I joined the Chainguard Sustaining Engineering team as a Senior Software Engineer. We are responsible
for maintaining packages and images in the software catalog up-to-date and CVE-free. The core of the business, basically.

We focus on the horizontal dimension of the catalog (pretty much all packages and images).

With +30,000 packages and +2,000 images, this is indeed an interesting task.

My role as Debian Developer, and my experiencie in the [Debian LTS project][lts] was extremely valuable when joning this
new team.

## Looking ahead

Software supply chain is truly a deep topic, gaining more and more relevance every day, especially as new technologies emerge
and get adopted everywhere.

Since early in my career, I saw a recurrent problem of how companies, enterprises, or even governments, relate to and consume
open source software, in a reliable, secure way. I believe Chainguard is doing the right things in the ecosystem,
and I'm happy to be participating in the effort.


[logo]:		{{site.url}}/assets/chainguard-logo.png
[chainguard]:	https://www.chainguard.dev
[images]:	https://www.chainguard.dev/chainguard-images
[slsa]:		https://slsa.dev
[sbom]:		https://www.cisa.gov/sbom
[lts]:		{{site.url}}/2025/04/17/lts.html
