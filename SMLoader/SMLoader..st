"
A simple package loader that is currently the standard UI for SqueakMap (the model is an SMSqueakMap instance).
You can open one with:

	SMLoader open
"
Class {
	#name : #SMLoader,
	#superclass : #SystemWindow,
	#instVars : [
		'packagesList',
		'selectedItemWrapper',
		'selectedCategoryWrapper',
		'filters',
		'categoriesToFilterIds'
	],
	#classVars : [
		'DefaultCategoriesToFilterIds',
		'DefaultFilters'
	],
	#category : #SMLoader
}

{ #category : #'parts bin' }
SMLoader class >> descriptionForPartsBin [
	^self partName: 'Package Loader'
		categories: #(Tools)
		documentation: 'SqueakMap UI'

]

{ #category : #'class initialization' }
SMLoader class >> initialize [
	"Hook us up in the world menu."
	"self initialize"
	Smalltalk
		at: #ToolBuilder
		ifAbsent: [self registerInFlapsRegistry.
			(TheWorldMenu respondsTo: #registerOpenCommand:)
				ifTrue: [| oldCmds |
					oldCmds := TheWorldMenu registry select: [:cmd | cmd first includesSubstring: 'Package Loader'].
					oldCmds do: [:cmd | TheWorldMenu unregisterOpenCommand: cmd first].
					TheWorldMenu registerOpenCommand: {self openMenuString. {self. #open}}]].
	DefaultFilters := OrderedCollection new.
	DefaultCategoriesToFilterIds := OrderedCollection new
]

{ #category : #'new-morph participation' }
SMLoader class >> initializedInstance [
	^self new createWindow extent: 400@400
]

{ #category : #'instance creation' }
SMLoader class >> new [
	"Create a SqueakMap loader on the default map."

	^self newOn: SMSqueakMap default
]

{ #category : #'instance creation' }
SMLoader class >> newOn: aMap [
	"Create a SqueakMap loader on given map."

	^super new on: aMap; yourself
]

{ #category : #'new-morph participation' }
SMLoader class >> newStandAlone [
	^self new createWindow
]

{ #category : #'instance creation' }
SMLoader class >> open [
	"Create and open a SqueakMap Loader."
	
	"SMLoader open"

	^self new openAsMorph
]

{ #category : #'class initialization' }
SMLoader class >> openMenuString [
	^ 'SqueakMap Catalog'
]

{ #category : #'instance creation' }
SMLoader class >> openOn: aSqueakMap [
	"Create and open a SqueakMap Loader on a given map."

	"self openOn: SqueakMap default"

	^(self newOn: aSqueakMap) openAsMorph
]

{ #category : #'new-morph participation' }
SMLoader class >> prototypicalToolWindow [
	"Do not update when creating a prototype window (used by flaps etc)"

	^[self new createWindow; applyModelExtent; yourself]
		valueSupplyingAnswers:{ {'*map on disk*'. false}}
]

{ #category : #'new-morph participation' }
SMLoader class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry."

	self environment
		at: #Flaps
		ifPresent: [:cl | (cl respondsTo: #registerQuad:forFlapNamed:)
				ifTrue: [cl registerQuad: #(#SMLoader #prototypicalToolWindow 'Package Loader' 'The SqueakMap Package Loader' ) forFlapNamed: 'Tools']]
]

{ #category : #'class initialization' }
SMLoader class >> unload [
	(TheWorldMenu respondsTo: #registerOpenCommand:) ifTrue: 
		[TheWorldMenu unregisterOpenCommand: self openMenuString].
	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #menus }
SMLoader >> addFiltersToMenu: aMenu [
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
SMLoader >> addSelectedCategoryAsFilter [
	"Add a new filter that filters on the currently selected category.
	Make it enabled as default."

	categoriesToFilterIds add: self selectedCategory id
]

{ #category : #interface }
SMLoader >> browseCacheDirectory [
	"Open a FileList2 on the directory for the package or release."

	| item dir win |
	item := self selectedPackageOrRelease ifNil: [^ nil].
	item ifNil: [^nil].
	dir := item isPackage
				ifTrue: [model cache directoryForPackage: item]
				ifFalse: [model cache directoryForPackageRelease: item].
	win := FileList2 morphicViewOnDirectory: dir. " withLabel: item name, ' cache directory'."
	win openInWorld

]

{ #category : #interface }
SMLoader >> buildButtonBar [
	| aRow btn |
	aRow := AlignmentMorph newRow beSticky.
	aRow color: Color transparent;
		clipSubmorphs: true.
	self buttonSpecs do: [:spec |
		btn := self buildButtonNamed: spec first helpText: spec third action: spec second.
		aRow addMorphBack: btn]
		separatedBy: [aRow addTransparentSpacerOfSize: 3@0].
	^ aRow
]

{ #category : #interface }
SMLoader >> buildButtonNamed: labelText helpText: balloon action: action [
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
SMLoader >> buildMorphicCategoriesList [
	"Create the hierarchical list holding the category tree."
	| list |
	list := (SimpleHierarchicalListMorph
				on: self
				list: #categoryWrapperList
				selected: #selectedCategoryWrapper
				changeSelected: #selectedCategoryWrapper:
				menu: #categoriesMenu:
				keystroke: nil) autoDeselect: true;
				 enableDrag: false;
				 enableDrop: true;
				 yourself.
	list setBalloonText: 'The categories are structured in a tree. Packages and package releases belong to several categories.
You can add one or more categories as filters and enable them in the menu.'.
	"list scroller submorphs do:[:each| list expandAll: each]."
	list adjustSubmorphPositions.
	^ list
]

{ #category : #interface }
SMLoader >> buildMorphicPackagesList [
	"Create the hierarchical list holding the packages and releases."

	^(SimpleHierarchicalListMorph 
		on: self
		list: #packageWrapperList
		selected: #selectedItemWrapper
		changeSelected: #selectedItemWrapper:
		menu: #packagesMenu:
		keystroke: nil)
		autoDeselect: false;
		enableDrag: false;
		enableDrop: true;
		setBalloonText: 'This shows all packages with their releases that should be displayed according the current filter.';
		yourself
]

{ #category : #interface }
SMLoader >> buildPackageButtonBar [
	| aRow |
	"Somewhat patterned after IRCe's buttonRow method."
	aRow := AlignmentMorph newRow beSticky.
	aRow color: Color transparent;
		clipSubmorphs: true.
	^ aRow
]

{ #category : #interface }
SMLoader >> buildPackagePane [
	"Create the text area to the right in the loader."

	| ptm |
	ptm := PluggableTextMorph 
		on: self 
		text: #contents
		accept: nil
		readSelection: nil "#packageSelection "
		menu: nil.
	ptm setBalloonText: 'This is where the selected package or package release is displayed.'.
	ptm lock.
	^ptm
]

{ #category : #interface }
SMLoader >> buildSearchPane [
	"Cribbed from MessageNames>>inMorphicWindowWithInitialSearchString:"
	| typeInView searchButton typeInPane |
	typeInView := PluggableTextMorph
				on: self
				text: nil
				accept: #findPackage:notifying:
				readSelection: nil
				menu: nil.
	typeInView acceptOnCR: true;
		 vResizing: #spaceFill;
		 hResizing: #spaceFill;
		 setTextMorphToSelectAllOnMouseEnter;
		 askBeforeDiscardingEdits: false;
		 setProperty: #alwaysAccept toValue: true.
	(typeInView respondsTo: #hideScrollBarsIndefinitely)
		ifTrue: [typeInView hideScrollBarsIndefinitely]
		ifFalse: [typeInView hideScrollBarIndefinitely].
	searchButton := SimpleButtonMorph new target: typeInView;
				 color: Color white;
				 label: 'Search';
				 actionSelector: #accept;
				 arguments: #(); yourself.
	typeInPane := AlignmentMorph newRow.
	typeInPane vResizing: #shrinkWrap;
		 hResizing: #shrinkWrap;
		 listDirection: #leftToRight;
		 addMorphFront: searchButton;
		 addTransparentSpacerOfSize: 6 @ 0;
		 addMorphBack: typeInView;
		 setBalloonText: 'Type into the pane, then press Search (or hit RETURN) to visit the next package matching what you typed.'.
	^ typeInPane
]

{ #category : #interface }
SMLoader >> buttonSpecs [
	^ #(('Install' installPackageRelease 'Install the latest version from the server.')
		('Email' emailPackageMaintainers 'Open an editor to send an email to the owner and co-maintainers of this package.')
		('Browse cache' browseCacheDirectory 'Browse cache directory of the selection.')
		('Update' loadUpdates 'Update the package index from the servers.')
		('Upgrade All' upgradeInstalledPackagesConfirm 'Upgrade all installed packages (confirming each).')
		('Help' help 'What is this?'))
]

{ #category : #actions }
SMLoader >> cachePackageReleaseAndOfferToCopy [
	"Cache package release, then offer to copy it somewhere.
	Answer the chosen file's location after copy,
	or the cache location if no directory was chosen."

	| release installer newDir newName newFile oldFile oldName |
	release := self selectedPackageOrRelease.
	release isPackageRelease ifFalse: [ self error: 'Should be a package release!'].
	installer := SMInstaller forPackageRelease: release.
	[Cursor wait showWhile: [installer cache]] on: Error do: [:ex |
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
SMLoader >> categoriesMenu: aMenu [ 
	"Answer the categories-list menu."

	self selectedCategory 
		ifNotNil: [aMenu addList: self categorySpecificOptions; addLine].
	aMenu addList: self generalOptions.
	self addFiltersToMenu: aMenu.
	^aMenu
]

{ #category : #menus }
SMLoader >> categorySpecificOptions [
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

{ #category : #lists }
SMLoader >> categoryWrapperList [
	"Create the wrapper list for the hierarchical list.
	We sort the categories by name but ensure that 'Squeak versions'
	is first if it exists."
	| list first |
	list := (model categories
				select: [:each | each parent isNil]) asArray
				sort: [:c1 :c2 | c1 name <= c2 name].
	first := list
				detect: [:any | any name = 'Squeak versions']
				ifNone: [].
	first
		ifNotNil: [list := list copyWithout: first.
			list := {first} , list].
	^ list
		collect: [:cat | SMCategoryWrapper with: cat model: self]
]

{ #category : #'filter utilities' }
SMLoader >> changeFilters: anObject [ 
	"Update my selection."

	| oldItem index |
	oldItem := self selectedPackageOrRelease.
	filters := anObject.
	self packagesListIndex: ((index := self packageList indexOf: oldItem) 
				ifNil: [0]
				ifNotNil: [index]).
	self noteChanged
]

{ #category : #private }
SMLoader >> contents [
	| packageOrRelease |
	packageOrRelease := self selectedPackageOrRelease.
	^packageOrRelease
		ifNil: ['<No package selected>']
		ifNotNil: [packageOrRelease fullDescription]

]

{ #category : #private }
SMLoader >> createNewRelease [
	SMReleaseBrowser
		 openOn: self selectedItem newUnattachedRelease initializeMandatoryCategories ;
		 yourself
]

{ #category : #interface }
SMLoader >> createWindow [
	| buttonBarHeight searchHeight vertDivide horizDivide |
	buttonBarHeight := 0.07.
	searchHeight := 0.07.
	vertDivide := 0.3.
	horizDivide := 0.6.
	self addMorph: (self buildButtonBar borderWidth: 0)
		frame: (0.0 @ 0.0 corner: 1.0 @ buttonBarHeight).
	self addMorph: (self buildSearchPane borderWidth: 0)
		frame: (0.0 @ buttonBarHeight corner: vertDivide @ searchHeight).
	self addMorph: (self buildMorphicPackagesList borderWidth: 0)
		frame: (0.0 @ (buttonBarHeight + searchHeight) corner: vertDivide @ horizDivide).
	self addMorph: (self buildMorphicCategoriesList borderWidth: 0)
		frame: (0.0 @ horizDivide corner: vertDivide @ 1.0).
	self addMorph: (self buildPackagePane borderWidth: 0)
		frame: (vertDivide @ buttonBarHeight corner: 1.0 @ 1.0).
	self on: #mouseEnter send: #paneTransition: to: self.
	self on: #mouseLeave send: #paneTransition: to: self
]

{ #category : #interface }
SMLoader >> defaultButtonPaneHeight [
	"Answer the user's preferred default height for new button panes."

	^ Preferences parameterAt: #defaultButtonPaneHeight ifAbsentPut: [25]
]

{ #category : #'user interface' }
SMLoader >> defaultColor [

	^ self defaultWindowColor
]

{ #category : #interface }
SMLoader >> defaultLabel [
	^'SqueakMap Package Loader'
]

{ #category : #'user interface' }
SMLoader >> defaultWindowColor [
	^ (Color r: 0.801 g: 0.801 b: 0.614)
]

{ #category : #actions }
SMLoader >> downloadPackageRelease [
	"Force a download of the selected package release into the cache."

	| release |
	release := self selectedPackageOrRelease.
	release isPackageRelease ifFalse: [ self error: 'Should be a package release!'].
	[Cursor wait showWhile: [
		(SMInstaller forPackageRelease: release) download]
	] on: Error do: [:ex |
		| msg | 
		msg := ex messageText ifNil: [ex asString].
		self informException: ex msg: ('Error occurred during download:\', msg, '\') withCRs]
]

{ #category : #actions }
SMLoader >> emailPackageMaintainers [
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
SMLoader >> filterAdd: anObject [

	self changeFilters: (self filters copyWith: anObject)

]

{ #category : #filters }
SMLoader >> filterAutoInstall [
	^[:package | package isInstallable]
]

{ #category : #filters }
SMLoader >> filterAvailable [
	
	^[:package | package isAvailable]
]

{ #category : #filters }
SMLoader >> filterInstalled [
	^[:package | package isInstalled]
]

{ #category : #filters }
SMLoader >> filterNotInstalledYet [
	^[:package | package isInstalled not]
]

{ #category : #filters }
SMLoader >> filterNotUptoDate [
	
	^[:package | package isAvailable]
]

{ #category : #filters }
SMLoader >> filterPublished [
	^[:package | package isPublished]
]

{ #category : #'filter utilities' }
SMLoader >> filterRemove: anObject [

	self changeFilters: (self filters copyWithout: anObject)

]

{ #category : #filters }
SMLoader >> filterSafelyAvailable [
	
	^[:package | package isSafelyAvailable]
]

{ #category : #'filter utilities' }
SMLoader >> filterSpecs [
	"Return a specification for the filter menu. Is called each time."

	| specs |
	specs := #(
	#('Auto-installable packages' #filterAutoInstall 'display only packages that can be installed automatically')
	#('New available packages' #filterAvailable 'display only packages that are not installed or that have newer releases available.')
	#('New safely-available packages' #filterSafelyAvailable 'display only packages that are not installed or that have newer releases available that are safe to install, meaning that they are published and meant for the current version of Squeak.')
	#('Installed packages' #filterInstalled 'Display only packages that are installed.')
	#('Published packages' #filterPublished 'Display only packages that have at least one published release.'))
		asOrderedCollection.
	categoriesToFilterIds do: [:catId |
		specs add: {'Packages in ', (model object: catId) name. catId. 'Display only packages that are in the category.'}].
	^ specs
]

{ #category : #filters }
SMLoader >> filterVersion [
	"Ignore spaces in the version string, they're sometimes spurious.

	Not used anymore."

	^[:package | package categories anySatisfy:  
		[:cat | (cat name, '*') match: (Smalltalk version copyWithout: $ ) ]]
]

{ #category : #'filter utilities' }
SMLoader >> filters [
	^filters
]

{ #category : #actions }
SMLoader >> findPackage: aString notifying: aView [ 
	"Search and select a package with the given (sub) string in the name or description."
	| index list match descriptions |
	match := aString asString asLowercase.
	index := self packagesListIndex.
	list := self packageNameList.
	list isEmpty ifTrue: [^self].
	descriptions := self packageWrapperList collect: [:e | e withoutListWrapper description].
	index + 1 to: list size
		do: 
			[:i | 
			(((list at: i) includesSubstring: match caseSensitive: false) or:
				[(descriptions at: i) includesSubstring: match caseSensitive: false])
				ifTrue: [^self packagesListIndex: i]].
	"wrap around"
	1 to: index
		do: 
			[:i | 
			(((list at: i) includesSubstring: match caseSensitive: false) or:
				[(descriptions at: i) includesSubstring: match caseSensitive: false])
				ifTrue: [^self packagesListIndex: i]].
	self inform: 'No package matching ' , aString asString
]

{ #category : #menus }
SMLoader >> generalOptions [
	^#( #('Upgrade all installed packages' upgradeInstalledPackagesNoConfirm)
		#('Upgrade all installed packages confirming each' upgradeInstalledPackagesConfirm)
		#('Put list in paste buffer' listInPasteBuffer)
		#('Save filters as default' saveFiltersAsDefault)
		#- )


]

{ #category : #interface }
SMLoader >> help [
	"Present help text. If there is a web server available, offer to open it.
	Use the WebBrowser registry if possible, or Scamper if available."
	| message browserClass |
	message := 'Welcome to the SqueakMap package loader. 
The names of packages are followed by (installed version -> latest version).
If there is no arrow, your installed version of the package is the latest.
Installed packages and releases are also in bold.
The checkbox menu items at the bottom let you modify which packages 
you''ll see. Take a look at them - only some packages are shown initially.
The options available for a package depend on how it was packaged.
If you like a package or have comments on it, please contact
the author or the squeak mailing list.'.

	browserClass := Smalltalk at: #WebBrowser ifPresent: [ :registry | registry default ].
	browserClass := browserClass ifNil: [ Smalltalk at: #Scamper ifAbsent: [ ^self inform: message ]].

	(self confirm: message, '
Would you like to view more detailed help on the SqueakMap swiki page?') 
	ifTrue: [ browserClass openOnUrl: 'http://wiki.squeak.org/squeak/2726' asUrl]
]

{ #category : #private }
SMLoader >> informException: ex msg: msg [ 
	"Tell the user that an error has occurred.
	Offer to open debug notifier."

	(self confirm: msg, 'Would you like to open a debugger?')
		ifTrue: [ex pass]
]

{ #category : #actions }
SMLoader >> installPackageRelease [
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
SMLoader >> installPackageRelease: aRelease [
	"Install a package release. The cache is used."

	| myRelease |
	aRelease isCompatibleWithCurrentSystemVersion ifFalse:
		[(self confirm:
'The package you are about to install is not listed as
being compatible with your image version (', SystemVersion current majorMinorVersion, '),
so the package may not work properly.
Do you still want to proceed with the install?')
			ifFalse: [^ self]].
	myRelease := self installedReleaseOfMe.
	[Cursor wait showWhile: [
		(SMInstaller forPackageRelease: aRelease) install.
		myRelease = self installedReleaseOfMe
					ifFalse: [self reOpen]
					ifTrue: [self noteChanged]]
	] on: Error do: [:ex |
		| msg |
		msg := ex messageText ifNil:[ex asString].
		self informException: ex msg: ('Error occurred during install:\', msg, '\') withCRs].
]

{ #category : #actions }
SMLoader >> installPackageWithDependents: package [

	| myRelease |
	myRelease := self installedReleaseOfMe.
	[Cursor wait showWhile: [
		package installWithDependencies.
		myRelease = self installedReleaseOfMe ifFalse: [self reOpen].
		self noteChanged]
	] on: Error do: [:ex |
		| msg |
		msg := ex messageText ifNil:[ex asString].
		self informException: ex msg: ('Error occurred during install:\', msg, '\') withCRs].
]

{ #category : #private }
SMLoader >> installedReleaseOfMe [
	"Return the release of the installed package loader."

	^SMSqueakMap default installedReleaseOf: (SMSqueakMap default packageWithId: '941c0108-4039-4071-9863-a8d7d2b3d4a3').
]

{ #category : #'filter utilities' }
SMLoader >> labelForFilter: aFilterSymbol [ 
	^(self filterSpecs detect: [:fs | fs second = aFilterSymbol]) first
]

{ #category : #actions }
SMLoader >> listInPasteBuffer [
	"Useful when talking with people etc.
	Uses the map to produce a nice String."

	Clipboard clipboardText:
		(String streamContents: [:s |
			packagesList do: [:p |
				s nextPutAll: p nameWithVersionLabel; cr ]]) asText
]

{ #category : #actions }
SMLoader >> loadUpdates [
	[Cursor wait showWhile: [
		model loadUpdates.
		self noteChanged ]
	] on: Error do: [:ex |
		self informException: ex msg: ('Error occurred when updating map:\', ex messageText, '\') withCRs]
]

{ #category : #private }
SMLoader >> noteChanged [
	filters ifNil: [^self reOpen].
	model ifNotNil: [
		packagesList := nil.
		selectedCategoryWrapper := nil.
		self changed: #categoryWrapperList.
		self changed: #packageWrapperList.
		self changed: #packagesListIndex.	"update my selection"
		self contentsChanged]
]

{ #category : #initialization }
SMLoader >> on: aSqueakMap [ 
	"Initialize instance."
	model := aSqueakMap.
	model synchWithDisk.
	filters := DefaultFilters copy.
	categoriesToFilterIds := DefaultCategoriesToFilterIds copy
]

{ #category : #initialization }
SMLoader >> openAsMorph [
	"Open the loader as a Morphic window."
	"SMLoader new openAsMorph"
	
	^self createWindow openInWorld
]

{ #category : #'filter utilities' }
SMLoader >> package: aPackage filteredByCategory: aCategory [
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
SMLoader >> packageList [
	"Return a list of the SMPackages that should be visible
	by applying all the filters. Also filter based on the currently
	selected category - if any."

	| list selectedCategory |
	list := packagesList ifNil: [
			packagesList := self packages select: [:p | 
				(filters ifNil: [#()]) allSatisfy: [:currFilter |
					currFilter isSymbol
						ifTrue: [(self perform: currFilter) value: p]
						ifFalse: [
						self package: p
							filteredByCategory: (model object: currFilter)]]]].
	selectedCategoryWrapper ifNotNil:
		[selectedCategory := selectedCategoryWrapper category.
		list := list select: [:each | self package: each filteredByCategory: selectedCategory]].
	self updateLabel: list.
	^list
]

{ #category : #lists }
SMLoader >> packageNameList [
	^self packageWrapperList collect: [:e | e withoutListWrapper name]
]

{ #category : #menus }
SMLoader >> packageSpecificOptions [
	| choices packageOrRelease |
	packageOrRelease := self selectedPackageOrRelease.
	choices := OrderedCollection new.
	packageOrRelease isInstallable ifTrue: [ choices add: self buttonSpecs first ].
	(packageOrRelease isDownloadable and: [ packageOrRelease isCached ]) ifTrue: [ choices add: self buttonSpecs third ].
	(packageOrRelease isPackageRelease and: [ packageOrRelease isDownloadable ]) ifTrue:
		[ choices add: #('Copy from cache' #cachePackageReleaseAndOfferToCopy 'Download selected release into cache first if needed, and then offer to copy it somewhere else.' ).
		choices add: #('Force download into cache' #downloadPackageRelease 'Force a download of the selected release into the cache.' ).
		packageOrRelease isPackageRelease ifTrue: [ choices add: #('Edit Release' #openReleaseEditor 'Open a browser on this release to make updates.' ) ].
		choices add: #('Create new Release' #createNewRelease 'Create a new release based on this release' ) ].
	choices add: self buttonSpecs second.
	^ choices
]

{ #category : #lists }
SMLoader >> packageWrapperList [
	"Return the list with each element wrapped so that it
	can be used in a SimpleHierarchicalListMorph."

	^self packageList collect: [:e | SMPackageWrapper with: e]
]

{ #category : #private }
SMLoader >> packages [
	"We request the packages as sorted by name by default."

	^model packagesByName asArray

]

{ #category : #accessing }
SMLoader >> packagesListIndex [
	^self packageWrapperList indexOf: self selectedItemWrapper
]

{ #category : #accessing }
SMLoader >> packagesListIndex: anObject [ 
	self
		selectedItemWrapper: (anObject ifNotNil: [anObject = 0
				ifFalse: [self packageWrapperList at: anObject]])
]

{ #category : #menus }
SMLoader >> packagesMenu: aMenu [ 
	"Answer the packages-list menu."

	self selectedPackageOrRelease 
		ifNotNil: [aMenu addList: self packageSpecificOptions; addLine].
	aMenu addList: self generalOptions.
	self addFiltersToMenu: aMenu.
	^aMenu
]

{ #category : #interface }
SMLoader >> perform: selector orSendTo: otherTarget [ 
	"Selector was just chosen from a menu by a user. If can respond, then  
	perform it on myself. If not, send it to otherTarget, presumably the  
	editPane from which the menu was invoked."

	(self respondsTo: selector)
		ifTrue: [^ self perform: selector]
		ifFalse: [^ super perform: selector orSendTo: otherTarget]
]

{ #category : #private }
SMLoader >> reOpen [
	"Close this package loader, probably because it has been updated,
	and open a new one."
	self inform: 'This package loader has been upgraded and will be closed and reopened to avoid strange side effects.'.
	self delete.
	(Smalltalk at: self class name) open
]

{ #category : #actions }
SMLoader >> removeCategoryFilters [
	"Remove all category filters."

	categoriesToFilterIds := OrderedCollection new
]

{ #category : #actions }
SMLoader >> removeSelectedCategoryAsFilter [
	"Remove the filter that filters on the currently selected category."

	categoriesToFilterIds remove: self selectedCategory id
]

{ #category : #actions }
SMLoader >> saveFiltersAsDefault [
	"Save the current filters as default so that they
	are selected the next time the loader is opened."

	DefaultFilters := filters copy.
	DefaultCategoriesToFilterIds := categoriesToFilterIds copy
]

{ #category : #accessing }
SMLoader >> selectedCategory [
	"Return selected category."
	^selectedCategoryWrapper ifNotNil: [:w | w withoutListWrapper]
]

{ #category : #accessing }
SMLoader >> selectedCategoryWrapper [
	^selectedCategoryWrapper
]

{ #category : #accessing }
SMLoader >> selectedCategoryWrapper: aWrapper [
	selectedCategoryWrapper := aWrapper.
	(aWrapper notNil and:
		[aWrapper withoutListWrapper objects includes: selectedItemWrapper withoutListWrapper])
		ifFalse: [self selectedItemWrapper: nil].
	self changed: #selectedCategoryWrapper.
	self changed: #packageWrapperList.
]

{ #category : #accessing }
SMLoader >> selectedItemWrapper [
	^selectedItemWrapper
]

{ #category : #accessing }
SMLoader >> selectedItemWrapper: aWrapper [
	selectedItemWrapper := aWrapper.
	self changed: #selectedItemWrapper.
	self contentsChanged
]

{ #category : #private }
SMLoader >> selectedPackageOrRelease [
	"Return selected package or package release."

	^self selectedItemWrapper ifNotNil: [:w | w withoutListWrapper]
]

{ #category : #'filter utilities' }
SMLoader >> showFilterString: aFilterSymbol [ 
	^(self stateForFilter: aFilterSymbol), (self labelForFilter: aFilterSymbol)
]

{ #category : #'filter utilities' }
SMLoader >> stateForFilter: aFilterSymbol [ 
	^(self filters includes: aFilterSymbol) ifTrue: ['<yes>'] ifFalse: ['<no>']


]

{ #category : #'filter utilities' }
SMLoader >> toggleFilterState: aFilterSymbol [ 

	^(self filters includes: (aFilterSymbol)) 
		ifTrue: [self filterRemove: aFilterSymbol]
		ifFalse: [self filterAdd: aFilterSymbol]
]

{ #category : #actions }
SMLoader >> uncheckFilters [
	"Uncheck all filters."
	
	filters := OrderedCollection new.
	self noteChanged
]

{ #category : #interface }
SMLoader >> updateLabel: packagesShown [
	"Update the label of the window."

	self setLabel: self defaultLabel , ' (',
			(packagesShown size < model packages size ifTrue: [packagesShown size printString,
			' shown out of '] ifFalse: ['']) , model packages size printString, ' packages)'
]

{ #category : #actions }
SMLoader >> upgradeInstalledPackages [
	"Tries to upgrade all installed packages to the latest published release for this
	version of Squeak. So this is a conservative approach."

	| installed old myRelease toUpgrade info |
	installed := model installedPackages.
	old := model oldPackages.
	old isEmpty ifTrue: [
			^self inform: 'All ', installed size printString, ' installed packages are up to date.'].
	toUpgrade := model upgradeableAndOldPackages.
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
			[Cursor wait showWhile: [
				model upgradeOldPackages.
				self inform: toUpgrade size printString, ' packages successfully upgraded.'.
				myRelease = self installedReleaseOfMe
					ifFalse: [self reOpen]
					ifTrue: [self noteChanged]]
			] on: Error do: [:ex |
				self informException: ex msg: ('Error occurred when upgrading old packages:\', ex messageText, '\') withCRs]]
]

{ #category : #actions }
SMLoader >> upgradeInstalledPackagesConfirm [
	"Tries to upgrade all installed packages to the latest published release for this
	version of Squeak. Confirms on each upgrade."

	^ self upgradeInstalledPackagesConfirm: true
]

{ #category : #private }
SMLoader >> upgradeInstalledPackagesConfirm: confirmEach [
	"Tries to upgrade all installed packages to the latest published release for this
	version of Squeak. If confirmEach is true we ask for every upgrade."

	| installed old myRelease toUpgrade info |
	installed := model installedPackages.
	old := model oldPackages.
	old isEmpty ifTrue: [
			^self inform: 'All ', installed size printString, ' installed packages are up to date.'].
	toUpgrade := model upgradeableAndOldPackages.
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
			[Cursor wait showWhile: [
				confirmEach ifTrue: [
					model upgradeOldPackagesConfirmBlock: [:p |
						self confirm: 'Upgrade ', p installedRelease packageNameWithVersion, ' to ',
							(p lastPublishedReleaseForCurrentSystemVersionNewerThan: p installedRelease) listName, '?']]
						ifFalse: [model upgradeOldPackages].
				self inform: toUpgrade size printString, ' packages successfully processed.'.
				myRelease = self installedReleaseOfMe
					ifFalse: [self reOpen]
					ifTrue: [self noteChanged]]
			] on: Error do: [:ex |
				self informException: ex msg: ('Error occurred when upgrading old packages:\', ex messageText, '\') withCRs]]
]

{ #category : #actions }
SMLoader >> upgradeInstalledPackagesNoConfirm [
	"Tries to upgrade all installed packages to the latest published release for this
	version of Squeak. No confirmation on each upgrade."

	^ self upgradeInstalledPackagesConfirm: false
]
