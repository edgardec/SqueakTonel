Class {
	#name : #MCPatchMessage,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #'patch operations' }
MCPatchMessage >> addDefinition: aDefinition [
	stream nextPutAll: 'A'; tab; nextPutAll: aDefinition summary; cr
]

{ #category : #accessing }
MCPatchMessage >> message [
	^stream contents

]

{ #category : #'patch operations' }
MCPatchMessage >> modifyDefinition: oldDefinition to: newDefinition [
	stream nextPutAll: 'M'; tab; nextPutAll: newDefinition summary; cr
]

{ #category : #accessing }
MCPatchMessage >> patch: aPatch [
	stream ifNil: [stream := WriteStream on: (String new: 100)].
	aPatch operations sorted
		do: [:op | op applyTo: self]
]

{ #category : #'patch operations' }
MCPatchMessage >> removeDefinition: aDefinition [
	stream nextPutAll: 'D'; tab; nextPutAll: aDefinition summary; cr
]
