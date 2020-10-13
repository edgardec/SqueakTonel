"
I represent a prompt for string input from the user. The user is asked to type in and edit a string. The resulting string is supplied as the argument to a client-supplied action block.

"
Class {
	#name : #FillInTheBlank,
	#superclass : #StringHolder,
	#instVars : [
		'acceptOnCR',
		'done',
		'responseUponCancel'
	],
	#category : #'ST80-Menus'
}

{ #category : #private }
FillInTheBlank class >> fillInTheBlankMorphClass [
	"By factoring out this class references, it becomes possible to discard 
	morphic by simply removing this class.  All calls to this method needs
	to be protected by 'Smalltalk isMorphic' tests."

	^ Smalltalk
		at: #FillInTheBlankMorph
		ifAbsent: [self notify: 'Morphic class FillInTheBlankMorph not present']
]

{ #category : #private }
FillInTheBlank class >> fillInTheBlankViewClass [
	"By factoring out this class references, it becomes possible to discard 
	MVC by simply removing this class.  All calls to this method needs
	to be protected by 'Smalltalk isMorphic' tests."

	^ FillInTheBlankView
]

{ #category : #'instance creation' }
FillInTheBlank class >> multiLineRequest: queryString centerAt: aPoint initialAnswer: defaultAnswer answerHeight: answerHeight [ 
	"Create a multi-line instance of me whose question is queryString with
	the given initial answer. Invoke it centered at the given point, and
	answer the string the user accepts.  Answer nil if the user cancels.  An
	empty string returned means that the ussr cleared the editing area and
	then hit 'accept'.  Because multiple lines are invited, we ask that the user
	use the ENTER key, or (in morphic anyway) hit the 'accept' button, to 
	submit; that way, the return key can be typed to move to the next line.
	NOTE: The ENTER key does not work on Windows platforms."

	"UIManager default
		multiLineRequest:
'Enter several lines; end input by accepting
or canceling via menu or press Alt+s/Alt+l'
		centerAt: Display center
		initialAnswer: 'Once upon a time...'
		answerHeight: 200"

	| model fillInView |
	Smalltalk isMorphic 
		ifTrue: 
			[^self fillInTheBlankMorphClass 
				request: queryString
				initialAnswer: defaultAnswer
				centerAt: aPoint
				inWorld: self currentWorld
				onCancelReturn: nil
				acceptOnCR: false].
	model := self new.
	model contents: defaultAnswer.
	model responseUponCancel: nil.
	model acceptOnCR: false.
	fillInView := self fillInTheBlankViewClass 
				multiLineOn: model
				message: queryString
				centerAt: aPoint
				answerHeight: answerHeight.
	^model show: fillInView
]

{ #category : #'instance creation' }
FillInTheBlank class >> request: queryString [ 
	"Create an instance of me whose question is queryString. Invoke it 
	centered at the cursor, and answer the string the user accepts. Answer 
	the empty string if the user cancels."

	"UIManager default request: 'Your name?'"

	^ self
		request: queryString
		initialAnswer: ''
		centerAt: (self currentHand ifNil: [Sensor]) cursorPoint
]

{ #category : #'instance creation' }
FillInTheBlank class >> request: queryString initialAnswer: defaultAnswer [ 
	"Create an instance of me whose question is queryString with the given 
	initial answer. Invoke it centered at the given point, and answer the 
	string the user accepts. Answer the empty string if the user cancels."

	"UIManager default 
		request: 'What is your favorite color?' 
		initialAnswer: 'red, no blue. Ahhh!'"

	^ self
		request: queryString
		initialAnswer: defaultAnswer
		centerAt: (self currentHand ifNil: [Sensor]) cursorPoint
]

{ #category : #'instance creation' }
FillInTheBlank class >> request: queryString initialAnswer: defaultAnswer centerAt: aPoint [ 

	^ self
		request: queryString
		initialAnswer: defaultAnswer
		centerAt: aPoint
		onCancelReturn: ''
]

{ #category : #'instance creation' }
FillInTheBlank class >> request: queryString initialAnswer: defaultAnswer centerAt: aPoint onCancelReturn: cancelResponse [
	"Create an instance of me whose question is queryString with the given
	initial answer. Invoke it centered at the given point, and answer the
	string the user accepts. Answer the empty string if the user cancels."

	"UIManager default
		request: 'Type something, then type CR.'
		initialAnswer: 'yo ho ho!'
		centerAt: Display center"

	| model fillInView |
	Smalltalk isMorphic 
		ifTrue: 
			[^self fillInTheBlankMorphClass 
				request: queryString
				initialAnswer: defaultAnswer
				centerAt: aPoint].
	model := self new.
	model contents: defaultAnswer.
	model responseUponCancel: cancelResponse.
	fillInView := self fillInTheBlankViewClass 
				on: model
				message: queryString
				centerAt: aPoint.
	^model show: fillInView
]

{ #category : #'instance creation' }
FillInTheBlank class >> request: queryString initialAnswer: defaultAnswer onCancelReturn: cancelResponse [

	^ self
		request: queryString
		initialAnswer: defaultAnswer
		centerAt: (self currentHand ifNil: [Sensor]) cursorPoint
		onCancelReturn: cancelResponse
]

{ #category : #'instance creation' }
FillInTheBlank class >> requestPassword: queryString [ 
	"Create an instance of me whose question is queryString. Invoke it centered
	at the cursor, and answer the string the user accepts. Answer the empty 
	string if the user cancels."

	"UIManager default requestPassword: 'POP password'"

	| model fillInView |
	Smalltalk isMorphic 
		ifTrue: [^self fillInTheBlankMorphClass requestPassword: queryString].
	model := self new.
	model contents: ''.
	fillInView := self fillInTheBlankViewClass 
				requestPassword: model
				message: queryString
				centerAt: Sensor cursorPoint
				answerHeight: 40.
	^model show: fillInView
]

{ #category : #accessing }
FillInTheBlank >> acceptOnCR [
	"Answer whether a carriage return should cause input to be accepted."

	^ acceptOnCR

]

{ #category : #accessing }
FillInTheBlank >> acceptOnCR: aBoolean [

	acceptOnCR := aBoolean.

]

{ #category : #'object fileIn' }
FillInTheBlank >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	varDict at: 'responseUponCancel' ifAbsent: [responseUponCancel := ''].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #accessing }
FillInTheBlank >> done [
	"Answer whether the user has ended the interaction."

	^ done

]

{ #category : #accessing }
FillInTheBlank >> done: aBoolean [

	done := aBoolean.

]

{ #category : #'initialize-release' }
FillInTheBlank >> initialize [

	super initialize.
	acceptOnCR := false.
	done := false.
	responseUponCancel := ''

]

{ #category : #accessing }
FillInTheBlank >> responseUponCancel: resp [
	responseUponCancel := resp
]

{ #category : #accessing }
FillInTheBlank >> setResponseForCancel [
	self contents: responseUponCancel
]

{ #category : #private }
FillInTheBlank >> show: fillInView [
	| savedArea |
	savedArea := Form fromDisplay: fillInView displayBox.
	fillInView display.
	contents isEmpty
		ifFalse: [fillInView lastSubView controller selectFrom: 1 to: contents size].
	(fillInView lastSubView containsPoint: Sensor cursorPoint)
		ifFalse: [fillInView lastSubView controller centerCursorInView].
	fillInView controller startUp.
	fillInView release.
	savedArea displayOn: Display at: fillInView viewport topLeft.
	^ contents
]
