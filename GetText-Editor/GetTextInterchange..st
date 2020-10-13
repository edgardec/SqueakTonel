Class {
	#name : #GetTextInterchange,
	#superclass : #Object,
	#instVars : [
		'language',
		'stream'
	],
	#category : #'GetText-Editor'
}

{ #category : #private }
GetTextInterchange >> defaultFileName [
	^ language localeID posixName , '.po'
]

{ #category : #accessing }
GetTextInterchange >> language: translator [
	language := translator
]

{ #category : #accessing }
GetTextInterchange >> stream [
	^ stream
]

{ #category : #accessing }
GetTextInterchange >> stream: aStream [
	stream := aStream
]
