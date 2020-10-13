Class {
	#name : #EnvironmentsAPIDocumentation,
	#superclass : #EnvironmentsHelp,
	#category : #'Environments-Help'
}

{ #category : #converting }
EnvironmentsAPIDocumentation class >> asHelpTopic [

	^ (HelpTopic named: self bookName)
		subtopics: (self packages collect: [:pkgName | PackageAPIHelpTopic new packageName: pkgName]);
		yourself
]

{ #category : #accessing }
EnvironmentsAPIDocumentation class >> bookName [
	^'Reference'
]

{ #category : #private }
EnvironmentsAPIDocumentation class >> packages [
	^#('Environments-Core' 'Environments-Loading' 'Environments-Policies')
]
