Class {
	#name : #WebServerReference,
	#superclass : #WebServerHelp,
	#category : #'WebClient-Help'
}

{ #category : #accessing }
WebServerReference class >> asHelpTopic [

	^ (HelpTopic named: self bookName)
		subtopics: (self packages collect: [:pkgName | PackageAPIHelpTopic new packageName: pkgName]);
		yourself
]

{ #category : #accessing }
WebServerReference class >> bookName [
	^'Reference'
]

{ #category : #accessing }
WebServerReference class >> builder [
	^PackageAPIHelpBuilder
]

{ #category : #accessing }
WebServerReference class >> packages [
	^#('WebClient-Core')
]
