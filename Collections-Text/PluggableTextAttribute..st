"
An attribute which evaluates an arbitrary block when it is selected.
"
Class {
	#name : #PluggableTextAttribute,
	#superclass : #TextAction,
	#instVars : [
		'evalBlock'
	],
	#category : #'Collections-Text'
}

{ #category : #'instance creation' }
PluggableTextAttribute class >> evalBlock: aBlock [
	^super new evalBlock: aBlock
]

{ #category : #'event handling' }
PluggableTextAttribute >> actOnClickFor: anObject [
	evalBlock ifNil: [ ^self ].
	evalBlock numArgs = 0 ifTrue: [ evalBlock value.  ^true ].
	evalBlock numArgs = 1 ifTrue: [ evalBlock value: anObject.  ^true ].
	self error: 'evalBlock should have 0 or 1 arguments'
]

{ #category : #initialization }
PluggableTextAttribute >> evalBlock: aBlock [
	evalBlock := aBlock
]

{ #category : #'fileIn\/fileOut' }
PluggableTextAttribute >> writeScanOn: aStream [
	"Impossible for this kind of attribute"
	^ self shouldNotImplement
	
]
