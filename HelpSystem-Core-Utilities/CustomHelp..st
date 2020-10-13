"
This is a common superclass for custom help. Subclasses of this class are automatically included into the system help.

By default the informations provided on the receiver class are converted into help topics by a specific builder 
- here the CustomHelpHelpBuilder. Note that you can provide an own custom builder by overriding the #builder method


"
Class {
	#name : #CustomHelp,
	#superclass : #Object,
	#category : #'HelpSystem-Core-Utilities'
}

{ #category : #converting }
CustomHelp class >> asHelpTopic [
	"Convert the receiver to a help topic"
	
	^ ClassBasedHelpTopic new helpClass: self
]

{ #category : #accessing }
CustomHelp class >> bookName [
	"Returns the name of the custom help book"
	
	^'Help'
]

{ #category : #editing }
CustomHelp class >> edit: aSelector [

	(HelpBrowser openOn: self asHelpTopic) model showTopicNamed: aSelector..

]

{ #category : #accessing }
CustomHelp class >> icon [
	"Returns an icon used for displaying the custom help book"
	
	^HelpIcons iconNamed: #bookIcon
]

{ #category : #accessing }
CustomHelp class >> ignore [

	^ false
]

{ #category : #accessing }
CustomHelp class >> pages [ 
	"Returns a collection of method selectors to return the pages of the custom help book"
		
	^#()
]

{ #category : #accessing }
CustomHelp class >> priority [

	^ nil
]

{ #category : #testing }
CustomHelp class >> usesCodeStyling [
	"do I want pages styled for code; at some point it should be made possible for individual topics to make this choice and the help browser will do The Right Thing for each one"
		^false
]
