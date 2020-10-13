Class {
	#name : #HelpTopicListItemWrapperTest,
	#superclass : #TestCase,
	#category : #'HelpSystem-Tests-Core-UI'
}

{ #category : #accessing }
HelpTopicListItemWrapperTest >> defaultTestClass [ 
	^HelpTopicListItemWrapper 
	
]

{ #category : #tests }
HelpTopicListItemWrapperTest >> testDisplayLabel [
	|instance|
	instance := self defaultTestClass with: (HelpTopic named: 'My Topic').
	self assert: instance asString = 'My Topic'
	
]
