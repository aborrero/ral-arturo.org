---
layout: post
title:  "Debunk some Debian myths"
date:   2017-05-11 18:21 +0200
tags:	[debian, cusl]
---

![Debian CUSL 11][debian-cusl11]

Debian has many years of history, about 25 years already.
With such a long travel over the continous field of developing our Universal
Operating System, some miths, false accusations and bad reputation has arisen.

Today I had the oportunity to discuss this topic, I was invited to give a Debian
talk in the ["11º Concurso Universitario de Software Libre"][cusl], a spanish
contest for students to develop and dig a bit into free-libre open source
software (and hardware).

<!--more-->

In this talk, I walked through some of the most common debian myts, and I
would like to summarice here some of them, with a short explanation of why I
think they should be debunked.

![Picture of the talk][talk]

***myth #1: debian is old software***

Please, use testing or stable-backports. If you use debian stable your system
will in fact be stable and that means: updates contain no new software but
only fixes.

***myth #2: debian is slow***

We compile and build most of our packages with industry-standar compilers and
options. I don't see a significative difference on how fast linux kernel or
mysql run in a CentOS or in Debian.

***myth #3: debian is difficult***

I already discussed about this issue back in
[Jan 2017, Debian is a puzzle: difficult][oldpost].


***myth #4: debian has no graphical environment***

This is, simply put, false. We have gnome, kde, xfce and more.
The basic debian installer ask you what do you want at install time.

***myth #5: since debian isn't commercial, the quality is poor***

Did you know that most of our package developers are experts in their packages
and in their upstream code? Not all, but most of them.
Besides, many package developers get paid to do their debian job.
Also, there are external companies which do indeed offer support for
debian (see [freexian][freexian] for example).

***myth #6: I don't trust debian***

Why? Did we do something to gain this status? If so, please let us know.
You don't trust how we build or configure our packages? You don't trust
how we work?
Anyway, I'm sorry, you have to trust someone if you want to use any kind
of computer. Supervising every single bit of your computer isn't practical
for you. Please trust us, we do our best.

***myth #7: nobody uses debian***

I don't agree. Many people use debian. They even run debian in the
[International Space Station][iss]. Do you count derivatives, such as Ubuntu?

I believe this myth is just pointless, but some people out there really think
nobody uses debian.

***myth #8: debian uses systemd***

Well, this is true. But you can run sysvinit if you want.
I prefer and recommend systemd though :-)

***myth #9: debian is only for servers***

No. See myths #1, #2 and #4.

You may download my slides in [PDF][pdf] and in [ODP][odp] format
(only in spanish, sorry for english readers).

[debian-cusl11]:	{{site.url}}/assets/debian-cusl11.jpg
[cusl]:			http://www.concursosoftwarelibre.org/1617/
[oldpost]:		{{site.url}}/2017/01/17/debian-puzzle.html
[PDF]:			{{site.url}}/assets/debian_no_es_lo_que_piensas_pdf.pdf
[ODP]:			{{site.url}}/assets/debian_no_es_lo_que_piensas.odp
[freexian]:		https://www.freexian.com/
[iss]:			https://www.fsf.org/blogs/community/gnu-linux-chosen-as-operating-system-of-the-international-space-station
[talk]:			{{site.url}}/assets/debian-cusl11-pic.png
