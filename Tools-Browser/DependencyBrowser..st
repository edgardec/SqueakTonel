"
A simple dependency browser showing five panes:
[1]: Packages: The list of available packages in the system.
[2]: Package Dependencies: The dependent packages of the currently selected package.
[3]: Class Dependencies: The classes causing the dependencies.
[4]: Class List: The classes introducing the dependencies.
[5]: Messages: The messages introducing the dependencies.
"
Class {
	#name : #DependencyBrowser,
	#superclass : #CodeHolder,
	#instVars : [
		'packageList',
		'packageDeps',
		'packageDepsList',
		'classDeps',
		'classDepsList',
		'classList',
		'messageList',
		'packageListIndex',
		'packageDepsIndex',
		'classDepsIndex',
		'classListIndex',
		'messageListIndex',
		'autoSelectString'
	],
	#category : #'Tools-Browser'
}

{ #category : #'class initialization' }
DependencyBrowser class >> initialize [
	"Initializes the receiver class"
 
	 TheWorldMenu registerOpenCommand: {'Dependency Browser'. {self. #open}}. 
]

{ #category : #opening }
DependencyBrowser class >> open [
	"DependencyBrowser open"
	^ToolBuilder open: self
]

{ #category : #contents }
DependencyBrowser >> aboutToStyle: aStyler [
	"This is a notification that aStyler is about to re-style its text.
	Set the classOrMetaClass in aStyler, so that identifiers
	will be resolved correctly.
	Answer true to allow styling to proceed, or false to veto the styling"
	| selectedClass |
	selectedClass := self classListSelection ifNil:[^false].
	self messageListSelection ifNil:[^false].
	aStyler classOrMetaClass: ((self messageListSelection == #Definition) ifFalse:[Smalltalk classNamed: selectedClass]).
	^true
]

{ #category : #accessing }
DependencyBrowser >> autoSelectString [
	^ autoSelectString
]

{ #category : #accessing }
DependencyBrowser >> autoSelectString: aString [
	autoSelectString := aString.
	self changed: #contentsSelection.
]

{ #category : #toolbuilder }
DependencyBrowser >> buildClassDepsWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		name: 'Required Classes' ;
		list: #classDepsList; 
		getIndex: #classDepsIndex; 
		setIndex: #classDepsIndex:; 
		menu: #classDepsMenu:; 
		keyPress: #classDepsKey:from:.
	^listSpec

]

{ #category : #toolbuilder }
DependencyBrowser >> buildClassListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		name: 'Client classes' ;
		list: #classList; 
		getIndex: #classListIndex; 
		setIndex: #classListIndex:; 
		menu: #classListMenu:; 
		keyPress: #classListKey:from:.
	^listSpec

]

{ #category : #toolbuilder }
DependencyBrowser >> buildMessageListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		name: 'Client methods' ;
		list: #messageList; 
		getIndex: #messageListIndex; 
		setIndex: #messageListIndex:; 
		menu: #messageListMenu:; 
		keyPress: #messageListKey:from:.
	^listSpec

]

{ #category : #toolbuilder }
DependencyBrowser >> buildPackageDepsWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		name: 'Required Packages' ;
		list: #packageDepsList; 
		getIndex: #packageDepsIndex; 
		setIndex: #packageDepsIndex:; 
		menu: #packageDepsMenu:; 
		keyPress: #packageDepsKey:from:.
	^listSpec

]

{ #category : #toolbuilder }
DependencyBrowser >> buildPackageListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		name: 'Packages' ;
		list: #packageList; 
		getIndex: #packageListIndex; 
		setIndex: #packageListIndex:; 
		menu: #packageListMenu:; 
		keyPress: #packageListKey:from:.
	^listSpec

]

{ #category : #toolbuilder }
DependencyBrowser >> buildWith: builder [
	"Create the ui for the browser"
	| windowSpec max |
	max := self wantsOptionalButtons ifTrue:[0.42] ifFalse:[0.5].
	windowSpec := self buildWindowWith: builder specs: {
		(0@0 corner: 0.2@max) -> [self buildPackageListWith: builder].
		(0.2@0 corner: 0.4@max) -> [self buildPackageDepsWith: builder].
		(0.4@0 corner: 0.6@max) -> [self buildClassDepsWith: builder].
		(0.6@0 corner: 0.8@max) -> [self buildClassListWith: builder].
		(0.8@0 corner: 1.0@max) -> [self buildMessageListWith: builder].
		(0@max corner: 1@1) -> [self buildCodePaneWith: builder].
	}.
	^builder build: windowSpec
]

{ #category : #'class deps' }
DependencyBrowser >> classDeps [
	"Class dependencies for the currently selected package"
	packageDeps ifNil: [^ #()].
	^ (packageDeps at: self packageDepsSelection ifAbsent:[#()]) sort.

]

{ #category : #'class deps' }
DependencyBrowser >> classDepsIndex [
	"Class dependency selection"
	^classDepsIndex ifNil:[0]
]

{ #category : #'class deps' }
DependencyBrowser >> classDepsIndex: idx [
	"Class dependency selection"
	classDepsIndex := idx.
	self changed: #classDepsIndex.
	classList := nil.
	self changed: #classList.
	self classListIndex: (idx = 0 ifTrue: [0] ifFalse: [1]).
]

{ #category : #'class deps' }
DependencyBrowser >> classDepsKey: aCharacter from: aPluggableListMorphPlus [ 
	aCharacter = $N ifTrue: [^ self referencesToIt: (self classDeps at: self classDepsIndex)].
]

{ #category : #'class deps' }
DependencyBrowser >> classDepsList [
	"Class dependencies for the currently selected package"

	| checkDef checkExt |
	checkDef := [:mref | mref selector = #Definition].
	checkExt := [:mref | mref category notNil and: [mref category first = $*]].
	
	^ classDepsList ifNil: [	
		classDepsList := self classDeps.
		classDepsList := classDepsList collect: [:className |
			String streamContents: [:label |
				label nextPutAll: className.
				(self depsForClassNamed: className allSatisfy: checkDef)
					ifTrue: [label nextPutAll: ' (defs only)']
					ifFalse: [(self depsForClassNamed: className allSatisfy: checkExt)
						ifTrue: [label nextPutAll: ' *exts only']
						ifFalse: [
							(self depsForClassNamed: className anySatisfy: checkDef)
								ifTrue: [label nextPutAll: ' ()'].
							(self depsForClassNamed: className anySatisfy: checkExt)
								ifTrue: [label nextPutAll: ' *']]]]]]
]

{ #category : #'class deps' }
DependencyBrowser >> classDepsMenu: aMenu [
	^aMenu
]

{ #category : #'class deps' }
DependencyBrowser >> classDepsSelection [
	"Class dependency selection"
	^(self classDepsIndex between: 1 and: self classDeps size)
		ifTrue:[self classDeps at: self classDepsIndex].
]

{ #category : #'class list' }
DependencyBrowser >> classList [
	"List of classes that refer to dependencies"
	|  selectedPackage |
	classDeps ifNil: [^ #()].
	self classDepsSelection ifNil: [^ #()].
	
	selectedPackage := PackageOrganizer default
		packageNamed: self packageListSelection ifAbsent: [nil]. 
		
	classList := (classDeps at: self classDepsSelection ifAbsent: [#()]) 
		collect: [:mref |
			mref selector = #Definition
				ifTrue: [mref actualClass name, ' (class definition)']
				ifFalse: [mref category first = $*
					ifTrue: ['*extensions']
					ifFalse: [mref actualClass name]]]
		as: Set.
	
	^ classList := classList asArray sort
]

{ #category : #'class list' }
DependencyBrowser >> classListIndex [
	"Class list selection"
	^classListIndex ifNil:[0]
]

{ #category : #'class list' }
DependencyBrowser >> classListIndex: idx [
	"Class list selection"
	classListIndex := idx.
	self changed: #classListIndex.
	self changed: #messageList.
	self messageListIndex: (idx = 0 ifTrue: [0] ifFalse: [1]).

]

{ #category : #'class list' }
DependencyBrowser >> classListMenu: aMenu [
	^aMenu
]

{ #category : #'class list' }
DependencyBrowser >> classListSelection [
	"Class list selection"
	^ self selectedClassOrMetaClass name
]

{ #category : #'package deps' }
DependencyBrowser >> computePackageDependencies: pkgName [
	"Compute the dependencies for the given package"
	| pi |
	classDeps := Dictionary new.
	packageDeps := Dictionary new.
	pkgName ifNil:[^self].
	pi := PackageOrganizer default packageNamed: pkgName ifAbsent:[^self]. "unloaded"
	pi classes do:[:pkgClass |
		(classDeps at: (pkgClass superclass ifNil:[ProtoObject]) name
			ifAbsentPut:[OrderedCollection new]) add: 
				(MethodReference class: pkgClass selector: #Definition).
		pkgClass sharedPools do: [:sharedPool |
			sharedPool isBehavior ifTrue: [
				(classDeps at: sharedPool name
					ifAbsentPut:[OrderedCollection new]) add: 
						(MethodReference class: pkgClass selector: #Definition)]]].

	pi coreMethods do:[:mref| 
		mref compiledMethod allLiteralsDo:[:lit |
			(lit isVariableBinding and: [lit value isBehavior]) ifTrue:[
				(classDeps at: lit value name ifAbsentPut:[OrderedCollection new])
					add: mref]]].

	pi extensionMethods do:[:mref|
		(classDeps at: mref actualClass name ifAbsentPut: [OrderedCollection new])
			add: mref].

	classDeps keys do:[:className| | aClass pkg |
		aClass := Smalltalk classNamed: className.
		pkg := aClass ifNil: [nil] ifNotNil: [PackageOrganizer default packageOfClass: aClass ifNone:[nil]].
		pkg ifNil:[
			Transcript cr; show: 'WARNING: No package for ', className.
			(classDeps removeKey: className) do:[:each| Transcript crtab; show: each].
		] ifNotNil:[
			(packageDeps at: pkg name ifAbsentPut:[OrderedCollection new]) add: className.
		].
	].

	(packageDeps removeKey: pkgName ifAbsent:[#()]) do:[:each|
		classDeps removeKey: each ifAbsent:[].
	].
]

{ #category : #contents }
DependencyBrowser >> contents: input notifying: aController [ 
	"The retrieved information has changed and its source must now be
	 updated. The information can be a variety of things, depending on
	 the list selections (such as templates for class or message definition,
	 methods) or the user menu commands (such as definition, comment,
	 hierarchy).  Answer the result of updating the source."

	| aString aText theClass theMethodName |
	self changed: #annotation.
	aString := input asString.
	aText := input asText.
	
	theClass := self selectedClassOrMetaClass.
	theMethodName := self selectedMessageName.
	(theClass notNil and: [theMethodName notNil]) ifTrue: [
		^ self okayToAccept
				ifFalse:
					[false]
				ifTrue:
					[self defineMessageFrom: aText notifying: aController]].
	self error: 'unacceptable accept'

]

{ #category : #accessing }
DependencyBrowser >> contentsSelection [

	^ self autoSelectString
		ifNil: [super contentsSelection]
		ifNotNil: [:term | | index |
			(index := self contents asString findString: term) > 0
				ifTrue: [index to: index + term size - 1]
				ifFalse: [super contentsSelection]]
]

{ #category : #contents }
DependencyBrowser >> defineMessageFrom: aString notifying: aController [
	"Compile the expressions in aString. Notify aController if a syntax error occurs. Install the compiled method in the selected class classified under  the currently selected message category name. Answer the selector obtained if compilation succeeds, nil otherwise."
	| selectedMessageName selector category oldMessageList |
	selectedMessageName := self selectedMessageName.
	oldMessageList := self messageList.
	contents := nil.
	selector := (self selectedClassOrMetaClass newParser parseSelector: aString).
	selector := self selectedClassOrMetaClass
				compile: aString
				classified: (category := self selectedMessageCategoryName)
				notifying: aController.
	selector == nil ifTrue: [^ false].
	contents := aString copy.
	^ true

]

{ #category : #enumerating }
DependencyBrowser >> depsForClassNamed: className allSatisfy: workBlock [

	self
		depsForClassNamed: className
		do: [:mref | (workBlock value: mref) ifFalse: [^ false]].
	^ true
]

{ #category : #enumerating }
DependencyBrowser >> depsForClassNamed: className anySatisfy: workBlock [

	self
		depsForClassNamed: className
		do: [:mref | (workBlock value: mref) ifTrue: [^ true]].
	^ false
]

{ #category : #enumerating }
DependencyBrowser >> depsForClassNamed: className do: workBlock [

	classDeps ifNil: [^ self].
	(classDeps at: className ifAbsent: [^ self]) do: workBlock.
]

{ #category : #enumerating }
DependencyBrowser >> depsForPackageNamed: packageName allSatisfy: workBlock [

	self
		depsForPackageNamed: packageName
		do: [:mref | (workBlock value: mref) ifFalse: [^ false]].
	^ true
]

{ #category : #enumerating }
DependencyBrowser >> depsForPackageNamed: packageName anySatisfy: workBlock [

	self
		depsForPackageNamed: packageName
		do: [:mref | (workBlock value: mref) ifTrue: [^ true]].
	^ false
]

{ #category : #enumerating }
DependencyBrowser >> depsForPackageNamed: packageName do: workBlock [

	packageDeps ifNil: [^ self].
	(packageDeps at: packageName) do: [:className |
		self
			depsForClassNamed: className
			do: workBlock]
]

{ #category : #'package list' }
DependencyBrowser >> hasPackageSelected [
	^ packageListIndex > 0.
]

{ #category : #'initialize-release' }
DependencyBrowser >> initialize [
	super initialize.
	packageListIndex := 0.
	packageDepsIndex := 0.
	classDepsIndex := 0.
	classListIndex := 0.
	messageListIndex := 0.
]

{ #category : #'message list' }
DependencyBrowser >> messageList [
	"List of messages creating dependencies"
	| selectedClass label filter |
	classDeps ifNil: [^ #()].
	classList ifNil: [^ #()].
	
	selectedClass := self classListSelection.
	label := classList at: classListIndex ifAbsent: [''].
	
	filter := label ifEmpty: [ [:mref | false] ] ifNotEmpty: [
		(label first = $* or: [(label endsWith: '(class definition)') not])
			ifTrue: [ [:mref | mref selector ~= #Definition and: [mref actualClass name = selectedClass]] ]
			ifFalse: [ [:mref | mref selector = #Definition and: [mref actualClass name = selectedClass]] ]].
	
	^((classDeps at: self classDepsSelection ifAbsent:[#()]) 
		select: filter
		thenCollect:[:mref| mref methodSymbol]) asSet asArray sort
]

{ #category : #'message list' }
DependencyBrowser >> messageListIndex [
	"Message list selection"
	^messageListIndex ifNil:[0]
]

{ #category : #'message list' }
DependencyBrowser >> messageListIndex: idx [
	"Message list selection"
	messageListIndex := idx.
	self changed: #messageListIndex.
	self changed: #contents.
	self changed: #annotation.
	
	self autoSelectString: self classDepsSelection.
]

{ #category : #'message list' }
DependencyBrowser >> messageListMenu: aMenu [
	^aMenu
]

{ #category : #'message list' }
DependencyBrowser >> messageListSelection [
	"Message list selection"
	^(self messageListIndex between: 1 and: self messageList size)
		ifTrue:[self messageList at: self messageListIndex]
]

{ #category : #'package deps' }
DependencyBrowser >> packageDeps [
	"Package dependencies for the currently selected package"
	packageDeps ifNil:[
		packageDeps := Dictionary new.
		Cursor wait showWhile:[
			self computePackageDependencies: self packageListSelection.
		].
	].
	^packageDeps keys sort
]

{ #category : #'package deps' }
DependencyBrowser >> packageDepsIndex [
	"Current package dependencies selection"
	^packageDepsIndex ifNil:[0]
]

{ #category : #'package deps' }
DependencyBrowser >> packageDepsIndex: aNumber [
	"Current package dependencies selection"
	packageDepsIndex := aNumber.
	self changed: #packageDepsIndex.
	
	classDepsList := nil.
	self changed: #classDepsList.
	self classDepsIndex: (aNumber = 0 ifTrue: [0] ifFalse: [1]).

]

{ #category : #'package deps' }
DependencyBrowser >> packageDepsList [
	"Package dependencies for the currently selected package"
	
	| checkDef checkExt |
	checkDef := [:mref | mref selector = #Definition].
	checkExt := [:mref | mref category notNil and: [mref category first = $*]].
	
	^ packageDepsList ifNil: [
		packageDepsList := self packageDeps.
		packageDepsList := packageDepsList collect: [:packageName |
			String streamContents: [:label |
				label nextPutAll: packageName.
				(self depsForPackageNamed: packageName allSatisfy: checkDef)
					ifTrue: [label nextPutAll: ' (defs only)']
					ifFalse: [(self depsForPackageNamed: packageName allSatisfy: checkExt)
						ifTrue: [label nextPutAll: ' *exts only']
						ifFalse: [
							(self depsForPackageNamed: packageName anySatisfy: checkDef)
								ifTrue: [label nextPutAll: ' ()'].
							(self depsForPackageNamed: packageName anySatisfy: checkExt)
								ifTrue: [label nextPutAll: ' *']]]]]]
]

{ #category : #'package deps' }
DependencyBrowser >> packageDepsMenu: aMenu [
	^aMenu
]

{ #category : #'package deps' }
DependencyBrowser >> packageDepsSelection [
	"Current package dependencies selection"
	^(self packageDepsIndex between: 1 and: self packageDeps size)
		ifTrue:[self packageDeps at: self packageDepsIndex]
]

{ #category : #'package list' }
DependencyBrowser >> packageList [
	"The base list of packages in the system"
	^packageList ifNil:[packageList := (PackageInfo allPackages collect: [ :each | each packageName]) sort]
]

{ #category : #'package list' }
DependencyBrowser >> packageListIndex [
	"Current package list selection"
	^packageListIndex ifNil:[0]
]

{ #category : #'package list' }
DependencyBrowser >> packageListIndex: aNumber [
	"Current package list selection"
	packageListIndex := aNumber.
	self changed: #packageListIndex.
	packageDeps := nil.
	packageDepsList := nil.
	self changed: #packageDepsList.
	self packageDepsIndex: (aNumber = 0 ifTrue: [0] ifFalse: [1]).

]

{ #category : #'package list' }
DependencyBrowser >> packageListKey: aChar from: view [
	aChar == $f ifTrue: [^ self findClass].
	^ self classListKey: aChar from: view
]

{ #category : #'package list' }
DependencyBrowser >> packageListMenu: aMenu [
	^aMenu
]

{ #category : #'package list' }
DependencyBrowser >> packageListSelection [
	"Current package list selection"
	^(self packageListIndex between: 1 and: self packageList size)
		ifTrue:[self packageList at: self packageListIndex]
]

{ #category : #accessing }
DependencyBrowser >> referencesToIt: aClassName [ 
	| binding environment |
	environment := self selectedEnvironment.
	binding := (environment bindingOf: aClassName) ifNil: [ ^ self ].
	self systemNavigation browseAllCallsOn: binding
]

{ #category : #'morphic ui' }
DependencyBrowser >> representsSameBrowseeAs: anotherModel [ 
	^ self hasUnacceptedEdits not
]

{ #category : #'class list' }
DependencyBrowser >> selectedClass [
	"Answer the class that is currently selected. Answer nil if no selection exists."
	
	^ self selectedClassOrMetaClass

]

{ #category : #'class list' }
DependencyBrowser >> selectedClassName [
	| idx |
	idx := classListIndex ifNil: [0].
	^ (classList ifNotNil: [ :l | l at: idx ifAbsent: [nil]])
		ifNotNil: [:label |
			label first = $*
				ifTrue: [nil "extension methods"]
				ifFalse: [(label endsWith: '(class definition)')
					ifTrue: [label findTokens first]
					ifFalse: [label "e.g., 'String' or 'String class'"]]]
]

{ #category : #'class list' }
DependencyBrowser >> selectedClassOrMetaClass [
	"Answer the class or metaclass that is currently selected. Answer nil if no selection 
	exists."
	classList ifNil: [^nil].
	^ (self selectedEnvironment classNamed: (self selectedClassName ifNil: ['']))
		ifNil: [classListIndex > 0 ifFalse: [nil] ifTrue: [
			"Use the class the current selection is depending on such as for method extensions or (base) class definitions."
			self selectedEnvironment classNamed: (self classDepsSelection ifNil: [''])]]
]

{ #category : #accessing }
DependencyBrowser >> selectedEnvironment [
	"Answer the name of the selected package or nil."

	self hasPackageSelected ifFalse: [^nil].
	^ Smalltalk globals
]

{ #category : #contents }
DependencyBrowser >> selectedMessage [
	"Source code for currently selected message"
	| className methodName mref |
	className := self classListSelection.
	methodName := self messageListSelection.
	mref := (classDeps at: self classDepsSelection ifAbsent:[#()])
		detect:[:mr| mr actualClass name = className 
						and:[mr methodSymbol = methodName]]
		ifNone:[nil].
	mref ifNil:[^self class comment].
	mref methodSymbol == #Definition ifTrue:[^mref actualClass definition].
	^mref sourceCode
]

{ #category : #'message list' }
DependencyBrowser >> selectedMessageName [
	^ self messageList at: messageListIndex ifAbsent: [nil]
]
