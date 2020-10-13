"
A customized updating-string-morph used for displaying and editing boolean values; mouse-down on one of these is inerpreted as a request to toggle.
"
Class {
	#name : #UpdatingBooleanStringMorph,
	#superclass : #UpdatingStringMorph,
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #'event handling' }
UpdatingBooleanStringMorph >> handlesMouseDown: evt [
	^ true
]

{ #category : #'target access' }
UpdatingBooleanStringMorph >> informTarget [
	"Determine a value by evaluating my readout, and send that value to my target"

	| newValue |
	(target notNil and: [putSelector notNil]) 
		ifTrue: 
			[newValue := self valueFromContents.
			newValue ifNotNil: 
					[target 
						perform: putSelector
						with: getSelector
						with: newValue.
					target isMorph ifTrue: [target changed]].
			self growable 
				ifTrue: 
					[self
						readFromTarget;
						fitContents.
					owner updateLiteralLabel]]
]

{ #category : #'event handling' }
UpdatingBooleanStringMorph >> mouseDown: evt [
	self color: Color red
]

{ #category : #'event handling' }
UpdatingBooleanStringMorph >> mouseUp: evt [
	(bounds containsPoint: evt cursorPoint)
		ifTrue:
			[self contentsClipped: (target perform: getSelector) not asString.
			self informTarget]
		ifFalse:
			[Beeper beep].
	self color: Color black
]
