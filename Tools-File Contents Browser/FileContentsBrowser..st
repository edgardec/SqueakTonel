"
I am a class browser view on a fileout (either a source file (.st) or change set (.cs)). I do not actually load the code into to the system, nor do I alter the classes in the image. Use me to vet code in a comfortable way before loading it into your image.

From a FileList, I can be invoked by selecting a source file and selecting the ""browse code"" menu item from the yellow button menu.

I use PseudoClass, PseudoClassOrganizers, and PseudoMetaclass to model the class structure of the source file.
"
Class {
	#name : #FileContentsBrowser,
	#superclass : #Browser,
	#instVars : [
		'packages',
		'infoString'
	],
	#category : #'Tools-File Contents Browser'
}

{ #category : #'instance creation' }
FileContentsBrowser class >> browseCompressedCodeStream: aStandardFileStream [ 
	"Browse the selected file in fileIn format."
	| unzipped |
	unzipped :=  [MultiByteBinaryOrTextStream
			with:  (GZipReadStream on: aStandardFileStream) contents asString]
		ensure: [aStandardFileStream close].
	unzipped reset.
	self browseStream: unzipped named: aStandardFileStream name
]

{ #category : #'instance creation' }
FileContentsBrowser class >> browseFile: aFilename [
	"Open a file contents browser on a file of the given name"

	aFilename ifNil: [^ Beeper beep].
	self browseFiles: (Array with: aFilename)
]

{ #category : #'instance creation' }
FileContentsBrowser class >> browseFiles: fileList [
	"Open a browser on the packages found within the files in the list; we expect the list to contain acceptable filename strings.
	If there is more than one package found the browser will be a full system browser, otherwise it will be a category browser"
	^ (self createBrowserForPackagesFrom: fileList withEach: [:fileName |
			FilePackage fromFileNamed: fileName]) buildAndOpenBrowser

]

{ #category : #'instance creation' }
FileContentsBrowser class >> browseStream: aStream [

	aStream setConverterForCode.
	^ self browseStream: aStream named: aStream name
]

{ #category : #'instance creation' }
FileContentsBrowser class >> browseStream: aStream named: aString [
	"Read an already opened file stream into a browser"
	^ (self createBrowserForStream: aStream named: aString) buildAndOpenBrowser 
	
]

{ #category : #private }
FileContentsBrowser class >> createBrowserForPackagesFrom: collectionOfPackageSources withEach: filePackageCreation [

	| browser packageDict organizer |
	Cursor wait showWhile: [ 
		browser := self new.	
		packageDict := Dictionary new.
		organizer := SystemOrganizer defaultList: Array new.
	
		collectionOfPackageSources do: [:src | | package |
			package := filePackageCreation value: src.
			packageDict 
				at: package packageName 
				put: package.
			organizer 
				classifyAll: package classes keys 
				under: package packageName].	
				
		(browser := self systemOrganizer: organizer)
			packages: packageDict].
	^ browser
]

{ #category : #private }
FileContentsBrowser class >> createBrowserForStream: aStream named: aString [

	^ self createBrowserForPackagesFrom: {aStream} withEach: [:stream |
			(FilePackage new fullName: aString; fileInFrom: aStream)]
]

{ #category : #'file list services' }
FileContentsBrowser class >> fileReaderServicesForDirectory: aDirectory [
	^{ self serviceBrowseCodeFiles }
]

{ #category : #'file list services' }
FileContentsBrowser class >> fileReaderServicesForFile: fullName suffix: suffix [

	((FileStream isSourceFileSuffix: suffix) or: [ suffix = '*' ])
		ifTrue: [ ^Array with: self serviceBrowseCode].

	^(fullName endsWith: 'cs.gz')
		ifTrue: [ Array with: self serviceBrowseCompressedCode ]
		ifFalse: [#()]

]

{ #category : #'class initialization' }
FileContentsBrowser class >> initialize [

	FileServices registerFileReader: self
]

{ #category : #'file list services' }
FileContentsBrowser class >> selectAndBrowseFile: aFileList [
	"When no file are selected you can ask to browse several of them"

	| selectionPattern files |
	selectionPattern := UIManager default request:'What files?' initialAnswer: '*.cs;*.st'.
	files := (aFileList directory fileNamesMatching: selectionPattern) 
				collect: [:each | aFileList directory fullNameFor: each].
	self browseFiles: files.



]

{ #category : #'file list services' }
FileContentsBrowser class >> serviceBrowseCode [
	"Answer the service of opening a file-contents browser"

	^ (SimpleServiceEntry
		provider: self 
		label: 'code-file browser' translatedNoop
		selector: #browseStream:
		description: 'open a "file-contents browser" on this file, allowing you to view and selectively load its code' translatedNoop
		buttonLabel: 'code' translatedNoop)
		argumentGetter: [ :fileList | fileList readOnlyStream ]
]

{ #category : #'file list services' }
FileContentsBrowser class >> serviceBrowseCodeFiles [

	^  (SimpleServiceEntry 
		provider: self
		label: 'browse code files' translatedNoop
		selector: #selectAndBrowseFile:)
		argumentGetter: [ :fileList | fileList ];
		yourself
]

{ #category : #'file list services' }
FileContentsBrowser class >> serviceBrowseCompressedCode [
	"Answer a service for opening a changelist browser on a file"

	^ (SimpleServiceEntry 
		provider: self 
		label: 'code-file browser' translatedNoop
		selector: #browseCompressedCodeStream:
		description: 'open a "file-contents browser" on this file, allowing you to view and selectively load its code' translatedNoop
		buttonLabel: 'code' translatedNoop)
		argumentGetter: [ :fileList | fileList readOnlyStream ]
]

{ #category : #'file list services' }
FileContentsBrowser class >> services [
	"Answer potential file services associated with this class"

	^ {self serviceBrowseCode}.
]

{ #category : #preferences }
FileContentsBrowser class >> showMessageIcons [
	"Remove this method once PseudoClass implements the methods of the class API required to show the icons."

	^false
]

{ #category : #'class initialization' }
FileContentsBrowser class >> unload [

	FileServices unregisterFileReader: self 
]

{ #category : #'edit pane' }
FileContentsBrowser >> aboutToStyle: aStyler [
	"This is a notification that aStyler is about to re-style its text.
	Set the classOrMetaClass in aStyler, so that identifiers
	will be resolved correctly.
	Answer true to allow styling to proceed, or false to veto the styling"

	self isModeStyleable ifFalse: [^false].
	aStyler classOrMetaClass: self selectedClassOrMetaClass.
	^true
]

{ #category : #other }
FileContentsBrowser >> browseMessages [
	"Open a message set browser of all implementors of the currently selected message"

	self systemNavigation browseAllImplementorsOf: (self selectedMessageName ifNil: [ ^nil ])
]

{ #category : #'class list' }
FileContentsBrowser >> browseMethodFull [
	| myClass |
	(myClass := self selectedClassOrMetaClass) ifNotNil:
		[ToolSet browse: myClass realClass selector: self selectedMessageName]
]

{ #category : #other }
FileContentsBrowser >> browseSenders [
	"Create and schedule a message set browser on all senders of the 
	currently selected message selector. Do nothing if no message is selected."

	self hasMessageSelected 
		ifTrue: [self systemNavigation browseAllCallsOn: self selectedMessageName]
]

{ #category : #other }
FileContentsBrowser >> browseSendersOfMessages [
	"delegate to plain browseSenders since we can't (easily) find all the enst messages within the not-real method"

	^self browseSenders
]

{ #category : #other }
FileContentsBrowser >> browseVersions [
	"Create and schedule a message set browser on all versions of the 
	currently selected message selector."
	| class selector |
	(selector := self selectedMessageName) ifNotNil:
		[class := self selectedClassOrMetaClass.
		(class exists and: [class realClass includesSelector: selector]) ifTrue:
			[VersionsBrowser
				browseVersionsOf: (class realClass compiledMethodAt: selector)
				class: class realClass theNonMetaClass
				meta: class realClass isMeta
				category: self selectedMessageCategoryName
				selector: selector]]
]

{ #category : #toolbuilder }
FileContentsBrowser >> buildAndOpenBrowser [
	"assemble the spec for a file contents browser, build it and open it"
	"The browser may have either the full 4-pane layout or the simpler 3-pane version, depending on whether we have 1 or more packages to look at"

	contentsSymbol := self defaultDiffsSymbol.  "#showDiffs or #prettyDiffs"
	
	^ self packages size = 1
		ifTrue:[
			self systemCategoryListIndex: 1.
			self buildAndOpenCategoryBrowser]
		ifFalse: [self buildAndOpenFullBrowser]
]

{ #category : #toolbuilder }
FileContentsBrowser >> buildAnnotationPaneWith: builder [

	| textSpec |
	textSpec := builder pluggableInputFieldSpec new.
	textSpec 
		model: self;
		getText: #infoViewContents.
	^textSpec
]

{ #category : #toolbuilder }
FileContentsBrowser >> buildSystemCatListSingletonWith: aToolBuilder [
	"Overwritten to change callbacks for menu and keyboard interaction."
	^ aToolBuilder pluggableInputFieldSpec new
		model: self ;
		getText: #selectedSystemCategoryName ;
		setText: nil ;
"		keyPress: #systemCatSingletonKey:from: ;
"		menu: #packageListMenu:shifted:; 
"		keyPress: #packageListKey:from:;
"		yourself
]

{ #category : #toolbuilder }
FileContentsBrowser >> buildSystemCategoryListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
			model: self;
			list: #systemCategoryList; 
			getIndex: #systemCategoryListIndex; 
			setIndex: #systemCategoryListIndex:; 
			menu: #packageListMenu:shifted:; 
			keyPress: #packageListKey:from:.
	^listSpec
]

{ #category : #toolbuilder }
FileContentsBrowser >> buildWith: builder [
	"Depending upon whether we have a single package or multiple packages, we use different window specs. "

	self packages ifNil:[^self error: self class name, ' cannot be built without any packages; see class instance creation methods' ].
	^ self packages size = 1
		ifTrue:[
			self systemCategoryListIndex: 1;
			buildCategoryBrowserWith: builder]
		ifFalse: [super buildWith: builder]
]

{ #category : #other }
FileContentsBrowser >> changeMessageCategories: aString [ 
	"The characters in aString represent an edited version of the the message 
	categories for the selected class. Update this information in the system 
	and inform any dependents that the categories have been changed. This 
	message is invoked because the user had issued the categories command 
	and edited the message categories. Then the user issued the accept 
	command."

	self classOrMetaClassOrganizer changeFromString: aString.
	self editClass.
	self selectClassNamed: selectedClassName.
	^ true
]

{ #category : #'class list' }
FileContentsBrowser >> classList [
	"Answer an array of the class names of the selected category. Answer an 
	empty array if no selection exists."

	(self hasSystemCategorySelected not or:[self selectedPackage isNil])
		ifTrue: [^Array new]
		ifFalse: [^self selectedPackage classes keys asArray sort].
]

{ #category : #keys }
FileContentsBrowser >> classListKey: aChar from: view [
	aChar == $b ifTrue: [^ self browseMethodFull].
	aChar == $N ifTrue: [^ self browseClassRefs].
	self packageListKey: aChar from: view
]

{ #category : #menus }
FileContentsBrowser >> classListMenu: aMenu shifted: aBool [

	^ self menu: aMenu for: #(fileClassListMenu fileClassListMenuShifted:) shifted: aBool

]

{ #category : #accessing }
FileContentsBrowser >> contents [
	self updateInfoView.
	(editSelection == #newClass and:[self selectedPackage notNil])
		ifTrue: [^self selectedPackage packageInfo].
	editSelection == #editClass
		ifTrue:[^self modifiedClassDefinition].
	^super contents
]

{ #category : #accessing }
FileContentsBrowser >> contents: input notifying: aController [ 
	"The retrieved information has changed and its source must now be 
	updated. The information can be a variety of things, depending on the 
	list selections (such as templates for class or message definition, methods) 
	or the user menu commands (such as definition, comment, hierarchy). 
	Answer the result of updating the source."

	| aString aText theClass |
	aString := input asString.
	aText := input asText.

	editSelection == #editComment 
		ifTrue: [theClass := self selectedClass.
				theClass ifNil: [self inform: 'You must select a class
before giving it a comment.'.
				^ false].
				theClass comment: aText. ^ true].
	editSelection == #editMessageCategories 
		ifTrue: [^ self changeMessageCategories: aString].

	self inform:'You cannot change the current selection'.
	^false

]

{ #category : #menus }
FileContentsBrowser >> contentsSymbolQuints [
	"Answer a list of quintuplets representing information on the alternative views available in the code pane.  For the file-contents browser, the choices are restricted to source and the two diffing options"

	^ self sourceAndDiffsQuintsOnly
]

{ #category : #toolbuilder }
FileContentsBrowser >> defaultBrowserTitle [
	^  'File Contents Browser' 
]

{ #category : #'user interface' }
FileContentsBrowser >> defaultWindowColor [
	^ (Color r: 0.7 g: 0.7 b: 0.508)
]

{ #category : #other }
FileContentsBrowser >> didCodeChangeElsewhere [
	"Determine whether the code for the currently selected method and class has been changed somewhere else."

	| aClass |
	(aClass := self selectedClassOrMetaClass) ifNil: [^ false].

	(aClass isKindOf: PseudoClass) ifTrue: [^ false]. "class not installed"
	^super didCodeChangeElsewhere
]

{ #category : #infoView }
FileContentsBrowser >> extraInfo [
	^ (self
		methodDiffFor: (self selectedClassOrMetaClass sourceCodeAt: self selectedMessageName)
		class: self selectedClass
		selector: self selectedMessageName
		meta: self metaClassIndicated) unembellished
			ifTrue: [' - identical']
			ifFalse: [' - modified']
]

{ #category : #menus }
FileContentsBrowser >> fileClassListMenu: aMenu [
	"Answer the class list menu, ignoring the state of the shift key in this case"
	<fileClassListMenu>
	aMenu addList: #(
			('definition'		editClass)
			('comment'			editComment)
			-
			('browse full (b)'	browseMethodFull)
			('class refs (N)'	browseClassRefs)
			-
			('fileIn'			fileInClass)
			('fileOut'			fileOutClass)
			-
			('rename...'			renameClass)
			('remove'			removeClass)
			('remove existing'	removeUnmodifiedCategories)).
	^ aMenu

]

{ #category : #'fileIn\/fileOut' }
FileContentsBrowser >> fileInClass [
	Cursor read showWhile:[
		self selectedClass fileIn.
	].
]

{ #category : #'fileIn\/fileOut' }
FileContentsBrowser >> fileInMessage [
	
	self selectedMessageName ifNil: [^self].
	Cursor read showWhile: [
		self selectedClassOrMetaClass fileInMethod: self selectedMessageName.
	].
]

{ #category : #'fileIn\/fileOut' }
FileContentsBrowser >> fileInMessageCategories [
	Cursor read showWhile:[
		self selectedClassOrMetaClass fileInCategory: self selectedMessageCategoryName.
	].
]

{ #category : #'fileIn\/fileOut' }
FileContentsBrowser >> fileInPackage [
	Cursor read showWhile:[
		self selectedPackage fileIn.
	].
]

{ #category : #'fileIn\/fileOut' }
FileContentsBrowser >> fileIntoNewChangeSet [
	| p ff |
	(p := self selectedPackage) ifNil: [^ Beeper beep].
	ff := FileStream readOnlyFileNamed: p fullPackageName.
	ChangeSet newChangesFromStream: ff named: p packageName
]

{ #category : #menus }
FileContentsBrowser >> fileMessageCategoryMenu: aMenu [
	<fileMessageCategoryMenu>
	^ aMenu addList: #(
		('file in'				fileInMessageCategories)
		('file out'			fileOutMessageCategories)
		-
		('reorganize'		editMessageCategories)
		-
		('add item...'			addCategory)
		('rename...'			renameCategory)
		('remove'			removeMessageCategory)
		-
		('remove existing'	removeUnmodifiedMethods));
		yourself

]

{ #category : #menus }
FileContentsBrowser >> fileMessageListMenu: aMenu [
	<fileMessageListMenu>
	aMenu addList: #(
		('fileIn'						fileInMessage)
		('fileOut'					fileOutMessage)
		-
		('senders (n)'				browseSenders)
		('implementors (m)'			browseImplementors)
		('method inheritance (h)'	methodHierarchy)
		('versions (v)'				browseVersions)
		-
		('remove'					removeMessage)).
	^ aMenu

]

{ #category : #'fileIn\/fileOut' }
FileContentsBrowser >> fileOutClass [
	Cursor write showWhile:[
		self selectedClass fileOut.
	].
]

{ #category : #'fileIn\/fileOut' }
FileContentsBrowser >> fileOutMessageCategories [
	Cursor write showWhile:[
		self selectedClassOrMetaClass fileOutCategory: self selectedMessageCategoryName.
	].
]

{ #category : #'fileIn\/fileOut' }
FileContentsBrowser >> fileOutPackage [
	Cursor write showWhile:[
		self selectedPackage fileOut.
	].
]

{ #category : #menus }
FileContentsBrowser >> filePackageListMenu: aMenu [
	<filePackageListMenu>
	^ aMenu addList: #(
			('find class... (f)'		findClass)
			-
			('file in'			fileInPackage)
			('file into new changeset'	fileIntoNewChangeSet)
			('file out'			fileOutPackage)
			-
			('remove'			removePackage)
			-
			('remove existing'		removeUnmodifiedClasses));
		yourself

]

{ #category : #'class list' }
FileContentsBrowser >> findClass [
	| pattern foundClass classNames index foundPackage |
	self okToChange ifFalse: [^ self classNotFound].
	pattern := (UIManager default request: 'Class Name?') asLowercase.
	pattern isEmpty ifTrue: [^ self].
	classNames := Set new.
	self packages do:[:p| classNames addAll: p classes keys].
	classNames := classNames asArray select: 
		[:n | (n asLowercase indexOfSubCollection: pattern startingAt: 1) > 0].
	classNames isEmpty ifTrue: [^ self].
	index := classNames size = 1
				ifTrue:	[1]
				ifFalse:	[(UIManager default chooseFrom: classNames lines: #())].
	index = 0 ifTrue: [^ self].
	foundPackage := nil.
	foundClass := nil.
	self packages do:[:p| 
		(p classes includesKey: (classNames at: index)) ifTrue:[
			foundClass := p classes at: (classNames at: index).
			foundPackage := p]].
	foundClass isNil ifTrue:[^self].
 	self selectSystemCategory: foundPackage packageName asSymbol.
	self classListIndex: (self classList indexOf: foundClass name). 
]

{ #category : #'message list' }
FileContentsBrowser >> formattedLabel: aString forSelector: aSymbol inClass: aPseudoClass [
	"We have no way get compiled methods for a pseudo class."

	^ aString
]

{ #category : #'class list' }
FileContentsBrowser >> hasClassSelected [
	^ selectedClassName notNil 
]

{ #category : #infoView }
FileContentsBrowser >> infoString [
	^infoString ifNil: [infoString := StringHolder new]
]

{ #category : #infoView }
FileContentsBrowser >> infoViewContents [
	"Answer the string to show in the info view"

	| theClass stamp exists |
	editSelection == #newClass ifTrue: [^ self packageInfo: self selectedPackage].
	self selectedClass isNil ifTrue: [^ ''].
	theClass := Smalltalk at: self selectedClass name asSymbol ifAbsent: [].
	editSelection == #editClass ifTrue:
		[^ theClass notNil
			ifTrue: ['Class exists already in the system' translated]
			ifFalse: ['New class' translated]].
	editSelection == #editMessage ifFalse: [^ ''].
	(theClass notNil and: [self metaClassIndicated])
		ifTrue: [theClass := theClass class].

	stamp := self selectedClassOrMetaClass stampAt: self selectedMessageName.
	exists := theClass notNil and: [theClass includesSelector: self selectedMessageName].
	^ stamp = 'methodWasRemoved'
		ifTrue:
			[exists
				ifTrue:
					['Existing method removed  by this change-set' translated]
				ifFalse:
					['Removal request for a method that is not present in this image' translated]]
		ifFalse:
			[stamp, ' · ',
				(exists 
					ifTrue: ['Method already exists' translated , self extraInfo]
					ifFalse: ['New method' translated])]
]

{ #category : #other }
FileContentsBrowser >> labelString [
	"Answer the string for the window title"

	^ 'File Contents Browser ', (self selectedSystemCategory ifNil: [''])
]

{ #category : #menus }
FileContentsBrowser >> messageCategoryMenu: aMenu [
	^ self menu: aMenu for: #(fileMessageCategoryMenu fileMessageCategoryMenuShifted:)

]

{ #category : #keys }
FileContentsBrowser >> messageListKey: aChar from: view [
	aChar == $b ifTrue: [^ self browseMethodFull].
	super messageListKey: aChar from: view
]

{ #category : #menus }
FileContentsBrowser >> messageListMenu: aMenu shifted: aBool [

	^ self menu: aMenu for: #(fileMessageListMenu fileMessageListMenuShifted:) shifted: aBool

]

{ #category : #diffs }
FileContentsBrowser >> methodDiffFor: aString class: aPseudoClass selector: selector meta: meta [ 
	"Answer the diff between the current copy of the given class/selector/meta for the string provided"

	| theClass source |
	theClass := Smalltalk
				at: aPseudoClass name
				ifAbsent: [^ aString copy].
	meta
		ifTrue: [theClass := theClass class].
	(theClass includesSelector: selector)
		ifFalse: [^ aString copy].
	source := theClass sourceCodeAt: selector.
	^ Cursor wait
		showWhile: [TextDiffBuilder buildDisplayPatchFrom: source to: aString inClass: theClass prettyDiffs: self showingPrettyDiffs]
]

{ #category : #other }
FileContentsBrowser >> methodHierarchy [
	(self selectedClassOrMetaClass isNil or:
		[self selectedClassOrMetaClass hasDefinition])
			ifFalse: [super methodHierarchy]
]

{ #category : #diffs }
FileContentsBrowser >> modifiedClassDefinition [
	| pClass rClass old new diff |
	pClass := self selectedClassOrMetaClass.
	pClass hasDefinition ifFalse:[^pClass definition].
	rClass := Smalltalk at: self selectedClass name asSymbol ifAbsent:[nil].
	rClass isNil ifTrue:[^pClass definition].
	self metaClassIndicated ifTrue:[ rClass := rClass class].
	old := rClass definition.
	new := pClass definition.
	diff := Cursor wait showWhile:[
		ClassDiffBuilder buildDisplayPatchFrom: old to: new
	].
	^diff
]

{ #category : #infoView }
FileContentsBrowser >> packageInfo: p [
	| nClasses newClasses oldClasses |
	p isNil ifTrue:[^''].
	nClasses := newClasses := oldClasses := 0.
	p classes do:[:cls|
		nClasses := nClasses + 1.
		(Smalltalk hasClassNamed: cls name)
			ifTrue:[oldClasses := oldClasses + 1]
			ifFalse:[newClasses := newClasses + 1]].
	^nClasses printString,' classes (', newClasses printString, ' new / ', oldClasses printString, ' modified)'
]

{ #category : #keys }
FileContentsBrowser >> packageListKey: aChar from: view [
	aChar == $f ifTrue: [^ self findClass].
	self arrowKey: aChar from: view
]

{ #category : #menus }
FileContentsBrowser >> packageListMenu: aMenu shifted: shifted [

	^ self menu: aMenu for: #(filePackageListMenu filePackageListMenuShifted:) shifted: shifted

]

{ #category : #accessing }
FileContentsBrowser >> packages [
	^packages
]

{ #category : #accessing }
FileContentsBrowser >> packages: aDictionary [
	packages := aDictionary.
]

{ #category : #removing }
FileContentsBrowser >> removeClass [
	| class |
	self hasClassSelected ifFalse: [^ self].
	class := self selectedClass.
	(self confirm:'Are you certain that you
want to delete the class ', class name, '?') ifFalse:[^self].
	self selectedPackage removeClass: class.
	self classListIndex: 0.
	self changed: #classList.
]

{ #category : #removing }
FileContentsBrowser >> removeMessage [
	| messageName |
	self hasMessageSelected
		ifFalse: [^ self].
	self okToChange
		ifFalse: [^ self].
	messageName := self selectedMessageName.
	(self selectedClass confirmRemovalOf: messageName)
		ifFalse: [^ false].
	self selectedClassOrMetaClass removeMethod: self selectedMessageName.
	self selectMessageNamed: nil.
	self setClassOrganizer.
	"In case organization not cached"
	self changed: #messageList
]

{ #category : #removing }
FileContentsBrowser >> removeMessageCategory [
	"If a message category is selected, create a Confirmer so the user can 
	verify that the currently selected message category should be removed
 	from the system. If so, remove it."

	| messageCategoryName |
	self hasMessageCategorySelected ifFalse: [^ self].
	self okToChange ifFalse: [^ self].
	messageCategoryName := self selectedMessageCategoryName.
	(self messageList size = 0
		or: [self confirm: 'Are you sure you want to
remove this method category 
and all its methods?']) ifFalse: [^ self].
	self selectedClassOrMetaClass removeCategory: messageCategoryName.
	self messageCategoryListIndex: 0.
	self changed: #messageCategoryList.
]

{ #category : #removing }
FileContentsBrowser >> removePackage [
	self hasSystemCategorySelected ifTrue: [^ self].
	self okToChange ifFalse: [^ self].
	(self confirm: 'Are you sure you want to
remove this package 
and all its classes?') ifFalse:[^self].
	(systemOrganizer listAtCategoryNamed: self selectedSystemCategory) do:[:el|
		systemOrganizer removeElement: el].
	self packages removeKey: self selectedPackage packageName.
	systemOrganizer removeCategory: self selectedSystemCategory.
	self selectSystemCategory: nil.
	self changed: #systemCategoryList
]

{ #category : #removing }
FileContentsBrowser >> removeUnmodifiedCategories [
	| theClass |
	self okToChange ifFalse: [^self].
	theClass := self selectedClass.
	theClass isNil ifTrue: [^self].
	Cursor wait showWhile:
		[theClass removeUnmodifiedMethods: theClass selectors.
		theClass metaClass removeUnmodifiedMethods: theClass metaClass selectors].
	self messageCategoryListIndex: 0.
	self changed: #messageCategoryList.
]

{ #category : #removing }
FileContentsBrowser >> removeUnmodifiedClasses [
	| packageList |
	self okToChange ifFalse:[^self].
	packageList := self selectedPackage
						ifNil: [ self packages] 
						ifNotNil: [ Array with: self selectedPackage].
	packageList do:[:package|
		package classes copy do:[:theClass|
			Cursor wait showWhile:[
				theClass removeAllUnmodified.
			].
			theClass hasChanges ifFalse:[
				package removeClass: theClass.
			].
		]].
	self classListIndex: 0.
	self changed: #classList
]

{ #category : #removing }
FileContentsBrowser >> removeUnmodifiedMethods [
	| theClass cat |
	self okToChange ifFalse:[^self].
	theClass := self selectedClassOrMetaClass.
	theClass ifNil: [ ^self].
	cat := self selectedMessageCategoryName.
	cat ifNil: [ ^self].
	Cursor wait showWhile:[
		theClass removeUnmodifiedMethods: (theClass organization listAtCategoryNamed: cat).
	].
	self messageListIndex: 0.
	self changed: #messageList.
]

{ #category : #'class list' }
FileContentsBrowser >> renameClass [
	| oldName newName |
	self hasClassSelected ifFalse: [^ self].
	self okToChange ifFalse: [^ self].
	oldName := self selectedClass name.
	newName := (self request: 'Please type new class name'
						initialAnswer: oldName) asSymbol.
	(newName isEmpty or:[newName = oldName]) ifTrue: [^ self].
	(self selectedPackage classes includesKey: newName)
		ifTrue: [^ self error: newName , ' already exists in the package'].
	systemOrganizer classify: newName under: self selectedSystemCategory.
	systemOrganizer removeElement: oldName.
	self selectedPackage renameClass: self selectedClass to: newName.
	self changed: #classList.
	self classListIndex: ((systemOrganizer listAtCategoryNamed: self selectedSystemCategory) indexOf: newName).

]

{ #category : #'edit pane' }
FileContentsBrowser >> selectedBytecodes [
	"Compile the source code for the selected message selector and extract and return
	the bytecode listing."
	| class selector |
	class := self selectedClassOrMetaClass.
	selector := self selectedMessageName.
	contents := class sourceCodeAt: selector.
	contents := Compiler new
					parse: contents
					in: class
					notifying: nil.
	contents := contents generate.
	^ contents symbolic asText
]

{ #category : #'class list' }
FileContentsBrowser >> selectedClass [
	"Answer the class that is currently selected. Answer nil if no selection 
	exists."

	self selectedClassName == nil ifTrue: [^nil].
	^self selectedPackage classAt: self selectedClassName
]

{ #category : #metaclass }
FileContentsBrowser >> selectedClassOrMetaClass [
	"Answer the selected class or metaclass."

	| cls |
	self metaClassIndicated
		ifTrue: [^ (cls := self selectedClass) ifNotNil: [cls metaClass]]
		ifFalse: [^ self selectedClass]
]

{ #category : #'edit pane' }
FileContentsBrowser >> selectedMessage [
	"Answer a copy of the source code for the selected message selector."

	| class selector |
	class := self selectedClassOrMetaClass.
	selector := self selectedMessageName.
	contents := class sourceCodeAt: selector.
	SystemBrowser browseWithPrettyPrint 
		ifTrue: 
			[contents := class prettyPrinterClass 
						format: contents
						in: class
						notifying: nil
						decorated: false].
	self showingAnyKindOfDiffs 
		ifTrue: 
			[contents := self 
						methodDiffFor: contents
						class: self selectedClass
						selector: self selectedMessageName
						meta: self metaClassIndicated].
	^contents asText makeSelectorBoldIn: class
]

{ #category : #accessing }
FileContentsBrowser >> selectedPackage [
	| cat |
	cat := self selectedSystemCategory.
	cat isNil ifTrue:[^nil].
	^self packages at: cat asString ifAbsent:[nil]
]

{ #category : #metaclass }
FileContentsBrowser >> setClassOrganizer [
	"Install whatever organization is appropriate"
	| theClass |
	classOrganizer := nil.
	metaClassOrganizer := nil.
	self hasClassSelected ifFalse: [^ self].
	classOrganizer := (theClass := self selectedClass) organization.
	metaClassOrganizer := theClass metaClass organization.

]

{ #category : #'system category list' }
FileContentsBrowser >> systemCategoryList [

	^ self packages size = 1
		ifTrue: [super systemCategoryList allButFirst "without all category"]
		ifFalse: [super systemCategoryList]
]

{ #category : #infoView }
FileContentsBrowser >> updateInfoView [

	Smalltalk isMorphic 
		ifTrue: [self changed: #infoViewContents]
		ifFalse: [
			self infoString contents: self infoViewContents.
			self infoString changed].
]
