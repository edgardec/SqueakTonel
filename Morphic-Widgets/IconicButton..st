"
A ""Simple Button"" in which the appearance is provided by a Form.
"
Class {
	#name : #IconicButton,
	#superclass : #SimpleButtonMorph,
	#instVars : [
		'darkenedForm'
	],
	#category : #'Morphic-Widgets'
}

{ #category : #menu }
IconicButton >> addLabelItemsTo: aCustomMenu hand: aHandMorph [
	"don't do the inherited behavior, since there is no textual label in this case"
]

{ #category : #initialization }
IconicButton >> borderNormal [
	self borderStyle: (BorderStyle width: 2 color: Color transparent).
]

{ #category : #initialization }
IconicButton >> borderThick [
	self borderStyle: (BorderStyle width: 2 color: self raisedColor twiceDarker).
]

{ #category : #initialization }
IconicButton >> buttonSetup [
	self actWhen: #buttonUp.
	self cornerStyle: #rounded.
	self borderNormal.
	self on: #mouseEnter send: #borderRaised to: self.
	self on: #mouseLeave send: #borderNormal to: self.
	self on: #mouseLeaveDragging send: #borderNormal to: self.
	self on: #mouseDown send: #borderInset to: self.
	self on: #mouseUp send: #borderRaised to: self.
]

{ #category : #'as yet unclassified' }
IconicButton >> darken [

	self firstSubmorph form: self darkenedForm
]

{ #category : #ui }
IconicButton >> darkenedForm [
	^ darkenedForm ifNil: [ darkenedForm := self firstSubmorph baseGraphic darker ]
]

{ #category : #initialization }
IconicButton >> defaultBorderWidth [
	^ 2
]

{ #category : #compatibility }
IconicButton >> dim [
	"backwards compability for old system windows"

]

{ #category : #button }
IconicButton >> doButtonAction [

	super doButtonAction.
	self restoreImage.
]

{ #category : #initialization }
IconicButton >> initialize [
	super initialize.
	self useSquareCorners
]

{ #category : #initialization }
IconicButton >> initializeWithThumbnail: aThumbnail withLabel: aLabel andColor: aColor andSend: aSelector to: aReceiver [ 	
	"Initialize the receiver to show aThumbnail on its face, giving it the label supplied and arranging for it, when the button goes down on it, to obtain a new morph by sending the supplied selector to the supplied receiver"

	| labeledItem nonTranslucent |
	nonTranslucent := aColor asNontranslucentColor.
	labeledItem := AlignmentMorph newColumn.
	labeledItem color: nonTranslucent.
	labeledItem borderWidth: 0.
	labeledItem
		layoutInset: 4@0;
		cellPositioning: #center.
	labeledItem addMorph: aThumbnail.
	labeledItem addMorphBack: (Morph new extent: (4@4)) beTransparent.
	labeledItem addMorphBack: (TextMorph new
		backgroundColor: nonTranslucent;
		contentsAsIs: aLabel;
		beAllFont: Preferences standardEToysFont;
		centered).

	self
		beTransparent;
		labelGraphic: ((labeledItem imageForm: 32 backgroundColor: nonTranslucent forRectangle: labeledItem fullBounds) replaceColor: nonTranslucent withColor: Color transparent);
		borderWidth: 0;
		target: aReceiver;
		actionSelector: #launchPartVia:label:;
		arguments: {aSelector. aLabel};
		actWhen: #buttonDown.

	self stationarySetup.
]

{ #category : #initialization }
IconicButton >> initializeWithThumbnail: aThumbnail withLabel: aLabel andSend: aSelector to: aReceiver [ 	
	"Initialize the receiver to show aThumbnail on its face, giving it the label supplied and arranging for it, when the button goes down on it, to obtain a new morph by sending the supplied selector to the supplied receiver"

	^self initializeWithThumbnail: aThumbnail withLabel: aLabel andColor: Color transparent   andSend: aSelector to: aReceiver 	
]

{ #category : #label }
IconicButton >> labelFromString: aString [
	"Make an iconic label from aString"

	self labelGraphic: (StringMorph contents: aString) imageForm

]

{ #category : #label }
IconicButton >> labelGraphic: aForm [
	| oldLabel graphicalMorph |
	(oldLabel := self findA: SketchMorph)
		ifNotNil: [oldLabel delete].
	graphicalMorph := SketchMorph withForm: aForm.
	self extent: graphicalMorph extent + (self borderWidth + 6).
	graphicalMorph position: self center - (graphicalMorph extent // 2).
	self addMorph: graphicalMorph.
	graphicalMorph 
		baseGraphic;
		lock.

]

{ #category : #events }
IconicButton >> mouseEnter: evt [

	self borderStyle: BorderStyle thinGray
]

{ #category : #events }
IconicButton >> mouseLeave: evt [

	self borderNormal
]

{ #category : #ui }
IconicButton >> restoreImage [

	self firstSubmorph restoreBaseGraphic.
]

{ #category : #initialization }
IconicButton >> setDefaultLabel [
	self labelGraphic: (ScriptingSystem formAtKey: 'squeakyMouse')
]

{ #category : #ui }
IconicButton >> shedSelvedge [
	self extent: (self extent - (6@6))
]

{ #category : #initialization }
IconicButton >> stationarySetup [
	"Set up event handlers for mouse actions.  Should be spelled stationery..."

	self actWhen: #startDrag.
	self cornerStyle: #rounded.
	self borderNormal.
	self on: #mouseEnter send: #borderThick to: self.
	self on: #mouseDown send: nil to: nil.
	self on: #mouseLeave send: #borderNormal to: self.
	self on: #mouseLeaveDragging send: #borderNormal to: self.
	self on: #mouseUp send: #borderThick to: self.

	self on: #click send: #launchPartFromClick to: self
]

{ #category : #compatibility }
IconicButton >> undim [
     "backwards compability for old system windows"

]
