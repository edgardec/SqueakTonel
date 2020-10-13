"
I test the behavior of SimpleSwitchMorph
"
Class {
	#name : #SimpleSwitchMorphTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'testSwitch'
	],
	#category : #'MorphicTests-Widgets'
}

{ #category : #accessing }
SimpleSwitchMorphTest >> classToBeTested [
	^ SimpleSwitchMorph 
]

{ #category : #'initialize-release' }
SimpleSwitchMorphTest >> setUp [
	super setUp.
	testSwitch := SimpleSwitchMorph new
]

{ #category : #tests }
SimpleSwitchMorphTest >> testName [

	self assert: testSwitch externalName = 'SimpleSwitch'
]

{ #category : #tests }
SimpleSwitchMorphTest >> testState [
	self assert: testSwitch isOff.
	self deny: testSwitch isOn.
	testSwitch toggleState.
	self assert: testSwitch isOn.
	self deny: testSwitch isOff
]

{ #category : #tests }
SimpleSwitchMorphTest >> testSwitching [

	testSwitch setSwitchState: false.
	self assert: testSwitch isOff.
	self assert: testSwitch color = testSwitch offColor.
	testSwitch setSwitchState: true.
	self assert: testSwitch isOn.
	self assert: testSwitch color = testSwitch onColor.
]
