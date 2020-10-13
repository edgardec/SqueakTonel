Class {
	#name : #MCReader,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Monticello-Storing'
}

{ #category : #testing }
MCReader class >> canReadFileNamed: fileName [
	^ (fileName endsWith: '.', self extension)
]

{ #category : #testing }
MCReader class >> concreteSubclassesDo: aBlock [

	self allSubclassesDo: [ :each |
		each isAbstract ifFalse: [ aBlock value: each ] ]
]

{ #category : #testing }
MCReader class >> isAbstract [
	^ (self respondsTo: #extension) not
]

{ #category : #'instance creation' }
MCReader class >> new [
	^ self basicNew initialize
]

{ #category : #'instance creation' }
MCReader class >> on: aStream [
	^ self new stream: aStream
]

{ #category : #'instance creation' }
MCReader class >> on: aStream name: aFileName [
	| class |
	class := self readerClassForFileNamed: aFileName.
	^ class
		ifNil: [self error: 'Unsupported format: ', aFileName]
		ifNotNil: [class on: aStream]
]

{ #category : #testing }
MCReader class >> readerClassForFileNamed: fileName [
	
	self concreteSubclassesDo: [ :each |
		(each canReadFileNamed: fileName) ifTrue: [ ^each ] ].
	^nil
]

{ #category : #accessing }
MCReader >> stream: aStream [
	stream := aStream
]
