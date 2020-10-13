Class {
	#name : #GradientEditor,
	#superclass : #RectangleMorph,
	#instVars : [
		'gradientDisplay',
		'rampMorphs',
		'selectedSketch',
		'row',
		'text',
		'target',
		'selector',
		'morph'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #'instance creation' }
GradientEditor class >> on: aTarget selector: aSelector forMorph: aMorph colorRamp: aColorRamp [
	^self new 
		setTarget: aTarget
		selector: aSelector
		forMorph: aMorph
		colorRamp: aColorRamp.
		

]

{ #category : #initialization }
GradientEditor >> addButtonRow [
	| button button2 buttonRow button3 |
	buttonRow := RectangleMorph new borderWidth: 0; 
		color: Color transparent;
		layoutPolicy: TableLayout new;
		 hResizing: #spaceFill;
		 vResizing: #spaceFill;
		 cellPositioning: #center;
		 listCentering: #topLeft;
		 listDirection: #LeftToRight;
		 reverseTableCells: true;
		 cellGap: 4.

	button := PluggableButtonMorph on: self
				getState: nil
				action: #addHandle
				label: #addColorButtonLabel.
	button hResizing: #spaceFill;
			vResizing: #spaceFill.
	buttonRow  addMorph: button.

	button2 := PluggableButtonMorph on: self
				getState: nil
				action: #deleteHandle
				label: #removeColorButtonLabel.
	button2 hResizing: #spaceFill;
			vResizing: #spaceFill.
	buttonRow addMorph: button2.

	button3 := PluggableButtonMorph on: self
				getState: nil
				action: #delete
				label: #closeButtonLabel.
	button3 hResizing: #spaceFill;
			vResizing: #spaceFill.
	buttonRow addMorph: button3.
	
	self addMorph: buttonRow
]

{ #category : #initialization }
GradientEditor >> addColorButtonLabel [
	^ 'Add color' translated
]

{ #category : #'change reporting' }
GradientEditor >> addHandle [
	self addHandleForColor: Color random position: 0.5.
	self updateColorRamp
]

{ #category : #'change reporting' }
GradientEditor >> addHandleForColor: aColor position: aPosition [
	| handleInstance colorIcon delta |
	handleInstance := self handle.
	colorIcon := SketchMorph
						withForm: ((aColor iconOrThumbnailOfSize: 20) borderWidth: 1 color: Color black)..
	self eventHandler: colorIcon target: colorIcon.
	self eventHandler: handleInstance target: self.
	row addMorph: handleInstance.
	delta := gradientDisplay left - 10 + (gradientDisplay width * aPosition).
	handleInstance position:  delta @ (gradientDisplay top - 18).
	colorIcon position: delta @ (gradientDisplay bottom + 5).
	handleInstance addMorph: colorIcon.
	rampMorphs addLast: handleInstance.
	
	
]

{ #category : #'change reporting' }
GradientEditor >> addHandles [
	| handle colorRamp |
	rampMorphs := OrderedCollection new.
	colorRamp := gradientDisplay colorRamp asOrderedCollection.
	handle := self handle.
	colorRamp
		do: [:i | 
			self addHandleForColor: i value position: i key
			].
	
	self changed.
]

{ #category : #'change reporting' }
GradientEditor >> changeColor: aSketchMorph event: evt target: aMorph [
	| newColor |
	newColor := aSketchMorph rotatedForm colorAt: aSketchMorph rotatedForm center.
	selectedSketch := aSketchMorph.
 	self changeColorTarget: self selector: #updateColor: originalColor: newColor value hand: evt hand.
	
]

{ #category : #initialization }
GradientEditor >> closeButtonLabel [
	^ 'Close' translated
]

{ #category : #accessing }
GradientEditor >> colorRamp [
	^gradientDisplay fillStyle colorRamp asArray printString.
	
]

{ #category : #accessing }
GradientEditor >> colorRamp: aColorRamp [
	gradientDisplay colorRamp: aColorRamp.
	self changed: #colorRamp.
	self changed
	

]

{ #category : #accessing }
GradientEditor >> colorRampExpression: aString [ 
	"Set my color by evaluating aString, a Smalltalk expression which results in a Color instance."
	| col |
	
	{aString.}
		detect:
			[ : each | ([ col := Compiler evaluate: each ]
				on: Error
				do:
					[ : err | nil ]) notNil ]
		ifNone: [ nil ]. 
	col ifNotNil: [ self colorRamp: col.
	rampMorphs do:[ :each| each delete].
	self addHandles; updateColorRamp. ]
]

{ #category : #initialization }
GradientEditor >> colorRampExpressionMorph [
	| inputField builder |
	builder := ToolBuilder default.
	inputField := (builder build: (builder pluggableInputFieldSpec new
		model: self;
		getText: #colorRamp;
		setText: #colorRampExpression:;
		softLineWrap: true)).
	inputField
		 hResizing: #spaceFill ;
		 vResizing: #spaceFill ;
		 
		 height: (Preferences standardDefaultTextFont height * 3/2).
	^ inputField
]

{ #category : #'change reporting' }
GradientEditor >> deleteHandle [
	rampMorphs do:[ :i | (i color == Color black) ifTrue:[ rampMorphs remove: i. row removeMorph: i]].
	self updateColorRamp
	

]

{ #category : #'event handling' }
GradientEditor >> eventHandler: anInstance target: aTarget [ 
	(anInstance isKindOf: SketchMorph)
		ifTrue: [anInstance
				on: #mouseUp
				send: #changeColor:event:target:
				to: self
				withValue: aTarget]
		ifFalse: [anInstance
				on: #mouseDown
				send: #limitHandleMove:event:from:
				to: self
				withValue: aTarget.
			anInstance
				on: #mouseMove
				send: #limitHandleMove:event:from:
				to: self
				withValue: aTarget]
]

{ #category : #initialization }
GradientEditor >> handle [
	| handle |
	handle := PolygonMorph
				vertices: (Array
						with: 0 @ 0
						with: 16 @ 0
						with: 8 @ 16)
				color: Color white darker
				borderWidth: 1
				borderColor: Color black.
	^ handle
		addMorph: ((RectangleMorph
				newBounds: (8 @ 18 extent: 1 @ (gradientDisplay height - 2))
				color: Color orange)
				borderWidth: 0)
]

{ #category : #initialization }
GradientEditor >> initialize [
	super initialize.
	self myLayout.
	self extent: 500 @ 200.
	row := RectangleMorph new extent: self width @ 100;
				 color: Color transparent;
				 borderStyle: BorderStyle inset.
	row addMorph: (gradientDisplay := GradientDisplayMorph new position: 20 @ 20;
					 extent: self width - 40 @ 40).
	gradientDisplay fillStyle direction: gradientDisplay width @ 0.
	self addMorph: row.
	self addButtonRow.
	self addMorph: self colorRampExpressionMorph
]

{ #category : #'change reporting' }
GradientEditor >> limitHandleMove: association event: evt from: handle [
	| p  newBounds |
	rampMorphs do:[ : i | i color: (Color white darker)].
	newBounds := gradientDisplay bounds.
	newBounds := (newBounds left: (newBounds left - 10)).
	newBounds := (newBounds right: (newBounds right - 10)). 
	p := (evt cursorPoint - (10@0)) adhereTo: newBounds.
	handle position: (p x )@ (handle position y).
	handle color: Color black.
	self updateColorRamp
]

{ #category : #accessing }
GradientEditor >> morph: aMorph [
	^morph := aMorph
]

{ #category : #initialization }
GradientEditor >> myLayout [
	self color: (Color white darker) ;
		 cornerStyle: #rounded ;
		 borderWidth: 0;
		 layoutPolicy: TableLayout new;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 cellPositioning: #center;
		 listCentering: #topLeft;
		 layoutInset: 4;
		 listDirection: #topToBottom;
		 reverseTableCells: true;
		 wrapCentering: #topLeft;
		 cellGap: 4
]

{ #category : #initialization }
GradientEditor >> removeColorButtonLabel [
	^ 'Remove color' translated
]

{ #category : #accessing }
GradientEditor >> selector: aSelector [	
	^selector := aSelector
]

{ #category : #initialization }
GradientEditor >> setTarget: aTarget selector: aSelector forMorph:aMorph colorRamp: aColorRamp [

	self target: aTarget; selector: aSelector; morph: aMorph; colorRamp: aColorRamp; addHandles
	
		
]

{ #category : #accessing }
GradientEditor >> target: aTarget [
	^target := aTarget
]

{ #category : #'change reporting' }
GradientEditor >> updateColor: aColor [
	selectedSketch rotatedForm  floodFill: aColor at: selectedSketch rotatedForm center.
	self updateColorRamp

]

{ #category : #'change reporting' }
GradientEditor >> updateColorRamp [
	| newAssociation newKey newColor sketch colorRamp |
	
	self updateRampMorphs.
	colorRamp := OrderedCollection new.
	rampMorphs
		do: [:i | 
			newKey := ((i position x - gradientDisplay left / gradientDisplay width) asFloat roundUpTo: 0.01)
						min: 1.0
						max: 0.0.
			sketch := i findA: SketchMorph.
			newColor := sketch rotatedForm colorAt: sketch rotatedForm center.
			newAssociation := newKey -> newColor.
			colorRamp addLast: newAssociation].
	colorRamp := colorRamp sorted.
	gradientDisplay colorRamp: colorRamp.
	gradientDisplay fillStyle direction: gradientDisplay extent x @ 0.
	self changed.
	target ifNotNil:[
			target perform: selector
			with: colorRamp 
			with: morph].
	self changed: #colorRamp
]

{ #category : #'change reporting' }
GradientEditor >> updateRampMorphs [
	rampMorphs do:[ :i | i isInWorld ifFalse:[ rampMorphs remove: i]]
]
