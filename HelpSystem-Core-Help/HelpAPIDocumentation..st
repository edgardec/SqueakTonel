"
This class represents the browsable package API help for the help system.

Instance Variables

"
Class {
	#name : #HelpAPIDocumentation,
	#superclass : #HelpOnHelp,
	#category : #'HelpSystem-Core-Help'
}

{ #category : #defaults }
HelpAPIDocumentation class >> asHelpTopic [

	^ (HelpTopic named: self bookName)
		subtopics: (self packages collect: [:pkgName | PackageAPIHelpTopic new packageName: pkgName]);
		yourself
]

{ #category : #accessing }
HelpAPIDocumentation class >> bookName [
	^'API Documentation'
]

{ #category : #accessing }
HelpAPIDocumentation class >> packages [
	^#('HelpSystem-Core-Model' 'HelpSystem-Core-Utilities' 'HelpSystem-Core-UI')
]
