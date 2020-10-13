"
This is a simple base class for halos in the system. It represents the minimal interface used to implement custom halo morphs. 

It provides:

- event handling code to invoke and transfer a halo when clicking the meta-button (blue)
- move the halo's target (morph) when click-hold-drag the meta-button
- one close button as a minimal handle (see #addHandles)

In general, the halo concept consists of one dedicated user interaction (meta-button click) to invoke an additional, interactive view (the halo) for any morph. This interactive view is itself a morph that can have submorphs (e.g. buttons or text fields) to enrich the target morph. Besides button-based interactions (e.g. resize, move, duplicate, etc.), this could also be used to show other, even domain-specific, information.

Use the halo concept to provide means to explore and modify interactive, graphical elements in Squeak and your application. You can benefit from this concept without wasting additional screen space. In non-Squeak applications, the meta-key (typically the mouse-wheel button) is often without real functionality for the user. There, it makes scrolling more convenient---at best. In Squeak, you can easily take advantage of this button click. 

Notice that direct user input is very limited. Many keyboard shortcuts (such as [ctrl]+[c]) are already pre-defined and should not be remapped for your domain-specific applications to avoid user confusion. Key chords (such as [ctrl]+[alt]+[v], [a] from Visual Studio) have to be learned with great effort. 

The left mouse click (red) selects something.
The right mouse click (yellow) invokes a context menu.
Only the middle click, the meta-key, the blue button, is unused in many environments.

This is where the halo concept comes in.

[For two- or single-button mice, the meta-key can be simulated.]
"
Class {
	#name : #SimpleHaloMorph,
	#superclass : #Morph,
	#instVars : [
		'target',
		'positionOffset'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #construction }
SimpleHaloMorph >> addHandles [
	"This is an example for handles."
	
	self addMorphFront: (IconicButton new
		color: Color red muchLighter;
		borderColor: Color red;
		labelGraphic: MenuIcons smallCancelIcon;
		target: self target;
		actionSelector: #delete;
		bottomRight: self topLeft;
		yourself).
]

{ #category : #'submorphs-add\/remove' }
SimpleHaloMorph >> delete [

	self target hasHalo: false.
	super delete.
]

{ #category : #dragging }
SimpleHaloMorph >> doDragTarget: event [

	self target
		setConstrainedPosition: (self target point: (event position - self positionOffset) from: self owner)
		hangOut: true.
		
	self bounds: self target worldBoundsForHalo.
]

{ #category : #drawing }
SimpleHaloMorph >> drawOn: aCanvas [ 
	"Draw this morph only if it has no target."

	(Preferences showBoundsInHalo and: [self target isWorldMorph not])
		ifTrue: [
			aCanvas
				frameAndFillRectangle: self bounds
				fillColor: Color transparent
				borderWidth: 2
				borderColor: (self userInterfaceTheme borderColor ifNil: [Color blue alpha: 0.8])]
]

{ #category : #events }
SimpleHaloMorph >> handleMouseUp: evt [

	super handleMouseUp: evt.
	evt hand newMouseFocus: self.
]

{ #category : #events }
SimpleHaloMorph >> handlesMouseDown: evt [

	^ true
]

{ #category : #accessing }
SimpleHaloMorph >> innerTarget [
	"If the target is merely a decorator for another morph, the inner target can be distiguished. Scroll panes, for example, could have their scrolled content as an inner target."

	^ self target
]

{ #category : #testing }
SimpleHaloMorph >> isMagicHalo [

	^ false
]

{ #category : #events }
SimpleHaloMorph >> mouseDown: event [
	"Transfer the halo to the next likely recipient"

	event hand obtainHalo: self.

	((self containsPoint: event position) not or: [event blueButtonPressed not])
		ifTrue: [
			"Close this halo and give another morph the chance to react."
			event hand removeHalo.
			event resetHandlerFields.
			event hand world processEvent: event.
			^ self].

	self target ifNil: [
		event hand removeHalo.
		^self].

	self positionOffset: (event position - (self target point: self target position in: self owner)).

	"wait for drags or transfer"
	event hand 
		waitForClicksOrDrag: self 
		event: event
		selectors: { #transferHalo:. nil. nil. #startDragTarget:. }
		threshold: HandMorph dragThreshold.
]

{ #category : #events }
SimpleHaloMorph >> mouseMove: event [

	self doDragTarget: event.
]

{ #category : #'pop up' }
SimpleHaloMorph >> popUpFor: morph [

	self
		popUpFor: morph
		hand: (morph world activeHand ifNil: [morph world primaryHand]).
]

{ #category : #'pop up' }
SimpleHaloMorph >> popUpFor: morph at: position hand: hand [

	self target: morph.
	
	hand halo: self.
	hand world addMorphFront: self.
	
	self positionOffset: position - (morph point: morph position in: self owner).
]

{ #category : #'pop up' }
SimpleHaloMorph >> popUpFor: morph event: event [

	self
		popUpFor: morph
		at: event position
		hand: event hand.
]

{ #category : #'pop up' }
SimpleHaloMorph >> popUpFor: morph hand: hand [

	self
		popUpFor: morph
		at: (hand lastEvent transformedBy: (morph transformedFrom: nil)) position
		hand: hand
]

{ #category : #'pop up' }
SimpleHaloMorph >> popUpMagicallyFor: morph hand: hand [

	self
		popUpFor: morph
		hand: hand.
]

{ #category : #accessing }
SimpleHaloMorph >> positionOffset [

	^ positionOffset
]

{ #category : #accessing }
SimpleHaloMorph >> positionOffset: aPoint [

	positionOffset := aPoint.
]

{ #category : #events }
SimpleHaloMorph >> processFocusEvent: evt using: dispatcher [

	^ dispatcher dispatchFocusEventAllOver: evt with: self
]

{ #category : #events }
SimpleHaloMorph >> rejectsEvent: anEvent [
	"Return true to reject the given event. Rejecting an event means neither the receiver nor any of it's submorphs will be given any chance to handle it."
	(super rejectsEvent: anEvent) ifTrue:[^true].
	anEvent isDropEvent ifTrue:[^true]. "never attempt to drop on halos"
	^false
]

{ #category : #dragging }
SimpleHaloMorph >> startDragTarget: event [

	self positionOffset: (event position - (self target point: self target position in: self owner)).		
	event hand newMouseFocus: self.
]

{ #category : #testing }
SimpleHaloMorph >> staysUpWhenMouseIsDownIn: aMorph [
	^ ((aMorph == self target) or: [aMorph hasOwner: self])
]

{ #category : #accessing }
SimpleHaloMorph >> target [

	^ target ifNil: [target := Morph new]
]

{ #category : #accessing }
SimpleHaloMorph >> target: morph [

	target := morph.
	morph hasHalo: true.
	self addHandles.
]

{ #category : #'pop up' }
SimpleHaloMorph >> transferHalo: event [
	"Transfer the halo to the next likely recipient"

	self target
		transferHalo: (event transformedBy: (self target transformedFrom: self))
		from: self target.
]

{ #category : #'halos and balloon help' }
SimpleHaloMorph >> transferHalo: event from: formerHaloOwner [
	"If my world tries to open on me, pass it on to the next sibling after me."
	
	formerHaloOwner == self world ifTrue: [
		self world submorphsDo: [:m |
			(m ~~ self and: [m fullContainsPoint: event position]) ifTrue: [
				m comeToFront.
				^ m transferHalo: event from: formerHaloOwner]]].
]
