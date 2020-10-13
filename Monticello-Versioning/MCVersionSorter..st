Class {
	#name : #MCVersionSorter,
	#superclass : #Object,
	#instVars : [
		'layers',
		'depthIndex',
		'depths',
		'stepparents',
		'roots'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #'instance creation' }
MCVersionSorter class >> new [
	^ self basicNew initialize
]

{ #category : #accessing }
MCVersionSorter >> addAllAncestorsOf: aVersionInfo to: aSet [
	(aSet includes: aVersionInfo) ifTrue: [^ self].
	aSet add: aVersionInfo.
	(self knownAncestorsOf: aVersionInfo) do:
		[:ea |
		self addAllAncestorsOf: ea to: aSet]
]

{ #category : #accessing }
MCVersionSorter >> addAllVersionInfos: aCollection [
	aCollection do: [:ea | self addVersionInfo: ea]
]

{ #category : #accessing }
MCVersionSorter >> addToCurrentLayer: aVersionInfo [
	| layer |
	layer := layers at: depthIndex.
	(layer includes: aVersionInfo) ifFalse:
		[depths at: aVersionInfo ifPresent:
			[:i |
			i < depthIndex
				ifTrue: [(layers at: i) remove: aVersionInfo]
				ifFalse: [^ false]].
		layer add: aVersionInfo.
		depths at: aVersionInfo put: depthIndex.
		^ true].
	^ false 
]

{ #category : #accessing }
MCVersionSorter >> addVersionInfo: aVersionInfo [
	roots add: aVersionInfo.
	self registerStepChildrenOf: aVersionInfo seen: Set new
]

{ #category : #ancestry }
MCVersionSorter >> allAncestorsOf: aVersionInfo [
	| all |
	all := Set new.
	self addAllAncestorsOf: aVersionInfo to: all.
	^ all
]

{ #category : #'initialize-release' }
MCVersionSorter >> initialize [
	stepparents := Dictionary new.
	roots := OrderedCollection new.
]

{ #category : #ancestry }
MCVersionSorter >> knownAncestorsOf: aVersionInfo [
	^ aVersionInfo ancestors, (self stepParentsOf: aVersionInfo) asArray
]

{ #category : #accessing }
MCVersionSorter >> layers [
	^ layers
]

{ #category : #private }
MCVersionSorter >> popLayer [
	depthIndex := depthIndex - 1
]

{ #category : #private }
MCVersionSorter >> processVersionInfo: aVersionInfo [
	(self addToCurrentLayer: aVersionInfo) ifTrue:
		[self pushLayer.
		(self knownAncestorsOf: aVersionInfo) do: [:ea | self processVersionInfo: ea].
		self popLayer]

]

{ #category : #private }
MCVersionSorter >> pushLayer [
	depthIndex := depthIndex + 1.
	depthIndex > layers size ifTrue: [layers add: OrderedCollection new].
	
]

{ #category : #private }
MCVersionSorter >> registerStepChildrenOf: aVersionInfo seen: aSet [
	(aSet includes: aVersionInfo) ifTrue: [^ self].
	aSet add: aVersionInfo.
	aVersionInfo stepChildren do: [:ea | (self stepParentsOf: ea) add: aVersionInfo].
	aVersionInfo ancestors do: [:ea | self registerStepChildrenOf: ea seen: aSet].
]

{ #category : #versions }
MCVersionSorter >> sortedVersionInfos [
	layers := OrderedCollection with: OrderedCollection new.
	depthIndex := 1.
	depths := Dictionary new.
	roots do: [:ea | self processVersionInfo: ea].
	^ layers gather: [:ea | ea]
]

{ #category : #ancestry }
MCVersionSorter >> stepParentsOf: aVersionInfo [
	^ (stepparents at: aVersionInfo ifAbsentPut: [Set new])
]
