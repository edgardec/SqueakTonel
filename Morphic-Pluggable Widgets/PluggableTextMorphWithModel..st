Class {
	#name : #PluggableTextMorphWithModel,
	#superclass : #PluggableTextMorph,
	#instVars : [
		'myContents'
	],
	#category : #'Morphic-Pluggable Widgets'
}

{ #category : #scripting }
PluggableTextMorphWithModel class >> authoringPrototype [
	"Answer an instance of the receiver suitable for placing in a parts bin"

	| proto |
	proto := super authoringPrototype.
	proto color: (Color r: 0.972 g: 0.972 b: 0.662).
	^ proto
]

{ #category : #'submorphs-add\/remove' }
PluggableTextMorphWithModel >> delete [
	"Delete the receiver.  Since I have myself as a dependent, I need to remove it. which is odd in itself.  Also, the release of dependents will seemingly not be done if the *container* of the receiver is deleted rather than the receiver itself, a further problem"

	self removeDependent: self.
	super delete
]

{ #category : #contents }
PluggableTextMorphWithModel >> getMyText [
	^myContents
]

{ #category : #initialization }
PluggableTextMorphWithModel >> initialize [
	"initialize the state of the receiver"
	super initialize.
	self
		on: self
		text: #getMyText
		accept: #setMyText:
		readSelection: nil
		menu: nil
]

{ #category : #contents }
PluggableTextMorphWithModel >> newTextContents: stringOrText [
	"Accept new text contents."

	| newText myText |
	"Just underway; trying to make this work like TextMorph does, but not quite there yet."

	newText := stringOrText asText.
	(myText := textMorph text) = newText ifTrue: [^ self].  "No substantive change"
	
	self world ifNotNil:
		[self world startSteppingSubmorphsOf: self ].

]

{ #category : #contents }
PluggableTextMorphWithModel >> setMyText: someText [
	myContents := someText.
	^true.
]
