Class {
	#name : #ChangeSetCategoryWithParameters,
	#superclass : #ChangeSetCategory,
	#instVars : [
		'parameters'
	],
	#category : #'Etoys-Squeakland-Tools-Changes'
}

{ #category : #'as yet unclassified' }
ChangeSetCategoryWithParameters >> acceptsManualAdditions [
	"Answer whether the user is allowed manually to manipulate the contents of the change-set-category."

	^ true
]

{ #category : #'as yet unclassified' }
ChangeSetCategoryWithParameters >> addChangeSet: aChangeSet [
	self inform: 'sorry, you can''t do that'
]

{ #category : #'as yet unclassified' }
ChangeSetCategoryWithParameters >> includesChangeSet: aChangeSet [
	"Answer whether the receiver includes aChangeSet in its retrieval list"

	^ ChangeSorter perform: membershipSelector withArguments: { aChangeSet } , parameters
]

{ #category : #'as yet unclassified' }
ChangeSetCategoryWithParameters >> parameters: anArray [
	parameters := anArray
]

{ #category : #'as yet unclassified' }
ChangeSetCategoryWithParameters >> reconstituteList [
	"Clear out the receiver's elements and rebuild them"

	| newMembers |
	"First determine newMembers and check if they have not changed..."
	newMembers := ChangeSet allChangeSets select:
		[:aChangeSet | ChangeSorter perform: membershipSelector withArguments: { aChangeSet }, parameters].
	(newMembers collect: [:cs | cs name]) = keysInOrder ifTrue: [^ self  "all current"].

	"Things have changed.  Need to recompute the whole category"
	self clear.
	newMembers do:
		[:aChangeSet | self fasterElementAt: aChangeSet name asSymbol put: aChangeSet]
]
