"
A representation of a TrueType point which includes a 'type' flag defining whether this point is an 'on' or an 'off' curve point.
"
Class {
	#name : #TTPoint,
	#superclass : #Object,
	#instVars : [
		'x',
		'y',
		'type'
	],
	#category : #'TrueType-Support'
}

{ #category : #converting }
TTPoint >> asPoint [
	^x@y
]

{ #category : #printing }
TTPoint >> printOn: aStream [

	aStream 
		nextPutAll: self class name;
		nextPut:$(;
		print: x;
		nextPut:$@;
		print: y;
		nextPut:$|;
		print: type;
		nextPut:$)
]

{ #category : #accessing }
TTPoint >> type [
	^type
]

{ #category : #accessing }
TTPoint >> type: aSymbol [

	type := aSymbol
]

{ #category : #accessing }
TTPoint >> x [
	^x
]

{ #category : #accessing }
TTPoint >> x: aNumber [

	x := aNumber
]

{ #category : #accessing }
TTPoint >> y [
	^y
]

{ #category : #accessing }
TTPoint >> y: aNumber [
	y := aNumber
]
