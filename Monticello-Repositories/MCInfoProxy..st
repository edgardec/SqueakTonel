"
A MCInfoProxy takes the place of a MCVersionInfo with a large tree of ancestors that consume memory in the image, but are almost never accessed.  If they are, however, I will dynamically retrieve and become the Info from the original MC repository which includes the full ancestry tree.
"
Class {
	#name : #MCInfoProxy,
	#superclass : #ProtoObject,
	#instVars : [
		'info',
		'repository',
		'workingCopy'
	],
	#category : #'Monticello-Repositories'
}

{ #category : #'instance creation' }
MCInfoProxy class >> info: aMCVersionInfo workingCopy: aMCWorkingCopy repository: aMCRepository [
	^ self new
		setInfo: aMCVersionInfo
		workingCopy: aMCWorkingCopy
		repository: aMCRepository
]

{ #category : #private }
MCInfoProxy >> becomeAncestry [
	^ self becomeForward: (MCProxyMaterialization signalMaterializing: self)
]

{ #category : #private }
MCInfoProxy >> doesNotUnderstand: aMessage [
	^ aMessage sendTo: self becomeAncestry
]

{ #category : #testing }
MCInfoProxy >> isMCInfoProxy [
	^ true
]

{ #category : #private }
MCInfoProxy >> materializeInfo [
	workingCopy ancestry breadthFirstAncestorsDo:
		[ : each | (repository versionWithInfo: each) ifNotNil:
			[ : ver | ^ ver info allAncestorsDo:
				[ : eachAncestor | eachAncestor = info ifTrue: [ ^ eachAncestor ] ] ] ].
	nil error: 'Expected ' , info asString , ' to be an ancestor of one of ' , workingCopy ancestors asString
]

{ #category : #'initialize-release' }
MCInfoProxy >> setInfo: aMCVersionInfo workingCopy: aMCWorkingCopy repository: aMCRepository [ 
	info := aMCVersionInfo.
	workingCopy := aMCWorkingCopy.
	repository := aMCRepository
]
