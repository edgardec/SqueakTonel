Class {
	#name : #ComponentLikeModel,
	#superclass : #MorphicModel,
	#instVars : [
		'pinSpecs'
	],
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #components }
ComponentLikeModel >> addPinFromSpec: pinSpec [
	| pin |
	pin := PinMorph new component: self pinSpec: pinSpec.
	self addMorph: pin.
	pin placeFromSpec.
	^ pin
]

{ #category : #naming }
ComponentLikeModel >> choosePartName [
	"When I am renamed, get a slot, make default methods, move any existing methods."

	| old |
	(self pasteUpMorph model isKindOf: Component) 
		ifTrue: 
			[self knownName ifNil: [^self nameMeIn: self pasteUpMorph]
				ifNotNil: [^self renameMe]].
	old := slotName.
	super choosePartName.
	slotName ifNil: [^self].	"user chose bad slot name"
	self model: self world model slotName: slotName.
	old isNil 
		ifTrue: [self compilePropagationMethods]
		ifFalse: [self copySlotMethodsFrom: old]
	"old ones not erased!"
]

{ #category : #'submorphs-add\/remove' }
ComponentLikeModel >> delete [
	"Delete the receiver.  Possibly put up confirming dialog.  Abort if user changes mind"

	(model isKindOf: Component) ifTrue: [^self deleteComponent].
	(model isMorphicModel) ifFalse: [^super delete].
	slotName ifNotNil: 
			[(PopUpMenu confirm: 'Shall I remove the slot ' , slotName 
						, '
	along with all associated methods?') 
				ifTrue: 
					[(model class selectors select: [:s | s beginsWith: slotName]) 
						do: [:s | model class removeSelector: s].
					(model class instVarNames includes: slotName) 
						ifTrue: [model class removeInstVarName: slotName]]
				ifFalse: 
					[(PopUpMenu 
						confirm: '...but should I at least dismiss this morph?
	[choose no to leave everything unchanged]') 
							ifFalse: [^self]]].
	super delete
]

{ #category : #components }
ComponentLikeModel >> deleteComponent [
	model removeDependent: self.
	self pinsDo: [:pin | pin delete].
	^ super delete
]

{ #category : #initialization }
ComponentLikeModel >> duplicate: newGuy from: oldGuy [
	"oldGuy has just been duplicated and will stay in this world.  Make sure all the ComponentLikeModel requirements are carried out for the copy.  Ask user to rename it.  "

	newGuy installModelIn: oldGuy pasteUpMorph.
	newGuy copySlotMethodsFrom: oldGuy slotName.
]

{ #category : #geometry }
ComponentLikeModel >> extent: newExtent [
	super extent: newExtent.
	self submorphsDo: [:m | (m isKindOf: PinMorph) ifTrue: [m placeFromSpec]]
]

{ #category : #components }
ComponentLikeModel >> initComponentIn: aLayout [
	model := aLayout model.
	self nameMeIn: aLayout.
	self color: Color lightCyan.
	self initPinSpecs.
	self initFromPinSpecs.
	self showPins.
	model addDependent: self
]

{ #category : #components }
ComponentLikeModel >> initFromPinSpecs [
	"no-op for default"
]

{ #category : #components }
ComponentLikeModel >> initPinSpecs [
	"no-op for default"
	pinSpecs := Array new.

]

{ #category : #'dropping\/grabbing' }
ComponentLikeModel >> justDroppedInto: aMorph event: anEvent [
	| theModel |
	theModel := aMorph modelOrNil.
	((aMorph isKindOf: ComponentLayout) 
		and: [theModel isKindOf: Component]) ifFalse:
		["Disconnect prior to removal by move"
		(theModel isKindOf: Component) ifTrue: [self unwire.  model := nil].
		^ super justDroppedInto: aMorph event: anEvent].
	theModel == model ifTrue: [^ self  "Presumably just a move"].
	self initComponentIn: aMorph.
	super justDroppedInto: aMorph event: anEvent
]

{ #category : #components }
ComponentLikeModel >> nameMeIn: aWorld [
	| stem otherNames i partName className |
	className := self class name.
	stem := className.
	(stem size > 5 and: [stem endsWith: 'Morph'])
		ifTrue: [stem := stem copyFrom: 1 to: stem size - 5].
	stem := stem first asLowercase asString , stem allButFirst.
	otherNames := Set newFrom: aWorld allKnownNames.
	i := 1.
	[otherNames includes: (partName := stem , i printString)]
		whileTrue: [i := i + 1].
	self setNamePropertyTo: partName
]

{ #category : #components }
ComponentLikeModel >> pinSpecs [
	^ pinSpecs
]

{ #category : #components }
ComponentLikeModel >> pinsDo: pinBlock [
	self submorphsDo: [:m | (m isKindOf: PinMorph) ifTrue: [pinBlock value: m]]
]

{ #category : #components }
ComponentLikeModel >> renameMe [
	| otherNames newName |
	otherNames := Set newFrom: self pasteUpMorph allKnownNames.
	newName := FillInTheBlank request: 'Please give this new a name'
						initialAnswer: self knownName.
	newName isEmpty ifTrue: [^ nil].
	(otherNames includes: newName) ifTrue:
			[self inform: 'Sorry, that name is already used'. ^ nil].
	self setNamePropertyTo: newName
]

{ #category : #components }
ComponentLikeModel >> showPins [
	"Make up sensitized pinMorphs for each of my interface variables"
	self pinSpecs do: [:pinSpec | self addPinFromSpec: pinSpec]
]
