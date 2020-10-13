"
I am a font for special purpose like password or fallback.
I can show same form whenever someone requests any character.

Variable displaySelector is future use to show a form dynamically.
(Although it would be unnecessary...)
"
Class {
	#name : #FixedFaceFont,
	#superclass : #AbstractFont,
	#instVars : [
		'baseFont',
		'substitutionCharacter',
		'displaySelector'
	],
	#category : #'Graphics-Fonts'
}

{ #category : #accessing }
FixedFaceFont >> ascent [
	^baseFont ascent
]

{ #category : #accessing }
FixedFaceFont >> ascentOf: aCharacter [
	^ self ascent
]

{ #category : #accessing }
FixedFaceFont >> baseFont [
	^baseFont
]

{ #category : #accessing }
FixedFaceFont >> baseFont: aFont [
	baseFont := aFont
]

{ #category : #accessing }
FixedFaceFont >> baseKern [
	^baseFont baseKern
]

{ #category : #private }
FixedFaceFont >> basicHasGlyphOf: aCharacter [

	" We present the same for any character, so, yes"
	^ true
]

{ #category : #accessing }
FixedFaceFont >> characterFormAt: character [ 
	^ baseFont characterFormAt: substitutionCharacter
]

{ #category : #accessing }
FixedFaceFont >> depth [

	^ self baseFont depth
]

{ #category : #accessing }
FixedFaceFont >> descent [
	^baseFont descent
]

{ #category : #accessing }
FixedFaceFont >> descentKern [
	^baseFont descentKern
]

{ #category : #accessing }
FixedFaceFont >> descentOf: aCharacter [
	^ self descent
]

{ #category : #displaying }
FixedFaceFont >> displayErrorOn: aCanvas length: length at: aPoint kern: kernDelta [ 
	| maskedString |
	maskedString := String new: length.
	maskedString atAllPut: substitutionCharacter.
	^ baseFont
		displayString: maskedString
		on: aCanvas
		from: 1
		to: length
		at: aPoint
		kern: kernDelta
]

{ #category : #displaying }
FixedFaceFont >> displayErrorOn: aCanvas length: length at: aPoint kern: kernDelta baselineY: baselineY [
	| maskedString |
	maskedString := String new: length.
	maskedString atAllPut: substitutionCharacter.
	^ baseFont
		displayString: maskedString
		on: aCanvas
		from: 1
		to: length
		at: aPoint
		kern: kernDelta
		baselineY: baselineY
]

{ #category : #displaying }
FixedFaceFont >> displayPasswordOn: aCanvas length: length at: aPoint kern: kernDelta [ 
	| maskedString |
	maskedString := String new: length.
	maskedString atAllPut: substitutionCharacter.
	^ baseFont
		displayString: maskedString
		on: aCanvas
		from: 1
		to: length
		at: aPoint
		kern: kernDelta
]

{ #category : #displaying }
FixedFaceFont >> displayPasswordOn: aCanvas length: length at: aPoint kern: kernDelta baselineY: baselineY [
	| maskedString |
	maskedString := String new: length.
	maskedString atAllPut: substitutionCharacter.
	^ baseFont
		displayString: maskedString
		on: aCanvas
		from: 1
		to: length
		at: aPoint
		kern: kernDelta
		baselineY: baselineY
]

{ #category : #displaying }
FixedFaceFont >> displayString: aString on: aDisplayContext from: startIndex to: stopIndex at: aPoint kern: kernDelta [ 
	| size |
	size := stopIndex - startIndex + 1.
	^ self perform: displaySelector withArguments: (Array with: aDisplayContext with: size with: aPoint with: kernDelta with: aPoint y + self ascent).
]

{ #category : #displaying }
FixedFaceFont >> displayString: aString on: aDisplayContext from: startIndex to: stopIndex at: aPoint kern: kernDelta baselineY: baselineY [
	| size |
	size := stopIndex - startIndex + 1.
	^ self perform: displaySelector withArguments: (Array with: aDisplayContext with: size with: aPoint with: kernDelta with: baselineY).
]

{ #category : #displaying }
FixedFaceFont >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta from: fromFont [ 
	| destPoint |
	destPoint := self
				displayString: aString
				on: aBitBlt
				from: startIndex
				to: stopIndex
				at: aPoint
				kern: kernDelta.
	^ Array with: stopIndex + 1 with: destPoint
]

{ #category : #displaying }
FixedFaceFont >> displayString: aString on: aBitBlt from: startIndex to: stopIndex at: aPoint kern: kernDelta from: fromFont baselineY: baselineY [
	| destPoint |
	destPoint := self
				displayString: aString
				on: aBitBlt
				from: startIndex
				to: stopIndex
				at: aPoint
				kern: kernDelta
				baselineY: baselineY.
	^destPoint
]

{ #category : #accessing }
FixedFaceFont >> emphasized: emph [
	^self class new baseFont: (baseFont emphasized: emph)
]

{ #category : #'initialize-release' }
FixedFaceFont >> errorFont [
	displaySelector := #displayErrorOn:length:at:kern:baselineY:.
	substitutionCharacter := $?.
]

{ #category : #accessing }
FixedFaceFont >> familyName [
	^baseFont familyName, '-pw'
]

{ #category : #accessing }
FixedFaceFont >> fontSize: aNumber [ 
	self baseFont: (StrikeFont familyName: baseFont familyName size: aNumber) copy
]

{ #category : #private }
FixedFaceFont >> glyphInfoOf: aCharacter into: glyphInfoArray [
"since we replace every character with substitutionCharacter, get my baseFont's glyphInfo for that"
	^ baseFont glyphInfoOf: substitutionCharacter into: glyphInfoArray.

]

{ #category : #accessing }
FixedFaceFont >> height [
	^baseFont height
]

{ #category : #'initialize-release' }
FixedFaceFont >> initialize [
	"This used to be the default textstyle, but it needs to be a StrikeFont and not a TTCFont and sometimes the default textstyle is a TTCFont.  So, we use a typical StrikeFont as the default fallback font."
	baseFont := StrikeFont defaultSized: 12.
	self passwordFont
]

{ #category : #displaying }
FixedFaceFont >> installOn: aDisplayContext foregroundColor: foregroundColor backgroundColor: backgroundColor [
	^baseFont installOn: aDisplayContext foregroundColor: foregroundColor backgroundColor: backgroundColor
]

{ #category : #accessing }
FixedFaceFont >> lineGrid [
	^baseFont lineGrid
]

{ #category : #accessing }
FixedFaceFont >> maxAscii [
	^ SmallInteger maxVal
]

{ #category : #accessing }
FixedFaceFont >> passwordCharacter [
	^$*
]

{ #category : #'initialize-release' }
FixedFaceFont >> passwordFont [
	displaySelector := #displayPasswordOn:length:at:kern:baselineY:.
	substitutionCharacter := $*
]

{ #category : #accessing }
FixedFaceFont >> pointSize [
	^baseFont pointSize
]

{ #category : #caching }
FixedFaceFont >> releaseCachedState [
	baseFont releaseCachedState.
]

{ #category : #measuring }
FixedFaceFont >> widthOf: aCharacter [
	^ (baseFont hasGlyphOf: substitutionCharacter)
		ifTrue: [baseFont widthOf: substitutionCharacter]
		ifFalse: [1]
]
