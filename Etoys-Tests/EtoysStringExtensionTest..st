Class {
	#name : #EtoysStringExtensionTest,
	#superclass : #TestCase,
	#category : #'Etoys-Tests'
}

{ #category : #'as yet unclassified' }
EtoysStringExtensionTest >> testGetterSelectorForReturnsAccessorName [
	self assert: #getFoo equals: #foo asGetterSelector.
	self assert: #getFoo equals: #Foo asGetterSelector.
	self assert: #getFoo equals: 'foo' asGetterSelector.
	
	"Special cases:"
	self assert: #seesColor: equals: 'isOverColor:' asGetterSelector.
	self assert: #seesColor: equals: #isOverColor: asGetterSelector.
	self assert: #getNewClone equals: 'copy' asGetterSelector.
	self assert: #getNewClone equals: #copy asGetterSelector.
]

{ #category : #'as yet unclassified' }
EtoysStringExtensionTest >> testInherentSelectorForGetterReturnsBaseName [
	"Inverse of #asGetterSelector"
	self assert: #foo equals: #getFoo inherentSelector.
	self assert: #foo equals: #getfoo inherentSelector.
	self assert: #foo equals: 'getFoo' inherentSelector.
	
	"Leaves other selector-like things alone, except for Symbol-ness"
	self assert: #foo equals: 'foo' inherentSelector.
	self assert: #foo equals: #foo inherentSelector.
	self assert: #get equals: #get inherentSelector.
	self assert: #GETAWAY equals: #GETAWAY inherentSelector.
	self assert: #geFoo equals: #geFoo inherentSelector.
]

{ #category : #'as yet unclassified' }
EtoysStringExtensionTest >> testSetterSelectorForReturnsMutatorName [
	self assert: #setFoo: equals: #foo asSetterSelector.
	self assert: #setFoo: equals: #Foo asSetterSelector.
	self assert: #setFoo: equals: 'foo' asSetterSelector.
]
