"
A package browser represents a hierarchical query path through an organization of class and method information.   It parses class categories into a two-level hierarchy on the first '-' character, giving ""packages"" (e.g.,  Magnitude, Collections, Graphics, etc.), and ""categories"" (e.g., Magnitude-General and Magnitude-Number).

Instance Variables:
	package  <Symbol> the ""category header,"" e.g., #Magnitudes or #Collections
	packageListIndex <Integer> The index in the package list
	packageList  <OrderedCollection of String> the list of package names

"
Class {
	#name : #PackagePaneBrowser,
	#superclass : #Browser,
	#instVars : [
		'package',
		'packageListIndex',
		'packageList'
	],
	#category : #'Tools-Browser'
}

{ #category : #'class initialization' }
PackagePaneBrowser class >> registerInAppRegistry [
	"Register the receiver in the SystemBrowser AppRegistry"
	SystemBrowser register: self.
]

{ #category : #toolbuilder }
PackagePaneBrowser >> buildDefaultBrowserWith: builder [
	"assemble the spec for a full 5-pane browser - package, category, class, protocol & message lists, build it and return the built but not opened morph.
	the build-but-don't-open phase is factored out to support the prototypicalToolWindow facility"

	"PackagePaneBrowser fullOnClass: Browser."

	| max windowSpec |
 	max := self wantsOptionalButtons ifTrue:[0.42] ifFalse:[0.5].
	windowSpec := self buildWindowWith: builder specs: {
		(0@0 corner: 0.15@max) -> [self buildPackageListWith: builder].
		(0.15@0 corner: 0.35@max) -> [self buildSystemCategoryListWith: builder].
		(self classListFrame: max fromLeft: 0.35 width: 0.25) -> [self buildClassListWith: builder].
		(self switchesFrame: max fromLeft: 0.35 width: 0.25) -> [self buildSwitchesWith: builder].
		(0.6@0 corner: 0.75@max) -> [self buildMessageCategoryListWith: builder].
		(0.75@0 corner: 1@max) -> [self buildMessageListWith: builder].
		(0@max corner: 1@1) -> [self buildCodePaneWith: builder].
	}.
	self setMultiWindowFor:windowSpec.

	^builder build: windowSpec
]

{ #category : #toolbuilder }
PackagePaneBrowser >> buildPackageListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #packageList; 
		getIndex: #packageListIndex; 
		setIndex: #packageListIndex:; 
		menu: #packageMenu:; 
		keyPress: #packageListKey:from:.
	^listSpec

]

{ #category : #'package list' }
PackagePaneBrowser >> categoryExistsForPackage [
	^ self hasPackageSelected
		and: [(systemOrganizer categories indexOf: self package asSymbol) ~= 0]

]

{ #category : #dragNDrop }
PackagePaneBrowser >> changeCategoryForClass: class srcSystemCategory: srcSystemCategorySel atListMorph: dstListMorph internal: internal copy: copyFlag [ 
	"only move semantic"
	| newClassCategory success |
	self flag: #stringSymbolProblem.
	success := copyFlag not ifFalse: [^ false].
	newClassCategory := self dstCategoryDstListMorph: dstListMorph internal: internal.
	(success := newClassCategory notNil & (newClassCategory ~= class category))
		ifTrue: 
			[class category: newClassCategory.
			self changed: #classList.
			internal ifFalse: [self selectClass: class]].
	^ success
]

{ #category : #'class list' }
PackagePaneBrowser >> classList [
	"Answer an array of the class names of the selected category. Answer an 
	empty array if no selection exists."

	^ self hasSystemCategorySelected 
		ifFalse: [self packageClasses]
		ifTrue: [systemOrganizer listAtCategoryNamed: self selectedSystemCategory]
]

{ #category : #'initialize-release' }
PackagePaneBrowser >> defaultBrowserTitle [
	^ 'Package Browser'
]

{ #category : #'user interface' }
PackagePaneBrowser >> defaultWindowColor [
	^ (Color r: 0.9 g: 0.9 b: 0.63)
]

{ #category : #'dragNDrop util' }
PackagePaneBrowser >> dstCategoryDstListMorph: dstListMorph internal: internal [ 
	| dropItem |
	^ internal & (dstListMorph getListSelector == #systemCategoryList)
		ifTrue: [(dropItem := dstListMorph potentialDropItem) ifNotNil: [(self package , '-' , dropItem) asSymbol]]
		ifFalse: [self selectedSystemCategory]
]

{ #category : #'package list' }
PackagePaneBrowser >> hasPackageSelected [

	^ packageListIndex ~= 0
]

{ #category : #'system category list' }
PackagePaneBrowser >> hasSystemCategorySelected [
	^ super selectedSystemCategory notNil.
]

{ #category : #'multi-window support' }
PackagePaneBrowser >> isPackage [
	^true
]

{ #category : #'initialize-release' }
PackagePaneBrowser >> labelString [
	^self package
		ifNil: [super labelString]
		ifNotNil:
			[:pkg| | label |
			label := self defaultBrowserTitle, ': ', pkg, (self selectedClass
														ifNil: ['']
														ifNotNil: [' ', self selectedClass printString]).
			(self multiWindowState notNil
			 and: [self multiWindowState models size > 1]) ifTrue:
				[label := (self multiWindowState models indexOf: self) printString, '. ', label].
			label]
]

{ #category : #'package list' }
PackagePaneBrowser >> mainPackageMenu: aMenu [
	"Answer a Menu of operations on class packages to be 
	displayed when the operate menu button is pressed."
	<packageListMenu>
	^aMenu addList: #(
			('find class...'		findClass)
			('recent classes...'	recent)
			-
			('reorganize'		editSystemCategories)
			('update'			updatePackages));
		yourself.

]

{ #category : #'multi-window support' }
PackagePaneBrowser >> multiWindowName [
	"Answer the string to display for the receiver in a multi-window."
	^String streamContents:
		[:s| | str |
		self package
			ifNil: [s nextPut: $a; space; nextPutAll: self defaultBrowserTitle]
			ifNotNil:
				[:pkg|
				 self selectedClass
					ifNil: [self selectedSystemCategory
							ifNil: [s nextPutAll: pkg]
							ifNotNil: [:cat| s nextPutAll: cat]]
					ifNotNil:
						[:class|
						 s nextPutAll: pkg; space; print: class.
						 self metaClassIndicated ifTrue:
							[s nextPutAll: ' class']]].
		(str := self selectedMessageName) notNil
			ifTrue: [s nextPutAll: '>>'; nextPutAll: str]
			ifFalse:
				[(str := self selectedMessageCategoryName) notNil
					ifTrue: [s space; nextPut: ${; nextPutAll: str; nextPut: $}]]]
]

{ #category : #'multi-window support' }
PackagePaneBrowser >> multiWindowNameForState: savedStateMessage [
	"Answer the string to display for the receiver in a multi-window."
	| getarg |
	getarg := [:keyword| savedStateMessage arguments at: (savedStateMessage selector keywords indexOf: keyword)].
	^String streamContents:
		[:s|
		(getarg value: 'restoreToPackage:')
			ifNil: [s nextPut: $a; space; nextPutAll: self defaultBrowserTitle]
			ifNotNil:
				[:pkg|
				 s nextPutAll: pkg.
				(getarg value: 'className:')
					ifNil: [(getarg value: 'category:') ifNotNil:
							[:categoryName| s nextPut: $-; nextPutAll: categoryName]]
					ifNotNil:
						[:className|
						s space; nextPutAll: className.
						(getarg value: 'meta:') ifTrue:
							[s nextPutAll: ' class'].
						  self isHierarchy ifTrue:
							[s space; nextPutAll: ' Hierarchy'].
						(getarg value: 'selector:')
							ifNil: [(getarg value: 'protocol:') ifNotNil:
									[:protocol| s space; nextPut: ${; nextPutAll: protocol; nextPut: $}]]
							ifNotNil: [:selector| s nextPutAll: '>>'; nextPutAll: selector]]]]
]

{ #category : #'package list' }
PackagePaneBrowser >> package [
	"Answer the receiver's 'package'."

	^ self hasPackageSelected
		ifFalse: [nil]
		ifTrue: [self packageList at: packageListIndex]

]

{ #category : #'class list' }
PackagePaneBrowser >> packageClasses [
	^ self categoryExistsForPackage
		ifFalse: [Array new]
		ifTrue:
			[systemOrganizer listAtCategoryNumber:
				(systemOrganizer categories indexOf: self package asSymbol)]
]

{ #category : #'package list' }
PackagePaneBrowser >> packageList [
	"Answer a list of the packages in the current system organization."

	| str stream |
	str := Set new: 100.
	stream := WriteStream on: (Array new: 100).
	systemOrganizer categories do:
		[ :categ | | cats | 
		cats := categ asString copyUpTo: $-.
		(str includes: cats) ifFalse: 
			[str add: cats.
			stream nextPut: cats]].
	^stream contents
]

{ #category : #'package list' }
PackagePaneBrowser >> packageListIndex [
	"Answer the index of the current package selection."

	^packageListIndex
]

{ #category : #'package list' }
PackagePaneBrowser >> packageListIndex: anInteger [ 
	"Set anInteger to be the index of the current package selection."

	packageListIndex := anInteger.
	anInteger = 0
		ifFalse: [package := self packageList at: packageListIndex].
	selectedMessageCategoryName := nil.
	self selectSystemCategory: nil.
	selectedMessageName := nil.
	selectedClassName := nil.
	self setClassOrganizer.
	self changed: #packageSelectionChanged.
	self changed: #packageListIndex.	"update my selection"
	self changed: #systemCategoryList.	"update the category list"
	self selectSystemCategory: nil.	"update category list selection"

]

{ #category : #'package list' }
PackagePaneBrowser >> packageListKey: aChar from: view [
	aChar == $f ifTrue: [^ self findClass].
	^ self classListKey: aChar from: view
]

{ #category : #'package list' }
PackagePaneBrowser >> packageMenu: aMenu [

	^ self menu: aMenu for: #(packageListMenu packageListMenuShifted:)
]

{ #category : #'multi-window support' }
PackagePaneBrowser >> restoreToPackage: packageNameOrNil category: category className: className protocol: protocol selector: selector mode: editMode meta: metaBool [
	self packageListIndex: (self packageList indexOf: packageNameOrNil).
	super restoreToCategory: category className: className protocol: protocol selector: selector mode: editMode meta: metaBool
]

{ #category : #'multi-window support' }
PackagePaneBrowser >> saveMultiWindowState [
	^Message
		selector: #restoreToPackage:category:className:protocol:selector:mode:meta:
		arguments: {	self package.
						self selectedSystemCategory.
						self selectedClassName.
						self selectedMessageCategoryName.
						self selectedMessageName.
						self editSelection.
						self metaClassIndicated }
]

{ #category : #'system category list' }
PackagePaneBrowser >> selectCategoryForClass: theClass [
	"Set the package and category lists to display the given class."

	| cat catName |
	cat := theClass category.
	self packageListIndex: (self packageList indexOf: (cat copyUpTo: $-)).
	catName := (cat copyFrom: ((cat indexOf: $-) + 1) to: cat size).
	self selectSystemCategory: catName.
]

{ #category : #'class list' }
PackagePaneBrowser >> selectedClass [
	"Answer the class that is currently selected. Answer nil if no selection 
	exists."

	| name envt |
	(name := self selectedClassName) ifNil: [^ nil].
	"(envt := self selectedEnvironment) ifNil: [^ nil]."
	envt:= Smalltalk.
	^ envt at: name
]

{ #category : #'system category list' }
PackagePaneBrowser >> selectedSystemCategory [
	"Answer the name of the selected system category or nil."

	self hasSystemCategorySelected
		ifFalse: [^nil].
	packageListIndex = 0
		ifTrue: [^ super selectedSystemCategory ].
	^ self package , '-' , super selectedSystemCategory
]

{ #category : #'system category list' }
PackagePaneBrowser >> systemCategoryList [
	"Answer the sequenceable collection containing the class categories that 
	the receiver accesses."

	| prefix |
	packageListIndex = 0 ifTrue: [^ systemOrganizer categories].
	prefix := self package, '-'.
	^ Array streamContents:
		[:strm |
		systemOrganizer categories do: 
			[ :cat | (cat beginsWith: prefix) ifTrue:
				[strm nextPut: (cat copyFrom: prefix size + 1 to: cat size)]]]
]

{ #category : #'system category list' }
PackagePaneBrowser >> systemCategoryListIndex [
	"Answer the index of the selected class category."

	^ self systemCategoryList indexOf: super selectedSystemCategory.
]

{ #category : #'initialize-release' }
PackagePaneBrowser >> systemOrganizer: aSystemOrganizer [ 
	"Initialize the receiver as a perspective on the system organizer, 
	aSystemOrganizer. Typically there is only one--the system variable 
	SystemOrganization."

	super systemOrganizer: aSystemOrganizer .
	packageListIndex := 0
]

{ #category : #'package list' }
PackagePaneBrowser >> updatePackages [
	"Update the contents of the package list."

	self editSelection: #none.
	self changed: #packageList.
	self changed: #package.
	self packageListIndex: 0 
]
