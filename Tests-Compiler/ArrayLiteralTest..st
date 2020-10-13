Class {
	#name : #ArrayLiteralTest,
	#superclass : #TestCase,
	#category : #'Tests-Compiler'
}

{ #category : #running }
ArrayLiteralTest >> tearDown [
	self class removeSelector: #array
]

{ #category : #tests }
ArrayLiteralTest >> testReservedIdentifiers [
	self class compileSilently: 'array ^ #(nil true false)'.
	self assert: self array = {nil. true. false}.
]

{ #category : #tests }
ArrayLiteralTest >> testSymbols [
	self class compileSilently: 'array ^ #(#nil #true #false #''nil'' #''true'' #''false'')'.
	self assert: self array = {#nil. #true. #false. #nil. #true. #false}.
]
