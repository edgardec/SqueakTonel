"
I am a View of a String that is an aspect of a more structured object. This String should not be changed by any editing unless the user issues the accept command. Thus my instances provide a working copy of the String. This copy is edited. When the user issues the accept command, the String is copied from the working version; or if the user issues the cancel command, the working version is restored from the String. StringHolderController is my default controller. It is initialized specially by passing the string viewed which is then converted to a Paragraph for editing.
"
Class {
	#name : #StringHolderView,
	#superclass : #View,
	#instVars : [
		'displayContents',
		'hasUnacceptedEdits',
		'askBeforeDiscardingEdits'
	],
	#category : #'ST80-Support'
}

{ #category : #'instance creation' }
StringHolderView class >> container [
	"Answer an instance of me with a new instance of StringHolder as the 
	model."

	^self container: StringHolder new
]

{ #category : #'instance creation' }
StringHolderView class >> container: aContainer [ 
	"Answer an instance of me whose model is aContainer. Give it a 2-dot 
	border."

	| aCodeView |
	aCodeView := self new model: aContainer.
	aCodeView borderWidthLeft: 2 right: 2 top: 2 bottom: 2.
	^aCodeView
]

{ #category : #'instance creation' }
StringHolderView class >> open [
	"Create a standard system view of a workspace on the screen."

	self open: StringHolder new label: 'Workspace'
]

{ #category : #'instance creation' }
StringHolderView class >> open: aStringHolder [ 
	"Create a standard system view of the argument, aStringHolder, as viewed 
	by an instance of me. The view has label 'StringHolder'."

	self open: aStringHolder label: 'StringHolder'
]

{ #category : #'instance creation' }
StringHolderView class >> open: aStringHolder label: labelString [ 
	"NOTE this should be in the model class, and all senders so redirected,
	in order that the view class can be discarded in a morphic world."

	"Create a standard system view of the model, aStringHolder, as viewed by 
	an instance of me. The label of the view is aString."
	| aStringHolderView topView |

	aStringHolderView := self container: aStringHolder.
	topView := StandardSystemView new.
	topView model: aStringHolderView model.
	topView addSubView: aStringHolderView.
	topView label: labelString.
	topView minimumSize: 100 @ 50.
	topView controller open
]

{ #category : #updating }
StringHolderView >> askBeforeDiscardingEdits: aBoolean [
	"Set the flag that determines whether the user should be asked before discarding unaccepted edits."

	askBeforeDiscardingEdits := aBoolean.

]

{ #category : #updating }
StringHolderView >> canDiscardEdits [
	"Return true if this view either has no text changes or does not care."

	^ (hasUnacceptedEdits & askBeforeDiscardingEdits) not

]

{ #category : #deEmphasizing }
StringHolderView >> deEmphasizeView [ 
	"Refer to the comment in View|deEmphasizeView."

	(self controller isKindOf: ParagraphEditor)
	 	ifTrue: [controller deselect]
]

{ #category : #'controller access' }
StringHolderView >> defaultController [ 
	"Refer to the comment in View|defaultController."

	^self defaultControllerClass newParagraph: displayContents
]

{ #category : #'controller access' }
StringHolderView >> defaultControllerClass [ 
	"Refer to the comment in View|defaultControllerClass."

	^StringHolderController
]

{ #category : #displaying }
StringHolderView >> display [ 
	"Refer to the comment in View.display."
	(self isUnlocked and: [self insetDisplayBox ~= displayContents clippingRectangle])
		ifTrue:  "Recompose the text if the window changed"
				[self positionDisplayContents. 
				(self controller isKindOf: ParagraphEditor)
					ifTrue: [controller recomputeSelection]].
	super display
]

{ #category : #'controller access' }
StringHolderView >> displayContents [

	^displayContents
]

{ #category : #displaying }
StringHolderView >> displayView [ 
	"Refer to the comment in View|displayView."

	Display deferUpdatesIn: self displayBox while: [
		self clearInside.
		(self controller isKindOf: ParagraphEditor)
			ifTrue: [controller display]
			ifFalse: [displayContents display]]
]

{ #category : #'model access' }
StringHolderView >> editString: aString [ 
	"The paragraph to be displayed is created from the characters in aString."

	displayContents := Paragraph withText: aString asText
		style: TextStyle default copy
		compositionRectangle: (self insetDisplayBox insetBy: 6 @ 0)
		clippingRectangle: self insetDisplayBox
		foreColor: self foregroundColor backColor: self backgroundColor.
	(self controller isKindOf: ParagraphEditor)
		ifTrue: [controller changeParagraph: displayContents]
]

{ #category : #'model access' }
StringHolderView >> getMenu: shiftKeyState [
	^ nil
]

{ #category : #updating }
StringHolderView >> hasUnacceptedEdits [
	"Return true if this view has unaccepted edits."

	^ hasUnacceptedEdits

]

{ #category : #updating }
StringHolderView >> hasUnacceptedEdits: aBoolean [
	"Set the hasUnacceptedEdits flag to the given value."

	hasUnacceptedEdits := aBoolean.

]

{ #category : #'initialize-release' }
StringHolderView >> initialize [ 
	"Refer to the comment in View|initialize."

	super initialize.
	displayContents := '' asParagraph.
	hasUnacceptedEdits := false.
	askBeforeDiscardingEdits := true.

]

{ #category : #wrapping }
StringHolderView >> isWrapped [
	^true
]

{ #category : #displaying }
StringHolderView >> lock [
	"Refer to the comment in view|lock.  Must do at least what display would do to lock the view."
	(self isUnlocked and: [self insetDisplayBox ~= displayContents clippingRectangle])
		ifTrue:  "Recompose the text if the window changed"
				[self positionDisplayContents. 
				(self controller isKindOf: ParagraphEditor)
					ifTrue: [controller recomputeSelection]].
	super lock
]

{ #category : #'model access' }
StringHolderView >> model: aLockedModel [ 
	"Refer to the comment in View|model:."
 
	super model: aLockedModel.
	self editString: model contents
]

{ #category : #displaying }
StringHolderView >> positionDisplayContents [
	"Presumably the text being displayed changed so that the wrapping box 
	and clipping box should be reset."

	displayContents 
		wrappingBox: (self insetDisplayBox insetBy: 6 @ 0)
		clippingBox: self insetDisplayBox
]

{ #category : #updating }
StringHolderView >> promptForCancel [
	"Ask if it is OK to cancel changes to text"
	| okToCancel stripes |
	self topView isCollapsed ifTrue:
		[(self confirm: 'Changes have not been saved.
Is it OK to cancel those changes?' translated) ifTrue: [model changed: #clearUserEdits].
		^ self].
	stripes := (Form extent: 16@16 fromStipple: 16r36C9) bits.
	Display border: self insetDisplayBox width: 4
			rule: Form reverse fillColor: stripes.
	okToCancel := self confirm: 'Changes have not been saved.
Is it OK to cancel those changes?' translated.
	Display border: self insetDisplayBox width: 4
			rule: Form reverse fillColor: stripes.
	okToCancel ifTrue:
		[self updateDisplayContents.
		model changed: #clearUserEdits].

]

{ #category : #updating }
StringHolderView >> update: aSymbol [
	"Refer to the comment in View|update:."
	aSymbol == #wantToChange ifTrue: [^ self promptForCancel].
	aSymbol == #clearUserEdits ifTrue: [^ self hasUnacceptedEdits: false].
	aSymbol == #flash ifTrue: [^ controller flash].
	self updateDisplayContents
]

{ #category : #updating }
StringHolderView >> updateDisplayContents [
	"Make the text that is displayed be the contents of the receiver's model."

	self editString: model contents.
	self displayView
]

{ #category : #wrapping }
StringHolderView >> wrapFlag: aBoolean [
	"Control whether contained text will adjust its bounds as I change shape.
	This is a no-op in MVC,. See TextMorph>>wrapFlag: for reference."

]
