"
A simple package loader that is currently the standard UI for SqueakMap (the model is an SMSqueakMap instance). It uses ToolBuilder to construct its window. You can open one with:

	SMLoaderPlus open

Instance Variables
	categoriesToFilterIds:		<OrderedCollection> The set of categories to filter the packages list.
	filters:				<OrderedCollection> The set of filters to apply to the packages list.
	map:				<SMSqueakMap> The model SqueakMap.
	packagesList:		<OrderedCollection> The list of packages from the map.
	selectedCategory:	<SMCategory> The current category.
	selectedItem:			<SMPackage> The selected package or release.
	window:			<PluggableSystemWindow> The window, held only so we can reOpen.
"
Class {
	#name : #SMLoaderPlus,
	#superclass : #Model,
	#instVars : [
		'packagesList',
		'selectedItem',
		'selectedCategory',
		'filters',
		'categoriesToFilterIds',
		'map',
		'builder',
		'window'
	],
	#classVars : [
		'DefaultCategoriesToFilterIds',
		'DefaultFilters'
	],
	#category : #SMLoader
}

{ #category : #'parts bin' }
SMLoaderPlus class >> descriptionForPartsBin [
	^self partName: 'Package Loader'
		categories: #(Tools)
		documentation: 'SqueakMap UI'

]

{ #category : #'class initialization' }
SMLoaderPlus class >> initialize [
	"Hook us up in the world menu."
	"self initialize"
	Smalltalk
		at: #ToolBuilder
		ifPresent:
			[ : tb | self registerInFlapsRegistry.
			(TheWorldMenu respondsTo: #registerOpenCommand:) ifTrue:
				[ | oldCmds |
				oldCmds := TheWorldMenu registry select:
					[ : cmd | cmd first includesSubstring: 'Package Loader' ].
				oldCmds do:
					[ : cmd | TheWorldMenu unregisterOpenCommand: cmd first ].
				TheWorldMenu registerOpenCommand: {self openMenuString. 
					{self. 
					#open}} ] ].
	DefaultFilters := OrderedCollection new.
	DefaultCategoriesToFilterIds := OrderedCollection new
]

{ #category : #'new-morph participation' }
SMLoaderPlus class >> initializedInstance [
	^ (ToolBuilder open: self new) extent: 400@400
]

{ #category : #'instance creation' }
SMLoaderPlus class >> new [
	"Create a SqueakMap loader on the default map."

	^self newOn: SMSqueakMap default
]

{ #category : #'instance creation' }
SMLoaderPlus class >> newOn: aMap [
	"Create a SqueakMap loader on given map."

	^super new on: aMap; yourself
]

{ #category : #'new-morph participation' }
SMLoaderPlus class >> newStandAlone [
	^ ToolBuilder open: self new
]

{ #category : #'instance creation' }
SMLoaderPlus class >> open [
	"Create and open a SqueakMap Loader."
	
	"SMLoaderPlus open"

	^ (Smalltalk at: #ToolBuilder) open: self new
]

{ #category : #'class initialization' }
SMLoaderPlus class >> openMenuString [
	^ 'SqueakMap Catalog'
]

{ #category : #'instance creation' }
SMLoaderPlus class >> openOn: aSqueakMap [
	"Create and open a SqueakMap Loader on a given map."

	"self openOn: SqueakMap default"

	^ (Smalltalk at: #ToolBuilder) open: (self newOn: aSqueakMap)
]

{ #category : #'new-morph participation' }
SMLoaderPlus class >> prototypicalToolWindow [
	"Do not update when creating a prototype window (used by flaps etc)"

	^[(ToolBuilder open: self new) applyModelExtent; yourself] 
		valueSupplyingAnswers:{ {'*map on disk*'. false}}
]

{ #category : #'new-morph participation' }
SMLoaderPlus class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry."

	self environment
		at: #Flaps
		ifPresent: [:cl | (cl respondsTo: #registerQuad:forFlapNamed:)
				ifTrue: [cl registerQuad: #(#SMLoader #prototypicalToolWindow 'Package Loader' 'The SqueakMap Package Loader' ) forFlapNamed: 'Tools']]
]

{ #category : #'class initialization' }
SMLoaderPlus class >> setDefaultFilters: anOrderedCollection [
	DefaultFilters := anOrderedCollection
]

{ #category : #'class initialization' }
SMLoaderPlus class >> unload [
	(TheWorldMenu respondsTo: #registerOpenCommand:) ifTrue: 
		[TheWorldMenu unregisterOpenCommand: self openMenuString].
	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #menus }
SMLoaderPlus >> addFiltersToMenu: aMenu [
	| filterSymbol help |
	self filterSpecs do: [:filterArray | 
		filterSymbol := filterArray second.
		help := filterArray third.
		aMenu addUpdating: #showFilterString: target: self selector: #toggleFilterState: argumentList: (Array with: filterSymbol).
		aMenu balloonTextForLastItem: help].
	aMenu addLine;
		addList: #(('Clear all filters' uncheckFilters 'Unchecks all filters to list all packages'))
	
]

{ #category : #actions }
SMLoaderPlus >> addSelectedCategoryAsFilter [
	"Add a new filter that filters on the currently selected category.
	Make it enabled as default."

	categoriesToFilterIds add: self selectedCategory id
]

{ #category : #interface }
SMLoaderPlus >> browseCacheDirectory [
	"Open a FileList2 on the directory for the package or release."
	| item dir win |
	item := self selectedPackageOrRelease
				ifNil: [^ nil].
	dir := item isPackage
				ifTrue: [map cache directoryForPackage: item]
				ifFalse: [map cache directoryForPackageRelease: item].
	win := FileList2 morphicViewOnDirectory: dir.
	"withLabel: item name, ' cache directory'."
	win openInWorld
]

{ #category : #interface }
SMLoaderPlus >> buildButtonBarWith: aBuilder [
	^ aBuilder pluggablePanelSpec new
		model: self;
		layout: #horizontal;
		children: (self commandSpecs select: [ :spec | spec fourth includes: #all]
				thenCollect: [ :spec |
					aBuilder pluggableActionButtonSpec new
						model: self;
						label: spec first;
						action: spec second;
						help: spec third;
						enabled: ((spec fourth includes: #item) ifTrue: [#hasSelectedItem]);
						yourself]);
		name: #buttonBar;
		yourself
]

{ #category : #interface }
SMLoaderPlus >> buildButtonNamed: labelText helpText: balloon action: action [
	| btn |
	btn := PluggableButtonMorph on: self getState: nil action: action.
	btn color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #spaceFill;
		label: labelText;
		setBalloonText: balloon;
		onColor: Color transparent offColor: Color transparent.
	^ btn
]

{ #category : #interface }
SMLoaderPlus >> buildCategoriesListWith: aBuilder [ 
	"Create the hierarchical list holding the category tree."
	^ aBuilder pluggableTreeSpec new model: self;
		 roots: #categoryList;
		 getSelectedPath: #selectedCategoryPath;
		 getChildren: #categoryChildren:;
		 hasChildren: #categoryHasChildren:;
		 setSelected: #selectedCategory:;
		 getSelected: #selectedCategory;
		 menu: #categoriesMenu:;
		 label: #categoryLabel:;
		 autoDeselect: true;
		 name: #categoriesList;
		 yourself
]

{ #category : #interface }
SMLoaderPlus >> buildPackagePaneWith: aBuilder [
	"Create the text area to the right in the loader."

	^ aBuilder pluggableTextSpec new
		model: self;
		getText: #itemDescription;
		name: #packagePane;
		help: 'Select a package to view its description.';
		yourself
]

{ #category : #interface }
SMLoaderPlus >> buildPackagesListWith: aBuilder [ 
	"Create the hierarchical list holding the packages and releases."
	^ aBuilder pluggableTreeSpec new model: self;
		 roots: #packageList;
		 getSelectedPath: #selectedItemPath;
		 getSelected: #selectedItem;
		 setSelected: #selectedItem:;
		 menu: #packagesMenu:;
		 label: #itemLabel:;
		 getChildren: #itemChildren:;
		 hasChildren: #itemHasChildren:;
		 autoDeselect: true;
		 name: #packagesList;
		 yourself
]

{ #category : #interface }
SMLoaderPlus >> buildSearchPaneWith: aBuilder [
	^ aBuilder pluggableInputFieldSpec new model: self;
		selection: #searchSelection;
		setText: #findPackage:notifying:;
		help: 'Search packages...';
		name: #search;
		yourself
]

{ #category : #interface }
SMLoaderPlus >> buildWith: aBuilder [ 
	"Create the package loader window."
	| buttonBarHeight searchPaneHeight vertDivide horizDivide |
	buttonBarHeight := Preferences standardButtonFont height * 2.
	searchPaneHeight := Preferences standardDefaultTextFont height * 2.
	vertDivide := 0.6.
	horizDivide := 0.3.
	builder := aBuilder.
	window := builder build: (builder pluggableWindowSpec new model: self;
					 label: #label;
					 children: (OrderedCollection new
						add: ((self buildButtonBarWith: builder)
							frame: (LayoutFrame
								fractions: (0 @ 0 corner: 1 @ 0)
								offsets: (0@0 corner: 0@buttonBarHeight)));
						add: ((self buildSearchPaneWith: builder)
							frame: (LayoutFrame
								fractions: (0 @ 0 corner: horizDivide @ 0)
								offsets: (0@ buttonBarHeight corner: 0@ (buttonBarHeight + searchPaneHeight))));
						add: ((self buildPackagesListWith: builder)
							frame: (LayoutFrame
								fractions: (0 @ 0 corner: horizDivide @ vertDivide)
								offsets: (0 @ (buttonBarHeight + searchPaneHeight) corner: 0@0)));
						add: ((self buildCategoriesListWith: builder)
							frame: (0 @ vertDivide corner: horizDivide @ 1));
						add: ((self buildPackagePaneWith: builder)
								frame: (LayoutFrame
									fractions: (horizDivide @ 0 corner: 1 @ 1)
									offsets: (0 @ buttonBarHeight corner: 0@0)));
						 yourself);
					 yourself).
	window on: #mouseEnter send: #paneTransition: to: window.
	window on: #mouseLeave send: #paneTransition: to: window.
	window extent: self initialExtent.
	^ window
]

{ #category : #actions }
SMLoaderPlus >> cachePackageReleaseAndOfferToCopy [
	"Cache package release, then offer to copy it somewhere.
	Answer the chosen file's location after copy,
	or the cache location if no directory was chosen."

	| release installer newDir newName newFile oldFile oldName |
	release := self selectedPackageOrRelease.
	release isPackageRelease ifFalse: [ self error: 'Should be a package release!'].
	installer := SMInstaller forPackageRelease: release.
	[UIManager default informUser: 'Caching ' , release asString during: [installer cache]] on: Error do: [:ex |
		| msg |
		msg := ex messageText ifNil: [ex asString].
		self informException: ex msg: ('Error occurred during download:\', msg, '\') withCRs.
		^nil ].
	installer isCached ifFalse: [self inform: 'Download failed, see transcript for details'. ^nil].
	oldName := installer fullFileName.
	newDir := UIManager default chooseDirectoryFrom: installer directory.
	newDir ifNil: [ ^oldName ].
	newDir = installer directory ifTrue: [ ^oldName ].
	newName := newDir fullNameFor: installer fileName.
	newFile := FileStream newFileNamed: newName.
	newFile ifNil: [ ^oldName ].
	newFile binary.
	oldFile := FileStream readOnlyFileNamed: oldName.
	oldFile ifNil: [ ^nil ].
	oldFile binary.
	[[ newDir copyFile: oldFile toFile: newFile ] ensure: [ oldFile close. newFile close ]] on: Error do: [ :ex | ^oldName ].
	^newName
]

{ #category : #menus }
SMLoaderPlus >> categoriesMenu: aMenu [ 
	"Answer the categories-list menu."

	self selectedCategory 
		ifNotNil: [aMenu addList: self categorySpecificOptions; addLine].
	aMenu addList: self generalOptions.
	self addFiltersToMenu: aMenu.
	^aMenu
]

{ #category : #interface }
SMLoaderPlus >> categoryChildren: aCategory [
	^ aCategory subCategories
]

{ #category : #interface }
SMLoaderPlus >> categoryHasChildren: aCategory [
	^ aCategory hasSubCategories
]

{ #category : #interface }
SMLoaderPlus >> categoryLabel: aCategory [
	^ aCategory name
]

{ #category : #lists }
SMLoaderPlus >> categoryList [
	"Create the category list for the hierarchical list.
	We sort the categories by name but ensure that 'Squeak versions'
	is first if it exists."
	| list first |
	list := (map categories
				select: [:each | each parent isNil]) asArray
				sort: [:c1 :c2 | c1 name <= c2 name].
	first := list
				detect: [:any | any name = 'Squeak versions']
				ifNone: [].
	first
		ifNotNil: [list := list copyWithout: first.
			list := {first} , list].
	^ list
]

{ #category : #menus }
SMLoaderPlus >> categorySpecificOptions [
	| choices |
	choices := OrderedCollection new.
	(categoriesToFilterIds includes: self selectedCategory id)
		ifTrue: [
			choices add: #('Remove filter' #removeSelectedCategoryAsFilter 'Remove the filter for the selected category.')]
		ifFalse: [
			choices add: #('Add as filter' #addSelectedCategoryAsFilter 'Add the selection as a filter to hide unrelated packages.')].
	categoriesToFilterIds isEmpty ifFalse: [
		choices add: #('Remove all filters' #removeCategoryFilters 'Remove all category filters.')].
	^ choices
]

{ #category : #accessing }
SMLoaderPlus >> changeFilters: anObject [ 
	"Update my selection."

	| oldItem index |
	oldItem := self selectedPackageOrRelease.
	filters := anObject.
	self packagesListIndex: ((index := self packageList indexOf: oldItem) 
				ifNil: [0]
				ifNotNil: [index]).
	self noteChanged
]

{ #category : #menus }
SMLoaderPlus >> commandSpecFor: selector [
	^ self commandSpecs detect: [:spec | spec second = selector]
]

{ #category : #menus }
SMLoaderPlus >> commandSpecs [
	^ #(('Install' installPackageRelease 'Install the latest version from the server.' (item all))
		('Email' emailPackageMaintainers 'Open an editor to send an email to the owner and co-maintainers of this package.' (item all))
		('Browse cache' browseCacheDirectory 'Browse cache directory of the selection.' (item all))
		('Copy from cache' cachePackageReleaseAndOfferToCopy 'Download selected release into cache first if needed, and then offer to copy it somewhere else.' (item))
		('Edit Release' openReleaseEditor 'Open a browser on this release to make updates.' (item))
		('Create new Release' createNewRelease 'Create a new release based on the selected item' (item))
		('Force download into cache' downloadPackageRelease 'Force a download of the selected release into the cache.' (item))
		('Update' loadUpdates 'Update the package index from the servers.' (all))
		('Upgrade All' upgradeInstalledPackagesConfirm 'Upgrade all installed packages (confirming each).' (all))
		('Upgrade all installed packages' upgradeInstalledPackagesNoConfirm '' (item))
		('Upgrade all installed packages confirming each' upgradeInstalledPackagesConfirm '' (item))
		('Copy list' listInPasteBuffer 'Puts the list as text into the clipboard.' (all))
		('Save filters' saveFiltersAsDefault 'Saves the current filters as default.' (all))
		('Help' help 'What is this?' (all)))
]

{ #category : #actions }
SMLoaderPlus >> createNewRelease [
	SMReleaseBrowser
		 openOn: self selectedItem newUnattachedRelease initializeMandatoryCategories ;
		 yourself
]

{ #category : #interface }
SMLoaderPlus >> defaultButtonPaneHeight [
	"Answer the user's preferred default height for new button panes."

	^ Preferences parameterAt: #defaultButtonPaneHeight ifAbsentPut: [25]
]

{ #category : #lists }
SMLoaderPlus >> defaultLabel [
	^ 'SqueakMap Package Loader'
]

{ #category : #'user interface' }
SMLoaderPlus >> defaultWindowColor [
	^ (Color r: 0.801 g: 0.801 b: 0.614)
]

{ #category : #actions }
SMLoaderPlus >> downloadPackageRelease [
	"Force a download of the selected package release into the cache."

	| release |
	release := self selectedPackageOrRelease.
	release isPackageRelease ifFalse: [ self error: 'Should be a package release!'].
	[UIManager default informUser: 'Downloading ' , release asString during: [
		(SMInstaller forPackageRelease: release) download]
	] on: Error do: [:ex |
		| msg | 
		msg := ex messageText ifNil: [ex asString].
		self informException: ex msg: ('Error occurred during download:\', msg, '\') withCRs]
]

{ #category : #actions }
SMLoaderPlus >> emailPackageMaintainers [
	"Send mail to package owner and co-maintainers."

	| item package toAddresses |
	item := self selectedPackageOrRelease ifNil: [^ nil].
	package := item isPackageRelease ifTrue: [item package] ifFalse: [item].

	"(this logic should be moved to MailMessage as soon as it can handle 
multiple To: addresses)"
	toAddresses := '<', package owner email, '>'.
	package maintainers ifNotNil: [
		package maintainers do: [:maintainer |
			toAddresses := toAddresses, ', <', maintainer email, '>']].

	SMUtilities sendMailTo: toAddresses regardingPackageRelease: item
]

{ #category : #'filter utilities' }
SMLoaderPlus >> filterAdd: anObject [

	self changeFilters: (self filters copyWith: anObject)

]

{ #category : #filters }
SMLoaderPlus >> filterAutoInstall [
	^[:package | package isInstallable]
]

{ #category : #filters }
SMLoaderPlus >> filterAvailable [
	^[:package | package isAvailable]
]

{ #category : #filters }
SMLoaderPlus >> filterInstalled [
	^[:package | package isInstalled]
]

{ #category : #filters }
SMLoaderPlus >> filterNotInstalledYet [
	^[:package | package isInstalled not]
]

{ #category : #filters }
SMLoaderPlus >> filterNotUptoDate [
	^[:package | package isAvailable]
]

{ #category : #filters }
SMLoaderPlus >> filterPublished [
	^[:package | package isPublished]
]

{ #category : #'filter utilities' }
SMLoaderPlus >> filterRemove: anObject [

	self changeFilters: (self filters copyWithout: anObject)

]

{ #category : #filters }
SMLoaderPlus >> filterSafelyAvailable [
	^[:package | package isSafelyAvailable]
]

{ #category : #'filter utilities' }
SMLoaderPlus >> filterSpecs [
	"Return a specification for the filter menu. Is called each time."
	| specs |
	specs := #(#('Auto-installable packages' #filterAutoInstall 'display only packages that can be installed automatically') #('New available packages' #filterAvailable 'display only packages that are not installed or that have newer releases available.') #('New safely-available packages' #filterSafelyAvailable 'display only packages that are not installed or that have newer releases available that are safe to install, meaning that they are published and meant for the current version of Squeak.') #('Installed packages' #filterInstalled 'Display only packages that are installed.') #('Published packages' #filterPublished 'Display only packages that have at least one published release.') ) asOrderedCollection.
	categoriesToFilterIds
		do: [:catId | specs add: {'Packages in ' , (map object: catId) name. catId. 'Display only packages that are in the category.'}].
	^ specs
]

{ #category : #filters }
SMLoaderPlus >> filterVersion [
	"Ignore spaces in the version string, they're sometimes spurious.
	Not used anymore."
	^[:package | package categories anySatisfy:  
		[:cat | (cat name, '*') match: (Smalltalk version copyWithout: $ ) ]]
]

{ #category : #'filter utilities' }
SMLoaderPlus >> filters [
	^filters
]

{ #category : #actions }
SMLoaderPlus >> findPackage: aString notifying: aView [ 
	"Search and select a package with the given (sub) string in the name or
	description. "
	| index list match descriptions |
	match := aString asString asLowercase.
	index := self packagesListIndex.
	list := self packageNameList.
	list isEmpty
		ifTrue: [^ self].
	descriptions := self packageList collect: [:e | e description].
	index + 1
		to: list size
		do: [:i | (((list at: i)
						includesSubstring: match
						caseSensitive: false)
					or: [(descriptions at: i)
							includesSubstring: match
							caseSensitive: false])
				ifTrue: [^ self packagesListIndex: i]].
	"wrap around"
	1
		to: index
		do: [:i | (((list at: i)
						includesSubstring: match
						caseSensitive: false)
					or: [(descriptions at: i)
							includesSubstring: match
							caseSensitive: false])
				ifTrue: [^ self packagesListIndex: i]].
	self inform: 'No package matching ' , aString asString
]

{ #category : #menus }
SMLoaderPlus >> generalOptions [
	^#( #('Upgrade all installed packages' upgradeInstalledPackagesNoConfirm)
		#('Upgrade all installed packages confirming each' upgradeInstalledPackagesConfirm)
		#('Put list in paste buffer' listInPasteBuffer)
		#('Save filters as default' saveFiltersAsDefault)
		#- )


]

{ #category : #private }
SMLoaderPlus >> hasSelectedItem [
	^ self selectedPackageOrRelease notNil
]

{ #category : #interface }
SMLoaderPlus >> help [
	"Present help text. If there is a web server available, offer to open it.
	Use the WebBrowser registry if possible, or Scamper if available."
	| message browserClass |
	message := 'Welcome to the SqueakMap package loader. 
The names of packages are followed by versions: (installed -> latest).
If there is no arrow, your installed version of the package is the latest.
Bold packages and releases have been installed.
The checkbox menu items modify which packages you''ll see.
Take a look at them - only some packages are shown initially.
The options available for a package depend on how it was packaged.
Comment on a package by emailing the author or the squeak list.'.

	browserClass := Smalltalk at: #WebBrowser ifPresent: [ :registry | registry default ].
	browserClass := browserClass ifNil: [ Smalltalk at: #Scamper ifAbsent: [ ^self inform: message ]].

	(self confirm: message, '
Would you like to view more detailed help on the SqueakMap swiki page?') 
	ifTrue: [ browserClass openOnUrl: 'http://wiki.squeak.org/2726' asUrl]
]

{ #category : #private }
SMLoaderPlus >> informException: ex msg: msg [ 
	"Tell the user that an error has occurred.
	Offer to open debug notifier."

	(self confirm: msg, 'Would you like to open a debugger?')
		ifTrue: [ex pass]
]

{ #category : #interface }
SMLoaderPlus >> initialExtent [
	^500@400
]

{ #category : #actions }
SMLoaderPlus >> installPackageRelease [
	"Install selected package or release.
	The cache is used."
	| item release |
	item := self selectedPackageOrRelease
				ifNil: [^ nil].
	item isPackageRelease
		ifTrue: [^ self installPackageRelease: item]
		ifFalse: [release := item lastReleaseForCurrentSystemVersion.
			release
				ifNil: [(self confirm: 'The package has no published release for your Squeak version, try releases for any Squeak version?')
						ifTrue: [release := item lastPublishedRelease.
							release
								ifNil: [(self confirm: 'The package has no published release at all, take the latest of the unpublished releases?')
										ifTrue: [release := item lastRelease]]]].
			release
				ifNotNil: [^ self installPackageRelease: release]]
]

{ #category : #private }
SMLoaderPlus >> installPackageRelease: aRelease [
	"Install a package release. The cache is used."

	| myRelease installer |
	aRelease isCompatibleWithCurrentSystemVersion ifFalse:
		[(self confirm:
'The package you are about to install is not listed as
being compatible with your image version (', SystemVersion current majorMinorVersion, '),
so the package may not work properly.
Do you still want to proceed with the install?')
			ifFalse: [^ self]].
	myRelease := self installedReleaseOfMe.
	installer := SMInstaller forPackageRelease: aRelease.
	[UIManager default informUser: 'Downloading ' , aRelease asString during:
		[installer download].
	UIManager default informUser: 'Installing ' , aRelease asString during: [
		installer install.
		myRelease = self installedReleaseOfMe
					ifFalse: [self reOpen]
					ifTrue: [self noteChanged]]
	] on: Error do: [:ex |
		| msg |
		msg := ex messageText ifNil:[ex asString].
		self informException: ex msg: ('Error occurred during install:\', msg, '\') withCRs].
]

{ #category : #private }
SMLoaderPlus >> installedReleaseOfMe [
	"Return the release of the installed package loader."

	^SMSqueakMap default installedReleaseOf: (SMSqueakMap default packageWithId: '941c0108-4039-4071-9863-a8d7d2b3d4a3').
]

{ #category : #interface }
SMLoaderPlus >> itemChildren: anItem [ 
	^ anItem isPackage
		ifTrue: [ self sortReleases: anItem releases ]
		ifFalse: [ #() ]
]

{ #category : #private }
SMLoaderPlus >> itemDescription [
	^ self selectedPackageOrRelease
		ifNotNil: [:item | item fullDescription]
]

{ #category : #interface }
SMLoaderPlus >> itemHasChildren: anItem [ 
	^ anItem isPackage and: [anItem releases notEmpty]
]

{ #category : #interface }
SMLoaderPlus >> itemLabel: anItem [ 
	| label |
	label := anItem isPackage
				ifTrue: [anItem name
						, (anItem versionLabel
								ifEmpty: ['']
								ifNotEmptyDo: [:lbl | ' (' , anItem versionLabel , ')'])]
				ifFalse: [anItem smartVersion].
	^ anItem isInstalled
		ifTrue: [label asText allBold]
		ifFalse: [label]
]

{ #category : #lists }
SMLoaderPlus >> label [
	^ self
		labelForShown: (packagesList
				ifNil: [self packageList])
]

{ #category : #'filter utilities' }
SMLoaderPlus >> labelForFilter: aFilterSymbol [ 
	^(self filterSpecs detect: [:fs | fs second = aFilterSymbol]) first
]

{ #category : #lists }
SMLoaderPlus >> labelForShown: packagesShown [
	"Update the label of the window."
	^ self defaultLabel , ' (',
		(packagesShown size < map packages size ifTrue: [packagesShown size printString,
		' shown out of '] ifFalse: ['']) , map packages size printString, ' packages)'
]

{ #category : #actions }
SMLoaderPlus >> listInPasteBuffer [
	"Useful when talking with people etc.
	Uses the map to produce a nice String."

	Clipboard clipboardText:
		(String streamContents: [:s |
			packagesList do: [:p |
				s nextPutAll: p nameWithVersionLabel; cr ]]) asText
]

{ #category : #actions }
SMLoaderPlus >> loadUpdates [
	[UIManager default informUser: 'Loading Updates' during: [
		map loadUpdates.
		self noteChanged ]
	] on: Error do: [:ex |
		self informException: ex msg: ('Error occurred when updating map:\', ex messageText, '\') withCRs]
]

{ #category : #private }
SMLoaderPlus >> noteChanged [
	filters
		ifNil: [^ self reOpen].
	map
		ifNotNil: [packagesList := nil.
			selectedCategory := nil.
			self changed: #categoryList.
			self changed: #packageList.
			self changed: #packagesListIndex.
			"update my selection"
			self contentsChanged]
]

{ #category : #initialization }
SMLoaderPlus >> on: aSqueakMap [ 
	"Initialize instance."
	map := aSqueakMap.
	map synchWithDisk.
	filters := DefaultFilters copy.
	categoriesToFilterIds := DefaultCategoriesToFilterIds copy
]

{ #category : #actions }
SMLoaderPlus >> openReleaseEditor [
	SMReleaseBrowser openOn: self selectedItem 
]

{ #category : #'filter utilities' }
SMLoaderPlus >> package: aPackage filteredByCategory: aCategory [
	"Answer true if the package should be shown
	if we filter on <aCategory>. It should be shown
	if itself or any of its releases has the category."

	| releases |
	releases := aPackage releases.
	^(aPackage hasCategoryOrSubCategoryOf: aCategory) or: [
			releases anySatisfy: [:rel |
				rel hasCategoryOrSubCategoryOf: aCategory]]
]

{ #category : #lists }
SMLoaderPlus >> packageList [
	"Return a list of the SMPackages that should be visible
	by applying all the filters. Also filter based on the currently
	selected category - if any."
	| list |
	list := packagesList ifNil: [packagesList := self packageListCalculated].
	selectedCategory ifNotNil: [
		list := list select: [:each | self package: each filteredByCategory: selectedCategory]].
	self updateLabel: list.
	^ list
]

{ #category : #lists }
SMLoaderPlus >> packageListCalculated [
	"Return a list of the SMPackages that should be visible
	by applying all the filters. Also filter based on the currently
	selected category - if any."
	^ self packages select: [:p |
		filters allSatisfy: [:currFilter |
			currFilter isSymbol
				ifTrue: [(self perform: currFilter) value: p]
				ifFalse: [self package: p filteredByCategory: (map object: currFilter)]]]
]

{ #category : #lists }
SMLoaderPlus >> packageNameList [
	^ self packageList collect: [:e | e name]
]

{ #category : #menus }
SMLoaderPlus >> packageSpecificOptions [
	| choices packageOrRelease |
	packageOrRelease := self selectedPackageOrRelease.
	choices := OrderedCollection new.
	packageOrRelease isInstallable ifTrue: [ choices add: (self commandSpecFor: #installPackageRelease) ].
	(packageOrRelease isDownloadable and: [ packageOrRelease isCached ]) ifTrue: [ choices add: (self commandSpecFor: #browseCacheDirectory) ].
	(packageOrRelease isPackageRelease and: [ packageOrRelease isDownloadable ]) ifTrue:
		[ choices add: (self commandSpecFor: #cachePackageReleaseAndOfferToCopy).
		choices add: (self commandSpecFor: #downloadPackageRelease) ].
	choices add: (self commandSpecFor: #emailPackageMaintainers).
	packageOrRelease isPackageRelease ifTrue: [ choices add: (self commandSpecFor: #openReleaseEditor) ].
	choices add: (self commandSpecFor: #createNewRelease).
	^ choices
]

{ #category : #private }
SMLoaderPlus >> packages [
	"We request the packages as sorted by name by default."

	^map packagesByName asArray

]

{ #category : #accessing }
SMLoaderPlus >> packagesListIndex [
	^ self packageList indexOf: self selectedItem
]

{ #category : #accessing }
SMLoaderPlus >> packagesListIndex: anObject [ 
	self
		selectedItem: (anObject = 0
				ifFalse: [self packageList at: anObject])
]

{ #category : #menus }
SMLoaderPlus >> packagesMenu: aMenu [ 
	"Answer the packages-list menu."

	self selectedPackageOrRelease 
		ifNotNil: [aMenu addList: self packageSpecificOptions; addLine].
	aMenu addList: self generalOptions.
	self addFiltersToMenu: aMenu.
	^aMenu
]

{ #category : #interface }
SMLoaderPlus >> perform: selector orSendTo: otherTarget [ 
	"Selector was just chosen from a menu by a user. If can respond, then  
	perform it on myself. If not, send it to otherTarget, presumably the  
	editPane from which the menu was invoked."

	^ (self respondsTo: selector)
		ifTrue: [self perform: selector]
		ifFalse: [super perform: selector orSendTo: otherTarget]
]

{ #category : #private }
SMLoaderPlus >> reOpen [
	"Close this package loader, probably because it has been updated,
	and open a new one."
	self inform: 'This package loader has been upgraded and will be closed and reopened to avoid strange side effects.'.
	window delete.
	(Smalltalk at: self class name) open
]

{ #category : #actions }
SMLoaderPlus >> removeCategoryFilters [
	"Remove all category filters."

	categoriesToFilterIds := OrderedCollection new
]

{ #category : #actions }
SMLoaderPlus >> removeSelectedCategoryAsFilter [
	"Remove the filter that filters on the currently selected category."

	categoriesToFilterIds remove: self selectedCategory id
]

{ #category : #private }
SMLoaderPlus >> representsSameBrowseeAs: anotherSMLoaderPlus [
	^ true
]

{ #category : #actions }
SMLoaderPlus >> saveFiltersAsDefault [
	"Save the current filters as default so that they
	are selected the next time the loader is opened."

	DefaultFilters := filters copy.
	DefaultCategoriesToFilterIds := categoriesToFilterIds copy
]

{ #category : #interface }
SMLoaderPlus >> searchSelection [
	"Selects all of the default search text so that a type-in overwrites it."
	^ {1. self searchText size}
]

{ #category : #interface }
SMLoaderPlus >> searchText [
	"A dummy default search text so that the field describes its purpose."
	^ ''
]

{ #category : #accessing }
SMLoaderPlus >> selectedCategory [
	"Return selected category."
	^ selectedCategory
]

{ #category : #accessing }
SMLoaderPlus >> selectedCategory: anSMCategory [ 
	"Change the selected category."
	selectedCategory := anSMCategory.
	selectedCategory ifNotNil:
		[ (selectedCategory objects includes: self selectedItem) ifFalse: [ self selectedItem: nil ] ].
	self
		 changed: #selectedCategory;
		 changed: #packageList
]

{ #category : #accessing }
SMLoaderPlus >> selectedCategoryPath [
	"Return selected category's path."
	| path |
	path := #().
	selectedCategory
		ifNotNil: [selectedCategory parent
				ifNotNil: [:p | path := path copyWith: p].
			path := path copyWith: selectedCategory].
	^ path
]

{ #category : #accessing }
SMLoaderPlus >> selectedItem [
	^ selectedItem
]

{ #category : #accessing }
SMLoaderPlus >> selectedItem: anItem [
	"This == workaround protects us from recursion since ToolBuilder's tree widgets will always tell us that the selection has been updated when we tell it that the selection path has been updated. Cleaner solutions invited."
	anItem == selectedItem ifFalse: [
		selectedItem := anItem.
		self changed: #selectedItem.
		self changed: #itemDescription.
		self changed: #hasSelectedItem]
]

{ #category : #accessing }
SMLoaderPlus >> selectedItemPath [
	| path |
	path := #().
	(selectedItem isKindOf: SMPackageRelease)
		ifTrue: [path := path copyWith: selectedItem package].
	selectedItem
		ifNotNil: [path := path copyWith: selectedItem].
	^ path
]

{ #category : #accessing }
SMLoaderPlus >> selectedPackageOrRelease [
	"Return selected package or package release."
	^ selectedItem
]

{ #category : #'filter utilities' }
SMLoaderPlus >> showFilterString: aFilterSymbol [ 
	^(self stateForFilter: aFilterSymbol), (self labelForFilter: aFilterSymbol)
]

{ #category : #private }
SMLoaderPlus >> sortReleases: anOrderedCollection [ 
	"SqueakMap stores them in chronological order, let's list them in reverse-chronological order for easy-selection."
	| answer headIndex |
	answer := anOrderedCollection reversed.
	"After that, look for the 'head' release, put it to the top."
	headIndex := answer findFirst:
		[ : each | each version = 'head' ].
	headIndex > 1 ifTrue: [ answer addFirst: (answer removeAt: headIndex) ].
	^ answer
]

{ #category : #'filter utilities' }
SMLoaderPlus >> stateForFilter: aFilterSymbol [ 
	^(self filters includes: aFilterSymbol) ifTrue: ['<yes>'] ifFalse: ['<no>']


]

{ #category : #'filter utilities' }
SMLoaderPlus >> toggleFilterState: aFilterSymbol [ 

	^(self filters includes: (aFilterSymbol)) 
		ifTrue: [self filterRemove: aFilterSymbol]
		ifFalse: [self filterAdd: aFilterSymbol]
]

{ #category : #actions }
SMLoaderPlus >> uncheckFilters [
	"Uncheck all filters."
	
	filters := OrderedCollection new.
	self noteChanged
]

{ #category : #lists }
SMLoaderPlus >> updateLabel: packagesShown [
	"Update the label of the window."
	window ifNotNil: [:w | w setLabel: (self labelForShown: packagesShown)]
]

{ #category : #actions }
SMLoaderPlus >> upgradeInstalledPackages [
	"Tries to upgrade all installed packages to the latest published release for this
	version of Squeak. So this is a conservative approach."

	| installed old myRelease toUpgrade info |
	installed := map installedPackages.
	old := map oldPackages.
	old isEmpty ifTrue: [
			^self inform: 'All ', installed size printString, ' installed packages are up to date.'].
	toUpgrade := map upgradeableAndOldPackages.
	toUpgrade isEmpty ifTrue: [
			^self inform: 'None of the ', old size printString, ' old packages of the ', installed size printString, ' installed can be automatically upgraded. You need to upgrade them manually.'].
	info := old size < toUpgrade size ifTrue: [
		'Of the ', old size printString, ' old packages only ', toUpgrade size printString, ' can be upgraded.
The following packages will not be upgraded:
',  (String streamContents: [:s | (old removeAll: toUpgrade; yourself)
	do: [:p | s nextPutAll: p nameWithVersionLabel; cr]])]
		ifFalse: ['All old packages upgradeable.'].
	(self confirm: info, '
About to upgrade the following packages:
', (String streamContents: [:s | toUpgrade do: [:p | s nextPutAll: p nameWithVersionLabel; cr]]), 'Proceed?') ifTrue: [
			myRelease := self installedReleaseOfMe.
			[UIManager default informUser: 'Upgrading Installed Packages' during: [
				map upgradeOldPackages.
				self inform: toUpgrade size printString, ' packages successfully upgraded.'.
				myRelease = self installedReleaseOfMe
					ifFalse: [self reOpen]
					ifTrue: [self noteChanged]]
			] on: Error do: [:ex |
				self informException: ex msg: ('Error occurred when upgrading old packages:\', ex messageText, '\') withCRs]]
]

{ #category : #actions }
SMLoaderPlus >> upgradeInstalledPackagesConfirm [
	"Tries to upgrade all installed packages to the latest published release for this
	version of Squeak. Confirms on each upgrade."

	^ self upgradeInstalledPackagesConfirm: true
]

{ #category : #private }
SMLoaderPlus >> upgradeInstalledPackagesConfirm: confirmEach [ 
	"Tries to upgrade all installed packages to the latest published release for
	this version of Squeak. If confirmEach is true we ask for every
	upgrade. "
	| installed old myRelease toUpgrade info |
	installed := map installedPackages.
	old := map oldPackages.
	old isEmpty
		ifTrue: [^ self inform: 'All ' , installed size printString , ' installed packages are up to date.'].
	toUpgrade := map upgradeableAndOldPackages.
	toUpgrade isEmpty
		ifTrue: [^ self inform: 'None of the ' , old size printString , ' old packages of the ' , installed size printString , ' installed can be automatically upgraded. You need to upgrade them manually.'].
	info := old size < toUpgrade size
		ifTrue: ['Of the ' , old size printString , ' old packages only ' , toUpgrade size printString , ' can be upgraded.
The following packages will not be upgraded:
'
						, (String
								streamContents: [:s | (old removeAll: toUpgrade;
										 yourself)
										do: [:p | s nextPutAll: p nameWithVersionLabel;
												 cr]])]
		ifFalse: ['All old packages upgradeable.'].
	(self confirm: info , '
About to upgrade the following packages:
'
				, (String
						streamContents: [:s | toUpgrade
								do: [:p | s nextPutAll: p nameWithVersionLabel;
										 cr]]) , 'Proceed?')
		ifTrue: [myRelease := self installedReleaseOfMe.
			[UIManager default informUser: 'Upgrading Installed Packages' during:
					[confirmEach
						ifTrue: [map
								upgradeOldPackagesConfirmBlock: [:p | self confirm: 'Upgrade ' , p installedRelease packageNameWithVersion , ' to ' , (p lastPublishedReleaseForCurrentSystemVersionNewerThan: p installedRelease) listName , '?']]
						ifFalse: [map upgradeOldPackages].
					self inform: toUpgrade size printString , ' packages successfully processed.'.
					myRelease = self installedReleaseOfMe
						ifTrue: [self noteChanged]
						ifFalse: [self reOpen]]]
				on: Error
				do: [:ex | self informException: ex msg: ('Error occurred when upgrading old packages:\' , ex messageText , '\') withCRs]]
]

{ #category : #actions }
SMLoaderPlus >> upgradeInstalledPackagesNoConfirm [
	"Tries to upgrade all installed packages to the latest published release for this
	version of Squeak. No confirmation on each upgrade."

	^ self upgradeInstalledPackagesConfirm: false
]
