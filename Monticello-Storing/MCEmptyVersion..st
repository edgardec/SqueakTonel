Class {
	#name : #MCEmptyVersion,
	#superclass : #Warning,
	#category : #'Monticello-Storing'
}

{ #category : #exceptionInstantiator }
MCEmptyVersion class >> signal [

	self signal: 'About to serialize an empty mcz version.'
]
