"
Deprecated: please don't use this class any more. It is part of the deprecated StandardFileMenu system.

A StandardFileMenuResult is xxxxxxxxx.

Instance Variables
	directory:		<Object>
	name:		<Object>

directory
	- xxxxx

name
	- xxxxx

"
Class {
	#name : #StandardFileMenuResult,
	#superclass : #Object,
	#instVars : [
		'directory',
		'name'
	],
	#category : #'60Deprecated-Tools-Menus'
}

{ #category : #'instance creation' }
StandardFileMenuResult class >> directory: aDirectory name: aString [

	^super new directory: aDirectory name: aString
]

{ #category : #accessing }
StandardFileMenuResult >> directory [

	^directory
]

{ #category : #accessing }
StandardFileMenuResult >> directory: aDirectory [

	^directory := aDirectory
]

{ #category : #private }
StandardFileMenuResult >> directory: aDirectory name: aString [

	directory := aDirectory.
	name := aString.
	^self
]

{ #category : #testing }
StandardFileMenuResult >> isCommand [

	^name isNil
]

{ #category : #testing }
StandardFileMenuResult >> isDirectory [

	^name = ''
]

{ #category : #accessing }
StandardFileMenuResult >> name [

	^name
]

{ #category : #accessing }
StandardFileMenuResult >> name: aString [

	^name := aString
]

{ #category : #accessing }
StandardFileMenuResult >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' with directory: '.
	directory printOn: aStream.
	aStream nextPutAll: ' name: '.
	name printOn: aStream

"StandardFileMenu oldFile"
]
