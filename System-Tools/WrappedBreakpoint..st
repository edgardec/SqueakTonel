"
I am a wrapper around an actual method that should be debugged.
Contrary to my siblings BreakPoint and BreakpointManager I do not need
to modify the original method nor its source but rather implant me in my
method's position.

I am based on OBBreakpoint from the OmniBrowser framework.

Instance Variables
	method:		<CompiledMethod>

method
	- actual method I wrap

"
Class {
	#name : #WrappedBreakpoint,
	#superclass : #ProtoObject,
	#instVars : [
		'method'
	],
	#category : #'System-Tools'
}

{ #category : #'instance creation' }
WrappedBreakpoint class >> on: aCompiledMethod [
	^ self basicNew initializeOn: aCompiledMethod
]

{ #category : #literals }
WrappedBreakpoint >> allLiteralsDo: aBlock [
	"This method is necessary to show the breakpoint-flag in the browser."
	
	aBlock value: #break.
	method allLiteralsDo: aBlock.
]

{ #category : #private }
WrappedBreakpoint >> doesNotUnderstand: aMessage [
	^ method 
		perform: aMessage selector
		withArguments: aMessage arguments
]

{ #category : #private }
WrappedBreakpoint >> flushCache [
	method selector flushCache
]

{ #category : #public }
WrappedBreakpoint >> hasBreakpoint [
	^ true
]

{ #category : #initialization }
WrappedBreakpoint >> initializeOn: aCompiledMethod [
	method := aCompiledMethod
]

{ #category : #public }
WrappedBreakpoint >> install [
	method methodClass methodDictionary
		at: method selector
		put: self
]

{ #category : #literals }
WrappedBreakpoint >> literalsDo: aBlock [
	"This method is necessary to show the breakpoint-flag in the browser."
	
	aBlock value: #break.
	method literalsDo: aBlock.
]

{ #category : #private }
WrappedBreakpoint >> printOn: aStream [

	aStream nextPutAll: 'Break in '.
	method printOn: aStream.
]

{ #category : #private }
WrappedBreakpoint >> printStringLimitedTo: limit [
	"Answer a String whose characters are a description of the receiver.
	If you want to print without a character limit, use fullPrintString."
	| limitedString |
	limitedString := String streamContents: [:s | self printOn: s] limitedTo: limit.
	limitedString size < limit ifTrue: [^ limitedString].
	^ limitedString , '...etc...'
]

{ #category : #evaluation }
WrappedBreakpoint >> run: aSelector with: anArray in: aReceiver [
	| process |
	process := Process 
		forContext: (Context
			sender: thisContext sender
			receiver: aReceiver
			method: method
			arguments: anArray)
		priority: Processor activeProcess priority.
	ToolSet
		debugProcess: process
		context: process suspendedContext
		label:  'Breakpoint in ' , method methodClass name , '>>#' , method selector
		contents: nil
		fullView: true.
	Project current spawnNewProcessIfThisIsUI: Processor activeProcess.
	thisContext swapSender: nil.
	Processor activeProcess terminate
]

{ #category : #public }
WrappedBreakpoint >> uninstall [
	method methodClass methodDictionary
		at: method selector
		put: method
]
