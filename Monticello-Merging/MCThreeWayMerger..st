Class {
	#name : #MCThreeWayMerger,
	#superclass : #MCMerger,
	#instVars : [
		'index',
		'operations',
		'provisions',
		'redundantAdds'
	],
	#category : #'Monticello-Merging'
}

{ #category : #'instance creation' }
MCThreeWayMerger class >> base: aSnapshot patch: aPatch [
	aPatch isEmpty ifTrue: [MCNoChangesException signal].
	^ self new
		addBaseSnapshot: aSnapshot;
		applyPatch: aPatch;
		yourself
		
]

{ #category : #'instance creation' }
MCThreeWayMerger class >> base: aSnapshot target: targetSnapshot ancestor: ancestorSnapshot [
	^ self base: aSnapshot patch: (targetSnapshot patchRelativeToBase: ancestorSnapshot)
]

{ #category : #'instance creation' }
MCThreeWayMerger class >> new [
	^ self basicNew initialize
]

{ #category : #'as yet unclassified' }
MCThreeWayMerger >> addBaseSnapshot: aSnapshot [
	aSnapshot definitions do:
		[:ea |
		index add: ea.
		provisions addAll: ea provisions]
]

{ #category : #'as yet unclassified' }
MCThreeWayMerger >> addDefinition: aDefinition [
	index
		definitionLike: aDefinition
		ifPresent: [:other |
			(self removalForDefinition: aDefinition)
				ifNotNil:
					[:op |
					self addOperation: (MCModification of: other to: aDefinition).
					self removeOperation: op.
					^ self].
			other = aDefinition
				ifFalse: [self addConflictWithOperation: (MCModification of: other to: aDefinition)]
				ifTrue: [self redundantAdds add: aDefinition]]
		ifAbsent: [self addOperation: (MCAddition of: aDefinition)]
]

{ #category : #'as yet unclassified' }
MCThreeWayMerger >> addOperation: anOperation [
	self operations add: anOperation
]

{ #category : #applying }
MCThreeWayMerger >> applyPatch: aPatch [
	aPatch applyTo: self
]

{ #category : #applying }
MCThreeWayMerger >> applyTo: anObject [
	super applyTo: anObject.
	self operations do: [:ea | ea applyTo: anObject]
]

{ #category : #'as yet unclassified' }
MCThreeWayMerger >> baseSnapshot [
	^ (MCSnapshot fromDefinitions: index definitions)
]

{ #category : #'initialize-release' }
MCThreeWayMerger >> initialize [
	index := MCDefinitionIndex new.
	provisions := Set new
]

{ #category : #'as yet unclassified' }
MCThreeWayMerger >> modificationConflictForDefinition: aDefinition [
	^ conflicts ifNotNil:
		[conflicts detect:
			[:ea | (ea definition isRevisionOf: aDefinition) and:
				[ea operation isModification]] ifNone: []]
]

{ #category : #'as yet unclassified' }
MCThreeWayMerger >> modifyDefinition: baseDefinition to: targetDefinition [
	index
		definitionLike: baseDefinition
		ifPresent: [:other | other = baseDefinition
								ifTrue: [self addOperation: (MCModification of:  baseDefinition to: targetDefinition)]
								ifFalse: [other = targetDefinition
											ifFalse: [self addConflictWithOperation:
														(MCModification of: other to: targetDefinition)]]]
		ifAbsent: [self addConflictWithOperation: (MCAddition of: targetDefinition)]
]

{ #category : #accessing }
MCThreeWayMerger >> operations [
	^ operations ifNil: [operations := OrderedCollection new]
]

{ #category : #accessing }
MCThreeWayMerger >> provisions [
	^ provisions
]

{ #category : #'as yet unclassified' }
MCThreeWayMerger >> redundantAdds [
	^ redundantAdds ifNil: [redundantAdds := Set new]
]

{ #category : #'as yet unclassified' }
MCThreeWayMerger >> removalForDefinition: aDefinition [
	^ operations ifNotNil:
		[operations
			detect: [:ea | (ea definition isRevisionOf: aDefinition) and: [ea isRemoval]]
			ifNone: []]
]

{ #category : #'as yet unclassified' }
MCThreeWayMerger >> removeConflict: aConflict [
	conflicts remove: aConflict
]

{ #category : #'as yet unclassified' }
MCThreeWayMerger >> removeDefinition: aDefinition [
	index
		definitionLike: aDefinition
		ifPresent: [:other | other = aDefinition
								ifTrue:
									[(self modificationConflictForDefinition: aDefinition)
										ifNotNil:
											[:c |
											self addOperation: c operation.
											self removeConflict: c.
											^ self]. 
									(self redundantAdds includes: aDefinition)
										ifFalse: [self addOperation: (MCRemoval of: aDefinition)]]
								ifFalse:
									[self addConflictWithOperation: (MCRemoval of: other)]]
		ifAbsent: []
]

{ #category : #'as yet unclassified' }
MCThreeWayMerger >> removeOperation: anOperation [
	operations remove: anOperation
]
