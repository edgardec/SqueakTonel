Class {
	#name : #ScrollPaneLeftBarTest,
	#superclass : #ScrollPaneTest,
	#category : #'MorphicTests-Widgets'
}

{ #category : #testing }
ScrollPaneLeftBarTest class >> shouldInheritSelectors [

	^ true
]

{ #category : #running }
ScrollPaneLeftBarTest >> setUp [

	super setUp.
	sut scrollBarOnLeft: true.
]
