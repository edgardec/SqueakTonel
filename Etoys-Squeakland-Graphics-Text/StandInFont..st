Class {
	#name : #StandInFont,
	#superclass : #AbstractFont,
	#instVars : [
		'familyName',
		'pointSize',
		'emphasis'
	],
	#category : #'Etoys-Squeakland-Graphics-Text'
}

{ #category : #'as yet unclassified' }
StandInFont >> ascent [

	| threeQ |
	threeQ := pointSize * 3 // 4.
	^ threeQ.

]

{ #category : #'as yet unclassified' }
StandInFont >> descent [

	| threeQ |
	threeQ := pointSize * 3 // 4.
	^ pointSize - threeQ.

]

{ #category : #'as yet unclassified' }
StandInFont >> emphasis [

	^ emphasis
]

{ #category : #'as yet unclassified' }
StandInFont >> emphasized: code [

	^ TextStyle defaultFont emphasized: code.

]

{ #category : #'as yet unclassified' }
StandInFont >> familyName [

	^ familyName
]

{ #category : #'as yet unclassified' }
StandInFont >> familyName: aString pointSize: aNumber emphasized: emph [

	familyName := aString.
	pointSize := aNumber.
	emphasis := emph.

]

{ #category : #'as yet unclassified' }
StandInFont >> height [

	^ pointSize.

]

{ #category : #'as yet unclassified' }
StandInFont >> pointSize [

	^ pointSize
]
