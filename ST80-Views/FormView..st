"
I represent a view of a Form.
"
Class {
	#name : #FormView,
	#superclass : #View,
	#instVars : [
		'rule',
		'mask'
	],
	#category : #'ST80-Views'
}

{ #category : #examples }
FormView class >> exampleOne [
	"Frame a Form (specified by the user) with a border of 2 bits in width and display it offset 60 x 40 from the cornor of the display screen. "
	| f view |
	f := Form fromUser.
	view := self new model: f.
	view translateBy: 60 @ 40.
	view borderWidth: 2.
	view display.
	view release

	"FormView exampleOne"
]

{ #category : #examples }
FormView class >> exampleTwo [
	"Frame a Form (specified by the user) that is scaled by 2. The border is 2 bits in width. Displays at location 60, 40."
	| f view |
	f := Form fromUser.
	view := self new model: f.
	view scaleBy: 2.0.
	view translateBy: 60 @ 40.
	view borderWidth: 2.
	view display.
	view release

	"FormView exampleTwo"
]

{ #category : #examples }
FormView class >> open: aForm named: aString [
	"FormView open: ((Form extent: 100@100) borderWidth: 1) named: 'Squeak' "
	"Open a window whose model is aForm and whose label is aString."
	| topView aView |
	topView := StandardSystemView new.
	topView model: aForm.
	topView label: aString.
	topView minimumSize: aForm extent;
	          maximumSize: aForm extent.
	aView := FormView new.
	aView model: aForm.
	aView window: (aForm boundingBox expandBy: 2).
	aView borderWidthLeft: 2 right: 2 top: 2 bottom: 2.
	topView addSubView: aView.
	topView controller open
]

{ #category : #'menu messages' }
FormView >> accept [
	"The receiver's model is set to the working version, the one in which 
	edits are carried out."

	^self
]

{ #category : #'menu messages' }
FormView >> cancel [
	"Set the working form to be a copy of the model."

	^self
]

{ #category : #'model access' }
FormView >> changeValueAt: location put: anInteger [
	"The receiver's model is a form which has an array of bits. Change the 
	bit at index, location, to be anInteger (either 1 or 0). Inform all objects 
	that depend on the model that it has changed."

	model pixelValueAt: location put: anInteger.
	model changed: self
]

{ #category : #'controller access' }
FormView >> defaultControllerClass [ 
	"Refer to the comment in View|defaultControllerClass."

	^  FormEditor
]

{ #category : #private }
FormView >> defaultRule [ 
	"The default display rule is 3=over or storing."

	^Form over
]

{ #category : #'window access' }
FormView >> defaultWindow [ 
	"Refer to the comment in View|defaultWindow."

	^(Rectangle origin: 0 @ 0 extent: model extent)
		expandBy: borderWidth
]

{ #category : #displaying }
FormView >> displayOn: aPort [
	model displayOnPort: aPort at: self displayBox origin
]

{ #category : #displaying }
FormView >> displayView [ 
	"Refer to the comment in View|displayView."

	| oldOffset |
	super displayView.
	insideColor == nil ifFalse: [Display fill: self insetDisplayBox fillColor: insideColor].
	oldOffset := model offset.
	model offset: "borderWidth origin" 0@0.
	model
		displayOn: Display
		transformation: self displayTransformation
		clippingBox: self insetDisplayBox
		rule: self rule
		fillColor: self fillColor.
	model offset: oldOffset
]

{ #category : #accessing }
FormView >> fillColor [
	"Answer an instance of class Form that is the mask used when displaying 
	the receiver's model (a Form) on the display screen (see BitBlt for the 
	meaning of this mask)."

	^ mask
]

{ #category : #accessing }
FormView >> fillColor: aForm [ 
	"Set the display mask for displaying the receiver's model to be the 
	argument, aForm."

	mask := aForm
]

{ #category : #accessing }
FormView >> mask [
	"Answer an instance of class Form that is the mask used when displaying 
	the receiver's model (a Form) on the display screen (see BitBlt for the 
	meaning of this mask)."

	^ mask
]

{ #category : #accessing }
FormView >> rule [
	"Answer a number from 0 to 15 that indicates which of the sixteen 
	display rules (logical function of two boolean values) is to be used when 
	copying the receiver's model (a Form) onto the display screen."

	rule == nil
		ifTrue: [^self defaultRule]
		ifFalse: [^rule]
]

{ #category : #accessing }
FormView >> rule: anInteger [ 
	"Set the display rule for the receiver to be the argument, anInteger."

	rule := anInteger
]

{ #category : #displaying }
FormView >> uncacheBits [
	"Placed vacuously here so that when ControlManager>>restore calls uncacheBits for a project with no windows, we don't hang.  1/24/96 sw"
]

{ #category : #updating }
FormView >> update: aFormView [ 
	"Refer to the comment in View|update:."

	self == aFormView ifFalse: [self display]
]

{ #category : #displaying }
FormView >> updateDisplay [
	"overridden by subclass"
]

{ #category : #'window access' }
FormView >> windowBox [
	"For comaptibility with Control manager (see senders)"
	^ self insetDisplayBox
]
