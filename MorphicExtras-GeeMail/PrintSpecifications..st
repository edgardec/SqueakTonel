Class {
	#name : #PrintSpecifications,
	#superclass : #Object,
	#instVars : [
		'landscapeFlag',
		'drawAsBitmapFlag',
		'scaleToFitPage'
	],
	#classVars : [
		'DefaultSpecs'
	],
	#category : #'MorphicExtras-GeeMail'
}

{ #category : #accessing }
PrintSpecifications class >> defaultSpecs [

	DefaultSpecs ifNil: [DefaultSpecs := self new].
	^DefaultSpecs copy
]

{ #category : #accessing }
PrintSpecifications class >> defaultSpecs: aPrintSpecification [

	DefaultSpecs := aPrintSpecification
]

{ #category : #acccessing }
PrintSpecifications >> drawAsBitmapFlag [

	^drawAsBitmapFlag ifNil: [false]
]

{ #category : #acccessing }
PrintSpecifications >> drawAsBitmapFlag: aBoolean [

	drawAsBitmapFlag := aBoolean
]

{ #category : #'initialize-release' }
PrintSpecifications >> initialize [

	landscapeFlag := false.
	scaleToFitPage := false.
	drawAsBitmapFlag := false.

]

{ #category : #acccessing }
PrintSpecifications >> landscapeFlag [

	^landscapeFlag ifNil: [false]
]

{ #category : #acccessing }
PrintSpecifications >> landscapeFlag: aBoolean [

	landscapeFlag := aBoolean
]

{ #category : #acccessing }
PrintSpecifications >> scaleToFitPage [

	^scaleToFitPage ifNil: [false]
]

{ #category : #acccessing }
PrintSpecifications >> scaleToFitPage: aBoolean [

	scaleToFitPage := aBoolean
]
