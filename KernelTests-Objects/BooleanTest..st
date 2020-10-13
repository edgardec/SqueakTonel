"
This is the unit test for the class Boolean. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category

"
Class {
	#name : #BooleanTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Objects'
}

{ #category : #tests }
BooleanTest >> testBooleanInitializedInstance [

	self assert: (Boolean initializedInstance = nil).
]

{ #category : #tests }
BooleanTest >> testBooleanNew [

	self should: [Boolean new] raise: TestResult error. 
	self should: [True new] raise: TestResult error. 
	self should: [False new] raise: TestResult error. 
]

{ #category : #tests }
BooleanTest >> testNew [

	self should: [Boolean new] raise: TestResult error. 
]
