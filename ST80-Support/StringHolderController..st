"
I represent a ParagraphEditor for a single paragraph of text, omitting alignment commands. I provide items in the yellow button menu so that the text selection can be evaluated and so that the contents of the model can be stored or restored.
	doIt	evaluate the text selection as an expression
	printIt	same as doIt but insert a description of the result after the selection
	accept	store the contents of the StringHolder into the model
	cancel	store the contents of the model into the StringHolder
"
Class {
	#name : #StringHolderController,
	#superclass : #ParagraphEditor,
	#classVars : [
		'CodeYellowButtonMenu',
		'CodeYellowButtonMessages'
	],
	#category : #'ST80-Support'
}

{ #category : #'menu messages' }
StringHolderController >> accept [ 
	"Refer to the comment in ParagraphEditor|accept."

	super accept.
	model contents: paragraph string.
	self userHasNotEdited.

]

{ #category : #'compiler access' }
StringHolderController >> bindingOf: aString [
	^model bindingOf: aString
]

{ #category : #'menu messages' }
StringHolderController >> cancel [ 
	"Refer to the comment in ParagraphEditor|cancel."

	super cancel.
	self userHasNotEdited.

]

{ #category : #accessing }
StringHolderController >> changeText: aText [
	"The paragraph to be edited is changed to aText."
	paragraph text: aText.
	self resetState.
	self selectInvisiblyFrom: paragraph text size + 1 to: paragraph text size.
	self selectAndScroll.
	self deselect
]

{ #category : #private }
StringHolderController >> closeTypeIn [
	"Note edit if something actually was typed."

	beginTypeInBlock ~~ nil ifTrue: [self userHasEdited].
	super closeTypeIn.

]

{ #category : #'edit flag' }
StringHolderController >> hasUnacceptedEdits: aBoolean [
	^ view hasUnacceptedEdits: aBoolean
]

{ #category : #accessing }
StringHolderController >> model: aModel [

	super model: aModel.
	view displayContents == nil
		ifFalse: [self changeParagraph: view displayContents]
]

{ #category : #'menu messages' }
StringHolderController >> performMenuMessage: aSelector [
	"Intercept #again so the model does not get locked by keying the search text."

	| hadEdits |
	hadEdits := view canDiscardEdits not.
	super performMenuMessage: aSelector.
	(hadEdits not and:
	 [aSelector == #again and:
	 [(UndoMessage sends: #undoAgain:andReselect:typedKey:) and:
	 [UndoMessage arguments at: 3]]])
		ifTrue: [self userHasNotEdited].

]

{ #category : #'edit flag' }
StringHolderController >> userHasEdited [
	"Note that the user has edited my text."

	view hasUnacceptedEdits: true

]

{ #category : #'edit flag' }
StringHolderController >> userHasNotEdited [
	"Note that my text is free of user edits."

	model changed: #clearUserEdits.
]

{ #category : #private }
StringHolderController >> zapSelectionWith: aText [
	"Note edit except during typeIn, which notes edits at close."

	super zapSelectionWith: aText.
	beginTypeInBlock == nil ifTrue: [self userHasEdited].

]
