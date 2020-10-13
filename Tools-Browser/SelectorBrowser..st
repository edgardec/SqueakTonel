"
A SelectorBrowser is more commonly referred to as the method finder; you can enter message names or more interestingly,  example inputs and results to have the system try to find plausible methods that would satisfy the parameters. See SelectorBrowser>>#byExample for much more detail.
"
Class {
	#name : #SelectorBrowser,
	#superclass : #StringHolder,
	#instVars : [
		'selectorIndex',
		'selectorList',
		'classListIndex',
		'classList'
	],
	#category : #'Tools-Browser'
}

{ #category : #'instance creation' }
SelectorBrowser class >> prototypicalToolWindow [
	"Answer an example of myself seen in a tool window, for the benefit of parts-launching tools"

	| aWindow |
	aWindow := ToolBuilder build: self new.
	aWindow setLabel: 'Selector Browser'.
	aWindow applyModelExtent.
	^ aWindow
]

{ #category : #toolbuilder }
SelectorBrowser >> buildClassListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #classList; 
		getIndex: #classListIndex; 
		setIndex: #classListIndex:; 
		keyPress: #arrowKey:from:.
	^listSpec

]

{ #category : #toolbuilder }
SelectorBrowser >> buildEditViewWith: builder [
	| textSpec |
	textSpec := builder pluggableInputFieldSpec new.
	textSpec 
		model: self;
		getText: #contents; 
		setText: #contents:notifying:; 
		selection: #contentsSelection; 
		menu: #codePaneMenu:shifted:.
	^textSpec
]

{ #category : #toolbuilder }
SelectorBrowser >> buildExamplePaneWith: builder [
	| textSpec |
	textSpec := builder pluggableTextSpec new.
	textSpec 
		model: self;
		getText: #byExample; 
		setText: #byExample:; 
		selection: #contentsSelection; 
		menu: #codePaneMenu:shifted:.
	^textSpec
]

{ #category : #toolbuilder }
SelectorBrowser >> buildMessageListWith: builder [
	| listSpec |
	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #messageList; 
		getIndex: #messageListIndex; 
		setIndex: #messageListIndex:; 
		menu: #selectorMenu:; 
		keyPress: #messageListKey:from:.
	^listSpec

]

{ #category : #toolbuilder }
SelectorBrowser >> buildWith: builder [
	"Create a Browser that lets you type part of a selector, shows a list of selectors, shows the classes of the one you chose, and spawns a full browser on it.  Answer the window
	SelectorBrowser new open "
	| windowSpec |
	selectorIndex := classListIndex := 0.
	windowSpec := 	self buildWindowWith: builder specs: {
		(0@0 corner: 0.5@0.14) -> [self buildEditViewWith: builder].
		(0@0.14 corner: 0.5@0.6) -> [self buildMessageListWith: builder].
		(0.5@0 corner: 1@0.6) -> [self buildClassListWith: builder].
		(0@0.6 corner: 1@1) -> [self buildExamplePaneWith: builder].
	}.
	^builder build: windowSpec
]

{ #category : #'example pane' }
SelectorBrowser >> byExample [
	"The comment in the bottom pane"

	false ifTrue: [MethodFinder methodFor: #( (4 3) 7  (0 5) 5  (5 5) 10)].
		"to keep the method methodFor: from being removed from the system"

	^ 'Type a fragment of a selector in the top pane.  Accept it.

Or, use an example to find a method in the system.  Type receiver, args, and answer in the top pane with periods between the items.  3. 4. 7

Or, in this pane, use examples to find a method in the system.  Select the line of code and choose "print it".  

	MethodFinder methodFor: #( (4 3) 7  (0 5) 5  (5 5) 10).
This will discover (data1 + data2).

You supply inputs and answers and the system will find the method.  Each inner array is a list of inputs.  It contains the receiver and zero or more arguments.  For Booleans and any computed arguments, use brace notation.

	MethodFinder methodFor: { {1. 3}. true.  {20. 10}. false}.
This will discover the expressions (data1 < data2), (data2 > data1), and many others.

	MethodFinder methodFor: { {''29 Apr 1999'' asDate}. ''Thursday''.  
		{''30 Apr 1999'' asDate}. ''Friday'' }.
This will discover the expression (data1 weekday)

Receiver and arguments do not have to be in the right order.
See MethodFinder.verify for more examples.'
]

{ #category : #'example pane' }
SelectorBrowser >> byExample: newText [
	"Don't save it"
	^ true
]

{ #category : #'class list' }
SelectorBrowser >> classList [
	^ classList ifNil: [#()]
]

{ #category : #'class list' }
SelectorBrowser >> classListIndex [
	^ classListIndex
]

{ #category : #'class list' }
SelectorBrowser >> classListIndex: anInteger [

	classListIndex := anInteger.
	classListIndex > 0 ifTrue:
		[self changed: #startNewBrowser. "MVC view will terminate control to prepare for new browser"
		ToolSet browse: self selectedClass selector: self selectedMessageName.
		"classListIndex := 0"]

]

{ #category : #'class list' }
SelectorBrowser >> classListSelectorTitle [
	^ 'Class List Menu'
]

{ #category : #'example pane' }
SelectorBrowser >> contents: aString notifying: aController [
	"Take what the user typed and find all selectors containing it"

	| tokens |
	contents := aString.
	classList := #().  classListIndex := 0.
	selectorIndex := 0.
	tokens := contents asString findTokens: ' .'.
	selectorList := Cursor wait showWhile: [
		tokens size = 1 
			ifTrue: [(Symbol selectorsContaining: contents asString) asArray
				sort: [:x :y | x asLowercase <= y asLowercase]]
			ifFalse: [self quickList]].	"find selectors from a single example of data"
	self changed: #messageList.
	self changed: #classList.
	^ true
]

{ #category : #'user interface' }
SelectorBrowser >> defaultWindowColor [
	^ (Color r: 0.45 g: 0.9 b: 0.9)
]

{ #category : #'selector functions' }
SelectorBrowser >> implementors [
	| aSelector |
	(aSelector := self selectedMessageName) ifNotNil:
		[self systemNavigation browseAllImplementorsOf: aSelector]
]

{ #category : #'message list' }
SelectorBrowser >> initialExtent [

	^ 350@250

]

{ #category : #'user interface' }
SelectorBrowser >> labelString [

	^ 'Selector Browser' translated
]

{ #category : #'selector finding' }
SelectorBrowser >> listFromResult: resultOC [
	"ResultOC is of the form #('(data1 op data2)' '(...)'). Answer a sorted array."

	(resultOC first beginsWith: 'no single method') ifTrue: [^ #()].
	^ resultOC sorted: [:a :b | 
		(a copyFrom: 6 to: a size) < (b copyFrom: 6 to: b size)].


]

{ #category : #'selector list' }
SelectorBrowser >> mainSelectorMenu: aMenu [

	<selectorMenu>
	^ aMenu addList: #(
			('senders (n)'					senders)
			('implementors (m)'				implementors)
			('copy selector to clipboard'	copyName));
		yourself

]

{ #category : #'message list' }
SelectorBrowser >> markMatchingClasses [
	"If an example is used, mark classes matching the example instance with an asterisk."

	| unmarkedClassList firstPartOfSelector receiverString receiver |

	self flag: #mref.	"allows for old-fashioned style"

	"Only 'example' queries can be marked."
	(contents asString includes: $.) ifFalse: [^ self].

	unmarkedClassList := classList copy.

	"Get the receiver object of the selected statement in the message list."
	firstPartOfSelector := (Scanner new scanTokens: (selectorList at: selectorIndex)) second.
	receiverString := (ReadStream on: (selectorList at: selectorIndex))
						upToAll: firstPartOfSelector.
	receiver := Compiler evaluate: receiverString.

	unmarkedClassList do: [ :classAndMethod | | class |
		(classAndMethod isKindOf: MethodReference) ifTrue: [
			(receiver isKindOf: classAndMethod actualClass) ifTrue: [
				classAndMethod stringVersion: '*', classAndMethod stringVersionDefault.
			]
		] ifFalse: [
			class := Compiler evaluate:
					((ReadStream on: classAndMethod) upToAll: firstPartOfSelector).
			(receiver isKindOf: class) ifTrue: [
				classList add: '*', classAndMethod.
				classList remove: classAndMethod
			]
		].
	].

]

{ #category : #'message list' }
SelectorBrowser >> messageList [
	"Find all the selectors containing what the user typed in."

	^ selectorList ifNil: [#()]
]

{ #category : #'message list' }
SelectorBrowser >> messageListIndex [
	"Answer the index of the selected message selector."

	^ selectorIndex
]

{ #category : #'message list' }
SelectorBrowser >> messageListIndex: anInteger [ 
	"Set the selected message selector to be the one indexed by anInteger. 
	Find all classes it is in."
	selectorIndex := anInteger.
	selectorIndex = 0
		ifTrue: [^ self].
	classList := self systemNavigation allImplementorsOf: self selectedMessageName.
	self markMatchingClasses.
	classListIndex := 0.
	self changed: #messageListIndex.
	"update my selection"
	self changed: #classList
]

{ #category : #'message list' }
SelectorBrowser >> messageListKey: aChar from: view [
	"Respond to a command key. Handle (m) and (n) here,
	else defer to the StringHolder behaviour."

	aChar == $m ifTrue: [^ self implementors].
	aChar == $n ifTrue: [^ self senders].
	super messageListKey: aChar from: view

]

{ #category : #toolbuilder }
SelectorBrowser >> open [
	"Create a Browser that lets you type part of a selector, shows a list of selectors,
	shows the classes of the one you chose, and spwns a full browser on it.
		SelectorBrowser new open
	"
	^ToolBuilder open: self
]

{ #category : #'selector finding' }
SelectorBrowser >> quickList [
	"Compute the selectors for the single example of receiver and args, in the very top pane" 

	| data result resultArray dataStrings mf dataObjects aa statements |
	data := contents asString withBlanksTrimmed.
	mf := MethodFinder new.
	data := mf cleanInputs: data.	"remove common mistakes"
	dataObjects := Compiler evaluate: '{', data, '}'. "#( data1 data2 result )"
	statements := (Compiler new parse: 'zort ' , data in: Object notifying: nil)
				body statements select: [:each | (each isKindOf: ReturnNode) not].
 	dataStrings := statements collect:
				[:node | String streamContents:
					[:strm | (node isMessage) ifTrue: [strm nextPut: $(].
					node shortPrintOn: strm.
					(node isMessage) ifTrue: [strm nextPut: $)].]].
	dataObjects size < 2 ifTrue: [self inform: 'If you are giving an example of receiver, \args, and result, please put periods between the parts.\Otherwise just type one selector fragment' withCRs. ^#()].
 	dataObjects := Array with: dataObjects allButLast with: dataObjects last. "#( (data1
  data2) result )" 
	result := mf load: dataObjects; findMessage.
	(result first beginsWith: 'no single method') ifFalse: [
		aa := self testObjects: dataObjects strings: dataStrings.
		dataObjects := aa second.  dataStrings := aa third].
	resultArray := self listFromResult: result. 
	resultArray isEmpty ifTrue: [self inform: result first].

	dataStrings size = (dataObjects first size + 1) ifTrue:
		[resultArray := resultArray collect: [:expression | | newExp |
		newExp := expression.
		dataObjects first withIndexDo: [:lit :i |
			newExp := newExp copyReplaceAll: 'data', i printString
							with: (dataStrings at: i)].
		newExp, ' --> ', dataStrings last]].

 	^ resultArray
]

{ #category : #'example pane' }
SelectorBrowser >> searchResult: anExternalSearchResult [

	self contents: ''.
	classList := #(). classListIndex := 0.
	selectorIndex := 0.
	selectorList := self listFromResult: anExternalSearchResult.
 	self changed: #messageList.
	self changed: #classList.
	self changed: #contents

]

{ #category : #'class list' }
SelectorBrowser >> selectedClass [
	"Answer the currently selected class."

	| pairString |

	self flag: #mref.	"allows for old-fashioned style"

	classListIndex = 0 ifTrue: [^nil].
	pairString := classList at: classListIndex.
	(pairString isKindOf: MethodReference) ifTrue: [
		^pairString actualClass
	].
	(pairString includes: $*) ifTrue: [pairString := pairString allButFirst].
	MessageSet 
		parse: pairString
		toClassAndSelector: [:cls :sel | ^ cls].
]

{ #category : #accessing }
SelectorBrowser >> selectedClassName [
	"Answer the name of the currently selected class."

	classListIndex = 0 ifTrue: [^nil].
	^ self selectedClass name
]

{ #category : #accessing }
SelectorBrowser >> selectedMessageName [
	"Answer the name of the currently selected message."

	| example tokens |
	selectorIndex = 0 ifTrue: [^nil].
	example := selectorList at: selectorIndex.
	tokens := Scanner new scanTokens: example.
	tokens size = 1 ifTrue: [^ tokens first].
	tokens first == #'^' ifTrue: [^ nil].
	(tokens second includes: $:) ifTrue: [^ example findSelector].
	Symbol hasInterned: tokens second ifTrue: [:aSymbol | ^ aSymbol].
	^ nil
]

{ #category : #'selector list' }
SelectorBrowser >> selectorList: anExternalList [

	self contents: ''.
	classList := #(). classListIndex := 0.
	selectorIndex := 0.
	selectorList := anExternalList.
	self changed: #messageList.
	self changed: #classList.
	self changed: #contents


]

{ #category : #'selector list' }
SelectorBrowser >> selectorMenu: aMenu [
	^ self menu: aMenu for: #(selectorMenu selectorMenuShifted:)

]

{ #category : #'selector list' }
SelectorBrowser >> selectorMenuTitle [
	^ self selectedMessageName ifNil: ['<no selection>']
]

{ #category : #'selector functions' }
SelectorBrowser >> senders [
	| aSelector |
	(aSelector := self selectedMessageName) ifNotNil:
		[self systemNavigation browseAllCallsOn: aSelector]
]

{ #category : #'selector finding' }
SelectorBrowser >> testObjects: dataObjects strings: dataStrings [
	| dataObjs dataStrs selectors classes didUnmodifiedAnswer |
	"Try to make substitutions in the user's inputs and search for the selector again.
1 no change to answer.
2 answer Array -> OrderedCollection.
2 answer Character -> String
4 answer Symbol or String of len 1 -> Character
	For each of these, try straight, and try converting args:
Character -> String
Symbol or String of len 1 -> Character
	Return array with result, dataObjects, dataStrings.  Don't ever do a find on the same set of data twice."

dataObjs := dataObjects.  dataStrs := dataStrings.
selectors := {#asString. #first. #asOrderedCollection}.
classes := {Character. String. Array}.
didUnmodifiedAnswer := false.
selectors withIndexDo: [:ansSel :ansInd | | ds do result answerMod | "Modify the answer object"
	answerMod := false.
	do := dataObjs copyTwoLevel.  ds := dataStrs copy.
	(dataObjs last isKindOf: (classes at: ansInd)) ifTrue: [
		((ansSel ~~ #first) or: [dataObjs last size = 1]) ifTrue: [
			do at: do size put: (do last perform: ansSel).	"asString"
			ds at: ds size put: ds last, ' ', ansSel.
			result := MethodFinder new load: do; findMessage.
			(result first beginsWith: 'no single method') ifFalse: [
				"found a selector!"
				^ Array with: result first with: do with: ds].	
			answerMod := true]].

	selectors allButLast withIndexDo: [:argSel :argInd | | ddo dds | "Modify an argument object"
			"for args, no reason to do Array -> OrderedCollection.  Identical protocol."
		didUnmodifiedAnswer not | answerMod ifTrue: [
		ddo := do copyTwoLevel.  dds := ds copy.
		dataObjs first withIndexDo: [:arg :ind |
			(arg isKindOf: (classes at: argInd))  ifTrue: [
				((argSel ~~ #first) or: [arg size = 1]) ifTrue: [
					ddo first at: ind put: ((ddo first at: ind) perform: argSel).	"asString"
					dds at: ind put: (dds at: ind), ' ', argSel.
					result := MethodFinder new load: ddo; findMessage.
					(result first beginsWith: 'no single method') ifFalse: [
						"found a selector!"
						^ Array with: result first with: ddo with: dds]	.	
					didUnmodifiedAnswer not & answerMod not ifTrue: [
						didUnmodifiedAnswer := true].
					]]]]].
	].
^ Array with: 'no single method does that function' with: dataObjs with: dataStrs
]
