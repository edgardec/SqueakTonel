"
A MessageTrace is a MessageSet allowing efficient sender/implementor message following.  With implementors indented below, and senders outdended above, message flow is succinctly expressed, hierarchically.

My autoSelectStrings and messageSelections are Arrays of Booleans, parallel to my messageList.  Each boolean indicates whether that message is selected.  Each autoSelectStrings indicates which string should be highlighted in the code for each method in my messageList.
"
Class {
	#name : #MessageTrace,
	#superclass : #MessageSet,
	#instVars : [
		'autoSelectStrings',
		'messageSelections',
		'anchorIndex',
		'defaultSelectString'
	],
	#category : #'Tools-Browser'
}

{ #category : #initializing }
MessageTrace class >> initialize [

	self setUpPreferencesPanel
]

{ #category : #initializing }
MessageTrace class >> setUpPreferencesPanel [
	Preferences
		addPreference: #traceMessages
		category: #browsing
		default: false
		balloonHelp: 'If true, browsing senders or implementors in a methods browser will add to the methods in that browser instead of opening a new browser.'

]

{ #category : #building }
MessageTrace >> addChildMessages: methodReferences autoSelectString: aString [ 
	| currentIndentionLevel addables selectables selectableString newAnchor |
	selectableString := aString keywords 
		ifEmpty: [ String empty ] 
		ifNotEmptyDo: [ : keywords |
			"we can probably do something more precise here; perhaps recombining the extracted keywords into a single selector? Then again all usages of this method seem to already enforce use of a selector"
			aString ].
	[ (messageListIndex between: 1 and: autoSelectStrings size) ]
		whileFalse: [ autoSelectStrings add: selectableString ].
	currentIndentionLevel := self currentIndentionLevel.
	"Don't add mulitple copies of the same method, if a method is already in the list we will merely select it."
	addables := methodReferences reject: [ : each | messageList includes: each ].
	addables do: 
		[ : each | 
		each stringVersion: (self indentionPrefixOfSize: currentIndentionLevel + 1) , each asStringOrText.
		messageList 
			add: each
			afterIndex: self messageListIndex.
		autoSelectStrings 
			add: nil
			afterIndex: self messageListIndex.
		messageSelections 
			add: false
			afterIndex: self messageListIndex ].
	selectables := 
		addables copy
			addAll: (methodReferences select: [ : each | messageList includes: each ]) ;
			yourself.
	self deselectAll.
	anchorIndex := nil.
	selectables do:
		[ : each |
		self
			messageAt: (newAnchor := messageList indexOf: each) 
			beSelected: true.
		anchorIndex ifNil: [ anchorIndex := newAnchor ] ].
	self changed: #messageList.
	"Select the first child method."
	self messageListIndex: 
		(selectables size > 0
			ifTrue: [ messageList indexOf: selectables last ]
			ifFalse: [ messageList ifEmpty: [ 0 ] ifNotEmpty: [ 1 ] ])
]

{ #category : #building }
MessageTrace >> addChildMethodsNamed: selectorSymbol [

	| methodsReferences |

	messageListIndex = 0 
		ifTrue:
			[ ^(PopUpMenu labels: ' OK ')
				startUpWithCaption: 'Please reselect a method.' ].
	(methodsReferences := self filteredSelectorsNamed: selectorSymbol) isEmpty
		ifTrue:
			[ ^(PopUpMenu labels: ' OK ')
				startUpWithCaption: 'There are no methods named ', selectorSymbol ]
		ifFalse:
			[ self
				addChildMessages: methodsReferences
				autoSelectString: selectorSymbol ]

]

{ #category : #'message list' }
MessageTrace >> addExtraShiftedItemsTo: aMenu [ 
	"The shifted selector-list menu is being built.  Add items specific to MessageTrace."
	super addExtraShiftedItemsTo: aMenu.
	aMenu addList: #(#('invert level selection (I)' #invertLevelSelection) )
]

{ #category : #building }
MessageTrace >> addParentMessages: methodReferences autoSelectString: aString [ 
	| currentIndentionLevel addables selectables |
	addables := methodReferences reject: [ : each | messageList includes: each ].
	"we may need to process aString here in a similar manner to that in #addChildMessages:autoSelectString:"
	selectables := addables copy
		addAll: (methodReferences select: [ : each | messageList includes: each ]) ;
		yourself.
	currentIndentionLevel := self currentIndentionLevel.
	(currentIndentionLevel = 0 and: [ addables notEmpty ]) ifTrue: 
		[ self indentEverything.
		currentIndentionLevel := 1 ].
	addables do: 
		[ : each | 
		each stringVersion: (self indentionPrefixOfSize: currentIndentionLevel - 1) , each asStringOrText.
		messageList 
			add: each
			afterIndex: self messageListIndex - 1.
		autoSelectStrings 
			add: aString
			afterIndex: self messageListIndex - 1.
		messageSelections 
			add: false
			afterIndex: self messageListIndex - 1 ].
	self deselectAll.
	selectables do:
		[ : each | | messageIndex |
		messageIndex := messageList indexOf: each.
		self
			messageAt: messageIndex 
			beSelected: true.
		autoSelectStrings
			at: messageIndex
			put: aString ].
	self changed: #messageList.
	anchorIndex := messageListIndex.
	selectables size > 0 ifTrue:
		[ self messageListIndex: (messageList indexOf: selectables first) ]
]

{ #category : #building }
MessageTrace >> addParentMethodsSending: selectorSymbol [

	| methodsList |
	(methodsList := self systemNavigation allCallsOn: selectorSymbol) isEmpty
		ifTrue:
			[ ^(PopUpMenu labels: ' OK ')
				startUpWithCaption: 'There are no methods that send ', selectorSymbol ]
		ifFalse:
			[ self
				addParentMessages: methodsList
				autoSelectString: selectorSymbol ]

]

{ #category : #building }
MessageTrace >> autoSelectString: aString [

	super autoSelectString: aString.
	autoSelectStrings := messageList collect: [ :each | aString ]

]

{ #category : #actions }
MessageTrace >> browseAllCallsOn: selectorSymbol [
	(self hasUnacceptedEdits or: [ Preferences traceMessages not ])
		ifTrue: [ super browseAllCallsOn: selectorSymbol ]
		ifFalse: [ self addParentMethodsSending: selectorSymbol ]
]

{ #category : #actions }
MessageTrace >> browseAllImplementorsOf: selectorSymbol [
	| selectorToBrowse |
	selectorToBrowse := self selection 
		ifNil: [ selectorSymbol ] 
		ifNotNil: [ self getImplementorNamed: selectorSymbol ].
	(self hasUnacceptedEdits or: [ Preferences traceMessages not ])
		ifTrue: [ super browseAllImplementorsOf: selectorToBrowse ]
		ifFalse: [ self addChildMethodsNamed: selectorToBrowse ]

]

{ #category : #'private initializing' }
MessageTrace >> buildMessageListWith: builder [
	| listSpec |
	listSpec := builder pluggableAlternateMultiSelectionListSpec new.
	listSpec 
		model: self ;
		list: #messageListFormatted ;
		getIndex: #messageListIndex ;
		setIndex: #toggleSelectionAt:shifted:controlled: ;
		icon: #messageIconAt:;
		helpItem: #messageHelpAt:; 
		menu: #messageListMenu:shifted: ; 
		getSelectionList: #isMessageSelectedAt: ;
		setSelectionList: #messageAt:beSelected: ;
		keyPress: #messageListKey:from:.
	SystemBrowser browseWithDragNDrop 
		ifTrue: [ listSpec dragItem: #dragFromMessageList: ].
	^ listSpec
]

{ #category : #menus }
MessageTrace >> copySelector [
	Clipboard clipboardText:
		(String streamContents:
			[ : stream | self selectedMessages
				do: [ : each | stream nextPutAll: each selector asString ]
				separatedBy: [ stream space ] ])
]

{ #category : #'private accessing' }
MessageTrace >> currentIndentionLevel [
	^ messageListIndex isZero ifFalse: [ self indentionLevelAt: messageListIndex ]
]

{ #category : #building }
MessageTrace >> deleteAllFromMessageList: aCollection [
	"Delete the given messages from the receiver's message list"

	| newAutoSelectStrings newMessageSelections newSize set |
	newSize := self messageList size - aCollection size.
	newAutoSelectStrings := OrderedCollection new: newSize.
	newMessageSelections := OrderedCollection new: newSize.
	set := aCollection asSet.
	self messageList withIndexDo: [:each :index |
		(set includes: each) ifFalse:
			[newAutoSelectStrings add: (autoSelectStrings at: index).
			newMessageSelections add: (messageSelections at: index)]].
	super deleteAllFromMessageList: aCollection.
	autoSelectStrings := newAutoSelectStrings.
	messageSelections := newMessageSelections.
	anchorIndex ifNotNil:
		[ anchorIndex := anchorIndex min: messageList size ]
]

{ #category : #building }
MessageTrace >> deleteFromMessageList: aMethodReference [
	"Delete the given message from the receiver's message list"

	| index |
	autoSelectStrings removeAt: (index := messageList indexOf: aMethodReference).
	messageSelections removeAt: index.
	super deleteFromMessageList: aMethodReference.
	anchorIndex ifNotNil:
		[ anchorIndex := anchorIndex min: messageList size ]

]

{ #category : #actions }
MessageTrace >> deselectAll [
	super deselectAll.
	1 to: messageSelections size do: [ :index | messageSelections at: index put: false ]

]

{ #category : #'private actions' }
MessageTrace >> deselectAllBetweenLastSelectionAnd: indexPosition [

	| lower higher |
	lower := messageListIndex min: indexPosition.
	higher := messageListIndex max: indexPosition.
	lower = 0 ifTrue: [ ^nil ].
	lower to: higher do:
		[ :index | messageSelections at: index put: false ]

]

{ #category : #filtering }
MessageTrace >> filterFrom: aBlock [ 
	"Filter the receiver's list down to only those items that satisfy aBlock, which takes a class an a selector as its arguments."
	| newList newAutoSelectStrings newMessageSelections oldList |
	oldList := Dictionary new.
	messageList do: [ : each | oldList at: each put: each ].
	newList := messageList class new.
	newAutoSelectStrings := autoSelectStrings class new.
	newMessageSelections := messageSelections class new.
	messageList withIndexDo:
		[ : each : index | (self class
			parse: each
			toClassAndSelector: aBlock) ifTrue:
				[ newList add: each.
				newAutoSelectStrings add: (autoSelectStrings at: index).
				newMessageSelections add: (messageSelections at: index) ] ].
	(self setFilteredList: newList) ifTrue:
		[ autoSelectStrings := newAutoSelectStrings.
		messageList do:
			[ : each | each stringVersion: (oldList at: each) asString ] ]
]

{ #category : #filtering }
MessageTrace >> filteredSelectorsNamed: selectorSymbol [

	^(SystemNavigation for: self environment) allImplementorsOf: selectorSymbol

]

{ #category : #'private accessing' }
MessageTrace >> getImplementorNamed: selectorSymbol [
	 | allPossibilities |
	allPossibilities := (((self selection compiledMethod messages 
		select: [ :eachSelector | eachSelector beginsWith: selectorSymbol ])
		copyWith: selectorSymbol)
		select: [ :each | (Symbol lookup: each) notNil ])
		asSet asOrderedCollection sort.
	(allPossibilities includes: selectorSymbol) ifTrue:
		[ allPossibilities addFirst: (allPossibilities remove: selectorSymbol) ].
	^allPossibilities size > 1
		ifTrue: 
			[ | selectionIndex |
			selectionIndex := (PopUpMenu labelArray: allPossibilities lines: #(1))
				startUpWithCaption: 
					'Browse implementors of
					which message?'.
			selectionIndex = 0 ifTrue: [ selectorSymbol ] ifFalse: [ allPossibilities at: selectionIndex ] ]
		ifFalse: [ allPossibilities isEmpty
			ifTrue: [ selectorSymbol ]
			ifFalse: [ allPossibilities first ] ]

]

{ #category : #indenting }
MessageTrace >> indentEverything [

	messageList do: [ :each | each stringVersion: (self indentionPrefixOfSize: 1), each asString ]

]

{ #category : #'private accessing' }
MessageTrace >> indentionLevelAt: msgListIndex [
	^ self indentionsIn: (messageList at: msgListIndex) asString
]

{ #category : #'private initializing' }
MessageTrace >> initialize [

	super initialize.
	messageSelections := OrderedCollection new.
	autoSelectStrings := OrderedCollection new

]

{ #category : #'private initializing' }
MessageTrace >> initializeMessageList: anArray [
	messageSelections := (Array new: anArray size withAll: false) asOrderedCollection.
	super initializeMessageList: anArray.
	self 
		messageAt: messageListIndex
		beSelected: true.
	"autoSelectStrings is initialized right after this method, in autoSelectString:"

]

{ #category : #actions }
MessageTrace >> invertLevelSelection [
	"The user wants to be able to quickly and easily assemble message-traces.  When browsing senders or implementors of a heavily overloaded selector, typically just one or two messages are relevant out of several.  In that situation, the user need merely select the range of relevant methods to arrive within two gestures of trimming the irrelevant methods:  Command+I (capital eye) to invert the selection within the local group followed by Command+d to remove that selection from the browser."
	| index currentLevel start |
	currentLevel := self currentIndentionLevel ifNil:
		[ | possibilities |
		possibilities := ((1 to: messageSelections size) select:
			[ : idx | messageSelections at: idx ]) collect:
			[ : eachSelectedIndex | self indentionLevelAt: eachSelectedIndex ].
		possibilities asSet size > 1
			ifTrue: [ ^ self ]
			ifFalse:
				[ possibilities ifEmpty: [ ^ self ].
				start := messageSelections indexOf: true.
				possibilities anyOne ] ].
	"First invert at messageListIndex then crawl up and down from there until a different level is reached, inverting as we go."
	messageListIndex > 0 ifTrue: [ start := messageListIndex ].
	self toggleMessageSelectionAt: start.
	index := start.
	[ index := index - 1.
	index > 0 and: [ (self indentionLevelAt: index) = currentLevel ] ] whileTrue: [ self toggleMessageSelectionAt: index ].
	index := start.
	[ index := index + 1.
	index <= messageList size and: [ (self indentionLevelAt: index) = currentLevel ] ] whileTrue: [ self toggleMessageSelectionAt: index ].
	self
		 messageListIndex: 0 ;
		 changed: #messageList
]

{ #category : #testing }
MessageTrace >> isMessageSelectedAt: anInteger [

	^messageSelections at: anInteger ifAbsent: [ false ]
]

{ #category : #actions }
MessageTrace >> messageAt: indexInteger beSelected: aBoolean [
	^ indexInteger isZero ifFalse:
		[ messageSelections
			at: indexInteger
			put: aBoolean ]
]

{ #category : #actions }
MessageTrace >> messageListIndex: anInteger [
	autoSelectStrings ifNotEmpty: 
		[ autoSelectString :=
			anInteger = 0
				ifTrue:
					[ defaultSelectString ifNotNil: [:default| self containingWindow setLabel: default].
					"clear the autoSelectString"
					'' ]
				ifFalse:
					[ messageListIndex := anInteger.  
					"setting the window label, below, can't wait for this.."
					self containingWindow setLabel: (self windowLabelAt: anInteger).
					"work out the string to ask the text view to pre-select. We should do better than this; after all the debugger does"
					(autoSelectStrings at: anInteger)] ].
	anInteger > 0 ifTrue:
		[ self
			messageAt: anInteger
			beSelected: true ].
	super messageListIndex: anInteger

]

{ #category : #'message list' }
MessageTrace >> messageListKey: aChar from: view [ 
	aChar == $I ifTrue: [ ^ self invertLevelSelection ].
	^ super messageListKey: aChar from: view
]

{ #category : #accessing }
MessageTrace >> noteSelectionIndex: anInteger for: aSymbol [
	aSymbol == #messageList
		ifTrue:
			[ messageListIndex := anInteger.
			self 
				messageAt: messageListIndex
				beSelected: true ].
	super
		noteSelectionIndex: anInteger
		for: aSymbol
]

{ #category : #'message list' }
MessageTrace >> removeFromCurrentChanges [
	"Tell the changes mgr to forget that the selected messages were changed."

	self selectedMessages do: [:each |
		each setClassAndSelectorIn: [:class :selector |
			ChangeSet current removeSelectorChanges: selector class: class]].
	self changed: #annotation
]

{ #category : #actions }
MessageTrace >> removeMessage [
	"Remove the selected messages from the system."
	self selectedMessages size = 0 ifTrue: [ ^self ].
	self selectedMessages size = 1 ifTrue: [ ^super removeMessage ].
	(self confirm: 'Are you certain you want to remove all of the selected methods from the image?') ifFalse: [ ^self ].
	self selectedMessages do:
		[ :each | 
		each actualClass removeSelector: each methodSymbol.
		self deleteFromMessageList: each ]
]

{ #category : #building }
MessageTrace >> removeMessageFromBrowser [
	| indexToSelect |
	"Try to keep the same selection index."
	indexToSelect := (messageSelections indexOf: true) max: 1.
	self deleteAllFromMessageList: self selectedMessages.
	self deselectAll.
	messageSelections ifNotEmpty:
		[ messageSelections 
			at: (indexToSelect min: messageSelections size)  "safety"
			put: true ].
	anchorIndex := indexToSelect min: messageSelections size.
	self 
		messageListIndex: anchorIndex ; 
		reformulateList
]

{ #category : #'private actions' }
MessageTrace >> selectAllBetweenAnchorAnd: indexPosition [

	| lower higher |
	self deselectAllBetweenLastSelectionAnd: indexPosition.
	anchorIndex ifNil: [ anchorIndex := indexPosition ].
	lower := anchorIndex min: indexPosition.
	higher := anchorIndex max: indexPosition.
	lower to: higher do:
		[ :index | messageSelections at: index put: true ]

]

{ #category : #'private actions' }
MessageTrace >> selectedMessages [

	| answer |
	answer := OrderedCollection new.
	messageSelections withIndexDo:
		[ :eachSelection :index |
		eachSelection ifTrue: [ answer add: (messageList at: index) ] ].
	^answer

]

{ #category : #'private actions' }
MessageTrace >> toggleMessageSelectionAt: anInteger [

	messageSelections 
		at: anInteger 
		put: (messageSelections at: anInteger) not

]

{ #category : #actions }
MessageTrace >> toggleSelectionAt: currentPosition [
	"Compatibility with MVC"

	^ self
		toggleSelectionAt: currentPosition
		shifted: false
		controlled: false
]

{ #category : #actions }
MessageTrace >> toggleSelectionAt: anInteger shifted: isShifted controlled: isMouseDragging [ 
	anInteger = 0 ifTrue: [ ^ nil ].
	(isMouseDragging not and: [anInteger = anchorIndex and: [ (messageSelections occurrencesOf: true) = 1 ]])
		ifTrue:
			[ self toggleMessageSelectionAt: anInteger.
			anchorIndex := nil.
			self messageListIndex: 0 ]
		ifFalse:
			[ self deselectAll.
			isShifted
				ifTrue: [ self selectAllBetweenAnchorAnd: anInteger ]
				ifFalse:
					[ self
						messageAt: anInteger
						beSelected: true.
					anchorIndex := anInteger ].
			self messageListIndex: anInteger ]
]

{ #category : #copying }
MessageTrace >> veryDeepInner: aDeepCopier [ 
	super veryDeepInner: aDeepCopier.
	autoSelectStrings := autoSelectStrings veryDeepCopyWith: aDeepCopier.
	messageSelections := messageSelections veryDeepCopyWith: aDeepCopier
]

{ #category : #'private accessing' }
MessageTrace >> windowLabelAt: anInteger [

	| str |
	defaultSelectString ifNil:
		[defaultSelectString := self containingWindow label].
	^(str := autoSelectStrings at: anInteger)
		ifNil:
			[ 'Implementors of ',
				(self class
					parse: self selection
					toClassAndSelector: [ :class :selector | selector ]) ]
		ifNotNil:
			[ 'Senders of ', str ]

]
