"
A NewColorPickerMorph is a new widget for choosing colors in Morphic.  Instantiate a NewColorPickerMorph:

	(NewColorPickerMorph
		on: objectToHaveItsColorSet
		getColorSelector: itsColorGetterSymbol
		setColorSelector: itsColorSetterSymbol) openInWorld


"
Class {
	#name : #NewColorPickerMorph,
	#superclass : #Morph,
	#instVars : [
		'target',
		'setColorSelector',
		'hsvaMorph',
		'colorPresenter'
	],
	#classVars : [
		'UseIt'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #create }
NewColorPickerMorph class >> on: anObject [ 
	^ self
		on: anObject
		originalColor: anObject color
		setColorSelector: #color:
]

{ #category : #create }
NewColorPickerMorph class >> on: objectToHaveItsColorSet originalColor: originalColor setColorSelector: colorSetterSymbol [ 
	^ self 
		on: objectToHaveItsColorSet
		originalColor: originalColor
		setColorSelector: colorSetterSymbol
		forPropertiesPanel: false
]

{ #category : #create }
NewColorPickerMorph class >> on: objectToHaveItsColorSet originalColor: originalColor setColorSelector: colorSetterSymbol forPropertiesPanel: aBool [
	^ self new
		setTarget: objectToHaveItsColorSet
		originalColor: originalColor
		setColorSelector: colorSetterSymbol
		forPropertiesPanel: aBool
]

{ #category : #accessing }
NewColorPickerMorph class >> useIt [
	<preference: 'Use the new color-picker'
		category: 'colors'
		description: 'When true, a newly-enhanced color-picker is used.'
		type: #Boolean>
	^ UseIt ifNil: [ false ]
]

{ #category : #accessing }
NewColorPickerMorph class >> useIt: aBoolean [
	UseIt := aBoolean
]

{ #category : #'initialize-release' }
NewColorPickerMorph >> closeButtonLabel [
	^ 'Close' translated
]

{ #category : #accessing }
NewColorPickerMorph >> colorExpression [
	"A Smalltalk which can create this color."
	^ self selectedColor printString
]

{ #category : #accessing }
NewColorPickerMorph >> colorExpression: aString [ 
	"Set my color by evaluating aString, a Smalltalk expression which results in a Color instance."
	| col |
	{aString. 
	'Color ' , aString}
		detect:
			[ : each | ([ col := Compiler evaluate: each ]
				on: Error
				do:
					[ : err | nil ]) notNil ]
		ifNone: [ nil ].
	col ifNotNil: [ self selectedColor: col ]
]

{ #category : #model }
NewColorPickerMorph >> colorSelected: aColor [
	self targetColor: aColor.
	self changed: #colorExpression
]

{ #category : #'initialize-release' }
NewColorPickerMorph >> initialize [
	super initialize.
	self initializeHsvaMorph
]

{ #category : #'initialize-release' }
NewColorPickerMorph >> initializeHsvaMorph [
	hsvaMorph := HSVAColorSelectorMorph new
		 hResizing: #spaceFill ;
		 vResizing: #spaceFill ;
		 yourself.
	hsvaMorph
		when: #selectedColor
		send: #colorSelected:
		to: self
]

{ #category : #'initialize-release' }
NewColorPickerMorph >> newBottomRow [
	^ Morph new
		 color: Color transparent ;
		 changeTableLayout ;
		 listDirection: #leftToRight ;
		 hResizing: #spaceFill; vResizing: #shrinkWrap ;
		 height: 20 ;
		 cellGap: 4 ;
		 addMorph: (StringMorph contents: 'Current selection:' translated) ;
		 addMorphBack: self newColorPresenterMorph ;
		 addMorphBack: self newCloseButton
]

{ #category : #'initialize-release' }
NewColorPickerMorph >> newCloseButton [
	^ (PluggableButtonMorph
		on: self
		getState: nil
		action: #delete
		label: #closeButtonLabel)
		 vResizing: #spaceFill ;
		hResizing: #spaceFill;
		 yourself
]

{ #category : #'initialize-release' }
NewColorPickerMorph >> newColorExpressionMorph [
	| inputField builder |
	builder := ToolBuilder default.
	inputField := (builder build: (builder pluggableInputFieldSpec new
		model: self;
		getText: #colorExpression;
		setText: #colorExpression:)).
	inputField
		 hResizing: #spaceFill ;
		 vResizing: #rigid ;
		 height: (Preferences standardDefaultTextFont height * 3/2).
	^ inputField
]

{ #category : #'initialize-release' }
NewColorPickerMorph >> newColorPresenterMorph [
	^ (ColorPresenterMorph
		on: hsvaMorph
		color: #selectedColor)
		 vResizing: #rigid ; height: 20 ;
		 hResizing: #spaceFill ;
		 yourself
]

{ #category : #accessing }
NewColorPickerMorph >> selectedColor [
	"The color selected."
	^ hsvaMorph selectedColor
]

{ #category : #accessing }
NewColorPickerMorph >> selectedColor: aColor [
	"The color selected."
	hsvaMorph selectedColor: aColor
]

{ #category : #model }
NewColorPickerMorph >> setColorSelector [
	"Answer the value of setColorSelector"

	^ setColorSelector
]

{ #category : #'initialize-release' }
NewColorPickerMorph >> setTarget: objectToHaveItsColorSet originalColor: aColor setColorSelector: colorSetterSymbol [ 
	target := objectToHaveItsColorSet.
	setColorSelector := colorSetterSymbol.
	hsvaMorph selectedColor: aColor.
	self setup
]

{ #category : #'initialize-release' }
NewColorPickerMorph >> setTarget: objectToHaveItsColorSet originalColor: aColor setColorSelector: colorSetterSymbol forPropertiesPanel: aBool [ 
	target := objectToHaveItsColorSet.
	setColorSelector := colorSetterSymbol.
	hsvaMorph selectedColor: aColor.
	aBool
		ifTrue: [self setupForProperties]
		ifFalse: [self setup]
]

{ #category : #'initialize-release' }
NewColorPickerMorph >> setup [
	self
		 color: (Color white darker) ;
		 cornerStyle: #rounded ;
		 changeTableLayout ;
		 hResizing: #shrinkWrap ;
		 vResizing: #shrinkWrap ;
		 extent: 240@240 ;
		 addMorphBack: hsvaMorph ;
		 addMorphBack: self newColorExpressionMorph ;
		 addMorphBack: self newBottomRow ;
		 layoutInset: 4 ;
		 cellGap: 2.
		
		Preferences menuAppearance3d
		ifTrue: [self addDropShadow].
	
]

{ #category : #'initialize-release' }
NewColorPickerMorph >> setupForProperties [
	self
		 color: (Color white darker) ;
		 changeTableLayout ;
		 hResizing: #shrinkWrap ;
		 vResizing: #shrinkWrap ;
		 extent: 240@240 ;
		 addMorphBack: hsvaMorph ;
		 layoutInset: 4 ;
		 cellGap: 2.
]

{ #category : #model }
NewColorPickerMorph >> target [
	"Answer the object whose color will be controlled."
	^ target
]

{ #category : #accessing }
NewColorPickerMorph >> targetColor: aColor [ 
	"The color of my target."
	target ifNotNil:
		[ target
			perform: setColorSelector
			with: aColor ]
]
