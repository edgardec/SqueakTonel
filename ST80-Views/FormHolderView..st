"
I represent a view of a Form. Editing takes place by modifying a working version of the Form. The message accept is used to copy the working version into the Form; the message cancel copies the Form into the working version.
"
Class {
	#name : #FormHolderView,
	#superclass : #FormView,
	#instVars : [
		'displayedForm'
	],
	#category : #'ST80-Views'
}

{ #category : #'menu messages' }
FormHolderView >> accept [ 
	"Refer to the comment in FormView|accept."
	model
		copyBits: displayedForm boundingBox
		from: displayedForm
		at: 0 @ 0
		clippingBox: model boundingBox
		rule: Form over
		fillColor: nil.
	model changed: self
]

{ #category : #'menu messages' }
FormHolderView >> cancel [ 
	"Refer to the comment in FormView|cancel."

	displayedForm becomeForward: model deepCopy.
	displayedForm changed: self.
	self display
]

{ #category : #'model access' }
FormHolderView >> changeValueAt: location put: anInteger [ 
	"Refer to the comment in FormView|changeValueAt:put:."

	displayedForm pixelValueAt: location put: anInteger.
	displayedForm changed: self
]

{ #category : #displaying }
FormHolderView >> displayView [ 
	"Display the Form associated with this View according to the rule and
	fillColor specifed by this class."

	| oldOffset |
	oldOffset := displayedForm offset.
	displayedForm offset: 0@0.
	displayedForm
		displayOn: Display
		transformation: self displayTransformation
		clippingBox: self insetDisplayBox
		rule: self rule
		fillColor: self fillColor.
	displayedForm offset: oldOffset
]

{ #category : #'model access' }
FormHolderView >> model: aForm [

	super model: aForm.
	displayedForm := aForm deepCopy
]

{ #category : #'initialize-release' }
FormHolderView >> release [

	super release.
	displayedForm release.
	displayedForm := nil
]

{ #category : #displaying }
FormHolderView >> updateDisplay [
	"The working version is redefined by copying the bits displayed in the 
	receiver's display area."

	displayedForm fromDisplay: self displayBox.
	displayedForm changed: self
]

{ #category : #'model access' }
FormHolderView >> workingForm [
	"Answer the form that is currently being displayed--the working version 
	in which edits are carried out."

	^displayedForm
]
