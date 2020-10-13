"
A TimeProfileBrowser is a browser visualizing the runtime profile of an executed Smalltalk block.  It is useful for finding performance bottlenecks in code. When optimizing code it can
be hard to know what methods actually constitute the bulk of the execution time. Is it a few
methods that take very long time to execute or is it perhaps a single method that gets executed a thousand times?

The block is first spied on using a MessageTally instance (which has even more funtionality than used by the TimeProfileBrowser) which samples the block during it's execution and collects the amount of time approximately spent in the methods executed. Then the methods are shown in the browser with their relative execution time in percent.

Example:
TimeProfileBrowser onBlock: [20 timesRepeat:  [Transcript show: 100 factorial printString]]

"
Class {
	#name : #TimeProfileBrowser,
	#superclass : #MessageSet,
	#instVars : [
		'block',
		'tally',
		'methodReferences'
	],
	#classVars : [
		'TextMenu'
	],
	#category : #'Tools-Debugger'
}

{ #category : #'instance creation' }
TimeProfileBrowser class >> onBlock: block [
	"Open a profile browser on the given block, thereby running the block and 
	 collecting the message tally."
	"TimeProfileBrowser onBlock: [20 timesRepeat: 
			[Transcript show: 100 factorial printString]]"

	| inst result |
	inst := self new.
	result := inst runBlock: block.
	self open: inst name: 'Time Profile'.
	^ result
]

{ #category : #utilities }
TimeProfileBrowser class >> parse: aString toClassAndSelector: csBlock [
	"Try to create a MethodReference from a line returned by MessageTally. Set both class and selector to nil if the string doesn't have the given format."

	| stream className class selector |
	stream := aString readStream.
	"Skip percentages and timing data."
	stream
		skipTo: $};
		skipSeparators.
	(stream peekFor: $[) ifTrue: [ "Skip block markers."
		stream upToAnyOf: CharacterSet separators ].
	className := stream upToAnyOf: '(>'.

	stream atEnd ifTrue: [ ^ csBlock value: nil value: nil ].
	stream last == $( ifTrue: [ "Method is defined in a super class"
		className := stream upTo: $).
		(stream peekFor: $>) ifFalse: [ ^ csBlock value: nil value: nil ] ].
	(stream peekFor: $>) ifFalse: [ ^ csBlock value: nil value: nil ].
	selector := stream upToEnd.
	
	self flag: #environments. "missing information about the class environment"
	(class := Smalltalk classNamed: className) ifNil: [^ csBlock value: nil value: nil].
	(selector := Symbol lookup: selector) ifNil: [^ csBlock value: nil value: nil].
	^ csBlock value: class value: selector
]

{ #category : #'instance creation' }
TimeProfileBrowser class >> spyOn: block [
	"Open a profile browser on the given block, thereby running the block and 
	 collecting the message tally."
	"TimeProfileBrowser spyOn:  [20 timesRepeat: 
			[Transcript show: 100 factorial printString]]"

	^self onBlock: block
]

{ #category : #'instance creation' }
TimeProfileBrowser class >> spyOnProcess: aProcess forMilliseconds: msecDuration [ 
	"Run aProcess for msecDuration milliseconds, then open a TimeProfileBrowser on the results."

	"| p |  
	p := [100000 timesRepeat: [3.14159 printString]] fork.  
	(Delay forMilliseconds: 100) wait.  
	TimeProfileBrowser spyOnProcess: p forMilliseconds: 1000"

	| inst |
	inst := self new.
	inst runProcess: aProcess forMilliseconds: msecDuration pollingEvery: MessageTally defaultPollPeriod.
	self open: inst name: (String streamContents: [ :s | s nextPutAll: 'Time Profile for '; print: msecDuration; nextPutAll: ' msec' ]).
	^ inst
]

{ #category : #'as yet unclassified' }
TimeProfileBrowser >> formattedLabel: aString forSelector: aSymbol inClass: aClass [

	^ aClass
		ifNil: [aString]
		ifNotNil: [super formattedLabel: aString forSelector: aSymbol inClass: aClass]
]

{ #category : #'message list' }
TimeProfileBrowser >> hasMessageSelected [

	^super hasMessageSelected and: [
		(self methodReferences at: self messageListIndex) notNil ]
]

{ #category : #private }
TimeProfileBrowser >> initializeMessageList: anArray [
	messageList := anArray.
	messageListIndex := 0.
	contents := ''
]

{ #category : #contents }
TimeProfileBrowser >> isModeStyleable [
	"Ensure that only methods are styled."

	^self selectedMessageName notNil and: [ super isModeStyleable ]
]

{ #category : #'message list' }
TimeProfileBrowser >> messageHelpAt: anIndex [
	"Show the first n lines of the sources code of the selected message."
	
	| reference |
	Preferences balloonHelpInMessageLists ifFalse: [^ nil].
	self messageList size < anIndex ifTrue: [^ nil].
	
	reference := (self methodReferences at: anIndex) ifNil: [ ^nil ].
	reference isValid ifFalse: [ ^nil ].
	^ self messageHelpForMethod: reference compiledMethod
]

{ #category : #'message list' }
TimeProfileBrowser >> messageIconAt: index [

	^nil
]

{ #category : #private }
TimeProfileBrowser >> messageListKey: aChar from: view [ 
	"Respond to a Command key. Cmd-D means re-run block."

	aChar == $d ifTrue: [ ^Cursor execute showWhile: block ].
	^super messageListKey: aChar from: view
]

{ #category : #private }
TimeProfileBrowser >> methodReferenceFrom: aString [

	^ self class parse: aString toClassAndSelector: [:class :selector |
		class ifNotNil: [MethodReference class: class selector: selector]]
]

{ #category : #accessing }
TimeProfileBrowser >> methodReferences [

	^methodReferences ifNil: [
		methodReferences := messageList collect: [ :each | self methodReferenceFrom: each ] ]

]

{ #category : #private }
TimeProfileBrowser >> runBlock: aBlock [
	^self runBlock: aBlock pollingEvery: MessageTally defaultPollPeriod
]

{ #category : #private }
TimeProfileBrowser >> runBlock: aBlock pollingEvery: pollPeriod [ 
	| list result |
	block := MessageSend 
				receiver: self
				selector: #runBlock:pollingEvery:
				arguments: { 
						aBlock.
						pollPeriod}.	"so we can re-run it"
	tally := MessageTally new.
	tally
		reportOtherProcesses: false;
		maxClassNameSize: 1000;
		maxClassPlusSelectorSize: 1000;
		maxTabs: 100.
	result := tally spyEvery: pollPeriod on: aBlock.
	list := OrderedCollection withAll: (String streamContents: [ :s | tally report: s]) lines.
	self initializeMessageList: list.
	self changed: #messageList.
	self changed: #messageListIndex.
	^result
]

{ #category : #private }
TimeProfileBrowser >> runProcess: aProcess forMilliseconds: msecDuration pollingEvery: pollPeriod [ 
	| list result |
	block := MessageSend 
				receiver: self
				selector: #runProcess:forMilliseconds:pollingEvery: 
				arguments: { 
						aProcess.
						msecDuration.
						pollPeriod}.	"so we can re-run it"
	tally := MessageTally new.
	tally
		reportOtherProcesses: false;
		maxClassNameSize: 1000;
		maxClassPlusSelectorSize: 1000;
		maxTabs: 100.
	result := tally 
				spyEvery: pollPeriod
				onProcess: aProcess
				forMilliseconds: msecDuration.
	list := OrderedCollection withAll: (String streamContents: [ :s | tally report: s]) lines.
	self initializeMessageList: list.
	self changed: #messageList.
	self changed: #messageListIndex.
	^result
]

{ #category : #'message list' }
TimeProfileBrowser >> selectedMessage [
	"Answer the source method for the currently selected message."

	self setClassAndSelectorIn: [ :class :selector |
		| source | 
		source := (class == UndefinedObject and: [ selector == #DoIt ])
			ifTrue: [ 'DoIt', String cr, String cr, block arguments first decompile decompileString ]
			ifFalse: [ class sourceMethodAt: selector ifAbsent: [ ^'Missing' ] ].
		SystemBrowser browseWithPrettyPrint ifTrue: [
			source := class prettyPrinterClass 
				format: source
				in: class
				notifying: nil
				decorated: false ].
		^source asText makeSelectorBoldIn: class ].
	^''
]

{ #category : #private }
TimeProfileBrowser >> setClassAndSelectorIn: csBlock [
	"Evaluate csBlock with the selected methodReference, or return nil if there's nothing selected."

	^((self methodReferences at: self messageListIndex) ifNil: [ ^nil ])
		setClassAndSelectorIn: csBlock
]

{ #category : #accessing }
TimeProfileBrowser >> tally [
	"Answer the receiver's 'tally'."

	^tally
]

{ #category : #accessing }
TimeProfileBrowser >> tally: anObject [
	"Set the receiver's instance variable 'tally' to be anObject."

	tally := anObject
]
