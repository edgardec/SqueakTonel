Class {
	#name : #TileMessageNode,
	#superclass : #MessageNode,
	#category : #'Etoys-Tile Scriptors'
}

{ #category : #printing }
TileMessageNode >> printIfNilNotNil: aMorph indent: level [

	| newNode |
	newNode := aMorph parseNode shallowCopy.
	newNode receiver ifNotNil:
		[newNode receiver: newNode receiver ifNilReceiver].	"fudge so it prints right"

	(arguments first isJust: NodeNil) ifTrue:
		[^ newNode morphFromKeywords: #ifNotNil:
				arguments: { arguments second }
				on: aMorph indent: level].
	(arguments second isJust: NodeNil) ifTrue:
		[^ newNode morphFromKeywords: #ifNil:
				arguments: { arguments first }
				on: aMorph indent: level].
	^ newNode morphFromKeywords: #ifNil:ifNotNil:
			arguments: arguments
			on: aMorph indent: level
]

{ #category : #printing }
TileMessageNode >> printIfOn: aStream indent: level [ 
"Just copied the old MessageNode one down here."
	(arguments last isJust: NodeNil)
		ifTrue: [^ self
				printKeywords: #ifTrue:
				arguments: (Array with: arguments first)
				on: aStream
				indent: level].
	(arguments last isJust: NodeFalse)
		ifTrue: [^ self
				printKeywords: #and:
				arguments: (Array with: arguments first)
				on: aStream
				indent: level].
	(arguments first isJust: NodeNil)
		ifTrue: [^ self
				printKeywords: #ifFalse:
				arguments: (Array with: arguments last)
				on: aStream
				indent: level].
	(arguments first isJust: NodeTrue)
		ifTrue: [^ self
				printKeywords: #or:
				arguments: (Array with: arguments last)
				on: aStream
				indent: level].
	self
		printKeywords: #ifTrue:ifFalse:
		arguments: arguments
		on: aStream
		indent: level
]

{ #category : #printing }
TileMessageNode >> printKeywords: key arguments: args on: morph indent: level [

	^morph parseNode
		morphFromKeywords: key 
		arguments: args 
		on: morph 
		indent: level

]

{ #category : #printing }
TileMessageNode >> printReceiver: rcvr on: aMorph indent: level [
					
	"I don't think we need this to do anything since we already printed the receiver ourself"

]

{ #category : #printing }
TileMessageNode >> printToDoOn: aMorph indent: level [ 
	| limitNode |
	limitNode := (arguments last isNil 
				or: [(arguments last isMemberOf: AssignmentNode) not]) 
					ifTrue: [arguments first]
					ifFalse: [arguments last value].
	(selector key = #to:by:do: 
		and: [arguments second isConstantNumber and: [arguments second key = 1]]) 
			ifTrue: 
				[self 
					printKeywords: #to:do:
					arguments: (Array with: limitNode with: (arguments third))
					on: aMorph
					indent: level]
			ifFalse: 
				[self 
					printKeywords: selector key
					arguments: (Array with: limitNode) , arguments allButFirst
					on: aMorph
					indent: level]
]

{ #category : #printing }
TileMessageNode >> printWhileOn: aMorph indent: level [

	(arguments first isJust: NodeNil) ifTrue: [
		selector := SelectorNode new
			key: (selector key == #whileTrue:
				ifTrue: [#whileTrue] ifFalse: [#whileFalse])
			code: #macro.
		arguments := Array new
	].
	self printKeywords: selector key arguments: arguments
		on: aMorph indent: level
]

{ #category : #printing }
TileMessageNode >> printWithClosureAnalysisIfOn: aStream indent: level [ 
"Just copied the old MessageNode one down here."
	(arguments last isJust: NodeNil)
		ifTrue: [^self
				printWithClosureAnalysisKeywords: #ifTrue:
				arguments: (Array with: arguments first)
				on: aStream
				indent: level].
	(arguments last isJust: NodeFalse)
		ifTrue: [^self
				printWithClosureAnalysisKeywords: #and:
				arguments: (Array with: arguments first)
				on: aStream
				indent: level].
	(arguments first isJust: NodeNil)
		ifTrue: [^self
				printWithClosureAnalysisKeywords: #ifFalse:
				arguments: (Array with: arguments last)
				on: aStream
				indent: level].
	(arguments first isJust: NodeTrue)
		ifTrue: [^self
				printWithClosureAnalysisKeywords: #or:
				arguments: (Array with: arguments last)
				on: aStream
				indent: level].
	self
		printWithClosureAnalysisKeywords: #ifTrue:ifFalse:
		arguments: arguments
		on: aStream
		indent: level
]

{ #category : #printing }
TileMessageNode >> printWithClosureAnalysisReceiver: rcvr on: aMorph indent: level [
					
	"I don't think we need this to do anything since we already printed the receiver ourself"
]

{ #category : #printing }
TileMessageNode >> printWithClosureAnalysisToDoOn: aMorph indent: level [ 
	| limitNode |
	limitNode := (arguments last isNil 
				or: [(arguments last isMemberOf: AssignmentNode) not]) 
					ifTrue: [arguments first]
					ifFalse: [arguments last value].
	(selector key = #to:by:do: 
		and: [arguments second isConstantNumber and: [arguments second key == 1]]) 
			ifTrue: 
				[self 
					printWithClosureAnalysisKeywords: #to:do:
					arguments: (Array with: limitNode with: (arguments third))
					on: aMorph
					indent: level]
			ifFalse: 
				[self 
					printWithClosureAnalysisKeywords: selector key
					arguments: (Array with: limitNode) , arguments allButFirst
					on: aMorph
					indent: level]
]

{ #category : #printing }
TileMessageNode >> printWithClosureAnalysisWhileOn: aMorph indent: level [

	(arguments first isJust: NodeNil) ifTrue: [
		selector := SelectorNode new
			key: (selector key == #whileTrue:
				ifTrue: [#whileTrue] ifFalse: [#whileFalse])
			code: #macro.
		arguments := Array new
	].
	self printWithClosureAnalysisKeywords: selector key arguments: arguments
		on: aMorph indent: level
]
