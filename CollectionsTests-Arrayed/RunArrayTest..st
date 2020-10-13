Class {
	#name : #RunArrayTest,
	#superclass : #TestCase,
	#category : #'CollectionsTests-Arrayed'
}

{ #category : #'tests - accessing' }
RunArrayTest >> testAt [
	"self debug: #testAt"
	| array |
	array := RunArray new: 5 withAll: 2.
	self assert: (array at: 3) = 2.
	
	array at: 3 put: 5.
	self assert: (array at: 3) = 5

]

{ #category : #'tests - accessing' }
RunArrayTest >> testAt2 [
	"self debug: #testAt2"
	| array |
	array := RunArray new: 5 withAll: 2.
	
	self should: [array at: 0] raise: Error.
	self should: [array at: 6] raise: Error.
	self should: [array at: $b] raise: Error.
]

{ #category : #'tests - accessing' }
RunArrayTest >> testAtPut [
	"self debug: #testAtPut"
	| array |
	array := RunArray new: 5 withAll: 2.
	
	array at: 3 put: 5.
	self assert: array asArray = #(2 2 5 2 2).
	
	array at: 1 put: 1.
	self assert: array asArray = #(1 2 5 2 2).
]

{ #category : #'tests - accessing' }
RunArrayTest >> testAtPut2 [
	"self debug: #testAtPut2"
	| array |
	array := RunArray new: 5 withAll: 2.
	
	self should: [array at: 0 put: 5] raise: Error.
	self should: [array at: 6 put: 5] raise: Error.
	self should: [array at: $b put: 5] raise: Error.
]

{ #category : #'tests - accessing' }
RunArrayTest >> testFirst [
	"self debug: #testFirst"
	| array |
	array := RunArray new: 5 withAll: 2.
	self assert: array first = 2.
	
	array := #($a $b $c $d) as: RunArray.
	self assert: array first = $a.
]

{ #category : #'tests - accessing' }
RunArrayTest >> testLast [
	"self debug: #testLast"
	| array |
	array := RunArray new: 5 withAll: 2.
	self assert: array last = 2.
	
	array := #($a $b $c $d) as: RunArray.
	self assert: array last = $d.
]

{ #category : #'tests - instance creation' }
RunArrayTest >> testNew [
	"self debug: #testNew"
	| array |
	array := RunArray new.
	self assert: array size = 0.
]

{ #category : #'tests - instance creation' }
RunArrayTest >> testNewFrom [
	"self debug: #testNewFrom"
	| array |
	array := RunArray newFrom: #($a $b $b $b $b $c $c $a).
	self assert: array size = 8.
	self assert: array asArray = #($a $b $b $b $b $c $c $a).
]

{ #category : #'tests - instance creation' }
RunArrayTest >> testNewWithAll [
	"self debug: #testNewWithAll"
	| array |
	array := RunArray new: 5 withAll: 2.
	self assert: array size = 5.
	self assert: array asArray = #(2 2 2 2 2)
]

{ #category : #'tests - instance creation' }
RunArrayTest >> testNewWithSize [
	|array|
	array := RunArray new: 5.
	self assert: array size = 5.
	1 to: 5 do: [:index | self assert: (array at: index) isNil]
]

{ #category : #'tests - accessing' }
RunArrayTest >> testRunLengthAt [
	"self debug: #testRunLengthAt"
	| array |
	array := #($a $b $b $c $c $c $d $d) as: RunArray.
	self assert: (array runLengthAt: 1) = 1.
	self assert: (array runLengthAt: 2) = 2.
	self assert: (array runLengthAt: 3) = 1.
	self assert: (array runLengthAt: 4) = 3.
	self assert: (array runLengthAt: 5) = 2.
	self assert: (array runLengthAt: 6) = 1.
	self assert: (array runLengthAt: 7) = 2.
	self assert: (array runLengthAt: 8) = 1.
]

{ #category : #'tests - instance creation' }
RunArrayTest >> testRunsValues [
	"self debug: #testRunsValues"
	| array |
	array := RunArray runs: #(1 4 2 1) values: #($a $b $c $a).
	self assert: array size = 8.
	self assert: array asArray = #($a $b $b $b $b $c $c $a).
]

{ #category : #'tests - instance creation' }
RunArrayTest >> testScanFromANSICompatibility [
	"self run: #testScanFromANSICompatibility"

	RunArray scanFrom: (ReadStream on: '()f1dNumber new;;').
	RunArray scanFrom: (ReadStream on: '()a1death;;').
	RunArray scanFrom: (ReadStream on: '()F1death;;').
]

{ #category : #'tests - instance creation' }
RunArrayTest >> testScanFromTrailer [
	"This test documents an ancient bug in RunArray class>>scanFrom:."

	self assert: (RunArray scanFrom: '(8 4 5),b,!' readStream) = 
		(RunArray runs: #(8 4 5) values: { {}. {TextEmphasis bold}. {} }).
]

{ #category : #'tests - accessing' }
RunArrayTest >> testWithStartStopAndValueDo [
	"self debug: #testWithStartStopAndValueDo"
	| array elements startStops |
	array := #($a $b $b $c $c $c $d $d) as: RunArray.
	elements := OrderedCollection new.
	startStops := OrderedCollection new.
	array withStartStopAndValueDo: [:start :stop :value | elements add: value. startStops add: start->stop].
	
	self assert: elements asArray = #($a $b  $c  $d).
	self assert: startStops asArray = {1->1 . 2->3 . 4->6 . 7->8}
]
