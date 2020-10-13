Class {
	#name : #WeakMessageSendTest,
	#superclass : #ClassTestCase,
	#category : #'KernelTests-Objects'
}

{ #category : #tests }
WeakMessageSendTest >> testNoArguments [
	"self run: #testNoArguments"

	| m |
	m := WeakMessageSend
			receiver: true
			selector: #yourself.
	self assert: (m value).

]

{ #category : #tests }
WeakMessageSendTest >> testOneArgument [
	"self run: #testOneArgument"	

	| m |
	m := WeakMessageSend
		receiver: Array
		selector: #with:
		argument: 1.
	Smalltalk garbageCollectMost.
	self assert: (m value  = { 1 })

]

{ #category : #tests }
WeakMessageSendTest >> testOneArgumentWithGC [

	| m |
	m := WeakMessageSend
		receiver: Array
		selector: #with:
		arguments: { Object new }.
	Smalltalk garbageCollectMost.
	self assert: (m value isNil)
]

{ #category : #tests }
WeakMessageSendTest >> testReceiverWithGC [

	| m |
	m := WeakMessageSend
		receiver: Object new
		selector: #isNil.
	Smalltalk garbageCollectMost.
	self assert: (m value isNil).
]

{ #category : #tests }
WeakMessageSendTest >> testTwoArguments [

	| m |
	m := WeakMessageSend
		receiver: Array
		selector: #with:with:
		arguments: { 1 . 2 }.
	Smalltalk garbageCollectMost.
	self assert: (m value = { 1 . 2 }).

]
