"
AtomMorph represents an atom used in the simulation of
an ideal gas. It's container is typically a BouncingAtomsMorph.

Try:

	BouncingAtomsMorph  new openInWorld

to open the gas simulation or:

	AtomMorph example

to open an instance in the current world
"
Class {
	#name : #AtomMorph,
	#superclass : #EllipseMorph,
	#instVars : [
		'velocity'
	],
	#category : #'MorphicExtras-Demo'
}

{ #category : #examples }
AtomMorph class >> example [
	"
	AtomMorph example
	"
	|a world|
	world := Project current world.
	a := AtomMorph new openInWorld. 
	a color: Color random.
 	[1000 timesRepeat:  [a bounceIn: world bounds.  (Delay forMilliseconds: 50) wait]. 
	 a delete] fork.
]

{ #category : #'new-morph participation' }
AtomMorph class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #private }
AtomMorph >> bounceIn: aRect [
	"Move this atom one step along its velocity vector and make it bounce if it goes outside the given rectangle. Return true if it is bounced."

	| p vx vy px py bounced |
	p := self position.
	vx := velocity x.		vy := velocity y.
	px := p x + vx.		py := p y + vy.
	bounced := false.
	px > aRect right ifTrue: [
		px := aRect right - (px - aRect right).
		vx := velocity x negated.
		bounced := true].
	py > aRect bottom ifTrue: [
		py :=  aRect bottom - (py - aRect bottom).
		vy := velocity y negated.
		bounced := true].
	px < aRect left ifTrue: [
		px := aRect left - (px - aRect left).
		vx := velocity x negated.
		bounced := true].
	py < aRect top ifTrue: [
		py :=  aRect top - (py - aRect top).
		vy := velocity y negated.
		bounced := true].
	self position: px @ py.
	bounced ifTrue: [self velocity: vx @ vy].
	^ bounced

]

{ #category : #initialization }
AtomMorph >> defaultBorderWidth [
"answer the default border width for the receiver"
	^ 0
]

{ #category : #initialization }
AtomMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color blue
]

{ #category : #drawing }
AtomMorph >> drawOn: aCanvas [
	"Note: Set 'drawAsRect' to true to make the atoms draw faster. When testing the speed of other aspects of Morphic, such as its damage handling efficiency for large numbers of atoms, it is useful to make drawing faster."

	| drawAsRect |
	drawAsRect := false.  "rectangles are faster to draw"
	drawAsRect
		ifTrue: [aCanvas fillRectangle: self bounds color: color]
		ifFalse: [super drawOn: aCanvas].
]

{ #category : #accessing }
AtomMorph >> infected [

	^ color = Color red
]

{ #category : #accessing }
AtomMorph >> infected: aBoolean [

	aBoolean
		ifTrue: [self color: Color red]
		ifFalse: [self color: Color blue].
]

{ #category : #initialization }
AtomMorph >> initialize [
	"Make a new atom with a random position and velocity."
	super initialize.
""
	self extent: 8 @ 7.
	
	self
		randomPositionIn: (0 @ 0 corner: 300 @ 300)
		maxVelocity: 10
]

{ #category : #initialization }
AtomMorph >> randomPositionIn: aRectangle maxVelocity: maxVelocity [
	"Give this atom a random position and velocity."

	| origin extent |
	origin := aRectangle origin.
	extent := (aRectangle extent - self bounds extent) rounded.
	self position:
		(origin x + extent x atRandom) @
		(origin y + extent y atRandom).
	velocity :=
		(maxVelocity - (2 * maxVelocity) atRandom) @
		(maxVelocity - (2 * maxVelocity) atRandom).

]

{ #category : #accessing }
AtomMorph >> velocity [

	^ velocity
]

{ #category : #accessing }
AtomMorph >> velocity: newVelocity [

	velocity := newVelocity.
]
