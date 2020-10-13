"
I am a view for a Modal System Window.  I vary from StandardSystemView, of which I am a subclass in a few ways:

	(1) I use ModalController as my default controller;
	(2) When asked to update with the symbol #close, I direct the controller to close;
	(3) I display a slightly different title bar with no control boxes.
"
Class {
	#name : #ModalSystemWindowView,
	#superclass : #StandardSystemView,
	#instVars : [
		'modalBorder'
	],
	#category : #'ST80-Views'
}

{ #category : #'label access' }
ModalSystemWindowView >> backgroundColor [
	^Color lightYellow
]

{ #category : #'initialize-release' }
ModalSystemWindowView >> borderWidth: anObject [

	modalBorder := false.
	^super borderWidth: anObject
]

{ #category : #'controller access' }
ModalSystemWindowView >> defaultControllerClass [

	^Smalltalk at: #ModalController
]

{ #category : #displaying }
ModalSystemWindowView >> display [

	super display.
	self displayLabelBackground: false.
	self displayLabelText.

]

{ #category : #displaying }
ModalSystemWindowView >> displayBorder [
	"Display the receiver's border (using the receiver's borderColor)."

	modalBorder ifFalse: [^super displayBorder].

	Display
		border: self displayBox
		widthRectangle: (1@1 corner: 2@2)
		rule: Form over
		fillColor: Color black.
	Display
		border: (self displayBox insetBy: (1@1 corner: 2@2))
		widthRectangle: (4@4 corner: 3@3)
		rule: Form over
		fillColor: (Color r: 16rEA g: 16rEA b: 16rEA).

]

{ #category : #displaying }
ModalSystemWindowView >> displayLabelBoxes [
	"Modal dialogs don't have closeBox or growBox."

]

{ #category : #'modal dialog' }
ModalSystemWindowView >> doModalDialog [

	| savedArea |
	self resizeInitially.
	self resizeTo: 
		((self windowBox)
			align: self windowBox center
			with: Display boundingBox aboveCenter).
	savedArea := Form fromDisplay: self windowBox.
	self displayEmphasized.
	self controller startUp.
	self release.
	savedArea displayOn: Display at: self windowOrigin.

]

{ #category : #'initialize-release' }
ModalSystemWindowView >> initialize [ 
	"Refer to the comment in View|initialize."
	super initialize.
	self borderWidth: 5.
	self noLabel.
	modalBorder := true.
]

{ #category : #'model access' }
ModalSystemWindowView >> update: aSymbol [
	aSymbol = #close
		ifTrue: [^self controller close].
	^super update: aSymbol
]
