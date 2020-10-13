"
A CompilerSyntaxErrorNotifyingTest is a specialization for testing correct handling of non interactive compiler notification.
Non interactive is a very relative notion in Smalltalk...
Here it means that user interaction will not happen directly in the TextEditor holding source code, but rather thru a SyntaxError window that will pop-up.
This test intercept the Notification before the pop-up is raised.

"
Class {
	#name : #CompilerSyntaxErrorNotifyingTest,
	#superclass : #CompilerNotifyingTest,
	#category : #'Tests-Compiler'
}

{ #category : #testing }
CompilerSyntaxErrorNotifyingTest class >> shouldInheritSelectors [
	"This class can recycle all of super tests, it just has to refine internal Compiler evaluation machinery"
	^true
]

{ #category : #private }
CompilerSyntaxErrorNotifyingTest >> enumerateAllSelections [
	"This method intercepts the SyntaxErrorNotification and prevent the SyntaxError morph to open.
	The notification errorCode hold the source of evaluated sub-selection with inserted error message.
	This can be compared to expected error notification."
	| syntaxErrorProbe |
	syntaxErrorProbe := Object new.
	1 to: self numberOfSelections do: [:n |
		| result |
		result := [self evaluateSelectionNumber: n] on: SyntaxErrorNotification do: [:exc |
			| expectedSourceWithError expectedNotificationLocation |
			expectedNotificationLocation := (expectedErrorPositions at: n) - (morph editor startIndex - 1).
			expectedSourceWithError := morph editor selection
							copyReplaceFrom: expectedNotificationLocation
							to: expectedNotificationLocation - 1
							with: (expectedErrors at: n) allButFirst.
			self assert: expectedSourceWithError = exc errorCode asString.
			exc return: syntaxErrorProbe].
		self assert: result == syntaxErrorProbe].
]

{ #category : #private }
CompilerSyntaxErrorNotifyingTest >> evaluateSelection [
	^(nil class evaluatorClass new)
		evaluate: morph editor selection readStream
		"Note subtle difference versus  (morph editor selectionAsStream). 
		The later does not answer the same contents and would raise a SyntaxErrorNotification with wrong sub-selection"
		in: nil
		to: nil
		notifying: nil
		ifFail: [^failure]
]

{ #category : #tests }
CompilerSyntaxErrorNotifyingTest >> testResumeEarlySyntaxError [

	| result |
	result := [Compiler evaluate: '''''''']
		on: SyntaxErrorNotification
		do: [:ex | ex resume: ''''''''''].
	self assert: '''' equals: result
]

{ #category : #tests }
CompilerSyntaxErrorNotifyingTest >> testResumeLateSyntaxError [

	| result |
	result := [Compiler evaluate: '6*:7']
		on: SyntaxErrorNotification
		do: [:ex | ex resume: '6*7'].
	self assert: 42 equals: result
]
