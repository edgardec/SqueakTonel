"
I represent a view of an instance of DisplayText.
"
Class {
	#name : #DisplayTextView,
	#superclass : #View,
	#instVars : [
		'rule',
		'mask',
		'editParagraph',
		'centered'
	],
	#category : #'ST80-Views'
}

{ #category : #examples }
DisplayTextView class >> example2 [	
	"Create a standarad system view with two parts, one editable, the other not."
	| topView aDisplayTextView |
	topView := StandardSystemView new.
	topView label: 'Text Editor'.
	aDisplayTextView := self new model: 'test string label' asDisplayText.
	aDisplayTextView controller: NoController new.
	aDisplayTextView window: (0 @ 0 extent: 100 @ 100).
	aDisplayTextView borderWidthLeft: 2 right: 0 top: 2 bottom: 2.
	topView addSubView: aDisplayTextView.

	aDisplayTextView := self new model: 'test string' asDisplayText.
	aDisplayTextView window: (0 @ 0 extent: 100 @ 100).
	aDisplayTextView borderWidth: 2.
	topView
		addSubView: aDisplayTextView
		align: aDisplayTextView viewport topLeft
		with: topView lastSubView viewport topRight.
	topView controller open

	"DisplayTextView example2"
]

{ #category : #examples }
DisplayTextView class >> example3 [	
	"Create a passive view of some text on the screen."
	| view |
	view:= self new model: 'this is a test of one line
and the second line' asDisplayText.
	view translateBy: 100@100.	
	view borderWidth: 2.
	view display.
	view release

	"DisplayTextView example3"
]

{ #category : #examples }
DisplayTextView class >> example4 [	
	"Create four passive views of some text on the screen with fat borders."
	| view |
	view:= self new model: 'this is a test of one line
and the second line' asDisplayText.
	view translateBy: 100@100.	
	view borderWidth: 5.
	view display.
	3 timesRepeat: [view translateBy: 100@100. view display].
	view release

	"DisplayTextView example4"
]

{ #category : #private }
DisplayTextView >> centerText [

	self isCentered
		ifTrue: 
			[editParagraph
				align: editParagraph boundingBox center
				with: self getWindow center]
]

{ #category : #accessing }
DisplayTextView >> centered [

	centered := true.
	self centerText
]

{ #category : #deEmphasizing }
DisplayTextView >> deEmphasizeView [ 
	"Refer to the comment in View|deEmphasizeView."

	(self controller isKindOf: ParagraphEditor)
	 	ifTrue: [controller deselect]
]

{ #category : #'controller access' }
DisplayTextView >> defaultController [ 
	"Refer to the comment in View|defaultController."

	^self defaultControllerClass newParagraph: editParagraph
]

{ #category : #'controller access' }
DisplayTextView >> defaultControllerClass [ 
	"Refer to the comment in View|defaultControllerClass."

	^ParagraphEditor
]

{ #category : #private }
DisplayTextView >> defaultRule [

	^Form over
]

{ #category : #'window access' }
DisplayTextView >> defaultWindow [ 
	"Refer to the comment in View|defaultWindow."

	^self inverseDisplayTransform: (editParagraph boundingBox expandBy: 6 @ 6)
]

{ #category : #displaying }
DisplayTextView >> display [ 
	"Refer to the comment in View|display."

	self isUnlocked ifTrue: [self positionText].
	super display
]

{ #category : #displaying }
DisplayTextView >> displayView [ 
	"Refer to the comment in View|displayView."

	self clearInside.
	(self controller isKindOf: ParagraphEditor )
		ifTrue: [controller changeParagraph: editParagraph].
	editParagraph foregroundColor: self foregroundColor
				backgroundColor: self backgroundColor.
	self isCentered
		ifTrue: 
			[editParagraph displayOn: Display
				transformation: self displayTransformation
				clippingBox: self insetDisplayBox
				fixedPoint: editParagraph boundingBox center]
		ifFalse: 
			[editParagraph displayOn: Display]
]

{ #category : #accessing }
DisplayTextView >> fillColor [
	"Answer an instance of class Form that is to be used as the mask when 
	displaying the receiver's model (a DisplayText)."

	^ mask
]

{ #category : #accessing }
DisplayTextView >> fillColor: aForm [ 
	"Set aForm to be the mask used when displaying the receiver's model."

	mask := aForm
]

{ #category : #'initialize-release' }
DisplayTextView >> initialize [ 
	"Refer to the comment in View|initialize."

	super initialize.
	centered := false
]

{ #category : #accessing }
DisplayTextView >> isCentered [

	^centered
]

{ #category : #'lock access' }
DisplayTextView >> lock [ 
	"Refer to the comment in View|lock.  Must do what would be done by displaying..."

	self isUnlocked ifTrue: [self positionText].
	super lock
]

{ #category : #accessing }
DisplayTextView >> mask [
	"Answer an instance of class Form that is to be used as the mask when 
	displaying the receiver's model (a DisplayText)."

	^ mask
]

{ #category : #'model access' }
DisplayTextView >> model: aDisplayText [ 
	"Refer to the comment in View|model:."

	super model: aDisplayText.
	editParagraph := model asParagraph.
	self centerText
]

{ #category : #private }
DisplayTextView >> positionText [

	| box |
	box := (self displayBox insetBy: 6@6) origin extent: editParagraph boundingBox extent.
	editParagraph wrappingBox: box clippingBox: box.
	self centerText
]

{ #category : #accessing }
DisplayTextView >> rule [
	"Answer a number from 0 to 15 that indicates which of the sixteen 
	display rules is to be used when copying the receiver's model (a 
	DisplayText) onto the display screen."

	rule == nil
		ifTrue: [^self defaultRule]
		ifFalse: [^rule]
]

{ #category : #accessing }
DisplayTextView >> rule: anInteger [ 
	"Set anInteger to be the rule used when displaying the receiver's model."

	rule := anInteger
]

{ #category : #displaying }
DisplayTextView >> uncacheBits [
	"Normally only sent to a StandardSystemView, but for casees where a DisplayTextView is used alone, without a superview, in which we make this a no-op, put in so that the Character Recognizer doesn't fail.  8/9/96 sw"
]

{ #category : #'window access' }
DisplayTextView >> window: aWindow [ 
	"Refer to the comment in View|window:."

	super window: aWindow.
	self centerText
]
