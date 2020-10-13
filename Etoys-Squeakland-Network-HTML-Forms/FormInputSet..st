"
Holds the inputs for an instance of an HTML Form.  It has a link to the browser it will be displayed in, and it has a link to each of the input PluggableTextMorph's that it input will read from.

inputs - maps HtmlInput's into the text morphs which will input their value.
"
Class {
	#name : #FormInputSet,
	#superclass : #Model,
	#instVars : [
		'inputs',
		'browser',
		'form'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Forms'
}

{ #category : #'instance creation' }
FormInputSet class >> forForm: form  andBrowser: browser [
	"create a FormData for the given form and browser"
	^super new form: form  browser: browser
]

{ #category : #'adding inputs' }
FormInputSet >> addInput: anInput [
	inputs add: anInput
]

{ #category : #'private-initialization' }
FormInputSet >> form: f  browser: b [
	inputs := OrderedCollection new.
	form := f.
	browser := b.
]

{ #category : #'adding inputs' }
FormInputSet >> inputs [
	"return a list of the list of inputs"
	^inputs
]

{ #category : #action }
FormInputSet >> reset [
	"reset all inputs to their default value"
	inputs do: [ :input | input reset ]
]

{ #category : #action }
FormInputSet >> submit [
	"collect inputs and instruct the browser to do a submission"
	| inputValues |
	inputValues := Dictionary new.

	inputs do: [ :input |
		input active ifTrue: [
			(inputValues includesKey: input name) ifFalse: [
				inputValues at: input name  put: (OrderedCollection new: 1) ].
			(inputValues at: input name)  add: input value ] ].
	browser submitFormWithInputs: inputValues url: form url
		method: form method encoding: form encoding.
	^true
]
