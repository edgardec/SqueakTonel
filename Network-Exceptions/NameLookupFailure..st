"
Signals that a name lookup operation failed.

	hostName	hostName for which the name loopup failed

"
Class {
	#name : #NameLookupFailure,
	#superclass : #NetworkError,
	#instVars : [
		'hostName'
	],
	#category : #'Network-Exceptions'
}

{ #category : #'instance creation' }
NameLookupFailure class >> hostName: aString [
	^ self new hostName: aString
]

{ #category : #handling }
NameLookupFailure >> defaultAction [
	"Backward compatibility"
	| response |
	response := (UIManager default  chooseFrom: #( 'Retry' 'Give Up')
			title: self messageText).
	^ response = 2
		ifFalse: [self retry]
]

{ #category : #accessing }
NameLookupFailure >> hostName [
	^ hostName
]

{ #category : #accessing }
NameLookupFailure >> hostName: aString [
	hostName := aString
]
