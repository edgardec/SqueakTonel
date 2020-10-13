Class {
	#name : #RecentMessages,
	#superclass : #Object,
	#instVars : [
		'methodReferences',
		'maximumSubmissionCount',
		'isSuspended'
	],
	#classVars : [
		'Default'
	],
	#category : #'System-Support'
}

{ #category : #'class initialization' }
RecentMessages class >> cleanUp: aggressive [

	aggressive ifTrue: [Default := nil].
]

{ #category : #accessing }
RecentMessages class >> default [
	^ Default ifNil: [Default := RecentMessages newRemembering: 30].
]

{ #category : #'instance creation' }
RecentMessages class >> newRemembering: anInteger [ 
	^ self new
		 maximumSubmissionCount: anInteger ;
		 yourself
]

{ #category : #preferences }
RecentMessages class >> numberOfRecentSubmissionsToStore [
	<preference: 'Number of recent submissions to store' category: 'Tools' description: 'Answer how many methods back the ''recent method submissions'' history should store' type: #Number>
	^ self default maximumSubmissionCount
]

{ #category : #preferences }
RecentMessages class >> numberOfRecentSubmissionsToStore: anInteger [
	self default maximumSubmissionCount: anInteger
]

{ #category : #preferences }
RecentMessages class >> setRecentHistorySize [
	"Let the user specify the recent history size."
	self numberOfRecentSubmissionsToStore:
		(UIManager default
			request: 'How many recent changes
should be remembered?'
			initialAnswer: self numberOfRecentSubmissionsToStore asString)
]

{ #category : #'system startup' }
RecentMessages class >> startUp [
	SystemChangeNotifier uniqueInstance
		notify: self default
		ofAllSystemChangesUsing: #event:.
]

{ #category : #private }
RecentMessages >> defaultSize [
	^ 30
]

{ #category : #'change logging' }
RecentMessages >> event: anEvent [ 
	"Hook for SystemChangeNotifier"
	(anEvent isCommented and: [ anEvent itemKind = SystemChangeNotifier classKind ]) ifTrue:
		[ self
			recordSelector: #Comment
			forClass: anEvent item
			inEnvironment: anEvent itemEnvironment ].
	((anEvent isAdded or: [ anEvent isModified ]) and: [ anEvent itemKind = SystemChangeNotifier methodKind ]) ifTrue:
		[ anEvent itemRequestor ifNotNil:
			[ self
				recordSelector: anEvent itemSelector
				forClass: anEvent itemClass
				inEnvironment: anEvent itemEnvironment ].
		InMidstOfFileinNotification signal ifFalse: [ Utilities changed: #recentMethodSubmissions ] ]
]

{ #category : #'initialize-release' }
RecentMessages >> initialize [
	super initialize.
	methodReferences := OrderedCollection new: (maximumSubmissionCount := 30).
	self resume
]

{ #category : #testing }
RecentMessages >> isEmpty [
	^ methodReferences isEmpty.
]

{ #category : #accessing }
RecentMessages >> leastRecent [
	^ methodReferences
		ifEmpty: [ nil ]
		ifNotEmpty: [ methodReferences last ]
]

{ #category : #accessing }
RecentMessages >> maximumSubmissionCount [
	^ maximumSubmissionCount.
]

{ #category : #accessing }
RecentMessages >> maximumSubmissionCount: anInteger [
	maximumSubmissionCount := anInteger.
	self trim
]

{ #category : #accessing }
RecentMessages >> methodReferences [
	^ methodReferences asArray
]

{ #category : #accessing }
RecentMessages >> mostRecent [
	^ methodReferences first
]

{ #category : #accessing }
RecentMessages >> purgeFromRecentSubmissions: aMethodReference [
	methodReferences remove: aMethodReference ifAbsent: []
]

{ #category : #accessing }
RecentMessages >> recordSelector: aSelector forClass: aClass inEnvironment: anEnvironment [ 
	| ref |
	(isSuspended = true or: [ aClass wantsChangeSetLogging not ]) ifTrue: [ ^ self ].
	ref := MethodReference
		class: aClass
		selector: aSelector
		environment: anEnvironment.
	methodReferences
		remove: ref
		ifAbsent: [  ].
	ref methodSymbol isDoIt ifFalse: [ methodReferences addFirst: ref ].
	self trim
]

{ #category : #accessing }
RecentMessages >> resume [
	isSuspended := false
]

{ #category : #accessing }
RecentMessages >> revertMostRecent [
	"If the most recent method submission was a method change, revert
	that change, and if it was a submission of a brand-new method, 
	remove that method."
	| changeRecords lastSubmission theClass theSelector |
	methodReferences ifEmpty: [ ^ Beeper beep ].
	lastSubmission := self mostRecent.
	theClass := lastSubmission actualClass ifNil: [ ^ Beeper beep ].
	theSelector := lastSubmission methodSymbol.
	changeRecords := theClass changeRecordsAt: theSelector.
	changeRecords isEmptyOrNil ifTrue: [ ^ Beeper beep ].
	changeRecords size = 1
		ifTrue: [ "method has no prior version, so reverting in this case means removing"
			theClass removeSelector: theSelector ]
		ifFalse: [ changeRecords second fileIn: lastSubmission environment ]

]

{ #category : #accessing }
RecentMessages >> size [
	^ methodReferences size.
]

{ #category : #accessing }
RecentMessages >> suspendWhile: aBlock [
	| priorSuspended |
	priorSuspended := isSuspended.
	isSuspended := true.
	aBlock ensure: [ isSuspended := priorSuspended ]
]

{ #category : #private }
RecentMessages >> trim [
	[ methodReferences size > maximumSubmissionCount ] whileTrue: [ methodReferences removeLast ]
]
