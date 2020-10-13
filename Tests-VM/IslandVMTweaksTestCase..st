"
Test case for some tweaks to the VM that Islands requires.  These tests are largely for documentation; with an un-tweaked VM, the tests mostly still succeed, albeit with possible memory corruption.
"
Class {
	#name : #IslandVMTweaksTestCase,
	#superclass : #TestCase,
	#category : #'Tests-VM'
}

{ #category : #primitives }
IslandVMTweaksTestCase >> aaaREADMEaboutPrimitives [
	"most of the Islands tweaks allow primitive methods to be located in places other than class Object.  Thus they are copied here for testing."

]

{ #category : #primitives }
IslandVMTweaksTestCase >> classOf: anObject [
	<primitive: 111>

]

{ #category : #primitives }
IslandVMTweaksTestCase >> instVarOf: anObject at: index [
	<primitive: 73>
	self primitiveFailed

]

{ #category : #primitives }
IslandVMTweaksTestCase >> instVarOf: anObject at: index put: anotherObject [
	<primitive: 74>
	self primitiveFailed

]

{ #category : #primitives }
IslandVMTweaksTestCase >> nextInstanceAfter: anObject [
	<primitive: 78>

]

{ #category : #primitives }
IslandVMTweaksTestCase >> nextObjectAfter: anObject [
	<primitive: 139>

]

{ #category : #primitives }
IslandVMTweaksTestCase >> replaceIn: replacee  from: start  to: stop   with: replacer  startingAt: replStart [
	<primitive: 105>
	self primitiveFailed
]

{ #category : #miscellaneous }
IslandVMTweaksTestCase >> returnTwelve [
	"this method is tweaked by testFlagInCompiledMethod"
	^12
]

{ #category : #primitives }
IslandVMTweaksTestCase >> someInstanceOf: aClass [
	<primitive: 77>
	self primitiveFailed
]

{ #category : #primitives }
IslandVMTweaksTestCase >> someObject [
	<primitive: 138>
	self primitiveFailed
]

{ #category : #tests }
IslandVMTweaksTestCase >> testEmptyReplace [
	| array1 array2 |
	array1 := Array with: 1 with: 2 with: 3 with: 4.
	array2 := Array with: 5 with: 6 with: 7.

	self replaceIn: array1 from: 1 to: 0 with: array2 startingAt: 1.
	self should: [ array1 = #(1 2 3 4) ].

]

{ #category : #tests }
IslandVMTweaksTestCase >> testFlagInCompiledMethod [
	"this tests that the flag in compiled methods is treated correctly"
	| method |
	method := self class compiledMethodAt: #returnTwelve.

	"turn off the flag"
	method objectAt: 1 put: (method header bitAnd: (1 << 29) bitInvert).
	self should: [ method flag not ].

	"turn on the flag"
	method objectAt: 1 put: (method header bitOr: (1 << 29)).
	self should: [ method flag ].

	"try running the method with the flag turned on"
	self should: [ self returnTwelve = 12 ].


	"make sure the flag bit isn't interpreted as a primitive"
	self should: [ method primitive = 0 ].
]

{ #category : #tests }
IslandVMTweaksTestCase >> testForgivingPrims [
	| aPoint anotherPoint array1 array2 |
	aPoint := Point x: 5 y: 6.
	anotherPoint := Point x: 7 y: 8.  "make sure there are multiple points floating around"
	anotherPoint.  "stop the compiler complaining about no uses"

	self assert: Point equals: (self classOf:  aPoint).
	self assert: 5 equals: (self instVarOf: aPoint at: 1).
	self instVarOf: aPoint at: 2 put: 10.
	self assert: 10 equals: (self instVarOf: aPoint at: 2).

	Smalltalk isRunningSpur "Spur does not maintain object ordering..."
		ifTrue: [self assert: Point equals: (self someInstanceOf: Point) class]
		ifFalse:
			[self someObject.
			 self nextObjectAfter: aPoint.

			 self assert: Point equals: (self someInstanceOf: Point) class.
			 self assert: Point equals: (self nextInstanceAfter: aPoint) class].


	array1 := Array with: 1 with: 2 with: 3.
	array2 := Array with: 4 with: 5 with: 6.

	self replaceIn: array1 from: 2 to: 3 with: array2 startingAt: 1.
	self assert: #(1 4 5) equals: array1.
]
