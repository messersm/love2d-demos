# love2d-demos
A collection of (not necessarily playable) demos written
in [Löve](https://love2d.org), mainly used to learn Lua and Löve.

All of the source code is licensed under the [GPLv3](LICENSE).
The artwork however is subject to miscellaneous licenses, which
are presented in the credits section of each demo (and possibly
within the demo itself.)

In order to play them, you have to have Löve installed. Then simply
download the ``.love``-file and open it with Löve.

## Thunderstorm
![Thunderstorm screenshot](thunderstorm/screenshot.gif "Thunderstorm screenshot")

A little scene displaying a thunderstorm in a desolate city.
It's main focus is generating time-delayed sound and graphics.

**Löve-File:** [thunderstorm.love](bin/thunderstorm.love?raw=true)

**Credits:** [Credits](thunderstorm/credits.md)

## A circle amongst squares
![Circle screenshot](circle-amongst-squares/screenshot.png "A circle amongst squares screenshot")

A little horror "game", in which you are a circle amongst squares.
This one has directional sound in it, so earphones may be a good idea.
It has some collision detection (using [bump](https://github.com/kikito/bump.lua)) and I played around with
a pixel shader and am quite pleased with the results. :-)

**How to play:** Move with w, a, s, d or the cursor keys. Press escape to exit.

**Löve-File:** [circle-amongst-squares.love](bin/circle-amongst-squares.love?raw=true)

**Credits:** [Credits](circle-amongst-squares/credits.md)
