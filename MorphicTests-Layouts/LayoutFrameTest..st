Class {
	#name : #LayoutFrameTest,
	#superclass : #TestCase,
	#category : #'MorphicTests-Layouts'
}

{ #category : #tests }
LayoutFrameTest >> testInset [
	| lf rectangle |
	lf := LayoutFrame new
		leftFraction: 0 offset: 10;
		topFraction: 0 offset: 10;
		rightFraction: 1 offset: -10;
		bottomFraction: 1 offset: -10;
		yourself.
	rectangle := lf layout: nil in: (50@10 corner: 150@70).
	self assert: (60@20 corner: 140@60) = rectangle
]

{ #category : #tests }
LayoutFrameTest >> testLeftTopAligned [
	| lf rectangle |
	lf := LayoutFrame new
		leftFraction: 0 offset: 10;
		topFraction: 0 offset: 10;
		rightFraction: 0 offset: 60;
		bottomFraction: 0 offset: 25;
		yourself.
	rectangle := lf layout: nil in: (50@10 corner: 150@70).
	self assert: (60@20 corner: 110@35) = rectangle
]

{ #category : #tests }
LayoutFrameTest >> testRightBottomQuadrant [
	| lf rectangle |
	lf := LayoutFrame new
		leftFraction: 1/2 offset: 1;
		topFraction: 1/2 offset: 1;
		rightFraction: 1 offset: -2;
		bottomFraction: 1 offset: -2;
		yourself.
	rectangle := lf layout: nil in: (50@10 corner: 150@70).
	self assert: (101@41 corner: 148@68) = rectangle
]

{ #category : #tests }
LayoutFrameTest >> testSpaceFill [
	| lf rectangle |
	lf := LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 0 offset: 0;
		rightFraction: 1 offset: 0;
		bottomFraction: 1 offset: 0;
		yourself.
	rectangle := lf layout: nil in: (50@10 corner: 150@70).
	self assert: (50@10 corner: 150@70) = rectangle
]
