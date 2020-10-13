"
A variant package loader that uses a more-or-less standard Smalltalk-80 browser perspective of selecting categories in one pane and then selecting items within in the next pane.
You can open one with:

	SMLoaderCategorical open
"
Class {
	#name : #SMLoaderCategorical,
	#superclass : #SMLoader,
	#instVars : [
		'currentPackageList',
		'packagesListIndex'
	],
	#category : #SMLoader
}

{ #category : #'menu registration' }
SMLoaderCategorical class >> initialize [
	Smalltalk at: #ToolBuilder ifAbsent: [
	(TheWorldMenu respondsTo: #registerOpenCommand:)
		ifTrue: [TheWorldMenu registerOpenCommand: {self openMenuString. {self. #open}}]]
]

{ #category : #'menu registration' }
SMLoaderCategorical class >> openMenuString [
	^ 'SqueakMap Categories'
]

{ #category : #'menu registration' }
SMLoaderCategorical class >> removeFromSystem [
	(TheWorldMenu respondsTo: #registerOpenCommand:)
		ifTrue: [TheWorldMenu unregisterOpenCommand: self openMenuString].
	self removeFromSystem: true
]

{ #category : #'menu registration' }
SMLoaderCategorical class >> unload [
	(TheWorldMenu respondsTo: #registerOpenCommand:) ifTrue: 
		[TheWorldMenu unregisterOpenCommand: self openMenuString].
]

{ #category : #interface }
SMLoaderCategorical >> buildMorphicInstalledPackagesList [
	| list |
	(list := PluggableListMorph new)
		on: self
		list: #installedPackageNameList
		selected: #installedPackagesListIndex
		changeSelected: #installedPackagesListIndex:
		menu: #packagesMenu:
		keystroke: #packagesListKey:from:.
	^ list
]

{ #category : #interface }
SMLoaderCategorical >> buildMorphicNotInstalledPackagesList [
	| list |
	(list := PluggableListMorph new)
		on: self
		list: #notInstalledPackageNameList
		selected: #notInstalledPackagesListIndex
		changeSelected: #notInstalledPackagesListIndex:
		menu: #packagesMenu:
		keystroke: #packagesListKey:from:.
	^ list
]

{ #category : #interface }
SMLoaderCategorical >> createFancyWindow [
	"Creates a variant of the window where the package pane is split between installed and uninstalled packages."
	| buttonBarHeight searchHeight vertDivide horizDivide |
	buttonBarHeight := 0.07.
	searchHeight := 0.07.
	vertDivide := 0.5.
	horizDivide := 0.6.
	self addMorph: (self buildButtonBar borderWidth: 0)
		frame: (0 @ 0 corner: 1 @ buttonBarHeight).
	self addMorph: (self buildSearchPane borderWidth: 0)
		frame: (0 @ buttonBarHeight corner: vertDivide @ searchHeight).
	self addMorph: (self buildMorphicCategoriesList borderWidth: 0)
		frame: (0 @ (buttonBarHeight + searchHeight) corner: vertDivide @ horizDivide).
	self addMorph: (self buildMorphicNotInstalledPackagesList borderWidth: 0)
		frame: (vertDivide @ buttonBarHeight corner: 1 @ (horizDivide / 2)).
	self addMorph: (self buildMorphicInstalledPackagesList borderWidth: 0)
		frame: (vertDivide @ (horizDivide / 2) corner: 1 @ horizDivide).
	self addMorph: (self buildPackagePane borderWidth: 0)
		frame: (0 @ horizDivide corner: 1 @ 1).
	self on: #mouseEnter send: #paneTransition: to: self.
	self on: #mouseLeave send: #paneTransition: to: self.
	self setUpdatablePanesFrom: #(#installedPackageNameList #notInstalledPackageNameList ).
	currentPackageList := #notInstalled.
	self setLabel: self defaultLabel
]

{ #category : #interface }
SMLoaderCategorical >> createWindow [
	| buttonBarHeight searchHeight vertDivide horizDivide |
	buttonBarHeight := 0.07.
	searchHeight := 0.07.
	vertDivide := 0.5.
	horizDivide := 0.6.
	self addMorph: (self buildButtonBar borderWidth: 0)
		frame: (0 @ 0 corner: 1 @ buttonBarHeight).
	self addMorph: (self buildMorphicCategoriesList borderWidth: 0)
		frame: (0 @ buttonBarHeight corner: vertDivide @ horizDivide).
	self addMorph: (self buildSearchPane borderWidth: 0)
		frame: (vertDivide @ buttonBarHeight corner: 1 @ (buttonBarHeight + searchHeight)).
	self addMorph: (self buildMorphicPackagesList borderWidth: 0)
		frame: (vertDivide @ (buttonBarHeight + searchHeight) corner: 1 @ horizDivide).
	self addMorph: (self buildPackagePane borderWidth: 0)
		frame: (0 @ horizDivide corner: 1 @ 1).
	self on: #mouseEnter send: #paneTransition: to: self.
	self on: #mouseLeave send: #paneTransition: to: self.
	self setLabel: self defaultLabel
]

{ #category : #accessing }
SMLoaderCategorical >> currentPackageList [
	^currentPackageList
]

{ #category : #accessing }
SMLoaderCategorical >> currentPackageList: aSymbol [
	currentPackageList := aSymbol.
	self changed: #installButtonLabel.
]

{ #category : #interface }
SMLoaderCategorical >> defaultLabel [
	^ 'SqueakMap Categorical Package Loader'
]

{ #category : #interface }
SMLoaderCategorical >> installButtonLabel [
	^ self currentPackageList = #notInstalled
		ifTrue: ['Install the above package']
		ifFalse: ['Remove the above package']
]

{ #category : #lists }
SMLoaderCategorical >> installedPackageNameList [
	^self packageList select: [:e | e isInstalled]
]

{ #category : #accessing }
SMLoaderCategorical >> installedPackagesListIndex [
	self currentPackageList = #installed
		ifTrue: [^ self packagesListIndex]
		ifFalse: [^ 0]
]

{ #category : #accessing }
SMLoaderCategorical >> installedPackagesListIndex: anObject [ 
	packagesListIndex := anObject.
	self currentPackageList ~= #installed
		ifTrue: [self currentPackageList: #installed.
			self changed: #currentPackageList].
	self noteChanged
]

{ #category : #accessing }
SMLoaderCategorical >> isOn [
	^false
]

{ #category : #lists }
SMLoaderCategorical >> notInstalledPackageNameList [
	^self packageList select: [:e | e isInstalled not]
]

{ #category : #accessing }
SMLoaderCategorical >> notInstalledPackagesListIndex [
	self currentPackageList = #notInstalled
		ifTrue: [^ self packagesListIndex]
		ifFalse: [^ 0]
]

{ #category : #accessing }
SMLoaderCategorical >> notInstalledPackagesListIndex: anObject [ 
	packagesListIndex := anObject.
	self currentPackageList ~= #notInstalled ifTrue:
		[self currentPackageList: #notInstalled.
		 self changed: #currentPackageList].
	self changed: #packagesListIndex.
	"update my selection"
	self noteChanged.
	self contentsChanged
]

{ #category : #private }
SMLoaderCategorical >> noteChanged [
	self changed: #installedPackageNameList.
	self changed: #notInstalledPackageNameList.
	super noteChanged."
	self changed: #packageNameList.
	self changed: #packagesListIndex.
	self changed: #categoriesForPackage.
	self contentsChanged."
]

{ #category : #lists }
SMLoaderCategorical >> packageList [
	^ self packages
		select: [:e | (e categories
					anySatisfy: [:cat | cat = self selectedCategory])
				and: [(filters ifNil: [#()])
						allSatisfy: [:currFilter | (self perform: currFilter)
								value: e]]]
]
