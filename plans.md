

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

Evolution rules
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
                      target RESPECT -> LOVE


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
   quick reflexes:
     - IMPRESSIVE: catch someone who falls over
   suave dancer:
     - IMPRESSIVE if they complete N dance moves in a row
   two left feet:
     - prevents dance partner from doing anything impressive
   beautiful:
     - always finds a dance partner
   obsessive host:
     - will not cause a scandal when their ire overflows
       at a party they are hosting
     - ire generated at a party they are hosting
       is permanent
   gossipy:
     - while dancing with this NPC, randomly gain info about other NPCs

NPC Stats:
  - IRE:
    - when this fills up they cause a SCANDAL with the player
  - PIQUE:
    - when this fills up they leave the party early
    - can cause CASCADING when interacting with relationships


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


Factions:
  - 4 great powers:
    - United Kingdom
    - Austria
    - Russia
    - Prussia
  - Spain?
  - Portugal?
  - Sweden?
  - France
  Minor:
  - Papacy
  - Denmark
  - Netherlands
  - Switzerland
  - Itialian kingdoms



Preexisting faction rels:
  - france allied with austria & britian against russia
  - prussia beef w/ austria & britian

goals:
  russia: tsar wanted to become king of poland


PC state:
  - scrolling window of inputs
  - a "grace" guage
    - this reduces the amount of IRE generated when they pull shenanigans

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
    - their IRE is fully reset between missions
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
        - if your grace is below a threshold, your partner continuously gains IRE
      - bumping into anyone else shoves them out of the way
        - this generates IRE
  - there is an observation pane
    - it shows what the player knows about the target NPC
    - it has an AI-generated portrait of the NPC? <<<<
    - clicking on an NPC changes the target
      - mouse-overrides target for duration of mouse-over
    - when no target, shows mission info
    - some UI interaction clears current target
    - shows NPC stats:
      - IRE is always known
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


