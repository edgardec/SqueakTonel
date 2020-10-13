Class {
	#name : #HtmlForm,
	#superclass : #HtmlEntity,
	#instVars : [
		'formEntities'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlForm >> addToFormatter: formatter [
	formatter startForm: self.
	super addToFormatter: formatter.
	formatter currentFormData reset.
	formatter endForm.
]

{ #category : #attributes }
HtmlForm >> encoding [
	"encoding for posting"
	^self getAttribute: 'enctype' default: nil.  
]

{ #category : #access }
HtmlForm >> formEntities [
	^formEntities
]

{ #category : #testing }
HtmlForm >> isBlockElement [
	^true
]

{ #category : #testing }
HtmlForm >> mayContain: anEntity [
	"allow anything.  People probably always put </form> anyway at the end of their forms.  And furthermore, it has no effect on the display, even if this is gotten wrong"
	^true
]

{ #category : #attributes }
HtmlForm >> method [
	"method to submit with"
	^self getAttribute: 'method' default: 'get'
]

{ #category : #parsing }
HtmlForm >> parsingFinished [
	"figure out who our constituents are"

	self allSubentitiesDo: [ :e |
		e isFormEntity ifTrue: [ e form: self ] ].
	super parsingFinished.
	formEntities := OrderedCollection new.
	self allSubentitiesDo: [ :e |
		(e isFormEntity and: [ e form == self ])
			ifTrue: [ formEntities add: e ] ].
]

{ #category : #testing }
HtmlForm >> tagName [
	^'form'
]

{ #category : #attributes }
HtmlForm >> url [
	"url to submit to"
	^self getAttribute: 'action' default: nil.  
]
