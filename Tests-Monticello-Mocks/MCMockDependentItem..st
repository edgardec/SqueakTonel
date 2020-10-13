Class {
	#name : #MCMockDependentItem,
	#superclass : #MCMock,
	#instVars : [
		'name',
		'provides',
		'requires'
	],
	#category : #'Tests-Monticello-Mocks'
}

{ #category : #'as yet unclassified' }
MCMockDependentItem >> <= other [
	^ self name <= other name
]

{ #category : #'as yet unclassified' }
MCMockDependentItem >> name [

	^ name
]

{ #category : #'as yet unclassified' }
MCMockDependentItem >> name: aString [

	name := aString
]

{ #category : #'as yet unclassified' }
MCMockDependentItem >> provides: anArray [

	provides := anArray
]

{ #category : #'as yet unclassified' }
MCMockDependentItem >> provisions [

	^ provides ifNil: [#()]
]

{ #category : #'as yet unclassified' }
MCMockDependentItem >> requirements [

	^ requires ifNil: [#()]
]

{ #category : #'as yet unclassified' }
MCMockDependentItem >> requires: anArray [

	requires := anArray
]

{ #category : #testing }
MCMockDependentItem >> wantsToBeOutermost [
	^false
]
