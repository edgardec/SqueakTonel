Class {
	#name : #DebuggerTestsToolSet,
	#superclass : #StandardToolSet,
	#instVars : [
		'data'
	],
	#category : #'ToolsTests-Debugger'
}

{ #category : #debugging }
DebuggerTestsToolSet >> debugProcess: aProcess context: aContext label: aString contents: contents fullView: aBool [

	(data at: #debuggedProcesses ifAbsentPut: [OrderedCollection new])
		add: aProcess.
		
	aProcess suspend.
]

{ #category : #'error handling' }
DebuggerTestsToolSet >> doesNotUnderstand: aMessage [

	aMessage numArgs = 0
		ifTrue: [^ data at: aMessage selector ifAbsent: [{}]].
	
	(self class respondsTo: aMessage selector)
		ifTrue: [^ aMessage sendTo: self class].
	
	^ super doesNotUnderstand: aMessage
]

{ #category : #'debugging - handlers' }
DebuggerTestsToolSet >> handleError: anError [

	(data at: #handledErrors ifAbsentPut: [OrderedCollection new])
		add: anError.
		
	Processor activeProcess suspend.
]

{ #category : #'debugging - handlers' }
DebuggerTestsToolSet >> handleUserInterruptRequest: aString [

	(data at: #handledUserInterruptRequests ifAbsentPut: [OrderedCollection new])
		add: aString.
]

{ #category : #'debugging - handlers' }
DebuggerTestsToolSet >> handleWarning: aWarning [

	(data at: #handledWarnings ifAbsentPut: [OrderedCollection new])
		add: aWarning.
		
	Processor activeProcess suspend.
]

{ #category : #'initialize-release' }
DebuggerTestsToolSet >> initialize [

	super initialize.
	data := Dictionary new.
]
