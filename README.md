# Welcome to the ThiccSmoke & ThiccFire Repo!

Hi! Welcome to the development repo of ThiccSmoke (and since v4: ThiccFire!). This repo is meant for tracking development progress, providing test versions, and track issues. If you want to have a go at changing/modifying and/or improving this mod, you are free to do so! I would appreciate some credit, but that is up to you!


# What is ThiccSmoke and ThiccFire?

I was a bit fed up with the lack of smoke within Teardown. Smoke, when you look at actual building/house fires, is thick and black due to the improper combustion of materials. Smoke should billow out of all crevices, cracks, holes and windows where smoke can go. Fire, also never really grew bigger after a small increase, eventhough more fires are spawned. Even more so, intensity wasn't accounted for during spreading of fire at all! But this mod allows for all of that! All this was sort of there in the game, but toned down a lot.

This is understandable, from performance and gameplay reasons, as this would limit visibility within a building to a huge decree. But that is what smoke and fire is about!

What definitely is not in the game, is that different materials being on fire would create different types of smoke! Smoke can be thick black and a bit colored when burning toxic materials (plastic, etc) but if something like wood would burn it would create much less thick and more clear smoke.

So I went ahead and tried my hands on modding Teardown for the first time, with the mentioned idea behind smoke in mind. Unfortunately fire *location* detection directly from Teardowns API is currently not possible (*but in the works :D*). Thus I had to figure out a stochastic method of detecting fires. Which, not to boast to much, works quit well actually!

Basically this mod is just:

 - Determine fire locations using an binary search and the latest API (teardown v0.8.0).
 - There is fire there! Determine what is on fire.
 - SPAWN SMOKE and FIRE

# Steam workshop

Here you can find the mod on Steam:

[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2593750226)
