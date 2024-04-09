---
layout:	post
title:	"How to use nftables from python"
date:	2020-11-22 19:08 +0200
tags:	[nftables]
---

![Netfilter logo][logo]

One of the most interesting (and possibly unknown) features of the nftables framework is the native
python interface, which allows python programs to access all nft features programmatically, from
the source code.

There is a high-level library, libnftables, which is responsible for translating the human-readable
syntax from the `nft` binary into low-level expressions that the nf_tables kernel subsystem can
run. The `nft` command line utility basically wraps this library, where all actual nftables logic
lives. You can only imagine how powerful this library is. Originally written in C, `ctypes` is used
to allow native wrapping of the shared lib object using pure python.

<!--more-->

To use nftables in your python script or program, first you have to install the libnftables library
and the python bindings. In Debian systems, installing the `python3-nftables` package should be
enough to have everything ready to go.

To interact with libnftables you have 2 options, either use the standard nft syntax or the JSON
format. The standard format allows you to send commands exactly like you would do using the `nft`
binary. This format is intended for humans, and it doesn't make a lot of sense in a programmatic 
interaction. Whereas JSON is pretty convenient, specially in a python environment, where there
are direct data structure equivalents.

The following code snippet gives you an example of how easy this is:

```python
#!/usr/bin/env python3

import nftables
import json

nft = nftables.Nftables()
nft.set_json_output(True)
rc, output, error = nft.cmd("list ruleset")
print(json.loads(output))
```

This is functionally equivalent to running `nft -j list ruleset`. Basically, all you have to do in
your python code is:

* import the nftables & json modules
* init the libnftables instance
* configure library behavior
* run commands and parse the output (ideally using JSON)

The key here is to use the JSON format. It allows performing ruleset modification in batches, i.e.
to create tables, chains, rules, sets, stateful counters, etc in a single atomic transaction, which
is the proper way to update firewalling and NAT policies in the kernel, to avoid inconsistent
intermediate states.

The JSON schema is pretty well documented in the [libnftables-json(5)][libnftables-json] manpage.
The following example is copy/pasted from there, and illustrates the basic idea behind the JSON
format. The structure accepts an arbitrary amount of commands which are interpreted in order of
appearance. For instance, the following standard syntax input:

```
flush ruleset
add table inet mytable
add chain inet mytable mychain
add rule inet mytable mychain tcp dport 22 accept
```

Translates into JSON as such:

```json
{ "nftables": [
    { "flush": { "ruleset": null }},
    { "add": { "table": {
        "family": "inet",
        "name": "mytable"
    }}},
    { "add": { "chain": {
        "family": "inet",
        "table": "mytable",
        "chain": "mychain"
    }}},
    { "add": { "rule": {
        "family": "inet",
        "table": "mytable",
        "chain": "mychain",
        "expr": [
            { "match": {
                "left": { "payload": {
                    "protocol": "tcp",
                    "field": "dport"
                }},
                "right": 22
            }},
            { "accept": null }
        ]
    }}}
]}
```
I encourage you to take a look at the manpage if you want to know more, and see how powerful this
interface is. I've created a git repository to host several source code examples using different
features of the library: [https://github.com/aborrero/python-nftables-tutorial][github]. I plan to
introduce more code examples as I learn and have time to create them.

There are several relevant projects out there using this nftables python integration already. One
of the most important pieces of software using it is `firewalld`. They
[started using the JSON format back in 2019][firewalld-json].

In the past, people interacting with iptables programmatically would either call the iptables
binary directly or, in the case of some C programs, hack libiptc/libxtables libraries into their
source code. The native python approach to use libnftables is a huge step forward, which should
come handy for developers, network engineers, integrators and other folks using the nftables
framework in a pythonic environment.

If you are interested in knowing how this python binding works, I invite you to take a look at the
[upstream source code, nftables.py][binding], which contains all the magic behind the scenes.

[github]:		    https://github.com/aborrero/python-nftables-tutorial
[binding]:		    https://git.netfilter.org/nftables/tree/py/src/nftables.py
[firewalld-json]:	https://firewalld.org/2019/09/libnftables-JSON
[libnftables-json]:	https://manpages.debian.org/unstable/libnftables1/libnftables-json.5
[logo]:			    {{site.url}}/assets/netfilter-logo3.png
