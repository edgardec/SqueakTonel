Class {
	#name : #ClassAPIHelpBuilderTest,
	#superclass : #TestCase,
	#category : #'HelpSystem-Tests-Builders'
}

{ #category : #tests }
ClassAPIHelpBuilderTest >> testDefaultBuilding [
	|topic|
	topic := CurrentReadOnlySourceFiles cacheDuring: [
		ClassAPIHelpBuilder buildHelpTopicFrom: Integer ].
	self assert: topic subtopics size = 2.
	self assert: topic subtopics first title = 'Instance side'.
	self assert: topic subtopics last title = 'Class side'
 

 
]

{ #category : #tests }
ClassAPIHelpBuilderTest >> testMethodsButNoSubclasses [
	|topic|
	topic := CurrentReadOnlySourceFiles cacheDuring: [
		ClassAPIHelpBuilder 
			buildHierarchicalHelpTopicFrom: Integer 
			withSubclasses: false 
			withMethods: true ].
	self assert: topic subtopics size = 2.
	self assert: topic subtopics first title = 'Instance side'.
	self assert: topic subtopics last title = 'Class side'
 

 
]
