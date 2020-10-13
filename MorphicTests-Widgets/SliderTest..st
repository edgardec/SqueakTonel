Class {
	#name : #SliderTest,
	#superclass : #TestCase,
	#instVars : [
		'sut'
	],
	#category : #'MorphicTests-Widgets'
}

{ #category : #running }
SliderTest >> setUp [

	super setUp.
	sut := self subjectClass
		on: (ValueHolder new contents: 0.0)
		getValue: #contents
		setValue: #contents:.
	sut extent: 400@20.
]

{ #category : #running }
SliderTest >> subjectClass [

	^ Slider
]

{ #category : #tests }
SliderTest >> test01Value [

	self assert: 0.0 equals: sut value.
	self assert: 0.0 equals: sut model contents.
]

{ #category : #tests }
SliderTest >> test02SetValue [

	sut setValue: 0.5.
	self
		assert: 0.5 equals: sut value;
		assert: 0.5 equals: sut model contents.
]

{ #category : #tests }
SliderTest >> test03MinMax [

	sut
		minimumValue: 10;
		maximumValue: 20.

	sut setValue: 5.
	self assert: 10 equals: sut value truncated.
	
	sut setValue: 30.
	self assert: 20 equals: sut value truncated.

	sut maximumValue: 15.
	self assert: 15 equals: sut value truncated.

	sut setValue: 10.
	sut minimumValue: 12.
	self assert: 12 equals: sut value truncated.

]

{ #category : #tests }
SliderTest >> test04Descending [

	| px |
	sut setValue: 0.3.
	px := sut thumb position.
	
	sut descending: sut descending not.
	self assert: px ~= sut thumb position.
]

{ #category : #tests }
SliderTest >> test05SliderWithoutModel [

	| swm |
	swm := Slider new.
	
	self assert: 0.0 equals: swm value.
	swm setValue: 0.6.
	self assert: 0.6 equals: swm value.
]

{ #category : #tests }
SliderTest >> test06Truncate [

	self assert: sut truncate not.
	
	sut maximumValue: 100.
	sut truncate: true.

	sut setValue: 23.45.
	self assert: 23 equals: sut value.

	sut setValue: 23.65.
	self assert: 24 equals: sut value.
]

{ #category : #tests }
SliderTest >> test07Quantum [

	sut maximumValue: 100.
	sut quantum: 5.

	sut setValue: 23.
	self assert: 25 equals: sut value.
]

{ #category : #tests }
SliderTest >> test08MinEqualsMax [

	sut
		maximumValue: 50;
		minimumValue: 50.

	self assert: 50 equals: sut value.
]

{ #category : #tests }
SliderTest >> test09SliderWithoutGetter [

	sut getValueSelector: nil.
	sut setValue: 0.5.
		
	self assert: 0.5 equals: sut value.
	self assert: 0.5 equals: sut model contents.
]
