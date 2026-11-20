Revolt - Final Project Prototype

Names: Cameron Drake & Emily Amos
Course: COMP4501A
Engine: Godot 4.6


CONTROLS
----------------------
- Move Camera: w/a/s/d keys
- Zoom In/Out Camera: up/down arrow keys
- Interact: left click

INTERACTIONS
----------------------
1. Interacting with the radio tower, the revolutionary base (the house) and the leader protester (the person 
with the hat) will present you with different actions you can perform and get the regular protesters to perform.

2. Radio Tower: Can spread the word with a radio broadcast, boost morale, trigger protest crowd formations, and 
interfere with the Surveillance Drone.

3. Revolutionary Base: Can recruit new protesters, access storage, make protesters collect new materials, heal
units, and print newspapers.

4. Leader Protester: Move the leader using a point-and-click movement system. Initiate a protest to make use of 
most of the unit and crowd options, including inspiring protesters and initiating enemy structure destruction.

5. Protesters: Protestors carry out the orders of the leader protestor such as partaking in protests. They also 
are used for the gathering of resources needed to print newspapers within the revolutionary base. 

6. Common People: Common people spawn randomly throughout the world, they spawn with the distinct attributes of 
able to be recruited and are marked as passionate.
    - They have a 50/50 chance of being able to be recruited and a 20/80 chance of being marked as passionate. 
    They can be recruited through the revolutionary base if their dissatisfaction level is above 80%. 
    - They can wander freely and are influenced by propaganda spread from the player.

ENEMY RELATED ENTITIES
----------------------
1. Riot Police: When the Leader Protester starts a Protest, Riot Police Spawn. If the Surveillance Drone has 
spotted the Leader and the Leader has decided to Destroy Structures, they attempt to arrest the Leader Protester.

2. Surveillance Drone: Spends most of its time patrolling the districts. Radio Towers are blocked from boosting 
morale and spreading the word while the Surveillance Drone is in the same district. When the Leader Protester 
starts a protest, the Surveillance Drone chases the Leader to identify them for the Riot Police.

RESOURCES
----------------------
All models and animations were created by us using Blockbench.
