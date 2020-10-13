Class {
	#name : #PluggableScrollPane,
	#superclass : #ScrollPane,
	#instVars : [
		'morph',
		'morphClass'
	],
	#category : #'Morphic-Pluggable Widgets'
}

{ #category : #'instance creation' }
PluggableScrollPane class >> on: morph [

	^ self new
		morph: morph;
		yourself
]

{ #category : #'instance creation' }
PluggableScrollPane class >> onClass: morphClass [

	^ self new
		morphClass: morphClass;
		updateMorph;
		yourself
]

{ #category : #accessing }
PluggableScrollPane >> morph [

	^ morph ifNil: [
		self morph: self morphClass new.
		morph]
]

{ #category : #accessing }
PluggableScrollPane >> morph: morphToScroll [

	morph ifNotNil: [:m | m removeDependent: self].

	morphToScroll topLeft: 0@0.
	morph := morphToScroll.
	morphClass := morphToScroll class.

	morph addDependent: self.

	self scroller
		removeAllMorphs;
		addMorph: morph.
	
	self updateMorph.
]

{ #category : #accessing }
PluggableScrollPane >> morphClass [

	^ morphClass ifNil: [Morph]
]

{ #category : #accessing }
PluggableScrollPane >> morphClass: aMorphClass [

	morphClass := aMorphClass.
]

{ #category : #updating }
PluggableScrollPane >> update: aspect [

	aspect == #submorphs
		ifTrue: [self updateMorph].

	super update: aspect.
]

{ #category : #updating }
PluggableScrollPane >> updateMorph [

	self morph fullBounds.
	self setScrollDeltas.
]
