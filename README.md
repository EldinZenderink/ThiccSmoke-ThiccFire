# Welcome to the ThiccSmoke Repo!

Hi! Welcome to the development repo of ThiccSmoke! This repo is meant for tracking development progress, providing test versions, and track issues. If you want to have a go at changing/modifying and/or improving this mod, you are free to do so! I would appreciate some credit, but that is up to you!


# What is ThiccSmoke?

I was a bit fed up with the lack of smoke within Teardown. Smoke, when you look at actual building/house fires, is thick and black due to the improper combustion of materials. Smoke should billow out of all crevices, cracks, holes and windows where smoke can go. All this was sort of there in the game, but toned down a lot.

This is understandable, from performance and gameplay reasons, as this would limit visibility within a building to a huge decree. But that is what smoke is about!

What definitely is not in the game, is that different materials being on fire would create different types of smoke! Smoke can be thick black and a bit colored when burning toxic materials (plastic, etc) but if something like wood would burn it would create much less thick and more clear smoke.

So I went ahead and tried my hands on modding Teardown for the first time, with the mentioned idea behind smoke in mind. Unfortunately fire *location* detection directly from Teardowns API is currently not possible (*but in the works :D*). Thus I had to figure out a stochastic method of detecting fires. Which, not to boast to much, works quit well actually!

Basically this mod is just:

 - Find broken objects at the moment they break.
 - Determine location where it broke from.
 - There is fire there! Determine what is on fire.
 - SPAWN SMOKE

Of course the side effect of this method is that objects broken through user actions, not related to fire would also spawn smoke. This is the unfortunate side effect of not actually being able to determine a state of a voxel/shape through the Teardown API. I have however implemented a method that should disable spawning smoke at the determined locations so long a user action is performed + a timeout.

This will never be 100% perfect as the way it is, but I think the side effects are minimal and if you like fire and smoke, this is the mod for you!