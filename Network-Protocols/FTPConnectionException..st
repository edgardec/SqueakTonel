Class {
	#name : #FTPConnectionException,
	#superclass : #Error,
	#category : #'Network-Protocols'
}

{ #category : #handling }
FTPConnectionException >> defaultAction [

	self resume
]

{ #category : #handling }
FTPConnectionException >> isResumable [

	^true
]
