Class {
	#name : #SystemWindowButton,
	#superclass : #IconicButton,
	#instVars : [
		'dimmed',
		'dimmedForm',
		'highlightedForm'
	],
	#category : #'Morphic-Windows'
}

{ #category : #'visual properties' }
SystemWindowButton >> dim [
	dimmed := true.
	self restoreImage.
]

{ #category : #'visual properties' }
SystemWindowButton >> dimmedForm [
	^ dimmedForm ifNil: [ dimmedForm := self firstSubmorph baseGraphic dimmed ]
]

{ #category : #'visual properties' }
SystemWindowButton >> handlesMouseOver: evt [

	^ true

]

{ #category : #'visual properties' }
SystemWindowButton >> highlight [

	self firstSubmorph form: self highlightedForm

]

{ #category : #'visual properties' }
SystemWindowButton >> highlightedForm [
	^ highlightedForm ifNil: [ highlightedForm := self firstSubmorph baseGraphic lighter ]
]

{ #category : #accessing }
SystemWindowButton >> lock [
	self firstSubmorph form: self dimmedForm.
	super lock
]

{ #category : #'visual properties' }
SystemWindowButton >> mouseEnter: evt [

	self highlight.

]

{ #category : #'visual properties' }
SystemWindowButton >> mouseLeave: evt [

	self restoreImage.

]

{ #category : #'visual properties' }
SystemWindowButton >> restoreImage [
	dimmed == true
		ifTrue: [self firstSubmorph form: self dimmedForm]
		ifFalse: [super restoreImage]

]

{ #category : #'visual properties' }
SystemWindowButton >> undim [
	dimmed := false..
	self isLocked ifFalse: [self restoreImage].
]

{ #category : #accessing }
SystemWindowButton >> unlock [
	self restoreImage.
	super unlock
]

{ #category : #'visual properties' }
SystemWindowButton >> updateVisualState: evt [

	(self containsPoint: evt cursorPoint)
		ifTrue: [self darken]
		ifFalse: [self restoreImage].

]
