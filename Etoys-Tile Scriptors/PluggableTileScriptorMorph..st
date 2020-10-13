Class {
	#name : #PluggableTileScriptorMorph,
	#superclass : #TwoWayScrollPane,
	#category : #'Etoys-Tile Scriptors'
}

{ #category : #'event handling' }
PluggableTileScriptorMorph >> keyStroke: evt [
	"A keystroke was hit while the receiver had keyboard focus.  Pass the keystroke on to my syntaxMorph, and also, if I have an event handler, pass it on to that handler"


	| sm |
	(sm := self syntaxMorph) ifNotNil: [sm keyStroke: evt].
	super keyStroke: evt
]

{ #category : #'as yet unclassified' }
PluggableTileScriptorMorph >> syntaxMorph [
	"Return the SyntaxMorph(MethodNode) that is inside me."

	| tm |
	^ (tm := self findA: TransformMorph) ifNotNil: [tm findA: SyntaxMorph]
]

{ #category : #updating }
PluggableTileScriptorMorph >> update: aSymbol [
	"Update the receiver in the manner suggested by aSymbol"

	aSymbol == #flash ifTrue: [^ self flash].

]
