Class {
	#name : #GlobalTest,
	#superclass : #TestCase,
	#instVars : [
		'key',
		'value'
	],
	#category : #'Tests-Environments'
}

{ #category : #running }
GlobalTest >> setUp [
	key := Object new.
	value := Object new.
	
]

{ #category : #tests }
GlobalTest >> testArrowBinding [
	| binding |
	binding := #Griffle => value.
	self assert: binding class = Global.
	self assert: binding key = #Griffle.
	self assert: binding value == value
]

{ #category : #tests }
GlobalTest >> testAsBindingOriginal [
	| global imported |
	global := Global key: #Griffle value: Object new.
	imported := global asBinding: #Griffle.
	self assert: imported == global
]

{ #category : #tests }
GlobalTest >> testAsBindingRead [
	| global imported |
	global := Global key: key value: value.
	imported := global asBinding: #Griffle.
	self assert: imported key = #Griffle.
	self assert: imported value == value.
	
]

{ #category : #tests }
GlobalTest >> testAsBindingWrite [
	| global imported |
	global := Global key: key value: Object new.
	imported := global asBinding: #Griffle.
	imported value: value.
	self assert: global value == value.

]

{ #category : #tests }
GlobalTest >> testCanAssign [
	| global |
	global := Global key: key value: value.
	self assert: global canAssign
]

{ #category : #tests }
GlobalTest >> testIsSpecialRead [
	| global |
	global := Global key: key value: value.
	self deny: global isSpecialReadBinding
]

{ #category : #tests }
GlobalTest >> testIsSpecialWrite [
	| global |
	global := Global key: key value: value.
	self deny: global isSpecialWriteBinding
]

{ #category : #tests }
GlobalTest >> testLiteralEqual [
	| global |
	global := #Griffle => value.
	self assert: (global literalEqual: global)
]

{ #category : #tests }
GlobalTest >> testLiteralUnequal [
	| g1 g2 |
	g1 := #Griffle => value.
	g2 := #Griffle => value.
	self deny: (g1 literalEqual: g2)
]

{ #category : #tests }
GlobalTest >> testRead [
	| global |
	global := Global key: key value: value.
	self assert: global key == key.
	self assert: global value == value.
]

{ #category : #tests }
GlobalTest >> testSource [
	| global |
	global := Global key: #Griffle value: Object new.
	self assert: global source == global
]

{ #category : #tests }
GlobalTest >> testWrite [
	| global |
	global := Global key: key value: Object new.
	global value: value.
	self assert: global value == value
]
