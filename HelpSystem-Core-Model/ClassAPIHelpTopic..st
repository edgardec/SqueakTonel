"
Show comments of a class, their subclasses and methods.
"
Class {
	#name : #ClassAPIHelpTopic,
	#superclass : #AbstractHelpTopic,
	#instVars : [
		'theClass',
		'withSubclasses',
		'withMethods',
		'subclassesAsSeparateTopic'
	],
	#category : #'HelpSystem-Core-Model'
}

{ #category : #accessing }
ClassAPIHelpTopic >> contents [

	^ self theClass instanceSide organization classComment
]

{ #category : #accessing }
ClassAPIHelpTopic >> icon [

	^ ToolIcons iconNamed: (ToolIcons iconForClass: self theClass name)
]

{ #category : #accessing }
ClassAPIHelpTopic >> subclassesAsSeparateTopic [

	^ subclassesAsSeparateTopic
]

{ #category : #accessing }
ClassAPIHelpTopic >> subclassesAsSeparateTopic: aBoolean [

	subclassesAsSeparateTopic := aBoolean.
]

{ #category : #accessing }
ClassAPIHelpTopic >> subtopics [
	
	^ (self withMethods ifFalse: [#()] ifTrue: [ {
		MethodListHelpTopic new theClass: self theClass theNonMetaClass.
		MethodListHelpTopic new theClass: self theClass theMetaClass }]),

	(self withSubclasses ifFalse: [#()] ifTrue: [
		| topics |
		topics := self theClass subclasses collect: [:cls |
			self class new
				theClass: cls;
				subclassesAsSeparateTopic: self subclassesAsSeparateTopic;
				withMethods: self withMethods;
				withSubclasses: self withSubclasses].

		self subclassesAsSeparateTopic
			ifTrue: [{(HelpTopic named: 'Subclasses')
				subtopics: topics;
				yourself}]
			ifFalse: [topics]])
]

{ #category : #accessing }
ClassAPIHelpTopic >> theClass [

	^ theClass
]

{ #category : #accessing }
ClassAPIHelpTopic >> theClass: aClassDescription [

	theClass := aClassDescription.
]

{ #category : #accessing }
ClassAPIHelpTopic >> title [

	^ self theClass name
]

{ #category : #accessing }
ClassAPIHelpTopic >> withMethods [

	^ withMethods ifNil:[false]
]

{ #category : #accessing }
ClassAPIHelpTopic >> withMethods: aBoolean [

	withMethods := aBoolean.
]

{ #category : #accessing }
ClassAPIHelpTopic >> withSubclasses [

	^ withSubclasses  ifNil:[false]
]

{ #category : #accessing }
ClassAPIHelpTopic >> withSubclasses: aBoolean [

	withSubclasses := aBoolean.
]
