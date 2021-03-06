"
I am a view of a FillInTheBlank. I display a query and an editable view of the user's reply string.

"
Class {
	#name : #FillInTheBlankView,
	#superclass : #StringHolderView,
	#category : #'ST80-Support'
}

{ #category : #'instance creation' }
FillInTheBlankView class >> multiLineOn: aFillInTheBlank message: queryString centerAt: aPoint answerHeight: answerHeight [
	"Answer an instance of me on aFillInTheBlank asking the question queryString. Allow the reply to be multiple lines, and make the user input view the given height."

	| messageView answerView topView |
	messageView := DisplayTextView new
		model: queryString asDisplayText;
		borderWidthLeft: 2 right: 2 top: 2 bottom: 0;
		controller: NoController new.
	messageView
		window: (0@0 extent: (messageView window extent max: 200@30));
		centered.
	answerView := self new
		model: aFillInTheBlank;
		window: (0@0 extent: (messageView window width@answerHeight));
		borderWidth: 2.
	topView := View new model: aFillInTheBlank.
	topView controller: ModalController new.
	topView addSubView: messageView.
	topView addSubView: answerView below: messageView.
	topView align: topView viewport center with: aPoint.
	topView window:
		(0 @ 0 extent:
			(messageView window width) @
			  (messageView window height + answerView window height)).
	topView translateBy:
		(topView displayBox amountToTranslateWithin: Display boundingBox).
	^ topView

]

{ #category : #'instance creation' }
FillInTheBlankView class >> on: aFillInTheBlank message: queryString centerAt: aPoint [
	"Answer an instance of me on aFillInTheBlank for a single line of input in response to the question queryString."

	aFillInTheBlank acceptOnCR: true.
	^ self
		multiLineOn: aFillInTheBlank
		message: queryString
		centerAt: aPoint
		answerHeight: 40

]

{ #category : #'instance creation' }
FillInTheBlankView class >> requestPassword: aFillInTheBlank message: queryString centerAt: aPoint answerHeight: answerHeight [
	"Answer an instance of me on aFillInTheBlank asking the question queryString. Allow the reply to be multiple lines, and make the user input view the given height."

	| messageView answerView topView myPar pwdFont myArray myStyle |
	aFillInTheBlank acceptOnCR: true.
	messageView := DisplayTextView new
		model: queryString asDisplayText;
		borderWidthLeft: 2 right: 2 top: 2 bottom: 0;
		controller: NoController new.
	messageView
		window: (0@0 extent: (messageView window extent max: 200@30));
		centered.
	answerView := self new
		model: aFillInTheBlank;
		window: (0@0 extent: (messageView window width@answerHeight));
		borderWidth: 2.
	" now answerView to use the password font"
	myPar := answerView displayContents.
	pwdFont := (StrikeFont passwordFontSize: 12).
	myArray := Array new: 1.
	myArray at: 1 put: pwdFont.
	myStyle := TextStyle fontArray: myArray.
	myPar setWithText: (myPar text) style: myStyle.

	topView := View new model: aFillInTheBlank.
	topView controller: ModalController new.
	topView addSubView: messageView.
	topView addSubView: answerView below: messageView.
	topView align: topView viewport center with: aPoint.
	topView window:
		(0 @ 0 extent:
			(messageView window width) @
			  (messageView window height + answerView window height)).
	topView translateBy:
		(topView displayBox amountToTranslateWithin: Display boundingBox).
	^ topView

]

{ #category : #'controller access' }
FillInTheBlankView >> defaultControllerClass [

	^ FillInTheBlankController

]
