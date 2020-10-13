Class {
	#name : #ProjectHistory,
	#superclass : #Model,
	#instVars : [
		'mostRecent'
	],
	#classVars : [
		'ChangeCounter',
		'CurrentHistory'
	],
	#category : #'System-Support'
}

{ #category : #accessing }
ProjectHistory class >> changeCounter [

	^ChangeCounter ifNil: [ChangeCounter := 0].
]

{ #category : #'class initialization' }
ProjectHistory class >> cleanUp [
	"Re-initialize current history"

	self currentHistory initialize
]

{ #category : #accessing }
ProjectHistory class >> currentHistory [
	^CurrentHistory ifNil: [CurrentHistory := self new]
]

{ #category : #'project lifetime' }
ProjectHistory class >> forget: aProject [

	self currentHistory forget: aProject

]

{ #category : #'project lifetime' }
ProjectHistory class >> remember: aProject [

	self currentHistory remember: aProject

]

{ #category : #updating }
ProjectHistory >> changed [

	ChangeCounter := (ChangeCounter ifNil: [0]) + 1.
	super changed.
]

{ #category : #'project lifetime' }
ProjectHistory >> cleanUp [
	mostRecent := mostRecent reject: [ :each |
		| proj |
		proj := each fourth first.
		proj isNil or: [proj world isNil]
	].
	self changed.

]

{ #category : #'project lifetime' }
ProjectHistory >> forget: aProject [

	| newTuple |
	newTuple := {
		aProject name.
		aProject thumbnail.
		aProject url.
		WeakArray with: aProject.
	}.
	mostRecent := mostRecent reject: [ :each |
		each fourth first == aProject or: [
			each fourth first isNil & (each first = newTuple first)
		].
	].
	self changed.
	^newTuple
]

{ #category : #'initialize-release' }
ProjectHistory >> initialize [

	mostRecent := OrderedCollection new.

]

{ #category : #accessing }
ProjectHistory >> mostRecentCopy [

	self cleanUp.
	^mostRecent copy
]

{ #category : #accessing }
ProjectHistory >> mostRecentNames [

	self cleanUp.
	^mostRecent collect: [ :each |
		each first
	].

]

{ #category : #accessing }
ProjectHistory >> mostRecentThread [

	| projectNames threadName |
	self cleanUp.
	projectNames := (mostRecent collect: [ :each | {each first} ]) reversed.

	threadName := UIManager default 
		request: 'Please name this thread.' 
		initialAnswer: 'Recent projects @ ',Time now printString.
	threadName isEmptyOrNil ifTrue: [^nil].
	"rbb 3/1/2005 - Should be refactored to eliminate Morphic dependency"
	InternalThreadNavigationMorph know: projectNames as: threadName.
	^threadName

]

{ #category : #'project lifetime' }
ProjectHistory >> remember: aProject [

	| newTuple |

	newTuple := self forget: aProject.
	mostRecent addFirst: newTuple.
	mostRecent size > 10 ifTrue: [mostRecent := mostRecent copyFrom: 1 to: 10].
	self changed
]
