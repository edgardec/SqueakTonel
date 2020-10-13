Class {
	#name : #TextStream,
	#superclass : #WriteStream,
	#category : #'Collections-Streams'
}

{ #category : #private }
TextStream >> applyAttribute: att beginningAt: startPos [
	collection addAttribute: att from: startPos to: self position
]

{ #category : #writing }
TextStream >> nextPutAll: aCollection [ 
	"Optimized access to get around Text at:Put: overhead"
	| n |
	n := aCollection size.
	position + n > writeLimit
		ifTrue:
			[self growTo: position + n + 10].
	collection 
		replaceFrom: position+1
		to: position + n
		with: aCollection
		startingAt: 1.
	position := position + n.
	^aCollection
]

{ #category : #private }
TextStream >> withAttribute: att do: strmBlock [
	| pos1 val |
	pos1 := self position.
	val := strmBlock value.
	collection addAttribute: att from: pos1+1 to: self position.
	^ val
]

{ #category : #private }
TextStream >> withAttributes: attributes do: streamBlock [ 
	| pos1 val |
	pos1 := self position.
	val := streamBlock value.
	attributes do: [:attribute |
		collection
			addAttribute: attribute
			from: pos1 + 1
			to: self position].
	^ val
]
