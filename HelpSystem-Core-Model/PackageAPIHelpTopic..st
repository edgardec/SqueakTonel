"
List all classes and their method comments. No subclasses.
"
Class {
	#name : #PackageAPIHelpTopic,
	#superclass : #AbstractHelpTopic,
	#instVars : [
		'packageName'
	],
	#category : #'HelpSystem-Core-Model'
}

{ #category : #accessing }
PackageAPIHelpTopic >> contents [

	^ ''
]

{ #category : #testing }
PackageAPIHelpTopic >> hasSubtopics [

	^ SystemOrganization categories anySatisfy: [:cat |
		(cat beginsWith: self packageName) and: [(SystemOrganization listAtCategoryNamed: cat) notEmpty]]
]

{ #category : #accessing }
PackageAPIHelpTopic >> packageName [

	^ packageName
]

{ #category : #accessing }
PackageAPIHelpTopic >> packageName: aString [

	packageName := aString.
]

{ #category : #accessing }
PackageAPIHelpTopic >> subtopics [
	"Watch out for not registering PackageInfo by accident. Still, you can use any system category prefix and PackageInfo will help you find the corresponding classes."
	
	^ ((PackageInfo new packageName: self packageName) classes
		sorted: [:cl1 :cl2 | cl1 name < cl2 name])
		collect: [:class | ClassAPIHelpTopic new
			theClass: class;
			withSubclasses: false;
			withMethods: true]
]

{ #category : #accessing }
PackageAPIHelpTopic >> title [

	^ self packageName
]
