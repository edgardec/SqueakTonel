"
I am a place-holder for information needed by the Debugger to inspect method activations.  See DebuggerMethodMap's comment. I map methods compiled using full block closures, where block methods are objects separate from the home mehtod, as is the case with the SistaV1 bytecode set.

Instance variables
	(inherited)
	abstractSourceRanges <Dictionary of: CompiledCode -> (Dictionary of: Integer-> Interval)
	startKeysToTempRefs <Dictionary of: CompiledCode -> Array of: (Array with: String with: temp reference)> where
		temp reference ::= Integer
							| (Array with: Integer with: Integer)
							| (Array with: #outer with: temp reference)
	(locally defined)
	sortedSourceMaps <Dictionary of: CompiledCode -> (Dictionary of: Integer-> Interval)
"
Class {
	#name : #DebuggerMethodMapForFullBlockCompiledMethods,
	#superclass : #DebuggerMethodMapForClosureCompiledMethods,
	#instVars : [
		'sortedSourceMaps'
	],
	#category : #'Tools-Debugger'
}

{ #category : #'source mapping' }
DebuggerMethodMapForFullBlockCompiledMethods >> abstractSourceMap [
	self shouldNotImplement
]

{ #category : #'source mapping' }
DebuggerMethodMapForFullBlockCompiledMethods >> abstractSourceMapForMethod: compiledCode [
	"Answer with a Dictionary of abstractPC <Integer> to sourceRange <Interval>
	 for compiledCode which may be either a CompiledMethod or a CompiledBlock."
	| rawSourceRanges theMethodToScan |
	abstractSourceRanges ifNotNil:
		[^abstractSourceRanges at: compiledCode].
	abstractSourceRanges := IdentityDictionary new.
	"If the methodNode hasn't had a method generated it doesn't have pcs set in its
	 nodes so we must generate a new method.  We use this method for scanning
	 since its rawSourceRanges refer to the block methods within the method, and
	 that means we can use identity comparisons to match nodes with blocks."
	methodNode rawSourceRangesAndMethodDo:
		[:ranges :method|
		 rawSourceRanges := ranges.
		 theMethodToScan := method].
	self scanMethod: theMethodToScan mappingRanges: rawSourceRanges.
	self mapBlockMethodKeysIn: theMethodToScan toActualBlockMethodsIn: compiledCode homeMethod.
	^abstractSourceRanges at: compiledCode
]

{ #category : #'source mapping' }
DebuggerMethodMapForFullBlockCompiledMethods >> mapBlockMethodKeysIn: theMethodToScan toActualBlockMethodsIn: actualMethod [
	abstractSourceRanges at: actualMethod put: (abstractSourceRanges removeKey: theMethodToScan).
	1 to: theMethodToScan numLiterals - 1 do: "i.e. don't scan the last literal which, in CompiledBlocks is a back pointer"
		[:i| | lit |
		 (lit := theMethodToScan literalAt: i) isCompiledCode ifTrue:
			[self mapBlockMethodKeysIn: lit toActualBlockMethodsIn: (actualMethod literalAt: i)]]
]

{ #category : #private }
DebuggerMethodMapForFullBlockCompiledMethods >> newBlockStartMap [
	"If blocks are embedded then keys in the map are simple integer pcs and a Dictionary can be used.
	 If blocks are full (separate method objects) then keys in the map are CompiledBlocks and
	 IdentityDictionary must be used to avoid confusing blocks with identical code."
	^WeakIdentityKeyDictionary new
]

{ #category : #'source mapping' }
DebuggerMethodMapForFullBlockCompiledMethods >> rangeForPC: contextsConcretePC in: method contextIsActiveContext: contextIsActiveContext [
	"Answer the indices in the source code for the supplied pc.
	 If the context is the actve context (is at the hot end of the stack)
	 then its pc is the current pc.  But if the context isn't, because it is
	 suspended sending a message, then its current pc is the previous pc."

	| pc i end mapForMethod sortedMap |
	pc := method abstractPCForConcretePC: (contextIsActiveContext
													ifTrue: [contextsConcretePC]
													ifFalse: [(method pcPreviousTo: contextsConcretePC)
																ifNotNil: [:prevpc| prevpc]
																ifNil: [contextsConcretePC]]).
	((mapForMethod := self abstractSourceMapForMethod: method) includesKey: pc) ifTrue:
		[^mapForMethod at: pc].
	sortedSourceMap ifNil:
		[sortedSourceMap := IdentityDictionary new].
	sortedMap := sortedSourceMap
						at: method
						ifAbsentPut: [mapForMethod associations
										replace: [ :each | each copy ];
										sort].
	sortedMap isEmpty ifTrue: [^1 to: 0].
	i := sortedMap findNearbyBinaryIndex: [:assoc| pc - assoc key].
	i < 1 ifTrue: [^1 to: 0].
	i > sortedMap size ifTrue:
		[end := sortedMap inject: 0 into:
			[:prev :this | prev max: this value last].
		^end+1 to: end].
	^(sortedMap at: i) value

	"| method source scanner map |
	 method := DebuggerMethodMapForFullBlockCompiledMethods compiledMethodAt: #rangeForPC:in:contextIsActiveContext:.
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
DebuggerMethodMapForFullBlockCompiledMethods >> scanMethod: theMethodToScan mappingRanges: rawSourceRanges [
	| abstractPC scanner client maybeBlock concreteSourceRanges rangesForMethod |
	rangesForMethod := (abstractSourceRanges at: theMethodToScan put: Dictionary new).
	concreteSourceRanges := Dictionary new.
	"The rawSourceRanges map node pcs to ranges.
	 When node is one in the home method the node's pc is an integer.
	When the node is within a block method the node's pc is an association from CompiledBlock to pc.
	 Extract pc -> range for this particular CompiledMethod or CompiledBlock."
	rawSourceRanges keysAndValuesDo:
		(theMethodToScan isCompiledMethod
			ifTrue:
				[[:node :range|
				   (node pc isVariableBinding
				    or: [node pc = 0]) ifFalse:
						[concreteSourceRanges at: node pc put: range]]]
			ifFalse:
				[[:node :range|
				   (node pc isVariableBinding
				    and: [node pc key == theMethodToScan
				    and: [node pc value ~= 0]]) ifTrue:
					[concreteSourceRanges at: node pc value put: range]]]).
	abstractPC := 1.
	scanner := InstructionStream on: theMethodToScan.
	client := BlockStartLocator new.
	[(concreteSourceRanges includesKey: scanner pc) ifTrue:
		[rangesForMethod at: abstractPC put: (concreteSourceRanges at: scanner pc)].
	 abstractPC := abstractPC + 1.
	 maybeBlock := scanner interpretNextInstructionFor: client.
	 (maybeBlock ~~ client
	  and: [maybeBlock isCompiledCode]) ifTrue:
		[self assert: maybeBlock isCompiledBlock.
		 self scanMethod: maybeBlock mappingRanges: rawSourceRanges].
	 scanner atEnd] whileFalse
]
