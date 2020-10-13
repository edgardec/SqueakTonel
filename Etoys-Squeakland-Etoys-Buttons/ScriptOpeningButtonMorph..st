Class {
	#name : #ScriptOpeningButtonMorph,
	#superclass : #SimpleButtonMorph,
	#instVars : [
		'affiliatedScriptor'
	],
	#category : #'Etoys-Squeakland-Etoys-Buttons'
}

{ #category : #accessing }
ScriptOpeningButtonMorph >> affiliatedScriptor [
	"Answer the affiliatedScriptor"

	^ affiliatedScriptor
]

{ #category : #accessing }
ScriptOpeningButtonMorph >> affiliatedScriptor: aScriptor [
	"Set the value of affiliatedScriptor."

	affiliatedScriptor := aScriptor
]

{ #category : #'as yet unclassified' }
ScriptOpeningButtonMorph >> bringUpToDate [
	"The object's name, or the script name, or both, may have changed.  Make sure I continue to look and act right"

	(self hasProperty: #labelManuallyEdited) ifFalse:
		[self label: self standardLabelForButton].
	self setBalloonText: ('show or hide the script named {1} in the object named {2} ' translated format: {affiliatedScriptor scriptName.  affiliatedScriptor playerScripted externalName}).
]

{ #category : #accessing }
ScriptOpeningButtonMorph >> isTileScriptingElement [
	"Answer whether the receiver is a tile-scripting element."

	^ true
]

{ #category : #accessing }
ScriptOpeningButtonMorph >> labelString: aString [
	"Set the labelString"

	super labelString: aString.
	self setProperty: #labelManuallyEdited toValue: true
]

{ #category : #accessing }
ScriptOpeningButtonMorph >> setLabelStringInitially: aString [
	"Set the labelString initially"

	self labelString: aString.
	self removeProperty: #labelManuallyEdited
]

{ #category : #'as yet unclassified' }
ScriptOpeningButtonMorph >> standardLabelForButton [
	"Answer a string to serve as a prospective label for the receiver."

	^  affiliatedScriptor playerScripted externalName , ' ', affiliatedScriptor scriptName
]
