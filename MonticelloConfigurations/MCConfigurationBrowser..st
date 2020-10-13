"
A MCConfigurationBrowser displays an MCConfiguration, and edits the configuration to add or remove package dependencies and repository specifications. It allows a configuration to be stored in a repository or posted to an update stream.
"
Class {
	#name : #MCConfigurationBrowser,
	#superclass : #MCTool,
	#instVars : [
		'configuration',
		'dependencyIndex',
		'repositoryIndex',
		'activeEditWindow'
	],
	#category : #MonticelloConfigurations
}

{ #category : #'class initialization' }
MCConfigurationBrowser class >> initialize [
	TheWorldMenu registerOpenCommand: { 'Monticello Configurations' . { self . #open }. 'Monticello Configuration Browser' }.
]

{ #category : #opening }
MCConfigurationBrowser class >> open [
	^self new show
]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> activeEditWindow [
	^activeEditWindow

]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> activeEditWindow: editWindow [
	"Set temporarily during the process of editing a version comment."
	activeEditWindow ifNotNil: [:window | window delete].
	activeEditWindow := editWindow.

]

{ #category : #dependencies }
MCConfigurationBrowser >> addDependency [
	(self pickWorkingCopiesSatisfying: [:each | (self includesPackage: each package) not])
		do: [:wc |
			wc ancestors isEmpty
				ifTrue: [self inform: 'You must save ', wc packageName, ' first!
Skipping this package']
				ifFalse: [
					self dependencies add: (MCVersionDependency
						package: wc package
						info: wc ancestors first)]].
	self changed: #dependencyList; changed: #description
]

{ #category : #repositories }
MCConfigurationBrowser >> addRepository [
	(self pickRepositorySatisfying:
		[ : ea | (self repositories includes: ea) not ]) ifNotNil:
		[ : repo | repo class supportsConfigurations ifFalse: [ ^ self inform: 'Not all of these repositories support MCConfigurations.' ].
		self repositories add: repo.
		self changed: #repositoryList ]
]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> buttonSpecs [
	^ #(('Add' addDependency 'Add a dependency')
		('Update' updateMenu 'Update dependencies')
		('Install' installMenu 'Load/Merge/Upgrade into image')
		('Up' up 'Move item up in list' canMoveUp)
		('Down' down 'Move item down in list' canMoveDown)
		('Remove' remove 'Remove item' canRemove)
		('Save' store 'Store the configuration to a repository')
		('Versions' versions 'Show prior versions of this configuration')
		)
]

{ #category : #testing }
MCConfigurationBrowser >> canMoveDown [
	^self index between: 1 and: self maxIndex - 1 
]

{ #category : #testing }
MCConfigurationBrowser >> canMoveUp [
	^self index > 1
]

{ #category : #testing }
MCConfigurationBrowser >> canRemove [
	^self index > 0
]

{ #category : #selection }
MCConfigurationBrowser >> changedButtons [
	self changed: #canMoveDown.
	self changed: #canMoveUp.
	self changed: #canRemove.
]

{ #category : #selection }
MCConfigurationBrowser >> changedList [
	self dependencyIndex > 0 ifTrue: [^self changed: #dependencyList].
	self repositoryIndex > 0 ifTrue: [^self changed: #repositoryList].
	self error: 'nothing selected'
]

{ #category : #dependencies }
MCConfigurationBrowser >> checkDependencies [
	^self checkModified and: [self checkMissing]
]

{ #category : #dependencies }
MCConfigurationBrowser >> checkMissing [
	| missing |
	missing := (self dependencies collect:
		[ : ea | ea versionInfo name ]) asSet.
	self repositories do:
		[ : eachRepository | eachRepository cacheAllFileNamesDuring:
			[ missing copy do:
				[ : eachVersionName | (eachRepository includesVersionNamed: eachVersionName) ifTrue: [ missing remove: eachVersionName ] ] ] ].
	^ missing isEmpty or:
		[ self selectDependency: missing anyOne.
		self confirm:
			(String streamContents:
				[ : strm | strm
					 nextPutAll: 'No repository found for' ;
					 cr.
				missing do:
					[ : r | strm
						 nextPutAll: r ;
						 cr ].
				strm nextPutAll: 'Do you still want to store?' ]) ]
]

{ #category : #dependencies }
MCConfigurationBrowser >> checkModified [
	| modified |
	modified := self dependencies select: [:dep |
		dep isFulfilled and: [dep package workingCopy modified]].
	
	^modified isEmpty or: [
		self selectDependency: modified anyOne.
		self confirm: (String streamContents: [:strm |
			strm nextPutAll: 'These packages are modified:'; cr.
			modified do: [:dep | strm nextPutAll: dep package name; cr].
			strm nextPutAll: 'Do you still want to store?'])]
	
]

{ #category : #repositories }
MCConfigurationBrowser >> checkRepositories [
	| bad |
	bad := self repositories reject: [:repo | repo class supportsConfigurations ].
	^bad isEmpty or: [
		self selectRepository: bad first.
		self inform: (String streamContents: [:strm |
			strm nextPutAll: 'Please remove these repositories:'; cr.
			bad do: [:r | strm nextPutAll: r description; cr].
			strm nextPutAll: '(only HTTP repositories are supported)']).
		false].

]

{ #category : #repositories }
MCConfigurationBrowser >> checkRepositoryTemplates [
	"unused for now - we only do HTTP"
	| bad |
	bad := self repositories select: [:repo | repo creationTemplate isNil].
	^bad isEmpty or: [
		self selectRepository: bad first.
		self inform: (String streamContents: [:strm |
			strm nextPutAll: 'Creation template missing for'; cr.
			bad do: [:r | strm nextPutAll: r description; cr].
			strm nextPutAll: 'Please fill in the details first!']).
		false].

]

{ #category : #actions }
MCConfigurationBrowser >> completeStoreAction [
	"The store method will arrange for this to be called after the user has entered
	a comment for the configuration version being stored."
	self activeEditWindow: nil. "Close the editor window"
	self pickRepository
		ifNotNil: [:repo | 
			configuration authorInitials: Utilities authorInitials.
			configuration timeStamp: (DateAndTime fromSeconds: DateAndTime now asSeconds) printString.
			configuration id: UUID new asString.
			repo storeVersion: configuration.
			self inform: 'Saved ', configuration name]
]

{ #category : #accessing }
MCConfigurationBrowser >> configuration [
	^configuration ifNil: [configuration := MCConfiguration new]
]

{ #category : #accessing }
MCConfigurationBrowser >> configuration: aConfiguration [
	configuration := aConfiguration
]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> defaultExtent [
	^ 450@500
]

{ #category : #accessing }
MCConfigurationBrowser >> dependencies [
	^self configuration dependencies

]

{ #category : #accessing }
MCConfigurationBrowser >> dependencies: aCollection [
	self configuration dependencies: aCollection.
	self changed: #dependencyList; changed: #description

]

{ #category : #selection }
MCConfigurationBrowser >> dependencyIndex [
	^dependencyIndex ifNil: [0]
]

{ #category : #selection }
MCConfigurationBrowser >> dependencyIndex: anInteger [
	dependencyIndex := anInteger.
	dependencyIndex > 0
		ifTrue: [self repositoryIndex: 0].
	self changed: #dependencyIndex; changed: #description.
	self changedButtons.
]

{ #category : #dependencies }
MCConfigurationBrowser >> dependencyList [
	^self dependencies collect: [:dep | 
		Text string: dep versionInfo name
			attributes: (Array streamContents: [:attr |
				dep isFulfilledByAncestors
					ifFalse: [attr nextPut: TextEmphasis bold]
					ifTrue: [dep isCurrent ifFalse: [attr nextPut: TextEmphasis italic]].
			])]

]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> dependencyMenu: aMenu [
	self fillMenu: aMenu fromSpecs: #(('add new dependency...' addDependency)).
	self selectedDependency ifNotNil: [
		self fillMenu: aMenu fromSpecs: #(
			addLine
			('remove this dependency' remove)
			('update this dependency from image' updateSelectedDependencyFromImage)
			('update this dependency from repositories' updateSelectedDependencyFromRepositories)
		)].
	^aMenu
]

{ #category : #description }
MCConfigurationBrowser >> description [
	self selectedDependency ifNotNil:
		[:dep |
		^ ('Package: ', dep package name, String cr, dep versionInfo summary) asText].
	self selectedRepository ifNotNil:
		[:repo |
		^repo creationTemplate
			ifNotNil: [repo creationTemplate asText]
			ifNil: [repo asCreationTemplate asText addAttribute: TextColor red]].
	^('A configuration is a set of particular versions of packages.  These can be used to manage multiple dependencies amongst packages when an update requires changes to multiple packages.  One stores the current configuration and then modifies the various packages needing modification.  On load, the image will be updated to at least the versions in the current configuration, hence providing the support needed to load the new packages.\\To create a new configuration first load the most up-to-date configuration in your repository (e.g.',  MCHttpRepository trunkUrlString, '), open that repository in the Monticello browser, scroll down to the "update" package, select the first entry in the list on the right hand side and click Browse, which will open the configuration in a new MCConfigurationBrowser.  Then in the new MCConfigurationBrowser click Update, and choose "update all from image" from the pop-up menu.  Click Store to save back to the repository.  If required, one can add repositories to the browser to store the configuration in a different repository.') withCRs
]

{ #category : #description }
MCConfigurationBrowser >> description: aText [

	self selectedRepository ifNotNil: [:repo | 
		| new | 
		new := MCRepository readFrom: aText asString.
		(new class = repo class 
			and: [new description = repo description])
				ifTrue: [
					repo creationTemplate: aText asString.
					self changed: #description]
				ifFalse: [
					self inform: 'This does not match the previous definition!'
				]
	].


]

{ #category : #actions }
MCConfigurationBrowser >> down [
	self canMoveDown ifTrue: [
		self list swap: self index with: self index + 1.
		self index: self index + 1.
		self changedList.
	].

]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> enterVersionCommentAndCompleteWith: aConfigBrowser nameForRestore: originalName [
	"Open an editor for comment entry. When text is accepted from the editor, ask
	if editing is done. If complete, then proceed to save the MCConfiguration. If cancelled,
	close the edit window and do nothing further. Otherwise leave the edit window open
	to allow further edits before proceeding to save the configuration."
	| editWindow |
	editWindow := UIManager default
		edit: configuration comment
		label: 'Enter or edit a comment for ', configuration name
		accept: [:aText | | editingComplete |
			editingComplete := UIManager default
				confirm: 'Comment accepted' translated
				title: 'Comment for ' translated, configuration name
				trueChoice: 'Proceed to save configuration' translated
				falseChoice: 'Continue editing comment' translated.
			editingComplete
				ifNil: [ "cancel button pressed"
					configuration name: originalName. "cancelling, undo the changed name"
					Project current
					addDeferredUIMessage: [aConfigBrowser activeEditWindow ifNotNil: [ :win | win delete ]]] 
				ifNotNil: [ editingComplete
					ifTrue: [configuration comment: aText asString.
						Project current
							addDeferredUIMessage: [aConfigBrowser completeStoreAction]]
					ifFalse: [ "edit window remains open" ]]].
	aConfigBrowser activeEditWindow: editWindow.

]

{ #category : #testing }
MCConfigurationBrowser >> includesPackage: aPackage [
	^self dependencies anySatisfy: [:each | each package = aPackage]
]

{ #category : #selection }
MCConfigurationBrowser >> index [
	^self dependencyIndex max: self repositoryIndex
]

{ #category : #selection }
MCConfigurationBrowser >> index: anInteger [
	self dependencyIndex > 0 ifTrue: [^self dependencyIndex: anInteger].
	self repositoryIndex > 0 ifTrue: [^self repositoryIndex: anInteger].
	anInteger > 0 ifTrue: [self error: 'cannot select']
]

{ #category : #actions }
MCConfigurationBrowser >> installMenu [
	| action |
	action := UIManager default
		chooseFrom: #('load packages' 'merge packages' 'upgrade packages')
		values: #(#load #merge #upgrade).
	action ifNotNil: [self perform: action].
]

{ #category : #selection }
MCConfigurationBrowser >> list [
	self dependencyIndex > 0 ifTrue: [^self dependencies].
	self repositoryIndex > 0 ifTrue: [^self repositories].
	^#()
]

{ #category : #actions }
MCConfigurationBrowser >> load [
	self configuration load.
	self changed: #dependencyList; changed: #description

]

{ #category : #selection }
MCConfigurationBrowser >> maxIndex [
	^ self list size
]

{ #category : #actions }
MCConfigurationBrowser >> merge [
	self configuration merge.
	self changed: #dependencyList; changed: #description

]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> pickName [
	| name |
	name := UIManager default
		request: 'Name (.', self configuration writerClass extension, ' will be appended):'
		initialAnswer: self configuration suggestedNameOfNextVersion.
	^ name isEmpty ifFalse: [name]
]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> pickRepository [
	^self pickRepositorySatisfying: [:ea | true]

]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> pickRepositorySatisfying: aBlock [
	| index list |
	list := MCRepositoryGroup default repositories select: aBlock.
	index := UIManager default chooseFrom: (list collect: [:ea | ea description])
		title: 'Repository:'.
	^ index = 0 ifFalse: [list at: index]
]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> pickWorkingCopiesSatisfying: aBlock [
	| copies item |
	copies := (MCWorkingCopy allManagers select: aBlock)
		sort: [:a :b | a packageName <= b packageName].
	item := UIManager default chooseFrom: #('match ...'),(copies collect: [:ea | ea packageName]) lines: #(1) title: 'Package:'.
	item = 1 ifTrue: [
		| pattern |
		pattern := UIManager default request: 'Packages matching:' initialAnswer: '*'.
		^pattern isEmptyOrNil
			ifTrue: [#()]
			ifFalse: [
				(pattern includes: $*) ifFalse: [pattern := '*', pattern, '*'].
				copies select: [:ea | pattern match: ea packageName]]
	].
	^ item = 0
		ifTrue: [#()]
		ifFalse: [{copies at: item - 1}]
]

{ #category : #actions }
MCConfigurationBrowser >> remove [
	self canRemove ifTrue: [
		self list removeAt: self index.
		self changedList.
		self updateIndex.
	].

]

{ #category : #repositories }
MCConfigurationBrowser >> removeRepository [
	repositoryIndex > 0
		ifTrue: [self repositories removeAt: repositoryIndex.
			repositoryIndex := 0.
			self changed: #repositoryList]
]

{ #category : #accessing }
MCConfigurationBrowser >> repositories [
	^ self configuration repositories
]

{ #category : #accessing }
MCConfigurationBrowser >> repositories: aCollection [
	^self configuration repositories: aCollection

]

{ #category : #selection }
MCConfigurationBrowser >> repositoryIndex [
	^repositoryIndex ifNil: [0]
]

{ #category : #selection }
MCConfigurationBrowser >> repositoryIndex: anInteger [
	repositoryIndex := anInteger.
	repositoryIndex > 0
		ifTrue: [self dependencyIndex: 0].
	self changed: #repositoryIndex; changed: #description.
	self changedButtons.
]

{ #category : #repositories }
MCConfigurationBrowser >> repositoryList [
	^self repositories collect: [:ea | ea description]

]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> repositoryMenu: aMenu [
	self fillMenu: aMenu fromSpecs: #(('add repository...' addRepository)).
	self selectedRepository ifNotNil: [
		self fillMenu: aMenu fromSpecs: #(('remove repository' removeRepository))].
	^aMenu

]

{ #category : #selection }
MCConfigurationBrowser >> selectDependency: aDependency [
	self dependencyIndex: (self dependencies indexOf: aDependency)
]

{ #category : #selection }
MCConfigurationBrowser >> selectRepository: aRepository [
	self repositoryIndex: (self repositories indexOf: aRepository)
]

{ #category : #dependencies }
MCConfigurationBrowser >> selectedDependency [
	^ self dependencies at: self dependencyIndex ifAbsent: []
]

{ #category : #dependencies }
MCConfigurationBrowser >> selectedPackage [
	^ self selectedDependency ifNotNil: [:dep | dep package]
]

{ #category : #repositories }
MCConfigurationBrowser >> selectedRepository [
	^ self repositories at: self repositoryIndex ifAbsent: []
]

{ #category : #actions }
MCConfigurationBrowser >> store [
	self activeEditWindow: nil. "Close previous if still open"
	(self checkRepositories and: [self checkDependencies]) ifFalse: [^self].
	self pickName ifNotNil: [:name | | originalName |
		originalName := configuration name.
		configuration name: name.
		self enterVersionCommentAndCompleteWith: self nameForRestore: originalName ].
]

{ #category : #actions }
MCConfigurationBrowser >> up [
	self canMoveUp ifTrue: [
		self list swap: self index with: self index - 1.
		self index: self index - 1.
		self changedList.
	].
]

{ #category : #updating }
MCConfigurationBrowser >> updateFromImage [
	self configuration updateFromImage.
	self changed: #dependencyList; changed: #description

]

{ #category : #updating }
MCConfigurationBrowser >> updateFromRepositories [
	self configuration updateFromRepositories.
	self changed: #dependencyList; changed: #description

]

{ #category : #selection }
MCConfigurationBrowser >> updateIndex [
	self index > 0 ifTrue: [self index: (self index min: self maxIndex)]
]

{ #category : #actions }
MCConfigurationBrowser >> updateMenu [
	| action |
	action := UIManager default
		chooseFrom: #('update all from image' 'update all from repositories')
		values: #(#updateFromImage #updateFromRepositories).
	action ifNotNil: [self perform: action].
]

{ #category : #actions }
MCConfigurationBrowser >> updateSelectedDependencyFromImage [
	self configuration updateFromImage: self dependencyIndex.
	self changed: #dependencyList; changed: #description

]

{ #category : #actions }
MCConfigurationBrowser >> updateSelectedDependencyFromRepositories [
	self configuration updateFromRepositories: self dependencyIndex.
	self changed: #dependencyList; changed: #description

]

{ #category : #actions }
MCConfigurationBrowser >> upgrade [
	self configuration upgrade.
	self changed: #dependencyList; changed: #description

]

{ #category : #actions }
MCConfigurationBrowser >> versions [
	configuration priorVersions explore
]

{ #category : #'morphic ui' }
MCConfigurationBrowser >> widgetSpecs [
	^ #(
		((buttonRow) (0 0 1 0) (0 0 0 defaultButtonPaneHeight))
		((listMorph:selection:menu: dependencyList dependencyIndex dependencyMenu:) (0 0 1 1) (0 defaultButtonPaneHeight 0 -180))
		((listMorph:selection:menu: repositoryList repositoryIndex repositoryMenu:) (0 1 1 1) (0 -180 0 -120))
		((textMorph: description) (0 1 1 1) (0 -120 0 0))
	 	)
]
