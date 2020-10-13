"
A HelpTopic provides content information that can be used as a help to the user.
It can be labeled with a title and marked with an (optional) icon.

Help topics form a hierarchy since any topic is able to have zero or more
subtopics. 
"
Class {
	#name : #AbstractHelpTopic,
	#superclass : #Model,
	#category : #'HelpSystem-Core-Model'
}

{ #category : #comparing }
AbstractHelpTopic >> <= anotherHelpTopic [

	"Priority-based: ... -3 -2 -1 nil nil nil 1 2 3 4 ..."
	(self priority notNil and: [anotherHelpTopic priority notNil])
		ifTrue: [^ self priority <= anotherHelpTopic priority].

	(self priority notNil and: [anotherHelpTopic priority isNil])
		ifTrue: [^ self priority <= 0].

	(self priority isNil and: [anotherHelpTopic priority notNil])
		ifTrue: [^ anotherHelpTopic priority >= 0].

	"Fall-back."
	^ self title <= anotherHelpTopic title
]

{ #category : #editing }
AbstractHelpTopic >> accept: newContents for: subtopic [
	"If this topic is editable, this will be the callback to update its contents."
]

{ #category : #conversion }
AbstractHelpTopic >> asHelpTopic [

	^ self
]

{ #category : #accessing }
AbstractHelpTopic >> contents [
	"Return the text contents of this topic."
	
	self subclassResponsibility.
]

{ #category : #testing }
AbstractHelpTopic >> hasSubtopics [

	^ self subtopics notEmpty
]

{ #category : #accessing }
AbstractHelpTopic >> icon [
	"Returns a descriptive form to support manual detection in a list of topics. Icons may encode the kind of topic."
	
	^ nil
]

{ #category : #testing }
AbstractHelpTopic >> isEditable [

	^ false
]

{ #category : #testing }
AbstractHelpTopic >> isSearchable [

	^ true
]

{ #category : #accessing }
AbstractHelpTopic >> key [
	^ nil
]

{ #category : #printing }
AbstractHelpTopic >> printOn: stream [

	| title |
	super printOn: stream.
	(title := self title) notNil 
		ifTrue: [stream nextPutAll: '<' , title , '>'].
]

{ #category : #accessing }
AbstractHelpTopic >> priority [

	^ nil
]

{ #category : #accessing }
AbstractHelpTopic >> priorityForSearch [

	^ 0
]

{ #category : #updating }
AbstractHelpTopic >> refresh [
	"Do nothing."
]

{ #category : #accessing }
AbstractHelpTopic >> subtopics [
	"Topics can be nested in a tree structure."

	^ #()
]

{ #category : #accessing }
AbstractHelpTopic >> title [
	"A brief description of this topic's contents."

	^ self contents truncateWithElipsisTo: 20
]

{ #category : #testing }
AbstractHelpTopic >> usesCodeStyling [
	"do I need a styled (ie with Shout) browser page?"
	^false
]
