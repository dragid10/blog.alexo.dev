---
title: "ResMed Stats"
description: "Pebble app showing your ResMed myAir CPAP sleep stats for the past week, refreshed once a day in the background."
demo: "https://apps.repebble.com/bca44cfa4de14135915afbec"
status: "active"
tags: ["c", "javascript", "pebble"]
stack: ["C", "PebbleKit JS", "Pebble SDK"]
pixelArt: true
screenshots:
  - src: "/assets/uploads/projects/resmed-stats/score-good.png"
    alt: "ResMed Stats showing a myAir score of 92 with events per hour, usage, mask-off, and leak stats"
  - src: "/assets/uploads/projects/resmed-stats/score-ok.png"
    alt: "ResMed Stats showing an okay myAir score"
  - src: "/assets/uploads/projects/resmed-stats/score-bad.png"
    alt: "ResMed Stats showing a poor myAir score"
order: 8
---

ResMed Stats puts your CPAP therapy numbers on your wrist. It signs in to your ResMed myAir account and shows your myAir score for the past week, color-coded green, yellow or red, along with events per hour, usage, mask-off count and leak percentage. Up and Down step through the days, newest first.

Data is cached, so the app opens instantly and only fetches when it's stale. It also refreshes itself once a day in the background. In the phone settings you can choose which stats to show, switch to a colorblind-friendly monochrome mode, or replace the numbers with simple Good / OK / Poor labels. Your login stays on your phone, the watch only stores the sleep stats, and nothing goes anywhere except ResMed's own servers.
