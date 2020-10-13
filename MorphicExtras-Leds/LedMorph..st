"
I am a collection of LED digits that can display a decimal value.  The display can be set to flash by sending flash: true.

LedMorph can now display characters:

LedMorph new  string:'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'; openInWorld

Lowercase letters will be converted to Uppercase. Carachters not in the examle
above will be shown as SPACE which is char 36 in LedCharacterMorph.

LedMorph new  chars: 10; string:'           I must get a life';flash:true;scrollLoop:true; openInWorld

The number of letters is set by chars. 
If chars is not specified it will be set to the string size. 
When the string size is bigger than chars
the string will scroll across the led. WOW!
scrollLoop let's you set the scrolling to start over once its finished.

Enjoy.


"
Class {
	#name : #LedMorph,
	#superclass : #Morph,
	#instVars : [
		'digits',
		'chars',
		'value',
		'flashing',
		'flash',
		'string',
		'scroller',
		'scrollLoop'
	],
	#category : #'MorphicExtras-Leds'
}

{ #category : #'new-morph participation' }
LedMorph class >> includeInNewMorphMenu [

	^false
]

{ #category : #accessing }
LedMorph >> chars [

	 ^ chars
]

{ #category : #accessing }
LedMorph >> chars: aNumber [ 
	chars := aNumber.
	self removeAllMorphs.
	1 to: chars do: [:i | self addMorph: (LedCharacterMorph new color: color)].
	self layoutChanged.
	self changed
]

{ #category : #accessing }
LedMorph >> color: aColor [ 
	"set the receiver's color and the submorphs color"
	super color: aColor.
	self
		submorphsDo: [:m | m color: aColor]
]

{ #category : #initialization }
LedMorph >> defaultColor [
"answer the default color/fill style for the receiver"
	^ Color green
]

{ #category : #accessing }
LedMorph >> digits [

	^ digits
]

{ #category : #accessing }
LedMorph >> digits: aNumber [

	digits := aNumber.
	self removeAllMorphs.
	1 to: digits do: [:i | self addMorph: (LedDigitMorph new color: color)].
	self layoutChanged.
	self changed.
]

{ #category : #drawing }
LedMorph >> drawOn: aCanvas [

	aCanvas fillRectangle: self bounds color: color darker darker.

]

{ #category : #macpal }
LedMorph >> flash [

	^ flash
]

{ #category : #accessing }
LedMorph >> flash: aBoolean [

	flash := aBoolean.
]

{ #category : #accessing }
LedMorph >> highlighted: aBoolean [

	self submorphsDo: [:m | m highlighted: aBoolean]
]

{ #category : #initialization }
LedMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	flashing := false.
	flash := false.
	self scrollInit.
	self digits: 2.
	self value: 0
]

{ #category : #layout }
LedMorph >> layoutChanged [

	super layoutChanged.
	submorphs withIndexDo:
		[:m :i |
		m
			position: self position + (((i-1) * self width / digits) rounded @ 0);
			extent: (self width / digits) rounded @ self height]
]

{ #category : #initialization }
LedMorph >> scrollInit [

	chars := 0.
	scroller := 1.
	string := ''.
	scrollLoop := false.

]

{ #category : #accessing }
LedMorph >> scrollLoop [	

	^ scrollLoop
]

{ #category : #accessing }
LedMorph >> scrollLoop: aBoolean [

	scrollLoop := aBoolean.
]

{ #category : #'stepping and presenter' }
LedMorph >> step [
	(flash or: [flashing])
		ifTrue: 
			[flashing := flashing not.
			self highlighted: flashing].
	scroller ifNil: [scroller := 1].
	chars ifNil: [^ self].
	scroller + chars < (string size + 1)
		ifTrue: 
			[scroller := scroller + 1.
			self stringToLed]
		ifFalse: [scrollLoop ifTrue: [scroller := 1]]
]

{ #category : #'stepping and presenter' }
LedMorph >> stepTime [

	^ 500
]

{ #category : #accessing }
LedMorph >> string [

	^ string
]

{ #category : #accessing }
LedMorph >> string: aString [ 
	string := aString.
	chars = 0
		ifTrue: 
			[chars := string size.
			self chars: chars].
	self stringToLed
]

{ #category : #accessing }
LedMorph >> stringToLed [
	| i k actualString |
	i := scroller ifNil: [1].
	k := 1.
	actualString := String new: chars.
	actualString do: 
		[:m | 
		i > string size ifFalse: [actualString at: k put: (string at: i) asUppercase asCharacter].
		i := i + 1.
		k := k + 1].
	i := 1.
	submorphs do: 
		[:m | 
		m char: (actualString at: i).
		i := i + 1].
	self changed
]

{ #category : #accessing }
LedMorph >> value [

	^ value
]

{ #category : #accessing }
LedMorph >> value: aNumber [

	| val |
	value := aNumber.
	val := value.
	submorphs reverseDo:
		[:m |
		m digit: val \\ 10.
		val := val // 10].
	self changed.
]
