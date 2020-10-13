Class {
	#name : #WebClientReference,
	#superclass : #WebClientHelp,
	#category : #'WebClient-Help'
}

{ #category : #accessing }
WebClientReference class >> asHelpTopic [

	^ (HelpTopic named: self bookName)
		subtopics: (self packages collect: [:pkgName | PackageAPIHelpTopic new packageName: pkgName]);
		yourself
]

{ #category : #accessing }
WebClientReference class >> bookName [
	^'Reference'
]

{ #category : #accessing }
WebClientReference class >> builder [
	^PackageAPIHelpBuilder
]

{ #category : #accessing }
WebClientReference class >> packages [
	^#('WebClient-Core')
]
