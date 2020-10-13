Class {
	#name : #MethodHighlightingTests,
	#superclass : #ClosureCompilerTest,
	#instVars : [
		'creator',
		'timeStamp',
		'duration',
		'tracks'
	],
	#category : #'Tests-Compiler'
}

{ #category : #tests }
MethodHighlightingTests >> asXML [
	"self new asXML"
	"Convert the master index into external XML representation"
	
	^String streamContents:[:s| | writer |
		writer := self xmlWriter on: s.
		writer xmlDeclaration: '1.0'.
		writer startTag: 'recording'; endTag.
			writer tag: 'creator' pcData: creator.
			writer tag: 'timestamp' pcData: timeStamp.
			writer tag: 'duration' pcData: duration.
			writer startTag: 'tracks'; endTag.
				tracks do:[:tdata|
					writer startTag: 'track'; attribute: 'type' value: tdata value; endTag.
					writer pcData: tdata key.
					writer endTag: 'track'.
				].
			writer endTag: 'tracks'.
		writer endTag: 'recording'.
	].

]

{ #category : #tests }
MethodHighlightingTests >> testMethodHighlighting [
	| map before after method retpc |
	"Test the highlighting of the asXML method.  Test the highlighting of the return
	 statement which should include the whole block supplied to streamContents:."
	"DebuggerMethodMap voidMapCache"
	"DebuggerMethodMap forMethod: MethodHighlightingTests >> #asXML"
	method := MethodHighlightingTests >> #asXML.
	map := DebuggerMethodMap forMethod: method.
	retpc := method endPC.
	before := map rangeForPC: retpc in: method contextIsActiveContext: false.
	map instVarNamed: 'abstractSourceRanges' put: nil.
	after := map rangeForPC: retpc in: method contextIsActiveContext: false.
	self assert: before size > 500.
	self assert: before = after
]
