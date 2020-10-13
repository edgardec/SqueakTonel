Class {
	#name : #MCPTest,
	#superclass : #TestCase,
	#category : #'MorphicTests-Kernel'
}

{ #category : #constants }
MCPTest >> defaultBounds [
	"the default bounds for morphs"
	^ 0 @ 0 corner: 50 @ 40 
]

{ #category : #constants }
MCPTest >> defaultTop [
	"the default top for morphs"
	^ self defaultBounds top 
]

{ #category : #tests }
MCPTest >> testIsMorphicModel [
	"test isMorphicModel"
	self deny: Object new isMorphicModel.
	self deny: Morph new isMorphicModel.
	self assert: MorphicModel new isMorphicModel.

]

{ #category : #tests }
MCPTest >> testIsSystemWindow [
	"test isSystemWindow"
	self deny: Object new isSystemWindow.
	self assert: SystemWindow new isSystemWindow.
]

{ #category : #tests }
MCPTest >> testTop [
	"test the #top: messages and its consequences"

	| morph factor newTop newBounds |
	morph := Morph new.
	""
	factor := 10.
	newTop := self defaultTop + factor.
	newBounds := self defaultBounds translateBy: 0 @ factor.
	""
	morph top: newTop.
	""
	self assert: morph top = newTop;
		 assert: morph bounds = newBounds
]
