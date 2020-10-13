"
I provide facilities to explore classes in the context of their subclass hierarchy.

My classDisplayList instvar uses indentation to show the subclassing relationship between the displayed classes.

"
Class {
	#name : #HierarchyBrowser,
	#superclass : #Browser,
	#instVars : [
		'classDisplayList',
		'centralClass'
	],
	#category : #'Tools-Browser'
}

{ #category : #'instance creation' }
HierarchyBrowser class >> openBrowser [
	"Open a default hierarchy browser on Object - ie the entire class tree, so it may take a moment -  with class/protocol/message lists"
	"HierarchyBrowser openBrowser"
	| newBrowser |
	newBrowser := self new initHierarchyForClass: Object.
	^ newBrowser buildAndOpenBrowserLabel: nil

]

{ #category : #toolbuilder }
HierarchyBrowser >> buildAndOpenBrowserLabel: aLabelString [
	"assemble the spec for a class list/hierarchy browser, build it and open it"

	| builder window |
	builder := ToolBuilder default.

	window := self buildDefaultBrowserWith: builder.
	aLabelString ifNotNil: [:str | window label: str].

	builder open: window.
]

{ #category : #'menu messages' }
HierarchyBrowser >> buildClassBrowserEditString: aString [ 
	"Open a hierarchy browser on the currently selected class; the string has to be ignored in this case"

	self spawnHierarchy
]

{ #category : #toolbuilder }
HierarchyBrowser >> buildDefaultBrowserWith: builder [
	"assemble the spec for a hierarchical browser, build it and return the built but not opened morph"
	"this build-but-don't-open phase is factored out to support the prototypicalToolWindow facility"

	| max windowSpec |


	self setupIfNotInitialisedYet. 
	max := self wantsOptionalButtons ifTrue:[0.32] ifFalse:[0.4].

	windowSpec := self buildWindowWith: builder specs: {
		(self classListFrame: max fromTop: 0 fromLeft: 0 width: 0.333) -> [self buildClassListWith: builder].
		(self switchesFrame: max fromLeft: 0 width: 0.333) -> [self buildSwitchesWith: builder].
		(LayoutFrame fractions: (0.333@0 corner: 0.666@max) offsets: (0@0 corner: 0@0)) -> [self buildMessageCategoryListWith: builder].
		(LayoutFrame fractions: (0.666@0 corner: 1@max) offsets: (0@0 corner: 0@0)) -> [self buildMessageListWith: builder].
		(0@max corner: 1@1) -> [self buildCodePaneWith: builder].
	}.
	self setMultiWindowFor:windowSpec.

	^builder build: windowSpec
]

{ #category : #'class list' }
HierarchyBrowser >> classList [
	"each time we update the class list make sure to check that all the classes we think we should display are in fact in the environment"
	classDisplayList := classDisplayList select: [:each | (self environment valueOf: each withBlanksTrimmed asSymbol) notNil].
	^ classDisplayList
]

{ #category : #initialization }
HierarchyBrowser >> classListIndex: newIndex [
	"Cause system organization to reflect appropriate category"
	| newClassName ind |
	newIndex ~= 0 ifTrue:
		[newClassName := (classDisplayList at: newIndex) copyWithout: $ .
		selectedSystemCategory := (systemOrganizer categories at:
			(systemOrganizer numberOfCategoryOfElement: newClassName)
			ifAbsent: [nil])].
	ind := super classListIndex: newIndex.

	"What I'd like to write:"
	"self selectedClassName ifNotNil:
		[ selectedSystemCategory := self selectedClass category ]."
	self changed: #systemCategorySingleton.
	^ ind
]

{ #category : #'class functions' }
HierarchyBrowser >> copyClass [

	super copyClass.
	self updateAfterClassChange.
]

{ #category : #initialization }
HierarchyBrowser >> defaultBrowserTitle [
	^ self selectedSystemCategoryName ifNil: [ 'Hierarchy Browser' ]
]

{ #category : #'class functions' }
HierarchyBrowser >> defineClass: defString notifying: aController [  

	super defineClass: defString notifying: aController.
	self updateAfterClassChange.
]

{ #category : #traits }
HierarchyBrowser >> defineTrait: defString notifying: aController [  

	super defineTrait: defString notifying: aController.
	self updateAfterClassChange.
]

{ #category : #initialization }
HierarchyBrowser >> initHierarchyForClass: aClassOrMetaClass [ 
	| nonMetaClass superclasses |
	centralClass := aClassOrMetaClass.
	nonMetaClass := aClassOrMetaClass theNonMetaClass.
	self selectEnvironment: aClassOrMetaClass environment.
	metaClassIndicated := aClassOrMetaClass isMeta.
	classDisplayList := OrderedCollection new.
	(superclasses := nonMetaClass allSuperclasses reversed) withIndexDo:
		[ : each : indent | classDisplayList add:
			(String streamContents:
				[ : stream | indent - 1 timesRepeat: [ stream nextPutAll: '  ' ].
				stream nextPutAll: each name ]) ].
	nonMetaClass
		allSubclassesWithLevelDo:
			[ : eachClass : lvl | classDisplayList add:
				(String streamContents:
					[ : stream | lvl timesRepeat: [ stream nextPutAll: '  ' ].
					stream nextPutAll: eachClass name ]) ]
		startingLevel: superclasses size.
		
	self changed: #classList.
	self selectClass: nonMetaClass
]

{ #category : #'multi-window support' }
HierarchyBrowser >> isHierarchy [
	"This almost certainly needs implementing in ClassListBrowser to return false"
	^true
]

{ #category : #'morphic ui' }
HierarchyBrowser >> postAcceptBrowseFor: aHierarchyBrowser [ 
	(aHierarchyBrowser selectedClass ~= self selectedClass or: [ aHierarchyBrowser selectedMessageName notNil ]) ifTrue: [ self selectMessageCategoryNamed: nil ].
	aHierarchyBrowser instanceMessagesIndicated
		ifTrue: [ self indicateInstanceMessages ]
		ifFalse: [ self indicateClassMessages ].
	self
		 selectClass: aHierarchyBrowser selectedClass ;
		 selectedMessageName: aHierarchyBrowser selectedMessageName ;
		 showHomeCategory
]

{ #category : #'menu messages' }
HierarchyBrowser >> removeSystemCategory [
	"If a class category is selected, create a Confirmer so the user can 
	verify that the currently selected class category and all of its classes
 	should be removed from the system. If so, remove it."

	self inform: 'Use a normal Browser, in which you can see 
the entire category you are trying to remove.'
]

{ #category : #'class functions' }
HierarchyBrowser >> renameClass [

	super renameClass.
	self updateAfterClassChange.
]

{ #category : #'morphic ui' }
HierarchyBrowser >> representsSameBrowseeAs: anotherModel [
	^ self hasUnacceptedEdits not
		and: [ classDisplayList size = anotherModel classList size
		and: [ classDisplayList includesAllOf: anotherModel classList ] ]
]

{ #category : #initialization }
HierarchyBrowser >> selectClassNamed: aSymbolOrString [
	| newClassName |
	newClassName := aSymbolOrString ifNotNil: [ aSymbolOrString asSymbol ].
	selectedSystemCategory := (systemOrganizer categories at:
			(systemOrganizer numberOfCategoryOfElement: newClassName) ifAbsent: [ nil ]).
			
	super selectClassNamed: newClassName.
	self changed: #systemCategorySingleton.	
	
	^ newClassName.
]

{ #category : #initialization }
HierarchyBrowser >> selectedClassName [
	"Answer the name of the class currently selected.   di
	  bug fix for the case where name cannot be found -- return nil rather than halt"

	| aName |
	aName := super selectedClassName.
	aName ifNil: [ ^ nil ].
	^ (aName copyWithout: Character space) asSymbol
]

{ #category : #initialization }
HierarchyBrowser >> setClass: aClass [ 
	self initHierarchyForClass: (centralClass ifNil: [ aClass ]).
	super setClass: aClass
]

{ #category : #toolbuilder }
HierarchyBrowser >> setupIfNotInitialisedYet [
	"HierarchyBrowser needs some initialisation to work in the ToolBuilder>build: world since there has to be a list of classes ready to be listed. As a default we use the full Object class tree"
	classDisplayList ifNil:[ self initHierarchyForClass: Object]
]

{ #category : #private }
HierarchyBrowser >> spawnOrNavigateTo: aClass [ 
	(aClass inheritsFrom: centralClass)
		ifTrue: [ super spawnOrNavigateTo: aClass ]
		ifFalse: [ self systemNavigation browseHierarchy: aClass ]
]

{ #category : #'menu messages' }
HierarchyBrowser >> systemCatSingletonKey: aChar from: aView [
	"This appears to be obsolete now that the hierarchybrowser has not category view"
	^ self systemCatListKey: aChar from: aView
]

{ #category : #'menu messages' }
HierarchyBrowser >> systemCatSingletonMenu: aMenu [
	"This appears to be obsolete now that the hierarchybrowser has not category view"
	^ aMenu labels:
'find class... (f)
browse
printOut
fileOut
update
rename...
remove' 
	lines: #(1 4)
	selections:
		#(findClass buildSystemCategoryBrowser
		printOutSystemCategory fileOutSystemCategory updateSystemCategories
		 renameSystemCategory removeSystemCategory )

]

{ #category : #initialization }
HierarchyBrowser >> systemCategorySingleton [

	| cls |
	cls := self selectedClass.
	^ cls ifNil: [Array new]
		ifNotNil: [Array with: cls category]
]

{ #category : #initialization }
HierarchyBrowser >> updateAfterClassChange [
	"It is possible that some the classes comprising the hierarchy have changed, so reinitialize the entire browser."

	| priorSelection |
	priorSelection := self selectedClassName.
	
	(centralClass notNil and: [centralClass isObsolete not])
		ifTrue: [self initHierarchyForClass: centralClass].
		
	(self classListIndexOf: priorSelection) > 0
		ifTrue: [self selectClassNamed: priorSelection].
]
