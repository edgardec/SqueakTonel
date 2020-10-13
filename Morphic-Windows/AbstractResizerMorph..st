"
I am the superclass of a hierarchy of morph specialized in allowing the user to resize or rearrange windows and panes.
"
Class {
	#name : #AbstractResizerMorph,
	#superclass : #Morph,
	#instVars : [
		'handleColor',
		'handleInset',
		'lastMouse',
		'showHandle'
	],
	#classVars : [
		'GripThickness',
		'HandleLength'
	],
	#category : #'Morphic-Windows'
}

{ #category : #preferences }
AbstractResizerMorph class >> gripThickness [
	"A number in pixels that encodes the area were the user can target splitters or edge grips."

	<preference: 'Grip Thickness'
		category: 'windows'
		description: 'A number in pixels that encodes the area were the user can target splitters or edge grips such as in application windows. Bigger grips make it easier to click on them.'
		type: #Number>
		
	^ GripThickness ifNil: [4]
]

{ #category : #preferences }
AbstractResizerMorph class >> gripThickness: anInteger [

	GripThickness := anInteger.
	Project current restoreDisplay.
	
	self flag: #todo. "mt: Update existing grips. This is challenging because it interferes with ProportionalLayoutPolicy, which is tricky to refresh from here for arbitrary morphs."
]

{ #category : #preferences }
AbstractResizerMorph class >> handleLength [

	<preference: 'Handle Length'
		category: 'windows'
		description: 'AThe size of a grip handle if shown. Can be interpreted as width or height, depending of the resizer orientation. Does not affect the clickable area. See grip thickness for that.'
		type: #Number>
			
	^ HandleLength ifNil: [25]
]

{ #category : #preferences }
AbstractResizerMorph class >> handleLength: anInteger [

	HandleLength := anInteger.
	Project current restoreDisplay.
	
	self flag: #todo. "mt: Update existing grips. This is challenging because it interferes with ProportionalLayoutPolicy, which is tricky to refresh from here for arbitrary morphs."
]

{ #category : #accessing }
AbstractResizerMorph >> handleColor [
	"Either use my handle color if set up or derive the handle color from my owner's color if I have an owner."
	
	^ (handleColor notNil or: [self owner isNil])
		ifTrue: [handleColor ifNil: [Color black]]
		ifFalse: [(self userInterfaceTheme resizerColorModifier ifNil: [ [:c | c muchDarker] ])
					value: (self owner color isTransparent ifTrue: [Color white] ifFalse: [self owner color]) ]
]

{ #category : #accessing }
AbstractResizerMorph >> handleColor: aColor [

	handleColor := aColor.
	self changed.
]

{ #category : #accessing }
AbstractResizerMorph >> handleInset [

	^ handleInset ifNil: [1]
]

{ #category : #accessing }
AbstractResizerMorph >> handleInset: anInteger [

	handleInset := anInteger.
	self changed.
]

{ #category : #'event handling' }
AbstractResizerMorph >> handlesMouseDown: anEvent [

	^ true
]

{ #category : #'event handling' }
AbstractResizerMorph >> handlesMouseOver: anEvent [

	^ true
	
]

{ #category : #initialization }
AbstractResizerMorph >> initialize [

	super initialize.
	self color: Color transparent
]

{ #category : #'event handling' }
AbstractResizerMorph >> mouseDown: anEvent [

	self referencePoint: anEvent position.
]

{ #category : #'event handling' }
AbstractResizerMorph >> mouseEnter: anEvent [

	anEvent hand showTemporaryCursor: self resizeCursor.
]

{ #category : #'event handling' }
AbstractResizerMorph >> mouseLeave: anEvent [

	anEvent hand showTemporaryCursor: nil.
]

{ #category : #accessing }
AbstractResizerMorph >> referencePoint [

	^ lastMouse
]

{ #category : #accessing }
AbstractResizerMorph >> referencePoint: aPoint [

	lastMouse := aPoint.
]

{ #category : #accessing }
AbstractResizerMorph >> resizeCursor [
	"The cursor shape I will set to the hand on hovering."
	
	self subclassResponsibility.
]

{ #category : #initialization }
AbstractResizerMorph >> setDefaultColors [

	"handleColor := Color lightGray lighter lighter.
	dotColor := Color gray lighter"
]

{ #category : #initialization }
AbstractResizerMorph >> setInverseColors [

	"handleColor := Color lightGray.
	dotColor := Color white"
]

{ #category : #accessing }
AbstractResizerMorph >> showHandle [

	^ showHandle ifNil: [false]
]

{ #category : #accessing }
AbstractResizerMorph >> showHandle: aBoolean [

	showHandle := aBoolean.
	self changed.
]
