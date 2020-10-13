Class {
	#name : #XTableForFixedFont,
	#superclass : #Object,
	#instVars : [
		'width',
		'maxCode'
	],
	#category : #'Multilingual-Display'
}

{ #category : #accessing }
XTableForFixedFont >> at: anInteger [

	(anInteger < 1 or: [maxCode + 2 < anInteger]) ifTrue: [
		self error: 'subscript out of bounds'.
	].
	^(anInteger - 1) * width.

]

{ #category : #accessing }
XTableForFixedFont >> maxAscii: anInteger [

	maxCode := anInteger.

]

{ #category : #accessing }
XTableForFixedFont >> maxCode [

	^ maxCode.

]

{ #category : #accessing }
XTableForFixedFont >> size [

	^ maxCode.

]

{ #category : #accessing }
XTableForFixedFont >> width [

	^ width.

]

{ #category : #accessing }
XTableForFixedFont >> width: anInteger [

	width := anInteger.

]
