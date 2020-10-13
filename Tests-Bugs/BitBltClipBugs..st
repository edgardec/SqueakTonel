Class {
	#name : #BitBltClipBugs,
	#superclass : #TestCase,
	#category : #'Tests-Bugs'
}

{ #category : #tests }
BitBltClipBugs >> testDrawingWayOutside [
	| f1 bb f2 |
	f1 := Form extent: 100@100 depth: 1.
	f2 := Form extent: 100@100 depth: 1.
	bb := BitBlt toForm: f1.
	bb combinationRule: 3.
	bb sourceForm: f2.
	bb destOrigin: SmallInteger maxVal squared asPoint.
	bb width: 100; height: 100.
	
	"This should not throw an exception:"
	bb copyBits.

]

{ #category : #tests }
BitBltClipBugs >> testDrawingWayOutside2 [
	| f1 bb f2 |
	f1 := Form extent: 100@100 depth: 1.
	f2 := Form extent: 100@100 depth: 1.
	bb := BitBlt toForm: f1.
	bb combinationRule: 3.
	bb sourceForm: f2.
	bb destOrigin: 0@0.
	bb width: SmallInteger maxVal squared; height: SmallInteger maxVal squared.
	
	"This should not throw an exception:"
	bb copyBits.
]

{ #category : #tests }
BitBltClipBugs >> testDrawingWayOutside3 [
	| f1 bb f2 |
	f1 := Form extent: 100@100 depth: 1.
	f2 := Form extent: 100@100 depth: 1.
	bb := BitBlt toForm: f1.
	bb combinationRule: 3.
	bb sourceForm: f2.
	bb destOrigin: SmallInteger maxVal squared asPoint.
	bb width: SmallInteger maxVal squared; height: SmallInteger maxVal squared.
	
	"This should not throw an exception:"
	bb copyBits.

]

{ #category : #tests }
BitBltClipBugs >> testDrawingWayOutside4 [
	| f1 bb f2 |
	f1 := Form extent: 100@100 depth: 1.
	f2 := Form extent: 100@100 depth: 1.
	bb := BitBlt toForm: f1.
	bb combinationRule: 3.
	bb sourceForm: f2.
	bb destOrigin: SmallInteger maxVal squared asPoint.
	bb width: 100; height: 100.
	bb sourceOrigin: SmallInteger maxVal squared asPoint.
	
	"This should not throw an exception:"
	bb copyBits.

]

{ #category : #tests }
BitBltClipBugs >> testDrawingWayOutside5 [
	| f1 bb f2 |
	f1 := Form extent: 100@100 depth: 1.
	f2 := Form extent: 100@100 depth: 1.
	bb := BitBlt toForm: f1.
	bb combinationRule: 3.
	bb sourceForm: f2.
	bb destOrigin: 0@0.
	bb width: SmallInteger maxVal squared; height: SmallInteger maxVal squared.
	bb sourceOrigin: SmallInteger maxVal squared asPoint.
	
	"This should not throw an exception:"
	bb copyBits.
]

{ #category : #tests }
BitBltClipBugs >> testDrawingWayOutside6 [
	| f1 bb f2 |
	f1 := Form extent: 100@100 depth: 1.
	f2 := Form extent: 100@100 depth: 1.
	bb := BitBlt toForm: f1.
	bb combinationRule: 3.
	bb sourceForm: f2.
	bb destOrigin: SmallInteger maxVal squared asPoint.
	bb width: SmallInteger maxVal squared; height: SmallInteger maxVal squared.
	bb sourceOrigin: SmallInteger maxVal squared asPoint.
	
	"This should not throw an exception:"
	bb copyBits.

]

{ #category : #tests }
BitBltClipBugs >> testFillingWayOutside [
	| f1 bb |
	f1 := Form extent: 100@100 depth: 1.
	bb := BitBlt toForm: f1.
	bb combinationRule: 3.
	bb fillColor: Color black.
	bb destOrigin: SmallInteger maxVal squared asPoint.
	bb width: 100; height: 100.
	
	"This should not throw an exception:"
	bb copyBits.

]

{ #category : #tests }
BitBltClipBugs >> testFillingWayOutside2 [
	| f1 bb |
	f1 := Form extent: 100@100 depth: 1.
	bb := BitBlt toForm: f1.
	bb combinationRule: 3.
	bb fillColor: Color black.
	bb destOrigin: 0@0.
	bb width: SmallInteger maxVal squared; height: SmallInteger maxVal squared.
	
	"This should not throw an exception:"
	bb copyBits.
]

{ #category : #tests }
BitBltClipBugs >> testFillingWayOutside3 [
	| f1 bb |
	f1 := Form extent: 100@100 depth: 1.
	bb := BitBlt toForm: f1.
	bb combinationRule: 3.
	bb fillColor: Color black.
	bb destOrigin: SmallInteger maxVal squared asPoint.
	bb width: SmallInteger maxVal squared; height: SmallInteger maxVal squared.
	
	"This should not throw an exception:"
	bb copyBits.

]
