Class {
	#name : #HelpTopicTest,
	#superclass : #TestCase,
	#instVars : [
		'topic'
	],
	#category : #'HelpSystem-Tests-Core-Model'
}

{ #category : #accessing }
HelpTopicTest >> defaultTestClass [
	^HelpTopic 
]

{ #category : #running }
HelpTopicTest >> setUp [
	super setUp.
	topic := self defaultTestClass new.
]

{ #category : #tests }
HelpTopicTest >> testAddingSubtopic [

	|subtopic returned|
	subtopic := self defaultTestClass named: 'Subtopic'.
	returned := topic addSubtopic: subtopic.
	self assert: returned == subtopic.
	self assert: (topic subtopics includes: subtopic) 
]

{ #category : #tests }
HelpTopicTest >> testInitialization [

	self assert: topic title = 'Unnamed Topic'.
	self assert: topic contents isEmpty 
]

{ #category : #tests }
HelpTopicTest >> testInstanceCreation [

	|instance|
	instance := self defaultTestClass named: 'My Topic'.
	self assert: instance title = 'My Topic'.

]

{ #category : #tests }
HelpTopicTest >> testSortOrder [

	|a b c sorted |
	a := self defaultTestClass named: 'A'.
	b := self defaultTestClass named: 'B'.
	c := self defaultTestClass named: 'C'.
	sorted := (OrderedCollection with: b with: c with: a) sort.
	self assert: sorted first = a.
	self assert: sorted last = c.
	
]
