Class {
	#name : #ImageSegmentTest,
	#superclass : #TestCase,
	#category : #'Tests-System-Object Storage'
}

{ #category : #testing }
ImageSegmentTest class >> shouldInheritSelectors [
	^ false
]

{ #category : #Accessing }
ImageSegmentTest class >> testSelectors [

	(Smalltalk isRunningSpur
	and: [Smalltalk vmVMMakerVersion < 2295]) ifTrue:
		"The ImageSegment Test is known to not work on older Spur VMs
		 with the prospect of crashing. #expectedFailures does not cut it here;
		 don't even try to run them"
		[^#()].
	^super testSelectors
]

{ #category : #tests }
ImageSegmentTest >> testContextsShouldBeWritableToaFile [
	"This should not throw an exception"
	NativeImageSegment new
		copyFromRoots: {thisContext. thisContext copyStack} sizeHint: 100;
		extract;
		writeToFile: 'ContextChain';
		yourself
		
	"TODO: write assertions showing that something meaningful actually happened."

	"TODO:  bring them back in again"
]

{ #category : #tests }
ImageSegmentTest >> testImageSegmentsShouldBeWritableToaFile [
	"This should not throw an exception"
	| classes |
	classes := UIManager subclasses reject: [:sc| sc isActiveManager].
	NativeImageSegment new
		copyFromRoots: classes asArray sizeHint: 100;
		extract;
		writeToFile: 'InactiveUIManagers';
		yourself.
		
	"TODO: write assertions showing that something meaningful actually happened."

	"now bring them back in again"
	classes do: [:ea| ea new]
]
