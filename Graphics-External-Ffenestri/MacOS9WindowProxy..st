Class {
	#name : #MacOS9WindowProxy,
	#superclass : #HostWindowProxy,
	#instVars : [
		'windowClass',
		'windowAttributes'
	],
	#category : #'Graphics-External-Ffenestri'
}

{ #category : #constants }
MacOS9WindowProxy class >> altDBoxProc [
	^3

]

{ #category : #constants }
MacOS9WindowProxy class >> closeBoxAttribute [
	^1
]

{ #category : #constants }
MacOS9WindowProxy class >> dBoxProc [
	^1
]

{ #category : #constants }
MacOS9WindowProxy class >> documentProc [
	^0
]

{ #category : #constants }
MacOS9WindowProxy class >> documentWindowClass [
	^self zoomDocProc
]

{ #category : #constants }
MacOS9WindowProxy class >> floatGrowProc [
	^1987

]

{ #category : #constants }
MacOS9WindowProxy class >> floatProc [
	^1985

]

{ #category : #constants }
MacOS9WindowProxy class >> floatSideGrowProc [
	^1995

]

{ #category : #constants }
MacOS9WindowProxy class >> floatSideProc [
	^1993

]

{ #category : #constants }
MacOS9WindowProxy class >> floatSideZoomGrowProc [
	^1999
]

{ #category : #constants }
MacOS9WindowProxy class >> floatSideZoomProc [
	^1997
]

{ #category : #constants }
MacOS9WindowProxy class >> floatZoomGrowProc [
	^1991

]

{ #category : #constants }
MacOS9WindowProxy class >> floatZoomProc [
	^1989

]

{ #category : #'system startup' }
MacOS9WindowProxy class >> isActiveHostWindowProxyClass [
"Am I active?"
	^Smalltalk platformName  = 'Mac OS' and: [Smalltalk osVersion asInteger < 1000]
]

{ #category : #constants }
MacOS9WindowProxy class >> movableDBoxProc [
	^5

]

{ #category : #constants }
MacOS9WindowProxy class >> noAttributes [
	^0
]

{ #category : #constants }
MacOS9WindowProxy class >> noGrowDocProc [
	^4

]

{ #category : #constants }
MacOS9WindowProxy class >> plainDBox [
	^2
]

{ #category : #constants }
MacOS9WindowProxy class >> rDocProc [
	^16

]

{ #category : #constants }
MacOS9WindowProxy class >> standardDocumentAttributes [ 
	^self closeBoxAttribute
]

{ #category : #constants }
MacOS9WindowProxy class >> zoomDocProc [
	^8
]

{ #category : #constants }
MacOS9WindowProxy class >> zoomNoGrow [
	^12

]

{ #category : #accessing }
MacOS9WindowProxy >> attributes [
	| val |
	val := ByteArray new: 8.
	val 
		unsignedLongAt: 1
		put: windowClass
		bigEndian: Smalltalk isBigEndian.
	val 
		unsignedLongAt: 5
		put: windowAttributes
		bigEndian: Smalltalk isBigEndian.
	^ val
]

{ #category : #metrics }
MacOS9WindowProxy >> defaultWindowType [
	self windowClass: self class documentWindowClass.
	self windowAttributes: self class standardDocumentAttributes.
]

{ #category : #accessing }
MacOS9WindowProxy >> windowAttributes [
	^windowAttributes

]

{ #category : #accessing }
MacOS9WindowProxy >> windowAttributes: aNumber [
	windowAttributes := aNumber
]

{ #category : #accessing }
MacOS9WindowProxy >> windowClass [
	^windowClass

]

{ #category : #accessing }
MacOS9WindowProxy >> windowClass: aNumber [
	windowClass := aNumber
]
