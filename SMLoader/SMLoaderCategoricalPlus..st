"
A variant package loader that uses a more-or-less standard Smalltalk-80 browser perspective of selecting categories in one pane and then selecting items within in the next pane.
You can open one with:

	SMLoaderCategoricalPlus open
"
Class {
	#name : #SMLoaderCategoricalPlus,
	#superclass : #SMLoaderPlus,
	#instVars : [
		'currentPackageList',
		'packagesListIndex'
	],
	#category : #SMLoader
}

{ #category : #'menu registration' }
SMLoaderCategoricalPlus class >> initialize [
	Smalltalk at: #ToolBuilder ifPresent: [:tb |
		(TheWorldMenu respondsTo: #registerOpenCommand:)
			ifTrue: [TheWorldMenu registerOpenCommand: {self openMenuString. {self. #open}}]]
]

{ #category : #'menu registration' }
SMLoaderCategoricalPlus class >> openMenuString [
	^ 'SqueakMap Categories'
]

{ #category : #'menu registration' }
SMLoaderCategoricalPlus class >> removeFromSystem [
	(TheWorldMenu respondsTo: #registerOpenCommand:)
		ifTrue: [TheWorldMenu unregisterOpenCommand: self openMenuString].
	self removeFromSystem: true
]

{ #category : #'menu registration' }
SMLoaderCategoricalPlus class >> unload [
	(TheWorldMenu respondsTo: #registerOpenCommand:) ifTrue: 
		[TheWorldMenu unregisterOpenCommand: self openMenuString].
]

{ #category : #DEPRECATED }
SMLoaderCategoricalPlus >> buildFancyWith: aBuilder [
	"Creates a variant of the window where the package pane is split between installed and uninstalled packages."
	| buttonBarHeight searchHeight vertDivide horizDivide |
	buttonBarHeight := 0.07.
	searchHeight := 0.07.
	vertDivide := 0.5.
	horizDivide := 0.6.
	builder := aBuilder.
	window := builder build: (builder pluggableWindowSpec new model: self;
				label: #label;
				children: (OrderedCollection new add:
				((self buildButtonBarWith: builder)
					frame: (0 @ 0 corner: 1 @ buttonBarHeight); yourself);
				add: ((self buildCategoriesListWith: builder)
					frame: (0 @ buttonBarHeight corner: vertDivide @ horizDivide); yourself);
				add: ((self buildSearchPaneWith: builder)
					frame: (vertDivide @ buttonBarHeight corner: 1 @ (buttonBarHeight + searchHeight)); yourself);
				add: ((self buildNotInstalledPackagesListWith: builder)
					frame: (vertDivide @ (buttonBarHeight + searchHeight) corner: 1 @ (horizDivide / 2)); yourself);
				add: ((self buildInstalledPackagesListWith: builder)
					frame: (vertDivide @ (horizDivide / 2) corner: 1 @ horizDivide); yourself);
				add: ((self buildPackagePaneWith: builder)
					frame: (0 @ horizDivide corner: 1 @ 1); yourself); yourself)).
	window on: #mouseEnter send: #paneTransition: to: window.
	window on: #mouseLeave send: #paneTransition: to: window.
	self setUpdatablePanesFrom: #(#installedPackageList #notInstalledPackageList ).
	currentPackageList := #notInstalled.
	window extent: self initialExtent.
	^ window
]

{ #category : #DEPRECATED }
SMLoaderCategoricalPlus >> buildInstalledPackagesListWith: aBuilder [
	^ aBuilder pluggableTreeSpec new model: self;
		 roots: #installedPackageList;
		 getSelectedPath: #selectedItemPath;
		 getSelected: #selectedItem;
		 setSelected: #selectedItem:;
		 menu: #packagesMenu:;
		 label: #itemLabel:;
		 getChildren: #itemChildren:;
		 hasChildren: #itemHasChildren:;
		 autoDeselect: true;
		 yourself
]

{ #category : #DEPRECATED }
SMLoaderCategoricalPlus >> buildNotInstalledPackagesListWith: aBuilder [
	^ aBuilder pluggableTreeSpec new model: self;
		 roots: #notInstalledPackageList;
		 getSelectedPath: #selectedItemPath;
		 getSelected: #selectedItem;
		 setSelected: #selectedItem:;
		 menu: #packagesMenu:;
		 label: #itemLabel:;
		 getChildren: #itemChildren:;
		 hasChildren: #itemHasChildren:;
		 autoDeselect: true;
		 yourself
]

{ #category : #interface }
SMLoaderCategoricalPlus >> buildWith: aBuilder [
	| buttonBarHeight searchHeight vertDivide horizDivide |
	buttonBarHeight := Preferences standardButtonFont height * 2.
	searchHeight := Preferences standardDefaultTextFont height * 2.
	vertDivide := 0.5.
	horizDivide := 0.6.
	builder := aBuilder.
	window := builder build: (builder pluggableWindowSpec new model: self;
				label: #label;
				children:  (OrderedCollection new
						add: ((self buildButtonBarWith: builder)
							frame: (LayoutFrame
								fractions: (0 @ 0 corner: 1 @ 0)
								offsets: (0@0 corner: 0@buttonBarHeight)));
						add: ((self buildCategoriesListWith: builder)
							frame: (LayoutFrame
								fractions: (0 @ 0 corner: vertDivide @ horizDivide)
								offsets: (0@ buttonBarHeight corner: 0@0)));
						add: ((self buildSearchPaneWith: builder)
							frame: (LayoutFrame
								fractions: (vertDivide @ 0 corner: 1 @ 0)
								offsets: (0@ buttonBarHeight corner: 0@ (buttonBarHeight + searchHeight))));
						add: ((self buildPackagesListWith: builder)
							frame: (LayoutFrame
								fractions: (vertDivide @ 0 corner: 1 @ horizDivide)
								offsets: (0 @ (buttonBarHeight + searchHeight) corner: 0@0)));
						add: ((self buildPackagePaneWith: builder)
								frame: (0 @ horizDivide corner: 1 @ 1));
						 yourself);
					 yourself).
	window on: #mouseEnter send: #paneTransition: to: window.
	window on: #mouseLeave send: #paneTransition: to: window.
	window extent: self initialExtent.
	^ window
]

{ #category : #accessing }
SMLoaderCategoricalPlus >> currentPackageList [
	^currentPackageList
]

{ #category : #accessing }
SMLoaderCategoricalPlus >> currentPackageList: aSymbol [
	currentPackageList := aSymbol.
	self changed: #installButtonLabel.
]

{ #category : #interface }
SMLoaderCategoricalPlus >> defaultLabel [
	^ 'Categorical ' , super defaultLabel
]

{ #category : #interface }
SMLoaderCategoricalPlus >> installButtonLabel [
	^ self currentPackageList = #notInstalled
		ifTrue: ['Install the above package']
		ifFalse: ['Remove the above package']
]

{ #category : #lists }
SMLoaderCategoricalPlus >> installedPackageList [
	^self packageList select: [:e | e isInstalled]
]

{ #category : #accessing }
SMLoaderCategoricalPlus >> installedPackagesListIndex [
	^ self currentPackageList = #installed
		ifTrue: [self packagesListIndex]
		ifFalse: [0]
]

{ #category : #accessing }
SMLoaderCategoricalPlus >> installedPackagesListIndex: anObject [ 
	packagesListIndex := anObject.
	self currentPackageList ~= #installed
		ifTrue: [self currentPackageList: #installed.
			self changed: #currentPackageList].
	self noteChanged
]

{ #category : #accessing }
SMLoaderCategoricalPlus >> isOn [
	^false
]

{ #category : #lists }
SMLoaderCategoricalPlus >> notInstalledPackageList [
	^self packageList reject: [:e | e isInstalled]
]

{ #category : #accessing }
SMLoaderCategoricalPlus >> notInstalledPackagesListIndex [
	^ self currentPackageList = #notInstalled
		ifTrue: [self packagesListIndex]
		ifFalse: [0]
]

{ #category : #accessing }
SMLoaderCategoricalPlus >> notInstalledPackagesListIndex: anObject [ 
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
SMLoaderCategoricalPlus >> noteChanged [
	self changed: #installedPackageList.
	self changed: #notInstalledPackageList.
	super noteChanged."
	self changed: #packageNameList.
	self changed: #packagesListIndex.
	self changed: #categoriesForPackage.
	self contentsChanged."
]

{ #category : #lists }
SMLoaderCategoricalPlus >> packageList [
	^ self packages
		select: [:e | (e categories
					anySatisfy: [:cat | cat = self selectedCategory])
				and: [(filters ifNil: [#()])
						allSatisfy: [:currFilter | (self perform: currFilter)
								value: e]]]
]
