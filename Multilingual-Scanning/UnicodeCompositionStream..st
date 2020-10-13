Class {
	#name : #UnicodeCompositionStream,
	#superclass : #WriteStream,
	#instVars : [
		'combinedChar'
	],
	#category : #'Multilingual-Scanning'
}

{ #category : #accessing }
UnicodeCompositionStream >> contents [

	(self isCombining) ifTrue: [^ super contents copyWith: combinedChar combined].
	^ super contents.

]

{ #category : #testing }
UnicodeCompositionStream >> isCombining [

	^ combinedChar ~~ nil

]

{ #category : #accessing }
UnicodeCompositionStream >> nextPut: anObject [

	self isCombining ifFalse: [
		combinedChar := CombinedChar new.
		combinedChar simpleAdd: anObject.
	] ifTrue: [
		(combinedChar simpleAdd: anObject) ifFalse: [
			super nextPut: combinedChar combined.
			combinedChar := CombinedChar new.
			combinedChar simpleAdd: anObject.
		]
	].
	^anObject

]

{ #category : #accessing }
UnicodeCompositionStream >> nextPutAll: aCollection [

	^aCollection do: [:e | self nextPut: e].

]
