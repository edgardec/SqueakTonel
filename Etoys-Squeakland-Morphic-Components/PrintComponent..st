Class {
	#name : #PrintComponent,
	#superclass : #TextComponent,
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #'menu commands' }
PrintComponent >> accept [
	"Inform the model of text to be accepted, and return true if OK."

	| textToAccept |
	self canDiscardEdits ifTrue: [^self flash].
	setTextSelector isNil ifTrue: [^self].
	textToAccept := textMorph asText.
	model perform: setTextSelector
		with: (Compiler evaluate: textToAccept logged: false).
	self setText: textToAccept.
	self hasUnacceptedEdits: false
]

{ #category : #'model access' }
PrintComponent >> getText [
	"Retrieve the current model text"

	getTextSelector isNil ifTrue: [^Text new].
	^(model perform: getTextSelector) printString asText
]

{ #category : #components }
PrintComponent >> initPinSpecs [ 
	pinSpecs := Array
		with: (PinSpec new pinName: 'value' direction: #inputOutput
				localReadSelector: nil localWriteSelector: nil
				modelReadSelector: getTextSelector modelWriteSelector: setTextSelector
				defaultValue: nil pinLoc: 1.5)
]
