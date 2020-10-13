Class {
	#name : #ClassBindingTest,
	#superclass : #TestCase,
	#instVars : [
		'key',
		'value'
	],
	#category : #'Tests-Environments'
}

{ #category : #running }
ClassBindingTest >> setUp [
	key := Object new.
	value := Object new.
]

{ #category : #tests }
ClassBindingTest >> testArrowBinding [
	| binding |
	binding := #Griffle => self class.
	self assert: binding class = ClassBinding.
	self assert: binding key = #Griffle.
	self assert: binding value = self class.
	
]

{ #category : #tests }
ClassBindingTest >> testAsBindingAlias [
	| binding imported |
	binding := ClassBinding key: #Griffle value: value.
	imported := binding asBinding: #Plonk.
	self assert: imported class == Alias
]

{ #category : #tests }
ClassBindingTest >> testAsBindingOriginal [
	| binding imported |
	binding := ClassBinding key: #Griffle value: value.
	imported := binding asBinding: #Griffle.
	self assert: binding == imported
]

{ #category : #tests }
ClassBindingTest >> testAsBindingRead [
	| binding imported |
	binding := ClassBinding key: #Griffle value: value.
	imported := binding asBinding: #Plonk.
	self assert: imported key = #Plonk.
	self assert: imported value == value.
]

{ #category : #tests }
ClassBindingTest >> testAsBindingWrite [
	| binding imported |
	binding := ClassBinding key: #Griffle value: value.
	imported := binding asBinding: #Plonk.
	self
		should: [imported value: Object new]
		raise: AttemptToWriteReadOnlyGlobal

]

{ #category : #tests }
ClassBindingTest >> testCanAssign [
	| binding |
	binding := ClassBinding key: key value: value.
	self deny: binding canAssign
]

{ #category : #tests }
ClassBindingTest >> testIsSpecialRead [
	| binding |
	binding := ClassBinding key: key value: value.
	self deny: binding isSpecialReadBinding
]

{ #category : #tests }
ClassBindingTest >> testIsSpecialWrite [
	| binding |
	binding := ClassBinding key: key value: value.
	self assert: binding isSpecialWriteBinding
]

{ #category : #tests }
ClassBindingTest >> testLiteralEqual [
	| b1 b2 |
	b1 := #Griffle => self class.
	b2 := #Plonk => self class.
	self assert: (b1 literalEqual: b2)
]

{ #category : #tests }
ClassBindingTest >> testLiteralUnequal [
	| b1 b2 |
	b1 := #Griffle => self class.
	b2 := #Griffle => self class superclass.
	self deny: (b1 literalEqual: b2)
]

{ #category : #tests }
ClassBindingTest >> testRead [
	| binding |
	binding := ClassBinding key: key value: value.
	self assert: binding key == key.
	self assert: binding value == value
]

{ #category : #tests }
ClassBindingTest >> testResumeExceptionToWrite [
	| binding |
	binding := ClassBinding key: key value: Object new.
	[binding value: value]
		on: AttemptToWriteReadOnlyGlobal
		do: [:ex | ex resume: true].
	self assert: binding value == value
]

{ #category : #tests }
ClassBindingTest >> testSource [
	| binding |
	binding := ClassBinding key: #Griffle value: value.
	self assert: binding source == binding
]

{ #category : #tests }
ClassBindingTest >> testWriteRaisesException [
	| binding |
	binding := ClassBinding key: key value: value.
	self
		should: [binding value: Object new]
		raise: AttemptToWriteReadOnlyGlobal.
]
