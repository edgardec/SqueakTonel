"
The simplest possible encoding:  leave the objects as is.

"
Class {
	#name : #FlattenEncoder,
	#superclass : #NullEncoder,
	#category : #'Morphic-Support'
}

{ #category : #configuring }
FlattenEncoder class >> filterSelector [
	^#flattenOnStream:

]

{ #category : #writing }
FlattenEncoder >> cr [
	^self print:String cr.


]

{ #category : #'filter streaming' }
FlattenEncoder >> elementSeparator [
	^target elementSeparator.
]

{ #category : #writing }
FlattenEncoder >> writeArrayedCollection:anArrayedCollection [
	^self writeCollectionContents:anArrayedCollection.


]

{ #category : #writing }
FlattenEncoder >> writeCollection:aCollection [
	^self writeCollectionContents:aCollection.


]

{ #category : #writing }
FlattenEncoder >> writeCollectionContents:aCollection [
    ^self writeCollectionContents:aCollection separator:self elementSeparator iterationMessage:#do:.


]

{ #category : #writing }
FlattenEncoder >> writeCollectionContents:aCollection separator:separator [
	^self writeCollectionContents:aCollection separator:separator iterationMessage:#do:.
]

{ #category : #writing }
FlattenEncoder >> writeCollectionContents:aCollection separator:separator iterationMessage:op [
	| first |
	first := true.
	aCollection perform:op with: [ :each |  first ifFalse:[ self writeObject:separator ]. self write:each. first:=false.].

]

{ #category : #writing }
FlattenEncoder >> writeDictionary:aCollection [
	^self writeDictionaryContents:aCollection separator:nil.


]

{ #category : #writing }
FlattenEncoder >> writeDictionaryContents:aCollection separator:separator [
	^self writeCollectionContents:aCollection separator:separator iterationMessage:#associationsDo:.
]
