"
Signalled when ReadStream>>next encounters a premature end.
"
Class {
	#name : #EndOfStream,
	#superclass : #Error,
	#category : #'Collections-Exceptions'
}

{ #category : #handling }
EndOfStream >> defaultAction [
	"Answer ReadStream>>next default reply."

	^ nil
]

{ #category : #description }
EndOfStream >> isResumable [
	"EndOfStream is resumable, so ReadStream>>next can answer"

	^ true
]
