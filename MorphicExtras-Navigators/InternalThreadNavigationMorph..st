Class {
	#name : #InternalThreadNavigationMorph,
	#superclass : #ThreadNavigationMorph,
	#instVars : [
		'threadName',
		'preferredIndex'
	],
	#classVars : [
		'CachedThumbnails',
		'KnownThreads'
	],
	#category : #'MorphicExtras-Navigators'
}

{ #category : #thumbnails }
InternalThreadNavigationMorph class >> cacheThumbnailFor: aProject [
	"Save a thumbnail  of the given project in my thumbnail cache."

	| form |
	CachedThumbnails ifNil: [CachedThumbnails := Dictionary new].
	CachedThumbnails
		at: aProject name
		put: (form := self sorterFormForProject: aProject sized: 160 @ 120).
	^ form
	
]

{ #category : #'known threads' }
InternalThreadNavigationMorph class >> clearKnownThreads [

	KnownThreads := nil
]

{ #category : #thumbnails }
InternalThreadNavigationMorph class >> clearThumbnailCache [

	CachedThumbnails := nil
]

{ #category : #'parts bin' }
InternalThreadNavigationMorph class >> descriptionForPartsBin [
	^ self partName: 	'ThreadNavigator' translatedNoop
		categories:		{'Multimedia' translatedNoop}
		documentation:	'A tool that lets you navigate through a thread of projects.' translatedNoop
]

{ #category : #thumbnails }
InternalThreadNavigationMorph class >> getThumbnailFor: aProject [
	"Answer a thumbnail for the given project, retrieving it from a cache of such objects if possible, else creating a fresh thumbnail, storing it in the cache, and answering it."

	CachedThumbnails ifNil: [CachedThumbnails := Dictionary new].
	^CachedThumbnails
		at: aProject name
		ifAbsentPut: [self sorterFormForProject: aProject sized: 160@120]
]

{ #category : #'known threads' }
InternalThreadNavigationMorph class >> know: listOfPages as: nameOfThread [

	self knownThreads at: nameOfThread put: listOfPages.

]

{ #category : #'known threads' }
InternalThreadNavigationMorph class >> knownThreads [

	^KnownThreads ifNil: [KnownThreads := Dictionary new].

]

{ #category : #'known threads' }
InternalThreadNavigationMorph class >> openThreadNamed: nameOfThread atIndex: anInteger [

	| coll nav |

	coll := self knownThreads at: nameOfThread ifAbsent: [^self].
	nav := Project current world 
		submorphThat: [ :each | (each isKindOf: self) and: [each threadName = nameOfThread]]
		ifNone: [
			nav := self basicNew.
			nav
				listOfPages: coll;
				threadName: nameOfThread index: anInteger;
				initialize;
				openInWorld;
				positionAppropriately.
			^self
		].
	nav
		listOfPages: coll;
		threadName: nameOfThread index: anInteger;
		removeAllMorphs;
		addButtons.


]

{ #category : #'known threads' }
InternalThreadNavigationMorph class >> openThreadNamed: nameOfThread atIndex: anInteger beKeyboardHandler: aBoolean [
	"Activate the thread of the given name, from the given index; set it up to be navigated via desktop keys if indicated"

	| coll nav |

	coll := self knownThreads at: nameOfThread ifAbsent: [^self].
	nav := Project current world 
		submorphThat: [ :each | (each isKindOf: self) and: [each threadName = nameOfThread]]
		ifNone:
			[nav := self basicNew.
			nav
				listOfPages: coll;
				threadName: nameOfThread index: anInteger;
				initialize;
				openInWorld;
				positionAppropriately.
			aBoolean ifTrue: [Project current world keyboardNavigationHandler: nav].
			^ self].
	nav
		listOfPages: coll;
		threadName: nameOfThread index: anInteger;
		removeAllMorphs;
		addButtons.
	aBoolean ifTrue: [Project current world keyboardNavigationHandler: nav].
]

{ #category : #sorter }
InternalThreadNavigationMorph class >> sorterFormForProject: aProject sized: aSize [
	"Answer a form to use in a project-sorter to represent the project."

	^ (ProjectViewMorph on: aProject) imageForm scaledToSize: aSize

]

{ #category : #sorting }
InternalThreadNavigationMorph >> acceptSortedContentsFrom: aHolder [
	"Update my page list from the given page sorter."

	

	threadName isEmpty ifTrue: [threadName := 'I need a name' translated].
	threadName := UIManager default 
		request: 'Name this thread.' translated 
		initialAnswer: threadName.
	threadName isEmptyOrNil ifTrue: [^self].
	listOfPages := OrderedCollection new.
	aHolder submorphs doWithIndex: [:m :i | | cachedData proj nameOfThisProject |
		(nameOfThisProject := m valueOfProperty: #nameOfThisProject) ifNotNil: [
			cachedData := {nameOfThisProject}.
			proj := Project named: nameOfThisProject.
			(proj isNil or: [proj thumbnail isNil]) ifFalse: [
				cachedData := cachedData, {proj thumbnail scaledToSize: self myThumbnailSize}.
			].
			listOfPages add: cachedData.
		].
	].
	self class know: listOfPages as: threadName.
	self removeAllMorphs; addButtons.
	self world ifNil: [
		self openInWorld; positionAppropriately.
	].

]

{ #category : #initialization }
InternalThreadNavigationMorph >> addButtons [

	| marginPt i sz data images b1 b2 dot arrowWidth arrowHeight nameMorph sizeRatio controlsColor |

	sizeRatio := self sizeRatio.
	controlsColor := Color orange lighter.

	self changeNoLayout.
	self hResizing: #rigid.
	self vResizing: #rigid.
	marginPt := (4 @ 4 * sizeRatio) rounded..
	i := self currentIndex.
	sz := self myThumbnailSize.
	arrowWidth := (14 * sizeRatio) rounded.
	arrowHeight := (14 * sizeRatio) rounded.
	data := {
		{i - 1. 'Previous:'. #previousPage. #leftCenter. arrowWidth. 'Prev'}.
		{i + 1. 'Next:'. #nextPage. #rightCenter. arrowWidth negated. 'Next'}
	}.
	images := data collect: [ :tuple | | pageNumber f vertices m arrowCenter |
		pageNumber := tuple first.
		(pageNumber between: 1 and: listOfPages size) ifTrue: [
			f := self 
				makeThumbnailForPageNumber: pageNumber 
				scaledToSize: sz 
				default: tuple sixth.
			f := f deepCopy.		"we're going to mess it up"
			arrowCenter := f boundingBox perform: tuple fourth.
			vertices := {
				arrowCenter + (tuple fifth @ arrowHeight negated).
				arrowCenter + (tuple fifth @ arrowHeight).
				arrowCenter.
			}.
			f getCanvas
				drawPolygon: vertices 
				color: controlsColor
				borderWidth: 0 
				borderColor: Color transparent.
			m := ImageMorph new image: f.
			m setBalloonText: tuple second translated,' ',(listOfPages at: pageNumber) first.
			m addMouseUpActionWith: (
				MessageSend receiver: self selector: tuple third
			).
		] ifFalse: [
			f := (Form extent: sz depth: 16) fillColor: Color lightGray.
			m := ImageMorph new image: f.
		].
		m
	].
	b1 := images first.
	b2 := images second.
	dot := EllipseMorph new extent: (18@18 * sizeRatio) rounded; color: controlsColor; borderWidth: 0.

	self addMorph: (b1 position: self position + marginPt).
	self addMorph: (b2 position: b1 topRight + (marginPt x @ 0)).

	self extent: (b1 bottomRight max: b2 bottomRight) - self position + marginPt.
	self addMorph: dot.
	dot align: dot center with: b1 bounds rightCenter + ((marginPt x @ 0) // 2).
	dot setBalloonText: threadName,'
more commands'.
	dot on: #mouseDown send: #moreCommands to: self.
	self fullBounds.
	self addMorph: (nameMorph := SquishedNameMorph new).
	nameMorph
		target: self getSelector: #threadName setSelector: nil;
		color: Color transparent;
		width: self width;
		height: (15 * sizeRatio) rounded;
		align: nameMorph bottomLeft with: self bottomLeft.


]

{ #category : #navigation }
InternalThreadNavigationMorph >> buttonForMenu [

	^self makeButton: '?' balloonText: 'More commands' translated for: #moreCommands.

]

{ #category : #private }
InternalThreadNavigationMorph >> currentIndex [

	| currentName |

	currentName := Project current name.
	listOfPages withIndexDo: [ :each :index |
		(each first = currentName and: [preferredIndex = index]) ifTrue: [^currentIndex := index]
	].
	listOfPages withIndexDo: [ :each :index |
		each first = currentName ifTrue: [^currentIndex := index]
	].
	
	currentIndex isNil
		ifTrue: [^ 1].

	^ currentIndex min: listOfPages size

]

{ #category : #initialization }
InternalThreadNavigationMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^(Color r: 0.27 g: 0.634 b: 0.365) alpha: 0.5
]

{ #category : #navigation }
InternalThreadNavigationMorph >> deleteCurrentPage [

	"no-op here"
]

{ #category : #navigation }
InternalThreadNavigationMorph >> destroyThread [
	"Manually destroy the thread"

	(self confirm: ('Destroy thread <{1}> ?' translated format:{threadName})) ifFalse: [^ self].
	self class knownThreads removeKey: threadName ifAbsent: [].
	self setProperty: #moribund toValue: true.  "In case pointed to in some other project"
	self currentWorld keyboardNavigationHandler == self ifTrue:
		[self stopKeyboardNavigation]. 
	self delete.
]

{ #category : #navigation }
InternalThreadNavigationMorph >> editThisThread [

	| sorter |

	sorter := ProjectSorterMorph new.
	sorter navigator: self listOfPages: listOfPages.
	self currentWorld addMorphFront: sorter.
	sorter align: sorter topCenter with: self currentWorld topCenter.
	self delete.


]

{ #category : #initialization }
InternalThreadNavigationMorph >> ensureSuitableDefaults [

	listOfPages ifNil: [
		listOfPages := Project allMorphicProjects collect: [ :each | {each name}].
		threadName := 'all (default)' translated.
		self class know: listOfPages as: threadName.
	].
	currentIndex ifNil: [currentIndex := 0].

]

{ #category : #navigation }
InternalThreadNavigationMorph >> getRecentThread [

	self switchToThread: (
		ProjectHistory currentHistory mostRecentThread ifNil: [^self]
	)


]

{ #category : #navigation }
InternalThreadNavigationMorph >> insertNewProject [

	| newProj |

	[newProj := MorphicProject openViewOn: nil.]
		on: ProjectViewOpenNotification
		do: [ :ex | ex resume: false].	

	Smalltalk at: #EToyProjectDetailsMorph ifPresent:[:aClass|
		aClass
			getFullInfoFor: newProj
			ifValid: [self insertNewProjectActionFor: newProj]
			expandedFormat: false.
	].


]

{ #category : #navigation }
InternalThreadNavigationMorph >> insertNewProjectActionFor: newProj [

	| me |

	me := Project current name.
	listOfPages withIndexDo: [ :each :index |
		each first = me ifTrue: [
			listOfPages add: {newProj name} afterIndex: index.
			^self switchToThread: threadName.
		].
	].
	listOfPages add: {newProj name} afterIndex: listOfPages size.
	^self switchToThread: threadName
		

]

{ #category : #navigation }
InternalThreadNavigationMorph >> jumpToIndex: anInteger [

	currentIndex := anInteger.
	self loadPageWithProgress.
]

{ #category : #navigation }
InternalThreadNavigationMorph >> jumpWithinThread [

	| aMenu me weHaveOthers myIndex |

	me := Project current name.
	aMenu := MenuMorph new defaultTarget: self.
	weHaveOthers := false.
	myIndex := self currentIndex.
	listOfPages withIndexDo: [ :each :index |
		index = myIndex ifTrue: [
			aMenu add: 'you are here' translated action: #yourself.
			aMenu lastSubmorph color: Color red.
		] ifFalse: [
			weHaveOthers := true.
			aMenu add: ('jump to <{1}>' translated format:{each first}) selector: #jumpToIndex: argument: index.
			myIndex = (index - 1) ifTrue: [
				aMenu lastSubmorph color: Color blue
			].
			myIndex = (index + 1) ifTrue: [
				aMenu lastSubmorph color: Color orange
			].
		].
	].
	weHaveOthers ifFalse: [^self inform: 'This is the only project in this thread' translated].
	aMenu popUpEvent: self world primaryHand lastEvent in: self world
]

{ #category : #private }
InternalThreadNavigationMorph >> listOfPages: aCollection [

	listOfPages := aCollection.
	currentIndex := nil.
	self currentIndex

]

{ #category : #private }
InternalThreadNavigationMorph >> loadPageWithProgress [
	"Load the desired page, showing a progress indicator as we go"
	
	| projectInfo projectName beSpaceHandler |
	projectInfo := listOfPages at: currentIndex.
	projectName := projectInfo first.
	loadedProject := Project named: projectName.
	self class know: listOfPages as: threadName.
	beSpaceHandler := (Project current world keyboardNavigationHandler == self).
	self currentWorld addDeferredUIMessage:
		[InternalThreadNavigationMorph openThreadNamed: threadName atIndex: currentIndex beKeyboardHandler: beSpaceHandler].

	loadedProject ifNil: [
		ComplexProgressIndicator new 
			targetMorph: self;
			historyCategory: 'project loading' translated;
			withProgressDo: [
				[
					loadedProject := Project current 
							fromMyServerLoad: projectName
				] 
					on: ProjectViewOpenNotification
					do: [ :ex | ex resume: false]		
						"we probably don't want a project view morph in this case"
			].
	].
	loadedProject ifNil: [
		^self inform: 'I cannot find that project' translated
	].
	self delete.

	loadedProject enter.
]

{ #category : #sorting }
InternalThreadNavigationMorph >> makeThumbnailForPageNumber: pageNumber scaledToSize: sz default: aString [

	| cachedData proj tn label |
	cachedData := listOfPages at: pageNumber.
	proj := Project named: cachedData first.
	(proj isNil or: [proj thumbnail isNil]) ifTrue: [
		cachedData size >= 2 ifTrue: [^cachedData second].
		tn := Form extent: sz depth: 8.
		tn fillColor: Color veryLightGray.
		label := (StringMorph contents: aString) imageForm.
		label displayOn: tn at: tn center - (label extent // 2) rule: Form paint.
		^tn
	].
	tn := proj thumbnail  scaledToSize: sz.
	cachedData size < 2 ifTrue: [
		cachedData := cachedData,#(0).
		listOfPages at: pageNumber put: cachedData.
	].
	cachedData at: 2 put: tn.
	^tn

]

{ #category : #navigation }
InternalThreadNavigationMorph >> moreCommands [
	"Put up a menu of options"

	| allThreads aMenu others target |
	allThreads := self class knownThreads.
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'navigation' translated.

	Preferences noviceMode ifFalse:[
		self flag: #deferred.  "Probably don't want that stay-up item, not least because the navigation-keystroke stuff is not dynamically handled"
		aMenu addStayUpItem
	].
	
	others := (allThreads keys reject: [ :each | each = threadName]) asArray sort.
	others do: [ :each |
		aMenu add: ('switch to <{1}>' translated format:{each}) selector: #switchToThread: argument: each
	].

	aMenu addList: {
		{'switch to recent projects' translated.  #getRecentThread}.
		#-.
		{'create a new thread' translated.  #threadOfNoProjects}.
		{'edit this thread' translated.  #editThisThread}.
		{'create thread of all projects' translated.  #threadOfAllProjects}.
		#-.
		{'First project in thread' translated.  #firstPage}.
		{'Last project in thread' translated.  #lastPage}
	}.

	(target := self currentIndex + 2) > listOfPages size ifFalse: [
		aMenu 
			add: ('skip over next project ({1})' translated format:{(listOfPages at: target - 1) first})
			action: #skipOverNext
	].

	aMenu addList: {
		{'jump within this thread' translated.  #jumpWithinThread}.
		{'insert new project' translated.  #insertNewProject}.
		#-.
		{'simply close this navigator' translated.  #delete}.
		{'destroy this thread' translated. #destroyThread}.
		#-
	}.

	(self currentWorld keyboardNavigationHandler == self) ifFalse:[
		aMenu add: 'start keyboard navigation with this thread' translated action: #startKeyboardNavigation
	]
	ifTrue: [
		aMenu add: 'stop keyboard navigation with this thread' translated action: #stopKeyboardNavigation
	].

	aMenu popUpInWorld.
]

{ #category : #navigation }
InternalThreadNavigationMorph >> myThumbnailSize [
	^ (52 @ 39 * self sizeRatio) rounded
]

{ #category : #navigation }
InternalThreadNavigationMorph >> positionAppropriately [

	| others world otherRects overlaps bottomRight |
	(self ownerThatIsA: HandMorph) ifNotNil: [^self].
	others := (world := Project currentWorld) submorphs select: [ :each | each ~~ self and: [each isKindOf: self class]].
	otherRects := others collect: [ :each | each bounds].
	bottomRight := (world hasProperty: #threadNavigatorPosition)
		ifTrue: [world valueOfProperty: #threadNavigatorPosition]
		ifFalse: [world bottomRight].
	self align: self fullBounds bottomRight with: bottomRight.
	self setProperty: #previousWorldBounds toValue: self world bounds.

	[
		overlaps := false.
		otherRects do: [ :r |
			(r intersects: bounds) ifTrue: [overlaps := true. self bottom: r top].
		].
		self top < self world top ifTrue: [
			self bottom: bottomRight y.
			self right: self left - 1.
		].
		overlaps
	] whileTrue.
]

{ #category : #menu }
InternalThreadNavigationMorph >> showMenuFor: actionSelector event: evt [

	self perform: actionSelector

]

{ #category : #accessing }
InternalThreadNavigationMorph >> sizeRatio [
	"answer the size ratio for the receiver"
	
	^ 1.0

	"^ Preferences standardMenuFont height / 12"    "Good grief!"
]

{ #category : #navigation }
InternalThreadNavigationMorph >> skipOverNext [
	
	| target |

	(target := self currentIndex + 2) > listOfPages size ifTrue: [^Beeper beep].
	currentIndex := target.
	self loadPageWithProgress.

]

{ #category : #navigation }
InternalThreadNavigationMorph >> startKeyboardNavigation [
	"Tell the active world to starting navigating via desktop keyboard navigation via me"

	self currentWorld keyboardNavigationHandler: self
]

{ #category : #stepping }
InternalThreadNavigationMorph >> step [

	super step.
	(self valueOfProperty: #previousWorldBounds) = self world bounds ifFalse: [
		self positionAppropriately.
	].
	self class knownThreads
		at: threadName
		ifPresent: [ :known |
			known == listOfPages ifFalse: [
				listOfPages := known.
				self removeAllMorphs.
				self addButtons.
			].
		].

]

{ #category : #navigation }
InternalThreadNavigationMorph >> stopKeyboardNavigation [
	"Cease navigating via the receiver in response to desktop keystrokes"

	self currentWorld removeProperty: #keyboardNavigationHandler
]

{ #category : #navigation }
InternalThreadNavigationMorph >> switchToThread: newName [

	threadName := newName.
	listOfPages := self class knownThreads at: threadName.
	self removeAllMorphs.
	self addButtons.
	self currentIndex.

]

{ #category : #navigation }
InternalThreadNavigationMorph >> threadName [

	^threadName
]

{ #category : #navigation }
InternalThreadNavigationMorph >> threadName: aString index: anInteger [

	threadName := aString.
	preferredIndex := anInteger.
	self currentIndex.
]

{ #category : #navigation }
InternalThreadNavigationMorph >> threadOfAllProjects [

	| nameList nav |

	nameList := Project allMorphicProjects collect: [ :each | {each name}].
	nav := self class basicNew.
	nav
		listOfPages: nameList;
		threadName: '' index: nil;
		initialize.
	nav editThisThread.

]

{ #category : #navigation }
InternalThreadNavigationMorph >> threadOfNoProjects [

	| nameList nav |

	nameList := { {Project current name} }.
	nav := self class basicNew.
	nav
		listOfPages: nameList;
		threadName: '' index: nil;
		initialize.
	nav editThisThread.

]

{ #category : #'piano rolls' }
InternalThreadNavigationMorph >> triggerActionFromPianoRoll [
	
	WorldState addDeferredUIMessage: 
			[ | proj |
			self currentIndex >= listOfPages size 
				ifTrue: [Beeper beep]
				ifFalse: 
					[currentIndex := self currentIndex + 1.
					proj := Project named: ((listOfPages at: currentIndex) first).
					proj world setProperty: #letTheMusicPlay toValue: true.
					proj enter]]
]
