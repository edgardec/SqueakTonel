Class {
	#name : #MCVersionInfoWriter,
	#superclass : #MCWriter,
	#instVars : [
		'written'
	],
	#category : #'Monticello-Storing'
}

{ #category : #testing }
MCVersionInfoWriter >> isWritten: aVersionInfo [
	^ self written includes: aVersionInfo
]

{ #category : #writing }
MCVersionInfoWriter >> writeVersionInfo: aVersionInfo [
	(self isWritten: aVersionInfo)
		ifTrue: [^ stream nextPutAll: '(id ', aVersionInfo id asString printString, ')'].
	stream nextPut: $(.
	#(name message id date time author) 
		do: [:sel | 
			stream nextPutAll: sel.
			stream nextPut: $ .
			((aVersionInfo perform: sel) ifNil: ['']) asString printOn: stream.
			stream nextPut: $ ].
	stream nextPutAll: 'ancestors ('.
	aVersionInfo ancestors do: [:ea | self writeVersionInfo: ea].
	stream nextPutAll: ') stepChildren ('.
	aVersionInfo stepChildren do: [:ea | self writeVersionInfo: ea].
	stream nextPutAll: '))'.
	self wrote: aVersionInfo
]

{ #category : #accessing }
MCVersionInfoWriter >> written [
	^ written ifNil: [written := Set new]
]

{ #category : #accessing }
MCVersionInfoWriter >> wrote: aVersionInfo [
	self written add: aVersionInfo
]
