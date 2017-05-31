---
layout: post
title:  "Debunking some Debian myths"
date:   2017-05-11 18:21 +0200
tags:	[debian, cusl]
---

![Debian CUSL 11][debian-cusl11]

Debian has many years of history, about 25 years already.
With such a long travel over the continuous field of developing our Universal
Operating System, some myths, false accusations and bad reputation has arisen.

Today I had the opportunity to discuss this topic, I was invited to give a
Debian talk in the ["11º Concurso Universitario de Software Libre"][cusl], a
Spanish contest for students to develop and dig a bit into free-libre open
source software (and hardware).

<!--more-->

In this talk, I walked through some of the most common Debian myths, and I
would like to summarize here some of them, with a short explanation of why I
think they should be debunked.

![Picture of the talk][talk]

***Myth #1: Debian is old software***

Please, use testing or stable-backports. If you use Debian stable your system
will in fact be stable and that means: updates contain no new software but
only fixes.

***Myth #2: Debian is slow***

We compile and build most of our packages with industry-standard compilers and
options. I don't see a significant difference on how fast Linux kernel or
MySQL run in a CentOS or in Debian.

***Myth #3: Debian is difficult***

I already discussed about this issue back in
[Jan 2017, Debian is a puzzle: difficult][oldpost].


***Myth #4: Debian has no graphical environment***

This is, simply put, false. We have gnome, KDE, XFCE and more.
The basic Debian installer asks you what do you want at install time.

***Myth #5: since Debian isn't commercial, the quality is poor***

Did you know that most of our package developers are experts in their packages
and in their upstream code? Not all, but most of them.
Besides, many package developers get paid to do their Debian job.
Also, there are external companies which do indeed offer support for
Debian (see [freexian][freexian] for example).

***Myth #6: I don't trust Debian***

Why? Did we do something to gain this status? If so, please let us know.
You don't trust how we build or configure our packages? You don't trust
how we work?
Anyway, I'm sorry, you have to trust someone if you want to use any kind
of computer. Supervising every single bit of your computer isn't practical
for you. Please trust us, we do our best.

***Myth #7: nobody uses Debian***

I don't agree. Many people use Debian. They even run Debian in the
[International Space Station][iss]. Do you count derivatives, such as Ubuntu?

I believe this myth is just pointless, but some people out there really think
nobody uses Debian.

***Myth #8: Debian uses systemd***

Well, this is true. But you can run sysvinit if you want.
I prefer and recommend systemd though :-)

***Myth #9: Debian is only for servers***

No. See myths #1, #2 and #4.

You may download my slides in [PDF][pdf] and in [ODP][odp] format
(only in Spanish, sorry for English readers).

[debian-cusl11]:	{{site.url}}/assets/debian-cusl11.jpg
[cusl]:			http://www.concursosoftwarelibre.org/1617/
[oldpost]:		{{site.url}}/2017/01/17/debian-puzzle.html
[PDF]:			{{site.url}}/assets/debian_no_es_lo_que_piensas_pdf.pdf
[ODP]:			{{site.url}}/assets/debian_no_es_lo_que_piensas.odp
[freexian]:		https://www.freexian.com/
[iss]:			https://www.fsf.org/blogs/community/gnu-linux-chosen-as-operating-system-of-the-international-space-station
[talk]:			{{site.url}}/assets/debian-cusl11-pic.png
