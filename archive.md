---
layout: page
title: Archive
permalink: /archive/
---

This is the archive of the blog *ral-arturo.org*.

| Date                                  | Post                                          |
|---------------------------------------|-----------------------------------------------| {% for post in site.posts %}
| {{ post.date | date: "%-d %b %Y" }}   | <a href="{{ post.url }}">{{ post.title }}</a> | {% endfor %}

