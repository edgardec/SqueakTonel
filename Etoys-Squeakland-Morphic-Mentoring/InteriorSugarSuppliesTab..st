"
DISUSED...  Superseded by InteriorSolidSugarSuppliesTab.  Retained for a while for backward compatability, in consideration of existing content.

A flap-tab for the the *fake* fake Sugar supplies flap at the top of an event-recording theatre or event-playback theatre.

Because this object cannot inherit both from InteriorFlapTab and from SugarSuppliesTab, it inherits only from the former, with  code copied over from the latter as needed.
"
Class {
	#name : #InteriorSugarSuppliesTab,
	#superclass : #InteriorFlapTab,
	#instVars : [
		'sugarNavBar'
	],
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #initialization }
InteriorSugarSuppliesTab >> arrangeToPopOutOnDragOver: aBoolean [
	"See to it that I do or don't pop out on drag-over, as per the boolean.  Copied over directly from the SugarSuppliesTab method of the same name."

	aBoolean
		ifTrue:
			[
			referent on: #mouseLeaveDragging send: #maybeHideFlapOnMouseLeaveDragging to: self.
			self on: #mouseLeaveDragging send: #maybeHideFlapOnMouseLeaveDragging to: self]
		ifFalse:
			[self on: #mouseEnterDragging send: nil to: nil.
			referent on: #mouseLeaveDragging send: nil to: nil.
			self on: #mouseLeaveDragging send: nil to: nil]
]

{ #category : #initialization }
InteriorSugarSuppliesTab >> naviHeight: anInteger [
	"Accept the argument as the height of the navigator.  Copied over from SugarSuppliesTab method of the same name."

	submorphs ifEmpty: [^ self].
	submorphs first extent: anInteger@anInteger.

]

{ #category : #positioning }
InteriorSugarSuppliesTab >> positionObject: anObject atEdgeOf: container [
	"Position the object supplied at the edge of the container supplied."

	| extra |
	extra := (sugarNavBar notNil and: [referent isInWorld]) ifTrue: [sugarNavBar height] ifFalse: [0].
	edgeToAdhereTo == #top ifTrue:
		[^ anObject top: container innerBounds top + extra].
	edgeToAdhereTo == #bottom ifTrue: 
		[^ anObject bottom: container innerBounds bottom - extra]

]

{ #category : #initialization }
InteriorSugarSuppliesTab >> sugarNavBar: aBar icon: aForm [
	"Associate the receiver with the given sugar-nav-bar."

	sugarNavBar :=  aBar.
	aForm ifNotNil:
		[self useTextualTab.
		self setProperty: #priorGraphic toValue: aForm.
		self useGraphicalTab].

]

{ #category : #positioning }
InteriorSugarSuppliesTab >> wantsToBeTopmost [
	"If my flap is showing, then force me to be topmost."

	^ self flapShowing

]
