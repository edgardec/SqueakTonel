Class {
	#name : #TraitSystemTest,
	#superclass : #TraitsTestCase,
	#category : #'TraitsTests-Kernel'
}

{ #category : #testing }
TraitSystemTest >> testAllClassesAndTraits [
	"self debug: #testAllClassesAndTraits"
	
	| trait |
	trait := self t1.

	self assert: (Smalltalk allClassesAndTraits includes: trait).
	self deny: (Smalltalk allClasses includes: trait).
	
]

{ #category : #testing }
TraitSystemTest >> testAllImplementedMessagesWithout [
	"self debug: #testAllImplementedMessagesWithout"

	SystemNavigation default allImplementedMessages in: [:msgs |
		self deny: (msgs includes: #das2qwdqwd).
		self deny: (msgs includes: #qwdqwdqwdc)].

	self t6 compile: 'das2qwdqwd'.

	SystemNavigation default allImplementedMessages in: [:msgs |
		self assert: (msgs includes: #das2qwdqwd).
		self deny: (msgs includes: #qwdqwdqwdc)].
]

{ #category : #testing }
TraitSystemTest >> testAllSentMessages [
	"self debug: #testAllSentMessages"

	SystemNavigation default allSentMessages in: [:msgs |
		self deny: (msgs includes: 'dasoia' asSymbol).
		self deny: (msgs includes: 'nioaosi' asSymbol)].
	
	self t1 compile: 'foo 1 dasoia'.

	SystemNavigation default allSentMessages in: [:msgs |
		self assert: (msgs includes: 'dasoia' asSymbol).
		self deny: (msgs includes: 'nioaosi' asSymbol)].
]
