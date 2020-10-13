"
I associate a type with a range of characters in a String
I have these instance variables...
	start - the one based index of the first character of the range within the String.
	end - the one based index of the last character  of the range within the String.
	type - a Symbol describing the type of the range
	
A sequence of instances of me are created by an instance of SHParserST80 which can then used by an instance of  SHTextStyler to style Text. 
"
Class {
	#name : #SHRange,
	#superclass : #Object,
	#instVars : [
		'start',
		'end',
		'type'
	],
	#category : #'ShoutCore-Parsing'
}

{ #category : #'instance creation' }
SHRange class >> start: s end: e type: aSymbol [
	
	^self new
		start: s end: e type: aSymbol;
		yourself
]

{ #category : #comparing }
SHRange >> = anObject [

	anObject class == SHRange ifFalse: [ ^false ].
	type = anObject type ifFalse: [ ^false ].
	start = anObject start ifFalse: [ ^false ].
	end = anObject end ifFalse: [ ^false ].
	^true
]

{ #category : #accessing }
SHRange >> end [
	^end
]

{ #category : #accessing }
SHRange >> end: anInteger [
	end := anInteger
]

{ #category : #comparing }
SHRange >> hash [

	^(((self class hash + type hash) hashMultiply + start) hashMultiply + end) hashMultiply
]

{ #category : #accessing }
SHRange >> length [
	^end - start + 1
]

{ #category : #accessing }
SHRange >> printOn: stream [

	super printOn: stream.
	stream
		nextPut: $(;
		print: type;
		nextPutAll: ', ';
		print: start;
		nextPutAll: ', ';
		print: end;
		nextPut: $)
]

{ #category : #accessing }
SHRange >> start [
	^start
]

{ #category : #accessing }
SHRange >> start: anInteger [
	start := anInteger
]

{ #category : #accessing }
SHRange >> start: startInteger end: endInteger type: typeSymbol [
	start := startInteger.
	end := endInteger.
	type := typeSymbol
]

{ #category : #accessing }
SHRange >> type [
	^type
]

{ #category : #accessing }
SHRange >> type: aSymbol [
	type := aSymbol
]
