---
layout: post
title: 'Of Productivity and Evil Gradle Scripts'
date: '2014-04-03 16:00:00'
description: "Learning how to work around red tape and do things elegantly in Gradle"
categories:
  - code
  - work
  - procrastination
  - android
  - gradle
  - ponies
---

Last time, I said I would write more often.

This was clearly a _lie_.

That aside, new blog post! Yay! Why a new blog post? Well, I'm busy running a test suite at work (it's stupidly slow) and already finished with most of my personal goals for today. Now, I'm forcing myself to write and update this blog, and hopefully include some cool ideas. One quickly comes to mind, about a helping a friend fix his employer's stupid, stupid Android build system.

__Disclaimer: I have non-tech friends who may be reading this, so I'm going to elaborate on things that you may already know if you're a fellow software engineer.__

First, the premise. This friend came to me, asking for help migrating his company's Android apps from Eclipse to Android's new [Gradle][gradle] build system. Now,  all of these apps have the same core code and the only difference was the res folder (which contains text, image and layout resources). This is usually solved very nicely by the flavours system in Gradle. Using the standard directory structure, you'd have something like this:

```
app/
`-- src/
    `-- main/
        `-- java/ (common code)
        `-- res/ (common resources)
    `-- flavour1
        `-- res/ (resources for the app "Flavour 1")
    `-- flavour2
        `-- res/ (resources for the app "Flavour 2")
```

Using this, Gradle would spit out ```app.apk```, ```flavour1.apk``` and ```flavour2.apk``` all with their own assets.

Yay! Problem solved!

_Except not._

Turns out, the employer had published all these apps with different keystores. For the uninitiated, when you build a version of an Android app to release to the Play Store you have to "sign" it cryptographically with a key you keep in a keystore. If you want to update this app, you have to sign the new APK file with the same keystore. This ensures that the person who publishes the app is the only one who's providing updates to users with it installed, even if their Google Play publishing account is compromised. This meant that merging keystores, or using a new one for all the apps, was simply impossible.

But this can be worked with, it's even easy! Loading the different keystores was simple, first by putting the keystores in source control. They're encrypted blobs, so there's no need to worry about someone stealing the keys. This makes your structure look something like this:

```
app/
`-- src/
    `-- main/
        `-- java/
            res/
    `-- flavour1
        `-- res/
            release.keystore
    `-- flavour2
        `-- res/
            release.keystore
```

Then in your ```build.gradle```, you can do this:

```groovy
android {
  ...

  signingConfigs {
    flavour1 {
      storeFile file('flavour1/release.keystore')
      storePassowrd "superSecretPassword"
      keyAlias "secretReleaseKey"
      keyPassword "secretReleaseKeyPassword"
    }
    flavour2 {
      storeFile file('flavour2/release.keystore')
      storePassowrd "superSecretPassword"
      keyAlias "secretReleaseKey"
      keyPassword "secretReleaseKeyPassword"
    }
    ...
  }

  buildTypes {
    flavour1 {
      signingConfig signingConfigs.flavour1
      packageName 'com.mycompany.flavour1'
    }
    flavour2 {
      signingConfig signingConfigs.flavour2
      packageName 'com.mycompany.flavour2'
    }
  }
}
```

Problem **_super_** solved!

**Except not.**

You see, this employer was concerned about keeping their keystore and key passwords in their source control (Mind you, this is a private, self-hosted, secured source control). Something about security and red tape.

<figure style="width:500px;margin-left:auto;margin-right:auto;">
  <img src="/images/lyra_table.gif" alt="Rage"/>
</figure>

At this point, I'm mad. I'm not even working for this company, just helping my friend out of pity, and I'm solving these major, complex, corporate-BS issues for them. Suddenly, lightbulb! Flash of brilliance! What if we put the signing configs in their own gradle file, and omit that from source control? You then have a file that someone, somewhere who feels like being managerial can control, and nobody without it can build the app for the Play Store. It all takes three simple steps:

  1. Move the signingConfigs section from ```build.gradle``` to ```signing.gradle```, make sure to wrap it in ```android { ... }```</li>
  2. In ```build.gradle```, inside the ```android { ... }``` add ```apply from: 'signing.gradle'```
  3. ???
  4. Profit!

At this point, he was able to produce production builds of the company's apps just like the old build system and I got to revel in my victory.

<figure style="width:360px;margin-left:auto;margin-right:auto;">
  <img src="/images/luna_clap.gif"/>
</figure>

Anyway, you can expect more posts in the near future. I'd like to start blogging about things I'm actually doing closer to real-time, as well as customise the site a bit more. Cheers, and until next time!

[gradle]: http://tools.android.com/tech-docs/new-build-system/user-guide
