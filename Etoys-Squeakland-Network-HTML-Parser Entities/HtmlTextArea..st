Class {
	#name : #HtmlTextArea,
	#superclass : #HtmlFormEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlTextArea >> addToFormatter: formatter [
	| inputMorph |
	formatter currentFormData ifNil: [
		"not in a form.  It's bogus HTML but try to survive"
		^self ].

	formatter ensureNewlines: 1.
	inputMorph := PluggableTextMorph on: StringHolder new text: #contents accept: #acceptContents:.
	inputMorph extent: (self columns * 5) @ (self rows * inputMorph scrollDeltaHeight).
	inputMorph retractable: false.
	formatter addMorph: inputMorph.
	formatter currentFormData addInput: (TextInput name: self name  defaultValue:  self textualContents  textMorph: inputMorph).
	formatter ensureNewlines: 1.
]

{ #category : #attributes }
HtmlTextArea >> columns [
	| a |
	a := self getAttribute: 'cols' default: '20'.
	^(Integer readFrom: (ReadStream on: a)) max: 5.
]

{ #category : #attributes }
HtmlTextArea >> defaultValue [
	^self textualContents  "it would be nice to through the tags in there, too....  Easiest way would probably be to modiy the tokenizer"
]

{ #category : #testing }
HtmlTextArea >> isBlockEntity [
	"not sure...."
	^true
]

{ #category : #testing }
HtmlTextArea >> mayContain: anEntity [
	^true   "really we shouldn't be interpretting tags in here at all, though...."
]

{ #category : #attributes }
HtmlTextArea >> rows [
	| a |
	a := self getAttribute: 'rows' default: '2'.
	^(Integer readFrom: (ReadStream on: a)) max: 1.
]

{ #category : #testing }
HtmlTextArea >> suppliesInput [
	^self name ~= nil
]

{ #category : #testing }
HtmlTextArea >> tagName [
	^'textarea'
]
