"
A class-comment-versions-browser tool
"
Class {
	#name : #ClassCommentVersionsBrowser,
	#superclass : #VersionsBrowser,
	#category : #'Tools-Changes'
}

{ #category : #'instance creation' }
ClassCommentVersionsBrowser class >> browseCommentOf: class [
	Cursor read showWhile:
		[| changeList |
		changeList := self new scanVersionsOf: class.
	 	 changeList ifNil: [^ self inform: 'No versions available'].
		 self open: changeList name: 'Recent versions of ',class name,'''s comments' multiSelect: false ]

]

{ #category : #utilities }
ClassCommentVersionsBrowser class >> commentRecordsOf: aClass [
	"Return a list of ChangeRecords for all versions of the method at selector. Source code can be retrieved by sending string to any one.  Return nil if the method is absent."

	| aList |
	aList := self new
			scanVersionsOf: aClass.
	^ aList ifNotNil: [aList changeList]
]

{ #category : #utilities }
ClassCommentVersionsBrowser class >> timeStampFor: aSelector class: aClass reverseOrdinal: anInteger [
	"Answer the time stamp corresponding to some version of the given method, nil if none.  The reverseOrdinal parameter is interpreted as:  1 = current version; 2 = last-but-one version, etc."
	
	| aChangeList |
	aChangeList :=  self new scanVersionsOf: aClass.
	^ aChangeList ifNil: [nil] ifNotNil:
		[aChangeList list size >= anInteger
			ifTrue:
				[(aChangeList changeList at: anInteger) stamp]
			ifFalse:
				[nil]]
]

{ #category : #contents }
ClassCommentVersionsBrowser >> aboutToStyle: aStyler [

	^false
]

{ #category : #misc }
ClassCommentVersionsBrowser >> classCommentIndicated [
	"Answer whether the receiver is pointed at a class comment"

	^ true
]

{ #category : #menu }
ClassCommentVersionsBrowser >> compareToCurrentVersion [
	"If the current selection corresponds to a method in the system, then spawn a window showing the diffs as text"

	^ self compareToCurrentSource: classOfMethod organization classComment
]

{ #category : #misc }
ClassCommentVersionsBrowser >> contentsSymbolQuints [
	"Answer a list of quintuplets representing information on the alternative views available in the code pane"

	^ #(
(source			togglePlainSource 		showingPlainSourceString	'source'			'the textual source code as writen')
(showDiffs		toggleRegularDiffing	showingRegularDiffsString	'showDiffs'		'the textual source diffed from its prior version'))
]

{ #category : #'user interface' }
ClassCommentVersionsBrowser >> defaultWindowColor [
	^ (Color r: 0.753 g: 0.677 b: 0.9)
]

{ #category : #'basic function' }
ClassCommentVersionsBrowser >> diffedVersionContents [
	"Answer diffed version contents, maybe pretty maybe not"

	| change class earlier later |
	(listIndex = 0
			or: [changeList size < listIndex])
		ifTrue: [^ ''].
	change := changeList at: listIndex.
	later := change text.
	class := self selectedClass.
	(listIndex == changeList size or: [class == nil])
		ifTrue: [^ later].

	earlier := (changeList at: listIndex + 1) text.

	^ TextDiffBuilder buildDisplayPatchFrom: earlier to: later inClass: class prettyDiffs: self showingPrettyDiffs
]

{ #category : #menu }
ClassCommentVersionsBrowser >> listSelectionVersionsMenu: aMenu [

	^ aMenu addTranslatedList: #(
		('compare to current'		compareToCurrentVersion		'compare selected version to the current version')
		('revert to selected version'	fileInSelections					'resubmit the selected version, so that it becomes the current version'));
	yourself

]

{ #category : #menu }
ClassCommentVersionsBrowser >> offerVersionsHelp [
	(StringHolder new contents: self versionsHelpString)
		openLabel: 'Class Comment Versions Browsers'
]

{ #category : #misc }
ClassCommentVersionsBrowser >> priorSourceOrNil [
	"If the currently-selected method has a previous version, return its source, else return nil"
	| aClass aSelector  changeRecords |
	(aClass := self selectedClass) ifNil: [^ nil].
	(aSelector := self selectedMessageName) ifNil: [^ nil].
	changeRecords :=  self class commentRecordsOf: self selectedClass.
	(changeRecords == nil or: [changeRecords size <= 1]) ifTrue: [^ nil].
	^ (changeRecords at: 2) string 

]

{ #category : #'basic function' }
ClassCommentVersionsBrowser >> reformulateList [

     classOfMethod organization classComment ifNil: [^ self].

	self scanVersionsOf: classOfMethod.
	self changed: #list. "for benefit of mvc"
	listIndex := 1.
	self changed: #listIndex.
	self contentsChanged
]

{ #category : #'basic function' }
ClassCommentVersionsBrowser >> scanVersionsOf: class [ 
	"Scan for all past versions of the class comment of the given class"

	| oldCommentRemoteStr sourceFilesCopy position prevPos stamp preamble tokens prevFileIndex |

	classOfMethod := class.
	oldCommentRemoteStr := class  organization commentRemoteStr.
	currentCompiledMethod := oldCommentRemoteStr.
	selectorOfMethod := #Comment.
	changeList := OrderedCollection new.
	list := OrderedCollection new.
	listIndex := 0.
	oldCommentRemoteStr ifNil:[^ nil] ifNotNil: [oldCommentRemoteStr sourcePointer].

	sourceFilesCopy := SourceFiles collect:
		[:x | x isNil ifTrue: [ nil ]
				ifFalse: [x readOnlyCopy]].
	position := oldCommentRemoteStr position.
	file := sourceFilesCopy at: oldCommentRemoteStr sourceFileNumber.
	[position notNil & file notNil]
		whileTrue:
		[file position: (0 max: position-150).  " Skip back to before the preamble"
		[file position < (position-1)]  "then pick it up from the front"
			whileTrue: [preamble := file nextChunk].

		prevPos := nil.
		stamp := ''.
		(preamble findString: 'commentStamp:' startingAt: 1) > 0
			ifTrue: [tokens := Scanner new scanTokens: preamble.
				(tokens at: tokens size-3) = #commentStamp:
				ifTrue: ["New format gives change stamp and unified prior pointer"
						stamp := tokens at: tokens size-2.
						prevPos := tokens last.
						prevFileIndex := sourceFilesCopy fileIndexFromSourcePointer: prevPos.
						prevPos := sourceFilesCopy filePositionFromSourcePointer: prevPos]]
			ifFalse: ["The stamp get lost, maybe after a condenseChanges"
					stamp := '<historical>'].

 		self addItem:
				(ChangeRecord new file: file position: position type: #classComment
						class: class name category: nil meta: class isMeta stamp: stamp)
			text: stamp , ' ' , class name , ' class comment'. 
		prevPos = 0 ifTrue:[prevPos := nil].
		position := prevPos.
		prevPos notNil 
					ifTrue:[file := sourceFilesCopy at: prevFileIndex]].
	sourceFilesCopy do: [:x | x notNil ifTrue: [x close]].
	listSelections := Array new: list size withAll: false
]

{ #category : #misc }
ClassCommentVersionsBrowser >> selectedClass [
	"Answer the class currently selected in the browser.  In the case of a VersionsBrowser, the class and selector are always the same, regardless of which version is selected and indeed whether or not any entry is selected in the list pane"

	^ classOfMethod
]

{ #category : #'basic function' }
ClassCommentVersionsBrowser >> updateListsAndCodeIn: aWindow [
	| aComment |
	aComment := classOfMethod organization commentRemoteStr.
	aComment == currentCompiledMethod
		ifFalse:
			["Do not attempt to formulate if there is no source pointer.
			It probably means it has been recompiled, but the source hasn't been written
			(as during a display of the 'save text simply?' confirmation)."
			aComment last ~= 0 ifTrue: [self reformulateList]].
	^ true

]

{ #category : #misc }
ClassCommentVersionsBrowser >> wantsPrettyDiffOption [
	"Answer whether pretty-diffs are meaningful for this tool"

	^ false
]
