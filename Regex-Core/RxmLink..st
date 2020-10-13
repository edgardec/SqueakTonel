"
-- Regular Expression Matcher v 1.1 (C) 1996, 1999 Vassili Bykov
--
A matcher is built of a number of links interconnected into some intricate structure. Regardless of fancy stuff, any link (except for the terminator) has the next one. Any link can match against a stream of characters, recursively propagating the match to the next link. Any link supports a number of matcher-building messages. This superclass does all of the above. 

The class is not necessarily abstract. It may double as an empty string matcher: it recursively propagates the match to the next link, thus always matching nothing successfully.

Principal method:
	matchAgainst: aMatcher
		Any subclass will reimplement this to test the state of the matcher, most
		probably reading one or more characters from the matcher's stream, and
		either decide it has matched and answer true, leaving matcher stream
		positioned at the end of match, or answer false and restore the matcher
		stream position to whatever it was before the matching attempt.

Instance variables:
	next		<RxmLink | RxmTerminator> The next link in the structure.
"
Class {
	#name : #RxmLink,
	#superclass : #Object,
	#instVars : [
		'next'
	],
	#category : #'Regex-Core'
}

{ #category : #copying }
RxmLink >> copyChain [
	"Create a full copy of all the links in this chain, including branches, while letting them share and reuse non-link objects as much as possible."

	^self copyUsing: IdentityDictionary new
]

{ #category : #copying }
RxmLink >> copyUsing: anIdentityDictionary [
	"Copy the receiver if it's not present in the argument dictionary, or just return the previously made copy. The rest of the object graph will be copied by #postCopyUsing:."

	^anIdentityDictionary 
		at: self
		ifAbsent: [
			"It may be tempting to use #at:ifAbsentPut: instead, but the argument block must not modify the receiver, so that wouldn't work."
			anIdentityDictionary
				at: self
				put: (self shallowCopy
					postCopyUsing: anIdentityDictionary;
					yourself) ]
]

{ #category : #matching }
RxmLink >> matchAgainst: aMatcher [
	"If a link does not match the contents of the matcher's stream,
	answer false. Otherwise, let the next matcher in the chain match."

	^next matchAgainst: aMatcher
]

{ #category : #accessing }
RxmLink >> next [
	
	^next
]

{ #category : #accessing }
RxmLink >> next: aLink [
	"Set the next link, either an RxmLink or an RxmTerminator."

	next := aLink
]

{ #category : #building }
RxmLink >> pointTailTo: anRxmLink [
	"Propagate this message along the chain of links.
	Point `next' reference of the last link to <anRxmLink>.
	If the chain is already terminated, blow up."

	next == nil
		ifTrue: [next := anRxmLink]
		ifFalse: [next pointTailTo: anRxmLink]
]

{ #category : #copying }
RxmLink >> postCopy [
	super postCopy.
	next := next copy
]

{ #category : #copying }
RxmLink >> postCopyUsing: anIdentityDictionary [
	"Copy the rest of the chain the same way as it's done in #copyUsing:."

	next ifNotNil: [
		next := next copyUsing: anIdentityDictionary ]
]

{ #category : #'as yet unclassified' }
RxmLink >> printOn: stream [

	super printOn: stream.
	stream
		nextPut: $(;
		print: self identityHash;
		nextPutAll: ', ';
		print: (next ifNotNil: [ next identityHash ]);
		nextPut: $)
]

{ #category : #building }
RxmLink >> terminateWith: aTerminator [
	"Propagate this message along the chain of links, and
	make aTerminator the `next' link of the last link in the chain.
	If the chain is already reminated with the same terminator, 
	do not blow up."

	next == nil
		ifTrue: [next := aTerminator]
		ifFalse: [next terminateWith: aTerminator]
]
