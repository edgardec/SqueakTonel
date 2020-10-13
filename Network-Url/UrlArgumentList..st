Class {
	#name : #UrlArgumentList,
	#superclass : #OrderedCollection,
	#category : #'Network-Url'
}

{ #category : #'instance creation' }
UrlArgumentList class >> with: argAssoc [
	| argList |
	argList := self new.
	argList add: argAssoc key value: argAssoc value.
	^argList
]

{ #category : #'instance creation' }
UrlArgumentList class >> with: firstArgAssoc with: secondArgAssoc [
	| argList |
	argList := self with: firstArgAssoc.
	argList add: secondArgAssoc key value: secondArgAssoc value.
	^argList
]

{ #category : #'instance creation' }
UrlArgumentList class >> with: firstArgAssoc with: secondArgAssoc with: thirdArgAssoc [
	| argList |
	argList := self with: firstArgAssoc with: secondArgAssoc.
	argList add: thirdArgAssoc key value: thirdArgAssoc value.
	^argList
]

{ #category : #adding }
UrlArgumentList >> add: argName value: argValue [
	| argAssociation |
	argAssociation := self argumentNamed: argName.
	argAssociation isNil
		ifTrue: [self add: (argName -> (OrderedCollection with: argValue))]
		ifFalse: [argAssociation value add: argValue]
]

{ #category : #private }
UrlArgumentList >> argumentNamed: argName [
	^self
		detect: [:each | each key = argName]
		ifNone: [nil]
]
