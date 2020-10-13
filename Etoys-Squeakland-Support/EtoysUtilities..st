Class {
	#name : #EtoysUtilities,
	#superclass : #Object,
	#classVars : [
		'LoggedIn'
	],
	#category : #'Etoys-Squeakland-Support'
}

{ #category : #'as yet unclassified' }
EtoysUtilities class >> loggedIn [

	^ LoggedIn == true

]

{ #category : #'as yet unclassified' }
EtoysUtilities class >> loggedIn: aBoolean [

	LoggedIn := aBoolean.

]
