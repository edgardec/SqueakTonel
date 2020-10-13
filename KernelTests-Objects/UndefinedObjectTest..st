"
This is the unit test for the class UndefinedObject. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #UndefinedObjectTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Objects'
}

{ #category : #'tests - Class Methods' }
UndefinedObjectTest >> testAllInstances [
	self assert: UndefinedObject allInstances size = 1 description: 'There should be a single instance of UndefinedObject'.
	self assert: (UndefinedObject allInstances includes: nil) description: 'nil should be an instance of UndefinedObject'.
]

{ #category : #'tests - copying' }
UndefinedObjectTest >> testDeepCopy [

	self assert:  (nil deepCopy = nil).
]

{ #category : #'tests - testing' }
UndefinedObjectTest >> testHaltIfNil [

	self should: [ nil haltIfNil] raise: Halt.
]

{ #category : #'tests - testing' }
UndefinedObjectTest >> testIfNil [

	| object block |
	object := Object new.
	self should: [ nil ifNil: [ self halt ] ] raise: Halt.
	self assert: (nil ifNil: [ object ]) == object.
	"Now the same without inlining."	
	block := [ self halt ].
	self should: [ nil ifNil: block ] raise: Halt.
	block := [ object ].
	self assert: (nil ifNil: block) == object.
	



]

{ #category : #'tests - testing' }
UndefinedObjectTest >> testIfNilIfNotNil [

	| object block |
	object := Object new.
	self should: [ nil ifNil: [self halt] ifNotNil: [ self error] ] raise: Halt.
	self should: [ nil ifNil: [ self halt ] ifNotNil: [ :o | self error ] ] raise: Halt.
	self assert: (nil ifNil: [ object ] ifNotNil: [ 1 ]) == object.
	self assert: (nil ifNil: [ object ] ifNotNil: [ :o | 1 ]) == object.
	"Now the same without inlining."
	block := [ self halt ].
	self should: [ nil ifNil: block ifNotNil: [ self error ] ] raise: Halt.
	self should: [ nil ifNil: block ifNotNil: [ :o | self error ] ] raise: Halt.
	block := [ object ].
	self assert: (nil ifNil: block ifNotNil: [ 1 ]) == object.
	self assert: (nil ifNil: block ifNotNil: [ :o | 1 ]) == object
]

{ #category : #'tests - testing' }
UndefinedObjectTest >> testIfNotNil [

	| block |
	self shouldnt: [ nil ifNotNil: [ self halt ] ] raise: Halt.
	self shouldnt: [ nil ifNotNil: [ :object | self halt ] ] raise: Halt.
	self assert: (nil ifNotNil: [ 1 ]) == nil.
	self assert: (nil ifNotNil: [ :o | 1 ]) == nil.
	"Now the same without inlining."	
	block := [ self halt ].
	self shouldnt: [ nil ifNotNil: block ] raise: Halt.
	block := [ :object | self halt ].
	self shouldnt: [ nil ifNotNil: block ] raise: Halt.
	block := [ 1 ].
	self assert: (nil ifNotNil: block) == nil.
	block := [ :o | 1 ].
	self assert: (nil ifNotNil: block) == nil.
		


]

{ #category : #'tests - testing' }
UndefinedObjectTest >> testIfNotNilIfNil [

	| object block |
	object := Object new.
	self should: [ nil ifNotNil: [ self error ] ifNil: [ self halt ] ] raise: Halt.
	self should: [ nil ifNotNil: [ :o | self error] ifNil: [ self halt ] ] raise: Halt.
	self assert: (nil ifNotNil: [ 1 ] ifNil: [ object ]) == object.
	self assert: (nil ifNotNil: [ :o | 1 ] ifNil: [ object ]) == object.
	"Now the same without inlining."
	block := [ self error ].
	self should: [ nil ifNotNil: block ifNil: [ self halt ] ] raise: Halt.
	block := [ :o | self error].
	self should: [ nil ifNotNil: block ifNil: [ self halt ] ] raise: Halt.
	block := [ 1 ].
	self assert: (nil ifNotNil: block ifNil: [ object ]) == object.
	block := [ :o | 1 ].
	self assert: (nil ifNotNil: block ifNil: [ object ]) == object
]

{ #category : #'tests - Class Methods' }
UndefinedObjectTest >> testInitializedInstance [

	self assert: ( UndefinedObject initializedInstance class == UndefinedObject).
]

{ #category : #'tests - testing' }
UndefinedObjectTest >> testIsEmptyOrNil [

	self assert: (nil isEmptyOrNil).
]

{ #category : #'tests - testing' }
UndefinedObjectTest >> testIsLiteral [

	self assert: (nil isLiteral).
]

{ #category : #'tests - testing' }
UndefinedObjectTest >> testIsNil [

	self assert: nil isNil
]

{ #category : #'tests - Class Methods' }
UndefinedObjectTest >> testNew [

	self should: [ UndefinedObject new] raise: Error.
]

{ #category : #'tests - testing' }
UndefinedObjectTest >> testNotNil [

	self deny: nil notNil
]

{ #category : #'tests - printing' }
UndefinedObjectTest >> testPrintOn [

	| string |
	string := String streamContents: [:stream | nil printOn: stream].
	self assert: (string = 'nil').
]

{ #category : #'tests - copying' }
UndefinedObjectTest >> testShallowCopy [

	self assert: (nil shallowCopy = nil).
]

{ #category : #'tests - printing' }
UndefinedObjectTest >> testStoreOn [

	| string |
	string := String streamContents: [:stream | nil storeOn: stream].
	self assert: ((Compiler evaluate: string) = nil).
]

{ #category : #'tests - copying' }
UndefinedObjectTest >> testVeryDeepCopyWith [

	self assert: ((nil veryDeepCopyWith: nil) = nil).
]
