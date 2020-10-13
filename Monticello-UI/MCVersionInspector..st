Class {
	#name : #MCVersionInspector,
	#superclass : #MCTool,
	#instVars : [
		'version'
	],
	#category : #'Monticello-UI'
}

{ #category : #accessing }
MCVersionInspector >> adopt [
	(self confirm:
'Modifying ancestry can be dangerous unless you know
what you are doing.  Are you sure you want to adopt
',self version info name, ' as an ancestor of your working copy?')
		ifTrue: [self version adopt]
]

{ #category : #accessing }
MCVersionInspector >> browse [
	self version browse
]

{ #category : #'morphic ui' }
MCVersionInspector >> buttonSpecs [
	^#(
		('Refresh' refresh 'refresh the version-list')
		(Browse browse 'Browse this version' hasVersion)
		(History history 'Browse the history of this version' hasVersion)
		(Changes changes 'Browse the changes this version would make to the image' hasVersion)
		(Load load 'Load this version into the image' hasVersion)
		(Merge merge 'Merge this version into the image' hasVersion)
		(Adopt adopt 'Adopt this version as an ancestor of your working copy' hasVersion)
		(Reparent reparent 'Adopt this version as the sole ancestor of your working copy' hasVersion)
		(Copy save 'Copy this version to another repository' hasVersion)
		(Diff diff 'Create an equivalent version based on an earlier release' hasVersion)
	)
]

{ #category : #accessing }
MCVersionInspector >> changes [
	(MCPatchBrowser forPatch: self version changes)
		showLabelled: 'Changes from ', self version info name
]

{ #category : #'morphic ui' }
MCVersionInspector >> defaultExtent [
	^ 400@200
]

{ #category : #'morphic ui' }
MCVersionInspector >> defaultLabel [
	^ 'Version: ', self version info name
]

{ #category : #accessing }
MCVersionInspector >> diff [
	| ancestorVersion |
	self pickAncestor ifNotNil:
		[:ancestor |
		ancestorVersion := self version workingCopy repositoryGroup versionWithInfo: ancestor.
		(self version asDiffAgainst: ancestorVersion) open]
]

{ #category : #accessing }
MCVersionInspector >> hasVersion [
	^version notNil
]

{ #category : #accessing }
MCVersionInspector >> history [
	(MCVersionHistoryBrowser new ancestry: self versionInfo) show
]

{ #category : #accessing }
MCVersionInspector >> load [
	Cursor wait showWhile: [self version load]
]

{ #category : #accessing }
MCVersionInspector >> merge [
	self version merge
]

{ #category : #'morphic ui' }
MCVersionInspector >> pickAncestor [
	| index versions |
	versions := self version info breadthFirstAncestors.
	index := UIManager default chooseFrom: (versions collect: [:ea | ea name])
				title: 'Ancestor:'.
	^ index = 0 ifFalse: [versions at: index]
]

{ #category : #'morphic ui' }
MCVersionInspector >> pickRepository [
	| index |
	index := UIManager default chooseFrom: (self repositories collect: [:ea | ea description])
				title: 'Repository:'.
	^ index = 0 ifFalse: [self repositories at: index]
]

{ #category : #accessing }
MCVersionInspector >> reparent [
	(self confirm:'Adopt ',self version info name, ' as the sole ancestor of your working copy?')
		ifTrue: [
			self version reparent.
			self refresh]
]

{ #category : #'morphic ui' }
MCVersionInspector >> repositories [
	^ MCRepositoryGroup default repositories
]

{ #category : #accessing }
MCVersionInspector >> save [
	self pickRepository ifNotNil:
		[:ea |
		ea storeVersion: self version]
]

{ #category : #accessing }
MCVersionInspector >> summary [
	^self hasVersion
		ifTrue: [ self versionSummary ]
		ifFalse: [ String new ]
]

{ #category : #accessing }
MCVersionInspector >> version [
	^ version
]

{ #category : #accessing }
MCVersionInspector >> version: aVersion [
	version := aVersion
]

{ #category : #accessing }
MCVersionInspector >> versionInfo [
	^ self version info
]

{ #category : #accessing }
MCVersionInspector >> versionSummary [
	^ self version summary
]

{ #category : #'morphic ui' }
MCVersionInspector >> widgetSpecs [
	^ #(
		((buttonRow) (0 0 1 0) (0 0 0 defaultButtonPaneHeight))
		((textMorph: summary) (0 0 1 1) (0 defaultButtonPaneHeight 0 0))
		)
]
