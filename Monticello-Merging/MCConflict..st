Class {
	#name : #MCConflict,
	#superclass : #Object,
	#instVars : [
		'operation',
		'chooseRemote'
	],
	#category : #'Monticello-Merging'
}

{ #category : #'instance creation' }
MCConflict class >> operation: anOperation [
	^ self new operation: anOperation	
]

{ #category : #accessing }
MCConflict >> annotations [
	^operation ifNotNil: [ :op | op annotations ]
]

{ #category : #applying }
MCConflict >> applyTo: anObject [
	self isResolved ifFalse: [self error: 'Cannot continue until this conflict has been resolved'].
	self remoteChosen ifTrue: [operation applyTo: anObject].
]

{ #category : #'resolving ' }
MCConflict >> chooseLocal [
	chooseRemote := false
]

{ #category : #'resolving ' }
MCConflict >> chooseNewer [
	self isLocalNewer ifTrue: [ self chooseLocal ]
		ifFalse: [ self isRemoteNewer ifTrue: [ self chooseRemote ]]
]

{ #category : #'resolving ' }
MCConflict >> chooseOlder [
	self isRemoteNewer ifTrue: [ self chooseLocal ]
		ifFalse: [ self isLocalNewer ifTrue: [ self chooseRemote ]]
]

{ #category : #'resolving ' }
MCConflict >> chooseRemote [
	chooseRemote := true
]

{ #category : #'resolving ' }
MCConflict >> chooseSameAST [
	| fromSrc toSrc |
	(self definition isNil or: [self definition isMethodDefinition not])
		ifTrue: [^ self].
	fromSrc := (Parser new parse: operation fromSource class: nil class)
		generate decompile asString.
	toSrc := (Parser new parse: operation toSource class: nil class)
		generate decompile asString.
	fromSrc = toSrc ifTrue: [self chooseLocal].
]

{ #category : #'resolving ' }
MCConflict >> clearChoice [
	chooseRemote := nil
]

{ #category : #accessing }
MCConflict >> definition [
	^operation ifNotNil: [ :op | op definition ]
]

{ #category : #testing }
MCConflict >> isConflict [
	^true
]

{ #category : #testing }
MCConflict >> isLocalNewer [
	^ self localDefinition fullTimeStamp > self remoteDefinition fullTimeStamp
]

{ #category : #testing }
MCConflict >> isRemoteNewer [
	^ self localDefinition fullTimeStamp < self remoteDefinition fullTimeStamp
]

{ #category : #testing }
MCConflict >> isResolved [
	^ chooseRemote notNil
]

{ #category : #testing }
MCConflict >> localChosen [
	^ chooseRemote notNil and: [chooseRemote not]
]

{ #category : #accessing }
MCConflict >> localDefinition [
	^ operation baseDefinition
]

{ #category : #accessing }
MCConflict >> operation [
	^ operation
]

{ #category : #accessing }
MCConflict >> operation: anOperation [
	operation := anOperation
]

{ #category : #testing }
MCConflict >> remoteChosen [
	^ chooseRemote notNil and: [chooseRemote]
]

{ #category : #testing }
MCConflict >> remoteDefinition [
	^ operation targetDefinition
]

{ #category : #accessing }
MCConflict >> source [
	^ self localChosen
		ifTrue: [operation fromSource]
		ifFalse: [operation source]
]

{ #category : #accessing }
MCConflict >> status [
	^ self isResolved
		ifFalse: ['']
		ifTrue: [self remoteChosen
					ifFalse: ['L']
					ifTrue: ['R']]
]

{ #category : #accessing }
MCConflict >> summary [
	| attribute |
	attribute := 
		self isResolved
			ifTrue: [self remoteChosen ifTrue: [#underlined] ifFalse: [#struckOut]]
			ifFalse: [#bold].
	^ Text string: operation summary attribute: (TextEmphasis perform: attribute)
]
