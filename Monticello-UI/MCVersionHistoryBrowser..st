Class {
	#name : #MCVersionHistoryBrowser,
	#superclass : #MCTool,
	#instVars : [
		'ancestry',
		'index',
		'repositoryGroup',
		'package',
		'infos'
	],
	#category : #'Monticello-UI'
}

{ #category : #accessing }
MCVersionHistoryBrowser >> ancestry: anAncestry [
	ancestry := anAncestry
]

{ #category : #accessing }
MCVersionHistoryBrowser >> baseSnapshot [
	^ self snapshotForInfo: ancestry
]

{ #category : #'morphic ui' }
MCVersionHistoryBrowser >> defaultExtent [
	^ 440@169.
	
]

{ #category : #'morphic ui' }
MCVersionHistoryBrowser >> defaultLabel [
	^ ancestry name, ' History'
]

{ #category : #'morphic ui' }
MCVersionHistoryBrowser >> getMenu: aMenu [
	| menuSpecs |
	self selection < 1 ifTrue: [^ aMenu]. "Nothing selected = nothing to do"
	menuSpecs := 	(self selectedInfo ancestors collect: [:parent |
			{'view changes from ', parent name . #viewChanges: . parent}]),
		#(('spawn history' spawnHistory)
		('search history' searchHistory)).
	self selection > 1 ifTrue: [menuSpecs := {{'view changes to ', ancestry name . #viewChanges}}, menuSpecs].
	self fillMenu: aMenu fromSpecs: menuSpecs.
	^ aMenu
]

{ #category : #accessing }
MCVersionHistoryBrowser >> index [
	"Answer the value of index"

	^ index
]

{ #category : #accessing }
MCVersionHistoryBrowser >> index: anObject [
	"Set the value of index"

	index := anObject
]

{ #category : #accessing }
MCVersionHistoryBrowser >> infos [
	^ infos ifNil: [infos := ancestry topologicalAncestors]
]

{ #category : #accessing }
MCVersionHistoryBrowser >> list [
	^ self infos collect: [:ea | ea name]
]

{ #category : #accessing }
MCVersionHistoryBrowser >> package: aMCPackage [
	package := aMCPackage
]

{ #category : #accessing }
MCVersionHistoryBrowser >> repositoryGroup [
	^ MCRepositoryGroup default
]

{ #category : #'morphic ui' }
MCVersionHistoryBrowser >> searchHistory [
	(UIManager default
		edit: (String streamContents:
			[:s|
			self selectedInfo topologicalAncestors
				do: [:versionInfo | s nextPutAll: versionInfo summary]
				separatedBy: [s cr; cr]])
		label: 'Version History: ', self selectedInfo versionName)
			extent: (0.5@0.9) * Display height
]

{ #category : #accessing }
MCVersionHistoryBrowser >> selectedInfo [
	^ self infos at: self selection ifAbsent: [nil]
]

{ #category : #accessing }
MCVersionHistoryBrowser >> selectedSnapshot [
	^ self snapshotForInfo: self selectedInfo
]

{ #category : #accessing }
MCVersionHistoryBrowser >> selection [
	^ index ifNil: [0]
]

{ #category : #accessing }
MCVersionHistoryBrowser >> selection: aNumber [
	index := aNumber.
	self changed: #selection; changed: #summary
]

{ #category : #accessing }
MCVersionHistoryBrowser >> snapshotForInfo: aVersionInfo [
	^ (self repositoryGroup versionWithInfo: aVersionInfo) snapshot
]

{ #category : #'morphic ui' }
MCVersionHistoryBrowser >> spawnHistory [
	MCVersionHistoryBrowser new
		ancestry: self selectedInfo;
		package: package;
		show
]

{ #category : #accessing }
MCVersionHistoryBrowser >> summary [
	| selInfo |
	selInfo := self selectedInfo.
	^ selInfo 
		ifNil: ['']
		ifNotNil: [selInfo summary]
]

{ #category : #'morphic ui' }
MCVersionHistoryBrowser >> viewChanges [
	self viewChanges: ancestry snapshot: self baseSnapshot
		relativeTo: self selectedInfo snapshot: self selectedSnapshot
]

{ #category : #'morphic ui' }
MCVersionHistoryBrowser >> viewChanges: otherInfo [
	self viewChanges: self selectedInfo snapshot: self selectedSnapshot
		relativeTo:  otherInfo snapshot: (self snapshotForInfo: otherInfo)
]

{ #category : #'morphic ui' }
MCVersionHistoryBrowser >> viewChanges: ancestorInfo snapshot: ancestorSnapshot relativeTo: baseInfo snapshot: baseSnapshot [
	"Note that the patchLabel will be parsed in MCPatchBrowser>>installSelection, so don't translate it!"
	| patch patchLabel |
	patchLabel := 'changes between {1} and {2}' format: { baseInfo name. ancestorInfo name }.
	patch := ancestorSnapshot patchRelativeToBase: baseSnapshot.
	(MCPatchBrowser forPatch: patch) label: patchLabel; show
]

{ #category : #'morphic ui' }
MCVersionHistoryBrowser >> widgetSpecs [
	^ #(
		((listMorph:selection:menu: list selection getMenu:) (0 0 0.3 1))
		((textMorph: summary) (0.3 0 1 1))
	 	)
]
