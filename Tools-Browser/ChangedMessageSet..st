"
A ChangedMessageSet is a message set associated with a change-set; it bears an entry for every method added or changed in the change set, as well as for every class-comment of which the change-set bears a note.
"
Class {
	#name : #ChangedMessageSet,
	#superclass : #MessageSet,
	#instVars : [
		'changeSet'
	],
	#category : #'Tools-Browser'
}

{ #category : #opening }
ChangedMessageSet class >> openFor: aChangeSet [
	"Open up a ChangedMessageSet browser on the given change set; this is a conventional message-list browser whose message-list consists of all the methods in aChangeSet.  After any method submission, the message list is refigured, making it plausibly dynamic"

	| messageSet |

	messageSet := aChangeSet changedMessageListAugmented select: [ :each | each isValid].
	self 
		openMessageList: messageSet 
		name: 'Methods in Change Set ', aChangeSet name
		autoSelect: nil
		changeSet: aChangeSet
]

{ #category : #opening }
ChangedMessageSet class >> openMessageList: messageList name: labelString autoSelect: autoSelectString changeSet: aChangeSet [
	| messageSet |
	messageSet := self messageList: messageList.
	messageSet changeSet: aChangeSet.
	messageSet autoSelectString: autoSelectString.
	ToolBuilder open: messageSet label: labelString.
]

{ #category : #initialization }
ChangedMessageSet >> changeSet: aChangeSet [
	changeSet := aChangeSet
]

{ #category : #acceptance }
ChangedMessageSet >> contents: aString notifying: aController [
	"Accept the string as new source for the current method, and make certain the annotation pane gets invalidated"

	| existingSelector existingClass superResult newSelector |
	existingSelector := self selectedMessageName.
	existingClass := self selectedClassOrMetaClass.

	superResult := super contents: aString notifying: aController.
	superResult ifTrue:  "succeeded"
		[newSelector := existingClass newParser parseSelector: aString.
		newSelector ~= existingSelector
			ifTrue:   "Selector changed -- maybe an addition"
				[self reformulateList.
				self changed: #messageList.
				self messageList doWithIndex:
					[:aMethodReference :anIndex |
						(aMethodReference actualClass == existingClass and:
									[aMethodReference methodSymbol == newSelector])
							ifTrue:
								[self messageListIndex: anIndex]]]].
	^ superResult
]

{ #category : #'message list' }
ChangedMessageSet >> growable [
	"Answer whether the receiver can be changed by manual additions & deletions"

	^ false
]

{ #category : #reformulation }
ChangedMessageSet >> reformulateList [
	"Reformulate the message list of the receiver"

	self initializeMessageList: (changeSet changedMessageListAugmented select: 
		[:each | each isValid])

]
