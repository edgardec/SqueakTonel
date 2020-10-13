Class {
	#name : #ViewerRow,
	#superclass : #AlignmentMorph,
	#instVars : [
		'elementSymbol'
	],
	#category : #'Etoys-Squeakland-Etoys-Scripting Tiles'
}

{ #category : #access }
ViewerRow >> elementSymbol [
	^ elementSymbol
]

{ #category : #access }
ViewerRow >> elementSymbol: aSymbol [
	elementSymbol := aSymbol
]

{ #category : #access }
ViewerRow >> entryType [
	"Answer one of: #systemSlot #userSlot #systemScript #userScript"

	^ self playerBearingCode elementTypeFor: elementSymbol vocabulary: self currentVocabulary
]

{ #category : #initialization }
ViewerRow >> initialize [
	super initialize.
	self layoutInset: 1
]

{ #category : #access }
ViewerRow >> playerBearingCode [
	^ owner playerBearingCode
]
