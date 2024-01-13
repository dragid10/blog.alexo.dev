---
excerpt: This is something I've been trying to figure out for the past couple of weeks.
header:
  overlay_image: >-
    https://upload.wikimedia.org/wikipedia/commons/9/9a/Visual_Studio_Code_1.35_icon.svg
  og_image: >-
    https://upload.wikimedia.org/wikipedia/commons/9/9a/Visual_Studio_Code_1.35_icon.svg
  caption: 'Photo credit: **Microsoft, Public domain, via Wikimedia Commons**'
  overlay_filter: 0.5
title: Connecting to TrueNAS Scale with VS Code SSH
date: 2021-12-02T03:00:00.000Z
tags:
  - home-server
  - knowledge-share
author: content/authors/Alex-Oladele.md
---

This is something I've been trying to figure out for the past couple of weeks. Trying to connect to my TrueNAS home server via VSCode remote just would not work some reason.

1. Download the [SSH remote extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) in VS Code
2. SSH into your TrueNAS server
3. In the file `/etc/ssh/sshd\_config` change the line `AllowTcpForwarding no` to `AllowTcpForwarding yes`
4. Open the Remote Explorer side panel in VS Code and connect to your TrueNAS server
5. If prompted, enter your password or ssh key passphrase
6. You should be able to connect without a problem!
