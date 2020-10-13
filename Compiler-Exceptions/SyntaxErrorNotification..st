"
A SyntaxErrorNotification is an Exception occuring when compiling a Smalltalk source code with incorrect syntax.
Note that in interactive mode, this exception is not raised because the Compiler will interact directly with source code editor.
The defaultAction is to raise a SyntaxError pop up window so as to enable interactive handling even in non interactive mode.

Instance Variables
	category:		<String | nil>
	code:		<String | Text | Stream>
	doitFlag:		<Boolean>
	errorMessage:		<String>
	inClass:		<Behavior>
	location:		<Integer>
	newSource:		<String | Text | Stream | nil>

category
	- the category in which the method will be classified

code
	- the source code to be compiled or evaluated

doitFlag
	- true if this is a doIt (code to evaluate), false if this is a method (code of a method to be compiled)

errorMessage
	- contains information about the syntax error

inClass
	- target class in which to compile the method

location
	- position in the source code where the syntax error occured

newSource
	- eventually hold a source code replacement typically passed by the SyntaxError window

"
Class {
	#name : #SyntaxErrorNotification,
	#superclass : #Error,
	#instVars : [
		'inClass',
		'code',
		'doitFlag',
		'errorMessage',
		'location',
		'newSource'
	],
	#category : #'Compiler-Exceptions'
}

{ #category : #exceptionInstantiator }
SyntaxErrorNotification class >> inClass: aClass withCode: codeString doitFlag: doitFlag errorMessage: errorString location: location [
	^self new
		setClass: aClass
		code: codeString
		doitFlag: doitFlag
		errorMessage: errorString
		location: location
]

{ #category : #accessing }
SyntaxErrorNotification >> doitFlag [
	^doitFlag
]

{ #category : #accessing }
SyntaxErrorNotification >> errorClass [
	^inClass
]

{ #category : #accessing }
SyntaxErrorNotification >> errorCode [
	^code
]

{ #category : #accessing }
SyntaxErrorNotification >> errorMessage [
	^errorMessage
]

{ #category : #accessing }
SyntaxErrorNotification >> isResumable [

	^ true
]

{ #category : #accessing }
SyntaxErrorNotification >> location [
	^location
]

{ #category : #accessing }
SyntaxErrorNotification >> messageText [
	^ super messageText
		ifEmpty: [messageText := code]
]

{ #category : #accessing }
SyntaxErrorNotification >> newSource [
	^newSource
]

{ #category : #accessing }
SyntaxErrorNotification >> newSource: aTextOrString [
	newSource := aTextOrString
]

{ #category : #accessing }
SyntaxErrorNotification >> reparse: aString notifying: aController ifFail: failBlock [
	"Try to parse if aString has correct syntax, but do not evaluate/install any code.
	In case of incorrect syntax, execute failBlock and let a Compiler interact with the requestor.
	In case of correct syntax, set newSource."
	doitFlag
		ifTrue: [nil class newCompiler compileNoPattern: aString in: nil class notifying: aController ifFail: failBlock]
		ifFalse: [inClass newCompiler compile: aString in: inClass notifying: aController ifFail: failBlock].
	newSource := aString
]

{ #category : #accessing }
SyntaxErrorNotification >> resume: source [

	self reparse: source notifying: nil ifFail: nil.
	^ super resume: self defaultResumeValue
]

{ #category : #accessing }
SyntaxErrorNotification >> setClass: aClass code: codeString doitFlag: aBoolean errorMessage: errorString location: anInteger [
	inClass := aClass.
	code := codeString.
	doitFlag := aBoolean.
	errorMessage := errorString.
	location := anInteger
]

{ #category : #accessing }
SyntaxErrorNotification >> tryNewSourceIfAvailable [
	newSource ifNotNil: [ReparseAfterSourceEditing withNewSource: newSource]
]
