Class {
	#name : #ScriptEditorMorphBuilder,
	#superclass : #Object,
	#instVars : [
		'context',
		'playerScripted',
		'topEditor'
	],
	#category : #'Etoys-Squeakland-Etoys-Scripting'
}

{ #category : #'as yet unclassified' }
ScriptEditorMorphBuilder class >> context: c playerScripted: p topEditor: t [

	^ self new context: c playerScripted: p topEditor: t

]

{ #category : #initialization }
ScriptEditorMorphBuilder >> context: c playerScripted: p [

	context := c.
	playerScripted := p.

]

{ #category : #initialization }
ScriptEditorMorphBuilder >> context: c playerScripted: p topEditor: t [

	context := c.
	playerScripted := p.
	topEditor := t.

]

{ #category : #initialization }
ScriptEditorMorphBuilder >> fromSexp: sexp [

	^ self perform: (sexp keyword copyWith: $:) asSymbol with: sexp.

]

{ #category : #'e-toy support' }
ScriptEditorMorphBuilder >> topEditor [

	^ topEditor.

]
