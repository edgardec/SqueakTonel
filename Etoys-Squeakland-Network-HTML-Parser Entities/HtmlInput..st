"
result of an <input> tag
"
Class {
	#name : #HtmlInput,
	#superclass : #HtmlFormEntity,
	#instVars : [
		'value'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlInput >> addCheckBoxButtonToFormatter: formatter [
	| name formData checked button buttonInput |

	"dig up relevant attributes"
	name := self getAttribute: 'name'.
	name ifNil: [ ^self ].
	value := self getAttribute: 'value'.
	value ifNil: [ ^value ].
	
	formData := formatter currentFormData.
	formData ifNil:  [ ^self ].

	checked := (self getAttribute: 'checked') isNil not.

	"set up the form input"
	buttonInput := ToggleButtonInput name: name value: value checkedByDefault: checked.
	formData addInput: buttonInput.

	"create the actual button"
	button := UpdatingThreePhaseButtonMorph checkBox.
	button target: buttonInput;
		getSelector: #pressed;
		actionSelector: #toggle.
	buttonInput button: button.
	formatter addMorph: button.



]

{ #category : #formatting }
HtmlInput >> addFileInputToFormatter: formatter [
	"is it a submit button?"
	| inputMorph size fileInput |
	inputMorph := PluggableTextMorph on: StringHolder new text: #contents accept: #acceptContents:.
	size := (self getAttribute: 'size' default: '12') asNumber.
	inputMorph extent: (size*10@20).
	fileInput := FileInput name: self name textMorph: inputMorph.
	formatter addMorph: inputMorph;
		addMorph: ((PluggableButtonMorph on: fileInput getState: nil action: #browse)
				label: 'Browse').
	formatter currentFormData addInput: fileInput
]

{ #category : #formatting }
HtmlInput >> addImageButtonToFormatter: formatter [
	"is it a submit button?"
	| formData imageUrl morph |
	(imageUrl := self getAttribute: 'src') ifNil: [^self].
	formatter baseUrl
		ifNotNil: [imageUrl := imageUrl asUrlRelativeTo: formatter baseUrl].

	morph := DownloadingImageMorph new.
	morph defaultExtent: self imageExtent.
	morph altText: self alt.
	morph url: imageUrl.

	value := self getAttribute: 'name' default: 'Submit'.
	formData := formatter currentFormData.
	morph
		on: #mouseUp
		send: #mouseUpFormData:event:linkMorph:
		to: self
		withValue: formData.
	formatter addIncompleteMorph: morph

]

{ #category : #formatting }
HtmlInput >> addRadioButtonToFormatter: formatter [
	| name formData checked buttonSet button buttonInput |

	"dig up relevant attributes"
	name := self getAttribute: 'name'.
	name ifNil: [ ^self ].
	value := self getAttribute: 'value'.
	value ifNil: [ ^value ].
	
	formData := formatter currentFormData.
	formData ifNil:  [ ^self ].

	checked := self getAttribute: 'checked'.


	"find or create the set of buttons with our same name"
	buttonSet := formData inputs detect: [ :i | i isRadioButtonSetInput and: [ i name = name ] ] ifNone: [ nil ].
	buttonSet ifNil: [ 
		"create a new button set"
		buttonSet := RadioButtonSetInput name: name.
		formData addInput: buttonSet. ].

	"set up the form input"
	buttonInput := RadioButtonInput  inputSet: buttonSet value: value.
	buttonSet addInput: buttonInput.
	checked ifNotNil: [
		buttonSet  defaultButton: buttonInput ].

	"create the actual button"
	button := UpdatingThreePhaseButtonMorph radioButton.
	button target: buttonInput;
		getSelector: #pressed;
		actionSelector: #toggle.
	buttonInput button: button.
	formatter addMorph: button.



]

{ #category : #formatting }
HtmlInput >> addTextInputToFormatter: formatter [
	"is it a submit button?"
	| inputMorph size |
	inputMorph := PluggableTextMorph on: StringHolder new text: #contents accept: #acceptContents:.
	self type = 'password'
		ifTrue: [inputMorph font: (StrikeFont passwordFontSize: 12)].
	size := (self getAttribute: 'size' default: '12') asNumber.
	inputMorph extent: (size*10@20).
	formatter addMorph: inputMorph.
	formatter currentFormData addInput:
		(TextInput name: self name defaultValue: self defaultValue  textMorph: inputMorph).
]

{ #category : #formatting }
HtmlInput >> addToFormatter: formatter [
	formatter currentFormData ifNil: [
		"not in a form.  It's bogus HTML but try to survive"
		^self ].

	"is it a submit button?"
	self type = 'submit' ifTrue: [
		formatter addMorph: ((PluggableButtonMorph on: formatter currentFormData getState: nil action: #submit) label: (self getAttribute: 'value' default: 'Submit')).
		^self ].

	self type = 'image'
		ifTrue: [^self addImageButtonToFormatter: formatter].

	(self type = 'text' or: [self type = 'password'])
		ifTrue: [^self addTextInputToFormatter: formatter].

	self type = 'hidden' ifTrue: [
		formatter currentFormData addInput: (HiddenInput name: self name  value: self defaultValue).
		^self ].

	self type = 'radio' ifTrue: [ 
		^self addRadioButtonToFormatter: formatter ].

	self type = 'checkbox' ifTrue: [ 
		^self addCheckBoxButtonToFormatter: formatter ].

	self type = 'file' ifTrue: [ 
		^self addFileInputToFormatter: formatter ].

	formatter addString: '[form input of type: ', self type, ']'.
]

{ #category : #attributes }
HtmlInput >> defaultValue [
	^(self getAttribute: 'value' default: '') replaceHtmlCharRefs
]

{ #category : #attributes }
HtmlInput >> imageExtent [
	"the image extent, according to the WIDTH and HEIGHT attributes.  returns nil if either WIDTH or HEIGHT is not specified"
	| widthText heightText |
	widthText := self getAttribute: 'width' ifAbsent: [ ^nil ].
	heightText := self getAttribute: 'height' ifAbsent: [ ^nil ].
	^ widthText asNumber @ heightText asNumber
]

{ #category : #testing }
HtmlInput >> isTextualEntity [
	^true
]

{ #category : #testing }
HtmlInput >> mayContain: anEntity [
	^false
]

{ #category : #morphic }
HtmlInput >> mouseUpEvent: arg1 linkMorph: arg2 formData: arg3 [
	"Reorder the arguments for existing event handlers"
	(arg3 isMorph and:[arg3 eventHandler notNil]) ifTrue:[arg3 eventHandler fixReversedValueMessages].
	^self mouseUpFormData: arg1 event: arg2 linkMorph: arg3
]

{ #category : #morphic }
HtmlInput >> mouseUpFormData: formData event: event linkMorph: linkMorph [
	| aPoint |
	aPoint := event cursorPoint - linkMorph topLeft.
	formData addInput: (HiddenInput name: (value, '.x') value: aPoint x asInteger asString).
	formData addInput: (HiddenInput name: (value, '.y') value: aPoint y asInteger asString).
	formData submit
]

{ #category : #testing }
HtmlInput >> suppliesInput [
	"whether we actually have input to supply"
	self type = 'text' ifTrue: [ ^true ].
	^false
]

{ #category : #testing }
HtmlInput >> tagName [
	^'input'
]

{ #category : #attributes }
HtmlInput >> type [
	^(self getAttribute: 'type' default: 'text') asLowercase
]
