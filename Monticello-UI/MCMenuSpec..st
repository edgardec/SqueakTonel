"
A MCMenuSpec holds information to add menu entries to the monticello browser menus from external classes.
Required is the entry string (#entry), the call target and the selector be called.
An external class may use the MCWorkingCopyBrowser class>>addMenuSpec: method to add it's own menu entry to the monticello browser context menu.

Note that MCMenuSpecs are compared via their menu entry string and if multiple MCMenuSpecs are added to the MCWorkingCopyBrowser, the last one takes precedence.
"
Class {
	#name : #MCMenuSpec,
	#superclass : #Object,
	#instVars : [
		'entry',
		'target',
		'selector'
	],
	#category : #'Monticello-UI'
}

{ #category : #comparing }
MCMenuSpec >> = aMCMenuSpec [

	^ self class == aMCMenuSpec class and: [self entry = aMCMenuSpec entry].
]

{ #category : #accessing }
MCMenuSpec >> entry [

	^entry
]

{ #category : #accessing }
MCMenuSpec >> entry: anObject [

	entry := anObject
]

{ #category : #comparing }
MCMenuSpec >> hash [

	^ self entry hash
]

{ #category : #accessing }
MCMenuSpec >> selector [

	^selector
]

{ #category : #accessing }
MCMenuSpec >> selector: anObject [

	selector := anObject
]

{ #category : #accessing }
MCMenuSpec >> target [

	^target
]

{ #category : #accessing }
MCMenuSpec >> target: anObject [

	target := anObject
]
