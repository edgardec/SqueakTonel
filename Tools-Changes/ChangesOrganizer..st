"
I manage ChangeSets in the system. See the protocols on my class side.

For an example of what I can do, select the following line in a Workspace and print it.


ChangesOrganizer allChangeSetNames
"
Class {
	#name : #ChangesOrganizer,
	#superclass : #Object,
	#classVars : [
		'ChangeSetNamesInRelease',
		'RecentUpdateMarker'
	],
	#category : #'Tools-Changes'
}

{ #category : #enumerating }
ChangesOrganizer class >> allChangeSetNames [
	^ ChangeSet allChangeSetNames
]

{ #category : #enumerating }
ChangesOrganizer class >> allChangeSets [
	"Return the list of all current ChangeSets"

	^ChangeSet allChangeSets
]

{ #category : #enumerating }
ChangesOrganizer class >> allChangeSetsWithClass: class selector: selector [
	
	^ ChangeSet allChangeSetsWithClass: class selector: selector
]

{ #category : #services }
ChangesOrganizer class >> assuredChangeSetNamed: aName [
	"Answer a change set of the given name.  If one already exists, answer that, else create a new one and answer it."

	^(self changeSetNamed: aName)
		ifNil:
			[self basicNewChangeSet: aName]
]

{ #category : #adding }
ChangesOrganizer class >> basicNewChangeSet: newName [
	^ChangeSet basicNewChangeSet: newName
]

{ #category : #'class initialization' }
ChangesOrganizer class >> belongsInAdditions: aChangeSet [
	"Answer whether a change set belongs in the Additions category, which is fed by all change sets that are neither numbered nor in the initial release"

	^ (((self belongsInProjectsInRelease: aChangeSet) or:
		[self belongsInNumbered: aChangeSet])) not
]

{ #category : #'class initialization' }
ChangesOrganizer class >> belongsInAll: aChangeSet [
	"Answer whether a change set belongs in the All category"

	^ true 
]

{ #category : #'class initialization' }
ChangesOrganizer class >> belongsInMyInitials: aChangeSet [
	"Answer whether a change set belongs in the MyInitials category. "

	^ aChangeSet name endsWith: ('-', Utilities authorInitials)
]

{ #category : #'class initialization' }
ChangesOrganizer class >> belongsInNumbered: aChangeSet [
	"Answer whether a change set belongs in the Numbered category. "

	^  aChangeSet name startsWithDigit
]

{ #category : #'class initialization' }
ChangesOrganizer class >> belongsInProjectChangeSets: aChangeSet [
	"Answer whether a change set belongs in the MyInitials category. "

	^ aChangeSet belongsToAProject
]

{ #category : #'class initialization' }
ChangesOrganizer class >> belongsInProjectsInRelease:  aChangeSet [
	"Answer whether a change set belongs in the ProjectsInRelease category.  You can hand-tweak this to suit your working style.  This just covers the space of project names in the 2.9, 3.0, and 3.1a systems"

	| aString |
	^ ((aString := aChangeSet name) beginsWith: 'Play With Me') or: [self changeSetNamesInReleaseImage includes: aString]
]

{ #category : #'class initialization' }
ChangesOrganizer class >> belongsInRecentUpdates: aChangeSet [
	"Answer whether a change set belongs in the RecentUpdates category."

	^ aChangeSet name startsWithDigit and:
			[aChangeSet name asInteger >= self recentUpdateMarker]
]

{ #category : #services }
ChangesOrganizer class >> buildAggregateChangeSet [
	
	^ ChangeSet buildAggregateChangeSet
]

{ #category : #enumerating }
ChangesOrganizer class >> changeSet: aChangeSet containsClass: aClass [
	| theClass |
	theClass := Smalltalk classNamed: aClass.
	theClass ifNil: [^ false].
	^ aChangeSet containsClass: theClass
]

{ #category : #enumerating }
ChangesOrganizer class >> changeSetNamed: aName [
	"Return the change set of the given name, or nil if none found.  1/22/96 sw"
	^ChangeSet named: aName
]

{ #category : #'class initialization' }
ChangesOrganizer class >> changeSetNamesInReleaseImage [
	"Answer a list of names of project change sets that come pre-shipped in the latest sytem release.  On the brink of shipping a new release, call 'ChangeSorter noteChangeSetsInRelease'  "

	^ ChangeSetNamesInRelease ifNil:
		[ChangeSetNamesInRelease := self changeSetNamesInThreeOh]
]

{ #category : #'class initialization' }
ChangesOrganizer class >> changeSetNamesInThreeOh [
	"Hard-coded: answer a list of names of project change sets that came pre-shipped in Squeak 3.0"

	^ #('The Worlds of Squeak' 'Fun with Morphic' 'Games' 'Fun With Music' 'Building with Squeak' 'Squeak and the Internet' 'Squeak in 3D' 'More About Sound' ) 
]

{ #category : #enumerating }
ChangesOrganizer class >> changeSetsNamedSuchThat: nameBlock [
	^ChangeSet changeSetsNamedSuchThat: nameBlock
]

{ #category : #services }
ChangesOrganizer class >> countOfChangeSetsWithClass: aClass andSelector: aSelector [
	"Answer how many change sets record a change for the given class and selector"

	^ (self allChangeSetsWithClass: aClass selector: aSelector) size
]

{ #category : #removing }
ChangesOrganizer class >> deleteChangeSetsNumberedLowerThan: anInteger [
	"Delete all changes sets whose names start with integers smaller than anInteger"

	self removeChangeSetsNamedSuchThat:
		[:aName | aName first isDigit and: [aName initialIntegerOrNil < anInteger]].

	"ChangesOrganizer deleteChangeSetsNumberedLowerThan: (ChangeSorter highestNumberedChangeSet name initialIntegerOrNil - 500)"

]

{ #category : #services }
ChangesOrganizer class >> doesAnyChangeSetHaveClass: aClass andSelector: aSelector [
	"Answer whether any known change set bears a change for the given class and selector"

	^ (self countOfChangeSetsWithClass: aClass andSelector: aSelector) > 0
]

{ #category : #enumerating }
ChangesOrganizer class >> existingOrNewChangeSetNamed: aName [
	^ChangeSet existingOrNewChangeSetNamed: aName
]

{ #category : #utilities }
ChangesOrganizer class >> fileOutChangeSetsNamed: nameList [
	"File out the list of change sets whose names are provided"
     "ChangeSorter fileOutChangeSetsNamed: #('New Changes' 'miscTidies-sw')"

	| notFound empty infoString |
	notFound := OrderedCollection new.
	empty := OrderedCollection new.
	nameList do:
		[:aName | | aChangeSet | (aChangeSet := self changeSetNamed: aName)
			ifNotNil:
				[aChangeSet isEmpty
					ifTrue:
						[empty add: aName]
					ifFalse:
						[aChangeSet fileOut]]
			ifNil:
				[notFound add: aName]].

	infoString := (nameList size - notFound size) printString, ' change set(s) filed out'.
	notFound size > 0 ifTrue:
		[infoString := infoString, '

', notFound size printString, ' change set(s) not found:'.
		notFound do:
			[:aName | infoString := infoString, '
', aName]].
	empty size > 0 ifTrue:
		[infoString := infoString, '
', empty size printString, ' change set(s) were empty:'.
		empty do:
			[:aName | infoString := infoString, '
', aName]].

	self inform: infoString
]

{ #category : #enumerating }
ChangesOrganizer class >> gatherChangeSets [		"ChangeSorter gatherChangeSets"
	^ChangeSet gatherChangeSets
]

{ #category : #enumerating }
ChangesOrganizer class >> highestNumberedChangeSet [

	^ ChangeSet highestNumberedChangeSet
]

{ #category : #'class initialization' }
ChangesOrganizer class >> initialize [

	"Initialize the class variables"
	RecentUpdateMarker := 0.



]

{ #category : #enumerating }
ChangesOrganizer class >> mostRecentChangeSetWithChangeForClass: class selector: selector [
	| hits |
	hits := self allChangeSets select: 
		[:cs | (cs atSelector: selector class: class) ~~ #none].
	hits isEmpty ifTrue: [^ 'not in any change set'].
	^ 'recent cs: ', hits last name
]

{ #category : #adding }
ChangesOrganizer class >> newChangeSet [
	"Prompt the user for a name, and establish a new change set of
	that name (if ok), making it the current changeset.  Return nil
	of not ok, else return the actual changeset."

	| newName newSet |
	newName := UIManager default
		request: 'Please name the new change set:'
		initialAnswer: ChangeSet defaultName.
	newName isEmptyOrNil ifTrue:
		[^ nil].
	newSet := self basicNewChangeSet: newName.
	newSet ifNotNil:
		[ChangeSet  newChanges: newSet].
	^ newSet
]

{ #category : #adding }
ChangesOrganizer class >> newChangeSet: aName [
	"Makes a new change set called aName, add author initials to try to
	ensure a unique change set name."

	| newName |
	newName := aName , FileDirectory dot , Utilities authorInitials.
	^ self basicNewChangeSet: newName
]

{ #category : #adding }
ChangesOrganizer class >> newChangesFromStream: aStream named: aName [
	^ChangeSet newChangesFromStream: aStream named: aName

]

{ #category : #'class initialization' }
ChangesOrganizer class >> noteChangeSetsInRelease [
	"Freshly compute what the change sets in the release are; to be called manually just before a release"

	ChangeSetNamesInRelease := (Project allProjects collect: [:p | p name]) asSet asOrderedCollection.

"ChangeSorter noteChangeSetsInRelease"
]

{ #category : #enumerating }
ChangesOrganizer class >> promoteToTop: aChangeSet [
	"Make aChangeSet the first in the list from now on"
	^ChangeSet promoteToTop: aChangeSet
]

{ #category : #services }
ChangesOrganizer class >> recentUpdateMarker [
	"Answer the number representing the threshold of what counts as 'recent' for an update number.  This allow you to use the RecentUpdates category in a ChangeSorter to advantage"

	^ RecentUpdateMarker ifNil: [RecentUpdateMarker := 0]
]

{ #category : #services }
ChangesOrganizer class >> recentUpdateMarker: aNumber [
	"Set the recent update marker as indicated"

	^ RecentUpdateMarker := aNumber
]

{ #category : #removing }
ChangesOrganizer class >> removeChangeSet: aChangeSet [
	"Remove the given changeSet.  Caller must assure that it's cool to do this"
	^ChangeSet removeChangeSet: aChangeSet
]

{ #category : #removing }
ChangesOrganizer class >> removeChangeSetsNamedSuchThat: nameBlock [
	(self changeSetsNamedSuchThat: nameBlock)
		do: [:cs | self removeChangeSet: cs]
]

{ #category : #removing }
ChangesOrganizer class >> removeEmptyUnnamedChangeSets [
	"Remove all change sets that are empty, whose names start with Unnamed,
		and which are not nailed down by belonging to a Project."
	"ChangeSorter removeEmptyUnnamedChangeSets"
	| toGo |
	(toGo := (self changeSetsNamedSuchThat: [:csName | csName beginsWith: 'Unnamed'])
		select: [:cs | cs isEmpty and: [cs okayToRemoveInforming: false]])
		do: [:cs | self removeChangeSet: cs].
	self inform: toGo size printString, ' change set(s) removed.'
]

{ #category : #services }
ChangesOrganizer class >> reorderChangeSets [
	"Change the order of the change sets to something more convenient:
		First come the project changesets that come with the release.  These are mostly empty.
		Next come all numbered updates.
		Next come all remaining changesets
	In a ChangeSorter, they will appear in the reversed order."

	"ChangeSorter reorderChangeSets"

	| newHead newMid newTail |
	newHead := OrderedCollection new.
	newMid := OrderedCollection new.
	newTail := OrderedCollection new.
	ChangeSet allChangeSets do:
		[:aChangeSet |
			(self belongsInProjectsInRelease: aChangeSet)
				ifTrue:
					[newHead add: aChangeSet]
				ifFalse:
					[(self belongsInNumbered: aChangeSet)
						ifTrue:
							[newMid add: aChangeSet]
						ifFalse:
							[newTail add: aChangeSet]]].
	ChangeSet allChangeSets: newHead, newMid, newTail.
	Project current wakeUpTopWindow
]

{ #category : #services }
ChangesOrganizer class >> secondaryChangeSet [
	^ChangeSet secondaryChangeSet
]

{ #category : #'class initialization' }
ChangesOrganizer class >> unload [
	"Unload the receiver from global registries"

	self environment at: #FileServices ifPresent: [:cl |
	cl unregisterFileReader: self].
	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]
