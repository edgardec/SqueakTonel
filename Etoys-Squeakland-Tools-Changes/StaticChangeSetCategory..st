"
StaticChangeSetCategory is a user-defined change-set category that has in it only those change sets specifically placed there.
"
Class {
	#name : #StaticChangeSetCategory,
	#superclass : #ChangeSetCategory,
	#category : #'Etoys-Squeakland-Tools-Changes'
}

{ #category : #queries }
StaticChangeSetCategory >> acceptsManualAdditions [
	"Answer whether the user is allowed manually to manipulate the contents of the change-set-category."

	^ true
]

{ #category : #add }
StaticChangeSetCategory >> addChangeSet: aChangeSet [
	"Add the change set manually"

	self elementAt: aChangeSet name put: aChangeSet
]

{ #category : #queries }
StaticChangeSetCategory >> includesChangeSet: aChangeSet [
	"Answer whether the receiver includes aChangeSet in its retrieval list"

	^ elementDictionary includesKey: aChangeSet name
]

{ #category : #updating }
StaticChangeSetCategory >> reconstituteList [
	"Reformulate the list.  Here, since we have a manually-maintained list, at this juncture we only make sure change-set-names are still up to date, and we purge moribund elements"

	|  survivors |
	survivors := elementDictionary select: [:aChangeSet | aChangeSet isMoribund not].
	self clear.
	(survivors sorted: [:a :b | a name <= b name]) reverseDo:
		[:aChangeSet | self addChangeSet: aChangeSet]
]
