"
A Morph serving as the cursor on an EventTimeline in an EventRoll.
At present, there is no real benefit to having a separate class for the cursor, since it has no unique behavior yet.   However, in the future we may wish for the cursor to be more dynamic, and this gives us a way in for doing things like that.
"
Class {
	#name : #EventRollCursor,
	#superclass : #Morph,
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #initialization }
EventRollCursor >> initialize [
	"Initialize the receiver."

	super initialize.
	self color: Color red.
	self width: 1.
	self beSticky
]
