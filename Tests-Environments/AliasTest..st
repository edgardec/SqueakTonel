Class {
	#name : #AliasTest,
	#superclass : #TestCase,
	#instVars : [
		'value'
	],
	#category : #'Tests-Environments'
}

{ #category : #tests }
AliasTest >> setUp [
	value := Object new
]

{ #category : #tests }
AliasTest >> testAsBindingOriginal [
	| alias imported original |
	original := #Griffle => value.
	alias := original asBinding: #Plonk.
	imported := alias asBinding: #Griffle.
	self assert: imported == original
]

{ #category : #tests }
AliasTest >> testAsBindingRead [
	| alias imported |
	alias := (#Griffle => value) asBinding: #Plonk.
	imported := alias asBinding: #Nurp.
	self assert: imported key = #Nurp.
	self assert: imported value == value
]

{ #category : #tests }
AliasTest >> testAsBindingWrite [
	| alias imported global |
	global := Global key: #Griffle value: Object new.
	alias := global asBinding: #Plonk.
	imported := alias asBinding: #Nurp.
	imported value: value.
	self assert: global value == value
]

{ #category : #tests }
AliasTest >> testCanAssign [
	| alias |
	alias := Alias key: #Plonk source: #Giffle => value.
	self assert: alias canAssign
]

{ #category : #tests }
AliasTest >> testIsSpecialRead [
	| alias |
	alias := Alias key: #Plonk source: #Griffle => value.
	self assert: alias isSpecialReadBinding
]

{ #category : #tests }
AliasTest >> testIsSpecialWrite [
	| alias |
	alias := Alias key: #Plonk source: #Griffle => value.
	self assert: alias isSpecialWriteBinding
]

{ #category : #tests }
AliasTest >> testLiteralEqual [
	| global a1 a2 |
	global := #Giffle => value.
	a1 := global asBinding: #Plonk.
	a2 := global asBinding: #Nurp.
	self assert: (a1 literalEqual: a2)
	
]

{ #category : #tests }
AliasTest >> testLiteralUnequal [
	| a1 a2 |
	a1 := (#Giffle => value) asBinding: #Plonk.
	a2 := (#Giffle => value) asBinding: #Plonk.
	self deny: (a1 literalEqual: a2)
	
]

{ #category : #tests }
AliasTest >> testRead [
	| alias global |
	global := #Giffle -> value.
	alias := Alias key: #Plonk source: global.
	self assert: alias key == #Plonk.
	self assert: alias value == value.
]

{ #category : #tests }
AliasTest >> testSource [
	| alias source |
	source := #Griffle => value.
	alias := source asBinding: #Plonk.
	self assert: alias source == source
]

{ #category : #tests }
AliasTest >> testWrite [
	| alias global |
	global := #Giffle => Object new.
	alias := Alias key: #Plonk source: global.
	alias value: value.
	self assert: global value == value.
	self assert: alias value == value.
]
