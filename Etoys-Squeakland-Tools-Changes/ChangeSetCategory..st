"
A ChangeSetCategory represents a list of change sets to be shown in a ChangeSorter.  It computes whether a given change set is in the list by sending its membershipSelector to ChangeSorter (i.e. the class object) with the change set as message argument.
"
Class {
	#name : #ChangeSetCategory,
	#superclass : #ElementCategory,
	#instVars : [
		'membershipSelector'
	],
	#category : #'Etoys-Squeakland-Tools-Changes'
}

{ #category : #queries }
ChangeSetCategory >> acceptsManualAdditions [
	"Answer whether the user is allowed manually to manipulate the contents of the change-set-category."

	^ false
]

{ #category : #queries }
ChangeSetCategory >> changeSetList [
	"Answer the list of change-set names in the category"

	| aChangeSet |
	self reconstituteList.
	keysInOrder size == 0 ifTrue:
		["don't tolerate emptiness, because ChangeSorters gag when they have no change-set selected"
		aChangeSet := ChangeSet assuredChangeSetNamed: 'New Changes'.
		self elementAt: aChangeSet name put: aChangeSet].
	^ keysInOrder reversed
]

{ #category : #miscellaneous }
ChangeSetCategory >> defaultChangeSetToShow [
	"Answer the name of a change-set to show"

	^ ChangeSet current
]

{ #category : #services }
ChangeSetCategory >> fileOutAllChangeSets [
	"File out all the nonempty change sets in the current category, suppressing the checks for slips that might otherwise ensue.  Obtain user confirmation before undertaking this possibly prodigious task."

	| aList |
	aList := self elementsInOrder select: [:aChangeSet  | aChangeSet notEmpty].
	aList isEmpty ifTrue: [^ self inform: 'sorry, all the change sets in this category are empty'].
	(self confirm: 'This will result in filing out ', aList size printString, ' change set(s)
Are you certain you want to do this?') ifFalse: [^ self].

	Preferences setFlag: #checkForSlips toValue: false during: 
		[ChangeSet fileOutChangeSetsNamed: (aList collect: [:m | m name]) sort]
]

{ #category : #services }
ChangeSetCategory >> fillAggregateChangeSet [
	"Create a change-set named Aggregate and pour into it all the changes in all the change-sets of the currently-selected category"

	| aggChangeSet |
	aggChangeSet :=  ChangeSet assuredChangeSetNamed: #Aggregate.
	aggChangeSet clear.
	aggChangeSet setPreambleToSay: '"Change Set:		Aggregate
Created at ', Time now printString, ' on ', Date today printString, ' by combining all the changes in all the change sets in the category ', categoryName printString, '"'.

	(self elementsInOrder copyWithout: aggChangeSet) do:
		[:aChangeSet  | aggChangeSet assimilateAllChangesFoundIn: aChangeSet].
	Smalltalk isMorphic ifTrue: [SystemWindow wakeUpTopWindowUponStartup] 

]

{ #category : #queries }
ChangeSetCategory >> hasChangeForClassName: aClassName selector: aSelector otherThanIn: excludedChangeSet [
	"Answer whether any change set in this category, other than the excluded one, has a change marked for the given class and selector"

	self elementsInOrder do:
		[:aChangeSet |
			(aChangeSet ~~ excludedChangeSet and:
				[((aChangeSet methodChangesAtClass: aClassName) includesKey: aSelector)]) ifTrue:	[^ true]].

	^ false
]

{ #category : #queries }
ChangeSetCategory >> includesChangeSet: aChangeSet [
	"Answer whether the receiver includes aChangeSet in its retrieval list"

	^ ChangeSorter perform: membershipSelector with: aChangeSet
]

{ #category : #initialization }
ChangeSetCategory >> membershipSelector: aSelector [
	"Set the membershipSelector"

	membershipSelector := aSelector
]

{ #category : #miscellaneous }
ChangeSetCategory >> reconstituteList [
	"Clear out the receiver's elements and rebuild them"

	| newMembers |
	"First determine newMembers and check if they have not changed..."
	newMembers := ChangeSet allChangeSets select:
		[:aChangeSet | ChangeSorter perform: membershipSelector with: aChangeSet].
	(newMembers collect: [:cs | cs name]) = keysInOrder ifTrue: [^ self  "all current"].

	"Things have changed.  Need to recompute the whole category"
	self clear.
	newMembers do:
		[:aChangeSet | self fasterElementAt: aChangeSet name asSymbol put: aChangeSet] 

]
