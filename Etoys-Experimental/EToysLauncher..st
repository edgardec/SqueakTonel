"
I am a simple launcher for recent projects.

EToysLauncher new openInHand

- I find latest ten projects in ""My Squeak"" and image directories (see: EToysLauncher>>directories).
- A thumbnail can be shown if there is ""project name.gif"" file.
- You can enter a project when you click a thumbnail.
- The list is updated when you go and back project.


"
Class {
	#name : #EToysLauncher,
	#superclass : #Morph,
	#instVars : [
		'window',
		'showGallery'
	],
	#category : #'Etoys-Experimental'
}

{ #category : #'instance creation' }
EToysLauncher class >> buildGallery [
	"self buildGallery openInHand"
	| launcher panel |
	launcher := self new.
	launcher showGallery: true.
	launcher buildPane.
	panel := ScriptingSystem buildPanelTitled: 'Projects'.
	panel addMorphBack: launcher.
	launcher window: panel.
	^ panel
]

{ #category : #'instance creation' }
EToysLauncher class >> buildPanel [
	"self buildPanel openInHand"
	| launcher panel |
	launcher := self new.
	launcher buildPane.
	panel := ScriptingSystem buildPanelTitled: 'Recent Etoy Projects'.
	panel addMorphBack: launcher.
	launcher window: panel.
	^ panel
]

{ #category : #'instance creation' }
EToysLauncher class >> openGallery [
	"self openGallery"
	| window |
	window := self buildGallery.
	window openCenteredInWorld.
	^ window
]

{ #category : #'instance creation' }
EToysLauncher class >> openPanel [
	"self openPanel"
	| window |
	window := self buildPanel.
	window openCenteredInWorld.
	^ window
]

{ #category : #initialization }
EToysLauncher >> buildButtonFor: fileName [ 
	"(self basicNew buildButtonFor: 'new2.001.pr') openInHand"
	"(self basicNew buildButtonFor: 'nothing.pr') openInHand"
	| thumbnail aButton base title projectName |
	projectName := (Project parseProjectFileName: fileName) first.
	base := Morph new.
	base clipSubmorphs: true.
	base color: Color transparent.
	base layoutPolicy: TableLayout new.
	base listDirection: #leftToRight.
	base hResizing: #rigid.
	base vResizing: #shrinkWrap.
	base width: 300.
	base layoutInset: 0.
	base cellInset: 3.
	base beSticky.
	title := StringMorph new.
	title contents: (Project parseProjectFileName: fileName) first.
	title font: Preferences standardEToysFont.
	thumbnail := self thumbnailFor: projectName.
	aButton := IconicButton new labelGraphic: thumbnail.
	aButton target: self.
	aButton actionSelector: #openProjectNamed:.
	aButton arguments: {projectName}.
	aButton borderWidth: 0.
	aButton color: ScriptingSystem baseColor.
	aButton extent: thumbnail extent + (4 @ 4).
	base addMorphBack: aButton.
	base addMorphBack: title.
	^ base
]

{ #category : #initialization }
EToysLauncher >> buildPane [
	"EToysLauncher new openInHand"
	self color: ScriptingSystem paneColor.
	self layoutPolicy: TableLayout new.
	self cellPositioning: #bottomCenter.
	self listDirection: #leftToRight.
	self wrapDirection: #topToBottom.
	self hResizing: #rigid.
	self vResizing: #shrinkWrap.
	self layoutInset: 6.
	self cellInset: 3.
	self width: 620.
	showGallery ifFalse: [self updatePane] ifTrue: [self updateBook].

]

{ #category : #utilities }
EToysLauncher >> directories [
	"I find a project name in this order"
	"self basicNew directories"
	| ret |
	ret := Array with: SecurityManager default untrustedUserDirectory with: Smalltalk imagePath.
	showGallery ifFalse: [^ ret].
	^ ret copyWith: Smalltalk imagePath, FileDirectory slash, 'ExampleEtoys'.

]

{ #category : #utilities }
EToysLauncher >> fullPathForProjectNamed: projectName [ 
	"Answer {directory name. file name}"
	"self basicNew fullPathForProjectNamed: 'DemonScript'"
	| entries fileName directory |
	entries := self sortedProjectFiles.
	fileName := (entries
				detect: [:each | (Project parseProjectFileName: each first) first = projectName]) first.
	directory := self directories
				detect: [:each | (FileDirectory on: each)
						includesKey: fileName].
	^ {directory. fileName}
]

{ #category : #initialization }
EToysLauncher >> initialize [
	super initialize.
	showGallery := false.
	"self buildPane."
]

{ #category : #initialization }
EToysLauncher >> intoWorld: aWorld [ 
	"World removeActionsForEvent: #aboutToEnterWorld"
	super intoWorld: aWorld.
	aWorld
		when: #aboutToEnterWorld
		send: #onEnterWorld
		to: self
]

{ #category : #'event handling' }
EToysLauncher >> onEnterWorld [
	(owner notNil
			and: [Project current world == owner])
		ifTrue: [owner addMorphInLayer: self.
			self updatePane]
		ifFalse: [Project current world removeActionsWithReceiver: self]
]

{ #category : #actions }
EToysLauncher >> openProjectNamed: projectName [ 
	| newProject array |
	window
		ifNotNil: [window delete].
	(newProject := Project named: projectName)
		ifNil: [array := self fullPathForProjectNamed: projectName.
			ProjectLoading
				openFromDirectory: (FileDirectory on: array first)
				andFileName: array second]
		ifNotNil: [newProject enter]
]

{ #category : #utilities }
EToysLauncher >> projectFiles [
	"Answer a collection of file entry. Only recent version is picked up."
	"self basicNew projectFiles"
	| entries |
	entries := self directories
				inject: OrderedCollection new
				into: [:collection :each | 
					collection addAll: (FileDirectory on: each) entries.
					collection].
	^ Project latestProjectVersionsFromFileEntries:  entries
]

{ #category : #utilities }
EToysLauncher >> setupBookPage: aPage [

	aPage color: ScriptingSystem paneColor.
	aPage layoutPolicy: TableLayout new.
	aPage cellPositioning: #bottomCenter.
	aPage listDirection: #leftToRight.
	aPage wrapDirection: #topToBottom.
	aPage hResizing: #rigid.
	aPage vResizing: #shrinkWrap.
	aPage layoutInset: 6.
	aPage cellInset: 3.
	aPage width: 620.

	aPage setProperty: #transitionSpec toValue: (Array with: 'silence' with: #none with: #none).

]

{ #category : #accessing }
EToysLauncher >> showGallery [

	^ showGallery.

]

{ #category : #accessing }
EToysLauncher >> showGallery: aBoolean [

	showGallery := aBoolean.

]

{ #category : #utilities }
EToysLauncher >> sortedAllProjectFiles [
	"self basicNew sortedAllProjectFiles"
	| entries |
	entries := self projectFiles asArray
				sort: [:a :b | a modificationTime > b modificationTime].
	^ entries
]

{ #category : #utilities }
EToysLauncher >> sortedProjectFiles [
	"self basicNew sortedProjectFiles"
	| entries |
	entries := self sortedAllProjectFiles.
	showGallery ifTrue: [^ entries].
	^ entries size > 10
		ifTrue: [entries first: 10]
		ifFalse: [entries]
]

{ #category : #initialization }
EToysLauncher >> thumbnailFor: projectName [ 
	| project thumbnailName newForm array |
	newForm := (project := Project named: projectName)
				ifNil: [array := self fullPathForProjectNamed: projectName.
					thumbnailName := array first , FileDirectory slash , projectName , '.gif'.
					[ImageReadWriter formFromFileNamed: thumbnailName]
						on: FileDoesNotExistException
						do: [^ Form extent: 100 @ 75]]
				ifNotNil: [project thumbnail].
	^ newForm scaledToSize: 100 @ 75
]

{ #category : #actions }
EToysLauncher >> updateBook [
	| entries fileNames aBookMorph currentPage count base |
	self removeAllMorphs.
	entries := self sortedProjectFiles.
	fileNames := entries
				collect: [:each | each first].
	aBookMorph := BookMorph new.
	aBookMorph extent: self extent.
	self addMorph: aBookMorph.
	currentPage := aBookMorph currentPage..
	self setupBookPage: currentPage.
	count := 0.
	fileNames
		do: [:each |
			currentPage addMorphBack: (self buildButtonFor: each).
			count := count + 1.
			(count \\ 10 = 0) ifTrue: [
				"base := Morph new.
				base width: 300; color: Color transparent; borderWidth: 0.
				currentPage addMorphBack: base.
				currentPage addMorphBack: (RectangleMorph new extent: 100@75; color: Color transparent; borderWidth: 0).
				currentPage addMorphBack: (StringMorph new font: Preferences standardEToysFont; contents: 'more...')."
				currentPage := aBookMorph insertPageSilentlyAtEnd.
				self setupBookPage: currentPage.
			]].
	aBookMorph evenFewerPageControlsAllowDragging: false..

]

{ #category : #actions }
EToysLauncher >> updatePane [
	| entries fileNames |
	self removeAllMorphs.
	entries := self sortedProjectFiles.
	fileNames := entries
				collect: [:each | each first].
	fileNames
		do: [:each | self
				addMorphBack: (self buildButtonFor: each)]
]

{ #category : #'event handling' }
EToysLauncher >> wantsToBeDroppedInto: aMorph [ 
	(aMorph isKindOf: ProjectViewMorph)
		ifTrue: [^ false].
	^ super wantsToBeDroppedInto: aMorph
]

{ #category : #accessing }
EToysLauncher >> window [
	^ window
]

{ #category : #accessing }
EToysLauncher >> window: aMorph [
	^ window := aMorph
]
