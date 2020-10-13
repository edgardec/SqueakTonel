"
An object description, for use with the ObjectsTool and other parts-bin-like repositories.

formalName				The formal name by which the object is to be known 
categoryList				A list of category symbols, by way of attribute tags
documentation			For use in balloon help, etc.
globalReceiverSymbol	A symbol representing the global to whom to send nativitySelector 
nativitySelector 		The selector to send to the global receiver to obtain a new instance
"
Class {
	#name : #DescriptionForPartsBin,
	#superclass : #Object,
	#instVars : [
		'formalName',
		'categoryList',
		'documentation',
		'globalReceiverSymbol',
		'nativitySelector',
		'sampleImageForm'
	],
	#category : #'MorphicExtras-PartsBin'
}

{ #category : #'instance creation' }
DescriptionForPartsBin class >> formalName: aName categoryList: aList documentation: aDoc globalReceiverSymbol: aSym nativitySelector: aSel [
	"Answer a new instance of the receiver with the given traits"

	^ self new formalName: aName categoryList: aList documentation: aDoc globalReceiverSymbol: aSym nativitySelector: aSel
]

{ #category : #'instance creation' }
DescriptionForPartsBin class >> fromQuad: aQuad categoryList: aList [
	"Answer an instance of DescriptionForPartsBin from the part-defining quad provided"

	^ self formalName: aQuad third categoryList: aList documentation: aQuad fourth globalReceiverSymbol: aQuad first nativitySelector: aQuad second
]

{ #category : #accessing }
DescriptionForPartsBin >> categories [
	"Answer the categoryList of the receiver"

	^ categoryList
]

{ #category : #accessing }
DescriptionForPartsBin >> documentation [
	"Answer the documentation of the receiver"

	^ documentation
]

{ #category : #accessing }
DescriptionForPartsBin >> formalName [
	"Answer the formalName of the receiver"

	^ formalName
]

{ #category : #initialization }
DescriptionForPartsBin >> formalName: aName categoryList: aList documentation: aDoc globalReceiverSymbol: aSym nativitySelector: aSel [
	"Set all of the receiver's instance variables from the parameters provided"

	formalName := aName.
	categoryList := aList.
	documentation := aDoc.
	globalReceiverSymbol := aSym.
	nativitySelector  := aSel
]

{ #category : #accessing }
DescriptionForPartsBin >> globalReceiverSymbol [
	"Answer the globalReceiverSymbol of the receiver"

	^ globalReceiverSymbol
]

{ #category : #accessing }
DescriptionForPartsBin >> nativitySelector [
	"Answer the nativitySelector of the receiver"

	^ nativitySelector
]

{ #category : #printing }
DescriptionForPartsBin >> printOn: aStream [
	aStream nextPutAll: 'a DescriptionForPartsBin, with categoryList=', categoryList asString, ' docmentation=', documentation asString,  ' globalReceiverSymbol=', globalReceiverSymbol asString, ' nativitySelector=', nativitySelector asString 
]

{ #category : #initialization }
DescriptionForPartsBin >> sampleImageForm [
	"If I have a sample image form override stored, answer it, else answer one obtained by launching an actual instance"

	^ sampleImageForm ifNil:
		[((Smalltalk at: globalReceiverSymbol) perform: nativitySelector) imageFormDepth: 32]
]

{ #category : #initialization }
DescriptionForPartsBin >> sampleImageForm: aForm [
	"Set the sample image form"

	sampleImageForm := aForm
]

{ #category : #initialization }
DescriptionForPartsBin >> sampleImageFormOrNil [
	"If I have a sample image form override stored, answer it, dlse answer nil"

	^ sampleImageForm 
]

{ #category : #accessing }
DescriptionForPartsBin >> translatedCategories [
	"Answer translated the categoryList of the receiver"
	^ self categories
		collect: [:each | each translated]
]
