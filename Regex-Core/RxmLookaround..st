"
Instance holds onto a lookaround which matches but does not consume anything.

Instance Variables
	lookbehind:		<RxmLink>
	forward:		<Boolean>
	positive:		<Boolean>
"
Class {
	#name : #RxmLookaround,
	#superclass : #RxmLink,
	#instVars : [
		'forward',
		'positive',
		'lookaround'
	],
	#category : #'Regex-Core'
}

{ #category : #'instance creation' }
RxmLookaround class >> with: aPiece forward: forwardBoolean positive: positiveBoolean [

	^self new lookaround: aPiece forward: forwardBoolean positive: positiveBoolean
]

{ #category : #accessing }
RxmLookaround >> lookaround: anRxmLink forward: forwardBoolean positive: positiveBoolean [
	lookaround := anRxmLink.
	forward := forwardBoolean.
	positive := positiveBoolean.
]

{ #category : #matching }
RxmLookaround >> matchAgainst: aMatcher [
	"Match if the predicate block evaluates to true when given the current stream character as the argument."

	^ forward
		ifTrue: [aMatcher matchAgainstLookahead: lookaround positive: positive nextLink: next]
		ifFalse: [aMatcher matchAgainstLookbehind: lookaround positive: positive nextLink: next]
]

{ #category : #copying }
RxmLookaround >> postCopy [

	super postCopy.
	lookaround := lookaround copy
]

{ #category : #copying }
RxmLookaround >> postCopyUsing: anIdentityDictionary [

	super postCopyUsing: anIdentityDictionary.
	lookaround := lookaround copyUsing: anIdentityDictionary
]

{ #category : #building }
RxmLookaround >> terminateWith: aNode [
	lookaround terminateWith: aNode.
	super terminateWith: aNode.
]
