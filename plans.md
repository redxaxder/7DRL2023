
first pass:
  + core gameplay:{{{
    + dance step triggers
      + there are dances
      + a dance has assigned sequences
  + dropcap glyphs: https://www.1001fonts.com/morris-initialen-font.html
  + dance room:{{{
    + dimensions 10x10}}}
  + GRACE mechanic{{{
    + two tiers:
       + grace "level"
       + grace "meter"
       + [3] [----15/30---| - - -]
       + higher lever grace has a bigger meter to fill
       + meter decays an amount based on level (equal to level?)
       + filling the meter inrements the level
    + performing the sequence generates GRACE for player}}}
  + player sprite
  + representation of dihedral group
  + action of dihedral group on move sequence
  + dances end and start
  + UI:
    + display player GRACE
    + display grace triggers for current dance
    + display move assistant pane
    + display time until dance end
    + display time until dance start
    + display moves of current dance}}}

second pass:
  + 12 NPCs in a dance
    + No names, or factions, just letters
    + they have genders (color coded?)
  + partnered NPCs move by following current dance steps
  + unpartnered NPCs move by following dijkstra map to compatible NPCS
    + one map for unpartnered men
    + one map for unpartnered women
  + player can get a dance partner by bumping
  + player can shove by bumping
  + dancing only happens when you have a partner
  + NPCs split up after dance end
  + UI:
    + display SUSPICION of NPC
    + display INTEL of NPC
  + LOS calculation{{{
    + check if bressenham line (and reverse line) is unoccupied}}}
  - game ends if SUSPICION guage fills
  + NPC state:{{{
    + NPCs have an INTEL guage
    + NPCs have an SUSPICION guage (0-100)?
    + connection data
    + corrupt/honest state}}}
  - connection graph screen{{{
    + use kinematic system
    + edges are springs
    + vertices repel each other
    + each NPC has their ICON inside a circle
      + the circle has a BLUE/RED halo depending on they support or oppose
    + each NPC a bar above and below
      + blue bar and red bar
    - if their RECALCITRANCE is known, they have a black line through the bars
    - show percentage on each bar}}}
  + SUSPICION{{{
    + SUSPICION increases in NPCS near the player
      + just adjacent?
      + possibly larger distance? (max norm? DnD octogon norm?)
    + high GRACE mitigates the increase
      + gives a chance to not generate SUSPICION
      + rolled seperately per NPC
      + chance to increase SUSPICION = n / (n + grace level)
        (n = 7?)
    + distance mitigates the increase
      + acts as a grace bonus? (multiplier?)
      + d = max norm
        g := (g + d) * d
      + if d > x, dont trigger it
        (x = 5?)
      + if chance is below threshold, dont trigger it
        (30%?) - need to be careful to not allow invulnerability}}}
  - INTEL{{{
    + while you have line of sight to that NPC, the guage fills
    - when the guage fills up, gain a type of INTEL on this character
      according to a priority list
      - 1. this character's support state
      - 2. location of this character in the connection graph
           and this character's "saturation"
           (proportion of ON neighbors)
      - 3. resolve
      - character's corrupt/honest state}}}

third pass:
  - NPC names
    - list of fixed names
    - list of name elements per faction
    - first names, last names, de la
    - [ john, carl, freiderich ]
    - [ schnitzel, sandwich, wellington ]
    - particle: faction -> particle
        von
        de la
        de
    - [ Berlin, Vienna, Whateversville ]
    - seperate list per faction
      - first name list
      - last name list
      - location list
      - 5 factions (english, french, german, russian, spanish)
      - 15 lists
  - player abilities
    - action of dihedral group on player ability
    - pilfer
  - victory / defeat screen
    - show epilogue

fourth pass:
  - player abilities
    - pick an ability to start with
    - ability unlocks
    - swap/introduce
    - twirl
    - trip
    - start game with a random ability
    - after each of first three nights, gain random ability
      - but choose among activation sequences
      - upgrade popup like in orcish fury
    - after each of next three nights, choose an ability to upgrade
      - bind an additional activation sequnce to it
      - there is a choice of multiple sequences to use

  - NPCs
    - marriages
    - alliances
    - grudges
    - traits
      - gossipy
      - duelist
      - reflexes
    - visible on NPC display
    - unlockable as INTEL
    - faction
    - at the start of the game, there is a clique for each faction

misc additions:
  - floor patterns: https://www.1001fonts.com/seamless-pattern-icons-font.html
  - display time remaining in current dance
  - legit sprites
    - for the NPCs
    - for the floor / walls
  - display recent STEPS of NPC
  - national flags
  - portraits
  - animate SUSPICION generation
    - red flash?
    - moving particle?
  - animate contagion
    - colored balls move from neighbors
    - look at ncase crowds sim
  - music
    - stop music when dance ends
    - start music when dance starts
    - [TODO: put list of first-pass songs here]
  - NPC intel: there is a list of which dances they will/won't attend
  - difficulty options:
    - no opposing NPCs, no alliances/grudges
    - some opposing NPCs, some alliances/grudges
    - key NPCs have extra alliances
    - extra opposition
  - agressive trait: forcibly initiates dance with player
  - patron trait: will never cause a scandal with player. no suspicion guage

ambitious extras:
  - choice of which dance to go to each night
    - different NPCs will be present at the different dances
    - the dances have different numbers of attendees (say 12 and 8?)
  - missions?

possible writing stuff:
  - scrolling prologue on title screen?
  - epilogue
    - what if you won
    - what if you lost
    - what if you got caught up in a scandal AND lost
    - what if you got caught up in a scandal AND won
      - what if it was a duel
  - blurbs for NPCs
    - these show up on the info pane for that NPC
  - blurbs between days
    - backstory that shows up during day transitions
    - some stuff that reacts to how the game is going
  - text for the following events:
    - connection restored due to alliance
    - connection broken due to grudge
    - NPC changing opinion
      - YES -> NO
      - YES -> NEUTRAL
      - NO -> YES
      - NO -> NEUTRAL
      - NEUTRAL -> YES
      - NEUTRAL -> NO
  - text for triggered SCANDAL
  - what is the plot?
    - the austrian emperor had a spymaster doing exactly what we're talking about
      - spymaster named franz joseph von hager or something
        - it was illegal to spy in certain locations
      - emperor named freidrich iii or something
    - is the player the spymaster?
    - does the player work for the spymaster?
    - is the spymaster mentioned, and how?
       - as the narrator?
    - player is spymaster's nephew?
       - you are not austrian
         - this is the reason you were called in
         - from the new world?


notes on CONTAGION mechanic:
  - there is a graph of relationships between NPCs
    - each pair of NPCs is either connected or not
  - some player actions cause connections to form/break
  - each NPC has a CONTAGION state: SUPPORT/NEUTRAL/OPPOSE
  - between dances, CONTAGION can spread from an NPC to its connections
    - each NPC has a saturation theshold. if the proportion of SUPPORT/OPPOSE neighbors
      is above the threshold, this NPC switches to SUPPORT/OPPOSE
    - if both SUPPORT and OPPOSE cross the threshold, switch to NEUTRAL
  - some NPCs have alliances/grudges
    - each of these has a percent chance
    - an alliance gives a chance for their conection to be restored after the dance
      ends (before propagation)
    - a grudge similarly breaks the connection
  - you win the game if at the end a set of key NPCs are ON
  - after every night there is one "round" of contagion calculation
    - assign a random order to all of the NPCs
      in order, flip it if necessary
    - after the end of the player's interference, it calculates until stable
      or looping?  (detect loops somehow if needed)


notes on PICKPICKET/PLANT:
  - player can hold one item
  - NPCs can hold one item
  - if it is targeting a space with no NPC, it fails
  - if player has an item:
      that item ends up in NPCs inventory
  - if NPC has an item:
      that item ends up in player's inventory
  - target is diagonal
  - costs 1 grace

notes on TWIRL:
  - moves the partner clockwise/counterclockwise
  - based on TAU component of dihedral
  - requires very high grace
    - should be unable to maintain necessary grace unless doing a ton of dancing
    n = 7?

notes on TRIP:
  - causes player to lose a lot of grace
  - causes lots of SUSPICION in tripped NPC
  - breaks connections between target and others who see it
  - moves the target one space
  - loses ALL grace

notes on SWAP:
  - creates connections between your
    partner and each member of the couple
  - costs n levels of grace
    n = 3?

notes on UNNAMED ABILITY:
  - increase max suspicion somehow?



NPC Stats:
  - SUSPICION:
    - when this fills up they cause a SCANDAL with the player
  - intel:
    - CORRUPT or HONEST
    - alliances
    - grudges
    - resolve - activation threshold
  - grace threshold?:
    - will refuse to dance with player while their grace is too low
  - PIQUE?:
    - when this fills up they leave the party early
    - can cause CASCADING when interacting with relationships





















7 Nights in Vienna: Party Like It's 1815


Example Goal:
  - get france into the inner circle
    - representative of france needs to get into
      an alliance with at least two great powers

  - get representative of france to dance with wife of
    rep of britian

  - transfer messages with agent
  - plant evidence of mischief
  - steal document
  - steal other thing?!
  - cause scandal by stealing and planting jewels
  - convince women to wear same dress
    - how?
  - seduce target
  - steal guest list
      - make copy
      - return it
  - swap thing?
  - get character to leave party
  - make a distraction
    - keep a specific character's attention
  - ruin the party!
    - get N people to leave

Evolution rules<!--{{{-->
  EVENT             EVOLUTIONS
  IMPRESSIVE act      0 -> LOVE
                      0 -> RESPECT
                      mutual RESPECT -> FRIENDSHIP
                      LOVE partner -> RIVALRY
                      COURTING to partner -> RIVALRY
                        if parters are also COURTING -> HATE
                      mutual LOVE -> COURTING
                      RIVALRY -> HATE
  EMBARASSING act     0 -> DISDAIN
                      RIVALRY -> 0
                      HATE -> cause scandal
  SCANDALOUS act      RESPECT -> DISDAIN
                      0 -> DISDAIN
                      RESPECT -> DISDAIN
                      DISDAIN -> HATE
                      ALLIANCE -> 0
  DANCE PROPOSAL      target 0 -> RESPECT
                      target HATE -> cause scandal
                      target RESPECT -> LOVE}}}


Player abilities:
  - trip someone (embarassing for them)
  - stain their clothing? (embarassing for them, but as a persistent effect instead of immediate)
    - maybe they leave ball early
  - twirl (make dance partner impressive)
  - dance partner swap
  - shove (moving npcs)
  - step on toes (
  - pickpocket (take item from character)
  - putpocket (put item on character)
  - poison! (apply debuff to character)
  - ditch partner
  - introduce
    - lead your dance partner to another couple
    - person you're dancing with gains relationship to other people

NPC traits:
   corrupt:
     - when this NPC gains posession of an item that is not theirs, they keep it
       this breaks a connection between them and its owner
   honest:
     - when this NPC gains posession of an item that is not theirs, they return it
       this makes a connection between them and its owner
   gossipy:
     - while dancing with this NPC, randomly gain info about other NPCs
   duelist:
     - if the player causes a scandal with this NPC, it is a duel
     - this NPC will be injured in the duel and will no longer influence
       contagion for the rest of the game
   quick reflexes:
     - IMPRESSIVE: catch someone who falls over


   obsessive host:
     - will not cause a scandal when their ire overflows
       at a party they are hosting
     - ire generated at a party they are hosting
       is permanent
   suave dancer:
     - IMPRESSIVE if they complete N dance moves in a row
   two left feet:
     - prevents dance partner from doing anything impressive
   resolute:
     - never leaves the party early
   beautiful:
     - always finds a dance partner


hosting schedule:
   - each party has a host
   - player knows who will host which party in advance
     - maybe this has to be earned by doing spy shit

characters have a CONNECT LIMIT (varies per character?)
  new connections will bump older connections of lower RANK
  off of the list

Connections:
    TYPE       RANK
  - friendship 3    (mutual only)
  - courting   3    (mutual only)
  - love       2
  - hate       2
  - rivalry    1
  - disdain    1
  - respect    1

delightful trivia:
  - wristwatches were worn exclusively by women
  - men had pocket watches

Factions:
  - 4 great powers:
    - United Kingdom (flag: https://en.wikipedia.org/wiki/List_of_United_Kingdom_flags#/media/File:Flag_of_the_United_Kingdom_(3-5).svg)
    - Austrian Empire (flag: https://en.wikipedia.org/wiki/Austrian_Empire#/media/File:Flag_of_the_Habsburg_Monarchy.svg)
    - Russia (https://en.wikipedia.org/wiki/File:Flag_of_Russia.svg)
    - Prussia (flag: https://en.wikipedia.org/wiki/Flag_of_Prussia)
  - Spain? (flag: https://en.wikipedia.org/wiki/Flag_of_Spain#/media/File:Bandera_de_Espa%C3%B1a.svg)
  - Portugal? (flag: https://en.wikipedia.org/wiki/History_of_Portugal_(1777%E2%80%931834))
  - Sweden? (flag: https://en.wikipedia.org/wiki/Gustavian_era)
  - France (flag: https://commons.wikimedia.org/wiki/File:Flag_of_Royalist_France.svg)
  Minor:
  - Papacy (https://en.wikipedia.org/wiki/Coat_of_arms_of_Vatican_City)
  - Bavaria (flag: https://en.wikipedia.org/wiki/Kingdom_of_Bavaria )
  - Denmark (https://en.wikipedia.org/wiki/Flag_of_Denmark)
  - Netherlands (https://en.wikipedia.org/wiki/File:Flag_of_the_Netherlands.svg)
  - Switzerland
  - Itialian kingdoms

important NPC names and relationships:
  - king friedrich wilhelm iii - prussia
  - tsar alexander - russia
    - sworn friends with kaiser wilhelm
      pre-treaty to divvy up poland
  - francis i - austria
  - Klemens von Metternich, foreign minister of austria
  - Prince Charles-Maurice de Talleyrand, France (chief delegate)
  - nations that send their leader to vienna congress:
    - prussia
    - russia
    - demnark (frederick vi)
    - austria
    - some minor german states (created by napolean)
      - bavaria (Maximilian I Joseph)
      - wu"rttemberg

Preexisting faction rels:
  - france allied with austria & britian against russia
  - prussia beef w/ austria & britian
  - prussia & russia have secret agreement to help each other out

goals:
  russia: tsar wanted to become king of poland


PC state:
  - scrolling window of inputs
  - a "grace" guage
    - this reduces the amount of SUSPICION generated when they pull shenanigans

- how many NPCs?
  - bigger number:
      greater variety
      more immersive (fuller world)
  - smaller number:
      easier to implement
      player needs to understand the political situation
  - about a dozen major NPCs (maybe more. like 20? ish? feel it out)
    - these are the characters the player needs to keep track of to play
    - they are less likely to be the target if minor (ie early game) missions
  - fill up with minor NPCs to get 50 characters
    - this fill out the dance room
    - have have factions
    - their SUSPICION is fully reset between missions
    - they are less likely to be the target of major (ie late game) missions
    - they are never involved in connections

moment-to-moment player experience:
- title screen
  - has scrolling text about setting
  - press button to start

- start is pressed
  - player appears in preparation room
  - preparation rooms contains a random game tip!
  - here they can
    - practice moves
    - learn their upcoming mission
    - fuse moves
    - get new moves
    - exit (toward mission start)

- mission starts
  - player appears in dance room
  - dance room is populated with other characters
  - there is dancing going on!
  - some characters are not dancing
  - there is a "current dance" consisting of some sequence of steps
    - there is more than one such sequence
      - the sequences are the sets of 4 steps that have at least one pair
        of duplicate consecutive steps
    - when the player executes that sequence, gain grace
    - the "current dance" eventually ends
      - dancers unlink
      - one turn later, a new dance starts
        - it has different steps
        - the music changes
    - when the player does not have a partner, they cannot gain grace
      - bumping into a matching unpartnered NPC invites them to dance
        - if your grace is below a threshold, your partner continuously gains SUSPICION
      - bumping into anyone else shoves them out of the way
        - this generates SUSPICION
  - there is an observation pane
    - it shows what the player knows about the target NPC
    - it has an AI-generated portrait of the NPC? <<<<
    - clicking on an NPC changes the target
      - mouse-overrides target for duration of mouse-over
    - when no target, shows mission info
    - some UI interaction clears current target
    - shows NPC stats:
      - SUSPICION is always known
      - PIQUE is always known
      - name is always known
      - faction is always known
      - dance step history is always known
      - trait, if known
      - connections, if known
  - there is a move assistant pane
    - this helps the player figure out which moves their current sequence of
      steps can complete into

  - if the mission is currently complete, there is an exit to the dance area
  - when the player goes through the exit, they go to the planning zone



{-
>>>v


NPC

>>vv>>^^<<



-}


EX move assistant pane:
history: ^^><
moveset:
  <^>v : move A
  <><> : current dance
  >>vv : move C
  >v^^ : move D

[ move has a tip icon which is transformed here ]
assistant:
  [^><]< : move D [ icon ]
  [><]>< : grace

true fax about assistant pane:
   - because of collision rules, there are at most 4 moves 1 away from completion
   - there are at most 16 moves 2 away from completion

UX idea:
  "shift-move" to filter assistant pane
  backspace to undo filter

ex: throw dart
 .>-
 .@.
 ...


-----------------
|   |   |   |   |
|   | X |   |   |
|   |   |   |   |
-----------------
|   |   |   |   |
|   |   |   |   |
|   |   |   |   |
-----------------
|   |   |   |   |
|   |   |  X|X  |
|   |   |   |   |
-----------------
|   |   |   |   |
|   |   |   |   |
|   |   |   |   |
-----------------
|   |   |   |   |
|   |   |   |   |
|   |   |   |   |


- MISSIONS
  - steal document
    - one of the NPCs is holding a document
    - player must perform PICKPOCKET ability on that character
  - steal document (unknown holder)
    - as above, except you need to gather info about who has it
  - make someone late for an appointment
    - an NPC has a timepiece
    - player must perform PICKPOCKET ability on that character
    - this triggers a countdown while you fiddle with the time
    - player must perform PLANT ability on that character after countdown
  - dance with a particular NPC
    - the mission target has a high grace threshold
  - eavesdrop on a conversation
    - spend X number of turns within [RANGE] of [NPC]
  - get two target NPCs to dance with each other
  - frame an NPC
    - steal an item from one NPC
    - plant it on a second NPC
  - swap NPC items
    - NPC A is holding item A
    - NPC B is holding item B
    - item A has to be in NPC B's inventory and vice versa
  - create a distraction
    - cause any SCANDAL between NPCS (if rels)
    - trip people (if no rels) <-


List of people
  Austria
    Klemens von Metternich
                full name: Klemens Wenzel Nepomuk Lothar, Prince of Metternich-Winneburg zu Beilstein
    S: Eleonore von Kaunitz
    Johann Philipp Freiherr von Wessenberg-Ampringen (Minister-President of the Austrian Empire)
    S: ???
  Britain
    Field Marshal His Grace The Duke of Wellington
    S: Catherine Pakenham
  Russia
    Tsar Alexander I (Emperor of Russia)
    S: Louise of Baden
    Karl Robert Reichsgraf von Nesselrode-Ehreshoven
    S: Maria Guryeva
  Prussia
    Karl August Fürst von Hardenberg (Prime Minister of Prussia)
    S: Christiane von Reventlow
    Friedrich Wilhelm Christian Karl Ferdinand von Humboldt
    S: Caroline von Humboldt
    Friedrich Wilhelm III (King of Prussia)
    S: none!
  France
    Charles-Maurice de Talleyrand-Périgord
    S: Catherine Noël Grand

