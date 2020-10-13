"
This builder builds help topics from a help topic description (which is typically stored
in a class). 

The help topic description object has to understand the following messages:

  #bookName - should return the name of the help book
  #icon - should return the icon of the help book
  #key - should return a unique key to identify the book
  #pages - should return an array of method selectors to call to get the books pages

"
Class {
	#name : #CustomHelpHelpBuilder,
	#superclass : #HelpBuilder,
	#category : #'HelpSystem-Core-Builders'
}

{ #category : #building }
CustomHelpHelpBuilder >> build [
	"Start building a help topic from a code description"
	
	topicToBuild := self createTopicFrom: rootToBuildFrom 

]

{ #category : #private }
CustomHelpHelpBuilder >> createTopicFrom: aDescription [
	"Create a help topic from a description provided by a class.
	aDescription must provide (via #pages) an ordered list of 
	 - selectors that return a HelpTopic,
	-  or the name of a class that must in turn provide help topics etc. This allows for hierarchies with 'subtrees in the middle'.
	The order of the pages reflects the order of the selectors and class names given"
	
	|topic page   pageClasses |
	topic := HelpTopic named: aDescription bookName.
	topic key: aDescription key.
	topic icon: aDescription icon.
	pageClasses := Set new.
	aDescription pages do: [:pageSelectorOrClass|
		page:= (Smalltalk hasClassNamed: pageSelectorOrClass asString)
					ifFalse: [aDescription perform: pageSelectorOrClass]
					ifTrue: [pageClasses add: (Smalltalk classNamed: pageSelectorOrClass asString).
							 (Smalltalk classNamed: pageSelectorOrClass asString) asHelpTopic].
		topic addSubtopic: page.
	].	
	((aDescription subclasses asSet)
		removeAllFoundIn: pageClasses;
		yourself) do: [:subclass | topic subtopics add: subclass asHelpTopic ].
	^topic
]
