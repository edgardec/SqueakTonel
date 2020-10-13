Class {
	#name : #SugarTube,
	#superclass : #Object,
	#instVars : [
		'id',
		'service',
		'buddy',
		'address'
	],
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #accessing }
SugarTube >> address [
	^ address
]

{ #category : #accessing }
SugarTube >> address: aString [
	address := aString
]

{ #category : #accessing }
SugarTube >> buddy [
	buddy isString ifTrue: [
		buddy := SugarLauncher current buddies at: buddy].
	^ buddy
]

{ #category : #accessing }
SugarTube >> buddy: aBuddy [
	buddy := aBuddy
]

{ #category : #accessing }
SugarTube >> id [
	^ id
]

{ #category : #accessing }
SugarTube >> id: anInteger [
	id := anInteger
]

{ #category : #accessing }
SugarTube >> service [
	^ service
]

{ #category : #accessing }
SugarTube >> service: aString [
	service := aString
]
