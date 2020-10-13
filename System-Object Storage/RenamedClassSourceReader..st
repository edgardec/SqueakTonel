Class {
	#name : #RenamedClassSourceReader,
	#superclass : #ClassCategoryReader,
	#category : #'System-Object Storage'
}

{ #category : #'instance creation' }
RenamedClassSourceReader class >> formerClassName: formerClassName methodsFor: aCategory stamp: aString [

	^self new
		setClass: formerClassName 
		category: aCategory 
		changeStamp: aString
]

{ #category : #'instance creation' }
RenamedClassSourceReader class >> scanner [

	^self new
]

{ #category : #'fileIn\/Out' }
RenamedClassSourceReader >> scanFrom: aStream [

	self flag: #bob. 	"should this ever happen?"
	self halt.
]

{ #category : #'fileIn\/Out' }
RenamedClassSourceReader >> scanFromNoCompile: aStream [

	self flag: #bob. 	"should this ever happen?"
	self halt.
]

{ #category : #'fileIn\/Out' }
RenamedClassSourceReader >> scanFromNoCompile: aStream forSegment: anImageSegment [
	"Just move the source code for the methods from aStream."
	| methodText d |

	[
		(methodText := aStream nextChunkText) size > 0
	] whileTrue: [
		(SourceFiles at: 2) ifNotNil: [
			d := Dictionary new.
			d
				at: #oldClassName put: class;		"may be 'Player1' or 'Player1 class'"
				at: #methodText put: methodText;
				at: #changeStamp put: changeStamp;
				at: #category put: category.
			anImageSegment acceptSingleMethodSource: d.
		]
	]
]
