Class {
	#name : #MCRepositoryInspector,
	#superclass : #MCVersionInspector,
	#instVars : [
		'repository',
		'packageNames',
		'versionNames',
		'selectedPackage',
		'selectedVersion',
		'order',
		'versionInfo',
		'loaded',
		'newer',
		'inherited',
		'inheritedId'
	],
	#classVars : [
		'BrowseBranchedVersionsSeparately',
		'Order'
	],
	#category : #'Monticello-UI'
}

{ #category : #'class initialization' }
MCRepositoryInspector class >> browseBranchedVersionsSeparately [

	<preference: 'Browse branched package versions separately'
	category: 'Monticello'
	description: 'If true, versions of packages on branches will be shown in a separate section from trunk package versions'
	type: #Boolean>
	^BrowseBranchedVersionsSeparately ifNil: [true]
]

{ #category : #'class initialization' }
MCRepositoryInspector class >> browseBranchedVersionsSeparately: aBoolean [
	BrowseBranchedVersionsSeparately := aBoolean
]

{ #category : #'class initialization' }
MCRepositoryInspector class >> initialize [
	"self initialize"

	self migrateInstances
]

{ #category : #'class initialization' }
MCRepositoryInspector class >> migrateInstances [
	self allSubInstancesDo: [:inst |
		#(packageList versionList) do: [:each |
			[(inst findListMorph: each) highlightSelector: nil]
				on: Error do: [:ignore | ]]].
]

{ #category : #'class initialization' }
MCRepositoryInspector class >> order [
	Order isNil
		ifTrue: [ Order := 5 ].
	^Order
]

{ #category : #'class initialization' }
MCRepositoryInspector class >> order: anInteger [
	Order := anInteger
]

{ #category : #'instance creation' }
MCRepositoryInspector class >> repository: aFileBasedRepository workingCopy: aWorkingCopy [
	^self new
		setRepository: aFileBasedRepository workingCopy: aWorkingCopy;
		yourself
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> defaultExtent [
	^600@300
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> defaultLabel [
	^'Repository: ' , repository description
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> hasVersion [
	^ selectedVersion notNil
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> identifyLoadedAndInherited: aMCWorkingCopy [ 
	| seen |
	seen := Set new.
	aMCWorkingCopy ancestors do:
		[ : ancestor | loaded add: ancestor versionName.
		seen add: ancestor.
		ancestor ancestorsDoWhileTrue:
			[ : heir | (seen includes: heir)
				ifTrue: [ false ]
				ifFalse:
					[ inherited add: heir versionName.
					inheritedId add: heir id.
					seen add: heir.
					true ] ] ]
]

{ #category : #'initialize-release' }
MCRepositoryInspector >> identifyNewerVersionsOf: aMCWorkingCopy [ 
	(repository possiblyNewerVersionsOfAnyOf: aMCWorkingCopy ancestry names) do:
		[ : eachNewerVersionName |
		newer add: (self class browseBranchedVersionsSeparately
						ifTrue: [ eachNewerVersionName packageAndBranchName ]
						ifFalse: [ eachNewerVersionName packageName ]) ]
]

{ #category : #'initialize-release' }
MCRepositoryInspector >> initialize [
	super initialize.
	self initializeEmphasis
]

{ #category : #'initialize-release' }
MCRepositoryInspector >> initializeEmphasis [
	inherited := Set new.
	inheritedId := Set new.
	loaded := Set new
]

{ #category : #'initialize-release' }
MCRepositoryInspector >> initializeVersionNames [
	repository cacheAllFileNamesDuring:
		[ versionNames := selectedPackage
			ifNil: [Array empty]
			ifNotNil: [repository versionNamesForPackageNamed: selectedPackage].
		self refreshEmphasis ]
]

{ #category : #actions }
MCRepositoryInspector >> load [
	self hasVersion ifTrue:
		[self version isCacheable
			ifTrue: [version workingCopy repositoryGroup addRepository: repository].
		super load.
		self refresh].
]

{ #category : #actions }
MCRepositoryInspector >> merge [
	super merge.
	self refresh.

]

{ #category : #'morphic ui' }
MCRepositoryInspector >> order: anInteger [
	self class order: (order := anInteger).
	self changed: #versionList.
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> orderSpecs [
	^{
		'unchanged' -> nil.
		'order by package' -> [ :x :y | x packageName < y packageName ].
		'order by author' -> [ :x :y | x author caseInsensitiveLessOrEqual: y author ].
		'order by version-string' -> [ :x :y | x versionNumber asString < y versionNumber asString ].
		'order by version-number' -> [ :x :y | x versionNumber > y versionNumber ].
		'order by filename' -> [ :x :y | x < y ].
	}
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> orderString: anIndex [
	^String streamContents: [ :stream |
		order = anIndex
			ifTrue: [ stream nextPutAll: '<yes>' ]
			ifFalse: [ stream nextPutAll: '<no>' ].
		stream nextPutAll: (self orderSpecs at: anIndex) key ]
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> packageHighlight: loadedPackageAndMaybeBranchName [
	| packageName bold underline emphasis |
	bold := TextEmphasis bold emphasisCode.
	underline := TextEmphasis underlined emphasisCode.
	packageName := loadedPackageAndMaybeBranchName copyUpTo: $..
	emphasis := (loaded detect: [:each| each packageName = packageName] ifNone: nil) ifNotNil:
			[:mcVersionName|
			 self class browseBranchedVersionsSeparately
				ifTrue:
					[mcVersionName packageAndBranchName = loadedPackageAndMaybeBranchName
						ifTrue:
							[(newer includes: loadedPackageAndMaybeBranchName)
								ifTrue: [bold + underline]
								ifFalse: [underline]]
						ifFalse:
							[(newer includes: packageName)
								ifTrue: [bold]
								ifFalse: [nil]]]
				ifFalse:
					[(newer includes: loadedPackageAndMaybeBranchName)
						ifTrue: [bold + underline]
						ifFalse: [underline]]].
	^emphasis
		ifNil: [loadedPackageAndMaybeBranchName]
		ifNotNil:
			[Text
				string: loadedPackageAndMaybeBranchName
				attribute: (TextEmphasis new emphasisCode: emphasis)]
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> packageList [
	| result loadedPackages |
	packageNames ifNotNil: [ ^ packageNames ].
	repository cacheAllFileNamesDuring: 
		[ "Enjoy emphasis side-effects of populating my versionNames." 
		self versionNames.
		result := self class browseBranchedVersionsSeparately
					ifTrue: [ repository allPackageAndBranchNames ]
					ifFalse: [ repository allPackageNames ] ].
	"sort loaded packages first, then alphabetically"
	loadedPackages := loaded asSet collect: [ : each | each packageAndBranchName ].
	result := result asArray sort:
		[ : a : b | | loadedA loadedB |
		loadedA := loadedPackages includes: a.
		loadedB := loadedPackages includes: b.
		loadedA = loadedB
			ifTrue: [ a < b ]
			ifFalse: [ loadedA ] ].
	^ packageNames := result collect:
		[ : each | self packageHighlight: each ]
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> packageListMenu: aMenu [
	^aMenu
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> packageSelection [
	^self packageList indexOf: selectedPackage
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> packageSelection: aNumber [
	selectedPackage := (aNumber between: 1 and: self packageList size)
		ifTrue: [ (self packageList at: aNumber) asString ].
	self versionSelection: 0.
	versionNames := nil.
	self changed: #packageSelection; changed: #versionList
]

{ #category : #'initialize-release' }
MCRepositoryInspector >> postAcceptBrowseFor: aModel [
	"Make the same selections as in aModel."
	self 
		packageSelection: aModel packageSelection ;
		versionSelection: aModel versionSelection
]

{ #category : #actions }
MCRepositoryInspector >> refresh [
	packageNames := versionNames := newer := nil.
	repository refresh.
	self
		 changed: #packageList ;
		 changed: #versionList.
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> refreshEmphasis [
	| identifyNewer |
	identifyNewer := newer isNil.
	identifyNewer ifTrue: [ newer := Set new ].
	self initializeEmphasis.
	MCWorkingCopy allManagers do:
		[ : each | self identifyLoadedAndInherited: each.
		identifyNewer ifTrue: [ self identifyNewerVersionsOf: each ] ]
]

{ #category : #access }
MCRepositoryInspector >> repository [
	^ repository
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> representsSameBrowseeAs: anotherModel [ 
	^ self class = anotherModel class
	and: [ self repository = anotherModel repository ]
]

{ #category : #testing }
MCRepositoryInspector >> selectedVersionIsFalseAncestor [
	"Answer true if selectedVersion is a false ancestor of working copy.
	An ancestor of working copy that has same name, but not same id is a false ancestor!"
	^(selectedVersion notNil
			and: [(inherited includes: selectedVersion versionName)
					and: [(inheritedId includes: self versionInfo id) not]])
]

{ #category : #'initialize-release' }
MCRepositoryInspector >> setRepository: aFileBasedRepository workingCopy: aWorkingCopy [ 
	order := self class order.
	repository := aFileBasedRepository.
	self refresh.
	aWorkingCopy
		ifNil: [ self packageSelection: 1 ]
		ifNotNil:
			[ selectedPackage := aWorkingCopy ancestry ancestors ifNotEmpty:
				[ : ancestors | ancestors anyOne name asMCVersionName packageAndBranchName ] ].
	MCWorkingCopy addDependent: self
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> summary [
	self selectedVersionIsFalseAncestor
		ifTrue: [^ (Text string: 'Beware, this is a false ancestor whose name conflicts with a true one\' withCRs attributes: {TextColor red. TextEmphasis bold})
				, super summary].
	^ super summary
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> version [
	^ version ifNil:
		[Cursor wait showWhile:
			[version := repository versionNamed: selectedVersion].
		version]
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> versionHighlight: aMCVersionName [ 
	inherited ifNil: [inherited := #()].
	inheritedId ifNil: [inheritedId := #()].
	(selectedVersion notNil
			and: [selectedVersion = aMCVersionName
					and: [self selectedVersionIsFalseAncestor]])
		ifTrue: ["False ancestor might be dangerous, signal them in red"
			^ Text string: aMCVersionName attributes: {TextColor red. TextEmphasis bold}].
	^ Text
		string: aMCVersionName
		attribute: (TextEmphasis new
				emphasisCode: ((loaded includes: aMCVersionName)
						ifTrue: ["underlined" 4]
						ifFalse: [(inherited includes: aMCVersionName)
								ifTrue: [0]
								ifFalse: ["bold" 1]]))
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> versionList [
	| result |
	result := selectedPackage
				ifNil: [ self versionNamesForNoPackageSelection ]
				ifNotNil: [ self versionNamesForSelectedPackage ].
	(self orderSpecs at: order) value ifNotNil:
		[ : sortBlock |
		result sort: sortBlock ].
	^result collect:
		[ : each | self versionHighlight: each ]
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> versionListMenu: aMenu [
	1 to: self orderSpecs size do: [ :index |
		aMenu addUpdating: #orderString: target: self selector: #order: argumentList: { index } ].
	aMenu addLine.
	aMenu add: 'Changes against ...' action: [| ri |
		ri := aMenu defaultTarget.
		(UIManager default
			chooseFrom: ri versionList
			values: ri versionList
			title: 'Select version to show patch against ...') ifNotNil: [:name |
			| versionName target base |
			versionName := MCVersionName on: name.
			target := ri repository versionNamed: ri versionInfo name.
			base := aMenu defaultTarget repository versionNamed: versionName.
			(MCPatchBrowser
				forPatch: (target snapshot patchRelativeToBase: base snapshot))
			showLabelled: 'Changes from ', versionName, ' to ', ri versionInfo name]].
	^aMenu
]

{ #category : #access }
MCRepositoryInspector >> versionNames [
	^ versionNames ifNil:
		[ self initializeVersionNames.
		versionNames ]
]

{ #category : #access }
MCRepositoryInspector >> versionNamesForNoPackageSelection [
	^ Array empty
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> versionNamesForSelectedPackage [
	^ self versionNames
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> versionSelection [
	^self versionList indexOf: selectedVersion
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> versionSelection: aNumber [ 
	selectedVersion := version := nil.
	aNumber isZero ifFalse: [ selectedVersion := (self versionList at: aNumber) asString ].
	self selectedVersionIsFalseAncestor ifTrue: [self changed: #versionList].
	self
		 changed: #versionSelection ;
		 changed: #summary ;
		 changed: #hasVersion
]

{ #category : #'morphic ui' }
MCRepositoryInspector >> widgetSpecs [
	^#(	((buttonRow) (0 0 1 0) (0 0 0 defaultButtonPaneHeight))
		((listMorph: package) (0 0 0.5 0.6) (0 defaultButtonPaneHeight 0 0))
		((listMorph: version) (0.5 0 1 0.6) (0 defaultButtonPaneHeight 0 0))
		((textMorph: summary) (0 0.6 1 1) (0 0 0 0)) )
]
