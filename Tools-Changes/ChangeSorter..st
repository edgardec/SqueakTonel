"
I display a ChangeSet.  Two of me are in a DualChangeSorter.

aStringOrNil
Instance Variables
	currentClassName:		<aStringOrNil>
	currentSelector:		<aStringOrNil>
	myChangeSet:		<aChangeSet>
	parent:		<aDualChangeSorterOrNil>
	priorChangeSetList:		<aCollection>


currentClassName
	- string parseable into class-name [class] [class trait]
	needs to be fitlered by (self withoutItemAnnotation: currentClassName) to remove pakaging note


currentSelector
	- string parseable into selector-name 
	needs to be fitlered by (self withoutItemAnnotation: currentSelector) to remove pakaging note

myChangeSet
	- name of current changeset
parent
	-the dual changesorter that contains this one. Used for dealing with the other half.
priorChangeSetList
	- holds the current change set list. Used to detect changes in list when a newly generated list no long match the prior list.
	
"
Class {
	#name : #ChangeSorter,
	#superclass : #CodeHolder,
	#instVars : [
		'parent',
		'myChangeSet',
		'currentClassName',
		'currentSelector',
		'priorChangeSetList'
	],
	#category : #'Tools-Changes'
}

{ #category : #browse }
ChangeSorter class >> browseChangeSetsWithClass: class selector: selector [
	"Put up a menu comprising a list of change sets that hold changes for the given class and selector.  If the user selects one, open a single change-sorter onto it"

	| hits index |
	hits := ChangeSet allChangeSets select: 
		[:cs | (cs atSelector: selector class: class) ~~ #none].
	hits isEmpty ifTrue: [^ self inform: class name, '.', selector , '
is not in any change set'].
	index := hits size = 1
		ifTrue:	[1]
		ifFalse:	[(UIManager default chooseFrom: (hits collect: [:cs | cs name])
					lines: #())].
	index = 0 ifTrue: [^ self].
	(ChangeSorter new myChangeSet: (hits at: index)) open.

]

{ #category : #browse }
ChangeSorter class >> browseChangeSetsWithSelector: aSelector [
	"Put up a list of all change sets that contain an addition, deletion, or change of any method with the given selector"

	| hits index |
	hits := ChangeSet allChangeSets select: 
		[:cs | cs hasAnyChangeForSelector: aSelector].
	hits isEmpty ifTrue: [^ self inform: aSelector , '
is not in any change set'].
	index := hits size = 1
		ifTrue:	[1]
		ifFalse:	[(UIManager default chooseFrom: (hits collect: [:cs | cs name])
					lines: #())].
	index = 0 ifTrue: [^ self].
	(ChangeSetBrowser new myChangeSet: (hits at: index)) open

"ChangeSorter browseChangeSetsWithSelector: #clearPenTrails"

]

{ #category : #'class initialization' }
ChangeSorter class >> initialize [
	"ChangeSorter initialize"

	FileServices registerFileReader: self.

	self registerInFlapsRegistry.

]

{ #category : #'instance creation' }
ChangeSorter class >> open [
	"Open a new instance of the receiver's class"

	self new open
]

{ #category : #browse }
ChangeSorter class >> prototypicalToolWindow [
	"Answer a window representing a prototypical instance of the receiver"

	^ToolBuilder build: self new
]

{ #category : #'class initialization' }
ChangeSorter class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#ChangeSorter.		#prototypicalToolWindow.		'Change Set'	 translatedNoop. 'A tool that allows you to view and manipulate all the code changes in a single change set' translatedNoop}
						forFlapNamed: 'Tools']
]

{ #category : #'initialize-release' }
ChangeSorter class >> unload [
	"Unload the receiver from global registries"

	self environment at: #FileServices ifPresent: [:cl |
		cl unregisterFileReader: self].
	self environment at: #Flaps ifPresent: [:cl |
		cl unregisterQuadsWithReceiver: self] 
]

{ #category : #'code pane' }
ChangeSorter >> aboutToStyle: aStyler [
	"This is a notification that aStyler is about to re-style its text.
	Set the classOrMetaClass in aStyler, so that identifiers
	will be resolved correctly.
	Answer true to allow styling to proceed, or false to veto the styling"

	self isModeStyleable ifFalse: [^false].
	self currentSelector ifNil: [^false].
	aStyler classOrMetaClass: self selectedClassOrMetaClass.
	^true
]

{ #category : #'changeSet menu' }
ChangeSorter >> addPreamble [
	myChangeSet assurePreambleExists.
	self okToChange ifTrue:
		[currentClassName := nil.
		currentSelector := nil.
		self showChangeSet: myChangeSet]
]

{ #category : #annotation }
ChangeSorter >> addPriorVersionsCountForSelector: aSelector ofClass: aClass to: aStream [
	"Add an annotation detailing the prior versions count.  Specially handled here for the case of a selector no longer in the system, whose prior version is pointed to by the lost-method pointer in the change held on to by the changeset"

	(aClass includesSelector: aSelector) ifTrue:
		[^ super addPriorVersionsCountForSelector: aSelector ofClass: aClass to: aStream].
	aStream nextPutAll:
		((myChangeSet methodInfoFromRemoval: {aClass name. aSelector})
			ifNil:
				['no prior versions']
			ifNotNil:
				['version(s) retrievable here']), self annotationSeparator
]

{ #category : #annotation }
ChangeSorter >> annotationForPackageforSelector: aSelector ofClass: aClass [ 
	"Provide a line of content for an annotation pane, representing 
	information about the given selector and class"
	"requestList"
	| aCategory |
	aClass ifNil: [ ^nil].
	aSelector ifNotNil:
		[ aCategory := aClass organization categoryOfElement: aSelector.
		(aCategory notNil and: [ aCategory first = $* ]) 
			ifTrue: [^ aCategory asString]] .
	
	"Ok. So the selector category does not indicate our package. We defer to the class category"
	^ aClass category asString.
	
]

{ #category : #'class list' }
ChangeSorter >> basicClassList [
	"Computed.  View should try to preserve selections, even though index changes"

	^ myChangeSet ifNotNil: [myChangeSet changedClassNames] ifNil: [OrderedCollection new]

]

{ #category : #'message list' }
ChangeSorter >> basicMessageList [ 

	| probe newSelectors className |
	currentClassName ifNil: [^ #()].
	className := (self withoutItemAnnotation: currentClassName) .
	probe := (className endsWith: ' class')
		ifTrue: [className]
		ifFalse: [className asSymbol].
	newSelectors := myChangeSet selectorsInClass: probe.
	(newSelectors includes: (self selectedMessageName)) 
		ifFalse: [currentSelector := nil].
	^ newSelectors sort

]

{ #category : #annotation }
ChangeSorter >> beginNote [
"return the string at the beginning of item annotation"
^' {'

]

{ #category : #'changeSet menu' }
ChangeSorter >> browseChangeSet [
	"Open a message list browser on the new and changed methods in the current change set"

	ChangedMessageSet openFor: myChangeSet


]

{ #category : #'changeSet menu' }
ChangeSorter >> browseMethodConflicts [
	"Check to see if any other change set also holds changes to any methods in the selected change set; if so, open a browser on all such."

	| aList |

	aList := myChangeSet 
		messageListForChangesWhich: [ :aClass :aSelector |
			(ChangesOrganizer allChangeSetsWithClass: aClass selector: aSelector) size > 1
		]
		ifNone: [^ self inform: 'No other change set has changes
for any method in this change set.'].
	
	ToolSet
		browseMessageSet: aList 
		name: 'Methods in "', myChangeSet name, '" that are also in other change sets (', aList size printString, ')'
		autoSelect: nil
]

{ #category : #'message list' }
ChangeSorter >> browseVersions [
	"Create and schedule a changelist browser on the versions of the 
	selected message."
	| class selector method category pair sourcePointer |

	(selector := self selectedMessageName) ifNil: [^ self].
	class := self selectedClassOrMetaClass.
	(class includesSelector: selector)
		ifTrue: [method := class compiledMethodAt: selector.
				category := class whichCategoryIncludesSelector: selector.
				sourcePointer := nil]
		ifFalse: [pair := myChangeSet methodInfoFromRemoval: {class name. selector}.
				pair ifNil: [^ nil].
				sourcePointer := pair first.
				method := CompiledMethod toReturnSelfTrailerBytes:
					(CompiledMethodTrailer new sourcePointer: sourcePointer).
				category := pair last].
	VersionsBrowser
		browseVersionsOf: method
		class: self selectedClass meta: class isMeta
		category: category selector: selector
		lostMethodPointer: sourcePointer.

]

{ #category : #toolbuilder }
ChangeSorter >> buildWith: builder [
	"
		ToolBuilder open: ChangeSorter.
	"
	|  windowSpec |
	windowSpec := builder pluggableWindowSpec new.
	windowSpec label: 'Change Sorter'.
	windowSpec model: self.
	windowSpec children: OrderedCollection new.
	windowSpec label: #labelString.
	self buildWith: builder in: windowSpec rect: (0@0 extent: 1@1).
	^builder build: windowSpec
]

{ #category : #toolbuilder }
ChangeSorter >> buildWith: builder in: window rect: rect [
	| csListHeight msgListHeight csMsgListHeight listSpec textSpec |
	contents := ''.
	csListHeight := 0.25.
	msgListHeight := 0.25.
	csMsgListHeight := csListHeight + msgListHeight.

	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #changeSetList; 
		getSelected: #currentCngSet; 
		setSelected: #showChangeSetNamed:; 
		menu: #changeSetMenu:shifted:; 
		keyPress: #changeSetListKey:from:;
		dragItem: #dragChangeSet:;
		autoDeselect: false;
		frame: (((0@0 extent: 0.5@csListHeight)
			scaleBy: rect extent) translateBy: rect origin).
	window children add: listSpec.

	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #classList; 
		getSelected: #currentClassName; 
		setSelected: #currentClassName:; 
		menu: #classListMenu:shifted:; 
		keyPress: #classListKey:from:;
		dragItem: #dragClass:;
		frame: (((0.5@0 extent: 0.5@csListHeight)
			scaleBy: rect extent) translateBy: rect origin).
	window children add: listSpec.

	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #messageList; 
		getSelected: #currentSelector;
		setSelected: #currentSelector:; 
		menu: #messageMenu:shifted:; 
		keyPress: #messageListKey:from:;
		dragItem: #dragMessage:;
		frame: (((0@csListHeight extent: 1@msgListHeight)
			scaleBy: rect extent) translateBy: rect origin).
	window children add: listSpec.

	textSpec := builder pluggableTextSpec new.
	textSpec 
		model: self;
		getText: #contents; 
		setText: #contents:notifying:; 
		selection: #contentsSelection; 
		menu: #codePaneMenu:shifted:;
		frame: (((0@csMsgListHeight corner: 1@1) scaleBy: rect extent) translateBy: rect origin).
	window children add: textSpec.
	^window
]

{ #category : #access }
ChangeSorter >> changeSet [
	^ myChangeSet
]

{ #category : #'changeSet menu' }
ChangeSorter >> changeSetCategories [

	^ ChangesOrganizer changeSetCategories
]

{ #category : #access }
ChangeSorter >> changeSetCurrentlyDisplayed [
	^ myChangeSet
]

{ #category : #'changeSet menu' }
ChangeSorter >> changeSetList [
	"Answer a list of ChangeSet names to be shown in the change sorter."

	^ChangeSet allChangeSets reverse collect: [:cs | cs name]
]

{ #category : #'changeSet menu' }
ChangeSorter >> changeSetListKey: aChar from: view [
	"Respond to a Command key.  I am a model with a listView that has a list of changeSets."

	aChar == $b ifTrue: [^ self browseChangeSet].
	aChar == $B ifTrue: [^ self openChangeSetBrowser].
	aChar == $c ifTrue: [^ self copyAllToOther].
	aChar == $D ifTrue: [^ self toggleDiffing]. 
	aChar == $f ifTrue: [^ self findCngSet].
	aChar == $m ifTrue: [^ self newCurrent].
	aChar == $n ifTrue: [^ self newSet].
	aChar == $o ifTrue: [^ self fileOut].
	aChar == $p ifTrue: [^ self addPreamble].
	aChar == $r ifTrue: [^ self rename].
	aChar == $x ifTrue: [^ self remove].
	aChar == $- ifTrue: [^ self subtractOtherSide].

	^ self messageListKey: aChar from: view
]

{ #category : #'changeSet menu' }
ChangeSorter >> changeSetMenu: aMenu shifted: isShifted [ 

	^ self menu: aMenu for: #( changeSetMenu changeSetMenuShifted: ) shifted: isShifted

]

{ #category : #'changeSet menu' }
ChangeSorter >> changeSetMenuForDropInClassCats: aMenu [
	
	aMenu add: 'remove contained in class categories...' action: #removeContainedInClassCategories.
	aMenu balloonTextForLastItem: ' Drops any changes in given class categories'.

	^ aMenu

]

{ #category : #'changeSet menu' }
ChangeSorter >> changeSetMenuForModification: aMenu [

	aMenu addLine.

	aMenu add: 'file into new...' action: #fileIntoNewChangeSet.
	aMenu balloonTextForLastItem: 
'Load a fileout from disk and place its changes into a new change set (seldom needed -- much better to do this from a file-list browser these days.)'.

	aMenu add: 'reorder all change sets' action: #reorderChangeSets.
	aMenu balloonTextForLastItem:
'Applies a standard reordering of all change-sets in the system -- at the bottom will come the sets that come with the release; next will come all the numbered updates; finally, at the top, will come all other change sets'.


	^ aMenu
]

{ #category : #'changeSet menu' }
ChangeSorter >> changeSetMenuForOpposite: aMenu [

	parent ifNotNil:
		[aMenu add: 'conflicts with change set opposite' action: #methodConflictsWithOtherSide.
			aMenu balloonTextForLastItem: 
'Browse all methods that occur both in this change set and in the one on the opposite side of the change sorter.'.].
	^ aMenu
]

{ #category : #'changeSet menu' }
ChangeSorter >> changeSetMenuForPromote: aMenu [

	aMenu add: 'promote to top of list' action: #promoteToTopChangeSet.
	aMenu balloonTextForLastItem:
'Make this change set appear first in change-set lists in all change sorters.'.

	^ aMenu
]

{ #category : #'changeSet menu' }
ChangeSorter >> checkForAlienAuthorship [
	"Open a message list browser on all uncommented methods in the current change set that have alien authorship"

	myChangeSet checkForAlienAuthorship


]

{ #category : #'changeSet menu' }
ChangeSorter >> checkForAnyAlienAuthorship [
	"Open a message list browser on all uncommented methods in the current change set that have alien authorship, even historically"

	myChangeSet checkForAnyAlienAuthorship


]

{ #category : #'changeSet menu' }
ChangeSorter >> checkForUnclassifiedMethods [
	"Open a message list browser on all methods in the current change set that have not been categorized"

	myChangeSet checkForUnclassifiedMethods


]

{ #category : #'changeSet menu' }
ChangeSorter >> checkForUncommentedClasses [
	"Open a class list browser on classes in the change set that lack class comments"

	myChangeSet checkForUncommentedClasses
]

{ #category : #'changeSet menu' }
ChangeSorter >> checkForUncommentedMethods [
	"Open a message list browser on all uncommented methods in the current change set"

	myChangeSet checkForUncommentedMethods


]

{ #category : #'changeSet menu' }
ChangeSorter >> checkForUnsentMessages [
	"Open a message list browser on all unsent messages in the current change set"

	myChangeSet checkForUnsentMessages


]

{ #category : #'changeSet menu' }
ChangeSorter >> checkThatSidesDiffer: escapeBlock [
	"If the change sets on both sides of the dual sorter are the same, put up an error message and escape via escapeBlock, else proceed happily"

	parent ifNil: [^ escapeBlock value].  "Not relevant unless in dual change sorter."

	(myChangeSet == (parent other: self) changeSet)
		ifTrue:
			[self inform: 
'This command requires that the
change sets selected on the two
sides of the change sorter *not*
be the same.' translated.
			^ escapeBlock value]

]

{ #category : #'changeSet menu' }
ChangeSorter >> chooseCngSet [
	"Present the user with an alphabetical list of change set names, and let her choose one"

	| changeSetsSortedAlphabetically chosen |
	self okToChange ifFalse: [^ self].

	changeSetsSortedAlphabetically := self changeSetList sorted:
		[:a :b | a asLowercase withoutLeadingDigits < b asLowercase withoutLeadingDigits].

	chosen := UIManager default chooseFrom: changeSetsSortedAlphabetically values: changeSetsSortedAlphabetically.
	chosen ifNil: [^ self].
	self showChangeSet: (ChangesOrganizer changeSetNamed: chosen)
]

{ #category : #'class list' }
ChangeSorter >> classList [
	"return the classlist with package note appended."
	
	^ self basicClassList collect: [: each | 
		each asString, (self packageNoteForClass: (Smalltalk classNamed: each) selector: nil) ] .
]

{ #category : #'class list' }
ChangeSorter >> classListKey: aChar from: view [
	"Respond to a Command key in the class-list pane."

	aChar == $x ifTrue: [^ self removeClass].
	aChar == $d ifTrue: [^ self forgetClass]. 

	^ self messageListKey: aChar from: view "picks up b,h,p"
]

{ #category : #'class list' }
ChangeSorter >> classListMenu: aMenu shifted: shifted [
	"Fill aMenu with items appropriate for the class list"
	^ self menu: aMenu for: #(classListMenu classListMenuShifted:) shifted: shifted

]

{ #category : #'class list' }
ChangeSorter >> classMenu: aMenu [
	"Set up aMenu for the class-list.  Retained for backward compatibility with old change sorters in image segments"

	^ self classListMenu: aMenu shifted: false
]

{ #category : #'class list' }
ChangeSorter >> classMenu: aMenu shifted: shifted [
	"Fill aMenu with items appropriate for the class list.  Retained for bkwd compatibility"

	^ self classListMenu: aMenu shifted: shifted
]

{ #category : #'changeSet menu' }
ChangeSorter >> clearChangeSet [
	"Clear out the current change set, after getting a confirmation."
	| message |

	self okToChange ifFalse: [^ self].
	myChangeSet isEmpty ifFalse:
		[message := 'Are you certain that you want to\forget all the changes in this set?' withCRs.
		(self confirm: message) ifFalse: [^ self]].
	myChangeSet clear.
	self changed: #classList.
	self changed: #messageList.
	self setContents.
	self contentsChanged.

]

{ #category : #'code pane' }
ChangeSorter >> contents: aString notifying: aController [ 
	"Compile the code in aString. Notify aController of any syntax errors. 
	Create an error if the category of the selected message is unknown. 
	Answer false if the compilation fails. Otherwise, if the compilation 
	created a new method, deselect the current selection. Then answer true."
	| category selector class oldSelector |

	(class := self selectedClassOrMetaClass) ifNil:
		[(myChangeSet preambleString == nil or: [aString size = 0]) ifTrue: [ ^ false].
		(aString count: [:char | char == $"]) odd 
			ifTrue: [self inform: 'unmatched double quotes in preamble']
			ifFalse: [(Scanner new scanTokens: aString) size > 0 ifTrue: [
				self inform: 'Part of the preamble is not within double-quotes.
To put a double-quote inside a comment, type two double-quotes in a row.
(Ignore this warning if you are including a doIt in the preamble.)']].
		myChangeSet preambleString: aString.
		self currentSelector: nil.  "forces update with no 'unsubmitted chgs' feedback"
		^ true].
	oldSelector := self selectedMessageName.
	category := class organization categoryOfElement: oldSelector.
	selector := class compile: aString
				classified: category
				notifying: aController.
	selector ifNil: [^ false].
	(self messageList includes: selector)
		ifTrue: [self currentSelector: selector]
		ifFalse: [self currentSelector: oldSelector].
	self update.
	^ true
]

{ #category : #'changeSet menu' }
ChangeSorter >> copyAllToOther [
	"Copy this entire change set into the one on the other side"
	| companionSorter |
	self checkThatSidesDiffer: [^ self].
	(companionSorter := parent other: self) changeSetCurrentlyDisplayed assimilateAllChangesFoundIn: myChangeSet.
	companionSorter changed: #classList.	"Later the changeSet itself will notice..."
	companionSorter changed: #messageList
]

{ #category : #'class list' }
ChangeSorter >> copyClassToOther [
	"Place these changes in the other changeSet also"

	| otherSorter otherChangeSet |
	self checkThatSidesDiffer: [^ self].
	self okToChange ifFalse: [^ Beeper beep].
	currentClassName ifNil: [^ Beeper beep].
	otherSorter := parent other: self.
	otherChangeSet := otherSorter changeSet.

	otherChangeSet absorbClass: self selectedClassOrMetaClass name from: myChangeSet.
	otherSorter showChangeSet: otherChangeSet.
]

{ #category : #'message list' }
ChangeSorter >> copyMethodToOther [
	"Place this change in the other changeSet also"
	| other cls sel |
	self checkThatSidesDiffer: [^ self].
	currentSelector ifNotNil:
		[other := (parent other: self) changeSet.
		cls := self selectedClassOrMetaClass.
		sel := self selectedMessageName.

		other absorbMethod: sel class: cls from: myChangeSet.
		(parent other: self) showChangeSet: other]

]

{ #category : #'class list' }
ChangeSorter >> currentClassName [

	^ currentClassName
]

{ #category : #'class list' }
ChangeSorter >> currentClassName: aString [

	currentClassName := aString.
	currentSelector := nil.	"fix by wod"
	self changed: #currentClassName.
	self changed: #messageList.
	self setContents.
	self contentsChanged.
]

{ #category : #'changeSet menu' }
ChangeSorter >> currentCngSet [
	^ myChangeSet name
]

{ #category : #'message list' }
ChangeSorter >> currentSelector [

	^ currentSelector
]

{ #category : #'message list' }
ChangeSorter >> currentSelector: messageName [

	currentSelector := messageName.
	self changed: #currentSelector.
	self setContents.
	self contentsChanged.
]

{ #category : #'user interface' }
ChangeSorter >> defaultWindowColor [
	^ (Color r: 0.719 g: 0.9 b: 0.9)
]

{ #category : #dragging }
ChangeSorter >> dragChangeSet: anIndex [

	anIndex = 0 ifTrue: [^ nil].
	^ ChangesOrganizer changeSetNamed: (self changeSetList at: anIndex) 
]

{ #category : #dragging }
ChangeSorter >> dragClass: anIndex [

	anIndex = 0 ifTrue: [^ nil].
	^ (Smalltalk classNamed: (self basicClassList at: anIndex)) classReference
]

{ #category : #dragging }
ChangeSorter >> dragMessage: anIndex [

	anIndex = 0 ifTrue: [^ nil].
	^ MethodReference
		class: self selectedClassOrMetaClass
		selector: (self basicMessageList at: anIndex)
]

{ #category : #'changeSet menu' }
ChangeSorter >> editPostscript [
	"Allow the user to edit the receiver's change-set's postscript -- in a separate window"

	myChangeSet editPostscript
]

{ #category : #'changeSet menu' }
ChangeSorter >> editPreamble [
	"Allow the user to edit the receiver's change-set's preamble -- in a separate window."

	myChangeSet editPreamble
]

{ #category : #annotation }
ChangeSorter >> endNote [
"return the string at the beginning of item annotation"
^'}'

]

{ #category : #'changeSet menu' }
ChangeSorter >> expungeUniclasses [
	"remove all memory of uniclasses in the receiver"

	self okToChange ifFalse: [^ self].
	myChangeSet expungeUniclasses.
	self changed: #classList.
	self changed: #messageList.


]

{ #category : #'changeSet menu' }
ChangeSorter >> fileIntoNewChangeSet [
	"Obtain a file designation from the user, and file its contents into a  
	new change set whose name is a function of the filename. Show the  
	new set and leave the current changeSet unaltered."
	self okToChange
		ifFalse: [^ self].
	ChangeSet promptForDefaultChangeSetDirectoryIfNecessary.
	
	(FileChooserDialog openOn: ChangeSet defaultChangeSetDirectory) ifNotNil: 
		[:fileName | 	
		FileStream oldFileNamed: fileName do: 
			[:stream | | localName |
			localName := FileDirectory localNameFor: fileName.
			(ChangeSet newChangesFromStream: stream named: localName)
				ifNotNil: [:aNewChangeSet | self showChangeSet: aNewChangeSet]]].
]

{ #category : #'changeSet menu' }
ChangeSorter >> fileOut [
	"File out the current change set."

	myChangeSet fileOut.
	parent modelWakeUp.	"notice object conversion methods created"

]

{ #category : #'class list' }
ChangeSorter >> fileOutClass [
	"this is a hack!! makes a new change set, called the class name, adds author initials to try to make a unique change set name, files it out and removes it. kfr 16 june 2000" 
	| aSet |
	"File out the selected class set."
     aSet := ChangeSet newChangeSet: (self withoutItemAnnotation: currentClassName).
	aSet absorbClass: self selectedClassOrMetaClass name from: myChangeSet.
	aSet fileOut.
	ChangeSet removeChangeSet: aSet.
	parent modelWakeUp.	"notice object conversion methods created"


]

{ #category : #'changeSet menu' }
ChangeSorter >> findCngSet [ 
	"Search for a changeSet by name.  Pop up a menu of all changeSets whose name contains the string entered by the user.  If only one matches, then the pop-up menu is bypassed"
	| index pattern candidates nameList |
	self okToChange ifFalse: [^ self].
	pattern := UIManager default request: 'ChangeSet name or fragment?'.
	pattern isEmpty ifTrue: [^ self].
	nameList := self changeSetList asSet.
	candidates := ChangeSet allChangeSets select:
			[:c | (nameList includes: c name) and: 
				[c name includesSubstring: pattern caseSensitive: false]].
	candidates size = 0 ifTrue: [^ Beeper beep].
	candidates size = 1 ifTrue:
		[^ self showChangeSet: candidates first].
	index := UIManager default chooseFrom: (candidates collect: [:each | each name]).
	index = 0 ifFalse: [self showChangeSet: (candidates at: index)].

]

{ #category : #'message list' }
ChangeSorter >> forget [
	"Drop this method from the changeSet"

	self okToChange ifFalse: [^ self].
	currentSelector ifNotNil: [
		myChangeSet removeSelectorChanges: self selectedMessageName 
			class: self selectedClassOrMetaClass.
		currentSelector := nil.
		self showChangeSet: myChangeSet]
]

{ #category : #'class list' }
ChangeSorter >> forgetClass [
	"Remove all mention of this class from the changeSet.
	 After forgetting, select at the same point in the class
	 list, which helps if e.g. doing something repetitive such
	 as moving a number of classes to the other side."
	| index classList |
	self okToChange ifFalse: [^ self].
	currentClassName ifNil: [^self].
	index := self classList indexOf: currentClassName.
	myChangeSet removeClassChanges: (self withoutItemAnnotation: currentClassName).
	currentSelector := nil.
	classList := self classList.
	currentClassName := classList isEmpty ifFalse:
								[classList at: (index min: classList size)].
	self showChangeSet: myChangeSet
]

{ #category : #'changeSet menu' }
ChangeSorter >> goToChangeSetsProject [
	"Transport the user to a project which bears the selected changeSet as its current changeSet"

	| aProject |
	(aProject := myChangeSet correspondingProject) 
		ifNotNil:
			[aProject enter: false revert: false saveForRevert: false]
		ifNil:
			[self inform: 'Has no project']
]

{ #category : #initialize }
ChangeSorter >> initialize [
	super initialize.
	myChangeSet := ChangeSet current.
]

{ #category : #'changeSet menu' }
ChangeSorter >> inspectChangeSet [
	"Open a message list browser on the new and changed methods in the current change set"

	myChangeSet inspectWithLabel: 'Change set: ', myChangeSet name


]

{ #category : #access }
ChangeSorter >> label [
	^ self labelString
]

{ #category : #access }
ChangeSorter >> labelString [
	"The label for my entire window.  The large button that displays my name is gotten via mainButtonName"

	^ String streamContents:
		[:aStream |
			aStream nextPutAll: (ChangeSet current == myChangeSet
				ifTrue: ['Changes go to "', myChangeSet name, '"']
				ifFalse: ['ChangeSet: ', myChangeSet name])]
]

{ #category : #'changeSet menu' }
ChangeSorter >> lookForSlips [
	"Open a message list browser on the new and changed methods in the current change set"

	myChangeSet lookForSlips


]

{ #category : #'changeSet menu' }
ChangeSorter >> mailOut [
	"Create a mail with a gzipped attachment holding out the current change 
	set. "
	myChangeSet mailOut.
	parent modelWakeUp
]

{ #category : #'changeSet menu' }
ChangeSorter >> mainButtonName [

	^ myChangeSet name
]

{ #category : #'class list' }
ChangeSorter >> mainClassListMenu: aMenu [
	"Fill aMenu with items appropriate for the class list"

	<classListMenuShifted: false>
	aMenu title: 'class list'.
	aMenu addStayUpItemSpecial.
	parent ifNotNil: [
		aMenu addList: #( "These two only apply to dual change sorters"
			('copy class chgs to other side'			copyClassToOther)	
			('move class chgs to other side'			moveClassToOther))].

	aMenu addList: #(
			-
			('delete class from change set (d)'		forgetClass)
			('remove class from system (x)'			removeClass)
			-
			('browse full (b)'						browseMethodFull)
			('browse hierarchy (h)'					spawnHierarchy)
			('browse protocol (p)'					browseFullProtocol)
			-
			('printOut'								printOutClass)
			('fileOut'								fileOutClass)
			-
			('references... (r)'						browseVariableReferences)
			('assignments... (a)'						browseVariableAssignments)
			('class refs (N)'							browseClassRefs)
			-
			('more...'								offerShiftedClassListMenu)).

	^ aMenu
]

{ #category : #'message list' }
ChangeSorter >> messageList [ 
	| thisClass organization |
	(thisClass := self selectedClassOrMetaClass) ifNil: [^ #() ] .
	organization := thisClass organization.
	^self basicMessageList collect: [ :each |
		each asString , (self noteString: (organization categoryOfElement: each))].

]

{ #category : #'class list' }
ChangeSorter >> messageListKey: aChar from: view [
	"Respond to a Command key in the message-list pane."

	aChar == $d ifTrue: [^ self forget].
	super messageListKey: aChar from: view
]

{ #category : #'message list' }
ChangeSorter >> messageListMenu: aMenu shifted: shifted [
	"Fill aMenu with items appropriate for the message list; could be for a single or double changeSorter"

	^ self messageMenu: aMenu shifted: shifted
]

{ #category : #'message list' }
ChangeSorter >> messageMenu: aMenu shifted: shifted [
	"Fill aMenu with items appropriate for the message list; could be for a single or double changeSorter"

	^ self menu: aMenu for: #(messageListMenu messageListMenuShifted:) shifted: shifted
]

{ #category : #'changeSet menu' }
ChangeSorter >> methodConflictsWithOtherSide [
	"Check to see if the change set on the other side shares any methods with the selected change set; if so, open a browser on all such."

	| aList other |

	self checkThatSidesDiffer: [^ self].
	other := (parent other: self) changeSet.
	aList := myChangeSet 
		messageListForChangesWhich: [ :aClass :aSelector |
			aClass notNil and: [(other methodChangesAtClass: aClass name) includesKey: aSelector]
		]
		ifNone:  [^ self inform: 'There are no methods that appear
both in this change set and
in the one on the other side.'].
	
	ToolSet 
		browseMessageSet: aList 
		name: 'Methods in "', myChangeSet name, '" that are also in ', other name,' (', aList size printString, ')'
		autoSelect: nil
]

{ #category : #access }
ChangeSorter >> modelWakeUp [
	"A window with me as model is being entered.
	Make sure I am up-to-date with the changeSets."

	self canDiscardEdits ifTrue: [self update]
]

{ #category : #'class list' }
ChangeSorter >> moveClassToOther [
	"Place class changes in the other changeSet and remove them from this one"

	self checkThatSidesDiffer: [^ self].
	(self okToChange and: [currentClassName notNil]) ifFalse: [^ Beeper beep].

	self copyClassToOther.
	self forgetClass
]

{ #category : #'message list' }
ChangeSorter >> moveMethodToOther [
	"Place this change in the other changeSet and remove it from this side"

	| other cls sel |
	self checkThatSidesDiffer: [^self].
	self okToChange ifFalse: [^Beeper beep].
	currentSelector ifNotNil: 
			[other := (parent other: self) changeSet.
			other == myChangeSet ifTrue: [^Beeper  beep].
			cls := self selectedClassOrMetaClass.
			sel := self selectedMessageName.
			other 
				absorbMethod: sel
				class: cls
				from: myChangeSet.
			(parent other: self) showChangeSet: other.
			self forget	"removes the method from this side"]
]

{ #category : #access }
ChangeSorter >> myChangeSet: anObject [
	myChangeSet := anObject
]

{ #category : #'changeSet menu' }
ChangeSorter >> newCurrent [
	"make my change set be the current one that changes go into"

	ChangeSet  newChanges: myChangeSet.
	self update.  "Because list of changes in a category may thus have changed"
	self changed: #relabel.
]

{ #category : #'changeSet menu' }
ChangeSorter >> newSet [
	"Create a new changeSet and show it., making it the current one.  Reject name if already in use."

	| aSet |
	self okToChange ifFalse: [^ self].
	aSet := ChangeSet newChangeSet.
	aSet ifNotNil:[
		self update.
		self showChangeSet: aSet.
		self changed: #relabel]
]

{ #category : #annotation }
ChangeSorter >> noteString: aString [
^ self beginNote , aString asString , self endNote
]

{ #category : #'changeSet menu' }
ChangeSorter >> offerShiftedChangeSetMenu [
	"Offer the shifted version of the change set menu"

	self offerMenuFrom: #changeSetMenu:shifted: shifted: true
]

{ #category : #'changeSet menu' }
ChangeSorter >> offerUnshiftedChangeSetMenu [
	"Offer the unshifted version of the change set menu"

	self offerMenuFrom: #changeSetMenu:shifted: shifted: false
]

{ #category : #creation }
ChangeSorter >> open [
	"ChangeSorterPluggable new open"
	^ToolBuilder open: self
]

{ #category : #'changeSet menu' }
ChangeSorter >> openChangeSetBrowser [
	"Open a ChangeSet browser on the current change set"
	ToolBuilder open: (ChangeSetBrowser new myChangeSet: myChangeSet)
]

{ #category : #annotation }
ChangeSorter >> packageNoteForClass: aClass selector: aSelector [ 
"return the category name that represents the package name for aClass>>aSelector.
when selector is nil or in a normal catagory return "
| package |
package := (self annotationForPackageforSelector: aSelector
			ofClass: aClass) ifNil: ['<class was deleted???>'] .

^ self noteString: package







]

{ #category : #access }
ChangeSorter >> parent [
	^ parent
]

{ #category : #access }
ChangeSorter >> parent: anObject [
	parent := anObject
]

{ #category : #'changeSet menu' }
ChangeSorter >> promoteToTopChangeSet [
	"Move the selected change-set to the top of the list"

	ChangeSet promoteToTop: myChangeSet.
	(parent ifNil: [self]) modelWakeUp
]

{ #category : #'changeSet menu' }
ChangeSorter >> remove [
	"Completely destroy my change set.  Check if it's OK first"

	self okToChange ifFalse: [^ self].
	self removePrompting: true.
	self update
]

{ #category : #'changeSet menu' }
ChangeSorter >> removeContainedInClassCategories [
	| matchExpression |
	myChangeSet removePreamble.
	matchExpression :=  UIManager default request: 'Enter class category name (wildcard is ok)' initialAnswer: 'System-*'. 
	(Smalltalk organization categories
		select: [:each | matchExpression match: each])
		do: [:eachCat | 
			| classNames | 
			classNames := Smalltalk organization listAtCategoryNamed: eachCat.
			classNames
				do: [:eachClassName | 
					myChangeSet removeClassChanges: eachClassName.
					myChangeSet removeClassChanges: eachClassName , ' class'].
			self showChangeSet: myChangeSet]
]

{ #category : #'message list' }
ChangeSorter >> removeFromCurrentChanges [
	"Redisplay after removal in case we are viewing the current changeSet"

	super removeFromCurrentChanges.
	currentSelector := nil.
	self showChangeSet: myChangeSet
]

{ #category : #'message list' }
ChangeSorter >> removeMessage [
	"Remove the selected msg from the system. Real work done by the 
	parent, a ChangeSorter"
	| confirmation sel |
	self okToChange
		ifFalse: [^ self].
	currentSelector
		ifNotNil: [confirmation := self systemNavigation   confirmRemovalOf: (sel := self selectedMessageName) on: self selectedClassOrMetaClass.
			confirmation = 3
				ifTrue: [^ self].
			self selectedClassOrMetaClass removeSelector: sel.
			self update.
			confirmation = 2
				ifTrue: [self systemNavigation browseAllCallsOn: sel]]
]

{ #category : #'changeSet menu' }
ChangeSorter >> removePostscript [
	(myChangeSet hasPostscript and: [myChangeSet postscriptHasDependents]) ifTrue:
		[^ self inform:
'Cannot remove the postscript right
now because there is at least one
window open on that postscript.
Close that window and try again.'].

	myChangeSet removePostscript.
	self showChangeSet: myChangeSet
]

{ #category : #'changeSet menu' }
ChangeSorter >> removePreamble [
	myChangeSet removePreamble.
	self showChangeSet: myChangeSet
]

{ #category : #'changeSet menu' }
ChangeSorter >> removePrompting: doPrompt [
	"Completely destroy my change set.  Check if it's OK first, and if doPrompt is true, get the user to confirm his intentions first."

	| message aName changeSetNumber msg |
	aName := myChangeSet name.
	myChangeSet okayToRemove ifFalse: [^ self]. "forms current changes for some project"
	(myChangeSet isEmpty or: [doPrompt not]) ifFalse:
		[message := 'Are you certain that you want to 
remove (destroy) the change set
named  "', aName, '" ?'.
		(self confirm: message) ifFalse: [^ self]].

	doPrompt ifTrue:
		[msg := myChangeSet hasPreamble
			ifTrue:
				[myChangeSet hasPostscript
					ifTrue:
						['a preamble and a postscript']
					ifFalse:
						['a preamble']]
			ifFalse:
				[myChangeSet hasPostscript
					ifTrue:
						['a postscript']
					ifFalse:
						['']].
		msg isEmpty ifFalse:
			[(self confirm: 
'Caution!  This change set has
', msg, ' which will be
lost if you destroy the change set.
Do you really want to go ahead with this?') ifFalse: [^ self]]].

	"Go ahead and remove the change set"
	changeSetNumber := myChangeSet name initialIntegerOrNil.
	changeSetNumber ifNotNil: [SystemVersion current unregisterUpdate: changeSetNumber].
	ChangesOrganizer removeChangeSet: myChangeSet.
	self changed: #changeSetList.
	self showChangeSet: ChangeSet current.
]

{ #category : #'changeSet menu' }
ChangeSorter >> rename [
	"Store a new name string into the selected ChangeSet.  reject duplicate name; allow user to back out"

	| newName |
	newName := UIManager default request: 'New name for this change set'
						initialAnswer: myChangeSet name.
	(newName = myChangeSet name or: [newName size = 0]) ifTrue:
			[^ Beeper beep].

	(ChangeSet named: newName) ifNotNil:
			[^ UIManager default inform: 'Sorry that name is already used'].

	myChangeSet name: newName.
	self update.
	self changed: #mainButtonName.
	self changed: #relabel.
]

{ #category : #'changeSet menu' }
ChangeSorter >> reorderChangeSets [
	"apply a standard reordering -- let the class handle this"

	^ ChangesOrganizer reorderChangeSets
]

{ #category : #'class list' }
ChangeSorter >> selectedClass [
	"Answer the currently-selected class.  If there is no selection, or if the selection refers to a class no longer extant, return nil"
	| c |
	^ currentClassName ifNotNil: [(c := self selectedClassOrMetaClass)
		ifNotNil: [c theNonMetaClass]]
]

{ #category : #traits }
ChangeSorter >> selectedClassOrMetaClass [
	"Careful, the class may have been removed!"

	| cName tName className |
	currentClassName ifNil: [^ nil].
	className := (self withoutItemAnnotation: currentClassName) .
	(className endsWith: ' class')
		ifTrue: [cName := (className copyFrom: 1 to: className size-6) asSymbol.
				^ (Smalltalk at: cName ifAbsent: [^nil]) class].
	(currentClassName endsWith: ' classTrait')
		ifTrue: [tName := (className copyFrom: 1 to: className size-11) asSymbol.
				^ (Smalltalk at: tName ifAbsent: [^nil]) classTrait].
	cName := className asSymbol.
	^ Smalltalk at: cName ifAbsent: [nil]
]

{ #category : #'message list' }
ChangeSorter >> selectedMessageName [

	currentSelector ifNil: [^ nil].
	^ (self withoutItemAnnotation: currentSelector) asSymbol
]

{ #category : #'code pane' }
ChangeSorter >> setContents [
	"return the source code that shows in the bottom pane"

	| sel class strm changeType | 
	self clearUserEditFlag.
	myChangeSet ifNil: [^ contents := String empty].   "should not happen but can"
	currentClassName ifNil: [^ contents := myChangeSet preambleString ifNil: [String empty]].
	class := self selectedClassOrMetaClass.
	(sel := self selectedMessageName) == nil
		ifFalse: [changeType := (myChangeSet atSelector: (sel := sel asSymbol) class: class).
			changeType == #remove
				ifTrue: [^ contents := 'Method has been removed (see versions)'].
			changeType == #addedThenRemoved
				ifTrue: [^ contents := 'Added then removed (see versions)'].
			class ifNil: [^ contents := 'Method was added, but cannot be found!'].
			(class includesSelector: sel)
				ifFalse: [^ contents := 'Method was added, but cannot be found!'].
			contents := class sourceCodeAt: sel.
			(#(prettyPrint prettyDiffs) includes: contentsSymbol) ifTrue:
				[contents :=  class prettyPrinterClass
					format: contents in: class notifying: nil].
			self showingAnyKindOfDiffs
				ifTrue: [contents := self diffFromPriorSourceFor: contents].
			^ contents := contents asText makeSelectorBoldIn: class]
		ifTrue: [strm := WriteStream on: (String new: 100).
			(myChangeSet classChangeAt: (self withoutItemAnnotation: currentClassName)) do:
				[:each |
				each = #remove ifTrue: [strm nextPutAll: 'Entire class was removed.'; cr].
				each = #addedThenRemoved ifTrue: [strm nextPutAll: 'Class was added then removed.'].
				each = #rename ifTrue: [strm nextPutAll: 'Class name was changed.'; cr].
				each = #add ifTrue: [strm nextPutAll: 'Class definition was added.'; cr].
				each = #change ifTrue: [strm nextPutAll: 'Class definition was changed.'; cr].
				each = #reorganize ifTrue: [strm nextPutAll: 'Class organization was changed.'; cr].
				each = #comment ifTrue: [strm nextPutAll: 'New class comment.'; cr.
				]].
			^ contents := strm contents].
]

{ #category : #'changeSet menu' }
ChangeSorter >> setRecentUpdatesMarker [
	"Allow the user to change the recent-updates marker"

	| result |
	result := UIManager default request: 
('Enter the lowest change-set number
that you wish to consider "recent"?
(note: highest change-set number
in this image at this time is ', ChangeSet highestNumberedChangeSet asString, ')') initialAnswer: ChangesOrganizer recentUpdateMarker recentUpdateMarker asString.
	(result notNil and: [result startsWithDigit]) ifTrue:
		[ChangesOrganizer recentUpdateMarker: result asInteger.
		Smalltalk isMorphic ifTrue: [SystemWindow wakeUpTopWindowUponStartup]]
]

{ #category : #'changeSet menu' }
ChangeSorter >> shiftedChangeSetMenu: aMenu [
	"Set up aMenu to hold items relating to the change-set-list pane when the shift key is down"

	<changeSetMenuShifted: true>

	aMenu title: 'Change set (shifted)'.
	aMenu addStayUpItemSpecial.

	"CONFLICTS SECTION"
	aMenu add: 'conflicts with other change sets' action: #browseMethodConflicts.
	aMenu balloonTextForLastItem: 
'Browse all methods that occur both in this change set and in at least one other change set.'.
	self changeSetMenuForOpposite: aMenu.
	aMenu addLine.

	"CHECKS SECTION"
	aMenu add: 'check for slips' action: #lookForSlips.
	aMenu balloonTextForLastItem: 
'Check this change set for halts and references to Transcript.'.

	aMenu add: 'check for unsent messages' action: #checkForUnsentMessages.
	aMenu balloonTextForLastItem:
'Check this change set for messages that are not sent anywhere in the system'.

	aMenu add: 'check for uncommented methods' action: #checkForUncommentedMethods.
	aMenu balloonTextForLastItem:
'Check this change set for methods that do not have comments'.

	aMenu add: 'check for uncommented classes' action: #checkForUncommentedClasses.
	aMenu balloonTextForLastItem:
'Check for classes with code in this changeset which lack class comments'.

	Utilities authorInitialsPerSe isEmptyOrNil ifFalse:
		[aMenu add: 'check for other authors' action: #checkForAlienAuthorship.
		aMenu balloonTextForLastItem:
'Check this change set for methods whose current authoring stamp does not start with "', Utilities authorInitials, '"'.

	aMenu add: 'check for any other authors' action: #checkForAnyAlienAuthorship.
	aMenu balloonTextForLastItem:
'Check this change set for methods any of whose authoring stamps do not start with "', Utilities authorInitials, '"'].

	aMenu add: 'check for uncategorized methods' action: #checkForUnclassifiedMethods.
	aMenu balloonTextForLastItem:
'Check to see if any methods in the selected change set have not yet been assigned to a category.  If any are found, open a browser on them.'.
	aMenu addLine.

	aMenu add: 'inspect change set' action: #inspectChangeSet.
	aMenu balloonTextForLastItem: 
'Open an inspector on this change set. (There are some details in a change set which you don''t see in a change sorter.)'.

	aMenu add: 'update' action: #update.
	aMenu balloonTextForLastItem: 
'Update the display for this change set.  (This is done automatically when you activate this window, so is seldom needed.)'.

	aMenu add: 'go to change set''s project' action: #goToChangeSetsProject.
	aMenu balloonTextForLastItem: 
'If this change set is currently associated with a Project, go to that project right now.'.

	self changeSetMenuForPromote: aMenu.

	aMenu add: 'trim history' action: #trimHistory.
	aMenu balloonTextForLastItem: 
' Drops any methods added and then removed, as well as renaming and reorganization of newly-added classes.  NOTE: can cause confusion if later filed in over an earlier version of these changes'.

	self changeSetMenuForDropInClassCats: aMenu.
	
	aMenu add: 'clear this change set' action: #clearChangeSet.
	aMenu balloonTextForLastItem: 
'Reset this change set to a pristine state where it holds no information. CAUTION: this is destructive and irreversible!'.
	aMenu add: 'expunge uniclasses' action: #expungeUniclasses.
	aMenu balloonTextForLastItem:
'Remove from the change set all memory of uniclasses, e.g. classes added on behalf of etoys, fabrik, etc., whose classnames end with a digit.'.

	aMenu add: 'uninstall this change set' action: #uninstallChangeSet.
	aMenu balloonTextForLastItem: 
'Attempt to uninstall this change set. CAUTION: this may not work completely and is irreversible!'.

	self changeSetMenuForModification: aMenu.

	aMenu addLine.

	aMenu add: 'more...' action: #offerUnshiftedChangeSetMenu.
	aMenu balloonTextForLastItem: 
'Takes you back to the primary change-set menu.'.

	^ aMenu
]

{ #category : #'class list' }
ChangeSorter >> shiftedClassListMenu: aMenu [
	"Fill aMenu with items appropriate for the class list"
	<classListMenuShifted: true>

	aMenu title: 'class list'.
	aMenu addStayUpItemSpecial.

	aMenu addList: #(
			-
			('unsent methods'						browseUnusedMethods)
			('unreferenced inst vars'				showUnreferencedInstVars)
			('unreferenced class vars'				showUnreferencedClassVars)
			-
			('sample instance'						makeSampleInstance)
			('inspect instances'						inspectInstances)
			('inspect subinstances'					inspectSubInstances)
			-
			('more...'								offerUnshiftedClassListMenu )).

	^ aMenu
]

{ #category : #'message list' }
ChangeSorter >> shiftedMessageMenu: aMenu [
	"Arm the menu so that it holds items appropriate to the message-list while the shift key is down.  Answer the menu."
	<messageListMenuShifted: true>
	^ aMenu addList: #(
		-
		('toggle diffing (D)'					toggleDiffing)
		('implementors of sent messages'		browseAllMessages)
		('change category...'				changeCategory)
			-
		('sample instance'					makeSampleInstance)
		('inspect instances'					inspectInstances)
		('inspect subinstances'				inspectSubInstances)
		-
		('change sets with this method'		findMethodInChangeSets)
		('revert to previous version'			revertToPreviousVersion)
		('revert & remove from changes'	revertAndForget));
	yourself

]

{ #category : #access }
ChangeSorter >> showChangeSet: chgSet [

	myChangeSet == chgSet ifFalse: [
		myChangeSet := chgSet.
		currentClassName := nil.
		currentSelector := nil].
	self changed: #relabel.
	self changed: #currentCngSet.	"new -- list of sets"
	self changed: #mainButtonName.	"old, button"
	self changed: #classList.
	self changed: #messageList.
	self setContents.
	self contentsChanged.
]

{ #category : #access }
ChangeSorter >> showChangeSetNamed: aName [

	self showChangeSet: (ChangesOrganizer changeSetNamed: aName) 
]

{ #category : #'changeSet menu' }
ChangeSorter >> submergeIntoOtherSide [
	"Copy the contents of the receiver to the other side, then remove the receiver -- all after checking that all is well."
	| other message nextToView i all |
	self checkThatSidesDiffer: [^ self].
	self okToChange ifFalse: [^ self].
	other := (parent other: self) changeSet.
	other == myChangeSet ifTrue: [^ self inform: 'Both sides are the same!'].
	myChangeSet isEmpty ifTrue: [^ self inform: 'Nothing to copy.  To remove,
simply choose "remove".'].

	myChangeSet okayToRemove ifFalse: [^ self].
	message := 'Please confirm:  copy all changes
in "', myChangeSet name, '" into "', other name, '"
and then destroy the change set
named "', myChangeSet name, '"?'.
 
	(self confirm: message) ifFalse: [^ self].

	(myChangeSet hasPreamble or: [myChangeSet hasPostscript]) ifTrue:
		[(self confirm: 
'Caution!  This change set has a preamble or
a postscript or both.  If you submerge it into
the other side, these will be lost.
Do you really want to go ahead with this?') ifFalse: [^ self]].

	other assimilateAllChangesFoundIn: myChangeSet.
	all := ChangeSet allChangeSets.
	nextToView := ((all includes: myChangeSet)
		and: [(i := all indexOf: myChangeSet) < all size])
		ifTrue: [all at: i+1]
		ifFalse: [other].

	self removePrompting: false.
	self showChangeSet: nextToView.
	parent modelWakeUp.

]

{ #category : #'changeSet menu' }
ChangeSorter >> subtractOtherSide [
	"Subtract the changes found on the other side from the requesting side."
	self checkThatSidesDiffer: [^ self].
	myChangeSet forgetAllChangesFoundIn: ((parent other: self) changeSet).
	self showChangeSet: myChangeSet
]

{ #category : #'code pane' }
ChangeSorter >> toggleDiffing [
	"Toggle whether diffs should be shown in the code pane"

	self okToChange ifTrue:
		[super toggleDiffing.
		self changed: #contents.
		self update]


]

{ #category : #'changeSet menu' }
ChangeSorter >> trimHistory [
	"Drop non-essential history (rename, reorg, method removals) from newly-added classes."

	myChangeSet trimHistory


]

{ #category : #'changeSet menu' }
ChangeSorter >> uninstallChangeSet [
	"Attempt to uninstall the current change set, after confirmation."

	self okToChange ifFalse: [^ self].
	(self confirm: 'Uninstalling a changeSet is unreliable at best.
It will only work if the changeSet consists only of single
changes, additions and removals of methods, and if
no subsequent changes have been to any of them.
No changes to classes will be undone.
The changeSet will be cleared after uninstallation.
Do you still wish to attempt to uninstall this changeSet?')
	ifFalse: [^ self].

	myChangeSet uninstall.
	self changed: #relabel.
	self changed: #classList.
	self changed: #messageList.
	self setContents.
	self contentsChanged.

]

{ #category : #'changeSet menu' }
ChangeSorter >> unshiftedChangeSetMenu: aMenu [
	"Set up aMenu to hold commands for the change-set-list pane.  This could be for a single or double changeSorter"
	<changeSetMenuShifted: false>
	Smalltalk isMorphic
		ifTrue:
			[aMenu title: 'Change Set']
		ifFalse:
			[aMenu title: 'Change Set:
' , myChangeSet name].
	aMenu addStayUpItemSpecial.

	aMenu add: 'make changes go to me (m)' action: #newCurrent.
	aMenu addLine.
	aMenu add: 'new change set... (n)' action: #newSet.
	aMenu add: 'find...(f)' action: #findCngSet.
	aMenu add: 'select change set...' action: #chooseCngSet.
	aMenu addLine.
	aMenu add: 'rename change set (r)' action: #rename.
	aMenu add: 'file out (o)' action: #fileOut.
	aMenu add: 'mail to list' action: #mailOut.
	aMenu add: 'browse methods (b)' action: #browseChangeSet.
	aMenu add: 'browse change set (B)' action: #openChangeSetBrowser.
	aMenu addLine.
	parent
		ifNotNil: 
			[aMenu add: 'copy all to other side (c)' action: #copyAllToOther.
			aMenu add: 'submerge into other side' action: #submergeIntoOtherSide.
			aMenu add: 'subtract other side (-)' action: #subtractOtherSide.
			aMenu addLine].
	myChangeSet hasPreamble
		ifTrue: 
			[aMenu add: 'edit preamble (p)' action: #addPreamble.
			aMenu add: 'remove preamble' action: #removePreamble]
		ifFalse: [aMenu add: 'add preamble (p)' action: #addPreamble].
	myChangeSet hasPostscript
		ifTrue: 
			[aMenu add: 'edit postscript...' action: #editPostscript.
			aMenu add: 'remove postscript' action: #removePostscript]
		ifFalse: [aMenu add: 'add postscript...' action: #editPostscript].
	aMenu addLine.

	aMenu add: 'destroy change set (x)' action: #remove.
	aMenu addLine.
	aMenu add: 'more...' action: #offerShiftedChangeSetMenu.
	^ aMenu
]

{ #category : #'message list' }
ChangeSorter >> unshiftedMessageMenu: aMenu [
	"Fill aMenu with items appropriate for the message list; could be for a single or double changeSorter"

	<messageListMenuShifted: false>

	aMenu title: 'message list'.
	aMenu addStayUpItemSpecial.

	parent ifNotNil:
		[aMenu addList: #(
			('copy method to other side'			copyMethodToOther)
			('move method to other side'			moveMethodToOther))].

	aMenu addList: #(
			('delete method from changeSet (d)'	forget)
			-
			('remove method from system (x)'	removeMessage)
				-
			('browse full (b)'					browseMethodFull)
			('browse hierarchy (h)'				spawnHierarchy)
			('browse protocol (p)'				browseFullProtocol)
			-
			('fileOut'							fileOutMessage)
			('printOut'							printOutMessage)
			-
			('senders of... (n)'					browseSendersOfMessages)
			('implementors of... (m)'				browseMessages)
			('inheritance (i)'					methodHierarchy)
			('versions (v)'						browseVersions)).
	^ aMenu

]

{ #category : #'changeSet menu' }
ChangeSorter >> update [
	"recompute all of my panes"

	self updateIfNecessary.
	parent ifNotNil: [(parent other: self) updateIfNecessary]
]

{ #category : #'changeSet menu' }
ChangeSorter >> updateIfNecessary [
	"Recompute all of my panes."

	| newList |
	self okToChange ifFalse: [^ self].

	myChangeSet ifNil: [^ self].  "Has been known to happen though shouldn't"
	(myChangeSet isMoribund) ifTrue:
		[self changed: #changeSetList.
		^ self showChangeSet: ChangeSet current].

	newList := self changeSetList.

	(priorChangeSetList == nil or: [priorChangeSetList ~= newList])
		ifTrue:
			[priorChangeSetList := newList.
			self changed: #changeSetList].
	self showChangeSet: myChangeSet
]

{ #category : #creation }
ChangeSorter >> veryDeepFixupWith: deepCopier [

	super veryDeepFixupWith: deepCopier.
	parent := deepCopier references at: parent ifAbsent: [parent].
	self updateIfNecessary
]

{ #category : #creation }
ChangeSorter >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared."

super veryDeepInner: deepCopier.
"parent := parent.		Weakly copied"
"myChangeSet := myChangeSet.		Weakly copied"
currentClassName := currentClassName veryDeepCopyWith: deepCopier.
"currentSelector := currentSelector.		Symbol"
priorChangeSetList := priorChangeSetList veryDeepCopyWith: deepCopier.



]

{ #category : #'code pane' }
ChangeSorter >> wantsOptionalButtons [
	"No optional buttons for ChangeSorter"
	^false
]

{ #category : #annotation }
ChangeSorter >> withoutItemAnnotation: aStringOrNil [
"return the current item without the package annotation we added on"
| endItemIndex |
aStringOrNil ifNil: [^nil] .
( endItemIndex := aStringOrNil findString: self beginNote) = 0
	ifTrue: [^ aStringOrNil ] .
^ aStringOrNil first: endItemIndex - 1
]
