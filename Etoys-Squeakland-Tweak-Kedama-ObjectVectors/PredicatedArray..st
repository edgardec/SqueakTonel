Class {
	#name : #PredicatedArray,
	#superclass : #ArrayedCollection,
	#instVars : [
		'predicates',
		'values',
		'type'
	],
	#category : #'Etoys-Squeakland-Tweak-Kedama-ObjectVectors'
}

{ #category : #'instance creation' }
PredicatedArray class >> new: size [

	| inst elems |
	inst := self basicNew.
	elems := ByteArray new: size withAll: 1.
	inst predicates: elems values: elems.
	^ inst.

]

{ #category : #'instance creation' }
PredicatedArray class >> newFor: anArrayedCollection [

	| inst predicates |
	inst := self basicNew.
	predicates := ByteArray new: anArrayedCollection size.
	inst predicates: predicates values: anArrayedCollection.
	^ inst.

]

{ #category : #'instance creation' }
PredicatedArray class >> predicates: predicates values: anArrayedCollection [

	^  self new predicates: predicates values: anArrayedCollection.

]

{ #category : #'instance creation' }
PredicatedArray class >> predicates: predicates values: anArrayedCollection type: typeSymbol [

	^  self new predicates: predicates values: anArrayedCollection type: typeSymbol

]

{ #category : #converting }
PredicatedArray >> asPredicate [

	predicates := values.

]

{ #category : #'slot accessing' }
PredicatedArray >> at: index [

	^ values at: index.

]

{ #category : #'slot accessing' }
PredicatedArray >> at: index put: anObject [

	^ values at: index put: anObject.

]

{ #category : #enumeration }
PredicatedArray >> atAllBasicPut: aValue [

	self indexDo: [:index |
		values basicAt: index put: aValue.
	].

]

{ #category : #enumeration }
PredicatedArray >> atAllPut: anObject [

	type = #Number ifTrue: [
		self primAtAllPutNumber: anObject asFloat.
		^ self.
	].
	type = #Object ifTrue: [
		self primAtAllPutObject: anObject.
		^ self.
	].
	type = #Color ifTrue: [
		self primAtAllPutColor: anObject.
		^ self.
	].
	type = #Boolean ifTrue: [
		self primAtAllPutBoolean: anObject.
		^ self.
	].


]

{ #category : #enumeration }
PredicatedArray >> do: aBlock [

	1 to: (values size min: predicates size) do: [:index |
		(predicates at: index) = 1 ifTrue: [
			aBlock value: (values at: index).
		].
	].

]

{ #category : #enumeration }
PredicatedArray >> from: from to: to put: anObject [

	self indexDo: [:index |
		(index between: from and: to) ifTrue: [
			self at: index put: anObject.
		].
	].

]

{ #category : #enumeration }
PredicatedArray >> indexDo: aBlock [

	1 to: (values size min: predicates size) do: [:index |
		(predicates at: index) = 1 ifTrue: [
			aBlock value: index.
		].
	].

]

{ #category : #accessing }
PredicatedArray >> predicates [

	^ predicates.

]

{ #category : #accessing }
PredicatedArray >> predicates: anArray [

	predicates := anArray.

]

{ #category : #initialization }
PredicatedArray >> predicates: anObject values: anotherObject [

	predicates := anObject.
	values := anotherObject.

]

{ #category : #initialization }
PredicatedArray >> predicates: anObject values: anotherObject type: typeSymbol [

	predicates := anObject.
	values := anotherObject.
	type := typeSymbol.

]

{ #category : #primitives }
PredicatedArray >> primAtAllPutBoolean: val [

	| b |
	<primitive: 'primitivePredicateAtAllPutBoolean' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitivePredicateAtAllPutBoolean."

	b := (val == true or: [val == false]) ifTrue: [
			val ifTrue: [1] ifFalse: [0].
		] ifFalse: [val].

	1 to: (values size min: predicates size) do: [:index |
		(predicates at: index) = 1 ifTrue: [
			values at: index put: b.
		].
	].

]

{ #category : #primitives }
PredicatedArray >> primAtAllPutColor: val [

	| p |
	<primitive: 'primitivePredicateAtAllPutColor' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitivePredicateAtAllPutColor."

	p := val bitOr: 16rFF000000.
	1 to: (values size min: predicates size) do: [:index |
		(predicates at: index) = 1 ifTrue: [
			values at: index put: p.
		].
	].

]

{ #category : #primitives }
PredicatedArray >> primAtAllPutNumber: val [

	<primitive: 'primitivePredicateAtAllPutNumber' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitivePredicateAtAllPutNumber."

	1 to: (values size min: predicates size) do: [:index |
		(predicates at: index) = 1 ifTrue: [
			values at: index put: val.
		].
	].

]

{ #category : #primitives }
PredicatedArray >> primAtAllPutObject: val [

	<primitive: 'primitivePredicateAtAllPutObject' module:'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitivePredicateAtAllPutObject."

	1 to: (values size min: predicates size) do: [:index |
		(predicates at: index) = 1 ifTrue: [
			values at: index put: val.
		].
	].

]

{ #category : #primitives }
PredicatedArray >> primReplaceBytesFrom: start to: stop with: replacement startingAt: repStart [

	| v |
	<primitive: 'primitivePredicateReplaceBytes' module: 'KedamaPlugin2'>
	Smalltalk
		at: #KedamaPlugin2
		ifPresent: [:p | ^ p doPrimitive: #primitivePredicateReplaceBytes].
	self indexDo: [:index |
		(index between: start and: stop) ifTrue: [
			v := replacement at: repStart + index - start.
			self at: index put: v.
		].
	].
]

{ #category : #primitives }
PredicatedArray >> primReplaceWordsFrom: start to: stop with: replacement startingAt: repStart [

	| v |
	<primitive: 'primitivePredicateReplaceWords' module: 'KedamaPlugin2'>
	"^ KedamaPlugin2 doPrimitive: #primitivePredicateReplaceWords."

	self indexDo: [:index |
		(index between: start and: stop) ifTrue: [
			v := replacement at: repStart + index - start.
			self at: index put: v.
		].
	].

]

{ #category : #printing }
PredicatedArray >> printElementsOn: aStream [
	aStream nextPut: $(.
	1 to: values size do: [:index | aStream print: (self at: index); space].
	self isEmpty ifFalse: [aStream skip: -1].
	aStream nextPut: $)
]

{ #category : #enumeration }
PredicatedArray >> replaceFrom: start to: stop with: replacement startingAt: repStart [

	(type = #Number or: [type = #Object or: [type = #Color]]) ifTrue: [
		self primReplaceWordsFrom: start to: stop with: replacement startingAt: repStart.
		^ self.
	].
	type = #Boolean ifTrue: [
		self primReplaceBytesFrom: start to: stop with: replacement startingAt: repStart.
		^ self.
	].

]

{ #category : #accessing }
PredicatedArray >> size [

	^ values size.

]

{ #category : #accessing }
PredicatedArray >> type [

	^ type.

]

{ #category : #accessing }
PredicatedArray >> type: aSymbol [

	type := aSymbol.

]

{ #category : #accessing }
PredicatedArray >> values [

	^ values.

]

{ #category : #accessing }
PredicatedArray >> values: anArray [

	values := anArray.

]
