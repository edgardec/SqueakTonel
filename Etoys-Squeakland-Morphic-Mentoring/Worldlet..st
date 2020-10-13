"
An area with a private Presenter, viz, for which the scope of its stop-step-go buttons is limited to the area's interior.

A Worldlet serves as a world within a world, which can have its own flaps, but does not have its own worldState. It is used for recording and replaying demos in an EventTheater.
"
Class {
	#name : #Worldlet,
	#superclass : #PasteUpMorph,
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #flaps }
Worldlet >> closeNavigatorFlap [
	"Close the navigator flap"

	(self submorphs
		detect:
			[:m  | (m isKindOf: FlapTab) and: [m flapID = 'Navigator']]
		ifNone:
			[nil])

	ifNotNil:
		[:nav | nav hideFlap]
]

{ #category : #initialization }
Worldlet >> initialize [
	"Initialize the receiver."

	super initialize.
	self setNameTo: 'screen' translated;
		extent: (700@556);  "yeah"
		color: Color white;
		impartPrivatePresenter;
		beSticky;
		borderColor: (Color r: 0.677 g: 0.935 b: 0.484);
		borderWidth: 2. 
"
Worldlet new openInWorld.
"

]

{ #category : #flaps }
Worldlet >> installFlaps [
	"Get flaps installed within the bounds of the receiver"

	| localFlapTabs |
	localFlapTabs := self localFlapTabs.
	localFlapTabs do: [:each | each visible: false].
	localFlapTabs do: [:each |
		each adaptToWorld.
		each visible: true.
		self displayWorld].
	self assureFlapTabsFitOnScreen.
	self bringTopmostsToFront
]

{ #category : #flaps }
Worldlet >> paintingFlapTab [
	"If the receiver has a flap which has a paintbox, return it, else return nil"

	^ nil
]
