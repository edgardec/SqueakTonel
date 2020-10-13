"
Act as a field in a HyperCard-like setting.  Has both properties of a Rectangle, and exposes some proteries of the TextMorph it owns.


"
Class {
	#name : #TextFieldMorph,
	#superclass : #RectangleMorph,
	#category : #'Morphic-Text Support'
}

{ #category : #scripting }
TextFieldMorph class >> authoringPrototype [ 
	"Answer an instance of the receiver that can serve as a prototype for authoring"

	| proto |
	proto := super authoringPrototype.
	proto setProperty: #shared toValue: true.
	proto extent: 170 @ 30.
	proto color: Color veryLightGray lighter.
	proto contents: 'on a clear day you can...'.
	^ proto

]

{ #category : #'class initialization' }
TextFieldMorph class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'class initialization' }
TextFieldMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#TextFieldMorph. #exampleBackgroundField. 'Scrolling Field' translatedNoop. 'A scrolling data field which will have a different value on every card of the background' translatedNoop}
						forFlapNamed: 'Scripting'.]
]

{ #category : #'class initialization' }
TextFieldMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #'just like textMorph' }
TextFieldMorph >> append: stringOrText [
	"add to my text"
	| tm |

	(tm := self findA: TextMorph) ifNil: [^ nil].
	tm contents append: stringOrText.
	tm releaseParagraph; paragraph.


	
]

{ #category : #'just like textMorph' }
TextFieldMorph >> contents [
	| tm |
	"talk to my text"

	(tm := self findA: TextMorph) ifNil: [^ nil].
	^ tm contents
]

{ #category : #'just like textMorph' }
TextFieldMorph >> contents: textOrString [
	"talk to my text"
	| tm newText atts |

	(tm := self findA: TextMorph) ifNil: [^ nil].
	textOrString isString ifTrue: [
		tm contents ifNotNil: ["Keep previous properties of the field"
			newText := textOrString asText.
			atts := tm contents attributesAt: 1.
			atts do: [:each | newText addAttribute: each].
			^ tm contents: newText]].

	^ tm contents: textOrString
]

{ #category : #initialization }
TextFieldMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color veryLightGray lighter
]

{ #category : #'just like textMorph' }
TextFieldMorph >> fit [
	"tell my text to recompute its looks"
	| tm |

	(tm := self findA: TextMorph) ifNil: [^ nil].
	tm releaseParagraph; paragraph.
]

{ #category : #'just like textMorph' }
TextFieldMorph >> fontName: fontName size: fontSize [
	| tm |
	"talk to my text"

	(tm := self findA: TextMorph) ifNil: [^ nil].
	^ tm fontName: fontName size: fontSize

]

{ #category : #initialization }
TextFieldMorph >> initialize [
	"initialize the state of the receiver"
	| tm |
	super initialize.
	""
	
	self addMorph: (tm := TextMorph new).
	tm fillingOnOff
]

{ #category : #'just like textMorph' }
TextFieldMorph >> lineCount [
	| tm |
	"how many lines in my text"

	(tm := self findA: TextMorph) ifNil: [^ nil].
	^ tm contents string lineCount
]

{ #category : #'just like textMorph' }
TextFieldMorph >> prepend: stringOrText [
	"add to my text"
	| tm |

	(tm := self findA: TextMorph) ifNil: [^ nil].
	tm contents prepend: stringOrText.
	tm releaseParagraph; paragraph.


	
]
