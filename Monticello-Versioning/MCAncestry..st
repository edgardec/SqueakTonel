"
Abstract superclass of records of ancestry.
"
Class {
	#name : #MCAncestry,
	#superclass : #Object,
	#instVars : [
		'ancestors',
		'stepChildren'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #'instance creation' }
MCAncestry class >> new [
	^ self basicNew initialize
]

{ #category : #ancestry }
MCAncestry >> allAncestors [
	
	| allAncestors |
	allAncestors := Set new.
	self allAncestorsDo: [ :each | ] visitedAncestors: allAncestors.
	^allAncestors 
]

{ #category : #ancestry }
MCAncestry >> allAncestorsDo: aBlock [
	
	self allAncestorsDo: aBlock visitedAncestors: Set new
]

{ #category : #ancestry }
MCAncestry >> allAncestorsDo: aBlock visitedAncestors: visitedAncestors [
	self ancestors do: [ :each |
		(visitedAncestors ifAbsentAdd: each) ifTrue: [
			aBlock value: each.
			each allAncestorsDo: aBlock visitedAncestors: visitedAncestors ] ]
]

{ #category : #ancestry }
MCAncestry >> allAncestorsOnPathTo: aVersionInfo [
	^ MCFilteredVersionSorter new
		target: aVersionInfo;
		addAllVersionInfos: self ancestors;
		sortedVersionInfos
]

{ #category : #ancestry }
MCAncestry >> ancestorString [
	^ String streamContents:
		[:s | self ancestors do: [:ea | s nextPutAll: ea name] separatedBy: [s nextPutAll: ', ']]
]

{ #category : #ancestry }
MCAncestry >> ancestorStringWithout: packageName [
	^ String streamContents:
		[:s | self ancestors do: [:ea | s nextPutAll: (ea nameWithout: packageName)] separatedBy: [s nextPutAll: ', ']]
]

{ #category : #ancestry }
MCAncestry >> ancestors [
	^ ancestors ifNil: [ Array empty ]
]

{ #category : #ancestry }
MCAncestry >> ancestorsDoWhileTrue: aBlock [
	self ancestors do:
		[:ea |
		(aBlock value: ea) ifTrue: 
			[ea ancestorsDoWhileTrue: aBlock]]
]

{ #category : #ancestry }
MCAncestry >> breadthFirstAncestors [
	^ Array streamContents: [:s | self breadthFirstAncestorsDo: [:ea | s nextPut: ea]]
]

{ #category : #ancestry }
MCAncestry >> breadthFirstAncestorsDo: aBlock [
	| seen todo next |
	seen := Set with: self.
	todo := OrderedCollection with: self.
	[todo isEmpty] whileFalse:
		[next := todo removeFirst.
		next ancestors do:
			[:ea |
			(seen includes: ea) ifFalse:
				[aBlock value: ea.
				seen add: ea.
				todo add: ea]]]
]

{ #category : #copying }
MCAncestry >> clearAncestors [
	ancestors := Array empty
]

{ #category : #copying }
MCAncestry >> clearStepChildren [
	stepChildren := Array empty
]

{ #category : #ancestry }
MCAncestry >> commonAncestorWith: aNode [
	| commonAncestors |
	commonAncestors := self commonAncestorsWith: aNode.
	^ commonAncestors at: 1 ifAbsent: [nil]
]

{ #category : #ancestry }
MCAncestry >> commonAncestorsWith: aVersionInfo [

	| sharedAncestors mergedOrder sorter |
	sorter := MCVersionSorter new
						addVersionInfo: self;
						addVersionInfo: aVersionInfo.
	mergedOrder := sorter sortedVersionInfos.
	sharedAncestors := (sorter allAncestorsOf: self) intersection: (sorter allAncestorsOf: aVersionInfo).
	^ mergedOrder select: [:ea | sharedAncestors includes: ea]
]

{ #category : #ancestry }
MCAncestry >> hasAncestor: aVersionInfo [
	"Answer whether the receiver has ancestor, aVersionInfo."
"Would it be more performant to use a Set for alreadySeen:?"
	^ self
		hasAncestor: aVersionInfo
		alreadySeen: OrderedCollection new
]

{ #category : #ancestry }
MCAncestry >> hasAncestor: aVersionInfo alreadySeen: aList [
	(aList includes: self) ifTrue: [^ false].
	aList add: self.

	^ self = aVersionInfo or: [self ancestors anySatisfy: [:ea | ea hasAncestor: aVersionInfo alreadySeen: aList]]

]

{ #category : #'initialize-release' }
MCAncestry >> initialize [
	ancestors := #().
	stepChildren := #()
]

{ #category : #testing }
MCAncestry >> isMCInfoProxy [
	^ false
]

{ #category : #ancestry }
MCAncestry >> isRelatedTo: aVersionInfo [
	^ aVersionInfo timeStamp < self timeStamp
		ifTrue: [self hasAncestor: aVersionInfo]
		ifFalse: [aVersionInfo hasAncestor: self]
]

{ #category : #progeny }
MCAncestry >> lastMergeOf: aNode and: anotherNode [
	"Find the last merge of two Nodes starting from myself.
	Answer nil if there is none.
	Note: there might have been several merges, in which case we take the common merge of merges.
	Example: if c is a merge of a and b, d is also a merge of a and b, and e is a merge of c and d, then asnwer e."

	| common |
	(self hasAncestor: aNode) ifFalse: [^nil].
	(self hasAncestor: anotherNode) ifFalse: [^nil].
	common := ancestors collect: [:e | e lastMergeOf: aNode and: anotherNode] as: Set.
	common remove: nil ifAbsent: [].
	common size = 1 ifTrue: [^common anyOne].
	^self
	
]

{ #category : #ancestry }
MCAncestry >> names [
	"The names of the ancestors."
	^ self ancestors collect: [ : each | each name asMCVersionName ]
]

{ #category : #copying }
MCAncestry >> postCopyWithTrimmedAncestry [
	ancestors ifNotNil:
		[ ancestors := ancestors collect:
			[ : each | each copy
				 clearAncestors ;
				 clearStepChildren ;
				 yourself ] ].
	stepChildren ifNotNil:
		[ stepChildren := stepChildren collect:
			[ : each | each copy
				 clearAncestors ;
				 clearStepChildren ;
				 yourself ] ]
]

{ #category : #ancestry }
MCAncestry >> stepChildren [
	^ stepChildren ifNil: [#()]
]

{ #category : #ancestry }
MCAncestry >> stepChildrenString [
	^ String streamContents:
		[:s | self stepChildren do: [:ea | s nextPutAll: ea name] separatedBy: [s nextPutAll: ', ']]
]

{ #category : #'initialize-release' }
MCAncestry >> stubAncestryFor: aMCWorkingCopy using: aMCRepository [ 
	"childInfo was retrieved from aMCRepository.  Replace my ancestry with a Proxy that can retrieve the full tree from these two elements."
	ancestors := ancestors collect:
		[ : each | each isMCInfoProxy
			ifTrue: [ each ]
			ifFalse:
				[ MCInfoProxy
					info: each copyWithTrimmedAncestry
					workingCopy: aMCWorkingCopy
					repository: aMCRepository ] ].
	stepChildren := stepChildren collect:
		[ : each | each isMCInfoProxy
			ifTrue: [ each ]
			ifFalse:
				[ MCInfoProxy
					info: each copyWithTrimmedAncestry
					workingCopy: aMCWorkingCopy
					repository: aMCRepository ] ]
]

{ #category : #ancestry }
MCAncestry >> topologicalAncestors [
	"Answer all ancestors in topological order (that is, children always come before all their ancestors). If multiple such orderings are possible, arbitrate by time stamp."	
	^ Array streamContents:
		[:s | | frontier next |
		frontier := MCFrontier frontierOn: self.
		next := self.
		[	frontier remove: next.
			s nextPut: next.
			next := frontier frontier detectMax: [:v | v timeStamp].
			next isNil] whileFalse]
]

{ #category : #ancestry }
MCAncestry >> withBreadthFirstAncestors [
	^ { self }, self breadthFirstAncestors
]
