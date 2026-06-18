---
title: TinyWebPlayground (and why I finally moved to Astro for my site)
description: "A cool thing on the web that my friend made, and why I finally consolidated my personal site and blog."
pubDatetime: 2026-06-18T19:56:24Z
tags:
  - others
draft: false
---

I have to admit that the redesign, redecoration, and rearchitecture of both my personal website and my blog have been very much inspired by my friends. I think I had lost the motivation for the past year (life responsibilities and all that), but everything changed when my friend Sam told me about his fun little website called tinywebplayground.com.

https://tinywebplayground.com

## TinyWebPlayground

What is it? Quite literally a website with a bunch of random little side projects. Some of them are games, others are status checkers, some are music emulation. It's really sick, actually. The [Daily Music Guesser](https://tinywebplayground.com/projects/music-guesser/) is one of my favorites. It's essentially Wordle, but for music.

One of the things he unveiled was Crossworld, a multiplayer crossword puzzle. He debuted the first iteration of it last month.

The idea behind Crossworld is that sometimes when you're doing a crossword (like the Mini on the New York Times), there are some clues that you would love to be able to delegate to someone you know has the answer. I would delegate things related to sewing or other crafty things to my fiancée, and it sucks that there's no way to do that. Kind of like "phone a friend" on certain game shows. Sam took that idea and made it the central theme of Crossworld: you're not the only one helping to figure out the crossword. It's you and anyone else you know who you think might know the answer. As you answer more and more clues, it unlocks other clues that you can then answer. At the end, it sometimes creates this cool image from all of the answered crossword clues.

The game is addicting. *Absolutely* addicting. There are so many categories and so many clues. It's collaborative. There's a leaderboard, but it's really more of a collaboration board. The cool thing is you can tag your friends like, "Hey, you might know the answer to this one," because every answer given reveals a new clue. It's a lot of fun.

It's cool to see my friends do whimsy things because it motivates me to want to do more whimsy things. I think I've needed that motivation for a little while now.

*Link to Sam's personal site:*

https://chocobosam.com/

## Why I rebuilt my site

The other half of this post is explaining why and how I fixed my personal site and blog. If you looked at it before, you might have noticed that my personal site (alexo.dev) was hosted on Ghost CMS, whereas my blog, even though it was a subdomain, was hosted on GitHub as a GitHub Pages Jekyll project. There was quite a separation between the two, which also meant twice the upkeep. Weird.

Like I said, I got inspiration from my friends to finally fix my stuff. I also wanted to make it easier to:
1. Add blog posts
2. Add the speaking engagements I do yearly, so there's an easy public record of where I've been and what I've spoken at
3. Put my speaking credentials right here on my site. It's something I've been doing at least once a year for the past three years now. I'm honestly a little tired of having to copy and paste my biography and speaking credentials from my own personal notes. I just want it on one site where any conference organizer can see it, or where I can grab it myself and know it's consistent.

I also wanted to give my side projects a proper home. Something I released almost two months ago now (but haven't even made a blog post about) is the mobile app that I pushed out to both the Google Play Store and the Apple App Store. That was a pretty big thing for me, and I didn't even talk about it on my own site. My own space. My digital garden.

I think part of that was because it felt like a lot of work to make those changes. On my previous site, some of my projects lived on the Ghost CMS half, and then I talked about other things in blog posts. It just felt disjointed to navigate.

## Why Astro

So I finally switched everything to Astro. It's all handled in the same place, version-controlled in Git. I only have to update things in one spot, and the whole goal was to make it as easy as possible for me to update. I only want to have to touch Markdown or YAML to make changes. Obviously, if I want to update the design of my website, that's going to be actual code, but for text-based things like blog posts, projects, and speaking engagements, I don't want to have to dig into code. That limits me to doing it from a computer.

If I'm only focusing on Markdown for all of my writing, then I can do that from my phone. Obsidian has a mobile app, and I can just write everything on the go. It doesn't have to be a sit-down-and-plan thing. I can do it spontaneously, and that's ultimately what I wanted.

## Looking ahead

All of this to say:
1. I'm grateful for my friends and the constant inspiration, pushing me to do more because it's fun. This is when I have fun, this is when I have whimsy, this is when I am joyous in life.
2. Sorry for subjecting you to the disjointed state of my old digital garden, but welcome to my new one.
3. I'm hoping this will make it a lot easier for me and give me more motivation to push out updates.
4. I think I'm actually going to integrate [Buttondown](https://buttondown.com/) so I can turn these blog posts into email campaigns. If people want to get updates from me, they don't have to remember to check my blog (though there is an [RSS feed](https://alexo.dev/rss.xml) you can absolutely subscribe to). They can also just get emailed directly. That's the goal.

I want to say that I think this is going to be easy for me, because I'm currently writing this entire blog post from my phone. I'm actually doing speech-to-text, so I think that sounds promising.
