"
EToyMorphsWelcomeMorph new openInWorld
"
Class {
	#name : #NebraskaMorphsWelcomeMorph,
	#superclass : #NebraskaCommunicatorMorph,
	#category : #'Nebraska-Morphs'
}

{ #category : #'parts bin' }
NebraskaMorphsWelcomeMorph class >> descriptionForPartsBin [

	^ self partName: 	'Welcome' translatedNoop
		categories:		#()
		documentation:	'A sign that you accept morphs dropped directly into your world' translatedNoop
]

{ #category : #'as yet unclassified' }
NebraskaMorphsWelcomeMorph class >> morphsWelcomeInWorld: aWorld [

	^self allInstances anySatisfy: [ :each | each world == aWorld]
]

{ #category : #initialization }
NebraskaMorphsWelcomeMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color yellow
]

{ #category : #initialization }
NebraskaMorphsWelcomeMorph >> initialize [
	"initialize the state of the receiver"
	| earMorph |
	super initialize.
	""
	
	self layoutInset: 8 @ 8.
	"earMorph := (EToyListenerMorph makeListeningToggle: true)  
	asMorph."
	earMorph := TextMorph new contents: 'Morphs
welcome
here';
				 fontName: Preferences standardEToysFont familyName size: 18;
				 centered;
				 lock.
	self addARow: {earMorph}.
	self setBalloonText: 'My presence in this world means received morphs may appear automatically' translated
]
