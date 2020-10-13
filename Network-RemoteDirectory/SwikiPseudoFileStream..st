Class {
	#name : #SwikiPseudoFileStream,
	#superclass : #RWBinaryOrTextStream,
	#instVars : [
		'directoryUrl',
		'localName',
		'directory'
	],
	#category : #'Network-RemoteDirectory'
}

{ #category : #accessing }
SwikiPseudoFileStream >> directory [

	^directory url
]

{ #category : #accessing }
SwikiPseudoFileStream >> directory: x [

	directory := x
]

{ #category : #accessing }
SwikiPseudoFileStream >> directoryObject [

	^directory
]

{ #category : #accessing }
SwikiPseudoFileStream >> directoryUrl [

	^directory url
]

{ #category : #accessing }
SwikiPseudoFileStream >> directoryUrl: x [

	directoryUrl := x
]

{ #category : #accessing }
SwikiPseudoFileStream >> fileName [

	^localName
]

{ #category : #testing }
SwikiPseudoFileStream >> isTypeHTTP [

	^true
]

{ #category : #accessing }
SwikiPseudoFileStream >> localName [

	^localName
]

{ #category : #accessing }
SwikiPseudoFileStream >> localName: x [

	localName := x
]
