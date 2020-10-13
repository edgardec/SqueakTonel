"
This is the unit test for the class ProtoObject. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #ProtoObjectTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Objects'
}

{ #category : #'tests - testing' }
ProtoObjectTest >> testFlag [
	"This should never throw an exception."
	ProtoObject new flag: #hallo.
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testIfNil [
	
	| object block |
	object := ProtoObject new.
	self shouldnt: [ object ifNil: [ self halt ]] raise: Halt.
	self assert: (object ifNil: [ nil ]) == object.
	"Now the same without inlining."
	block := [ self halt ].
	self shouldnt: [ object ifNil: block ] raise: Halt.
	block := [ nil ].
	self assert: (object ifNil: block) == object.
	

]

{ #category : #'tests - testing' }
ProtoObjectTest >> testIfNilIfNotNil [

	| object returnValue block |
	object := ProtoObject new.
	returnValue := Object new.
	self should: [ object ifNil: [ self error ] ifNotNil: [ self halt ] ] raise: Halt.
	self should: [ object ifNil: [ self error ] ifNotNil: [ :o | self halt ] ] raise: Halt.
	self assert: (object ifNil: [ false ] ifNotNil: [ :o | o == object ]).
	self assert: (object ifNil: [ nil ] ifNotNil: [ returnValue ]) == returnValue.
	self assert: (object ifNil: [ nil ] ifNotNil: [ :o | returnValue ]) == returnValue.
	"Now the same without inlining."
	block := [ self halt ].
	self should: [ object ifNil: [ self error ] ifNotNil: block ] raise: Halt.
	block := [ :o | self halt ].
	self should: [ object ifNil: [ self error ] ifNotNil: block ] raise: Halt.
	block := [ :o | o == object ].
	self assert: (object ifNil: [ false ] ifNotNil: block).
	block := [ returnValue ].
	self assert: (object ifNil: [ nil ] ifNotNil: block) = returnValue.
	block := [ :o | returnValue ].
	self assert: (object ifNil: [ nil ] ifNotNil: block) = returnValue
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testIfNotNil [

	| object returnValue block |
	object := ProtoObject new.
	returnValue := Object new.
	self should: [ object ifNotNil: [ self halt ] ] raise: Halt.
	self should: [ object ifNotNil: [ :o | self halt ] ] raise: Halt.
	self assert: (object ifNotNil: [ :o | o == object ]).
	self assert: (object ifNotNil: [ returnValue ]) == returnValue.
	self assert: (object ifNotNil: [ :o | returnValue ]) == returnValue.	
	"Now the same without inlining."
	block := [ self halt ].
	self should: [ object ifNotNil: block ] raise: Halt.
	block := [ :o | self halt ].
	self should: [ object ifNotNil: block ] raise: Halt.
	block := [ :o | o == object ].
	self assert: (object ifNotNil: block).
	block := [ returnValue ].
	self assert: (object ifNotNil: block) = returnValue.
	block := [ :o | returnValue ].
	self assert: (object ifNotNil: block) = returnValue
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testIfNotNilIfNil [

	| object returnValue block |
	object := ProtoObject new.
	returnValue := Object new.
	self should: [ object ifNotNil: [ self halt ] ifNil: [ self error ]  ] raise: Halt.
	self should: [ object ifNotNil: [ :o | self halt ] ifNil: [ self error ] ] raise: Halt.
	self assert: (object ifNotNil: [ :o | o == object ] ifNil: [ false ]).
	self assert: (object ifNotNil: [ returnValue ] ifNil: [ false ]) == returnValue.
	self assert: (object ifNotNil: [ :o | returnValue ] ifNil: [ false ]) == returnValue.
	"Now the same without inlining."
	block := [ self halt ].
	self should: [ object ifNotNil: block ifNil: [ self error ]  ] raise: Halt.
	block := [ :o | self halt ].
	self should: [ object ifNotNil: block ifNil: [ self error ] ] raise: Halt.
	block := [ :o | o == object ].
	self assert: (object ifNotNil: block ifNil: [ false ]).
	block := [ returnValue ].
	self assert: (object ifNotNil: block ifNil: [ false ]) == returnValue.
	block := [ :o | returnValue ].
	self assert: (object ifNotNil: block ifNil: [ false ]) == returnValue
]

{ #category : #'tests - testing' }
ProtoObjectTest >> testIsNil [

	self deny: ProtoObject new isNil
]
