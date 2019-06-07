turtles-own [mass distant velocityx velocityy a sphere] ;gives properties to the turtles
breed [stars star]                               ;breeds stars
breed [planets planet]                           ;breeds planets
breed [asteroids asteroid]                       ;breeds asteroids
breed [moons moon]                               ;breeds moons
planets-own [heading-star tow]            ;gives properties to the planets
stars-own [heading-star]                         ;gives properties to the stars

to setup           ;sets the world size and patch size
  ca
  resize-world     ;changes world size to 720 x 720 patch dimensions
  -360 360 -360 360
  set-patch-size 1 ;changes patch size to 1
end

to form_star                         ;creates the star that will be the center of the solar system
  create-stars 1 [set shape "circle" ;breeds a star, and sets the shape to circle
    set color star_color             ;sets the star's color to the choice made in the chooser
    set size star_size               ;sets the size to the choice made in the slider
    ifelse display_name?             ;uses a switch to determine if the star name is visible
    [set label star_name]            ;sets the label (if switch on) to star_name
    [set label ""]                   ;sets the label (if switch off) to blank
    set mass (size * 10)             ;sets the mass to the size x 10
    set sphere turtle 0
  ]
end

to update-heading-star                          ;procedure that updates a planet property asteroids and moons use to move identically to the planet
  ask planets [set heading-star towards one-of stars] ;sets heading-star to the heading of the planet to star 0
end

to update-sphere                                         ;procedure where planets ask asteroids and moons in their sphere of influence to set the sphere to the asking planet
  if breed = asteroids and any? planets in-radius (([size] of min-one-of planets [ xcor + ycor ]) * 2) [
    set sphere one-of planets in-radius (([size] of min-one-of planets [ xcor + ycor ]) * 2)
  ]
  if breed = moons and any? planets in-radius (([size] of min-one-of planets [ xcor + ycor ]) * 2) [
    set sphere one-of planets in-radius (([size] of min-one-of planets [ xcor + ycor ]) * 2)
  ]
end

to go                                                           ;procedure that incorporates planets, moons, and asteroids to interact using a circular orbit
  if sphere = 0 or sphere = nobody [
    set sphere one-of stars
  ]
  if breed = planets [
    circle_orbit
  ]
  update-sphere
  if breed = moons or breed = asteroids and sphere = one-of stars [
    set heading towards sphere
    rt 90
    fd (sin 0.5) * 2
    lt 1
  ]
end

to circle_orbit                                                                  ;procedure that allows bodies to move in a circular orbit around the star, and moons and asteroids to move identically to their sphere (if it is a planet)
  set heading towards sphere                                                     ;the turtle sets its heading towards its sphere, whether it is the star, or a planet
  update-heading-star                                                            ;planets update the property that moons and asteroids need to move identically
  if breed = planets [
    rt 90
    fd (sin 0.5) * 2
    lt 1
  ]
  ask moons [
    if [breed] of sphere = planets [
      set heading [heading-star] of sphere
      rt 90
      fd (sin 0.5) * 2
      lt 1
    ]
  ]
  ask asteroids [
    if [breed] of sphere = planets [
      set heading [heading-star] of sphere
      rt 90
      fd (sin 0.5) * 2
      lt 1
    ]
  ]
end

to orbit                                                ;actual orbit mechanism
  let p 1                                               ;make p
  set p 1                                               ;put it back every time
  if breed = planets [                                  ;more efficient than ask
    let s size                                          ;stores its size
    set s size                                          ;reset it each time
    if any? other planets in-radius (size / 2) and size >= ([ size ] of one-of other planets in-radius (size / 2)) [;checks if it is colliding with another planet and if its bigger
      set color scale-color (color) ((color mod 10 + ([color] of one-of other planets in-radius (size / 2)) mod 10) / (size / ([size] of one-of other planets in-radius (size / 2)))) 0 10; set the color to a blend of the small and the big (big color dominates)
      set velocityx velocityx + ([velocityx] of one-of other planets in-radius (size / 2)) * (([mass] of one-of other planets in-radius (size / 2)) / mass); change the velocity depending on the momentum of each
      set velocityy velocityy + ([velocityy] of one-of other planets in-radius (size / 2)) * (([mass] of one-of other planets in-radius (size / 2)) / mass); same for y
      carefully [; we sometimes get errors during collisions
        set size size + ([size] of one-of (other planets) in-radius (size / 2)); combine the sizes
        set mass size; reset the mass
        ask other planets in-radius (size / 2) [; kill the other one
          die
        ]
      ]
      [
      ]
    ]
    ask stars [; elaborate setup to change the angle of the planets
      repeat count planets [; does it for each planet; accounts for missing who numbers
        while [ not (any? planets with [ who = p ]) ] [; cycle through who numbers until you get a living planet
          set p p + 1
        ]
        let b 90 - towards planet p; make a new variable that is the angle we will look at
        ask planet p [
          set tow b; sets the angle of the planet to b
        ]
        set p p + 1; go to the next planet
      ]
      if any? planets in-radius ((size / 2) + s / 2) [; check if a planet collides
        set size size + s / 7; make it bigger, but it is dense, so nott too much
        set mass size * 10; reset the mass
        ask planets in-radius (size / 2) [; kill planets that run into it
          die
        ]
      ]
    ]
    pd; start drawing
    if a = 1 [; intial velocity function (happens once)
      set velocityx initial_velocity; this is easiest
      set velocityy 0
    ]
    affect; do the gravitation thing
    move-to patch (xcor + velocityx) (ycor + velocityy); move
    set a 0; stop the intial velocity setup
    set distant (xcor - [ xcor ] of one-of stars) ^ 2 + (ycor - [ ycor ] of one-of stars) ^ 2; save the distance to the star
  ]
end

to affect
  let accelerationx [mass] of one-of stars * (1 / abs (distant)) * cos (tow) * -15; make acceleration
  let accelerationy [mass] of one-of stars * (1 / abs (distant)) * sin (tow) * -15; same for y component
  set accelerationx [mass] of one-of stars * (1 / abs (distant)) * cos (tow) * -15; based on Gmm/r2
  set accelerationy [mass] of one-of stars * (1 / abs (distant)) * sin (tow) * -15; the sin makes it just for the y component
  set velocityx velocityx + accelerationx; accelerate in one direction
  set velocityy velocityy + accelerationy; accelrate perpendicularly
end

to form_planet [ plsize plcolor plname x y ]            ;creates a planet
  create-planets 1 [                                    ;breeds a planet                                 ;if the switch is on, then the orbit is visible (aka pd)
    set shape "circle"                                  ;sets the planet's shape to circle
    set color plcolor                                   ;sets the planet's color to the choice made in the chooser
    set size plsize                                     ;sets the planet's size to the choice made in the slider
    ifelse display_name?                                ;if the switch is on, then the name is visible (what is inputed)
    [set label plname]
    [set label ""]
    set mass size                                       ;sets the planet's mass based on its size
    setxy x y                                           ;sets spawn to what is inputed
    set sphere one-of stars                             ;sets the starting sphere to the star
    set distant (xcor - [ xcor ] of one-of stars) ^ 2 + ;sets the distant to the distance between the planet and the star, using a modified distance formula
    (ycor - [ ycor ] of one-of stars) ^ 2
    set a 1
    if random_planet_colors? [                          ;if switch is on, then the plabet gets a random color, rather than the input
      set color random 141
      if (color mod 10) < 1 [
        set color color + 1
      ]
    ]
  ]
  ask planets [if show_orbit? [pd]]                                  ;if the switch is on, then the orbit is visible (aka pd)
end

to planet_click
    if mouse-down? [
      form_planet planet_size planet_color planet_name mouse-xcor mouse-ycor
      wait 0.1
    ]
end

to form_asteroid                                                                                                                ;creates an asteroid
  create-asteroids 1 [set size 3 set shape "circle" set color asteroid_color setxy a_spawn_x a_spawn_y set sphere one-of stars] ;sets properties to set constants, and configurable options in interface tab
end

to form_moon                                                                                                            ;creates a moon
  create-moons 1 [set size 3 set shape "circle" set color moon_color setxy m_spawn_x m_spawn_y set sphere one-of stars] ;sets properties to set constants, and configurable options in interface tab
end

to sol_config ;procedure that configures the model to the sol system
  setup
  create-stars 1 [set size 6 set shape "circle" set color orange set label "Sol" if not display_name? [set label ""] ]
  create-planets 1 [set sphere one-of stars set size 2 set shape "circle" set color grey setxy 4 0 set label "Mercury" if show_orbit? [pd] if not display_name? [set label ""] ]   ;creates Mercury
  create-planets 1 [set sphere one-of stars set size 6 set shape "circle" set color 22 setxy 8 0 set label "Venus" if show_orbit? [pd] if not display_name? [set label ""] ]       ;creates Venus
  create-planets 1 [set sphere one-of stars set size 7 set shape "circle" set color green setxy 12 0 set label "Earth" if show_orbit? [pd] if not display_name? [set label ""] ]   ;creates Earth
  create-planets 1 [set sphere one-of stars set size 3.5 set shape "circle" set color 27 setxy 18 0 set label "Mars" if show_orbit? [pd] if not display_name? [set label ""] ]     ;creates Mars
  create-planets 1 [set sphere one-of stars set size 38.5 set shape "circle" set color 27 setxy 62 0 set label "Jupiter" if show_orbit? [pd] if not display_name? [set label ""] ] ;creates Jupiter
  create-planets 1 [set sphere one-of stars set size 30 set shape "circle" set color 42 setxy 110 0 set label "Saturn" if show_orbit? [pd] if not display_name? [set label ""] ]   ;creates Saturn
  create-planets 1 [set sphere one-of stars set size 25 set shape "circle" set color 86 setxy 220 0 set label "Uranus" if show_orbit? [pd] if not display_name? [set label ""] ]   ;creates Uranus
  create-planets 1 [set sphere one-of stars set size 22 set shape "circle" set color 103 setxy 350 0 set label "Neptune" if show_orbit? [pd] if not display_name? [set label ""] ] ;creates Nepturn (Pluto = not important)
end

to sol_config-inner ;procedure that configures the model to the inner planets of the sol system
  setup
  create-stars 1 [set size 18 set shape "circle" set color orange set label "Sol" if not display_name? [set label ""] ]
  create-planets 1 [set sphere one-of stars set size 6 set shape "circle" set color grey setxy 80 0 set label "Mercury" if show_orbit? [pd] if not display_name? [set label ""] ]  ;creates Mercury
  create-planets 1 [set sphere one-of stars set size 18 set shape "circle" set color 22 setxy 160 0 set label "Venus" if show_orbit? [pd] if not display_name? [set label ""] ]    ;creates Venus
  create-planets 1 [set sphere one-of stars set size 21 set shape "circle" set color green setxy 240 0 set label "Earth" if show_orbit? [pd] if not display_name? [set label ""] ] ;creates Earth
  create-planets 1 [set sphere one-of stars set size 10.5 set shape "circle" set color 27 setxy 360 0 set label "Mars" if show_orbit? [pd] if not display_name? [set label ""] ]   ;creates Mars
end

to kerbol_config
  setup
  create-stars 1 [set size 18 set shape "circle" set color orange set label "Sol" if not display_name? [set label ""] ]
  create-planets 1 [set sphere one-of stars set size 2 set shape "circle" set color 35 setxy 26 0 set label "Moho" if show_orbit? [pd] if not display_name? [set label ""] ]  ;creates Moho
  create-planets 1 [set sphere one-of stars set size 14 set shape "circle" set color 123 setxy 49 0 set label "Eve" if show_orbit? [pd] if not display_name? [set label ""] ]    ;creates Eve
  create-planets 1 [set sphere one-of stars set size 10 set shape "circle" set color 85 setxy 68 0 set label "Kerbin" if show_orbit? [pd] if not display_name? [set label ""] ] ;creates Kerbin
  create-planets 1 [set sphere one-of stars set size 6 set shape "circle" set color 27 setxy 103.5 0 set label "Duna" if show_orbit? [pd] if not display_name? [set label ""] ]   ;creates Duna
  create-planets 1 [set sphere one-of stars set size 3.5 set shape "circle" set color 5 setxy 204 0 set label "Dres" if show_orbit? [pd] if not display_name? [set label ""] ]  ;creates Dres
  create-planets 1 [set sphere one-of stars set size 30 set shape "circle" set color 65 setxy 343.5 0 set label "Jool" if show_orbit? [pd] if not display_name? [set label ""] ]    ;creates Jool (Eeloo = not important)
end
@#$#@#$#@
GRAPHICS-WINDOW
202
10
933
762
360
360
1.0
1
10
1
1
1
0
1
1
1
-360
360
-360
360
0
0
1
ticks
30.0

BUTTON
947
38
1094
71
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
947
286
1096
319
NIL
form_star
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
947
136
1096
169
star_size
star_size
0
45
25
1
1
NIL
HORIZONTAL

INPUTBOX
947
169
1096
229
star_color
45
1
0
Color

INPUTBOX
947
228
1097
288
star_name
My Star
1
0
String

BUTTON
948
567
1100
600
form_planet
form_planet planet_size planet_color planet_name planet_xspawn planet_yspawn
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
948
319
1098
352
planet_size
planet_size
0
25
13
1
1
NIL
HORIZONTAL

INPUTBOX
948
443
1099
503
planet_name
My Planet
1
0
String

INPUTBOX
948
385
1099
445
planet_color
105
1
0
Color

SLIDER
948
502
1100
535
planet_xspawn
planet_xspawn
-360
360
150
1
1
NIL
HORIZONTAL

SLIDER
948
534
1100
567
planet_yspawn
planet_yspawn
-360
360
-124
1
1
NIL
HORIZONTAL

SWITCH
947
71
1094
104
display_name?
display_name?
1
1
-1000

BUTTON
1249
205
1384
238
NIL
orbit
T
1
T
TURTLE
NIL
O
NIL
NIL
1

SLIDER
1249
172
1384
205
initial_velocity
initial_velocity
-20
20
20
1
1
NIL
HORIZONTAL

BUTTON
1101
724
1252
757
NIL
form_asteroid
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1101
660
1251
693
a_spawn_x
a_spawn_x
-360
360
-45
1
1
NIL
HORIZONTAL

SLIDER
1101
693
1252
726
a_spawn_y
a_spawn_y
-360
360
254
1
1
NIL
HORIZONTAL

INPUTBOX
1102
600
1251
660
asteroid_color
36
1
0
Color

BUTTON
1249
138
1384
171
NIL
go
T
1
T
TURTLE
NIL
NIL
NIL
NIL
1

BUTTON
1250
38
1385
71
NIL
sol_config
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1250
71
1385
104
NIL
sol_config-inner
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
948
352
1097
385
Random_Planet_Colors?
Random_Planet_Colors?
1
1
-1000

BUTTON
950
724
1103
757
NIL
form_moon
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
948
600
1102
660
Moon_Color
5
1
0
Color

SLIDER
948
659
1103
692
m_spawn_x
m_spawn_x
-360
360
154
1
1
NIL
HORIZONTAL

SLIDER
948
691
1103
724
m_spawn_y
m_spawn_y
-360
360
-129
1
1
NIL
HORIZONTAL

SWITCH
947
103
1094
136
show_orbit?
show_orbit?
0
1
-1000

TEXTBOX
1098
48
1248
66
Click this to reset the world
11
0.0
1

TEXTBOX
1100
77
1250
133
Should the planets display their name and track their orbit?
11
0.0
1

TEXTBOX
1105
138
1255
166
Choose the size of your star
11
0.0
1

TEXTBOX
1104
181
1254
209
Choose the color of your star
11
0.0
1

TEXTBOX
1104
238
1254
266
Choose the name of your star
11
0.0
1

TEXTBOX
1101
287
1363
343
Click this when you have configured the above buttons to your approval. ONLY click this once!
11
0.0
1

TEXTBOX
1100
326
1280
354
Choose the size of your planet
11
0.0
1

TEXTBOX
1104
355
1288
397
Choose this if you want the color of your planet to be randomized
11
0.0
1

TEXTBOX
1107
407
1306
435
Choose the color of your planet
11
0.0
1

TEXTBOX
1106
465
1288
493
Choose the name of your planet
11
0.0
1

TEXTBOX
1107
504
1270
574
Choose where you want your planet to spawn (-360 -> 360).  This also determines the distance of the orbit
11
0.0
1

TEXTBOX
1107
569
1715
626
Click this when you have configured the above buttons to your approval.  You can repeat this as many times as you like, by changing the configurations after every new planet is created, but beware, more planets = more lag!
11
0.0
1

TEXTBOX
1257
614
1407
642
Choose the color of your asteroid / moon
11
0.0
1

TEXTBOX
1258
676
1408
704
Choose where you want the asteroid / moon to spawn
11
0.0
1

TEXTBOX
1264
729
1774
841
Click this when you have configured the above buttons to your approval.  You can repeat this.  They assume circular orbits of their sphere of influence, whether it be a star or a planet.
11
0.0
1

TEXTBOX
1396
42
1575
84
Click this to configure the world in a model of our solar system
11
0.0
1

TEXTBOX
1395
75
1587
117
Click this to configure the world in a model of our inner solar system
11
0.0
1

TEXTBOX
1395
141
1574
183
Click this to run your solar system! Assumes ciruclar orbits
11
0.0
1

TEXTBOX
1391
177
1617
219
Choose the intial velocity of your bodies (only used with eccentric \"orbit\" button)
11
0.0
1

TEXTBOX
1391
209
1616
265
Click this to run your solar system! Assumes experimental eccentric orbits
11
0.0
1

TEXTBOX
948
10
1719
34
DO THE BUTTONS IN ORDER FROM TOP TO BOTTOM, THEN LEFT TO RIGHT
18
15.0
1

TEXTBOX
1623
157
1773
241
NOTE: If you are using the eccentric orbit, then it is advised that you spawn planets close to the star, and at a moderate (3-6) initial velocity
11
15.0
1

TEXTBOX
1273
504
1423
560
DO NOT:\n-Spawn planets on top of each other\n-At (0,0)
11
15.0
1

BUTTON
1250
103
1385
138
NIL
kerbol_config
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1395
107
1681
177
Click this to configure the world in a model of the Kerbol System from the game, Kerbal Space Program
11
0.0
1

TEXTBOX
1418
654
1568
710
DO NOT:\n-Spawn moons / asteroids on top of each other\n-At (0,0)
11
15.0
1

BUTTON
1358
355
1453
388
NIL
planet_click
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

This model is of the solar system.  It simulates the basic physics involved with orbital mechanics, and interactions between planetary bodies based on gravity.  The main purpose of our model was to allow the user to create their own solar system, in any configuration that they desire.  This would include creating their own stars, and planets, as well as modifying size, color, name, orbit, and display name / display orbit.  We also wanted the ability to add moons, and asteroids to the user's sysetems.  The physics in our model are very complex, which limits the full potential of the model.  It also includes a pre-configured model that includes our own solar system, with pluto as a "planet", and optimistically Planet X.

## HOW IT WORKS

In order to form the turtles (planets, stars, moons, asteroids), we used a different breed for each individual one.  Each create function uses the create-breed primitive, along with different properties that can be adjusted using global variables, that follow the create primitive in brackets.  These include color, size, label, shape, and two other variables that determine whether the label is visible, and if the pen is down or up.

The star remains immobile in our model, it is the constant that the planets move around.  In the circular orbit function, planets face the star, turn right 90, go foward sin * 2 (a formula used to calculate movement in orbital dynamics), and then go left 1.  This allows them to move a part of their orbit.  Succesively, this allows the planet to assume a "circular" shape around the star after many movements.  During each movement, the planet ask asteroids and moons in its radius * 2 to set their sphere of influence to themselves.

When the asteroids and moons are under the sphere of the star, they move identical to how the planets move.  However, when they are influenced by a planet, they are designed to move exactly how the planet moved, so it it is in the same position relative to the planet at all times, and then moves in a circular orbit, but instead of facing the star in the beginning, it faces the sphere.  And after that, it moves like a circular orbit.  The greatest challenge to this was figuring out how to make the asteroid / moon move identical to the planet.  The solution was to create a new property for the planet that records the heading from the planet to the star.  The asteroid / moon faces the heading set in this property, of their sphere, allowing them to move identically to the planet.

## HOW TO USE IT

All of the steps needed to use the model are on the interface panel.

## THINGS TO NOTICE

It is important that you notice the initial configuration of the solar system, and experiment with it.  It is quite fascinating to view the system that you live in over time.

Also notice that in order to make this as realistic as possible, we had to make some assumptions.  The most important of these is that the size you set the star is 100 times larger.  This is because stars, in reality, are significantly larger than planets, and we could not simulate a star this large because it would cover the entire screen!

## THINGS TO TRY

-Initial Configurations that come with the model
	-Sol System
	-Kerbol System
-Different planet sizes and intial spawn
-Orbits that are close enough together so moons can switch sphere of influence between planets

## EXTENDING THE MODEL

One of the shortcomings of this development was the lack of time we had to complete this. If we had no deadline, then we could have added much more.  Here is what we believe could have been done:
-Perfecting eccentric orbits
-Switch the model so all bodies can interact with each other, and not just based on breed
-Making the code more efficient so there is less lag with more bodies
-Expansion into NetLogo 3D
-More attributes of bodies that the user can customize

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

N-Bodies and Gravitation.

## CREDITS AND REFERENCES

-Ms. Genkina, for teaching us everything we know about Net Logo.
-http://ccl.northwestern.edu/netlogo/models/N-Bodies (gave the idea for use of velocities)
-http://ccl.northwestern.edu/netlogo/models/Gravitation
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
need-to-manually-make-preview-for-this-model
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
