"
I'm like TextDiffBuilder, but I split the input text by my own set of separator characters (see #separatorSet), instead of new lines. I'm meant to create diffs of class definitions.
"
Class {
	#name : #ClassDiffBuilder,
	#superclass : #TextDiffBuilder,
	#classVars : [
		'SeparatorSet'
	],
	#category : #'System-FilePackage'
}

{ #category : #'initialize-release' }
ClassDiffBuilder class >> cleanUp: aggressive [

	SeparatorSet := nil
]

{ #category : #constants }
ClassDiffBuilder class >> separatorSet [

	^SeparatorSet ifNil: [
		SeparatorSet := CharacterSet separators copy
			add: $'; "for variables"
			add: $"; "for comments in mc"
			yourself ]
]

{ #category : #private }
ClassDiffBuilder >> print: aString withAttributes: attributes on: stream [

	stream
		currentAttributes: attributes;
		nextPutAll: aString
]

{ #category : #private }
ClassDiffBuilder >> split: aString [
	"I return an Array or DiffElements containing aString splitted by whitespace ' and ""."

	^Array streamContents: [ :stream |
		| input separators |
		input := aString readStream.
		separators := self class separatorSet.
		[ input atEnd ] whileFalse: [
			| word separator |
			word := input
				upToAnyOf: separators
				do: [ :matchingSeparator | separator := matchingSeparator ].
			stream nextPut: (DiffElement string: word).
			separator ifNotNil: [
				stream nextPut: (DiffElement string: separator asString) ] ] ]
]
