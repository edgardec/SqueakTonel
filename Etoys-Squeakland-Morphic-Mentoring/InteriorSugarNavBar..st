"
Used for the ""fake sugar navigator bar"" that optionally appears at the top of an Event Theatre.
"
Class {
	#name : #InteriorSugarNavBar,
	#superclass : #SugarNavigatorBar,
	#instVars : [
		'edgeToAdhereTo'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #initialization }
InteriorSugarNavBar >> addButtons [
	"Add the sugar buttons, delimited on each end by spacers."

	self addTransparentSpacerOfSize: 30@1.
	super addButtons.
	self addTransparentSpacerOfSize: 30@1
]

{ #category : #menus }
InteriorSugarNavBar >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add further items to the menu as appropriate"

	aMenu addLine.
	aMenu addUpdating: #edgeString action: #setEdgeToAdhereTo.
	aMenu add: 'destroy this flap' translated action: #destroyFlap.

	aMenu addLine.

	aMenu add: 'use default green look' translated action: #makeGreen.
	aMenu add: 'use default gray look' translated action: #makeGray.
	aMenu add: 'color...' translated target: self action: #changeColor.
	aMenu add: 'highlight color...' translated target: self action: #changeHighlightColor.
	aMenu add: 'height...' translated target: self action: #changeNaviHeight.

]

{ #category : #accessing }
InteriorSugarNavBar >> adhereToEdge: aSymbol [
	"Set the value of edgeToAdhereTo, and position the receiver accordingly"

	edgeToAdhereTo := aSymbol.
	super adhereToEdge: aSymbol.
	supplies ifNotNil: [supplies setEdge: aSymbol]
]

{ #category : #'morphic interaction' }
InteriorSugarNavBar >> changeColor [
	"Change the color of the receiver -- triggered, e.g. from a menu"

	ColorPickerMorph new
		choseModalityFromPreference;
		sourceHand: self activeHand;
		target: self;
		selector: #color:;
		originalColor: color;
		putUpFor: self near: self fullBoundsInWorld
]

{ #category : #events }
InteriorSugarNavBar >> changeHighlightColor [
	"Put up a color picker allowing the user to select a highlight color."

	ColorPickerMorph new
		choseModalityFromPreference;
		sourceHand: self activeHand;
		target: self;
		selector: #highLightColor:;
		originalColor: self color;
		putUpFor: self near: self fullBoundsInWorld
]

{ #category : #events }
InteriorSugarNavBar >> changeNaviHeight [
	"Allow the user to choose a new height for the navigator."

	| f n |
	f := FillInTheBlank request: 'new height of the bar'  translated initialAnswer: self height asString.
	n := f asNumber min: (self pasteUpMorph height // 2) max: 0.
	self naviHeight: n.
]

{ #category : #'morphic interaction' }
InteriorSugarNavBar >> checkForResize [
	"Called during the step, make sure I conform to my owner's width."

	self width: owner width
]

{ #category : #buttons }
InteriorSugarNavBar >> chooseLanguage [
	"If I have a language button, make it inoperative."

]

{ #category : #'button actions' }
InteriorSugarNavBar >> destroyFlap [
	"Simply delete the receiver."

	self delete
]

{ #category : #buttons }
InteriorSugarNavBar >> doNewPainting [
	"Make a new painting"

	| worldlet aRect |
	self currentWorld assureNotPaintingElse: [^ self].
	worldlet := self ownerThatIsA: Worldlet.
	aRect := (worldlet topLeft + (0 @ self height)) corner: worldlet bottomRight.
	worldlet makeNewDrawing: (self currentEvent copy setPosition: aRect center).
]

{ #category : #edge }
InteriorSugarNavBar >> edgeString [
	"Answer a string characterizing the edge to which I cling."

	^ 'cling to edge... (current: {1})' translated format: {edgeToAdhereTo translated}
]

{ #category : #accessing }
InteriorSugarNavBar >> edgeToAdhereTo [
	"Answer the value of edgeToAdhereTo"

	^ edgeToAdhereTo
]

{ #category : #buttons }
InteriorSugarNavBar >> findAProjectSimple [
	"But don't..."
]

{ #category : #initialization }
InteriorSugarNavBar >> finishInitialization [
	"After the receiver is added at its proper place in the hierarchy, this needs to be called."

	self addButtons.
	self adhereToEdge: #top.
	self setNameTo: 'Navigator Flap' translated

]

{ #category : #initialization }
InteriorSugarNavBar >> initialize [
	"Initialize the receiver."

	| |
	super initialize.
	self listDirection: #leftToRight.
	self cellInset: 10@8.
	self layoutInset: 6@0.
	self hResizing: #spaceFill.
	self vResizing: #rigid. 
	self height: 75.
	self color: ( Color r: 0.258 g: 0.258 b: 0.258).
	self adhereToEdge: #top.
]

{ #category : #buttons }
InteriorSugarNavBar >> keepProject [
	"But don't..."
]

{ #category : #initialization }
InteriorSugarNavBar >> makeTheSimpleButtons [
	"Add the buttons for use in normal kids' mode."

	^{
		self buttonPaint.
		self buttonSupplies.
		"self buttonUndo."
		#spacer.

			}
]

{ #category : #buttons }
InteriorSugarNavBar >> newProject [
	"But don't..."

]

{ #category : #buttons }
InteriorSugarNavBar >> previousProject [
	"But don't..."
]

{ #category : #buttons }
InteriorSugarNavBar >> publishProject [
	"But don't..."
]

{ #category : #'morphic interaction' }
InteriorSugarNavBar >> resizeButtonsAndTabTo: newDim [
	"The user has chosen a new height for the nav bar; make the buttons follow suit."

	| frame wantsSupplies |
	wantsSupplies := supplies notNil and: [supplies flapShowing].
	wantsSupplies ifTrue: [supplies hideFlap].
	frame := paintButton owner.
	frame submorphs do: [:e |
		e naviHeight: newDim].
	frame height: newDim.
	self height: newDim.
	wantsSupplies ifTrue: [supplies showFlap]
]

{ #category : #edge }
InteriorSugarNavBar >> setEdgeToAdhereTo [
	"Put up a menu allowing user to specify the edge."

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	#(top bottom) do:
		[:sym | aMenu add: sym asString translated target: self selector:  #adhereToEdge: argument: sym].
	aMenu popUpEvent: self currentEvent in: self world
]

{ #category : #initialization }
InteriorSugarNavBar >> setupSuppliesFlap [
	"Set up the interior supplies flap."

	supplies := (self ownerThatIsA: EventRecordingSpace) sugarSuppliesFlapTab.
	self pasteUpMorph addMorphFront: supplies.
	^ supplies
]

{ #category : #buttons }
InteriorSugarNavBar >> shareThisWorld [
	"If I have a share button, make it inoperative."
]

{ #category : #'morphic interaction' }
InteriorSugarNavBar >> step [
	"thwart efforts of superclass."

	self checkForResize
]

{ #category : #buttons }
InteriorSugarNavBar >> stopSqueak [
	"But don't..."
]

{ #category : #'button actions' }
InteriorSugarNavBar >> toggleSupplies [
	"Toggle the whether the interior supplies flap is open."

	| ref aFlapTab |
	aFlapTab := self pasteUpMorph flapTabs
				detect: [:s | (s isKindOf: FlapTab)
						and: [s flapID = 'Supplies' translated]]
				ifNone: [self setupSuppliesFlap].
	ref := aFlapTab referent.
	ref isInWorld
		ifTrue:
			[aFlapTab hideFlap]
		ifFalse:
			[aFlapTab showFlap.
			(owner notNil and: [owner isFlapTab])
				ifTrue: [owner edgeToAdhereTo == #top
						ifTrue: [ref position: self bottomLeft].
					owner edgeToAdhereTo == #bottom
						ifTrue: [ref bottomLeft: self topLeft]]]
]

{ #category : #buttons }
InteriorSugarNavBar >> undoOrRedoLastCommand [
	"For now we let this be alive..."

	^ super undoOrRedoLastCommand
]

{ #category : #'morphic interaction' }
InteriorSugarNavBar >> wantsHaloFromClick [
	"Answer that I would take a halo from a click..."

	^ true

]
