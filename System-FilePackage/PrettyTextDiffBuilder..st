"
I'm like TextDiffBuilder, but I use the pretty-printed version of the source code if available.

Instance Variables
	sourceClass:		<Class>

sourceClass
	- this class provides the pretty-printer

"
Class {
	#name : #PrettyTextDiffBuilder,
	#superclass : #TextDiffBuilder,
	#instVars : [
		'sourceClass'
	],
	#category : #'System-FilePackage'
}

{ #category : #'instance creation' }
PrettyTextDiffBuilder class >> from: srcString to: dstString inClass: srcClass [ 
	^ (self new sourceClass: srcClass) from: srcString to: dstString
		
]

{ #category : #initialize }
PrettyTextDiffBuilder >> sourceClass: aClass [
	sourceClass := aClass.
]

{ #category : #private }
PrettyTextDiffBuilder >> split: aString [

	| formatted |
	aString ifEmpty: [ ^super split: aString ].
	formatted := [
		sourceClass prettyPrinterClass
			format: aString
			in: sourceClass
			notifying: nil
			decorated: false ] 
				on: Error
				do: [ :ex | aString ].
	^super split: formatted
]
