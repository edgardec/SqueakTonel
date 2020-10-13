Class {
	#name : #FunctionComponent,
	#superclass : #TextComponent,
	#instVars : [
		'inputSelectors',
		'functionSelector',
		'outputSelector',
		'outputValue'
	],
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #'menu commands' }
FunctionComponent >> accept [
	"Inform the model of text to be accepted, and return true if OK."
	| textToAccept oldSelector |
	oldSelector := functionSelector.
	textToAccept := textMorph asText.
	textToAccept = self getText ifTrue: [^ self].  "No body to compile yet"
	functionSelector := model class
		compile: self headerString , textToAccept asString
		classified: 'functions' notifying: nil.
	self setText: textToAccept.
	self hasUnacceptedEdits: false.
	oldSelector ifNotNil:
		[functionSelector = oldSelector ifFalse: [model class removeSelector: oldSelector]].
	self fire
]

{ #category : #menu }
FunctionComponent >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add custom menu items"

	super addCustomMenuItems: aMenu hand: aHandMorph.
	aMenu add: 'add pin' translated target: self selector: #addPin.

]

{ #category : #'as yet unclassified' }
FunctionComponent >> addPin [ 
	| i prev sideLength wasNew |
	wasNew := self getText = textMorph asText.
	i := pinSpecs size.
	prev := pinSpecs last.
	sideLength := prev pinLoc asInteger odd ifTrue: [self height] ifFalse: [self width].
	pinSpecs := pinSpecs copyWith:
		(PinSpec new pinName: ('abcdefghi' copyFrom: i to: i) direction: #input
				localReadSelector: nil localWriteSelector: nil
				modelReadSelector: nil modelWriteSelector: nil
				defaultValue: nil pinLoc: prev pinLoc + (8/sideLength) asFloat \\ 4).
	self initFromPinSpecs.
	self addPinFromSpec: pinSpecs last.
	wasNew ifTrue: [self setText: self getText].
	self accept
	
]

{ #category : #button }
FunctionComponent >> fire [
	| arguments newValue |
	outputSelector ifNil: [^outputValue := nil].
	functionSelector ifNil: [^outputValue := nil].
	arguments := inputSelectors 
				collect: [:s | s ifNil: [nil] ifNotNil: [model perform: s]].
	newValue := (arguments findFirst: [:a | a isNil]) = 0 
				ifTrue: [model perform: functionSelector withArguments: arguments]
				ifFalse: [nil].
	newValue = outputValue 
		ifFalse: 
			[model perform: outputSelector with: newValue.
			outputValue := newValue]
]

{ #category : #'model access' }
FunctionComponent >> getText [
	| ps |
	^ ('"type a function of' ,
		(String streamContents:
			[:s | 2 to: pinSpecs size do:
				[:i | ps := pinSpecs at: i.
				(i>2 and: [i = pinSpecs size]) ifTrue: [s nextPutAll: ' and'].
				s nextPutAll: ' ', ps pinName]]) ,
		'"') asText
]

{ #category : #'as yet unclassified' }
FunctionComponent >> headerString [
	| ps |
	^ String streamContents:
		[:s | s nextPutAll: self knownName.
		2 to: pinSpecs size do:
			[:i | ps := pinSpecs at: i.
			s nextPutAll: ps pinName , ': ';
				nextPutAll: ps pinName , ' '].
		s cr; tab; nextPutAll: '^ ']
]

{ #category : #components }
FunctionComponent >> initFromPinSpecs [
	outputSelector := pinSpecs first modelWriteSelector.
	inputSelectors := (pinSpecs copyFrom: 2 to: pinSpecs size)
						collect: [:ps | ps modelReadSelector]
]

{ #category : #components }
FunctionComponent >> initPinSpecs [ 
	pinSpecs := Array
		with: (PinSpec new pinName: 'output' direction: #output
				localReadSelector: nil localWriteSelector: nil
				modelReadSelector: nil modelWriteSelector: nil
				defaultValue: nil pinLoc: 3.5)
		with: (PinSpec new pinName: 'a' direction: #input
				localReadSelector: nil localWriteSelector: nil
				modelReadSelector: nil modelWriteSelector: nil
				defaultValue: nil pinLoc: 1.5)

]

{ #category : #updating }
FunctionComponent >> update: aSymbol [
	inputSelectors do:
		[:s | aSymbol = s ifTrue: [^ self fire]].
]
