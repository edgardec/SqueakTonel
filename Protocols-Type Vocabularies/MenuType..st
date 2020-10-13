"
A type associated with menu-item values.  An imperfect thing thus far, only usable in the doMenuItem etoy scripting phrase.
"
Class {
	#name : #MenuType,
	#superclass : #DataType,
	#category : #'Protocols-Type Vocabularies'
}

{ #category : #initialization }
MenuType >> initialize [
	"Initialize the receiver (automatically called when instances are created via 'new')"

	super initialize.
	self vocabularyName: #Menu
]

{ #category : #tiles }
MenuType >> representsAType [
	"Answer whether this vocabulary represents an end-user-sensible data type"

	^false
]
