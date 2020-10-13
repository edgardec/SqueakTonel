Class {
	#name : #MCEmptyDiffyVersion,
	#superclass : #MCEmptyVersion,
	#category : #'Monticello-Storing'
}

{ #category : #exceptionInstantiator }
MCEmptyDiffyVersion class >> signal [

	self signal: 'About to serialize an empty diffy version.' 
]
