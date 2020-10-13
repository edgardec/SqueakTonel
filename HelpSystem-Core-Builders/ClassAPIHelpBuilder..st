"
A builder to build the API Help for a class

Instance Variables
	addMethods:		<Boolean>
	addSubclasses:		<Boolean>
	subclassesAsSeparateTopic:		<Boolean>

addMethods
	- When true the builder will include method help

addSubclasses
	- When true the builder will recursively go through and add subclasses

subclassesAsSeparateTopic
	- xxxxx

"
Class {
	#name : #ClassAPIHelpBuilder,
	#superclass : #HelpBuilder,
	#instVars : [
		'addSubclasses',
		'addMethods',
		'subclassesAsSeparateTopic'
	],
	#category : #'HelpSystem-Core-Builders'
}

{ #category : #building }
ClassAPIHelpBuilder class >> buildHierarchicalHelpTopicFrom: aClass withSubclasses: aBoolean withMethods: anotherBoolean [
	"Start building from the given class"
	
	^(self new)
		addSubclasses: aBoolean;
		addMethods: anotherBoolean;
		rootToBuildFrom: aClass;
		build;
		topicToBuild 
]

{ #category : #accessing }
ClassAPIHelpBuilder >> addMethods [
	^ addMethods
]

{ #category : #accessing }
ClassAPIHelpBuilder >> addMethods: anObject [
	addMethods := anObject
]

{ #category : #accessing }
ClassAPIHelpBuilder >> addSubclasses [
	^ addSubclasses
]

{ #category : #accessing }
ClassAPIHelpBuilder >> addSubclasses: anObject [
	addSubclasses := anObject
]

{ #category : #building }
ClassAPIHelpBuilder >> build [

	CurrentReadOnlySourceFiles cacheDuring: [
		topicToBuild := (HelpTopic named: rootToBuildFrom name).
		topicToBuild icon: (HelpIcons iconNamed: #pageIcon).
		topicToBuild contents: rootToBuildFrom comment.
	
		addMethods ifTrue: [ self buildSubnodesForMethods ].
		addSubclasses	 ifTrue: [ self buildSubnodesForSubclasses ] ].
	 
]

{ #category : #'private building' }
ClassAPIHelpBuilder >> buildMethodTopicsOn: topic for: aClass [
	
	topic contents: (MethodListHelpTopic forClass: aClass) contents
]

{ #category : #'private building' }
ClassAPIHelpBuilder >> buildSubclassTopicFor: aSubclass [
	 
	^(self class new) 
			rootToBuildFrom: aSubclass;
			addSubclasses: addSubclasses;
			addMethods: addMethods;
			subclassesAsSeparateTopic: subclassesAsSeparateTopic;
			build;
			topicToBuild 
	 
]

{ #category : #'private building' }
ClassAPIHelpBuilder >> buildSubnodesForMethods [

	| instanceSide classSide |
	instanceSide := HelpTopic named: 'Instance side'.
	classSide := HelpTopic named: 'Class side'.
	topicToBuild icon: (HelpIcons iconNamed: #bookIcon).
	topicToBuild 
		addSubtopic: instanceSide;
		addSubtopic: classSide.
	self buildMethodTopicsOn: instanceSide for: rootToBuildFrom.	
	self buildMethodTopicsOn: classSide for: rootToBuildFrom class.	
]

{ #category : #'private building' }
ClassAPIHelpBuilder >> buildSubnodesForSubclasses [

	| topic |
	rootToBuildFrom subclasses isEmpty ifTrue: [^self].
	topicToBuild icon: (HelpIcons iconNamed: #bookIcon).
	topic := subclassesAsSeparateTopic 
				ifTrue: [topicToBuild addSubtopic: (HelpTopic named: 'Subclasses')]
				ifFalse: [topicToBuild ].
	rootToBuildFrom subclasses 
		do: [:subclass | topic addSubtopic: (self buildSubclassTopicFor: subclass)].
	topic sortSubtopicsByTitle.

	
]

{ #category : #'initialize-release' }
ClassAPIHelpBuilder >> initialize [
	"Initializes the receiver"
	
	super initialize.
	addSubclasses := false.
	addMethods := true.
	subclassesAsSeparateTopic := true.
]

{ #category : #accessing }
ClassAPIHelpBuilder >> subclassesAsSeparateTopic [
	^ subclassesAsSeparateTopic
]

{ #category : #accessing }
ClassAPIHelpBuilder >> subclassesAsSeparateTopic: anObject [
	subclassesAsSeparateTopic := anObject
]
