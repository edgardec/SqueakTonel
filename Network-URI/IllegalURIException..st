Class {
	#name : #IllegalURIException,
	#superclass : #Error,
	#instVars : [
		'uriString'
	],
	#category : #'Network-URI'
}

{ #category : #accessing }
IllegalURIException >> uriString [
	^uriString
]

{ #category : #accessing }
IllegalURIException >> uriString: aString [
	uriString := aString
]
