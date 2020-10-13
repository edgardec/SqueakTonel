Class {
	#name : #TextSqkProjectLink,
	#superclass : #TextURL,
	#category : #'System-Support'
}

{ #category : #'fileIn\/Out' }
TextSqkProjectLink class >> scanCharacter [
	"The character used to identify a subclass of TextAttribute for filein and fileout"
	^$p
]

{ #category : #'mouse events' }
TextSqkProjectLink >> actOnClickFor: textMorph [

	Project current enterIfThereOrFind: url.
	^ true
]

{ #category : #'initialize-release' }
TextSqkProjectLink >> analyze: aString [

	^url := aString
]

{ #category : #'fileIn\/fileOut' }
TextSqkProjectLink >> writeScanOn: strm [

	strm nextPut: $p; nextPutAll: url; nextPut: $;
]
