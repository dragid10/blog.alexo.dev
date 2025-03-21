---
title: I created a Tidbyt app!
excerpt:
date: 2025-03-20
tags:
  - Programming
  - Projects
  - Hardware
  - IOT
  - Open Source
author: content/authors/Alex-Oladele.md
---

With the First Robotics Competition season here, I took some time during a Saturday shop session to create a new Tidbyt app that I'm pretty darn proud of!

Using Starlark, I developed an app now available on the Tidbyt community repo. This app provides the current ranking of a specific team at the ongoing competition. It'll display the team's official Avatar, the team number, the team name and whatever the team's district event ranking is.

Ways it could probably be improved:

- Get the ranking from an arbitrary district event, instead of just the current district event
- Make the team name marquee a little more smooth (sometimes if the team name is long, it doesn't scroll nicely)
- Add the team's district points to the display
- Show the team's next qualification match number

For Tidbyt owners, the FRC Team Rank app is ready for download! Feel free to contribute by submitting a pull request if you encounter any bugs.
[Tidbyt Community Repo](https://github.com/tidbyt/community/tree/main/apps/frcteamrank)

![The FRC Team Rank app available in the Tidbyt app store. The pewview is of Team 6908 - Infuzed](../assets/uploads/tidbyt-app/tidbyt-app.png)

---

![The FRC Team Rank app running on an actual tidbyt, displaying the rank (or lacktherof) of Team 6908-Infuzed ](../assets/uploads/tidbyt-app/tidbyt-app-on-device.jpg)
