"
I represent a query path of the retrieval result of making a query about methods in the system. The result is a set of methods, denoted by a message selector and the class in which the method was found. As a StringHolder, the string I represent is the source code of the currently selected method. I am typically viewed in a Message Set Browser consisting of a MessageListView and a BrowserCodeView.
"
Class {
	#name : #MessageSet,
	#superclass : #CodeHolder,
	#instVars : [
		'growable',
		'messageList',
		'messageListFormatted',
		'autoSelectString',
		'messageListIndex',
		'editSelection'
	],
	#classVars : [
		'UseUnifiedMessageLabels'
	],
	#category : #'Tools-Browser'
}

{ #category : #utilities }
MessageSet class >> extantMethodsIn: aListOfMethodRefs [
	"Answer the subset of the incoming list consisting only of those message markers that refer to methods actually in the current image"


	self flag: #mref.	"may be removed in second round"


	^ aListOfMethodRefs select: [:aToken |
		self 
			parse: aToken 
			toClassAndSelector: [ :aClass :aSelector |
				aClass notNil and: [aClass includesSelector: aSelector]
			]
	]
]

{ #category : #utilities }
MessageSet class >> isPseudoSelector: aSelector [
	"Answer whether the given selector is a special marker"

	^ #(Comment Definition Hierarchy) includes: aSelector
]

{ #category : #'instance creation' }
MessageSet class >> messageList: anArray [ 
	"Answer an instance of me with message list anArray."

	^self new initializeMessageList: anArray
]

{ #category : #'instance creation' }
MessageSet class >> open: aMessageSet name: aString [ 
	"Create a standard system view for the messageSet, aMessageSet, whose label is aString."
	^ToolBuilder open: aMessageSet label: aString
]

{ #category : #'instance creation' }
MessageSet class >> openMessageList: anArray name: aString [ 
	"Create a standard system view for the message set on the list, anArray. 
	The label of the view is aString."

	self open: (self messageList: anArray) name: aString
]

{ #category : #'instance creation' }
MessageSet class >> openMessageList: messageList name: labelString autoSelect: autoSelectString [
	"Open a system view for a MessageSet on messageList. 
	 1/24/96 sw: the there-are-no msg now supplied by my sender"

	| messageSet |
	messageSet := self messageList: messageList.
	messageSet autoSelectString: autoSelectString.
	^ToolBuilder open: messageSet label: labelString
]

{ #category : #utilities }
MessageSet class >> parse: codeReferenceOrString toClassAndSelector: csBlock [
	"Decode strings of the form <className> [class] <selectorName>."

	| tuple cl |
	codeReferenceOrString ifNil: [^ csBlock value: nil value: nil].
	codeReferenceOrString isCodeReference ifTrue:
		[^codeReferenceOrString setClassAndSelectorIn: csBlock].
	codeReferenceOrString isEmpty ifTrue:
		[^csBlock value: nil value: nil].
	tuple := (codeReferenceOrString asString includesSubstring: '>>')
				ifTrue: [(codeReferenceOrString findTokens: '>>') fold: [:a :b| (a findTokens: ' '), {b first = $# ifTrue: [b allButFirst] ifFalse: [b]}]]
				ifFalse: [codeReferenceOrString asString findTokens: ' .'].
	self flag: #environments. "missing information about the class environment"
	cl := Smalltalk at: tuple first asSymbol ifAbsent: [^ csBlock value: nil value: nil].
	^(tuple size = 2 or: [tuple size > 2 and: [(tuple at: 2) ~= 'class']])
		ifTrue: [csBlock value: cl value: (tuple at: 2) asSymbol]
		ifFalse: [csBlock value: cl class value: (tuple at: 3) asSymbol]
]

{ #category : #preferences }
MessageSet class >> useUnifiedMessageLabels [
	<preference: 'Use unified message labels'
		categoryList: #(Tools tools)
		description: 'In all message set browsers such as senders and implementors, show a unified, textual representation of all method references (or messages).'
		type: #Boolean>
	^ UseUnifiedMessageLabels ifNil: [true]
]

{ #category : #preferences }
MessageSet class >> useUnifiedMessageLabels: aBoolean [

	UseUnifiedMessageLabels := aBoolean.
]

{ #category : #'code pane' }
MessageSet >> aboutToStyle: aPluggableShoutMorphOrView [
	"This is a notification that aPluggableShoutMorphOrView is about to re-style its text.
	Set the classOrMetaClass in aPluggableShoutMorphOrView, so that identifiers
	will be resolved correctly.
	Answer true to allow styling to proceed, or false to veto the styling"

	| selectedMessageName showingMethod |
	self showingSource ifFalse: [^false].
	selectedMessageName := self selectedMessageName.
	showingMethod := (#(Comment Definition Hierarchy) includes: selectedMessageName) not.
	"Hack!  setting classOrMetaClass: to nil allows doit or class definition colouring."
	aPluggableShoutMorphOrView classOrMetaClass: (showingMethod ifTrue: [self selectedClassOrMetaClass]).
	^(#(Comment Hierarchy) includes: selectedMessageName) not
]

{ #category : #'message list' }
MessageSet >> addExtraShiftedItemsTo: aMenu [
	"The shifted selector-list menu is being built.  Add items specific to MessageSet"
	self growable ifTrue:
		[aMenu addList: #(
			-
			('remove from this browser (d)'		removeMessageFromBrowser)
			('filter message list...'			filterMessageList))].
	aMenu 
		add: 'sort by date'
		action: #sortByDate
]

{ #category : #'message list' }
MessageSet >> addItem: classAndMethod [
	"Append a classAndMethod string to the list.  Select the new item."

	"Do some checks on the input?"
	self okToChange ifFalse: [^ self].
	messageList add: classAndMethod.
	self changed: #messageList.
	self messageListIndex: messageList size.
]

{ #category : #private }
MessageSet >> adjustWindowTitleAfterFiltering [
	"Set the title of the receiver's window, if any, to reflect the just-completed filtering"

	| aWindow existingLabel newLabel |

	(aWindow := self containingWindow) ifNil: [^ self].
	(existingLabel := aWindow label) isEmptyOrNil ifTrue: [^ self].
	(((existingLabel size < 3) or: [existingLabel last ~~ $]]) or: [(existingLabel at: (existingLabel size - 1)) isDigit not]) ifTrue: [^ self].
	existingLabel size to: 1 by: -1 do:
		[:anIndex | ((existingLabel at: anIndex) == $[) ifTrue:
			[newLabel := (existingLabel copyFrom: 1 to: anIndex),
				'Filtered: ',
				messageList size printString,
				']'.
			^ aWindow setLabel: newLabel]]
			


]

{ #category : #private }
MessageSet >> autoSelectString [
	"Return the string to be highlighted when making new selections. For actual keyword selectors, only select the first keyword."

	^ autoSelectString ifNotNil: [:stringOrSelector |
		(Symbol lookup: stringOrSelector)
			ifNil: [stringOrSelector "no change"]
			ifNotNil: [:selector | selector precedence = 3
				"only the first part of the keyword message"
				ifTrue: [selector copyFrom: 1 to: (selector indexOf: $:)]
				"no change"
				ifFalse: [stringOrSelector]]]

]

{ #category : #private }
MessageSet >> autoSelectString: aString [
	"Set the string to be highlighted when making new selections"
	autoSelectString := aString
]

{ #category : #'message functions' }
MessageSet >> browseAllImplementorsOf: selectorSymbol [
	self systemNavigation browseAllImplementorsOf: selectorSymbol
]

{ #category : #'message functions' }
MessageSet >> browseLocalSendersOfMessages [
	"Override so that if no method is selected it searches for senders local to the current list."

	self selectedClass ifNotNil:
		[^super browseLocalSendersOfMessages].

	self getSelectorAndSendQuery: #value:value:
		to: [:literal :label|
			self systemNavigation browseAllCallsOn: literal fromMethodReferences: messageList labelled: label]
		with: { 'messages' }
]

{ #category : #toolbuilder }
MessageSet >> buildMessageListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #messageListFormatted;
		getIndex: #messageListIndex; 
		setIndex: #messageListIndex:;
		icon: #messageIconAt:;
		helpItem: #messageHelpAt:; 
		menu: #messageListMenu:shifted:; 
		keyPress: #messageListKey:from:.
	SystemBrowser browseWithDragNDrop 
		ifTrue:[listSpec dragItem: #dragFromMessageList:].
	^listSpec

]

{ #category : #toolbuilder }
MessageSet >> buildWith: builder [
	| windowSpec max result |
	self wantsOptionalButtons ifTrue:[max := 0.3] ifFalse:[max := 0.3].
	windowSpec := self buildWindowWith: builder specs: {
		(0@0 corner: 1@max) -> [self buildMessageListWith: builder].
		(0@max corner: 1@1) -> [self buildCodePaneWith: builder].
	}.
	result := builder build: windowSpec.
	autoSelectString ifNotNil:[self changed: #autoSelect].
	^result
]

{ #category : #'message category functions' }
MessageSet >> canShowMultipleMessageCategories [
	"Answer whether the receiver is capable of showing multiple message categories"

	^ false
]

{ #category : #updating }
MessageSet >> changed: aspect [

	super changed: aspect.
	
	aspect = #messageList ifTrue: [
		messageListFormatted := nil.
		self changed: #messageListFormatted].
]

{ #category : #metaclass }
MessageSet >> classCommentIndicated [
	"Answer true iff we're viewing the class comment."

	^ editSelection == #editComment or: [ self selectedMessageName == #Comment ]
]

{ #category : #contents }
MessageSet >> contents [
	"Answer the contents of the receiver"

	^ contents == nil
		ifTrue: [currentCompiledMethod := nil. '']
		ifFalse: [self hasMessageSelected
			ifTrue: [self editContents]
			ifFalse: [currentCompiledMethod := nil. contents]]
]

{ #category : #private }
MessageSet >> contents: aString notifying: aController [ 
	"Compile the code in aString. Notify aController of any syntax errors. 
	Answer false if the compilation fails. Otherwise, if the compilation 
	created a new method, deselect the current selection. Then answer true."

	| category class oldSelector |
	self okayToAccept ifFalse: [^ false].
	class := self targetForContents: aString.
	class ifNil: [^ false].
	self setClassAndSelectorIn: [:c :os | oldSelector := os].
	(self contents: aString specialSelector: oldSelector in: class notifying: aController)
		ifTrue: [^ false].
	"Normal method accept"
	category := self selectedMessageCategoryName.
	^ self contents: aString
		oldSelector: oldSelector
		in: class
		classified: category
		notifying: aController
]

{ #category : #private }
MessageSet >> contents: aString oldSelector: oldSelector in: aClass classified: category notifying: aController [
	"Compile the code in aString. Notify aController of any syntax errors. 
	Answer false if the compilation fails. Otherwise, if the compilation 
	created a new method, deselect the current selection. Then answer true."
	| selector |
	selector := aClass compile: aString
				classified: category
				notifying: aController.
	selector == nil ifTrue: [^ false].
	self noteAcceptanceOfCodeFor: selector.
	selector == oldSelector ifFalse:
		[self reformulateListNoting: selector].
	contents := aString copy.
	self changed: #annotation.
	^ true
]

{ #category : #private }
MessageSet >> contents: aString specialSelector: oldSelector in: aClass notifying: aController [
	"If the selector is a fake to denote a different definition than that of a method,
	try to change that different object. Answer whether a special selector was found and
	handled."
	(oldSelector ~~ nil and: [oldSelector first isUppercase]) ifFalse: [^ false].
	oldSelector = #Comment ifTrue:
		[aClass comment: aString stamp: Utilities changeStamp.
		self changed: #annotation.
 			self clearUserEditFlag.
		^ true].
	oldSelector = #Definition ifTrue:
		["self defineClass: aString notifying: aController."
		aClass subclassDefinerClass
			evaluate: aString
			notifying: aController
			logged: true.
		self clearUserEditFlag.
 			^ true].
	oldSelector = #Hierarchy ifTrue:
		[self inform: 'To change the hierarchy, edit the class definitions'. 
		^ true].
	^ false
]

{ #category : #'user interface' }
MessageSet >> defaultWindowColor [
	^ (Color r: 0.719 g: 0.9 b: 0.9)
]

{ #category : #'message functions' }
MessageSet >> deleteAllFromMessageList: aCollection [
	"Delete the given messages from the receiver's message list"
	| currIdx |
	currIdx := self messageListIndex.
	messageList := messageList copyWithoutAll: aCollection.
	messageList ifNotEmpty: [self messageListIndex: {currIdx. messageList size.} min]
]

{ #category : #'message functions' }
MessageSet >> deleteFromMessageList: aMessage [
	"Delete the given message from the receiver's message list"
	| currIdx |
	currIdx := self messageListIndex.
	messageList := messageList copyWithout: aMessage.
	messageList ifNotEmpty: [self messageListIndex: {currIdx. messageList size.} min]
]

{ #category : #private }
MessageSet >> deselectAll [
	self messageListIndex: 0
]

{ #category : #accessing }
MessageSet >> doItReceiver [
	^ self selectedClass
]

{ #category : #'drag and drop' }
MessageSet >> dragFromMessageList: index [
	"Drag a method from the browser"
	^self selectedClassOrMetaClass compiledMethodAt: (self messageList at: index) ifAbsent:[nil]
]

{ #category : #'drag and drop' }
MessageSet >> dragPassengerFor: item inMorph: dragSource [ 
	| transferType |
	transferType := self dragTransferTypeForMorph: dragSource.
	transferType == #messageList
		ifTrue: [^self selectedClassOrMetaClass->(item contents findTokens: ' ') second asSymbol].
	transferType == #classList
		ifTrue: [^self selectedClass].
	^nil
]

{ #category : #accessing }
MessageSet >> editSelection: aSelection [
	"Set the editSelection as requested."

	editSelection := aSelection.
	self changed: #editSelection.
]

{ #category : #'message functions' }
MessageSet >> fileOutMessage [
	"Put a description of the selected method on a file, or all methods if none selected."

	| fileName |
	self selectedMessageName ifNotNil:
		[^super fileOutMessage].
	fileName := UIManager default saveFilenameRequest: 'File out on which file?' initialAnswer: 'methods'.
	fileName isEmptyOrNil ifTrue: [^self].
	Cursor write showWhile:
		[| internalStream |
		internalStream := WriteStream on: (String new: 1000).
		internalStream header; timeStamp.
		messageList do:
			[:methodRef|
			methodRef methodSymbol == #Comment
				ifTrue:
					[methodRef actualClass organization
						putCommentOnFile: internalStream
						numbered: 1
						moveSource: false
						forClass: methodRef actualClass]
				ifFalse:
					[methodRef actualClass
						printMethodChunk: methodRef methodSymbol
						withPreamble: true
						on: internalStream
						moveSource: false
						toFile: nil]].
		FileStream writeSourceCodeFrom: internalStream baseName: fileName isSt: true useHtml: false]
]

{ #category : #filtering }
MessageSet >> filterFrom: aBlock [
	"Filter the receiver's list down to only those items that satisfy aBlock, which takes a class an a selector as its arguments."

	| newList |
	newList := messageList select:
		[:anElement |
			self class parse: anElement toClassAndSelector: [ :cls :sel | 
				(self class isPseudoSelector: sel) not and: [  aBlock value: cls value: sel ]]].
	self setFilteredList: newList
]

{ #category : #filtering }
MessageSet >> filterMessageList [
	"Allow the user to refine the list of messages."
	| builder menuSpec |
	builder := ToolBuilder default.
	menuSpec := builder pluggableMenuSpec new
		model: self;
		yourself.
	menuSpec addList:
		#(
		('unsent messages' filterToUnsentMessages 'filter to show only messages that have no senders')
		-
		('messages that send...' filterToSendersOf 'filter to show only messages that send a selector I specify')
		('messages that do not send...' filterToNotSendersOf 'filter to show only messages that do not send a selector I specify')
		-
		('messages whose selector is...' filterToImplementorsOf 'filter to show only messages with a given selector I specify')
		('messages whose selector is NOT...' filterToNotImplementorsOf 'filter to show only messages whose selector is NOT a seletor I specify')
		-
		('messages in current change set' filterToCurrentChangeSet 'filter to show only messages that are in the current change set')
		('messages not in current change set' filterToNotCurrentChangeSet 'filter to show only messages that are not in the current change set')
		-
		('messages in any change set' filterToAnyChangeSet 'filter to show only messages that occur in at least one change set')
		('messages not in any change set' filterToNotAnyChangeSet 'filter to show only messages that do not occur in any change set in the system')
		-
		('messages authored by me' filterToCurrentAuthor 'filter to show only messages whose authoring stamp has my initials')
		('messages not authored by me' filterToNotCurrentAuthor 'filter to show only messages whose authoring stamp does not have my initials')
		-
		('messages logged in .changes file' filterToMessagesInChangesFile 'filter to show only messages whose latest source code is logged in the .changes file')
		('messages only in .sources file' filterToMessagesInSourcesFile 'filter to show only messages whose latest source code is logged in the .sources file')
		-
		('messages with prior versions'	 filterToMessagesWithPriorVersions 'filter to show only messages that have at least one prior version')
		('messages without prior versions' filterToMessagesWithoutPriorVersions 'filter to show only messages that have no prior versions')
		-
		('uncommented messages' filterToUncommentedMethods 'filter to show only messages that do not have comments at the beginning')
		('commented messages' filterToCommentedMethods 'filter to show only messages that have comments at the beginning')
		-
		('messages in hardened classes' filterToMessagesWithHardenedClasses 'filter to show only messages of established classes (as opposed to Uniclasses such as Player23)')		-
		('methods in classes with matching names' filterToMatchingClassesNames 'filter to show only methods of classes with names that match the given criteria (wildcards are allowed)')
		('methods in package...' filterToPackage 'filter to show only methods of a given package')
		('methods not in package...' filterToNotPackage 'filter to show only methods not of a given package')
		-
		('messages that...' filterToMessagesThat 'let me type in a block taking a class and a selector, which will specify yea or nay concerning which elements should remain in the list')).
	builder runModal: (builder open: menuSpec).
]

{ #category : #filtering }
MessageSet >> filterToAnyChangeSet [
	"Filter down only to messages present in ANY change set"

	self filterFrom:
		[:aClass :aSelector |
			ChangesOrganizer doesAnyChangeSetHaveClass: aClass andSelector: aSelector]

]

{ #category : #filtering }
MessageSet >> filterToCommentedMethods [
	"Filter the receiver's list down to only those items which have comments"

	self filterFrom:
		[:aClass :aSelector |
			(aClass includesSelector: aSelector) and:
						[(aClass firstPrecodeCommentFor: aSelector) isEmptyOrNil not]]
]

{ #category : #filtering }
MessageSet >> filterToCurrentAuthor [
	"Filter down only to messages with my initials as most recent author"
	self filterFrom:
		[:aClass :aSelector | | aMethod aTimeStamp |
			(aClass notNil and: [aSelector notNil]) and:			
				[aMethod := aClass compiledMethodAt: aSelector ifAbsent: [nil].
				aMethod notNil and:
					[(aTimeStamp := aMethod timeStamp) notNil and:
						[aTimeStamp beginsWith: Utilities authorInitials]]]]
]

{ #category : #filtering }
MessageSet >> filterToCurrentChangeSet [
	"Filter the receiver's list down to only those items in the current change set"

	self filterFrom:
		[:aClass :aSelector |
			(aClass notNil and: [aSelector notNil]) and:
				[(ChangeSet current atSelector: aSelector class: aClass) ~~ #none]]
]

{ #category : #filtering }
MessageSet >> filterToImplementorsOf [
	"Filter the receiver's list down to only those items with a given selector"

	| aFragment inputWithBlanksTrimmed |

	aFragment := self request: 'type selector:' initialAnswer: ''.
	aFragment  isEmptyOrNil ifTrue: [^ self].
	inputWithBlanksTrimmed := aFragment withBlanksTrimmed.
	Symbol hasInterned: inputWithBlanksTrimmed ifTrue:
		[:aSymbol | 
			self filterFrom:
				[:aClass :aSelector |
					aSelector == aSymbol]]
]

{ #category : #filtering }
MessageSet >> filterToMatchingClassesNames [

	| reply |

	reply := UIManager default
					request: 'Type the string to match'
					initialAnswer: 'ClassName*'
					centerAt: Sensor cursorPoint.
	reply isEmptyOrNil ifTrue: [^ self].

	self filterFrom: [:aClass :aSelector | reply match: aClass name asString]

]

{ #category : #filtering }
MessageSet >> filterToMessagesInChangesFile [
	"Filter down only to messages whose source code risides in the Changes file.  This allows one to ignore long-standing methods that live in the .sources file."

	
	self filterFrom:
		[:aClass :aSelector | | cm |
			aClass notNil and: [aSelector notNil and:
				[(self class isPseudoSelector: aSelector) not and:
					[(cm := aClass compiledMethodAt: aSelector ifAbsent: [nil]) notNil and:
					[cm fileIndex ~= 1]]]]]
]

{ #category : #filtering }
MessageSet >> filterToMessagesInSourcesFile [
	"Filter down only to messages whose source code resides in the .sources file."

	
	self filterFrom: [:aClass :aSelector | | cm |
		(aClass notNil and: [aSelector notNil]) and:
			[(self class isPseudoSelector: aSelector) not and:
				[(cm := aClass compiledMethodAt: aSelector ifAbsent: [nil]) notNil and:
					[cm fileIndex = 1]]]]
]

{ #category : #filtering }
MessageSet >> filterToMessagesThat [
	"Allow the user to type in a block which will be"

	| reply |
	reply := UIManager default
		multiLineRequest: 'Type your block here'
		centerAt: Sensor cursorPoint
		initialAnswer: '[:aClass :aSelector |
	
	]'
		answerHeight: 200.
	reply isEmptyOrNil ifTrue: [^ self].
	self filterFrom: (Compiler evaluate: reply)

]

{ #category : #filtering }
MessageSet >> filterToMessagesWithHardenedClasses [
	"Filter the receiver's list down to only those items representing methods of hardened classes, as opposed to uniclasses"

	self filterFrom:
		[:aClass :aSelector |
			(aClass notNil and: [aSelector notNil]) and:
				[aClass isUniClass not]]
]

{ #category : #filtering }
MessageSet >> filterToMessagesWithPriorVersions [
	"Filter down only to messages which have at least one prior version"

	self filterFrom:
		[:aClass :aSelector |
			(aClass notNil and: [aSelector notNil]) and:
				[(self class isPseudoSelector: aSelector) not and:
					[(VersionsBrowser versionCountForSelector: aSelector class: aClass) > 1]]]
]

{ #category : #filtering }
MessageSet >> filterToMessagesWithoutPriorVersions [
	"Filter down only to messages which have no prior version stored"

	self filterFrom:
		[:aClass :aSelector |
			(aClass notNil and: [aSelector notNil]) and:
				[(self class isPseudoSelector: aSelector) not and:
					[(VersionsBrowser versionCountForSelector: aSelector class: aClass) <= 1]]]
]

{ #category : #filtering }
MessageSet >> filterToNotAnyChangeSet [
	"Filter down only to messages present in NO change set"

	self filterFrom:
		[:aClass :aSelector |
			(ChangesOrganizer doesAnyChangeSetHaveClass: aClass andSelector: aSelector) not]

]

{ #category : #filtering }
MessageSet >> filterToNotCurrentAuthor [
	"Filter down only to messages not stamped with my initials"
	self filterFrom:
		[:aClass :aSelector | | aTimeStamp aMethod |
			(aClass notNil and: [aSelector notNil]) and:			
				[aMethod := aClass compiledMethodAt: aSelector ifAbsent: [nil].
				aMethod notNil and:
					[(aTimeStamp := aMethod timeStamp) isNil or:
						[(aTimeStamp beginsWith: Utilities authorInitials) not]]]]
]

{ #category : #filtering }
MessageSet >> filterToNotCurrentChangeSet [
	"Filter the receiver's list down to only those items not in the current change set"

	self filterFrom:
		[:aClass :aSelector |
			(aClass notNil and: [aSelector notNil]) and:
				[(ChangeSet current atSelector: aSelector class: aClass) == #none]]
]

{ #category : #filtering }
MessageSet >> filterToNotImplementorsOf [
	"Filter the receiver's list down to only those items whose selector is NOT one solicited from the user."

	| aFragment inputWithBlanksTrimmed |

	aFragment := self request: 'type selector: ' initialAnswer: ''.
	aFragment  isEmptyOrNil ifTrue: [^ self].
	inputWithBlanksTrimmed := aFragment withBlanksTrimmed.
	Symbol hasInterned: inputWithBlanksTrimmed ifTrue:
		[:aSymbol | 
			self filterFrom:
				[:aClass :aSelector |
					aSelector ~~ aSymbol]]
]

{ #category : #filtering }
MessageSet >> filterToNotPackage [
	self requestPackageSelection ifNotNil:
		[ : selectedPackage | self filterFrom:
			[ : aClass : aSelector | (selectedPackage
				includesMethod: aSelector
				ofClass: aClass) not ] ]
]

{ #category : #filtering }
MessageSet >> filterToNotSendersOf [
	"Filter the receiver's list down to only those items which do not send a given selector"

	| aFragment inputWithBlanksTrimmed |

	aFragment := self request: 'type selector:' initialAnswer: ''.
	aFragment  isEmptyOrNil ifTrue: [^ self].
	inputWithBlanksTrimmed := aFragment withBlanksTrimmed.
	Symbol hasInterned: inputWithBlanksTrimmed ifTrue:
		[:aSymbol | 
			self filterFrom:
				[:aClass :aSelector | | aMethod |
					(aMethod := aClass compiledMethodAt: aSelector) isNil or:
						[(aMethod hasLiteral: aSymbol) not]]]
]

{ #category : #filtering }
MessageSet >> filterToPackage [
	self requestPackageSelection ifNotNil:
		[ : selectedPackage | self filterFrom:
			[ : aClass : aSelector | selectedPackage
				includesMethod: aSelector
				ofClass: aClass ] ]
]

{ #category : #filtering }
MessageSet >> filterToSendersOf [
	"Filter the receiver's list down to only those items which send a given selector"

	| aFragment inputWithBlanksTrimmed |

	aFragment := self request: 'type selector:' initialAnswer: ''.
	aFragment  isEmptyOrNil ifTrue: [^ self].
	inputWithBlanksTrimmed := aFragment withBlanksTrimmed.
	Symbol hasInterned: inputWithBlanksTrimmed ifTrue:
		[:aSymbol | 
			self filterFrom:
				[:aClass :aSelector | | aMethod |
					(aMethod := aClass compiledMethodAt: aSelector) notNil and:
						[aMethod hasLiteral: aSymbol]]]


]

{ #category : #filtering }
MessageSet >> filterToUncommentedMethods [
	"Filter the receiver's list down to only those items which lack comments"

	self filterFrom:
		[:aClass :aSelector |
			(aClass includesSelector: aSelector) and:
						[(aClass firstPrecodeCommentFor: aSelector) isEmptyOrNil]]
]

{ #category : #filtering }
MessageSet >> filterToUnsentMessages [
	"Filter the receiver's list down to only those items which have no  
	senders"
	self
		filterFrom: [:aClass :aSelector | (self systemNavigation allCallsOn: aSelector) isEmpty]
]

{ #category : #'message list' }
MessageSet >> formattedLabel: aStringOrCodeReference [

	self class parse: aStringOrCodeReference toClassAndSelector: [:cls :sel |
		^ self
			formattedLabel: aStringOrCodeReference asString
			forSelector: sel
			inClass: cls]
]

{ #category : #'message list' }
MessageSet >> growable [
	"Answer whether the receiver is capable of growing/shrinking dynamically"

	^ growable ~~ false
]

{ #category : #'message list' }
MessageSet >> growable: aBoolean [
	"Give or take away the growable trait; when a message set is growable, methods submitted within it will be added to its message list"

	growable := aBoolean
]

{ #category : #'message list' }
MessageSet >> hasMessageSelected [
	^ messageListIndex ~= 0.
]

{ #category : #indenting }
MessageSet >> indentionPrefixOfSize: levelInteger [

	| answer |
	answer := String new: levelInteger * self indentionSize.
	answer atAllPut: $ . "space"
	^answer

]

{ #category : #indenting }
MessageSet >> indentionSize [

	^2  "that is, 2 spaces.."

]

{ #category : #indenting }
MessageSet >> indentionsIn: aString [

	aString
		withIndexDo: 
			[ :eachChar :index | 
			eachChar = $  "space" ifFalse: [ ^(index-1) / self indentionSize ] ].
	^0

]

{ #category : #'initialize-release' }
MessageSet >> initialize [
	super initialize.
	messageList := OrderedCollection new.
]

{ #category : #private }
MessageSet >> initializeMessageList: anArray [
	"Initialize my messageList from the given list of MethodReference or string objects.  NB: special handling for uniclasses.
	 Do /not/ replace the elements of anArray if they are already MethodReferences, so as to allow users to construct richer systems, such as differencers between existing and edited versions of code."
	messageList := OrderedCollection new.
	anArray do:
		[:each | each isMethodReference
			ifTrue: [messageList addLast: each]
			ifFalse:
				[ MessageSet
					parse: each 
					toClassAndSelector:
						[ : class : sel | class ifNotNil: [ messageList addLast: (MethodReference class: class selector: sel) ] ] ] ].
	"Unify labels if wanted."
	self class useUnifiedMessageLabels ifTrue:
		[ messageList withIndexDo: 
			[ : each : index | | cls |
			cls := each actualClass.
			each stringVersion:
				(self indentionPrefixOfSize: (self indentionsIn: each stringVersion))
				, (cls
					ifNil: [each asString] 
					ifNotNil: 
						[cls isUniClass
							ifTrue: [cls typicalInstanceName, ' ', each selector]
							ifFalse:
								[ cls name , ' ' , each selector , ' {'
								, ((cls organization categoryOfElement: each selector) ifNil: ['']) , '}'
								, ' {', cls category, '}' ] ]) ] ].
	messageListIndex := messageList isEmpty ifTrue: [0] ifFalse: [1].
	contents := String empty
]

{ #category : #'message list' }
MessageSet >> isClassDefinition: messageListItemOrSymbol [
	"Answer whether this item from the message list (or its extracted selector) indicates a
	class definition."
	^ messageListItemOrSymbol selector = #Definition
]

{ #category : #'message list' }
MessageSet >> isComment: messageListItemOrSymbol [
	"Answer whether this item from the message list (or its extracted selector) indicates a
	class comment."
	^ messageListItemOrSymbol selector = #Comment
]

{ #category : #'message list' }
MessageSet >> isHierarchy: messageListItemOrSymbol [
	"Answer whether this item from the message list (or its extracted selector) indicates a
	class hierarchy."
	^ messageListItemOrSymbol selector = #Hierarchy
]

{ #category : #'message list' }
MessageSet >> lastMessageName [
	^ self messageList last selector.
]

{ #category : #'message list' }
MessageSet >> mainMessageListMenu: aMenu [
	"Answer the message-list menu"
	<messageListMenuShifted: false>
	aMenu addList: #(
			('what to show...'			offerWhatToShowMenu)
			('toggle break on entry'		toggleBreakOnEntry)
			-
			('browse full (b)' 			browseMethodFull)
			('browse hierarchy (h)'			browseClassHierarchy)
			('browse protocol (p)'			browseFullProtocol)
			-
			('fileOut'				fileOutMessage)
			('printOut'				printOutMessage)
			('copy selector (c)'		copySelector)
			('copy reference (C)'	copyReference)
			-
			('senders of... (n)'			browseSendersOfMessages)
			('implementors of... (m)'		browseMessages)
			('inheritance (i)'			methodHierarchy)
			('versions (v)'				browseVersions)
			-
			('references... (r)'			browseVariableReferences)
			('assignments... (a)'			browseVariableAssignments)
			('class refs (N)'			browseClassRefs)
			-
			('remove method (x)'			removeMessage)
			('explore method'			exploreMethod)
			('inspect method'			inspectMethod)).
	^ aMenu
]

{ #category : #'message list' }
MessageSet >> messageHelpAt: anIndex [
	"Show the first n lines of the sources code of the selected message."
	
	| reference |
	Preferences balloonHelpInMessageLists ifFalse: [^ nil].
	self messageList size < anIndex ifTrue: [^ nil].
	
	reference := self messageList at: anIndex.
	reference isValid ifFalse: [^ nil].
	(self isComment: reference) ifTrue: [^ self messageHelpForComment: reference].
	(self isClassDefinition: reference) ifTrue: [^ self messageHelpForClassDefinition: reference].
	(self isHierarchy: reference) ifTrue: [^ self messageHelpForClassHierarchy: reference].
	^ self messageHelpForMethod: reference compiledMethod
]

{ #category : #'message list' }
MessageSet >> messageHelpForClassDefinition: aMethodReference [
	"Answer the formatted help text for a class definition."
	^ aMethodReference setClassAndSelectorIn: [:class :sel | class definition]
]

{ #category : #'message list' }
MessageSet >> messageHelpForClassHierarchy: aMethodReference [
	"Answer the formatted help text for a class hierarchy."
	"Show the first n lines of the class hierarchy."
	| source |
	source := aMethodReference setClassAndSelectorIn: [:class :sel | class printHierarchy].
	^ self messageHelpTruncated: source asText
]

{ #category : #'message list' }
MessageSet >> messageHelpForComment: aMethodReference [
	"Answer the formatted help text for a class comment."
	"Show the first n lines of the class comment."
	| source |
	source := aMethodReference setClassAndSelectorIn: [:class :sel | class comment].
	^ self messageHelpTruncated: source asText
]

{ #category : #'message list' }
MessageSet >> messageIconAt: anIndex [

	Browser showMessageIcons
		ifFalse: [^ nil].

	^ ToolIcons iconNamed: (ToolIcons
		iconForClass: (self messageList at: anIndex) actualClass
		selector: (self messageList at: anIndex) selector)
]

{ #category : #'message list' }
MessageSet >> messageList [
	"Answer the current list of messages."

	^messageList
]

{ #category : #'message list' }
MessageSet >> messageListFormatted [

	^ messageListFormatted ifNil: [
		messageListFormatted := messageList collect: [:ea | self formattedLabel: ea]]
]

{ #category : #'message list' }
MessageSet >> messageListIndex [
	^messageListIndex ifNil: [0]
]

{ #category : #'message list' }
MessageSet >> messageListIndex: anInteger [ 
	"Set the index of the selected item to be anInteger."

	messageListIndex := anInteger.
	contents := 
		messageListIndex ~= 0
			ifTrue: [self selectedMessage]
			ifFalse: [''].
	self changed: #messageListIndex.	 "update my selection"
	self editSelection: #editMessage.
	self contentsChanged.
	(messageListIndex ~= 0 and: [ autoSelectString notNil and: [ self contents notEmpty ] ]) ifTrue: [ self changed: #autoSelect ].
	self decorateButtons

]

{ #category : #'message list' }
MessageSet >> messageListIndexOf: aString [
	^ (self messageList collect: [:each | each selector]) indexOf: aString.
]

{ #category : #'message list' }
MessageSet >> messageListMenu: aMenu shifted: shifted [ 
	"Answer the message-list menu"
	^ self menu: aMenu for: #(messageListMenu messageListMenuShifted:) shifted: shifted

]

{ #category : #'pluggable menus - hooks' }
MessageSet >> messageListMenuHook: aMenu shifted: aBoolean [
	<messageListMenu>
	^ self menuHook: aMenu named: #messageListMenu shifted: aBoolean.

]

{ #category : #'class list' }
MessageSet >> metaClassIndicated [
	"Answer the boolean flag that indicates whether
	this is a class method."

	^ self selectedClassOrMetaClass isMeta
]

{ #category : #'message functions' }
MessageSet >> methodCategoryChanged [
	self changed: #annotation
]

{ #category : #'user interface' }
MessageSet >> modelWakeUp [
	"A window with me as model has been activated."

	super modelWakeUp.
	(self canDiscardEdits and: [autoSelectString notNil]) ifTrue: [
		self codeTextMorph ifNotNil: [:tm |
			(tm hasProperty: #launched) ifFalse: [
				tm scrollSelectionIntoView.
				tm setProperty: #launched toValue: true] ] ]
]

{ #category : #'message list' }
MessageSet >> optionalButtonHeight [

	^ 15
]

{ #category : #'message functions' }
MessageSet >> reformulateList [
	"The receiver's messageList has been changed; rebuild it"
	super reformulateList.
	self
		 changed: #messageList ;
		 changed: #messageListIndex.
	self contentsChanged.
	autoSelectString ifNotNil: [ self changed: #autoSelect ]
]

{ #category : #'message functions' }
MessageSet >> removeMessage [
	"Remove the selected message from the system. 1/15/96 sw"
	| messageName confirmation |
	self hasMessageSelected
		ifFalse: [^ self].
	self okToChange
		ifFalse: [^ self].
	messageName := self selectedMessageName.
	confirmation := self systemNavigation  confirmRemovalOf: messageName on: self selectedClassOrMetaClass.
	confirmation = 3
		ifTrue: [^ self].
	self selectedClassOrMetaClass removeSelector: messageName.
	self deleteFromMessageList: self selection.
	self reformulateList.
	confirmation = 2
		ifTrue: [self systemNavigation browseAllCallsOn: messageName]
]

{ #category : #'message functions' }
MessageSet >> removeMessageFromBrowser [
	"Remove the selected message from the browser."

	self hasMessageSelected ifFalse: [^ self].
	self deleteFromMessageList: self selection.
	self reformulateList.
	self adjustWindowTitleAfterFiltering

]

{ #category : #'morphic ui' }
MessageSet >> representsSameBrowseeAs: anotherModel [
	^ self hasUnacceptedEdits not
	and: [ messageList = anotherModel messageList ]
]

{ #category : #'user interface' }
MessageSet >> request: prompt initialAnswer: initialAnswer [

	^ UIManager default
		request: prompt
		initialAnswer: initialAnswer
]

{ #category : #private }
MessageSet >> requestPackageSelection [
	| packages selectedIndex |
	packages := PackageOrganizer default packages sort:
		[ : a : b | a packageName <= b packageName ].
	selectedIndex := UIManager default
		chooseFrom: (packages collect: [ : each | each packageName ])
		lines: Array empty
		title: 'Select a package...'.
	^ packages at: selectedIndex ifAbsent: [ nil ]
]

{ #category : #'class list' }
MessageSet >> selectedClass [ 
	"Return the base class for the current selection.  1/17/96 sw fixed up so that it doesn't fall into a debugger in a msg browser that has no message selected"

	| aClass |
	^ (aClass := self selectedClassOrMetaClass) == nil
		ifTrue:
			[nil]
		ifFalse:
			[aClass theNonMetaClass]
]

{ #category : #'class list' }
MessageSet >> selectedClassName [
	"Answer the name of class of the currently selected message. Answer nil if no selection 
	exists."

	| cls |
	(cls := self selectedClass) ifNil: [^ nil].
	^ cls name
]

{ #category : #'class list' }
MessageSet >> selectedClassOrMetaClass [
	"Answer the currently selected class (or metaclass)."
	self hasMessageSelected ifFalse: [^nil].
	self setClassAndSelectorIn: [:c :s | ^c]
]

{ #category : #'message list' }
MessageSet >> selectedMessage [
	"Answer the source method for the currently selected message."

	
	self setClassAndSelectorIn: [:class :selector | | source | 
		class ifNil: [^ 'Class vanished'].
		selector first isUppercase ifTrue:
			[selector == #Comment ifTrue:
				[currentCompiledMethod := class organization commentRemoteStr.
				^ class comment].
			selector == #Definition ifTrue:
				[^ class definition].
			selector == #Hierarchy ifTrue: [^ class printHierarchy]].
		source := class sourceMethodAt: selector ifAbsent:
			[currentCompiledMethod := nil.
			^ 'Missing'].

		self showingDecompile ifTrue: [^ self decompiledSourceIntoContents].

		currentCompiledMethod := class compiledMethodAt: selector ifAbsent: [nil].
		self showingDocumentation ifTrue: [^ self commentContents].

	source := self sourceStringPrettifiedAndDiffed.
	^ source asText makeSelectorBoldIn: class]
]

{ #category : #'class list' }
MessageSet >> selectedMessageCategoryName [ 
	"Answer the name of the selected message category or nil."
	| cls |
	self hasMessageSelected ifFalse: [^ nil].
	cls := self selectedClassOrMetaClass.
	
	cls ifNil: [^ nil].
	
	^ cls organization categoryOfElement: self selectedMessageName
]

{ #category : #'message list' }
MessageSet >> selectedMessageName [
	"Answer the name of the currently selected message."
	"wod 6/16/1998: answer nil if none are selected."

	messageListIndex = 0 ifTrue: [^ nil].
	^ self setClassAndSelectorIn: [:class :selector | ^ selector]
]

{ #category : #private }
MessageSet >> selection [
	"Answer the item in the list that is currently selected, or nil if no selection is present"

	^ self messageList at: (self messageListIndex) ifAbsent: [nil]
]

{ #category : #private }
MessageSet >> setClassAndSelectorIn: csBlock [
	"Decode strings of the form <className> [class] <selectorName>."

	| sel |
	sel := self selection.
	^ sel isCodeReference
		ifTrue: [sel setClassAndSelectorIn: csBlock]
		ifFalse: [self class parse: sel toClassAndSelector: csBlock]
]

{ #category : #contents }
MessageSet >> setContentsToForceRefetch [
	"Set the receiver's contents such that on the next update the contents will be formulated afresh.  This is a critical and obscure difference between Browsers on the one hand and MessageSets on the other, and has over the years been the source of much confusion and much difficulty.  By centralizing the different handling here, we don't need so many idiosyncratic overrides in MessageSet any more"

	contents := ''
]

{ #category : #private }
MessageSet >> setFilteredList: newList [ 
	"Establish newList as the new list if appropriate, and adjust the window title accordingly; if the new list is of the same size as the old, warn and do nothing"
	
	| currentSelection |
	newList size = 0 ifTrue:
		[ self inform: 'Nothing would be left in the list if you did that'.
		^false ].
	newList size = messageList size ifTrue:
		[ self inform: 'That leaves the list unchanged'.
		^false ].
	
	messageListIndex > 0 ifTrue:
		[currentSelection := messageList at: messageListIndex].
	
	self
		 initializeMessageList: newList ;
		 adjustWindowTitleAfterFiltering.

	currentSelection ifNotNil:
		[messageListIndex := messageList indexOf: currentSelection ifAbsent: [1]].

	self
		changed: #messageList;
		changed: #messageListIndex.
	
	^true
]

{ #category : #'message list' }
MessageSet >> shiftedMessageListMenu: aMenu [
	"Fill aMenu with the items appropriate when the shift key is held down"
	<messageListMenuShifted: true>

	aMenu addStayUpItem.
	aMenu addList: #(
		('toggle diffing (D)'						toggleDiffing)
		('implementors of sent messages'			browseAllMessages)
		-
		('local senders of...'						browseLocalSendersOfMessages)
		('local implementors of...'				browseLocalImplementors)
		-
		('spawn sub-protocol'					spawnProtocol)
		('spawn full protocol'					spawnFullProtocol)
		-
		('sample instance'						makeSampleInstance)
		('inspect instances'						inspectInstances)
		('inspect subinstances'					inspectSubInstances)).

	self addExtraShiftedItemsTo: aMenu.
	aMenu addList: #(
		-
		('change category...'					changeCategory)).

	self canShowMultipleMessageCategories ifTrue: [aMenu addList:
		 #(('show category (C)'						showHomeCategory))].
	aMenu addList: #(
		-
		('change sets with this method'			findMethodInChangeSets)
		('revert to previous version'				revertToPreviousVersion)
		('remove from current change set'		removeFromCurrentChanges)
		('revert & remove from changes'		revertAndForget)
		('add to current change set'				adoptMessageInCurrentChangeset)
		('copy up or copy down...'				copyUpOrCopyDown)).
	^ aMenu

]

{ #category : #'message list' }
MessageSet >> sortByDate [
	"Sort the message-list by date of time-stamp"

	| assocs inOrder |
	assocs := messageList collect:
		[:aRef | | aDate aCompiledMethod |
			aDate := aRef methodSymbol == #Comment
				ifTrue:
					[aRef actualClass organization dateCommentLastSubmitted]
				ifFalse:
					[aCompiledMethod := aRef actualClass compiledMethodAt: aRef methodSymbol ifAbsent: [nil].
					aCompiledMethod ifNotNil: [aCompiledMethod dateMethodLastSubmitted]].
			aRef -> (aDate ifNil: [Date fromString: '01/01/1996'])].  "The dawn of Squeak history"
	inOrder := assocs asArray sort: [:a :b | a value < b value].

	messageList := inOrder collect: [:assoc | assoc key].
	self changed: #messageList
]

{ #category : #'initialize-release' }
MessageSet >> systemOrganizer: aSystemOrganizer [

	messageListIndex := 0.
	^ super systemOrganizer: aSystemOrganizer.
]

{ #category : #private }
MessageSet >> targetForContents: aString [
	"Answer the behavior into which the contents will be accepted."
	self setClassAndSelectorIn: [:c :os | ^ c].
	^ nil "fail safe for overriding implementations of setClassAndSelectorIn:"
]

{ #category : #copying }
MessageSet >> veryDeepInner: deepCopier [
	super veryDeepInner: deepCopier.
	messageList := messageList veryDeepCopyWith: deepCopier.
	editSelection := editSelection veryDeepCopyWith: deepCopier.
]
