"
I am the controller for a FillInTheBlankView. Based on a flag in the view, I can either accept the input string when a carriage return is typed, or I can allow multiple lines of input that is accepted by either typing enter or by invoking the 'accept' command.

"
Class {
	#name : #FillInTheBlankController,
	#superclass : #StringHolderController,
	#category : #'ST80-Support'
}

{ #category : #other }
FillInTheBlankController >> accept [

	super accept.
	model done: true.

]

{ #category : #other }
FillInTheBlankController >> cancel [

	model setResponseForCancel.
	super cancel.
	model done: true.

]

{ #category : #'basic control sequence' }
FillInTheBlankController >> controlInitialize [

	model acceptOnCR ifFalse: [^ super controlInitialize].
	self setMark: self markBlock stringIndex.
	self setPoint: self pointBlock stringIndex.
	self initializeSelection.
	beginTypeInBlock := nil.

]

{ #category : #'basic control sequence' }
FillInTheBlankController >> controlTerminate [

	| topController |
	super controlTerminate.
	topController := view topView controller.
	topController ifNotNil: [topController close].

]

{ #category : #other }
FillInTheBlankController >> dispatchOnCharacter: char with: typeAheadStream [
	"Accept the current input if the user hits the carriage return or the enter key."

	(model acceptOnCR and:
	 [(char = Character cr) | (char = Character enter)])
		ifTrue: [
			sensor keyboard.  "absorb the character"
			self accept.
			^ true]
		ifFalse: [
			^ super dispatchOnCharacter: char with: typeAheadStream].

]

{ #category : #'control defaults' }
FillInTheBlankController >> isControlActive [
	^ self isControlWanted
]

{ #category : #'control defaults' }
FillInTheBlankController >> isControlWanted [
	^ model done not
]

{ #category : #other }
FillInTheBlankController >> processYellowButton [
	"Suppress yellow-button menu if acceptOnCR is true."

	model acceptOnCR ifFalse: [^ super processYellowButton].

]
