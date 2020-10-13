"
I am a place-holder for information needed by the Debugger to inspect method activations.  I insulate the debugger from details of code generation such as exact bytecode offsets and temporary variable locations.  I have two concrete subclasses, one for methods where block bytecodes are embedded in the home method and one for methods where blocks are separate objects (CompiledBlock).  These classes deal with temporary variable access. My function is to abstract the source map away from actual bytecode pcs to abstract bytecode pcs.  I used to have a subclass for ""BlueBook"" compiled methods, with non-closure blocks, but this was removed in October 2020 for simplicity's sake.

To reduce compilation time I try and defer as much computation to access time as possible as instances of me will be created after each compilation.

I maintain a WeakIdentityDictionary of method to DebuggerMethodMap to cache maps.  I refer to my method through a WeakArray to keep the map cache functional. If the reference from a DebuggerMethodMap to its method were strong then the method would never be dropped from the cache because the reference from its map would keep it alive.
"
Class {
	#name : #DebuggerMethodMap,
	#superclass : #Object,
	#instVars : [
		'timestamp',
		'methodReference',
		'methodNode',
		'startKeysToBlockExtents',
		'abstractSourceRanges',
		'sortedSourceMap'
	],
	#classVars : [
		'AccessLock',
		'MapCache',
		'MapCacheEntries'
	],
	#category : #'Tools-Debugger'
}

{ #category : #'debugger support' }
DebuggerMethodMap class >> cacheDebugMap: aDebuggerMethodMap forMethod: aCompiledMethod [
	
	^self protected: [ 
		MapCache size >= MapCacheEntries ifTrue: [
			MapCache slowSize >= MapCacheEntries 
				ifFalse: [ MapCache rehash ]
				ifTrue: [
					| mapsByAge |
					mapsByAge := MapCache keys sort: [ :m1 :m2 |
						"We are holding strongly on the keys, so #at: is suitable."
						(MapCache at: m1) timestamp < (MapCache at: m2) timestamp].
					mapsByAge from: 1 to: mapsByAge size - MapCacheEntries do: [ :each |
						MapCache removeKey: each ] ] ].
		MapCache
			at: aCompiledMethod
			put: aDebuggerMethodMap ]
]

{ #category : #'class initialization' }
DebuggerMethodMap class >> cleanUp [
	self initialize
]

{ #category : #'instance creation' }
DebuggerMethodMap class >> forMethod: aMethod [ "<CompiledMethod>"
	"Answer a DebuggerMethodMap suitable for debugging activations of aMethod.
	 Answer an existing instance from the cache if it exists, cacheing a new one if required."
	
	^self protected: [ 
		MapCache
			at: aMethod
			ifAbsent: [self
						cacheDebugMap:
							(self
								forMethod: aMethod
								methodNode: aMethod methodNode)
						forMethod: aMethod] ]
]

{ #category : #'instance creation' }
DebuggerMethodMap class >> forMethod: aMethod "<CompiledCode>" methodNode: methodNode [ "<MethodNode>"
	"Uncached instance creation method for private use or for tests.
	 Please consider using forMethod: instead."
	^(aMethod encoderClass supportsFullBlocks
			ifTrue: [DebuggerMethodMapForFullBlockCompiledMethods]
			ifFalse: [DebuggerMethodMapForClosureCompiledMethods]) new
		forMethod: aMethod homeMethod
		methodNode: methodNode
]

{ #category : #'class initialization' }
DebuggerMethodMap class >> initialize [
	"DebuggerMethodMap initialize"

	self voidMapCache
]

{ #category : #synchronization }
DebuggerMethodMap class >> protected: aBlock [

	^(AccessLock ifNil: [ AccessLock := Mutex new ]) critical: aBlock
]

{ #category : #'class initialization' }
DebuggerMethodMap class >> voidMapCache [

	self protected: [ 
		MapCache := WeakIdentityKeyDictionary new.
		MapCacheEntries := 16 ]
]

{ #category : #private }
DebuggerMethodMap >> abstractSourceMap [
	"Answer with a Dictionary of abstractPC <Integer> to sourceRange <Interval>."
	| theMethodToScan rawSourceRanges concreteSourceRanges abstractPC scanner client |
	abstractSourceRanges ifNotNil:
		[^abstractSourceRanges].
	"If the methodNode hasn't had a method generated it doesn't have pcs set in its
	 nodes so we must generate a new method and might as well use it for scanning."
	methodNode rawSourceRangesAndMethodDo:
		[:ranges :method|
		 rawSourceRanges := ranges.
		 theMethodToScan := method].
	concreteSourceRanges := Dictionary new.
	rawSourceRanges keysAndValuesDo:
		[:node :range|
		node pc ~= 0 ifTrue:
			[concreteSourceRanges at: node pc put: range]].
	abstractPC := 1.
	abstractSourceRanges := Dictionary new.
	scanner := InstructionStream on: theMethodToScan.
	client := InstructionClient new.
	[(concreteSourceRanges includesKey: scanner pc) ifTrue:
		[abstractSourceRanges at: abstractPC put: (concreteSourceRanges at: scanner pc)].
	 abstractPC := abstractPC + 1.
	 scanner interpretNextInstructionFor: client.
	 scanner atEnd] whileFalse.
	^abstractSourceRanges
]

{ #category : #'source mapping' }
DebuggerMethodMap >> abstractSourceMapForMethod: aCompiledMethod [
	"The default source mapping is for block bytecodes embedded within a
	 single compiled method, as in the BlueBook and EncoderForV3PlusClosures."
	^self abstractSourceMap
]

{ #category : #private }
DebuggerMethodMap >> blockExtentsInto: aDictionary from: initialPC to: endPC method: method numberer: numbererBlock [
	"Support routine for startpcsToBlockExtents"
	| pcs extentStart locator scanner blockSizeOrMethodOrLocator |
	extentStart := numbererBlock value.
	locator := BlockStartLocator new.
	scanner := InstructionStream new method: method pc: initialPC.
	pcs := OrderedCollection new.
	[pcs addLast: scanner pc.
	 scanner pc <= endPC] whileTrue:
		[blockSizeOrMethodOrLocator := scanner interpretNextInstructionFor: locator.
		 blockSizeOrMethodOrLocator ~~ locator ifTrue:
			 [blockSizeOrMethodOrLocator isInteger
				ifTrue:
					[self
						blockExtentsInto: aDictionary
						from: scanner pc
						to: scanner pc + blockSizeOrMethodOrLocator - 1
						method: method
						numberer: numbererBlock.
					 scanner pc: scanner pc + blockSizeOrMethodOrLocator]
				ifFalse:
					[self assert: blockSizeOrMethodOrLocator isCompiledBlock.
					 self
						blockExtentsInto: aDictionary
						from: blockSizeOrMethodOrLocator initialPC
						to: blockSizeOrMethodOrLocator endPC
						method: blockSizeOrMethodOrLocator
						numberer: numbererBlock]]].
	aDictionary
		at: (method isCompiledBlock
				ifTrue: [method]
				ifFalse: [initialPC])
		put: (extentStart to: numbererBlock value).
	^aDictionary
]

{ #category : #'initialize-release' }
DebuggerMethodMap >> forMethod: aMethod "<CompiledMethod>" methodNode: theMethodNode [ "<MethodNode>"
	methodReference := WeakArray with: aMethod.
	methodNode := theMethodNode.
	self markRecentlyUsed
]

{ #category : #private }
DebuggerMethodMap >> markRecentlyUsed [
	timestamp := Time totalSeconds
]

{ #category : #accessing }
DebuggerMethodMap >> method [
	^methodReference at: 1
]

{ #category : #accessing }
DebuggerMethodMap >> namedTempAt: index in: aContext [
	"Answer the value of the temp at index in aContext where index is relative
	 to the array of temp names answered by tempNamesForContext:"
	self assert: aContext method homeMethod == self method.
	^self
		privateTempAt: index
		in: aContext
		startKeysToBlockExtents: self startKeysToBlockExtents
]

{ #category : #accessing }
DebuggerMethodMap >> namedTempAt: index put: aValue in: aContext [
	"Assign the value of the temp at index in aContext where index is relative
	 to the array of temp names answered by tempNamesForContext:.
	 If the value is a copied value we also need to set it along the lexical chain."
	self assert: aContext method homeMethod == self method.
	^self
		privateTempAt: index
		in: aContext
		put: aValue
		startKeysToBlockExtents: self startKeysToBlockExtents
]

{ #category : #'source mapping' }
DebuggerMethodMap >> rangeForPC: contextsConcretePC in: method contextIsActiveContext: contextIsActiveContext [
	"Answer the indices in the source code for the supplied pc.
	 If the context is the actve context (is at the hot end of the stack)
	 then its pc is the current pc.  But if the context isn't, because it is
	 suspended sending a message, then its current pc is the previous pc."

	| pc abstractMap i end |
	pc := method abstractPCForConcretePC: (contextIsActiveContext
													ifTrue: [contextsConcretePC]
													ifFalse: [(method pcPreviousTo: contextsConcretePC)
																ifNotNil: [:prevpc| prevpc]
																ifNil: [contextsConcretePC]]).
	abstractMap := self abstractSourceMapForMethod: method.
	(abstractMap includesKey: pc) ifTrue:
		[^abstractMap at: pc].
	sortedSourceMap ifNil:
		[sortedSourceMap := abstractMap associations
			replace: [ :each | each copy ];
			sort].
	sortedSourceMap isEmpty ifTrue: [^1 to: 0].
	i := sortedSourceMap findNearbyBinaryIndex: [:assoc| pc - assoc key].
	i < 1 ifTrue: [^1 to: 0].
	i > sortedSourceMap size ifTrue:
		[end := sortedSourceMap inject: 0 into:
			[:prev :this | prev max: this value last].
		^end+1 to: end].
	^(sortedSourceMap at: i) value

	"| method source scanner map |
	 method := DebuggerMethodMap compiledMethodAt: #rangeForPC:in:contextIsActiveContext:.
	 source := method getSourceFromFile asString.
	 scanner := InstructionStream on: method.
	 map := method debuggerMap.
	 Array streamContents:
		[:ranges|
		[scanner atEnd] whileFalse:
			[| range |
			 range := map rangeForPC: scanner pc in: method contextIsActiveContext: true.
			 ((map abstractSourceMap includesKey: scanner abstractPC)
			  and: [range first ~= 0]) ifTrue:
				[ranges nextPut: (source copyFrom: range first to: range last)].
			scanner interpretNextInstructionFor: InstructionClient new]]"
]

{ #category : #'source mapping' }
DebuggerMethodMap >> sourceText [
	self method ifNotNil:
		[:method|
		method holdsTempNames ifTrue:
			[^method
				getSourceFor: (method selector ifNil: [method defaultSelector])
				in: method methodClass]].
	^methodNode sourceText
]

{ #category : #private }
DebuggerMethodMap >> startKeysToBlockExtents [
	"Answer the map from start keys (either start pcs for embedded closures, or
	 full block methods for full blocks) to the block extents in that method, where
	 a block extent is an abstract representation of block nesting within a method."

	startKeysToBlockExtents ifNil:
		[| index method |
		 index := 0.
		 method := self method homeMethod.
		 startKeysToBlockExtents := 
			self
				blockExtentsInto: self newBlockStartMap
				from: method initialPC
				to: method endPC
				method: method
				numberer: [| value | value := index. index := index + 2. value]].
	^startKeysToBlockExtents
]

{ #category : #accessing }
DebuggerMethodMap >> tempNamesForContext: aContext [
	"Answer an Array of all the temp names in scope in aContext starting with
	 the home's first local (the first argument or first temporary if no arguments)."
	self assert: aContext method homeMethod == self method.
	^(self
		privateTempRefsForContext: aContext
		startKeysToBlockExtents: self startKeysToBlockExtents) collect:
			[:pair| pair first]
]

{ #category : #accessing }
DebuggerMethodMap >> tempNamesForMethod: aMethod [
	"Answer an Array of all the temp names in scope in aMethod starting with
	 the home's first local (the first argument or first temporary if no arguments)."
	self assert: aMethod homeMethod == self method.
	^(self
		privateTempRefsForMethod: aMethod
		startKeysToBlockExtents: self startKeysToBlockExtents) collect:
			[:pair| pair first]
]

{ #category : #accessing }
DebuggerMethodMap >> tempsAndValuesForContext: aContext [
	"Return a string of the temporary variables and their current values"
	| aStream |
	aStream := WriteStream on: (String new: 100).
	(self tempNamesForContext: aContext) doWithIndex:
		[:title :index |
		 aStream nextPutAll: title; nextPut: $:; space; tab.
		 aContext print: (self namedTempAt: index in: aContext) on: aStream.
		 aStream cr].
	^aStream contents
]

{ #category : #private }
DebuggerMethodMap >> timestamp [
	^timestamp
]
