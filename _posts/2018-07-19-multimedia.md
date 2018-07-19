---
layout: post
title:  "Things you can do with Debian: multimedia editing"
date:   2018-07-19 10:28 +0200
tags:	[debian]
---

![Debian][debian]

The Debian operating system serves many purposes and you can do amazing things
with it. Apart of powering the servers behind big internet sites like
Wikipedia and others, you can use Debian in your PC or laptop. I've been doing
that for many years.

One of the great things you can do is some multimedia editing.
It turns out I love nature, outdoor sports and adventures, and I usually take
videos and photos with my friends while doing such activities. And when I
arrive home I love editing them for my other blog, or putting them together in
a video.

<!--more-->

![kdenlive][kdenlive_img]

The setup I've been using is composed of several different programs:

* [gimp][gimp] - image processing
* [audacity][audacity] - quick audio recording / editing
* [ardour][ardour] - audio recording / editing / mixing / mastering
* [kdenlive][kdenlive] - video editing / mixing
* [openshot][openshot] - video editing / mixing
* [handbrake][handbrake] - video transcoding

My usage of these tools ranges from very simple to more complex. In the case
of gimp, for example, I mostly do quick editting, crop, resize, fix colours,
etc.
I use audacity for quick audio recording and editing, like cutting a song in
half or quickly record my mic.
Ardour is such a powerfull DAW, which is more complex to use. I can use it
because my background in the audio business (did you know I worked as
recording/mixing/mastering engineer in a recording studio 10 years ago?).
The last amazing feature I discovered in Ardour was the hability to do
side-chain compression, great!

For video editing, I started using openshot some years ago, but I recently
switched to kdenlive, which from my point of view is more robust and more
fine-tunned. You should try both and decide which one fits your needs.

And another awesome tool in my setup is handbrake, which allows to easily
convert and transcode video between many formats, so you can reproduce your
videos in different platforms.

It amazes me how these FLOSS tools can be so usefull, powerful and easy to
install/use. From here, I would like to send a big **thanks you a lot!** to
all those upstream communities.

![Ardour][ardour_img]

In Debian, getting them is a matter of installing the packages from the
repositories. All this setup is waiting for you in the Debian archive.
This wouldn't be possible without the hard work of the
[Debian Multimedia team][debmultimedia] and other collaborators, who maintain
these packages ready to install and use. Well, in fact, thanks to every
single Debian contributor :-)


[debmultimedia]:	https://wiki.debian.org/DebianMultimedia
[ardour_img]:		{{site.url}}/assets/20180719-01-ardour.png
[kdenlive_img]:		{{site.url}}/assets/20180719-02-kdenlive.png
[debian]:		{{site.url}}/assets/debian-logo.jpg
[gimp]:			https://www.gimp.org/
[audacity]:		https://www.audacityteam.org/
[ardour]:		https://ardour.org/
[kdenlive]:		https://kdenlive.org/
[openshot]:		https://www.openshot.org/
[handbrake]:		https://handbrake.fr/
