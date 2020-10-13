Class {
	#name : #Component,
	#superclass : #Player,
	#instVars : [
		'model',
		'pinSpecs'
	],
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #compiling }
Component class >> acceptsLoggingOfCompilation [
	"Log everything for now"

	^ true
]

{ #category : #'as yet unclassified' }
Component class >> addSlotNamed: aName [
	(self allInstVarNames includes: aName) ifTrue: [self error: 'Duplicate slot name'].
	self addInstVarName: aName.

]

{ #category : #'as yet unclassified' }
Component class >> includeInNewMorphMenu [
	"Only include instances of subclasses of me"
	^ self ~~ Component
]

{ #category : #other }
Component class >> isSystemDefined [
	^ true

]

{ #category : #other }
Component class >> isUniClass [
	"UnscriptedPlayer reimplements to false"

	^ false
]

{ #category : #compiling }
Component class >> wantsChangeSetLogging [
	"Log changes for Component itself, but not for automatically-created subclasses like Component1, Component2"

	"^ self == Component or:
		[(self class name beginsWith: 'Component') not]"

	"Log everything for now"
	false ifTrue: [self halt  "DONT FORGET TO REORDER FILEOUT"].
	^ true
]

{ #category : #variables }
Component >> addVariableNamed: varName [ 
	"Adjust name if necessary and add it"

	| otherNames i partName |
	otherNames := self class allInstVarNames.
	i := nil.
	
	[partName := i isNil 
		ifTrue: [varName]
		ifFalse: [varName , i printString].
	otherNames includes: partName] 
			whileTrue: [i := i isNil ifTrue: [1] ifFalse: [i + 1]].
	self class addInstVarName: partName.

	"Now compile read method and write-with-change method"
	self class 
		compile: (String streamContents: 
					[:s | 
					s
						nextPutAll: partName;
						cr;
						tab;
						nextPutAll: '^' , partName])
		classified: 'view access'
		notifying: nil.
	self class 
		compile: (String streamContents: 
					[:s | 
					s
						nextPutAll: partName , 'Set: newValue';
						cr;
						tab;
						nextPutAll: partName , ' := newValue.';
						cr;
						tab;
						nextPutAll: 'self changed: #' , partName , '.';
						cr;
						tab;
						nextPutAll: '^ true'	"for components that expect a boolean for accept"])
		classified: 'view access'
		notifying: nil.
	^Array with: partName asSymbol with: (partName , 'Set:') asSymbol
]

{ #category : #naming }
Component >> chooseNameLike: someName [ 
	| stem otherNames i partName |
	stem := someName.
	(stem size > 5 and: [stem endsWith: 'Morph'])
		ifTrue: [stem := stem copyFrom: 1 to: stem size - 5].
	stem := stem first asLowercase asString , stem allButFirst.
	otherNames := self class allInstVarNames asSet.
	"otherNames addAll: self world allKnownNames."
	i := 1.
	[otherNames includes: (partName := stem , i printString)]
		whileTrue: [i := i + 1].
	partName := FillInTheBlank request: 'Please give this part a name'
						initialAnswer: partName.
	partName isEmpty ifTrue: [^ nil].
	(otherNames includes: partName) ifTrue:
			[self inform: 'Sorry, that name is already used'.
			^ nil].
	^ partName
]

{ #category : #viewer }
Component >> externalName [ 
	^ self class name
]

{ #category : #initialize }
Component >> initComponentIn: aLayout [
	model := aLayout model.
	self nameMeIn: aLayout world.
	self color: Color lightCyan.
	self showPins.
	model addDependent: self
]

{ #category : #'drag and drop' }
Component >> justDroppedInto: aMorph event: anEvent [
	| theModel |
	theModel := aMorph model.
	((aMorph isKindOf: ComponentLayout) 
		and: [theModel isKindOf: Component]) ifFalse:
		["Disconnect prior to removal by move"
		(theModel isKindOf: Component) ifTrue: [self unwire.  model := nil].
		^ super justDroppedInto: aMorph event: anEvent].
	theModel == model ifTrue: [^ self  "Presumably just a move"].
	self initComponentIn: aMorph.
	super justDroppedInto: aMorph event: anEvent.
]

{ #category : #naming }
Component >> nameMeIn: aWorld [
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

{ #category : #variables }
Component >> removeVariableNamed: varName [ 
	self class removeSelector: varName.
	self class removeSelector: (varName , 'Set:') asSymbol.
	self class removeInstVarName: varName asString
]

{ #category : #naming }
Component >> renameMe [
	| newName |
	newName := self chooseNameLike: self knownName.
	newName ifNil: [^ nil].
	self setNamePropertyTo: newName
]
