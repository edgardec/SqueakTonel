"
RecentMessageSet is a message set that shows the most recently-submitted methods, in chronological order.
"
Class {
	#name : #RecentMessageSet,
	#superclass : #MessageSet,
	#category : #'Tools-Browser'
}

{ #category : #'message list' }
RecentMessageSet >> addExtraShiftedItemsTo: aMenu [
	"The shifted selector-list menu is being built.  Overridden here to defeat the presence of the items that add or change order, since RecentMessageSet defines methods & order explicitly based on external criteria"

	aMenu add: 'set size of recent history...' target: RecentMessages action: #setRecentHistorySize
]

{ #category : #contents }
RecentMessageSet >> contents: c notifying: n [
	| result |
	result := super contents: c notifying: n.
	result == true ifTrue:
		[self reformulateList].
	^ result
]

{ #category : #'message list' }
RecentMessageSet >> formattedLabel: aString forSelector: aSymbol inClass: aClass [
	"Overridden to account for outdated MethodReference after class renames."	

	self flag: #fix. "mt: We might want to fix RecentMessages to instead. Other tools (or features) might depend on it, too."
	^ aClass
		ifNil: [aString asText]
		ifNotNil: [super formattedLabel: aString forSelector: aSymbol inClass: aClass]

]

{ #category : #update }
RecentMessageSet >> growable [
	"Answer whether the receiver can be changed by manual additions & deletions"

	^ false
]

{ #category : #'message list' }
RecentMessageSet >> messageHelpForMethod: aMethod [
	"Overridden to account for outdated MethodReference after class renames."
	
	self flag: #fix. "mt: We might want to fix RecentMessages to instead. Other tools (or features) might depend on it, too."
	^ aMethod ifNotNil: [super messageHelpForMethod: aMethod]
]

{ #category : #'message functions' }
RecentMessageSet >> messageListMenuForRecentSubmission: aMenu [
	<messageListMenuShifted: false>
	aMenu addList:#(
			('remove from RecentSubmissions'		removeFromRecentSubmissions)).
	^ aMenu
]

{ #category : #update }
RecentMessageSet >> reformulateList [
	"Reformulate the receiver's list.  Exclude methods now deleted"

	| currentSelection |
	messageListIndex > 0 ifTrue:
		[currentSelection := messageList at: messageListIndex].
	self initializeMessageList: (RecentMessages default methodReferences select: [:mr| mr isValid]).
	currentSelection ifNotNil:
		[messageListIndex := messageList indexOf: currentSelection ifAbsent: [1]].
	self
		changed: #messageList;
		changed: #messageListIndex
]

{ #category : #'message functions' }
RecentMessageSet >> removeFromRecentSubmissions [
	"Remove the currently-selected method from the RecentMessages list"

	| aClass methodSym |
	((aClass := self selectedClassOrMetaClass) notNil and: [(methodSym := self selectedMessageName) notNil])
		ifTrue: 
			[RecentMessages default purgeFromRecentSubmissions: (MethodReference class: aClass selector: methodSym).
			self reformulateList]
]

{ #category : #'message list' }
RecentMessageSet >> setRecentHistorySize [
	"Let the user specify the recent history size"

	| aReply aNumber |
	aReply := UIManager default request: 'How many recent methods
should be maintained?' initialAnswer: RecentMessages numberOfRecentSubmissionsToStore asString.
	aReply isEmptyOrNil ifFalse:
		[aNumber := aReply asNumber rounded.
		(aNumber > 1 and: [aNumber <= 1000])
			ifTrue:
				[RecentMessages numberOfRecentSubmissionsToStore: aNumber.
				self inform: 'Okay, ', aNumber asString, ' is the new size of the recent method history']
			ifFalse:
				[self inform: 'Sorry, must be a number between 2 & 1000']]
]

{ #category : #update }
RecentMessageSet >> updateListsAndCodeIn: aWindow [ 
	self canDiscardEdits ifFalse: [^self].
	RecentMessages default isEmpty ifTrue: [^self].
	(messageList isEmpty
	 or: [RecentMessages default mostRecent = messageList first and: [RecentMessages default mostRecent isValid]])
		ifTrue: [self updateCodePaneIfNeeded]
		ifFalse: [self reformulateList]
]
