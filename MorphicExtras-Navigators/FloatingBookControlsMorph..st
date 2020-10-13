Class {
	#name : #FloatingBookControlsMorph,
	#superclass : #AlignmentMorph,
	#category : #'MorphicExtras-Navigators'
}

{ #category : #initialization }
FloatingBookControlsMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 1
]

{ #category : #initialization }
FloatingBookControlsMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	self layoutInset: 0;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap 
]

{ #category : #'WiW support' }
FloatingBookControlsMorph >> morphicLayerNumber [

	"helpful for insuring some morphs always appear in front of or behind others.
	smaller numbers are in front"

	^23		"page controls are behind menus and balloons, but in front of most other stuff"
]

{ #category : #'stepping and presenter' }
FloatingBookControlsMorph >> step [

	owner == self world ifFalse: [^ self].
	owner addMorphInLayer: self.
	self position: (owner bottomCenter) - ((self width//2)@self height)

]

{ #category : #'stepping and presenter' }
FloatingBookControlsMorph >> stepTime [

	^1000
]

{ #category : #'stepping and presenter' }
FloatingBookControlsMorph >> wantsSteps [

	^true
]
