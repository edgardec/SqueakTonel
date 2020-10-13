Class {
	#name : #SugarSuppliesTab,
	#superclass : #FlapTab,
	#instVars : [
		'sugarNavTab'
	],
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #all }
SugarSuppliesTab >> arrangeToPopOutOnDragOver: aBoolean [
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

{ #category : #all }
SugarSuppliesTab >> naviHeight: anInteger [

	submorphs ifEmpty: [^ self].
	submorphs first extent: anInteger@anInteger.

]

{ #category : #all }
SugarSuppliesTab >> positionObject: anObject atEdgeOf: container [

	| extra |
	extra := (sugarNavTab notNil and: [referent isInWorld]) ifTrue: [sugarNavTab height] ifFalse: [0].
	edgeToAdhereTo == #top ifTrue: [
		^ anObject top: container innerBounds top + extra
	].
	edgeToAdhereTo == #bottom ifTrue: [
		^ anObject bottom: container innerBounds bottom - extra
	].

]

{ #category : #all }
SugarSuppliesTab >> sugarNavTab: anObject icon: aForm [

	sugarNavTab := anObject.
	aForm ifNotNil: [
		self useTextualTab.
		self setProperty: #priorGraphic toValue: aForm.
		self useGraphicalTab.
	].

]

{ #category : #all }
SugarSuppliesTab >> wantsToBeTopmost [

	^ self flapShowing

]
