Class {
	#name : #ByteEncoder,
	#superclass : #FlattenEncoder,
	#category : #'MorphicExtras-Postscript Filters'
}

{ #category : #configuring }
ByteEncoder class >> defaultTarget [
	^WriteStream on:(String new: 40000).
]

{ #category : #configuring }
ByteEncoder class >> filterSelector [
	^#byteEncode:.
]

{ #category : #configuring }
ByteEncoder class >> numberDefaultBase [
	^10.

]

{ #category : #writing }
ByteEncoder >> cr [
	^target cr.

]

{ #category : #'filter streaming' }
ByteEncoder >> elementSeparator [
	^' '.
]

{ #category : #writing }
ByteEncoder >> nextPut: encodedObject [
	"pass through for stream compatibility"
	^target nextPut: encodedObject.

]

{ #category : #writing }
ByteEncoder >> nextPutAll: encodedObject [
	"pass through for stream compatibility"
	^target nextPutAll: encodedObject.

]

{ #category : #accessing }
ByteEncoder >> numberDefaultBase [
	^self class numberDefaultBase.

]

{ #category : #writing }
ByteEncoder >> print:encodedObject [
	^target write:encodedObject.

]

{ #category : #writing }
ByteEncoder >> space [
	^target space.

]

{ #category : #writing }
ByteEncoder >> tab [
	^target tab.

]

{ #category : #writing }
ByteEncoder >> writeArray:aCollection [
	^self writeArrayedCollection:aCollection.


]

{ #category : #writing }
ByteEncoder >> writeAssocation:anAssociation [
	^self write:anAssociation key; print:'->'; write:anAssociation value.


]

{ #category : #writing }
ByteEncoder >> writeCollection:aCollection [
	^self print:aCollection class name; 
		writeCollectionContents:aCollection.


]

{ #category : #writing }
ByteEncoder >> writeCollectionContents:aCollection [
	self print:'( '.
		super writeCollectionContents:aCollection.
		self print:')'.
	^self.

]

{ #category : #writing }
ByteEncoder >> writeNumber:aNumber [
	^self writeNumber:aNumber base:self numberDefaultBase.


]

{ #category : #writing }
ByteEncoder >> writeNumber:aNumber base:aBase [
	^aNumber byteEncode:self base:aBase.


]

{ #category : #writing }
ByteEncoder >> writeObject:anObject [
	^self print:anObject stringRepresentation.

]

{ #category : #writing }
ByteEncoder >> writeString:aString [
	^aString encodeDoublingQuoteOn:self.
]
