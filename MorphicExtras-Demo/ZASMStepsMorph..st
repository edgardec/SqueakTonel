Class {
	#name : #ZASMStepsMorph,
	#superclass : #StringMorph,
	#category : #'MorphicExtras-Demo'
}

{ #category : #accessing }
ZASMStepsMorph >> getStepCount [

	^[self contents asNumber] ifError: [ :a :b | 10]
	

]

{ #category : #'event handling' }
ZASMStepsMorph >> handlesMouseDown: evt [

	^ true
]

{ #category : #'event handling' }
ZASMStepsMorph >> mouseDown: evt [
	"If the shift key is pressed, make this string the keyboard input focus."

	self launchMiniEditor: evt

]

{ #category : #accessing }
ZASMStepsMorph >> setStepCount: n [

	self contents: n printString.


]
