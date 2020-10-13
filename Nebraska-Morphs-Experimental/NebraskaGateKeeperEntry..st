Class {
	#name : #NebraskaGateKeeperEntry,
	#superclass : #MorphicModel,
	#instVars : [
		'ipAddress',
		'accessAttempts',
		'lastTimes',
		'acceptableTypes',
		'latestUserName',
		'attempsDenied',
		'lastRequests'
	],
	#classVars : [
		'KnownIPAddresses'
	],
	#category : #'Nebraska-Morphs-Experimental'
}

{ #category : #'new-morph participation' }
NebraskaGateKeeperEntry class >> includeInNewMorphMenu [
	"Not to be instantiated from the menu"
	^ false
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> acceptableTypes [

	^acceptableTypes
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> dateAndTimeStringFrom: totalSeconds [

	| dateAndTime |
	dateAndTime := Time dateAndTimeFromSeconds: totalSeconds.
	^dateAndTime first printString,' ',dateAndTime second printString
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> fullInfoString [

	^self latestUserName,
		' at ',
		ipAddress ,
		' attempts: ',
		accessAttempts printString,
		'/',
		attempsDenied printString,
		' last: ',
		(self lastIncomingMessageTimeString)
	 
"acceptableTypes"

 
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> getChoice: aString [

	^acceptableTypes includes: aString
]

{ #category : #initialization }
NebraskaGateKeeperEntry >> initialize [

	self flag: #bob.		"need to decide better initial types"

	super initialize.
	ipAddress := '???'.
	accessAttempts := attempsDenied := 0.
	lastRequests := OrderedCollection new.
	acceptableTypes := Set withAll: NebraskaIncomingMessage allTypes.

 
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> ipAddress [

	^ipAddress
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> ipAddress: aString [

	ipAddress := aString
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> lastIncomingMessageTimeString [

	lastRequests isEmpty ifTrue: [^'never'].
	^self dateAndTimeStringFrom: lastRequests first first

]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> lastTimeChecked [

	^self valueOfProperty: #lastTimeChecked

]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> lastTimeChecked: aDateAndTimeInSeconds [

	self setProperty: #lastTimeChecked toValue: aDateAndTimeInSeconds

]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> lastTimeCheckedString [

	| statusTime |
	statusTime := self valueOfProperty: #lastTimeChecked ifAbsent: [^'none'].
	^(self dateAndTimeStringFrom: statusTime)
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> latestUserName [

	^latestUserName ifNil: ['???']
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> latestUserName: aString [

	latestUserName := aString
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> requestAccessOfType: aString [

	| ok |

	accessAttempts := accessAttempts + 1.
	lastRequests addFirst: {Time totalSeconds. aString}.
	lastRequests size > 10 ifTrue: [
		lastRequests := lastRequests copyFrom: 1 to: 10.
	].
	ok := (acceptableTypes includes: aString) or: [acceptableTypes includes: 'all'].
	ok ifFalse: [attempsDenied := attempsDenied + 1].
	^ok
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> statusReplyReceived: anArray [

	self setProperty: #lastStatusReplyTime toValue: Time totalSeconds.
	self setProperty: #lastStatusReply toValue: anArray.
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> statusReplyReceivedString [

	| statusTime |
	statusTime := self valueOfProperty: #lastStatusReplyTime ifAbsent: [^'none'].
	^(self dateAndTimeStringFrom: statusTime),' accepts:
', (self valueOfProperty: #lastStatusReply) asArray printString
]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> timeBetweenLastAccessAnd: currentTime [

	lastRequests isEmpty ifTrue: [^0].
	^currentTime - lastRequests first first

]

{ #category : #'as yet unclassified' }
NebraskaGateKeeperEntry >> toggleChoice: aString [

	(acceptableTypes includes: aString) ifTrue: [
		acceptableTypes remove: aString ifAbsent: []
	] ifFalse: [
		acceptableTypes add: aString
	].
]
