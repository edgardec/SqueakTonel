Class {
	#name : #MorphLayoutTest,
	#superclass : #TestCase,
	#instVars : [
		'reset'
	],
	#category : #'MorphicTests-Layouts'
}

{ #category : #helper }
MorphLayoutTest >> ensureLayout: aMorph [

	^ aMorph
		fullBounds;
		yourself
]

{ #category : #tests }
MorphLayoutTest >> testAdhereToEdge [

	| child container |
	container := Morph new
		extent: 300 @ 200;
		addMorphBack: (child := Morph new extent: 100 @ 100).
	
	child adhereToEdge: #right.
	self ensureLayout: container.
	self assert: 200 @ 0 equals: child position.
	
	child adhereToEdge: #bottom.
	self ensureLayout: container.
	self assert: 200 @ 100 equals: child position.
	
	child adhereToEdge: #topLeft.
	self ensureLayout: container.
	self assert: 0 @ 0 equals: child position
]

{ #category : #tests }
MorphLayoutTest >> testLayoutPropertyAssertions [

	| morph |
	morph := Morph new.
	
	self should: [morph vResizing: #shrriinkWraap] raise: Error.
	self should: [morph hResizing: #spaceFlll] raise: Error.
	self should: [morph cellSpacing: 0] raise: Error.
	self should: [morph cellSpacing: #glob] raise: Error.
	self should: [morph listSpacing: 2] raise: Error.
	self should: [morph listSpacing: #eq] raise: Error
]

{ #category : #tests }
MorphLayoutTest >> testManualPositions [

	| container greenMorph redMorph |
	container := Morph new
		addMorphBack: (redMorph := Morph new color: Color red; extent: 30 @ 20; position: 20 @ 20);
		addMorphBack: (greenMorph := Morph new color: Color green;  extent: 200 @ 300; position: 80 @ 80).
	
	self ensureLayout: container.
	self assert: Morph new extent equals: container extent.
	
	container extent: 300 @ 300.
	self assert: 300 @ 300 equals: container extent
]
