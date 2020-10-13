Class {
	#name : #MethodPropertiesTest,
	#superclass : #TestCase,
	#instVars : [
		'method'
	],
	#category : #'KernelTests-Methods'
}

{ #category : #private }
MethodPropertiesTest >> propertyDictionaryFor: aMethod [
	^ aMethod properties properties
]

{ #category : #running }
MethodPropertiesTest >> setUp [
	method := Object >> #halt.
]

{ #category : #running }
MethodPropertiesTest >> tearDown [
	Object recompile: #halt from: Object.
]

{ #category : #tests }
MethodPropertiesTest >> testAllMethodsHaveMethodClass [
	Smalltalk garbageCollect.
	self assert: (CompiledMethod allInstances
			reject: [:cm | | lastLiteral |
				lastLiteral := cm literalAt: cm numLiterals.
				lastLiteral isVariableBinding
					and: [lastLiteral value isBehavior
							or: [lastLiteral value isTrait]]]) isEmpty
			description: 'CompiledMethods must have methodClass literal'
]

{ #category : #tests }
MethodPropertiesTest >> testAt [
	self should: [ method properties at: #zork ] raise: Error.
	self assert: (self propertyDictionaryFor: method) isEmpty.
	method properties at: #zork put: 'hello'.
	self assert: (method properties at: #zork) = 'hello'.
]

{ #category : #tests }
MethodPropertiesTest >> testAtIfAbsent [
	self assert: (method properties at: #zork ifAbsent: [ 'hello' ]) = 'hello'.
	self assert: (self propertyDictionaryFor: method) isEmpty.
	method properties at: #zork put: 'hi'.
	self assert: (method properties at: #zork ifAbsent: [ 'hello' ]) = 'hi'.
]

{ #category : #tests }
MethodPropertiesTest >> testAtIfAbsentPut [
	self assert: (method properties at: #zork ifAbsentPut: [ 'hello' ]) = 'hello'.
	self assert: (method properties at: #zork ifAbsentPut: [ 'hi' ]) = 'hello'.
]

{ #category : #tests }
MethodPropertiesTest >> testAtPut [
	self assert: (method properties at: #zork put: 'hello') = 'hello'.
	self assert: (method properties at: #zork) = 'hello'.
]

{ #category : #tests }
MethodPropertiesTest >> testAtPutRepeatedly [
	self assert: (method properties at: #zork put: 'hello') = 'hello'.
	self assert: (method properties at: #zork put: 'hello') = 'hello'.
	self assert: (method properties at: #zork) = 'hello'.
]

{ #category : #tests }
MethodPropertiesTest >> testIncludesKey [
	self deny: (method properties includesKey: #zork).
	self assert: (self propertyDictionaryFor: method) isEmpty.
	method properties at: #zork put: 123.
	self assert: (method properties includesKey: #zork).
]

{ #category : #tests }
MethodPropertiesTest >> testRemoveKey [
	method properties at: #zork put: 'hello'.
	self should: [ method properties removeKey: #halt ] raise: Error.
	self assert: (method properties removeKey: #zork) = 'hello'.
	self assert: (self propertyDictionaryFor: method) isEmpty.
	self should: [ method properties removeKey: #zork ] raise: Error.
	self assert: (self propertyDictionaryFor: method) isEmpty.
]

{ #category : #tests }
MethodPropertiesTest >> testRemoveKeyifAbsent [
	method properties at: #zork put: 'hello'.
	self assert: (method properties removeKey: #halt ifAbsent: [ 'hi' ]) = 'hi'.
	self assert: (method properties removeKey: #zork ifAbsent: [ 'hi' ]) = 'hello'.
	self assert: (self propertyDictionaryFor: method) isEmpty.
	self should: (method properties removeKey: #zork ifAbsent: [ 'hi' ]) = 'hi'.
	self assert: (self propertyDictionaryFor: method) isEmpty.
]
