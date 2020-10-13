"
The super swiki does not at present have subdirectories
"
Class {
	#name : #SuperSwikiDirectoryWrapper,
	#superclass : #FileDirectoryWrapper,
	#category : #'Morphic-Explorer'
}

{ #category : #accessing }
SuperSwikiDirectoryWrapper >> contents [

	^#()		"we have no sundirectories"
]

{ #category : #testing }
SuperSwikiDirectoryWrapper >> hasContents [

	^false		"we have no sundirectories"
]
