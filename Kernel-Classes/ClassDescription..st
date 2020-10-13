"
I add a number of facilities to basic Behaviors:
	Named instance variables
	Category organization for methods
	The notion of a name of this class (implemented as subclass responsibility)
	The maintenance of a ChangeSet, and logging changes on a file
	Most of the mechanism for fileOut.
	
I am an abstract class, in particular, my facilities are intended for inheritance by two subclasses, Class and Metaclass.

The slots 'organization' and 'methodDict' should ONLY be accessed by message in order for things to work during ImageSegment>>discoverActiveClasses (q.v.).
"
Class {
	#name : #ClassDescription,
	#superclass : #Behavior,
	#instVars : [
		'instanceVariables',
		'organization'
	],
	#classVars : [
		'TraitImpl'
	],
	#category : #'Kernel-Classes'
}

{ #category : #compiling }
ClassDescription >> acceptsLoggingOfCompilation [
	"weird name is so that it will come lexically before #compile, so that a clean build can make it through.  7/7/96 sw"

	^ true
]

{ #category : #'accessing method dictionary' }
ClassDescription >> addAndClassifySelector: selector withMethod: compiledMethod inProtocol: category notifying: requestor [
	| priorMethodOrNil |
	priorMethodOrNil := self compiledMethodAt: selector ifAbsent: [nil].
	self addSelectorSilently: selector withMethod: compiledMethod.
	SystemChangeNotifier uniqueInstance 
		doSilently: [self organization classify: selector under: category].
	priorMethodOrNil isNil
		ifTrue: [SystemChangeNotifier uniqueInstance methodAdded: compiledMethod selector: selector inProtocol: category class: self requestor: requestor]
		ifFalse: [SystemChangeNotifier uniqueInstance methodChangedFrom: priorMethodOrNil to: compiledMethod selector: selector inClass: self requestor: requestor].
]

{ #category : #'instance variables' }
ClassDescription >> addInstVarName: aString [ 
	"Add the argument, aString, as one of the receiver's instance variables."

	self subclassResponsibility
]

{ #category : #'accessing method dictionary' }
ClassDescription >> addSelector: selector withMethod: compiledMethod notifying: requestor [
	| priorMethodOrNil |
	priorMethodOrNil := self compiledMethodAt: selector ifAbsent: [nil].
	self addSelectorSilently: selector withMethod: compiledMethod.
	priorMethodOrNil isNil
		ifTrue: [SystemChangeNotifier uniqueInstance methodAdded: compiledMethod selector: selector inClass: self requestor: requestor]
		ifFalse: [SystemChangeNotifier uniqueInstance methodChangedFrom: priorMethodOrNil to: compiledMethod selector: selector inClass: self requestor: requestor].
]

{ #category : #'accessing method dictionary' }
ClassDescription >> addSelectorSilently: selector withMethod: compiledMethod [
	super addSelectorSilently: selector withMethod: compiledMethod.
	self instanceSide noteAddedSelector: selector meta: self isMeta.
]

{ #category : #'instance variables' }
ClassDescription >> allInstVarNamesEverywhere [
	"Answer the set of inst var names used by the receiver, all superclasses, and all subclasses"

	| aList |
	aList := OrderedCollection new.
	(self allSuperclasses , self withAllSubclasses asOrderedCollection) do:
		[:cls | aList addAll: cls instVarNames].
	^ aList asSet

	"BorderedMorph allInstVarNamesEverywhere"
]

{ #category : #'accessing method dictionary' }
ClassDescription >> allMethodCategoriesIntegratedThrough: mostGenericClass [
	"Answer a list of all the method categories of the receiver and all its superclasses, up through mostGenericClass"

	| aColl |
	aColl := Set new.
	self withAllSuperclasses do:
		[:aClass |
		(aClass includesBehavior: mostGenericClass) ifTrue:
			[aColl addAll: aClass organization categories]].
	aColl remove: 'no messages' asSymbol ifAbsent: [].

	^aColl asArray sort: [:a :b | a asLowercase < b asLowercase]

"ColorTileMorph allMethodCategoriesIntegratedThrough: TileMorph"
]

{ #category : #'accessing method dictionary' }
ClassDescription >> allMethodsInCategory: aName [ 
	"Answer a list of all the method categories of the receiver and all its 
	superclasses "
	| set |
	set := Set new.
	self withAllSuperclassesDo: [:aClass |
		set	addAll: (
			aName = ClassOrganizer allCategory
					ifTrue: [aClass organization allMethodSelectors]
					ifFalse: [aClass organization listAtCategoryNamed: aName])].
	^set sorted

	"TileMorph allMethodsInCategory: #initialization"
]

{ #category : #organization }
ClassDescription >> category [
	"Answer the system organization category for the receiver."

	^ self environment organization categoryOfElement: self name
]

{ #category : #'instance variables' }
ClassDescription >> checkForInstVarsOK: instVarString [
	"Return true if instVarString does no include any names used in a subclass"
	| instVarArray |
	instVarArray := Scanner new scanFieldNames: instVarString.
	self allSubclasses do:
		[:cl | cl instVarNames do:
			[:n | (instVarArray includes: n)
				ifTrue: [self error: n , ' is already used in ' , cl name.
						^ false]]].
	^ true
]

{ #category : #'instance variables' }
ClassDescription >> chooseInstVarAlphabeticallyThenDo: aBlock [
	| allVars index |
	"Put up a menu of all the instance variables in the receiver, presented in alphabetical order, and when the user chooses one, evaluate aBlock with the chosen variable as its parameter."

	allVars := self allInstVarNames.
	allVars isEmpty ifTrue: [^ self inform: 'There are no
instance variables'].
	allVars sort.

	index := (UIManager default chooseFrom: allVars lines: #() title: 'Instance variables in
', self name).
	index = 0 ifTrue: [^ self].
	aBlock value: (allVars at: index)
]

{ #category : #'instance variables' }
ClassDescription >> chooseVarThenDo: aBlock [ 
	"Put up a menu of all the instance variables in the receiver, and when
the user chooses one, evaluate aBlock with the chosen variable as its
parameter."
	| lines labelStream allVars index |
	(self allInstVarNames size + self theNonMetaClass allClassVarNames size) = 0 ifTrue: [ ^ self inform: 'There are no variables.' ].
	allVars := OrderedCollection new.
	lines := OrderedCollection new.
	labelStream := WriteStream on: (String new: 200).
	self withAllSuperclasses reverseDo:
		[ : class | | vars |
		vars := class instVarNames , class theNonMetaClass classVarNames.
		vars do:
			[ : var | labelStream
				 nextPutAll: var ;
				 cr.
			allVars add: var ].
		vars isEmpty ifFalse: [ lines add: allVars size ] ].
	labelStream skip: -1.
	"cut last CR"
	(lines size > 0 and: [ lines last = allVars size ]) ifTrue: [ lines removeLast ].
	"dispense with inelegant line beneath last item"
	index := UIManager default
		chooseFrom: (labelStream contents lines)
		lines: lines
		title: 'Variables in ' , self name.
	index = 0 ifTrue: [ ^ self ].
	aBlock value: (allVars at: index)
]

{ #category : #'fileIn\/Out' }
ClassDescription >> classComment: aString [
	"Store the comment, aString or Text or RemoteString, associated with the class we are orgainzing.  Empty string gets stored only if had a non-empty one before."
	^ self classComment: aString stamp: '<historical>'
]

{ #category : #'fileIn\/Out' }
ClassDescription >> classComment: aString stamp: aStamp [
	"Store the comment, aString or Text or RemoteString, associated with the class we are organizing.  Empty string gets stored only if had a non-empty one before."

	| ptr header file oldCommentRemoteStr |
	(aString isKindOf: RemoteString) ifTrue:
		[SystemChangeNotifier uniqueInstance classCommented: self.
		^ self organization classComment: aString stamp: aStamp].

	oldCommentRemoteStr := self organization commentRemoteStr.
	(aString size = 0) & (oldCommentRemoteStr == nil) ifTrue: [^ self organization classComment: nil].
		"never had a class comment, no need to write empty string out"

	ptr := oldCommentRemoteStr ifNil: [0] ifNotNil: [oldCommentRemoteStr sourcePointer].
	SourceFiles ifNotNil: [(file := SourceFiles at: 2) ifNotNil:
		[file setToEnd; cr; nextPut: $!.	"directly"
		"Should be saying (file command: 'H3') for HTML, but ignoring it here"
		header := String streamContents: [:strm | strm nextPutAll: self name;
			nextPutAll: ' commentStamp: '.
			aStamp storeOn: strm.
			strm nextPutAll: ' prior: '; nextPutAll: ptr printString].
		file nextChunkPut: header]].
	self organization classComment: (RemoteString newString: aString onFileNumber: 2) stamp: aStamp.
	file ifNotNil: [ InMidstOfFileinNotification signal ifFalse: [ file flush ] ].
	SystemChangeNotifier uniqueInstance classCommented: self.

]

{ #category : #'accessing comment' }
ClassDescription >> classCommentBlank [

	^String streamContents:
		[:stream|
		 stream
			nextPutAll: 'A';
			nextPutAll: (self name first isVowel ifTrue: ['n '] ifFalse: [' ']);
			nextPutAll: self name;
			nextPutAll: ' is xxxxxxxxx.';
			cr; cr;
			nextPutAll: 'Instance Variables'.

		 self instVarNames sorted do: [:each |
			stream
				crtab; nextPutAll: each;
				nextPut: $:;
				tab: 2;
				nextPutAll: '<Object>'].
		  stream cr.
		  self instVarNames sorted do: [:each |
			stream
				cr; nextPutAll: each;
				crtab; nextPutAll: '- xxxxx'; cr]]
]

{ #category : #'accessing parallel hierarchy' }
ClassDescription >> classSide [
	^self theMetaClass
]

{ #category : #'instance variables' }
ClassDescription >> classThatDefinesClassVariable: classVarName [
	"Answer the class that defines the given class variable"

	(self classPool includesKey: classVarName asSymbol) ifTrue: [^ self]. 
	^self superclass ifNotNil: [self superclass classThatDefinesClassVariable: classVarName]
]

{ #category : #'instance variables' }
ClassDescription >> classThatDefinesInstanceVariable: instVarName [
	(self instVarNames notNil and: [self instVarNames includes: instVarName asString]) ifTrue: [^ self]. 
	^self superclass ifNotNil: [self superclass classThatDefinesInstanceVariable: instVarName]
]

{ #category : #printing }
ClassDescription >> classVariablesString [
	"Answer a string of my class variable names separated by spaces."

	^String streamContents: [ :stream | 
		self classVarNames 
			do: [ :each | stream nextPutAll: each ]
			separatedBy: [ stream space ] ]
]

{ #category : #accessing }
ClassDescription >> classVersion [
	"Default.  Any class may return a later version to inform readers that use ReferenceStream.  8/17/96 tk"
	"This method allows you to distinguish between class versions when the shape of the class 
	hasn't changed (when there's no change in the instVar names).
	In the conversion methods you usually can tell by the inst var names 
	what old version you have. In a few cases, though, the same inst var 
	names were kept but their interpretation changed (like in the layoutFrame).
	By changing the class version when you keep the same instVars you can 
	warn older and newer images that they have to convert."
	^ 0
]

{ #category : #'accessing class hierarchy' }
ClassDescription >> classesThatImplementAllOf: selectorSet [
	"Return an array of any classes that implement all the messages in selectorSet."

	| found remaining |
	found := OrderedCollection new.
	selectorSet do:
		[:sel | (self methodDict includesKey: sel) ifTrue: [found add: sel]].
	found isEmpty
		ifTrue: [^ self subclasses inject: Array new
						into: [:subsThatDo :sub |
							subsThatDo , (sub classesThatImplementAllOf: selectorSet)]]
		ifFalse: [remaining := selectorSet copyWithoutAll: found.
				remaining isEmpty ifTrue: [^ Array with: self].
				^ self subclasses inject: Array new
						into: [:subsThatDo :sub |
							subsThatDo , (sub classesThatImplementAllOf: remaining)]]
]

{ #category : #'accessing comment' }
ClassDescription >> comment [
	"Answer the receiver's comment. (If missing, supply a template) "
	| aString |
	aString := self instanceSide organization classComment.
	aString isEmpty ifFalse: [^ aString].
	^self classCommentBlank
]

{ #category : #'accessing comment' }
ClassDescription >> comment: aStringOrText [
	"Set the receiver's comment to be the argument, aStringOrText."

	self instanceSide classComment: aStringOrText.
]

{ #category : #'accessing comment' }
ClassDescription >> comment: aStringOrText stamp: aStamp [
	"Set the receiver's comment to be the argument, aStringOrText."

	self instanceSide classComment: aStringOrText stamp: aStamp.
]

{ #category : #'fileIn\/Out' }
ClassDescription >> commentFollows [ 
	"Answer a ClassCommentReader who will scan in the comment."

	^ ClassCommentReader new setClass: self category: #Comment

	"False commentFollows inspect"
]

{ #category : #'accessing class hierarchy' }
ClassDescription >> commentInventory [
	"Answer a string with a count of the classes with and without comments 
	for all the classes in the package of which this class is a member."

	"Morph commentInventory"

	^ SystemOrganization commentInventory: (self category copyUpTo: $-), '*'
]

{ #category : #'fileIn\/Out' }
ClassDescription >> commentStamp: changeStamp [
	self organization commentStamp: changeStamp.
	^ self commentStamp: changeStamp prior: 0
]

{ #category : #'fileIn\/Out' }
ClassDescription >> commentStamp: changeStamp prior: indexAndOffset [
	"Prior source link ignored when filing in."

	^ ClassCommentReader new setClass: self
				category: #Comment
				changeStamp: changeStamp
]

{ #category : #compiling }
ClassDescription >> compile: code classified: heading [ 
	"Compile the argument, code, as source code in the context of the 
	receiver and install the result in the receiver's method dictionary under 
	the classification indicated by the second argument, heading. nil is to be 
	notified if an error occurs. The argument code is either a string or an 
	object that converts to a string or a PositionableStream on an object that 
	converts to a string."

	^self
		compile: code
		classified: heading
		notifying: nil
]

{ #category : #compiling }
ClassDescription >> compile: text classified: category notifying: requestor [
	| stamp |
	stamp := self acceptsLoggingOfCompilation ifTrue: [Utilities changeStamp] ifFalse: [nil].
	^ self compile: text classified: category
		withStamp: stamp notifying: requestor
]

{ #category : #compiling }
ClassDescription >> compile: text classified: category withStamp: changeStamp notifying: requestor [
	^ self compile: text classified: category withStamp: changeStamp notifying: requestor logSource: self acceptsLoggingOfCompilation
]

{ #category : #compiling }
ClassDescription >> compile: text classified: category withStamp: changeStamp notifying: requestor logSource: logSource [ 

	^self
		compile: text
		environment: (CurrentEnvironment signal ifNil: [ self environment ])
		classified: category
		withStamp: changeStamp
		notifying: requestor
		logSource: logSource
]

{ #category : #compiling }
ClassDescription >> compile: text environment: anEnvironment classified: category withStamp: changeStamp notifying: requestor [
	^ self 
		compile: text 
		environment: anEnvironment 
		classified: category 
		withStamp: changeStamp 
		notifying: requestor 
		logSource: self acceptsLoggingOfCompilation
]

{ #category : #compiling }
ClassDescription >> compile: text environment: anEnvironment classified: category withStamp: changeStamp notifying: requestor logSource: logSource [

	^self
		compileCue: (CompilationCue
						source: text
						class: self
						environment: anEnvironment
						requestor: requestor)
		classified: category
		withStamp: changeStamp
		logSource: logSource
]

{ #category : #compiling }
ClassDescription >> compile: code notifying: requestor [ 
	"Refer to the comment in Behavior|compile:notifying:." 

	^self compile: code
		 classified: ClassOrganizer default
		 notifying: requestor
]

{ #category : #compiling }
ClassDescription >> compileCue: compilationCue classified: category withStamp: changeStamp logSource: logSource [

	| methodAndNode methodNode selector |
	methodNode := self newCompiler compile: compilationCue ifFail: [^nil].
	methodAndNode := CompiledMethodWithNode 
							generateMethodFromNode: methodNode 
							trailer: (compilationCue methodTrailer ifNil:
										[self defaultMethodTrailerIfLogSource: logSource]).
	selector := methodAndNode selector.
	logSource ifTrue:
		[self
			logMethodSource: compilationCue source
			forMethodWithNode: methodAndNode 
			inCategory: category
			withStamp: changeStamp
			notifying: compilationCue requestor.
		RecentMessages default
			recordSelector: selector
			forClass: methodAndNode method methodClass
			inEnvironment: compilationCue environment].
	self
		addAndClassifySelector: selector
		withMethod: methodAndNode method
		inProtocol: category
		notifying: compilationCue requestor.
	self instanceSide
		noteCompilationOf: selector
		meta: self isClassSide.
	^selector
]

{ #category : #compiling }
ClassDescription >> compileSilently: code [ 
	"Compile the code, leaving no trail in the system log, nor in any change set, nor in the 'recent submissions' list. This should only be used when you know for sure that the compilation will succeed."

	^ self compileSilently: code classified: ClassOrganizer default.
]

{ #category : #compiling }
ClassDescription >> compileSilently: code classified: category [
	"Compile the code and classify the resulting method in the given category, leaving no trail in the system log, nor in any change set, nor in the 'recent submissions' list. This should only be used when you know for sure that the compilation will succeed."

	^ self compileSilently: code classified: category notifying: nil.
]

{ #category : #compiling }
ClassDescription >> compileSilently: code classified: category notifying: requestor [
	"Compile the code and classify the resulting method in the given category, leaving no trail in the system log, nor in any change set, nor in the 'recent submissions' list. This should only be used when you know for sure that the compilation will succeed."

	^self
		compileSilently: code
		environment: (CurrentEnvironment signal ifNil: [ self environment ])
		classified: category
		notifying: requestor
]

{ #category : #compiling }
ClassDescription >> compileSilently: code environment: anEnvironment classified: category notifying: requestor [
	"Compile the code and classify the resulting method in the given category, leaving no trail in the system log, nor in any change set, nor in the 'recent submissions' list. This should only be used when you know for sure that the compilation will succeed."

	^SystemChangeNotifier uniqueInstance doSilently: [
		self
			compile: code
			environment: anEnvironment
			classified: category
			withStamp: nil
			notifying: requestor
			logSource: false ]
]

{ #category : #copying }
ClassDescription >> copy: sel from: class [ 
	"Install the method associated with the first argument, sel, a message 
	selector, found in the method dictionary of the second argument, class, 
	as one of the receiver's methods. Classify the message under -As yet not 
	classified-."

	self copy: sel
		from: class
		classified: nil
]

{ #category : #copying }
ClassDescription >> copy: sel from: class classified: cat [ 
	"Install the method associated with the first arugment, sel, a message 
	selector, found in the method dictionary of the second argument, class, 
	as one of the receiver's methods. Classify the message under the third 
	argument, cat."

	"Useful when modifying an existing class"
	(class sourceCodeAt: sel ifAbsent: []) ifNotNil:
		[:code| | method category |
		method := class compiledMethodAt: sel.
		category := cat == nil
						ifTrue: [class organization categoryOfElement: sel]
						ifFalse: [cat].
		((self methodDict includesKey: sel)
		 and: [code asString ~= (self sourceCodeAt: sel) asString]) ifTrue:
			[self error: self name , ' '  , sel  , ' will be redefined if you proceed.'].
		self compile: code classified: category withStamp: method timeStamp notifying: nil]
]

{ #category : #copying }
ClassDescription >> copyAll: selArray from: class [ 
	"Install all the methods found in the method dictionary of the second 
	argument, class, as the receiver's methods. Classify the messages under 
	-As yet not classified-."

	self copyAll: selArray
		from: class
		classified: nil
]

{ #category : #copying }
ClassDescription >> copyAll: selArray from: class classified: cat [ 
	"Install all the methods found in the method dictionary of the second 
	argument, class, as the receiver's methods. Classify the messages under 
	the third argument, cat."

	selArray do: 
		[:s | self copy: s
				from: class
				classified: cat]
]

{ #category : #copying }
ClassDescription >> copyAllCategoriesFrom: aClass [ 
	"Specify that the categories of messages for the receiver include all of 
	those found in the class, aClass. Install each of the messages found in 
	these categories into the method dictionary of the receiver, classified 
	under the appropriate categories."

	aClass organization categories do: [:cat | self copyCategory: cat from: aClass]
]

{ #category : #copying }
ClassDescription >> copyAllCategoriesUnobtrusivelyFrom: aClass [ 
	"Specify that the categories of messages for the receiver include all of 
	those found in the class, aClass. Install each of the messages found in 
	these categories into the method dictionary of the receiver, classified 
	under the appropriate categories."

	aClass organization categories do: [:cat | self copyCategoryUnobtrusively: cat from: aClass]
]

{ #category : #copying }
ClassDescription >> copyAllUnobtrusively: selArray from: class classified: cat [ 
	"Install all the methods found in the method dictionary of the second 
	argument, class, as the receiver's methods. Classify the messages under 
	the third argument, cat."

	selArray do: 
		[:s | self copyUnobtrusively: s
				from: class
				classified: cat]
]

{ #category : #copying }
ClassDescription >> copyCategory: cat from: class [ 
	"Specify that one of the categories of messages for the receiver is cat, as 
	found in the class, class. Copy each message found in this category."

	self copyCategory: cat
		from: class
		classified: cat
]

{ #category : #copying }
ClassDescription >> copyCategory: cat from: aClass classified: newCat [ 
	"Specify that one of the categories of messages for the receiver is the 
	third argument, newCat. Copy each message found in the category cat in 
	class aClass into this new category."

	self copyAll: (aClass organization listAtCategoryNamed: cat)
		from: aClass
		classified: newCat
]

{ #category : #copying }
ClassDescription >> copyCategoryUnobtrusively: cat from: class [ 
	"Specify that one of the categories of messages for the receiver is cat, as 
	found in the class, class. Copy each message found in this category."

	self copyUnobtrusivelyCategory: cat
		from: class
		classified: cat
]

{ #category : #copying }
ClassDescription >> copyMethodDictionaryFrom: donorClass [
	"Copy the method dictionary of the donor class over to the receiver"

	self methodDict: donorClass copyOfMethodDictionary.
	self organization: donorClass organization deepCopy.
]

{ #category : #copying }
ClassDescription >> copyUnobtrusively: sel from: class classified: cat [ 
	"Install the method associated with the first arugment, sel, a message 
	selector, found in the method dictionary of the second argument, class, 
	as one of the receiver's methods. Classify the message under the third 
	argument, cat."

	| code category |
	"Useful when modifying an existing class"
	code := class sourceMethodAt: sel.
	code == nil
		ifFalse: 
			[cat == nil
				ifTrue: [category := class organization categoryOfElement: sel]
				ifFalse: [category := cat].
			(self methodDict includesKey: sel)
				ifTrue: [].
			self compileSilently: code classified: category]
]

{ #category : #copying }
ClassDescription >> copyUnobtrusivelyCategory: cat from: aClass classified: newCat [ 
	"Specify that one of the categories of messages for the receiver is the 
	third argument, newCat. Copy each message found in the category cat in 
	class aClass into this new category."

	self copyAllUnobtrusively: (aClass organization listAtCategoryNamed: cat)
		from: aClass
		classified: newCat
]

{ #category : #'fileIn\/Out' }
ClassDescription >> definition [
	"Answer a String that defines the receiver."

	| aStream path |
	aStream := WriteStream on: (String new: 300).
	superclass == nil
		ifTrue: [aStream nextPutAll: 'ProtoObject']
		ifFalse: [path := ''.
				self environment scopeFor: superclass name from: nil
						envtAndPathIfFound: [:envt :remotePath | path := remotePath].
				aStream nextPutAll: path , superclass name].
	aStream nextPutAll: self kindOfSubclass;
			store: self name.
	(self hasTraitComposition and: [self traitComposition notEmpty]) ifTrue: [
		aStream cr; tab; nextPutAll: 'uses: ';
			nextPutAll: self traitCompositionString].
	aStream cr; tab; nextPutAll: 'instanceVariableNames: ';
			store: self instanceVariablesString.
	aStream cr; tab; nextPutAll: 'classVariableNames: ';
			store: self classVariablesString.
	aStream cr; tab; nextPutAll: 'poolDictionaries: ';
			store: self sharedPoolsString.
	aStream cr; tab; nextPutAll: 'category: ';
			store: (self environment organization categoryOfElement: self name) asString.

	superclass ifNil: [ 
		aStream nextPutAll: '.'; cr.
		aStream nextPutAll: self name.
		aStream space; nextPutAll: 'superclass: nil'. ].

	^ aStream contents
]

{ #category : #compiling }
ClassDescription >> doneCompiling [
	"A ClassBuilder has finished the compilation of the receiver.
	This message is a notification for a class that needs to do some
	cleanup / reinitialization after it has been recompiled."
]

{ #category : #private }
ClassDescription >> errorCategoryName [
	self error: 'Category name must be a String'
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutCategory: catName [ 
	^ self fileOutCategory: catName asHtml: false
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutCategory: catName asHtml: useHtml [
	"FileOut the named category, possibly in Html format."
	| internalStream |
	internalStream := WriteStream on: (String new: 1000).
	internalStream header; timeStamp.
	self fileOutCategory: catName on: internalStream moveSource: false toFile: 0.
	internalStream trailer.

	FileStream writeSourceCodeFrom: internalStream baseName: (self name , '-' , catName) isSt: true useHtml: useHtml.
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutCategory: aSymbol on: aFileStream moveSource: moveSource toFile: fileIndex [ 
	"File a description of the receiver's category, aString, onto aFileStream. If 
	moveSource, is true, then set the method source pointer to the new file position.
	Note when this method is called with moveSource=true, it is condensing the
	.sources file, and should only write one preamble per method category."

	| selectors |

	aFileStream cr.
	selectors := (aSymbol asString = ClassOrganizer allCategory)
				ifTrue: [ self organization allMethodSelectors ]
				ifFalse: [ self organization listAtCategoryNamed: aSymbol ].

	selectors := selectors select: [:each | (self includesLocalSelector: each)].
	
	"Overridden to preserve author stamps in sources file regardless"
	selectors do: [:sel |
		self printMethodChunk: sel 
			withPreamble: true
			on: aFileStream 
			moveSource: moveSource 
			toFile: fileIndex].
	^ self
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutCategoryHistorically: aSymbol on: aFileStream moveSource: moveSource toFile: fileIndex [ 
	"File a description of the receiver's category, aString, onto aFileStream, preserving direct
	 history, but excluding branches . If moveSource, is true, then set the method source pointer
	 to the new file position. Note when this method is called with moveSource=true, it is
	 condensing the sources file, and should only write one preamble per method category."

	| selectors |
	aFileStream cr.
	selectors := aSymbol asString = ClassOrganizer allCategory
					ifTrue: [self organization allMethodSelectors]
					ifFalse: [self organization listAtCategoryNamed: aSymbol].

	selectors := selectors select: [:each | self includesLocalSelector: each].
	
	"Overridden to preserve author stamps in sources file regardless."
	selectors do: [:sel |
		self printMethodChunkHistorically: sel
			on: aFileStream 
			moveSource: moveSource 
			toFile: fileIndex]
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutChangedMessages: aSet on: aFileStream [ 
	"File a description of the messages of the receiver that have been 
	changed (i.e., are entered into the argument, aSet) onto aFileStream."

	self fileOutChangedMessages: aSet
		on: aFileStream
		moveSource: false
		toFile: 0
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutChangedMessages: aSet on: aFileStream moveSource: moveSource toFile: fileIndex [ 
	"File a description of the messages of this class that have been 
	changed (i.e., are entered into the argument, aSet) onto aFileStream.  If 
	moveSource, is true, then set the method source pointer to the new file position.
	Note when this method is called with moveSource=true, it is condensing the
	.changes file, and should only write a preamble for every method."
	| org |
	(org := self organization) categories do: 
		[:cat |  | sels |
		sels := (org listAtCategoryNamed: cat) select: [:sel | aSet includes: sel].
		(moveSource == #historically
		 or: [moveSource and: [(cat beginsWith: '*') and: [cat endsWith: '-override']]])
			ifTrue: "when condensing sources/changes, preserve overridden methods"
				[sels do:
					[:sel |
					self printMethodChunkHistorically: sel on: aFileStream
						moveSource: moveSource ~~ false toFile: fileIndex]]
			ifFalse:
				[sels do:
					[:sel |  self printMethodChunk: sel withPreamble: true on: aFileStream
						moveSource: moveSource toFile: fileIndex]]]
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutChangedMessagesHistorically: aSet on: aFileStream moveSource: moveSource toFile: fileIndex [ 
	"File all historical description of the messages of this class that have been 
	changed (i.e., are entered into the argument, aSet) onto aFileStream.  If 
	moveSource, is true, then set the method source pointer to the new file position.
	Note when this method is called with moveSource=true, it is condensing the
	.changes file, and should only write a preamble for every method."
	| org |
	(org := self organization) categories do: 
		[:cat | 
		| sels |
		sels := (org listAtCategoryNamed: cat) select: [:sel | aSet includes: sel].
		sels do:
			[:sel |  self printMethodChunkHistorically: sel on: aFileStream
							moveSource: moveSource toFile: fileIndex]]
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutInitializerOn: aStream [
	"If the receiver has initialization, file it out. Backstop for subclasses."
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutMethod: selector [
	"Write source code of a single method on a file.  Make up a name for the file."
	self fileOutMethod: selector asHtml: false
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutMethod: selector asHtml: useHtml [
	"Write source code of a single method on a file in .st or .html format"

	| internalStream |
	(selector == #Comment) ifTrue: [^ self inform: 'Sorry, cannot file out class comment in isolation.'].
	(self includesSelector: selector) ifFalse: [^ self error: 'Selector ', selector asString, ' not found'].
	internalStream := WriteStream on: (String new: 1000).
	internalStream header; timeStamp.
	self printMethodChunk: selector withPreamble: true
		on: internalStream moveSource: false toFile: 0.

	FileStream writeSourceCodeFrom: internalStream baseName: (self name , '-' , (selector copyReplaceAll: ':' with: '')) isSt: true useHtml: useHtml.

]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutOn: aFileStream [ 
	"File a description of the receiver on aFileStream."

	self fileOutOn: aFileStream
		moveSource: false
		toFile: 0
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex [
	"File a description of the receiver on aFileStream.  moveSOurce is one of
	 true, false or #historically.  If the argument, moveSource, is not false, then
	 set the trailing bytes to the position of aFileStream and to fileIndex in order
	 to indicate where to find the source code.  If moveSource == #historically,
	 print out each method's history, excluding branches"

	aFileStream command: 'H3'; nextChunkPut: self definition; command: '/H3'.

	self organization
		putCommentOnFile: aFileStream
		numbered: fileIndex
		moveSource: moveSource ~~ false
		forClass: self.
	self organization categories do: 
		[:heading |
		moveSource == #historically
			ifTrue:
				[self fileOutCategoryHistorically: heading
					on: aFileStream
					moveSource: true
					toFile: fileIndex]
			ifFalse:
				[self fileOutCategory: heading
					on: aFileStream
					moveSource: moveSource
					toFile: fileIndex]]
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex initializing: aBool [
	"File out the receiver. Backstop for subclasses."
	^self fileOutOn: aFileStream moveSource: moveSource toFile: fileIndex
]

{ #category : #'fileIn\/Out' }
ClassDescription >> fileOutOrganizationOn: aFileStream [
	"File a description of the receiver's organization on aFileStream."

	aFileStream cr; nextPut: $!.
	aFileStream nextChunkPut: self name, ' reorganize'; cr.
	aFileStream nextChunkPut: self organization printString; cr
]

{ #category : #'instance variables' }
ClassDescription >> forceNewFrom: anArray [
    "Create a new instance of the class and fill
    its instance variables up with the array."
    | object max |

    object := self new.
    max := self instSize.
    anArray doWithIndex: [:each :index |
        index > max ifFalse:
            [object instVarAt: index put: each]].
    ^ object
]

{ #category : #'accessing comment' }
ClassDescription >> hasComment [
	"return whether this class truly has a comment other than the default"
	| org |
	org := self instanceSide organization.
	^org classComment isEmptyOrNil not
]

{ #category : #'accessing method dictionary' }
ClassDescription >> induceMDFault [
	"Stache a copy of the methodDict in the organization slot (hack!),
	and set the methodDict to nil.  This will induce an MD fault on any message send.
	See: ClassDescription>>recoverFromMDFault
	and ImageSegment>>discoverActiveClasses."

	organization := Array with: methodDict with: organization.
	methodDict := nil.
	self flushCache
]

{ #category : #'instance variables' }
ClassDescription >> instVarIndexFor: instVarName ifAbsent: aBlock [
	"Answer the index of the named instance variable."

	| index |
	index := instanceVariables
		ifNil: [ 0 ]
		ifNotNil: [ instanceVariables indexOf: instVarName ].
	index = 0 ifTrue: [
		^superclass
			ifNil: [ aBlock value ]
			ifNotNil: [ superclass instVarIndexFor: instVarName ifAbsent: aBlock ] ].
	^superclass 
		ifNil: [ index ]
		ifNotNil: [ index + superclass instSize ]
]

{ #category : #private }
ClassDescription >> instVarMappingFrom: oldClass [
	"Return the mapping from instVars of oldClass to new class that is used for converting old instances of oldClass."
	| oldInstVarNames |
	oldInstVarNames := oldClass allInstVarNames.
	"Using #lastIndexOf: to ensure proper behavior in case where we have duplicate ivars."
	^self allInstVarNames collect: [:instVarName | oldInstVarNames lastIndexOf: instVarName].
]

{ #category : #'instance variables' }
ClassDescription >> instVarNameForIndex: index [
	"Answer the named instance variable with index index or nil if none."

	| superInstSize |
	index > self instSize ifTrue: [^nil].
	superInstSize := superclass isNil ifTrue: [0] ifFalse: [superclass instSize].
	index > superInstSize ifTrue:
		[^instanceVariables at: index - superInstSize].
	superclass isNil ifTrue: [^nil].
	^superclass instVarNameForIndex: index
]

{ #category : #'instance variables' }
ClassDescription >> instVarNames [
	"Answer an Array of the receiver's instance variable names."

	instanceVariables == nil
		ifTrue: [^#()]
		ifFalse: [^instanceVariables]
]

{ #category : #compiling }
ClassDescription >> instVarNamesAndOffsetsDo: aBinaryBlock [
	"This is part of the interface between the compiler and a class's instance or field names.
	 The class should enumerate aBinaryBlock with the instance variable name strings and
	 their integer offsets.  The order is important. Names evaluated later will override the
	 same names occurring earlier."

	| superInstSize |
	(superInstSize := superclass notNil ifTrue: [superclass instSize] ifFalse: [0]) > 0 ifTrue:
		[superclass instVarNamesAndOffsetsDo: aBinaryBlock].
	1 to: self instSize - superInstSize do:
		[:i| aBinaryBlock value: (instanceVariables at: i) value: i + superInstSize]
]

{ #category : #'accessing parallel hierarchy' }
ClassDescription >> instanceSide [
	^ self theNonMetaClass
]

{ #category : #printing }
ClassDescription >> instanceVariablesString [
	"Answer a string of my instance variable names separated by spaces."

	^String streamContents: [ :stream |
		self instVarNames 
			do: [ :each | stream nextPutAll: each ]
			separatedBy: [ stream space ] ]
]

{ #category : #'accessing parallel hierarchy' }
ClassDescription >> isClassSide [
	^self isMeta
]

{ #category : #testing }
ClassDescription >> isDeprecated [
	"Check for \d\d(Deprecated).* name."
	
	^ (self category findString: 'Deprecated' startingAt: 3 caseSensitive: true) > 0
]

{ #category : #'accessing parallel hierarchy' }
ClassDescription >> isInstanceSide [
	^self isClassSide not
]

{ #category : #testing }
ClassDescription >> isSelectorOverridden: aSelector [

	(self includesSelector: aSelector)
		ifFalse: [^ false].
		
	self allSubclassesDo: [ :class |
		(class includesSelector: aSelector)
			ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #testing }
ClassDescription >> isSelectorOverride: aSelector [

	(self includesSelector: aSelector)
		ifFalse: [^ false].

	self allSuperclassesDo: [ :class | 
		(class includesSelector: aSelector) 
			ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'accessing method dictionary' }
ClassDescription >> isUniClass [
	"Answer whether the receiver is a uniclass."

	^ self name endsWithDigit
]

{ #category : #private }
ClassDescription >> linesOfCode [
	"An approximate measure of lines of code.
	Includes comments, but excludes blank lines."
	| lines |
	lines := self methodDict inject: 0 into: [:sum :each | sum + each linesOfCode].
	self isMeta 
		ifTrue: [^ lines]
		ifFalse: [^ lines + self class linesOfCode]
]

{ #category : #private }
ClassDescription >> logMethodSource: aText forMethodWithNode: aCompiledMethodWithNode inCategory: category withStamp: changeStamp notifying: requestor [
	| priorMethodOrNil newText |
	priorMethodOrNil := self compiledMethodAt: aCompiledMethodWithNode selector ifAbsent: [].
	(priorMethodOrNil notNil and: [priorMethodOrNil hasBreakpoint]) ifTrue:
		[priorMethodOrNil := priorMethodOrNil getAndForgetUnbreakpointedOriginal].
	newText := (requestor notNil and: [Preferences confirmFirstUseOfStyle])
					ifTrue: [aText askIfAddStyle: priorMethodOrNil req: requestor]
					ifFalse: [aText].
	aCompiledMethodWithNode method
		putSource: newText
		fromParseNode: aCompiledMethodWithNode node
		class: self
		category: category
		withStamp: changeStamp 
		inFile: 2
		priorMethod: priorMethodOrNil
]

{ #category : #'fileIn\/Out' }
ClassDescription >> methods [
	"Answer a ClassCategoryReader for compiling messages that are not classified, as in fileouts made with Smalltalk/V"

	^ ClassCategoryReader new setClass: self category: ClassOrganizer default
]

{ #category : #'fileIn\/Out' }
ClassDescription >> methodsFor: categoryName [ 
	"Answer a ClassCategoryReader for compiling the messages in the category, categoryName, of the receiver."

	^ ClassCategoryReader new setClass: self category: categoryName asSymbol

	"(False methodsFor: 'logical operations') inspect"
]

{ #category : #'fileIn\/Out' }
ClassDescription >> methodsFor: aString priorSource: sourcePosition inFile: fileIndex [
	"Prior source pointer ignored when filing in."
	^ self methodsFor: aString
]

{ #category : #'fileIn\/Out' }
ClassDescription >> methodsFor: categoryName stamp: changeStamp [ 
	^ self methodsFor: categoryName stamp: (Utilities fixStamp: changeStamp) prior: 0
]

{ #category : #'fileIn\/Out' }
ClassDescription >> methodsFor: categoryName stamp: changeStamp prior: indexAndOffset [
	"Prior source link ignored when filing in."
	^ ClassCategoryReader new setClass: self
				category: categoryName asSymbol
				changeStamp: changeStamp

"Most importantly, return the new ClassCategoryReader, so a fileIn will let it seize control.  So method will be placed in the proper category.  See the transfer of control where ReadWriteStream fileIn calls scanFrom:"
]

{ #category : #'accessing method dictionary' }
ClassDescription >> methodsInCategory: aName [ 
	"Answer a list of the methods of the receiver that are in category named aName"
	
	| aColl |
	aColl := Set withAll: (aName = ClassOrganizer allCategory
			ifTrue: [self organization allMethodSelectors]
			ifFalse: [self organization listAtCategoryNamed: aName]).
	^ aColl asArray sort
]

{ #category : #'fileIn\/Out' }
ClassDescription >> moveChangesTo: newFile [ 
	"Used in the process of condensing changes, this message requests that 
	the source code of all methods of the receiver that have been changed 
	should be moved to newFile."

	| changes |
	changes := self methodDict keys select:
					[:sel | (self compiledMethodAt: sel) fileIndex > 1].
	changes isEmpty ifTrue:
		[^self].
	newFile cr; cr; command: 'H3'; nextChunkPut: self definition; command: '/H3'; cr.
	self
		fileOutChangedMessages: changes
		on: newFile
		moveSource: #historically
		toFile: 2
]

{ #category : #'filein\/out' }
ClassDescription >> moveChangesWithVersionsTo: newFile [ 
	"Used in the process of condensing changes, this message requests that 
	the source code of all methods of the receiver that have been changed 
	should be moved to newFile."

	| changes |
	changes := self selectors select: [:sel | (self methodDict at: sel) fileIndex > 1].
	self fileOutChangedMessagesHistorically: changes
		on: newFile
		moveSource: true
		toFile: 2
]

{ #category : #'fileIn\/Out' }
ClassDescription >> moveClassCommentTo: aFileStream fileIndex: newFileIndex [
	"Called when condensing changes.  If the receiver has a class comment, and if that class comment does not reside in the .sources file, then write it to the given filestream, with the resulting RemoteString being reachable from the source file fileIndex.  Note that any existing backpointer into the .sources file is lost by this process -- a situation that maybe should be fixed someday."

	| header aStamp aCommentRemoteStr |
	self isMeta ifTrue: [^ self].  "bulletproofing only"
	((aCommentRemoteStr := self organization commentRemoteStr) isNil or:
		[aCommentRemoteStr sourceFileNumber = 1]) ifTrue: [^ self].

	aFileStream cr; nextPut: $!.
	header := String streamContents: [:strm | strm nextPutAll: self name;
		nextPutAll: ' commentStamp: '.
		(aStamp := self organization commentStamp ifNil: ['<historical>']) storeOn: strm.
		strm nextPutAll: ' prior: 0'].
	aFileStream nextChunkPut: header.
	aFileStream cr.
	self organization classComment: (RemoteString newString: self organization classComment onFileNumber: newFileIndex toFile: aFileStream) stamp: aStamp
]

{ #category : #compiling }
ClassDescription >> moveInstVarNamed: instVarName to: anotherClass after: prevInstVarName [
	"Move the given instance variable to another class."
	self == anotherClass ifFalse:[
		self notify:'Warning:' asText allBold,' moving ', instVarName printString,' from ', self name,' to ', anotherClass name,' will not be recorded in the change set correctly.
Proceed to do it anyways.'].
	^(ClassBuilder new)
		moveInstVarNamed: instVarName 
		from: self 
		to: anotherClass 
		after: prevInstVarName
]

{ #category : #private }
ClassDescription >> newInstanceFrom: oldInstance variable: variable size: instSize map: map [
	"Create a new instance of the receiver based on the given old instance.
	The supplied map contains a mapping of the old instVar names into
	the receiver's instVars"
	| new |
	variable
		ifTrue: [new := self basicNew: oldInstance basicSize]
		ifFalse: [new := self basicNew].
	1 to: instSize do: 
		[:offset |  (map at: offset) > 0 ifTrue:
			[new instVarAt: offset
					put: (oldInstance instVarAt: (map at: offset))]].
	variable 
		ifTrue: [1 to: oldInstance basicSize do: 
					[:offset |
					new basicAt: offset put: (oldInstance basicAt: offset)]].
	^new
]

{ #category : #'accessing method dictionary' }
ClassDescription >> noteAddedSelector: aSelector meta: isMeta [
	"A hook allowing some classes to react to adding of certain selectors"
]

{ #category : #compiling }
ClassDescription >> noteCompilationOf: aSelector meta: isMeta [
	"A hook allowing some classes to react to recompilation of certain selectors"
]

{ #category : #organization }
ClassDescription >> notifyOfRecategorizedSelector: element from: oldCategory to: newCategory [
	SystemChangeNotifier uniqueInstance selector: element recategorizedFrom: oldCategory to: newCategory inClass: self
]

{ #category : #'initialize-release' }
ClassDescription >> obsolete [
	"Make the receiver obsolete."
	self hasTraitComposition ifTrue: [
		self traitComposition do: [:each |
			each removeTraitUser: self]].
	superclass removeSubclass: self.
	self organization: nil.
	super obsolete.
]

{ #category : #organization }
ClassDescription >> organization [
	"Answer the instance of ClassOrganizer that represents the organization 
	of the messages of the receiver."

	organization ifNil: [
		self organization: (ClassOrganizer defaultList: self methodDict keys sort) ].
	(organization isMemberOf: Array) ifTrue: [
		self recoverFromMDFaultWithTrace ].
	
	"Making sure that subject is set correctly. It should not be necessary."
	organization ifNotNil: [ organization setSubject: self ].
	^organization
]

{ #category : #organization }
ClassDescription >> organization: aClassOrg [
	"Install an instance of ClassOrganizer that represents the organization of the messages of the receiver."

	aClassOrg ifNotNil: [aClassOrg setSubject: self].
	organization := aClassOrg
]

{ #category : #'fileIn\/Out' }
ClassDescription >> printCategoryChunk: categoryName on: aFileStream [
	^ self printCategoryChunk: categoryName withStamp: '' on: aFileStream
]

{ #category : #'fileIn\/Out' }
ClassDescription >> printCategoryChunk: category on: aFileStream priorMethod: priorMethod [
	^ self printCategoryChunk: category on: aFileStream
		withStamp: Utilities changeStamp priorMethod: priorMethod
]

{ #category : #'fileIn\/Out' }
ClassDescription >> printCategoryChunk: category on: aFileStream withStamp: changeStamp priorMethod: priorMethod [ 
	"Print a method category preamble.  This must have a category name.
	It may have an author/date stamp, and it may have a prior source link.
	If it has a prior source link, it MUST have a stamp, even if it is empty."

"The current design is that changeStamps and prior source links are preserved in the changes file.  All fileOuts include changeStamps.  Condensing sources, however, eliminates all stamps (and links, natch)."

	aFileStream cr; command: 'H3'; nextPut: $!.
	aFileStream nextChunkPut: (String streamContents:
		[:strm |
		strm nextPutAll: self name; nextPutAll: ' methodsFor: '; print: category asString.
		(changeStamp ~~ nil and:
			[changeStamp size > 0 or: [priorMethod ~~ nil]]) ifTrue:
			[strm nextPutAll: ' stamp: '; print: changeStamp].
		priorMethod ~~ nil ifTrue:
			[strm nextPutAll: ' prior: '; print: priorMethod sourcePointer]]).
	aFileStream command: '/H3'.
]

{ #category : #'fileIn\/Out' }
ClassDescription >> printCategoryChunk: categoryName withStamp: changeStamp on: aFileStream [
	^ self printCategoryChunk: categoryName on: aFileStream withStamp: changeStamp
		priorMethod: nil
]

{ #category : #'fileIn\/Out' }
ClassDescription >> printMethodChunk: selector withPreamble: doPreamble on: outStream
		moveSource: moveSource toFile: fileIndex [
	"Copy the source code for the method associated with selector onto the fileStream.  If moveSource true, then also set the source code pointer of the method."
	| preamble method oldPos newPos sourceFile endPos |
	doPreamble 
		ifTrue: [preamble := self name , ' methodsFor: ' ,
					(self organization categoryOfElement: selector) asString printString]
		ifFalse: [preamble := ''].
	method := self methodDict at: selector ifAbsent:
		[outStream nextPutAll: selector; cr.
		outStream tab; nextChunkPut: '** ERROR!  THIS SCRIPT IS MISSING ** ' translated; cr; cr.
		outStream nextPutAll: '  '.
		^ outStream].

	((method fileIndex = 0
		or: [(SourceFiles at: method fileIndex) == nil])
		or: [(oldPos := method filePosition) = 0])
		ifTrue:
		["The source code is not accessible.  We must decompile..."
		preamble size > 0 ifTrue: [outStream cr; nextPut: $!; nextChunkPut: preamble; cr].
		outStream nextChunkPut: method decompileString]
		ifFalse:
		[sourceFile := SourceFiles at: method fileIndex.
		preamble size > 0
			ifTrue:    "Copy the preamble"
				[outStream copyPreamble: preamble from: sourceFile at: oldPos]
			ifFalse:
				[sourceFile position: oldPos].
		"Copy the method chunk"
		newPos := outStream position.
		outStream copyMethodChunkFrom: sourceFile.
		sourceFile skipSeparators.      "The following chunk may have ]style["
		sourceFile peek == $] ifTrue: [
			outStream cr; copyMethodChunkFrom: sourceFile].
		moveSource ifTrue:    "Set the new method source pointer"
			[endPos := outStream position.
			method checkOKToAdd: endPos - newPos at: newPos.
			method setSourcePosition: newPos inFile: fileIndex]].
	preamble size > 0 ifTrue: [outStream nextChunkPut: ' '].
	^ outStream cr
]

{ #category : #'fileIn\/Out' }
ClassDescription >> printMethodChunkHistorically: selector on: outStream moveSource: moveSource toFile: fileIndex [
	"Copy all source codes historically for the method associated with selector onto the 
	 fileStream.  If moveSource is true, then also set the source code pointer of the method.
	 N.B. fileIndex is interpreted as follows, 0 => just a fileOut; 1 => condensing sources;
	 2 => condensing changes; therefore only changes on the chnages file before the last
	 version in the sources file are recorded."

	| preamble method newPos category changeList priorPos index |
	category := self organization categoryOfElement: selector.
	preamble := self name , ' methodsFor: ', category asString printString.
	method := self methodDict at: selector.
	(method filePosition = 0
	 or: [method fileIndex = 0
	 or: [(SourceFiles at: method fileIndex) isNil]])
		ifTrue: "no source; must decompile"
			[outStream cr; nextPut: $!; nextChunkPut: preamble; cr.
			outStream nextChunkPut: method decompileString.
			outStream nextChunkPut: ' '; cr]
		ifFalse:
			[changeList := ChangeSet directAncestryOfVersions: (ChangeSet
																	scanVersionsOf: method 
																	class: self 
																	meta: self isMeta
																	category: category 
																	selector: selector).
			newPos := priorPos := nil.
			(fileIndex = 2 "condensing changes; select changes file code and find last sources file change"
			 and: [(index := changeList findFirst: [:chgRec| chgRec fileIndex = 1]) > 0]) ifTrue:
				[priorPos := SourceFiles 
								sourcePointerFromFileIndex: 1
								andPosition: (changeList at: index) position.
				 changeList := changeList copyFrom: 1 to: index - 1].
			changeList reverseDo:
				[:chgRec|
				chgRec file closed ifTrue:
					[chgRec file reopen; setToEnd].
				outStream copyPreamble: preamble from: chgRec file at: chgRec position.
				priorPos ifNotNil:
					[outStream
						position: outStream position - 2;
						nextPutAll: ' prior: '; print: priorPos; nextPut: $!; cr].
				"Copy the method chunk"
				newPos := outStream position.
				outStream copyMethodChunkFrom: chgRec file at: chgRec position.
				chgRec file skipSeparators.      "The following chunk may have ]style["
				chgRec file peek == $] ifTrue:
					[outStream cr; copyMethodChunkFrom: chgRec file].
				outStream nextChunkPut: ' '; cr.
				chgRec position: newPos.
				priorPos := SourceFiles 
								sourcePointerFromFileIndex: fileIndex
								andPosition: newPos].
			moveSource ifTrue:
				[method setSourcePosition: newPos inFile: fileIndex]].
	^outStream
]

{ #category : #printing }
ClassDescription >> printOn: aStream [ 
	aStream nextPutAll: self name
]

{ #category : #'accessing class hierarchy' }
ClassDescription >> printSubclassesOn: aStream level: level [ 
	"As part of the algorithm for printing a description of the receiver, print the
	subclass on the file stream, aStream, indenting level times."

	| subclassNames |
	aStream crtab: level.
	aStream nextPutAll: self name.
	aStream space; print: self instVarNames.
	self == Class
		ifTrue: 
			[aStream crtab: level + 1; nextPutAll: '[ ... all the Metaclasses ... ]'.
			^self].
	subclassNames := self subclasses sort:[:c1 :c2| c1 name <= c2 name].
	"Print subclasses in alphabetical order"
	subclassNames do:
		[:subclass | subclass printSubclassesOn: aStream level: level + 1]
]

{ #category : #printing }
ClassDescription >> printWithClosureAnalysisOn: aStream [ 

	aStream nextPutAll: self name
]

{ #category : #'fileIn\/Out' }
ClassDescription >> putClassCommentToCondensedChangesFile: aFileStream [
	"Called when condensing changes.  If the receiver has a class comment, and if that class comment does not reside in the .sources file, then write it to the given filestream, with the resulting RemoteString being reachable from the source file #2.  Note that any existing backpointer into the .sources file is lost by this process -- a situation that maybe should be fixed someday."
	^self moveClassCommentTo: aFileStream fileIndex: 2
]

{ #category : #'accessing method dictionary' }
ClassDescription >> recoverFromMDFault [
	"This method handles methodDict faults to support, eg, discoverActiveClasses (qv)."
	(organization isMemberOf: Array) ifFalse: [^ self error: 'oops'].
	methodDict := organization first.
	organization := organization second.

]

{ #category : #'accessing method dictionary' }
ClassDescription >> recoverFromMDFaultWithTrace [
	"This method handles emthodDict faults to support, eg, discoverActiveClasses (qv)."
	self recoverFromMDFault.
	self environment at: #MDFaultDict ifPresent:
		[:faultDict | faultDict at: self name put:
			(String streamContents:
				[:strm | (thisContext stackOfSize: 20) do: [:item | strm print: item; cr]])]

"Execute the following statement to induce MD fault tracing.  This means that, not only will all active classes be recorded but, after a test run, MDFaultDict will contain, for every class used, a stack trace showing how it came to be used.  This statement should be executed just prior to any such text, in order to clear the traces.

	Smalltalk at: #MDFaultDict put: Dictionary new.

"
]

{ #category : #compiling }
ClassDescription >> reformatAll [
	"Reformat all methods in this class.
	Leaves old code accessible to version browsing"
	self selectorsDo: [:sel | self reformatMethodAt: sel]
]

{ #category : #compiling }
ClassDescription >> reformatMethodAt: selector [
	| newCodeString method |
	newCodeString := self prettyPrinterClass 
				format: (self sourceCodeAt: selector)
				in: self
				notifying: nil
				decorated: false.
	method := self compiledMethodAt: selector.
	method 
		putSource: newCodeString
		fromParseNode: nil
		class: self
		category: (self organization categoryOfElement: selector)
		inFile: 2
		priorMethod: method

]

{ #category : #'accessing method dictionary' }
ClassDescription >> removeCategory: aString [ 
	"Remove each of the messages categorized under aString in the method 
	dictionary of the receiver. Then remove the category aString."
	| categoryName |
	categoryName := aString asSymbol.
	(self organization listAtCategoryNamed: categoryName) do:
		[:sel | self removeSelector: sel].
	self organization removeCategory: categoryName
]

{ #category : #'instance variables' }
ClassDescription >> removeInstVarName: aString [ 
	"Remove the argument, aString, as one of the receiver's instance 
	variables. Create an error notification if the argument is not found."

	self subclassResponsibility
]

{ #category : #'accessing method dictionary' }
ClassDescription >> removeSelector: selector [ 
	"Remove the message whose selector is given from the method 
	dictionary of the receiver, if it is there. Answer nil otherwise."

	| priorMethod priorProtocol | 
	priorMethod := self compiledMethodAt: selector ifAbsent: [^ nil].
	priorProtocol := self whichCategoryIncludesSelector: selector.

	SystemChangeNotifier uniqueInstance doSilently: [
		self organization removeElement: selector].

	super removeSelector: selector.

	SystemChangeNotifier uniqueInstance 
			methodRemoved: priorMethod selector: selector inProtocol: priorProtocol class: self.
]

{ #category : #'accessing class hierarchy' }
ClassDescription >> removeUninstantiatedSubclassesSilently [
	"Remove the classes of any subclasses that have neither instances nor subclasses.  Answer the number of bytes reclaimed"
	"self removeUninstantiatedSubclassesSilently"

	| oldFree |
	oldFree := Smalltalk garbageCollect.
	
	self subclasses
		select: [:c | (c isSystemDefined not and: [c instanceCount = 0]) and: [c subclasses isEmpty]]
		thenDo: [:c | c removeFromSystem].
	
	^ Smalltalk garbageCollect - oldFree
]

{ #category : #'instance variables' }
ClassDescription >> renameInstVar: oldName to: newName [

	(self confirm: 'WARNING: Renaming of instance variables
is subject to substitution ambiguities.
Do you still wish to attempt it?') ifFalse: [self halt].
	"...In other words, this does a dumb text search-and-replace,
	which might improperly alter, eg, a literal string.  As long as
	the oldName is unique, everything should work jes' fine. - di"

	^ self renameSilentlyInstVar: oldName to: newName
]

{ #category : #'instance variables' }
ClassDescription >> renameSilentlyInstVar: old to: new [
	| i oldName newName |
	oldName := old asString.
	newName := new asString.
	(i := self instVarNames indexOf: oldName) = 0 ifTrue:
		[self error: oldName , ' is not defined in ', self name].
	self allSuperclasses , self withAllSubclasses asOrderedCollection do:
		[:cls | (cls instVarNames includes: newName) ifTrue:
			[self error: newName , ' is already used in ', cls name]].

	self instVarNames replaceFrom: i to: i with: (Array with: newName).
	self replaceSilently: oldName to: newName.	"replace in text body of all methods"
]

{ #category : #organization }
ClassDescription >> reorganize [
	"During fileIn, !Rectangle reorganize! allows Rectangle to seize control and treat the next chunk as its organization.  See the transfer of control where ReadWriteStream fileIn calls scanFrom:"

	^self organization
]

{ #category : #'instance variables' }
ClassDescription >> replaceSilently: old to: new [
	"text-replace any part of a method.  Used for class and pool variables.  Don't touch the header.  Not guaranteed to work if name appears in odd circumstances"
	| oldName newName |
	oldName := old asString.
	newName := new asString.
	self withAllSubclasses do:
		[:cls |
		| sels |
		sels := cls selectors copyWithoutAll: #(DoIt DoItIn:).
		sels do:
			[:sel |
			| oldCode newCode parser header body |
			oldCode := cls sourceCodeAt: sel.
			"Don't make changes in the method header"
			(parser := cls newParser) parseSelector: oldCode.
			header := oldCode copyFrom: 1 to: (parser endOfLastToken min: oldCode size).
			body := header size > oldCode size
					ifTrue: ['']
					ifFalse: [oldCode copyFrom: header size+1 to: oldCode size].
			newCode := header , (body copyReplaceTokens: oldName with: newName).
			newCode ~= oldCode ifTrue:
				[cls compile: newCode
					classified: (cls organization categoryOfElement: sel)
					notifying: nil]].
		cls isMeta ifFalse:
			[| oldCode newCode |
			oldCode := cls comment.
			newCode := oldCode copyReplaceTokens: oldName with: newName.
			newCode ~= oldCode ifTrue:
				[cls comment: newCode]]]
]

{ #category : #private }
ClassDescription >> setInstVarNames: instVarArray [
	"Private - for class initialization only"
	| required |
	required := self instSize.
	superclass notNil ifTrue:[required := required - superclass instSize].
	instVarArray size = required
		ifFalse:[^self error: required printString, ' instvar names are required'].
	instVarArray isEmpty
		ifTrue:[instanceVariables := nil]
		ifFalse:[instanceVariables := instVarArray asArray].
]

{ #category : #printing }
ClassDescription >> sharedPoolsString [
	"Answer a string of my shared pool names separated by spaces."

	^String streamContents: [ :stream |
		self sharedPools 
			do: [ :each |
				stream nextPutAll: (self environment 
					keyAtIdentityValue: each 
					ifAbsent: [ 'private' ]) ]
			separatedBy: [ stream space ] ]
]

{ #category : #printing }
ClassDescription >> storeOn: aStream [
	"Classes and Metaclasses have global names."

	aStream nextPutAll: self name
]

{ #category : #'accessing class hierarchy' }
ClassDescription >> subclasses [
	^ Array new
]

{ #category : #'accessing class hierarchy' }
ClassDescription >> subclassesDo: aBlock [
	"Evaluate the argument, aBlock, for each of the receiver's immediate subclasses."
	^self subclasses do: aBlock
]

{ #category : #'initialize-release' }
ClassDescription >> superclass: aClass methodDictionary: mDict format: fmt [
	"Basic initialization of the receiver"
	super superclass: aClass methodDictionary: mDict format: fmt.
	instanceVariables := nil.
	self organization: nil.
]

{ #category : #'accessing parallel hierarchy' }
ClassDescription >> theMetaClass [
	"Sent to a class or metaclass, always return the metaclass"

	^self class
]

{ #category : #'accessing parallel hierarchy' }
ClassDescription >> theNonMetaClass [
	"Sent to a class or metaclass, always return the class"

	^self
]

{ #category : #'initialize-release' }
ClassDescription >> updateInstances: oldInstances from: oldClass isMeta: isMeta [
	"Recreate any existing instances of the argument, oldClass, as instances of the receiver,
	 which is a newly changed class. Permute variables as necessary, and forward old instances
	 to new instances.  Answer nil to defeat old clients that expect an array of old instances.
	 The old behaviour, which necessitated a global GC, exchanged identities and answered
	 the old instances.  But no clients used the result.  This way we avoid the unnecessary GC,"
	| map variable instSize newInstances |

	oldInstances isEmpty ifTrue:
		[^nil]. "no instances to convert"
	isMeta ifTrue:
		[(oldInstances size = 1
		  and: [self soleInstance class == self
				or: [self soleInstance class == oldClass]]) ifFalse:
			[^self error: 'Metaclasses can only have one instance']].
	map := self instVarMappingFrom: oldClass.
	variable := self isVariable.
	instSize := self instSize.
	newInstances := Array new: oldInstances size.
	1 to: oldInstances size do:
		[:i|
		newInstances
			at: i
			put: (self newInstanceFrom: (oldInstances at: i) variable: variable size: instSize map: map)].
	"Now perform a bulk mutation of old instances into new ones"
	oldInstances elementsForwardIdentityAndHashTo: newInstances.
	^nil
]

{ #category : #'initialize-release' }
ClassDescription >> updateInstancesFrom: oldClass [
	"Recreate any existing instances of the argument, oldClass, as instances of 
	 the receiver, which is a newly changed class. Permute variables as necessary,
	 and forward old instances to new instances.. Answer nil to defeat any clients
	 that expected the old behaviour of answering the array of old instances."
	"ar 7/15/1999: The updating below is possibly dangerous. If there are any
	contexts having an old instance as receiver it might crash the system if
	the new receiver in which the context is executed has a different layout.
	See bottom below for a simple example:"
	self updateInstances: oldClass allInstances asArray from: oldClass isMeta: self isMeta.
	^nil

"This attempts to crash the VM by stepping off the end of an instance.
 As the doctor says, do not do this."
"	| crashingBlock class |
	class := Object subclass: #CrashTestDummy
		instanceVariableNames: 'instVar'
		classVariableNames: ''
		poolDictionaries: ''
		category: 'Crash-Test'.
	class compile:'instVar: value instVar := value'.
	class compile:'crashingBlock ^[instVar]'.
	crashingBlock := (class new) instVar: 42; crashingBlock.
	Object subclass: #CrashTestDummy
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'Crash-Test'.
	crashingBlock value"
]

{ #category : #'initialize-release' }
ClassDescription >> updateMethodBindingsTo: aBinding [
	"ClassBuilder support for maintaining valid method bindings."
	methodDict do: [:method| method methodClassAssociation: aBinding]
]

{ #category : #accessing }
ClassDescription >> version [
	"Allows polymoprhism with TraitDescription>>version"

	^ self classVersion
]

{ #category : #compiling }
ClassDescription >> wantsChangeSetLogging [
	"Answer whether code submitted for the receiver should be remembered by the changeSet mechanism.  7/12/96 sw"

	^ true
]

{ #category : #compiling }
ClassDescription >> wantsRecompilationProgressReported [
	"Answer whether the receiver would like progress of its recompilation reported interactively to the user."

	^ true
]

{ #category : #organization }
ClassDescription >> whichCategoryIncludesSelector: aSelector [ 
	"Answer the category of the argument, aSelector, in the organization of 
	the receiver, or answer nil if the receiver does not inlcude this selector."

	(self includesSelector: aSelector)
		ifTrue: [^ self organization categoryOfElement: aSelector]
		ifFalse: [^nil]
]

{ #category : #testing }
ClassDescription >> whichMethodsStoreInto: varName [ 
	"Answer a collection of CompiledMethod whose methods access the argument, varName,
	 as a named class or pool variable. Or let super try with a named instance variable."
	^(self bindingOf: varName)
		ifNil: [super whichMethodsStoreInto: varName]
		ifNotNil: [:ref| self methodDict values select: [:eachMethod| eachMethod writesRef: ref]]
]

{ #category : #organization }
ClassDescription >> zapOrganization [
	"Remove the organization of this class by message categories.
	This is typically done to save space in small systems.  Classes and methods
	created or filed in subsequently will, nonetheless, be organized"

	self hasTraitComposition ifFalse:[
		self organization: nil.
		self isClassSide ifFalse: [self classSide zapOrganization]
	].
]
