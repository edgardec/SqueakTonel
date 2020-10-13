Class {
	#name : #MCMergeBrowser,
	#superclass : #MCOperationsBrowser,
	#instVars : [
		'conflicts',
		'merger',
		'ok'
	],
	#category : #'Monticello-UI'
}

{ #category : #'instance creation' }
MCMergeBrowser class >> resolveConflictsInMerger: aMerger [
	| inst |
	inst := self new merger: aMerger.
	^ inst showModally ifNil: [false]
]

{ #category : #ui }
MCMergeBrowser >> buttonSpecs [
	^ #((Merge merge 'Proceed with the merge' canMerge)
		 (Cancel cancel 'Cancel the merge')
		('All Newer' chooseAllNewerConflicts 'Choose all newer conflict versions')
		('All Older' chooseAllOlderConflicts 'Choose all older conflict versions')
		('Rest Reject' chooseAllUnchosenLocal 'Choose local versions of all remaining conflicts')
		('Rest Accept' chooseAllUnchosenRemote 'Choose remote versions of all remaining conflicts')
		('Accept same source' chooseAllSameAST 'Choose all local conflicting versions that have essentially the same code')
)
]

{ #category : #testing }
MCMergeBrowser >> canMerge [
	^ merger isMerged
]

{ #category : #actions }
MCMergeBrowser >> cancel [
	self answer: false
]

{ #category : #actions }
MCMergeBrowser >> chooseAllNewerConflicts [
	conflicts do: [ :ea | ea chooseNewer ].
	self changed: #text; changed: #list; changed: #canMerge.
]

{ #category : #actions }
MCMergeBrowser >> chooseAllOlderConflicts [
	conflicts do: [ :ea | ea chooseOlder ].
	self changed: #text; changed: #list; changed: #canMerge.
]

{ #category : #actions }
MCMergeBrowser >> chooseAllSameAST [
	conflicts do: [ :ea |
		ea chooseSameAST ].
	self changed: #text; changed: #list; changed: #canMerge.
]

{ #category : #actions }
MCMergeBrowser >> chooseAllUnchosenLocal [
	conflicts do: [ :ea | ea isResolved ifFalse: [ ea chooseLocal ] ].
	self changed: #text; changed: #list; changed: #canMerge.
]

{ #category : #actions }
MCMergeBrowser >> chooseAllUnchosenRemote [
	conflicts do: [ :ea | ea isResolved ifFalse: [ ea chooseRemote ] ].
	self changed: #text; changed: #list; changed: #canMerge.
]

{ #category : #actions }
MCMergeBrowser >> chooseLocal [
	self conflictSelectionDo:
		[selection chooseLocal.
		self changed: #text; changed: #list; changed: #canMerge].
	self selectNextUnresolvedConflict
]

{ #category : #actions }
MCMergeBrowser >> chooseRemote [
	self conflictSelectionDo:
		[selection chooseRemote.
		self changed: #text; changed: #list; changed: #canMerge].
	self selectNextUnresolvedConflict
]

{ #category : #actions }
MCMergeBrowser >> clearChoice [
	self conflictSelectionDo:
		[selection clearChoice.
		self changed: #text; changed: #list; changed: #canMerge]
]

{ #category : #'private-actions' }
MCMergeBrowser >> conflictSelectionDo: aBlock [
	self selectionIsConflicted
		ifTrue: aBlock
]

{ #category : #ui }
MCMergeBrowser >> defaultLabel [
	^ 'Merge Browser'
]

{ #category : #menus }
MCMergeBrowser >> getConflictMenu: aMenu [
	selection remoteChosen
		ifTrue: [aMenu add: 'undo keep change' target: self selector: #clearChoice]
		ifFalse: [aMenu add: 'keep change' target: self selector: #chooseRemote].
	selection localChosen
		ifTrue: [aMenu add: 'undo reject change' target: self selector: #clearChoice]	
		ifFalse: [aMenu add: 'reject change' target: self selector: #chooseLocal].
	^ aMenu
]

{ #category : #'morphic ui' }
MCMergeBrowser >> getMenu: aMenu [
	selection ifNil: [^ aMenu].
	^ self selectionIsConflicted
		ifTrue: [self getConflictMenu: aMenu]
		ifFalse: [self getOperationMenu: aMenu]
]

{ #category : #menus }
MCMergeBrowser >> getOperationMenu: aMenu [
	^ aMenu
]

{ #category : #'private-ui' }
MCMergeBrowser >> innerButtonRow [
	^ self buttonRow: self innerButtonSpecs
]

{ #category : #'private-ui' }
MCMergeBrowser >> innerButtonSpecs [
	^
		#((Accept chooseRemote 'Accept the selected incoming change. Overwrites local code.' )
		  (Reject chooseLocal 'Reject the selected incoming change. Retains local code.' ))
]

{ #category : #accessing }
MCMergeBrowser >> items [
	^ conflicts, super items
]

{ #category : #actions }
MCMergeBrowser >> merge [
	merger isMerged
		ifFalse: [self inform: 'You must resolve all the conflicts first']
		ifTrue: [self answer: true] 
]

{ #category : #accessing }
MCMergeBrowser >> merger: aMerger [
	merger := aMerger.
	items := aMerger operations sorted.
	conflicts := aMerger conflicts sort: [:a :b | a operation <= b operation].
]

{ #category : #menus }
MCMergeBrowser >> methodListKey: aKeystroke from: aListMorph [ 
	aKeystroke caseOf: {
		[$k] -> [self chooseRemote].
		[$r] -> [self chooseLocal]}
		 otherwise: [super methodListKey: aKeystroke from: aListMorph ]
]

{ #category : #actions }
MCMergeBrowser >> selectNextUnresolvedConflict [
	"Try and select the next unresolved conflict starting at current selection in the list, wrapping at beginning.
	If there is no more unresolved conflict, then simply move to next non conflict item in the list.
	This method makes assumption that conflicts are always sorted before non conflicts items."
	(self findListMorph: #list)
		ifNotNil:
			[:aMorph |
			| currentIndex nextUnresolvedIndex |
			currentIndex := aMorph getCurrentSelectionIndex min: conflicts size.
			nextUnresolvedIndex := (currentIndex + 1 to: currentIndex + conflicts size - 1)
				detect:
					[:i |
					| nextItem |
					((nextItem := conflicts atWrap: i) isKindOf: MCConflict)
						and: [nextItem isResolved not]]
				ifNone: [0].
			nextUnresolvedIndex = 0
				ifTrue: [items size > 1 ifTrue: [self selection: (aMorph getCurrentSelectionIndex max: conflicts size)  - conflicts size \\ items size + conflicts size + 1]]
				ifFalse: [self selection: nextUnresolvedIndex - 1 \\ conflicts size + 1].].
]

{ #category : #testing }
MCMergeBrowser >> selectionIsConflicted [
	^ selection isKindOf: MCConflict
]

{ #category : #ui }
MCMergeBrowser >> widgetSpecs [
	Preferences annotationPanes ifFalse: [ ^#(
		((buttonRow) (0 0 1 0) (0 0 0 defaultButtonPaneHeight))
		((listMorph:selection:menu:keystroke: list selection methodListMenu: methodListKey:from:) (0 0 1 0.4) (0 defaultButtonPaneHeight 0 0))
		((innerButtonRow) (0 0.4 1 0.4) (0 0 0 defaultButtonPaneHeight))
		((textMorph: text) (0 0.4 1 1) (0 defaultButtonPaneHeight 0 0))
		)].

	^ {
		#((buttonRow) (0 0 1 0) (0 0 0 defaultButtonPaneHeight)).
		#((listMorph:selection:menu:keystroke: list selection methodListMenu: methodListKey:from:) (0 0 1 0.4) (0 defaultButtonPaneHeight 0 0)).
		#((innerButtonRow) (0 0.4 1 0.4) (0 0 0 defaultButtonPaneHeight)).
		{ #(textMorph: annotations). #(0 0.4 1 0.4). { 0. self defaultButtonPaneHeight. 0. self defaultButtonPaneHeight+self defaultAnnotationPaneHeight. }}.
		{ #(textMorph: text). #(0 0.4 1 1). { 0. self defaultButtonPaneHeight+self defaultAnnotationPaneHeight. 0. 0.}}
	}
]
