Class {
	#name : #MCDictionaryRepositoryTest,
	#superclass : #MCRepositoryTest,
	#instVars : [
		'dict'
	],
	#category : #'Tests-Monticello'
}

{ #category : #actions }
MCDictionaryRepositoryTest >> addVersion: aVersion [
	dict at: aVersion info put: aVersion
]

{ #category : #actions }
MCDictionaryRepositoryTest >> deleteNode: aNode [
	dict removeKey: aNode
]

{ #category : #accessing }
MCDictionaryRepositoryTest >> dictionary [
	^ dict ifNil: [dict := Dictionary new]
]

{ #category : #running }
MCDictionaryRepositoryTest >> setUp [
	repository :=  MCDictionaryRepository new dictionary: self dictionary
]
