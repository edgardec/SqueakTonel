"
VersionsBrowser shows all the versions of a particular method, and lets you compare them, revert to selected versions, and so on.
"
Class {
	#name : #VersionsBrowser,
	#superclass : #ChangeList,
	#instVars : [
		'classOfMethod',
		'selectorOfMethod',
		'addedChangeRecord'
	],
	#category : #'Tools-Changes'
}

{ #category : #'instance creation' }
VersionsBrowser class >> browseMethod: aCompiledMethod [

	^ (self browseVersionsOf: aCompiledMethod)
		ifNotNil: [:browser |
			browser selectMethod: aCompiledMethod];
		yourself
]

{ #category : #'instance creation' }
VersionsBrowser class >> browseVersionsForClass: aClass selector: aSelector [

	^ self
		browseVersionsOf: (aClass compiledMethodAt: aSelector)
		class: aClass
		meta: aClass isMeta
		category: (aClass organization categoryOfElement: aSelector)
		selector: aSelector
]

{ #category : #'instance creation' }
VersionsBrowser class >> browseVersionsOf: aCompiledMethod [

	| methodClass methodSelector |
	methodClass := aCompiledMethod methodClass.
	methodSelector := aCompiledMethod selector.
	^ self
		browseVersionsOf: aCompiledMethod
		class: methodClass
		meta: methodClass isMeta
		category: (methodClass organization categoryOfElement: methodSelector)
		selector: methodSelector
]

{ #category : #'instance creation' }
VersionsBrowser class >> browseVersionsOf: method class: class meta: meta category: msgCategory selector: selector [ 
	^ self browseVersionsOf: method class: class meta: meta category: msgCategory selector: selector lostMethodPointer: nil
]

{ #category : #'instance creation' }
VersionsBrowser class >> browseVersionsOf: method class: class meta: meta category: msgCategory selector: selector lostMethodPointer: sourcePointer [ 
	| changeList browser |
	Cursor read showWhile:
		[changeList := (browser := self new)
			scanVersionsOf: method class: class meta: meta
			category: msgCategory selector: selector].
	changeList ifNil: [ self inform: 'No versions available'. ^nil ].

	sourcePointer ifNotNil:
		[changeList setLostMethodPointer: sourcePointer].

	self open: changeList name: 'Recent versions of ' ,
selector multiSelect: false.

	^browser
]

{ #category : #'instance creation' }
VersionsBrowser class >> timeStampFor: aSelector class: aClass reverseOrdinal: anInteger [
	"Answer the time stamp corresponding to some version of the given method, nil if none.  The reverseOrdinal parameter is interpreted as:  1 = current version; 2 = last-but-one version, etc."
	
	| method aChangeList |
	method := aClass compiledMethodAt: aSelector ifAbsent: [^ nil].
	aChangeList := self new
			scanVersionsOf: method class: aClass meta: aClass isMeta
			category: nil selector: aSelector.
	^ aChangeList ifNil: [nil] ifNotNil:
		[aChangeList list size >= anInteger
			ifTrue:
				[(aChangeList changeList at: anInteger) stamp]
			ifFalse:
				[nil]]
]

{ #category : #'instance creation' }
VersionsBrowser class >> versionCountForSelector: aSelector class: aClass [
	"Answer the number of versions known to the system for the given class and method, including the current version.  A result of greater than one means that there is at least one superseded version.  Answer zero if no logged version can be obtained."
	
	| method aChangeList |
	method := aClass compiledMethodAt: aSelector ifAbsent: [^ 0].
	aChangeList := self new
			scanVersionsOf: method class: aClass meta: aClass isMeta
			category: nil selector: aSelector.
	^ aChangeList ifNil: [0] ifNotNil: [aChangeList list size]
]

{ #category : #contents }
VersionsBrowser >> aboutToStyle: aStyler [

	"Style in source view, or when there's nothing to diff with."
	(self isModeStyleable or: [ listIndex = list size ]) ifFalse: [ ^false ].
	aStyler
		classOrMetaClass: classOfMethod;
		parseAMethod: true.
	^true
	
]

{ #category : #misc }
VersionsBrowser >> addPriorVersionsCountForSelector: aSelector ofClass: aClass to: aStream [
	"Add an annotation detailing the prior versions count.  Specially handled here for the case of a selector no longer in the system, whose prior versions are seen in a versions browser -- in this case, the inherited version of this method will not work."

	(aClass includesSelector: aSelector) ifTrue:
		[^ super addPriorVersionsCountForSelector: aSelector ofClass: aClass to: aStream].

	aStream nextPutAll: 
		((changeList size > 0
			ifTrue:
				[changeList size = 1
					ifTrue:
						['Deleted - one prior version']
					ifFalse:
						['Deleted - ', changeList size printString, ' prior versions']]
			ifFalse:
				['surprisingly, no prior versions']), self annotationSeparator)
]

{ #category : #'init & update' }
VersionsBrowser >> addedChangeRecord [
	^addedChangeRecord
]

{ #category : #'init & update' }
VersionsBrowser >> addedChangeRecord: aChangeRecord [
	addedChangeRecord := aChangeRecord.
	self reformulateList.
]

{ #category : #'init & update' }
VersionsBrowser >> changeListButtonSpecs [

	^#(
		('compare to current'
		compareToCurrentVersion
		'opens a separate window which shows the text differences between the selected version and the current version')

		('revert'
		fileInSelections
		'reverts the method to the version selected')

		('remove from changes'
		removeMethodFromChanges
		'remove this method from the current change set')

		('help'
		offerVersionsHelp
		'further explanation about use of Versions browsers')
		)
]

{ #category : #menu }
VersionsBrowser >> changeListKey: aChar from: view [
	"Respond to a Command key in the list pane. of the versions browser"

	^ self messageListKey: aChar from: view
]

{ #category : #misc }
VersionsBrowser >> classCommentIndicated [
	"Answer whether the receiver is pointed at a class comment"

	^ false
]

{ #category : #menu }
VersionsBrowser >> compareToOtherVersion [
	"Prompt the user for a reference version, then spawn a window 
	showing the diffs between the older and the newer of the current 
	version and the reference version as text."

	| change1 change2 s1 s2 |
	change1 := changeList at: listIndex ifAbsent: [ ^self ].

	change2 := ((UIManager default
				chooseFrom: (list copyWithoutIndex: listIndex)
				values: (changeList copyWithoutIndex: listIndex))) ifNil: [ ^self ].
	
	"compare earlier -> later"
	"change1 timeStamp < change2 timeStamp
		ifFalse: [ | temp | temp := change1. change1 := change2. change2 := temp ]."

	s1 := change1 string.
	s2 := change2 string.
	s1 = s2
		ifTrue: [^ self inform: 'Exact Match' translated].

	(StringHolder new
		textContents: (TextDiffBuilder
				buildDisplayPatchFrom: s1
				to: s2
				inClass: classOfMethod
				prettyDiffs: self showingPrettyDiffs))
		openLabel: (('Comparison from {1} to {2}' translated) format: { change1 stamp. change2 stamp })
]

{ #category : #'user interface' }
VersionsBrowser >> defaultWindowColor [
	^ (Color r: 0.782 g: 0.677 b: 0.9)
]

{ #category : #menu }
VersionsBrowser >> fileInSelections [ 
	super fileInSelections.
	self reformulateList
]

{ #category : #menu }
VersionsBrowser >> fileOutSelection [
	| them it file |
	them := OrderedCollection new.
	listSelections with: changeList do: 
		[:selected :item | selected ifTrue: [them add: item]].
	them size ~= 1
		ifTrue: [self inform: 'single version not selected, so nothing done']
		ifFalse:
			[it := them first.
			 file := FileStream newFileNamed: it methodClassName, (it isMetaClassChange ifTrue: [' class'] ifFalse: ['']), '-' , (it methodSelector copyReplaceAll: ':' with: '').
			 [file header; timeStamp.
			  it fileOutOn: file] ensure: [file close]]
]

{ #category : #menu }
VersionsBrowser >> findOriginalChangeSet [
	| changeSet |
	self currentChange ifNil: [^ self].
	changeSet := self currentChange originalChangeSetForSelector: self selectedMessageName.
	changeSet = #sources ifTrue:
		[^ self inform: 'This version is in the .sources file.'].
	changeSet ifNil:
		[^ self inform: 'This version was not found in any changeset nor in the .sources file.'].
	(ChangeSorter new myChangeSet: changeSet) open
]

{ #category : #'user interface' }
VersionsBrowser >> initialExtent [

	"adopt the extent so that the revert button fits in"
	^650@400
]

{ #category : #menu }
VersionsBrowser >> listSelectionVersionsMenu: aMenu [
	"Fill aMenu with menu items appropriate to the receiver"
	<versionsMenu>

	listIndex > 0 ifTrue:[
		(list size > 1 ) ifTrue: [ aMenu addTranslatedList: #(
			('compare to current'		compareToCurrentVersion		'compare selected version to the current version')
			('compare to version...'	compareToOtherVersion		'compare selected version to another selected version'))].
		"Note: Revert to selected should be visible for lists of length one for having the ability to revert to an accidentally deleted method"
		 aMenu addTranslatedList: #(
			('revert to selected version'	fileInSelections					'resubmit the selected version, so that it becomes the current version') 
			('fileOut selected version'	fileOutSelection					'file out the selected version') )].
	^ aMenu
]

{ #category : #menu }
VersionsBrowser >> mainVersionsMenu: aMenu [
	"Fill aMenu with menu items appropriate to the receiver"
	<versionsMenu>

	aMenu addTranslatedList: #(
		('remove from changes'		removeMethodFromChanges	'remove this method from the current change set, if present')
		('find original change set'	findOriginalChangeSet			'locate the changeset which originally contained this version')
		-
		('toggle diffing (D)'			toggleDiffing					'toggle whether or not diffs should be shown here')
		('update list'				reformulateList					'reformulate the list of versions, in case it somehow got out of synch with reality')
		-
		('senders (n)'				browseSenders					'browse all senders of this selector')
		('implementors (m)'			browseImplementors			'browse all implementors of this selector')
		('inheritance (i)'		methodHierarchy			'browse method inheritance')
		-
		('help...'					offerVersionsHelp				'provide an explanation of the use of this tool')).
											
	^aMenu
]

{ #category : #toolbuilder }
VersionsBrowser >> optionalButtonPairs [

	^ #(('revert' fileInSelections 'resubmit the selected version, so that it becomes the current version')) , super optionalButtonPairs
]

{ #category : #'init & update' }
VersionsBrowser >> reformulateList [
	| aMethod |
	"Some uncertainty about how to deal with lost methods here"
	aMethod := classOfMethod compiledMethodAt: selectorOfMethod ifAbsent: [^ self].
	
	self scanVersionsOf: aMethod class: classOfMethod theNonMetaClass meta: classOfMethod isMeta category: (classOfMethod whichCategoryIncludesSelector: selectorOfMethod) selector: selectorOfMethod.
	self changed: #list. "for benefit of mvc"
	listIndex := 1.
	self changed: #listIndex.
	self contentsChanged

]

{ #category : #menu }
VersionsBrowser >> removeMethodFromChanges [
	"Remove my method from the current change set"

	ChangeSet current removeSelectorChanges: selectorOfMethod class: classOfMethod.
	self changed: #annotation

]

{ #category : #'init & update' }
VersionsBrowser >> scanVersionsOf: method class: class meta: meta category: category selector: selector [
	| position prevPos prevFileIndex preamble tokens sourceFilesCopy stamp cat |
	selectorOfMethod := selector.
	currentCompiledMethod := method.
	classOfMethod := meta ifTrue: [class class] ifFalse: [class].
	cat := category ifNil: [''].
	changeList := OrderedCollection new.
	list := OrderedCollection new.
	self addedChangeRecord ifNotNil: [ :change |
		self addItem: change text: ('{1} (in {2})' translated format: { change stamp. change fileName }) ].
	listIndex := 0.
	position := method filePosition.
	sourceFilesCopy := SourceFiles collect:
		[:x | x isNil ifTrue: [ nil ]
				ifFalse: [x readOnlyCopy]].
	method fileIndex = 0 ifTrue: [^ nil].
	file := sourceFilesCopy at: method fileIndex.

	[position notNil & file notNil]
		whileTrue:
		[preamble := method getPreambleFrom: file at: (0 max: position - 3).

		"Preamble is likely a linked method preamble, if we're in
			a changes file (not the sources file).  Try to parse it
			for prior source position and file index"
		prevPos := nil.
		stamp := ''.
		(preamble findString: 'methodsFor:' startingAt: 1) > 0
			ifTrue: [tokens := Scanner new scanTokens: preamble]
			ifFalse: [tokens := Array new  "ie cant be back ref"].
		((tokens size between: 7 and: 8)
			and: [(tokens at: tokens size - 5) = #methodsFor:])
			ifTrue:
				[(tokens at: tokens size - 3) = #stamp:
				ifTrue: ["New format gives change stamp and unified prior pointer"
						stamp := tokens at: tokens size - 2.
						prevPos := tokens last.
						prevFileIndex := sourceFilesCopy fileIndexFromSourcePointer: prevPos.
						prevPos := sourceFilesCopy filePositionFromSourcePointer: prevPos]
				ifFalse: ["Old format gives no stamp; prior pointer in two parts"
						prevPos := tokens at: tokens size - 2.
						prevFileIndex := tokens last].
				cat := tokens at: tokens size - 4.
				(prevPos = 0 or: [prevFileIndex = 0]) ifTrue: [prevPos := nil]].
		((tokens size between: 5 and: 6)
			and: [(tokens at: tokens size - 3) = #methodsFor:])
			ifTrue:
				[(tokens at: tokens size - 1) = #stamp:
				ifTrue: ["New format gives change stamp and unified prior pointer"
						stamp := tokens at: tokens size].
				cat := tokens at: tokens size - 2].
 		self addItem:
				(ChangeRecord new file: file position: position type: #method
						class: class name category: cat meta: meta stamp: stamp)
			text: stamp , ' ' , class name , (meta ifTrue: [' class '] ifFalse: [' ']) , selector, ' {', cat, '}'.
		position := prevPos.
		prevPos notNil ifTrue:
			[file := sourceFilesCopy at: prevFileIndex]].
	sourceFilesCopy do: [:x | x notNil ifTrue: [x close]].
	listSelections := Array new: list size withAll: false
]

{ #category : #menu }
VersionsBrowser >> selectMethod: aCompiledMethod [

	self toggleListIndex: (self changeList indexOf: (
		self changeList detect: [:change |
			change stamp = aCompiledMethod timeStamp and: [
				change string = aCompiledMethod getSource asString]]))
]

{ #category : #misc }
VersionsBrowser >> selectedClass [
	"Answer the class currently selected in the browser.  In the case of a VersionsBrowser, the class and selector are always the same, regardless of which version is selected and indeed whether or not any entry is selected in the list pane"

	^ classOfMethod theNonMetaClass
]

{ #category : #misc }
VersionsBrowser >> selectedClassOrMetaClass [
	"Answer the class or metaclass currently selected in the browser.  In the case of a VersionsBrowser, the class and selector are always the same, regardless of which version is selected and indeed whether or not any entry is selected in the list pane"

	^ classOfMethod
]

{ #category : #misc }
VersionsBrowser >> selectedMessageName [
	"Answer the message name currently selected in the browser.  In the case of a VersionsBrowser, the class and selector are always the same, regardless of which version is selected and indeed whether or not any entry is selected in the list pane"

	^ selectorOfMethod
]

{ #category : #misc }
VersionsBrowser >> showsVersions [
	^ true
]

{ #category : #menu }
VersionsBrowser >> titleVersionsMenu: aMenu [
	"Add a menu title atop aMenu"
	<versionsMenu>
	<menuPriority: 100>
	aMenu title: 'Versions' translated.
	aMenu addStayUpItemSpecial.
	^ aMenu
]

{ #category : #'viewing access' }
VersionsBrowser >> toggleListIndex: newListIndex [

	listIndex ~= 0 ifTrue: [listSelections at: listIndex put: false].
	newListIndex ~= 0 ifTrue: [listSelections at: newListIndex put: true].
	
	super toggleListIndex: newListIndex.
]

{ #category : #'init & update' }
VersionsBrowser >> updateListsAndCodeIn: aWindow [
	| aMethod |
	aMethod := classOfMethod compiledMethodAt: selectorOfMethod ifAbsent: [^ false].
	aMethod == currentCompiledMethod
		ifFalse:
			["Do not attempt to formulate if there is no source pointer.
			It probably means it has been recompiled, but the source hasn't been written
			(as during a display of the 'save text simply?' confirmation)."
			aMethod last ~= 0 ifTrue: [self reformulateList]].
	^ true

]

{ #category : #menu }
VersionsBrowser >> versionFrom: secsSince1901 [
	
	"Return changeRecord of the version in effect at that time.  Accept in the VersionsBrowser does not use this code."

	changeList do: [:cngRec | | vTime strings |
		(strings := cngRec stamp findTokens: ' ') size > 2 ifTrue: [
				vTime := strings second asDate asSeconds + 
							strings third asTime asSeconds.
				vTime <= secsSince1901 ifTrue: ["this one"
					^ cngRec == changeList first ifTrue: [nil] ifFalse: [cngRec]]]].
	"was not defined that early.  Don't delete the method."
	^ changeList last	"earliest one may be OK"	
]

{ #category : #menu }
VersionsBrowser >> versionsHelpString [
	^ 'Each entry in the list pane represents a version of the source code for the same method; the topmost entry is the current version, the next entry is the next most recent, etc.

To revert to an earlier version, select it (in the list pane) and then do any of the following:
  *  Choose "revert to this version" from the list pane menu.
  *  Hit the "revert" button,
  *  Type ENTER in the code pane
  *  Type cmd-s (alt-s) in the code pane.

The code pane shows the source for the selected version.  If "diffing" is in effect, then differences betwen the selected version and the version before it are pointed out in the pane.  Turn diffing on and off by choosing "toggle diffing" from the list pane menu, or hitting the "diffs" button, or hitting cmd-D when the cursor is over the list pane.

To get a comparison between the selected version and the current version, choose "compare to current" from the list pane menu or hit the "compare to current" button.  (This is meaningless if the current version is selected, and is unnecessary if you''re interested in diffs from between the current version and the next-most-recent version, since the standard in-pane "diff" feature will give you that.)

You can also compare the selected version with any other version using the "compare to version..." menu choice.

If further versions of the method in question have been submitted elsewhere since you launched a particular Versions Browser, it will still stay nicely up-to-date if you''re in Morphic and have asked that smart updating be maintained; if you''re in mvc or in morphic but with smart-updating turned off, a versions browser is only brought up to date when you activate its window (and when you issue "revert" from within it, of course,) and you can also use the "update list" command to make certain the versions list is up to date.

Hit the "remove from changes" button, or choose the corresponding command in the list pane menu, to have the method in question deleted from the current change set.  This is useful if you''ve put debugging code into a method, and now want to strip it out and cleanse your current change set of all memory of the excursion.

Note:  the annotation pane in versions browsers shows information about the *current* version of the method in the image, not about the selected version.'
]

{ #category : #menu }
VersionsBrowser >> versionsMenu: aMenu [

	^ self menu: aMenu for: #(versionsMenu versionsMenuShifted:)

]
