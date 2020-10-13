"
This is the unit test for the class Morph. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #MorphTest,
	#superclass : #TestCase,
	#instVars : [
		'morph',
		'world'
	],
	#category : #'MorphicTests-Kernel'
}

{ #category : #support }
MorphTest >> createAndAddMorphs: someNames [

	(self createMorphs: #(a b)) do: [:newMorph |
		morph addMorphBack: newMorph].
]

{ #category : #support }
MorphTest >> createMorphs: someNames [

	^ someNames collect: [:nm | Morph new name: nm]
]

{ #category : #support }
MorphTest >> getSubmorph: name [

	^ morph submorphs detect: [:m | m knownName = name]
]

{ #category : #support }
MorphTest >> getSubmorphNames [

	^ morph submorphs collect: [:m | m knownName asSymbol]
]

{ #category : #support }
MorphTest >> getSubmorphs: someNames [

	^ someNames collect: [:nm | self getSubmorph: nm]
]

{ #category : #'initialize-release' }
MorphTest >> getWorld [

	^ world ifNil: [world := PasteUpMorph newWorldForProject: nil]
]

{ #category : #'initialize-release' }
MorphTest >> setUp [
	morph := Morph new
]

{ #category : #'initialize-release' }
MorphTest >> tearDown [

	morph delete.
]

{ #category : #'testing - add\/remove submorphs' }
MorphTest >> testAddAllMorphs [

	self createAndAddMorphs: #(a b).
	self assert: #(a b) equals: self getSubmorphNames.

	morph addAllMorphs: (self createMorphs: #(x y)).
	self assert: #(a b x y) equals: self getSubmorphNames.
	
	morph removeAllMorphs.
	morph addAllMorphs: (self createMorphs: #(x y)).
	self assert: #(x y) equals: self getSubmorphNames.
]

{ #category : #'testing - add\/remove submorphs' }
MorphTest >> testAddAllMorphsAfter [

	self createAndAddMorphs: #(a b).
	self assert: #(a b) equals: self getSubmorphNames.

	morph
		addAllMorphs: (self createMorphs: #(x y))
		after: (self getSubmorph: #a).
	self assert: #(a x y b) equals: self getSubmorphNames.
	
	morph
		addAllMorphs: (self getSubmorphs: #(x y))
		after: (self getSubmorph: #b).
	self assert: #(a b x y) equals: self getSubmorphNames.

	morph
		addAllMorphs: (self getSubmorphs: #(a x))
		after: (self getSubmorph: #y).
	self assert: #(b y a x) equals: self getSubmorphNames.

	morph
		addAllMorphs: (self getSubmorphs: #(x y))
		after: (self getSubmorph: #a).
	self assert: #(b a x y) equals: self getSubmorphNames.
]

{ #category : #'testing - add\/remove submorphs' }
MorphTest >> testAddAllMorphsInFrontOf [

	self createAndAddMorphs: #(a b).
	self assert: #(a b) equals: self getSubmorphNames.

	morph
		addAllMorphs: (self createMorphs: #(x y))
		inFrontOf: (self getSubmorph: #b).
	self assert: #(a x y b) equals: self getSubmorphNames.
	
	morph
		addAllMorphs: (self getSubmorphs: #(x y))
		inFrontOf: (self getSubmorph: #a).
	self assert: #(x y a b) equals: self getSubmorphNames.

	morph
		addAllMorphs: (self getSubmorphs: #(y b))
		inFrontOf: (self getSubmorph: #x).
	self assert: #(y b x a) equals: self getSubmorphNames.

	morph
		addAllMorphs: (self getSubmorphs: #(x y))
		inFrontOf: (self getSubmorph: #b).
	self assert: #(x y b a) equals: self getSubmorphNames.
]

{ #category : #'testing - into\/outOf World' }
MorphTest >> testIntoWorldCollapseOutOfWorld [
	| m1 m2 collapsed |
	"Create the guys"
	m1 := TestInWorldMorph new.
	m2 := TestInWorldMorph new.
	self assert: (m1 intoWorldCount = 0).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 0).
	self assert: (m2 outOfWorldCount = 0).

	"add them to basic morph"
	morph addMorphFront: m1.
	m1 addMorphFront: m2.
	self assert: (m1 intoWorldCount = 0).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 0).
	self assert: (m2 outOfWorldCount = 0).

	"open the guy"
	morph openInWorld.
	self assert: (m1 intoWorldCount = 1).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 1).
	self assert: (m2 outOfWorldCount = 0).

	"collapse it"
	collapsed := 	CollapsedMorph new beReplacementFor: morph.
	self assert: (m1 intoWorldCount = 1).
	self assert: (m1 outOfWorldCount = 1).
	self assert: (m2 intoWorldCount = 1).
	self assert: (m2 outOfWorldCount = 1).

	"expand it"
	collapsed collapseOrExpand.
	self assert: (m1 intoWorldCount = 2).
	self assert: (m1 outOfWorldCount = 1).
	self assert: (m2 intoWorldCount = 2).
	self assert: (m2 outOfWorldCount = 1).

	"delete it"
	morph delete.
	self assert: (m1 intoWorldCount = 2).
	self assert: (m1 outOfWorldCount = 2).
	self assert: (m2 intoWorldCount = 2).
	self assert: (m2 outOfWorldCount = 2).

]

{ #category : #'testing - into\/outOf World' }
MorphTest >> testIntoWorldDeleteOutOfWorld [
	| m1 m2 |
	"Create the guys"
	m1 := TestInWorldMorph new.
	m2 := TestInWorldMorph new.
	self assert: (m1 intoWorldCount = 0).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 0).
	self assert: (m2 outOfWorldCount = 0).

	morph addMorphFront: m1.
	m1 addMorphFront:  m2.
	self assert: (m1 intoWorldCount = 0).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 0).
	self assert: (m2 outOfWorldCount = 0).

	morph openInWorld.
	self assert: (m1 intoWorldCount = 1).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 1).
	self assert: (m2 outOfWorldCount = 0).

	morph delete.
	self assert: (m1 intoWorldCount = 1).
	self assert: (m1 outOfWorldCount = 1).
	self assert: (m2 intoWorldCount = 1).
	self assert: (m2 outOfWorldCount = 1).
	
]

{ #category : #'testing - into\/outOf World' }
MorphTest >> testIntoWorldTransferToNewGuy [
	| m1 m2 |
	"Create the guys"
	m1 := TestInWorldMorph new.
	m2 := TestInWorldMorph new.
	self assert: (m1 intoWorldCount = 0).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 0).
	self assert: (m2 outOfWorldCount = 0).

	morph addMorphFront: m1.
	m1 addMorphFront:  m2.
	self assert: (m1 intoWorldCount = 0).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 0).
	self assert: (m2 outOfWorldCount = 0).

	morph openInWorld.
	self assert: (m1 intoWorldCount = 1).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 1).
	self assert: (m2 outOfWorldCount = 0).

	morph addMorphFront: m2.
	self assert: (m1 intoWorldCount = 1).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 1).
	self assert: (m2 outOfWorldCount = 0).

	morph addMorphFront: m1.
	self assert: (m1 intoWorldCount = 1).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 1).
	self assert: (m2 outOfWorldCount = 0).

	m2 addMorphFront: m1.
	self assert: (m1 intoWorldCount = 1).
	self assert: (m1 outOfWorldCount = 0).
	self assert: (m2 intoWorldCount = 1).
	self assert: (m2 outOfWorldCount = 0).

	morph delete.
	self assert: (m1 intoWorldCount = 1).
	self assert: (m1 outOfWorldCount = 1).
	self assert: (m2 intoWorldCount = 1).
	self assert: (m2 outOfWorldCount = 1).

]

{ #category : #'testing - classification' }
MorphTest >> testIsMorph [
	self assert: (morph isMorph).
]

{ #category : #'testing - initialization' }
MorphTest >> testOpenInWorld [
	"This should not throw an exception."
	morph openInWorld.
]
