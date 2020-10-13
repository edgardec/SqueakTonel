Class {
	#name : #SpeechBubbleMorph,
	#superclass : #Morph,
	#instVars : [
		'type',
		'balloon',
		'tail',
		'target',
		'lastHash',
		'stepTime',
		'msgMorph'
	],
	#classInstVars : [
		'speakingForm',
		'topLeftCornerForm',
		'thinkingForm'
	],
	#category : #'Etoys-Squeakland-Etoys-SpeechBubbles'
}

{ #category : #'viewer categories' }
SpeechBubbleMorph class >> additionsToViewerCategoryBubble [
	"Answer viewer additions for the 'bubble' category"

	^#(
		bubble 
		(
			(command attachTo: 'Make the bubble follow an object' Player)
			(command stopAttaching 'Free the bubble from following an object')
			(slot attachment 'The object this bubble is currently following' Player readOnly Player getAttachment Player unused)		
		)
	)

]

{ #category : #forms }
SpeechBubbleMorph class >> bottomLeftCornerForm [
^self topLeftCornerForm flipBy: #vertical centerAt: self topLeftCornerForm boundingBox topCenter
]

{ #category : #forms }
SpeechBubbleMorph class >> bottomRightCornerForm [
^(self topLeftCornerForm flipBy: #horizontal centerAt: self topLeftCornerForm boundingBox leftCenter) flipBy: #vertical centerAt: self topLeftCornerForm boundingBox topCenter
]

{ #category : #'instance creation' }
SpeechBubbleMorph class >> form: aForm type: aSymbol [
^(self basicNew setMorph: (SketchMorph withForm: aForm) type: aSymbol) initialize
]

{ #category : #'instance creation' }
SpeechBubbleMorph class >> form: aForm type: aSymbol for: aMorph [
^(self form: aForm type: aSymbol) target: aMorph
]

{ #category : #'instance creation' }
SpeechBubbleMorph class >> morph: aMorph type: aSymbol [ 
^(self basicNew setMorph: aMorph type: aSymbol) initialize
]

{ #category : #'instance creation' }
SpeechBubbleMorph class >> morph: aMorph type: aSymbol for: targetMorph [
^(self morph: aMorph type: aSymbol) target: targetMorph
]

{ #category : #'instance creation' }
SpeechBubbleMorph class >> new [
	^self string: 'Hello world!'
]

{ #category : #forms }
SpeechBubbleMorph class >> speakingForm [
"
speakingForm := nil
"
^speakingForm ifNil: [speakingForm := (Form
	extent: 56@51
	depth: 16
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147418113 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 65537 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 65537 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	offset: 0@0)]
]

{ #category : #'parts bin' }
SpeechBubbleMorph class >> speechGraphicPrototype [
	^self form: (ScriptingSystem formAtKey: 'Painting') type: #speech
]

{ #category : #'parts bin' }
SpeechBubbleMorph class >> speechPrototype [
	^self string: 'Hello world!' type: #speech
]

{ #category : #'instance creation' }
SpeechBubbleMorph class >> string: aString [ 
^self string: aString type: #speech
]

{ #category : #'instance creation' }
SpeechBubbleMorph class >> string: aString type: aSymbol [
"self string: 'Hello world!' type: #speech"
| text instance |
text := (UserText new contents: aString) centered.
text width > 300 ifTrue: [text contents: aString wrappedTo: 300].
text on: #keyStroke send: #keyStroke:morph: to: (instance := self basicNew).
^(instance setMorph: text type: aSymbol) initialize
]

{ #category : #'instance creation' }
SpeechBubbleMorph class >> string: aString type: aSymbol for: aMorph [
"self string: 'Hello world!' type: #speech for: Morph new openInHand"
^(self string: aString type: aSymbol) target: aMorph
]

{ #category : #'parts bin' }
SpeechBubbleMorph class >> supplementaryPartsDescriptions [
	"Answer a list of DescriptionForPartsBin objects that characterize objects that this class wishes to contribute to Stationery bins *other* than by the standard default #newStandAlone protocol"

	^ {
	DescriptionForPartsBin
		formalName: 'Speech bubble' translatedNoop
		categoryList: #('Just for Fun')
		documentation: 'An object you can use to make words represent the speech of a character in a comic' translatedNoop
		globalReceiverSymbol: #SpeechBubbleMorph
		nativitySelector: #speechPrototype.

	DescriptionForPartsBin
		formalName: 'Thought bubble' translatedNoop
		categoryList: #('Just for Fun')
		documentation: 'An object you can use to make words represent the thoughts of a character in a comic' translatedNoop
		globalReceiverSymbol: #SpeechBubbleMorph
		nativitySelector: #thoughtPrototype.

	DescriptionForPartsBin
		formalName: 'Speech bubble (graphic)' translatedNoop
		categoryList: #('Just for Fun')
		documentation: 'An object you can use to make pictures represent the speech of a character in a comic' translatedNoop
		globalReceiverSymbol: #SpeechBubbleMorph
		nativitySelector: #speechGraphicPrototype.

	DescriptionForPartsBin
		formalName: 'Thought bubble (graphic)' translatedNoop
		categoryList: #('Just for Fun')
		documentation: 'An object you can use to make pictures represent the thoughts of a character in a comic' translatedNoop
		globalReceiverSymbol: #SpeechBubbleMorph
		nativitySelector: #thoughtGraphicPrototype.
}

]

{ #category : #forms }
SpeechBubbleMorph class >> thinkingForm [
"
thinkingForm := nil
thinkingForm
"
^thinkingForm ifNil: [thinkingForm := (Form
	extent: 56@49
	depth: 16
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 65537 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 65537 65537 65537 65537 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 65537 65537 2147450879 2147450879 2147450879 65537 65537 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 65537 65537 65537 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 1 65537 65537 65537 65537 65537 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 65537 65537 98303 2147450879 2147418113 65537 65537 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147418113 65537 65536 1 65537 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 65536 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65536 0 65537 65537 65537 2147450879 2147450879 2147450879 65537 65537 65537 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65536 0 0 1 65537 65537 65537 65537 65537 65537 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 1 65537 65537 65537 65536 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147418113 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 65537 65536 0 1 65537 98303 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 65537 65537 65537 65536 0 65537 65537 98303 2147450879 2147418113 65537 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 65537 65536 0 0 65537 65537 65537 65537 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147418113 65537 0 0 0 65537 65537 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 2147450879 2147450879 2147450879 2147450879 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65537 98303 2147450879 2147450879 2147418113 65537 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 2147450879 2147450879 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 65537 65537 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 65537 65537 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
	offset: 0@0)]
]

{ #category : #'parts bin' }
SpeechBubbleMorph class >> thoughtGraphicPrototype [
	^self form: (ScriptingSystem formAtKey: 'Painting') type: #thought
]

{ #category : #'parts bin' }
SpeechBubbleMorph class >> thoughtPrototype [
	^self string: 'Hello world!' type: #thought
]

{ #category : #forms }
SpeechBubbleMorph class >> topLeftCornerForm [
"
topLeftCornerForm := nil
(SketchMorph withForm: topLeftCornerForm) openInHand
"
^topLeftCornerForm ifNil: [topLeftCornerForm := (Form
	extent: 25@25
	depth: 16
	fromArray: #( 0 0 0 0 0 0 0 1 65537 65537 65537 65537 65536 0 0 0 0 0 1 65537 65537 65537 65537 65537 65537 65536 0 0 0 0 1 65537 65537 65537 2147450879 2147450879 2147450879 2147450879 2147418112 0 0 0 1 65537 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 0 0 0 65537 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 0 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 0 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 0 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 0 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 0 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 0 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 0 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 1 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 1 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 65537 98303 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112 65537 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147450879 2147418112)
	offset: 0@0)]
]

{ #category : #forms }
SpeechBubbleMorph class >> topRightCornerForm [
^self topLeftCornerForm flipBy: #horizontal centerAt:  self topLeftCornerForm boundingBox leftCenter
]

{ #category : #accessing }
SpeechBubbleMorph >> balloon [
	^balloon ifNil: [
		| balloonForm |
		balloonForm := Form extent: (self extent - (0 @ self tailHeight) max: 1@1) depth: 16.
		self drawBalloonOn: balloonForm getCanvas in: balloonForm boundingBox.
		balloonForm floodFill: self color at: balloonForm center.
		balloon := (SketchMorph withForm: balloonForm).
	]
]

{ #category : #accessing }
SpeechBubbleMorph >> color: aColor [
	super color: aColor.
	self refresh
]

{ #category : #testing }
SpeechBubbleMorph >> containsPoint: aPoint [
^ (self bounds containsPoint: aPoint) and:
	  [(self imageForm isTransparentAt: aPoint - bounds origin) not]

]

{ #category : #accessing }
SpeechBubbleMorph >> defaultColor [
	^Color white
]

{ #category : #'initialize-release' }
SpeechBubbleMorph >> delete [
	target isMorph ifTrue: [target bubble: nil].
	super delete.
	target := msgMorph := type := nil.

]

{ #category : #drawing }
SpeechBubbleMorph >> drawBalloonOn: aCanvas in: sourceRect [
| cornerBounds rect1 rect2 |
cornerBounds := self class topLeftCornerForm boundingBox.
aCanvas translucentImage: self class topLeftCornerForm at: sourceRect topLeft;
		translucentImage: self class topRightCornerForm at: sourceRect topRight - (cornerBounds width @ 0);
		translucentImage: self class bottomLeftCornerForm at: sourceRect bottomLeft - (0 @ (cornerBounds height));
		translucentImage: self class bottomRightCornerForm at: sourceRect bottomRight - cornerBounds extent.

rect1 := sourceRect topLeft + (cornerBounds width @ 1) corner: sourceRect bottomRight - (cornerBounds width @ 1).
rect2 := sourceRect topLeft + (1 @ cornerBounds height) corner: sourceRect bottomRight - (1 @ cornerBounds height).
aCanvas fillRectangle: rect1 color: Color white; fillRectangle: rect2 color: Color white.
aCanvas line: rect1 topLeft to: rect1 topRight width: 2 color: Color black;
		line: rect1 bottomLeft to: rect1 bottomRight width: 2 color: Color black;
		line: rect2 topLeft to: rect2 bottomLeft width: 2 color: Color black;
		line: rect2 topRight to: rect2 bottomRight width: 2 color: Color black.

]

{ #category : #drawing }
SpeechBubbleMorph >> drawOn: aCanvas [
]

{ #category : #accessing }
SpeechBubbleMorph >> extent: aPoint [
| width height |
width := aPoint x max: self minimumAcceptedWidth.
height := aPoint y max: self minimumAcceptedHeight.
super extent: width @ height.
self refresh.
target notNil ifTrue: [self positionMyselfAccordingToTarget]
]

{ #category : #accessing }
SpeechBubbleMorph >> fillStyle: aFillStyle [
	super fillStyle: aFillStyle.
	self refresh
]

{ #category : #accessing }
SpeechBubbleMorph >> form [
^(msgMorph isKindOf: SketchMorph) ifTrue: [msgMorph form]
]

{ #category : #stepping }
SpeechBubbleMorph >> incrementStepTime [
	stepTime := (stepTime + 1) min: self maximumStepTime
]

{ #category : #'initialize-release' }
SpeechBubbleMorph >> initialize [
super initialize.
stepTime := self minimumStepTime.
self positionBalloon; positionTail; positionMsgMorph.
self addMorph: self balloon; addMorph: self tail; addMorph: self msgMorph.
self extent: self msgMorphExtent + (20 @ self tailHeight + 20); color: Color white.
]

{ #category : #'event handling' }
SpeechBubbleMorph >> keyStroke: anEvent morph: aMorph [ 
	| string |
	(self msgMorph isKindOf: UserText) ifFalse: [^self].

	string := self msgMorph contents.

	"Update text width if necessary. Make sure we keep the selection at the end of the text so that the user can keep modifying"
	self msgMorph width > 300
		ifTrue: [self msgMorph contents: string wrappedTo: 300.
			self msgMorph editor selectFrom: string size + 1 to: string size].

	"Update my extent"
	self extent: self msgMorphExtent + (20 @ self tailHeight + 20).

]

{ #category : #stepping }
SpeechBubbleMorph >> maximumStepTime [
	^500
]

{ #category : #accessing }
SpeechBubbleMorph >> minimumAcceptedHeight [
^100 max: self msgMorph fullBounds height + 20 + self tailHeight
]

{ #category : #accessing }
SpeechBubbleMorph >> minimumAcceptedWidth [
^ 175 max: self msgMorph fullBounds width + 20
]

{ #category : #stepping }
SpeechBubbleMorph >> minimumStepTime [
	^20
]

{ #category : #accessing }
SpeechBubbleMorph >> msgMorph [
^msgMorph isNil ifTrue: [nil] ifFalse: [msgMorph topRendererOrSelf]
]

{ #category : #accessing }
SpeechBubbleMorph >> msgMorphExtent [
^self msgMorph fullBounds extent
]

{ #category : #accessing }
SpeechBubbleMorph >> position: aPoint [
target notNil ifTrue: [^self positionMyselfAccordingToTarget ].
super position: aPoint.
]

{ #category : #'initialize-release' }
SpeechBubbleMorph >> positionBalloon [
self balloon position: self position
]

{ #category : #'initialize-release' }
SpeechBubbleMorph >> positionMsgMorph [
| diff |
diff := self msgMorph center - self msgMorph fullBounds center.
self msgMorph center: self center - (0 @ self tailHeight / 2) + diff.
]

{ #category : #stepping }
SpeechBubbleMorph >> positionMyselfAccordingToTarget [
	| newCenter newOwner |
	"Modify mi position"
	newCenter := target topRendererOrSelf center - (0 @ ((target topRendererOrSelf height + self height) / 2)).
	self privatePosition: newCenter - (self topRendererOrSelf extent // 2).
	"Don't forget to check if my owner is still the right one. Maybe the morph was inside a Playfield and the user grabed it and put it in the World"
	(newOwner := target ownerThatIsA: PasteUpMorph) ifNil: [^self].
	self owner ~= newOwner ifTrue: [newOwner addMorph: self topRendererOrSelf]
]

{ #category : #'initialize-release' }
SpeechBubbleMorph >> positionTail [
self tail position: self bottomCenter - (0 @ self tailHeight + 2)
]

{ #category : #private }
SpeechBubbleMorph >> privatePosition: aPoint [
"Always changes the position, regardless of the target"
self isFlexed ifTrue: [self topRendererOrSelf position: aPoint]
				ifFalse: [super position: aPoint]

]

{ #category : #refreshing }
SpeechBubbleMorph >> refresh [
self refreshBalloon; refreshTail; refreshMsgMorph
]

{ #category : #refreshing }
SpeechBubbleMorph >> refreshBalloon [
	balloon ifNotNil: [balloon delete].
	balloon := nil.
	self positionBalloon.
	self addMorph: balloon
]

{ #category : #refreshing }
SpeechBubbleMorph >> refreshMsgMorph [
	self msgMorph owner = self ifFalse: [^self delete].
	self positionMsgMorph.
	self addMorph: self msgMorph
]

{ #category : #refreshing }
SpeechBubbleMorph >> refreshTail [
	tail ifNotNil: [tail delete].
	tail := nil.
	self positionTail.
	self addMorph: tail
]

{ #category : #accessing }
SpeechBubbleMorph >> selectedTailForm [
	^type caseOf: {
		[#speech] -> [self class speakingForm].
		[#thought] -> [self class thinkingForm].
		} otherwise: [self error: 'Wrong type']
]

{ #category : #private }
SpeechBubbleMorph >> setMorph: aMorph type: aSymbol [
	msgMorph := aMorph.
	type := aSymbol
]

{ #category : #stepping }
SpeechBubbleMorph >> step [
(target isNil or: [lastHash = (lastHash := target boundsSignatureHash)])
		ifTrue: [self incrementStepTime]
		ifFalse: [stepTime := self minimumStepTime].

target notNil ifTrue: [
target isInWorld ifFalse: [^self delete].
self positionMyselfAccordingToTarget].

"This will keep the correct extent if the graphic changed"
self msgMorph notNil ifTrue: [
(self balloon fullBounds containsRect: self msgMorph fullBounds)
	ifFalse: [self extent: 1@1]]

]

{ #category : #stepping }
SpeechBubbleMorph >> stepTime [
^stepTime 
]

{ #category : #accessing }
SpeechBubbleMorph >> string [
^(msgMorph isKindOf: UserText) ifTrue: [msgMorph contents]
]

{ #category : #accessing }
SpeechBubbleMorph >> tail [
^tail ifNil: [
	| tailForm |
	tailForm := self selectedTailForm deepCopy.
	
	"This will paint both forms correctly"
	tailForm floodFill: self color at: tailForm center + (6@ -15).

	"In the #thought case, we also need to paint the little bubbles"
	type = #thought ifTrue: [
		tailForm floodFill: self color at: tailForm center + (-7@7);
				floodFill: self color at: tailForm center + (-22@20)
	].

	tail := SketchMorph withForm: tailForm]
]

{ #category : #accessing }
SpeechBubbleMorph >> tailHeight [
^self tail height
]

{ #category : #accessing }
SpeechBubbleMorph >> target [
	^target
]

{ #category : #accessing }
SpeechBubbleMorph >> target: aMorph [
	target isMorph ifTrue: [target bubble: nil].
	target := aMorph.
	target notNil ifTrue: [target bubble: self topRendererOrSelf. self positionMyselfAccordingToTarget ]
]

{ #category : #accessing }
SpeechBubbleMorph >> type [
^type
]
