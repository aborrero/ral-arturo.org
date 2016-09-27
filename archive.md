---
layout: page
title: Archive
permalink: /archive/
---

This is the archive of the blog *ral-arturo.org*.

<ul>
	{% for post in site.posts %}
	<li>
		{{ post.date | date: "%-d %b %Y" }} <a href="{{ post.url }}">{{ post.title }}</a>
	</li>
	{% endfor %}
</ul>
