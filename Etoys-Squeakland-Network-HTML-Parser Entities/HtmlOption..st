Class {
	#name : #HtmlOption,
	#superclass : #HtmlFormEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #testing }
HtmlOption >> isOption [
	^true
]

{ #category : #attributes }
HtmlOption >> label [
	"label to be displayed for this morph"
	^self getAttribute: 'label' ifAbsent: [self textualContents]
]

{ #category : #testing }
HtmlOption >> mayContain: anEntity [
	^anEntity isTextualEntity
]

{ #category : #testing }
HtmlOption >> tagName [
	^'option'
]

{ #category : #attributes }
HtmlOption >> value [
	"value to pass if this option is selected"
	^self getAttribute: 'value' default: '(unspecified)'
]
