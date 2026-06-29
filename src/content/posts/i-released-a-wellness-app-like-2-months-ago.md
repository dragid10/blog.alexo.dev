---
title: I released a wellness app like 2 months ago
description: Getting older is a bit scary
pubDatetime: 2026-06-29T04:10:47Z
tags:
  - "career"
  - "open-source"
  - "project"
draft: false
---
Okay so admittedly I did this two to three months ago but I figured I might as well actually do a blog post about it. I built a wellness app and, to be clear, it is explicitly *not* a health app because this does not meet health app criteria. It's a wellness app.

https://apps.apple.com/us/app/wellnot/id6759883780

https://play.google.com/store/apps/details?id=dev.alexo.symptom_tracker_app

## Why I built this

Let me talk about why at the ripe age of 28, I have learned that sometimes when I feel something in my body that I am unsure about, I should probably question it. I am no longer able to just ignore it and assume it will go away, and I don't think that's something people really tell you as you're getting older. The random side pain you might experience, the popping, the crackling, those things, they might happen, and you're not supposed to just ignore them. You're supposed to be curious about why they happened, because ignoring them can lead to an actual problem down the line.

I also have had friends and loved ones over the past year or two experience some health issues of their own and try to make sense of what's happening. I was kind of inspired by habit tracking practices that I've seen in bullet journals across the web, so I figured why not have a dedicated "habit tracker" but for your own personal things. That was kind of the intention behind **Wellnot**.

## How it works

It is a very open-ended app intentionally. I don't want to be prescriptive about what you can track, what you can't track, and necessarily how you do it.

<img src="/assets/uploads/i-released-a-wellness-app-like-2-months-ago/Screenshot_20260628-223256.png" alt="Wellnot home calendar view" width="300" />

### Symptoms

The way that it manifests in the app is that you choose a symptom that you think you're experiencing. That could be literally anything you want. You can use the built-in ones or add your own custom symptoms. Doesn't matter.

<img src="/assets/uploads/i-released-a-wellness-app-like-2-months-ago/Screenshot_20260628-223306.png" alt="Creating a new symptom entry in Wellnot" width="300" />

### Severity

You also get to select a severity for that symptom! That's important because the same symptom can feel drastically different on two different days. A symptom like a cough could be light on one day, and rattling the next.

### Mood

Then you choose a mood: how does it make you feel? It doesn't even have to be a bad feeling. There's a standard set of moods you could choose from that hopefully cover the range: good, bad, sad, angry, all of them. This is one of the few fields that you cannot add more of. While we have a giant range of emoji, I felt like there were a select few that needed to be captured in order to describe mood.

### Tags

You can also set tags for a new entry. Tags are supposed to be whatever you want to associate with a symptom. It's again very open-ended on purpose. A tag could be around a relative time that you've experienced this. Maybe it was after lunch, maybe it was before dinner, maybe you got bad sleep, maybe you just watched a weird movie. You get to choose what you associate with that entry.

<img src="/assets/uploads/i-released-a-wellness-app-like-2-months-ago/Screenshot_20260628-223419.png" alt="Tags and notes on a Wellnot entry" width="300" />

### Notes

Another optional part of this is you can just type up notes, anything that doesn't fit in any of the other things. You can get as specific as you want, anything goes!

### Privacy first

The best part about this is the app is **completely offline**, no internet needed, because this can be personal information. I don't want to be responsible for any of that. I want the data in the hands of the user. I don't want there to be even a thought of, "Oh could this have leaked out somewhere?" **Absolutely not.** I want this to be personal. I want this to be private.

### Data export

If you would like to export your data in some way, shape, or form, maybe you want to take your data and go actually create a spreadsheet, create graphs, create charts, and run it through an AI model if you want to. That is in your hands. You can export your data into a JSON format and a CSV format.

### Metrics

The most metrics you get in the app as of right now are frequency patterns, like:
- You've used this symptom **x** many times.
- You used this mood **x** many times.
- You've used this tag **x** many times.

<img src="/assets/uploads/i-released-a-wellness-app-like-2-months-ago/Screenshot_20260628-223647.png" alt="Wellnot summary with frequency patterns" width="300" />

That's about as much as the app is going to do. Yes, it's rather light and simple but that's intentional. I think that part of the experience of using the app is the mindfulness aspect: thinking about what you're feeling and why you're feeling it. I want the user to be able to look at their data and see those patterns themselves.

## Customization

I know that when I adopt new tools, I have trouble using them because they're not in my daily workflow, so I simply forget they exist.

<div style="display: flex; gap: 1rem;">
<img src="/assets/uploads/i-released-a-wellness-app-like-2-months-ago/settings-top.png" alt="Wellnot settings page" width="300" />
<img src="/assets/uploads/i-released-a-wellness-app-like-2-months-ago/settings-bottom.png" alt="Wellnot settings page continued" width="300" />
</div>

There's a feature to get a notification at a specific time of the day that reminds you to log an entry. Some people need that push. That's perfectly fine.

Also to put more customization in the user's hands, the intent with the app was that I wanted there to be as little effort to log an entry as possible and to be able to open it, do exactly what you need to, and get out ideally within 5 to 10 seconds. While there is a set of default symptoms, moods, and tags, you can hide any of the built-in ones you want. Alternatively you can also pin your favorite ones or the ones you frequently come back to so they're always at the top.

Let's also say that you experience the same thing kind of frequently, you had an entry the day before. You can just duplicate that entry and put it for the next day or for the current day. It's supposed to help things be easier.

<img src="/assets/uploads/i-released-a-wellness-app-like-2-months-ago/Screenshot_20260628-223557.png" alt="A Wellnot entry's detail view, with options to duplicate or delete it" width="300" />

And I also know myself. I know that sometimes thinking about things may feel a little bit boring. It may feel a little bit stale. It's good for you obviously but sometimes it's like, "This is not helping me with anything."

Well something that I also added to make it a little bit more rewarding to track your entries or be mindful of your symptoms is I added achievements to the app. There's supposed to be wholesome achievements, not like forcing you to do anything out of the ordinary. I want to reward you for just using the app as you normally would.

There are achievements like: "You've logged something three days in a row, good job!"

But there are also achievements like: "You missed a couple of days of logging, but came back. Good job!"

I don't want to penalize you for being human. That'd be weird. Humans forget stuff all the time, so coming back to it, cool, good job. That's great.

This is not supposed to be something you 100% have to do. The achievements are just there to keep things fun. If that's not really your jam, you can turn achievements off. That's completely your choice.

<div style="display: flex; gap: 1rem;">
<img src="/assets/uploads/i-released-a-wellness-app-like-2-months-ago/Screenshot_20260628-223710.png" alt="Wellnot achievements page" width="300" />
<img src="/assets/uploads/i-released-a-wellness-app-like-2-months-ago/Screenshot_20260628-223717.png" alt="More Wellnot achievements: milestones and tracking" width="300" />
</div>

## Open source and availability

The app is actually [open source](https://github.com/dragid10/Wellnot-app). Anyone can add features and anyone can look at the source code. If you want to take the app and add certain features that you want, feel free. Fork it, add stuff, release it as a brand new app with a different set of features. This code belongs to the public and I want everyone to feel empowered to do whatever they want with it.

Admittedly there have been a couple of feature requests that I have declined because they would start to border into health app territory and that's really not where I'm trying to go. I want to keep this as light and as open as possible but if you really want a feature that you don't currently see implemented in the app, please feel free to contribute the code yourself! I'd be even happy to help you and then install it on your device and re-release it under a new name.

### Technical Stuff

The app is built with Flutter so that it is cross-device compatible. Weirdly enough, it was fairly easy to get the app into the [iOS App Store](https://apps.apple.com/us/app/wellnot/id6759883780). I had a lot more trouble getting the app into the [Google Play Store](https://play.google.com/store/apps/details?id=dev.alexo.symptom_tracker_app), surprisingly, because the Google Play Store has a very stringent rule about you needing to have **14 active testers for 14 days straight** before you can even submit the app for production access.

(Mind you, I had already relaunched the app to production for the Apple App Store at this point. The app was in use. It was out in the wild. iPhone users could download it directly from the App Store and that was not enough to get into the Google Play Store.)

I had to still go through much more rigorous testing in order to get to the Google Play Store and it was a little bit challenging because I was already kind of feature complete at that point. They want to see you get user feedback and add more features, and there's not a whole lot to add here because I've already had that feedback. It was just a little weirdness there, but it finally launched on the Google Play Store a month and a half after already launching on the Apple App Store.

Furthermore, for my Android users, I know not everyone is huge on using Google Play Store, so you can also get this app on Obtainium and I will soon hopefully be making the app available on F-Droid for use as well so that you don't have to be locked into the Google ecosystem in order to download and use this. I also publish the APKs directly on the [Wellnot releases page on GitHub](https://github.com/dragid10/Wellnot-releases).

## Wrap-up

All in all, I am extremely proud of this app. My goal is not to get 100,000 downloads or anything. My goal is to release free open software that anyone can benefit from. If at least one person benefits from this then I will consider this a success. I just want to do my best to help people.

Feel free to download the app if you think it would help you. I'm extremely open to feedback, any and all types of feedback. If it's something that I don't think I will be doing, I'll let you know.

*Shoutout to all my alpha and beta testers that helped me get to production. I quite literally couldn't have done it without any of you!*

### Links

- [Wellnot on the App Store](https://apps.apple.com/us/app/wellnot/id6759883780)
- [Wellnot on Google Play](https://play.google.com/store/apps/details?id=dev.alexo.symptom_tracker_app)
- [Wellnot source code on GitHub](https://github.com/dragid10/Wellnot-app)
- [Wellnot releases on GitHub](https://github.com/dragid10/Wellnot-releases)
