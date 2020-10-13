"
I represent a mechanism for retrieving class descriptions stored on a file.
"
Class {
	#name : #ClassCategoryReader,
	#superclass : #Object,
	#instVars : [
		'class',
		'category',
		'changeStamp'
	],
	#category : #'Kernel-Classes'
}

{ #category : #'fileIn\/Out' }
ClassCategoryReader >> scanFrom: aStream [ 
	"File in methods from the stream, aStream."
	| methodText |
	[methodText := aStream nextChunkText.
	 methodText size > 0]
		whileTrue:
		[class compile: methodText classified: category
			withStamp: changeStamp notifying: nil]
]

{ #category : #'fileIn\/Out' }
ClassCategoryReader >> scanFrom: aStream environment: anEnvironment [
	"File in methods from the stream, aStream."
	| methodText |
	[methodText := aStream nextChunkText.
	 methodText size > 0] whileTrue:
		[class 
			compile: methodText 
			environment: anEnvironment
			classified: category
			withStamp: changeStamp 
			notifying: nil]
]

{ #category : #'fileIn\/Out' }
ClassCategoryReader >> scanFromNoCompile: aStream [ 
	"Just move the source code for the methods from aStream."
	| methodText selector |

	[methodText := aStream nextChunkText.
	 methodText size > 0]
		whileTrue:
		[(SourceFiles at: 2) ifNotNil: [
			selector := class newParser parseSelector: methodText.
			(class compiledMethodAt: selector) putSource: methodText 
				fromParseNode: nil class: class category: category
				withStamp: changeStamp inFile: 2 priorMethod: nil]]
]

{ #category : #'fileIn\/Out' }
ClassCategoryReader >> scanFromNoCompile: aStream forSegment: anImageSegment [

	^self scanFromNoCompile: aStream 	"subclasses may care about the segment"
]

{ #category : #private }
ClassCategoryReader >> setClass: aClass category: aCategory [
	^ self setClass: aClass category: aCategory changeStamp: String new

]

{ #category : #private }
ClassCategoryReader >> setClass: aClass category: aCategory changeStamp: aString [

	class := aClass.
	category := aCategory.
	changeStamp := aString

]

{ #category : #private }
ClassCategoryReader >> theClass [

	^ class
]
