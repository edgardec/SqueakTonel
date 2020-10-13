Class {
	#name : #ScrollBarTest,
	#superclass : #SliderTest,
	#category : #'MorphicTests-Widgets'
}

{ #category : #testing }
ScrollBarTest class >> shouldInheritSelectors [
	^ true
]

{ #category : #running }
ScrollBarTest >> subjectClass [

	^ ScrollBar
]
