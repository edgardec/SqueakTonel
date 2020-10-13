"
I am a place-holder for information needed by the Debugger to inspect method activations.  See my superclass's comment. I map methods compiled using closures whose bytecodes are embedded within the home CompiledMethod, as is the case for the V3PlusClosures bytecode set.

Instance variables
	blockExtentsToTempsRefs <Dictionary of: Interval -> Array of: (Array with: String with: (Integer | (Array with: Integer with: Integer)))>
		maps a block extent to an Array of temp references for that block/method.
		Each reference is a pair of temp name and index, where the index can itself be a pair for a remote temp.
	startKeysToTempRefs <Dictionary of: Integer startpc -> Array of: (Array with: String with: temp reference)> where
		temp reference ::= Integer
							| (Array with: Integer with: Integer)
							| (Array with: #outer with: temp reference)
"
Class {
	#name : #DebuggerMethodMapForClosureCompiledMethods,
	#superclass : #DebuggerMethodMap,
	#instVars : [
		'blockExtentsToTempRefs',
		'startpcsToTempRefs',
		'startKeysToTempRefs'
	],
	#classVars : [
		'FirstTime'
	],
	#category : #'Tools-Debugger'
}

{ #category : #private }
DebuggerMethodMapForClosureCompiledMethods >> newBlockStartMap [
	"If blocks are embedded then keys in the map are simple integer pcs and a Dictionary can be used.
	 If blocks are full (separate method objects) then keys in the map are CompiledBlocks and
	 IdentityDictionary must be used to avoid confusing blocks with identical code."
	^Dictionary new
]

{ #category : #private }
DebuggerMethodMapForClosureCompiledMethods >> privateDereference: tempReference in: aContext [
	"Fetch the temporary with reference tempReference in aContext.
	 tempReference can be
		integer - direct temp reference
		#( indirectionVectorIndex tempIndex ) - remote temp in indirectionVector at index
		#( outer. temp reference ) - a temp reference in an outer context."
	^tempReference isInteger
		ifTrue:
			[tempReference <= aContext stackPtr ifTrue:
				[aContext tempAt: tempReference]]
		ifFalse:
			[tempReference first == #outer
				ifTrue:
					[self privateDereference: tempReference last
						in: aContext outerContext]
				ifFalse: "If stopped before indirection vectors are created they will be nil. Simply answer nil"
					[tempReference first <= aContext stackPtr ifTrue:
						[(aContext tempAt: tempReference first) ifNotNil:
							[:indirectionVector|
							indirectionVector at: tempReference second]]]]
]

{ #category : #private }
DebuggerMethodMapForClosureCompiledMethods >> privateDereference: tempReference in: aContext put: aValue [
	"Assign the temporary with reference tempReference in aContext.
	 tempReference can be
		integer - direct temp reference
		#( indirectionVectorIndex tempIndex ) - remote temp in indirectionVector at index
		#( outer. temp reference ) - a temp reference in an outer context."
	^tempReference isInteger
		ifTrue:
			[tempReference <= aContext stackPtr
				ifTrue:
					[aContext tempAt: tempReference put: aValue]
				ifFalse:
					[UIManager default inform: 'Cannot assign temp because it is no longer on stack.\Activation has returned?' withCRs.
							nil]]
		ifFalse:
			[tempReference first == #outer
				ifTrue:
					[self privateDereference: tempReference last
						in: aContext outerContext
						put: aValue]
				ifFalse: "If stopped before indirection vectors are created they will be nil."
					[tempReference first <= aContext stackPtr
						ifTrue:
							[(aContext tempAt: tempReference first)
								ifNil: [UIManager default inform: 'Cannot assign remote temp because indirection vector is nil.\Too early in method execution?' withCRs.
									nil]
								ifNotNil:
									[:indirectionVector|
									indirectionVector
										at: tempReference second
										put: aValue]]
						ifFalse:
							[UIManager default inform: 'Cannot assign remote temp because it is no longer on stack.\Activation has returned?' withCRs.
							nil]]]
]

{ #category : #private }
DebuggerMethodMapForClosureCompiledMethods >> privateTempAt: index in: aContext put: aValue startKeysToBlockExtents: theContextsStartKeysToBlockExtents [
	| nameRefPair |
	nameRefPair := (self privateTempRefsForContext: aContext
						 startKeysToBlockExtents: theContextsStartKeysToBlockExtents)
						at: index
						ifAbsent: [aContext errorSubscriptBounds: index].
	^self privateDereference: nameRefPair last in: aContext put: aValue
]

{ #category : #private }
DebuggerMethodMapForClosureCompiledMethods >> privateTempAt: index in: aContext startKeysToBlockExtents: theContextsStartKeysToBlockExtents [
	| nameRefPair |
	nameRefPair := (self privateTempRefsForContext: aContext
						 startKeysToBlockExtents: theContextsStartKeysToBlockExtents)
						at: index
						ifAbsent: [aContext errorSubscriptBounds: index].
	^self privateDereference: nameRefPair last in: aContext
]

{ #category : #private }
DebuggerMethodMapForClosureCompiledMethods >> privateTempRefsForContext: aContext startKeysToBlockExtents: theContextsStartKeysToBlockExtents [
	"Answer the sequence of temps in scope in aContext in the natural order,
	 outermost arguments and temporaries first, innermost last.  Each temp is
	 a pair of the temp's name followed by a reference.  The reference can be
		integer - index of temp in aContext
		#( indirectionVectorIndex tempIndex ) - remote temp in indirectionVector at index in aContext
		#( outer. temp reference ) - a temp reference in an outer context."
	blockExtentsToTempRefs ifNil:
		[blockExtentsToTempRefs := (aContext method holdsTempNames
										ifTrue: [aContext method]
										ifFalse: [methodNode]) blockExtentsToTempsMap.
		 blockExtentsToTempRefs
			ifNil: ["an empty method.  shouldn't be able to step into here but it
				  can happen in weird circumstances (i.e. with MethodWrapper)."
				blockExtentsToTempRefs := Dictionary new.
				blockExtentsToTempRefs
					at: (theContextsStartKeysToBlockExtents at: aContext startKey)
					put: {}]
			ifNotNil:
				[(blockExtentsToTempRefs isKindOf: IdentityDictionary) ifTrue:
					[blockExtentsToTempRefs := Dictionary withAll: blockExtentsToTempRefs associations]].
		 startKeysToTempRefs := self newBlockStartMap].
	^startKeysToTempRefs
		at: aContext startKey
		ifAbsentPut:
			[| localRefs |
			 localRefs := blockExtentsToTempRefs at: (theContextsStartKeysToBlockExtents at: aContext startKey) ifAbsent: [#()].
			 aContext outerContext
				ifNil: [localRefs]
				ifNotNil:
					[:outer| | outerTemps |
					"Present temps in the order outermost to innermost left-to-right, but replace
					 copied outermost temps with their innermost copies"
					 outerTemps := (self
										privateTempRefsForContext: outer
										startKeysToBlockExtents: theContextsStartKeysToBlockExtents) collect:
						[:outerPair|
						localRefs
							detect: [:localPair| outerPair first = localPair first]
							ifNone: [{ outerPair first. { #outer. outerPair last } }]].
					outerTemps,
					 (localRefs reject: [:localPair| outerTemps anySatisfy: [:outerPair| localPair first = outerPair first]])]]
]

{ #category : #private }
DebuggerMethodMapForClosureCompiledMethods >> privateTempRefsForMethod: method startKeysToBlockExtents: startKeysToBlockExtents [
	"Answer the sequence of temps in scope in method in the natural order,
	 outermost arguments and temporaries first, innermost last.  Each temp is
	 a pair of the temp's name followed by a reference.  The reference can be
		integer - index of temp in aContext
		#( indirectionVectorIndex tempIndex ) - remote temp in indirectionVector at index in aContext
		#( outer. temp reference ) - a temp reference in an outer context."
	blockExtentsToTempRefs ifNil:
		[blockExtentsToTempRefs := (method holdsTempNames
										ifTrue: [method]
										ifFalse: [methodNode]) blockExtentsToTempsMap.
		 blockExtentsToTempRefs ifNil:
			["an empty method.  shouldn't be able to step into here but it
			  can happen in weird circumstances (i.e. with MethodWrapper)."
			blockExtentsToTempRefs := Dictionary new.
			blockExtentsToTempRefs
				at: (startKeysToBlockExtents at: method startKey)
				put: {}].
		 startKeysToTempRefs := Dictionary new].
	^startKeysToTempRefs
		at: method startKey
		ifAbsentPut:
			[blockExtentsToTempRefs at: (startKeysToBlockExtents at: method startKey)]
]
