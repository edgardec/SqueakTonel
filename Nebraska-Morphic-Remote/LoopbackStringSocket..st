"
a string socket which is connected to another string sockt on the local computer.  Used mostly for testing.
"
Class {
	#name : #LoopbackStringSocket,
	#superclass : #Object,
	#instVars : [
		'associate',
		'inArrays',
		'outArrays'
	],
	#classVars : [
		'WRITESTRINGSIZES'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'as yet unclassified' }
LoopbackStringSocket class >> clearStats [

	WRITESTRINGSIZES := nil
]

{ #category : #'instance creation' }
LoopbackStringSocket class >> newPair [
	"create a connected pair of sockets"
	| a b |
	a := self new.
	b := self new.
	a associate: b.
	b associate: a.
	^{a. b}
]

{ #category : #'as yet unclassified' }
LoopbackStringSocket class >> stats [

	^WRITESTRINGSIZES
]

{ #category : #private }
LoopbackStringSocket >> arraysFromAssociate: arrays [
	"new string-arrays have arrived from our associate"

	inArrays ifNil: [^self].
	inArrays addAll: arrays.
]

{ #category : #initialization }
LoopbackStringSocket >> associate: aLoopbackStringSocket [
	associate := aLoopbackStringSocket.
	inArrays := OrderedCollection new.
	outArrays := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
LoopbackStringSocket >> destroy [

	associate := inArrays := outArrays := nil.
]

{ #category : #'I\/O' }
LoopbackStringSocket >> flush [
]

{ #category : #'I\/O' }
LoopbackStringSocket >> isConnected [
	^true
]

{ #category : #'I\/O' }
LoopbackStringSocket >> nextOrNil [

	inArrays ifNil: [^nil].

	inArrays isEmpty 
		ifTrue: [ ^nil ]
		ifFalse: [
			^inArrays removeFirst. ]	
]

{ #category : #'I\/O' }
LoopbackStringSocket >> nextPut: aStringArray [

	inArrays ifNil: [^aStringArray].

	^outArrays add: aStringArray.
	"WRITESTRINGSIZES ifNil: [WRITESTRINGSIZES := Bag new].
	aStringArray do: [ :each | WRITESTRINGSIZES add: each size]."
]

{ #category : #'I\/O' }
LoopbackStringSocket >> processIO [

	inArrays ifNil: [^self].

	associate arraysFromAssociate: outArrays.
	outArrays := OrderedCollection new.
]
