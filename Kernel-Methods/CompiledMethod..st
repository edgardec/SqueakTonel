"
CompiledMethod instances are methods suitable for interpretation by the virtual machine.  They are a specialization of CompiledCode.  They represent methods, and may also, depending on the bytecode set, include nested blocks.  Bytecode sets that support non-nested blocks use CompiledBlock instances to implement nested block methods, that are separate from their enclosing method.  Bytecode sets that do not support non-nested blocks require the literals and bytecodes for a block to occur within the literals and bytecodes of a single CompiledMethod.  For example, the inject:into: method in the EncoderForV3PlusClosures bytecode set is as follows

Collection>>#inject:into:
	header	((primitive: 0) (numArgs: 2) (numTemps: 3) (numLiterals: 3) (frameSize: 16) (bytecodeSet: V3PlusClosures))
	literal1	#value:value:
	literal2	#inject:into:
	literal3	#Collection=>Collection
	33	<8A 01> push: (Array new: 1)
	35	<6A> popIntoTemp: 2
	36	<10> pushTemp: 0
	37	<8E 00 02> popIntoTemp: 0 inVectorAt: 2
	40	<70> self
	41	<11> pushTemp: 1
	42	<12> pushTemp: 2
	43	<8F 21 00 0A> closureNumCopied: 2 numArgs: 1 bytes 47 to 56
	47	        <11> pushTemp: 1
	48	        <8C 00 02> pushTemp: 0 inVectorAt: 2
	51	        <10> pushTemp: 0
	52	        <F0> send: value:value:
	53	        <8D 00 02> storeIntoTemp: 0 inVectorAt: 2
	56	        <7D> blockReturn
	57	<CB> send: do:
	58	<87> pop
	59	<8C 00 02> pushTemp: 0 inVectorAt: 2
	62	<7C> returnTop

whereas using the encoderForSistaV1 bytecode set it is

Collection>>#inject:into:
	header	((primitive: 0) (numArgs: 2) (numTemps: 3) (numLiterals: 3) (frameSize: 16) (bytecodeSet: #SistaV1))
	literal1	([] in Collection>>#inject:into: ""a CompiledBlock(3755867)"")
	literal2	#inject:into:
	literal3	#Collection=>Collection
	33	<E7 01> push: (Array new: 1)
	35	<D2> popIntoTemp: 2
	36	<40> pushTemp: 0
	37	<FD 00 02> popIntoTemp: 0 inVectorAt: 2
	40	<4C> self
	41	<41> pushTemp: 1
	42	<42> pushTemp: 2
	43	<F9 00 02> closureNumCopied: 2 numArgs: 1
	46	<7B> send: do:
	47	<D8> pop
	48	<FB 00 02> pushTemp: 0 inVectorAt: 2
	51	<5C> returnTop

[] in Collection>>#inject:into: ""a CompiledBlock(3755867)""
	header	((block #full) (numArgs: 1) (numTemps: 3) (numLiterals: 3) (frameSize: 16) (bytecodeSet: #SistaV1))
	literal1	#value:value:
	literal2	nil
	literal3	(Collection>>#inject:into: ""a CompiledMethod(736427)"")
	33	<41> pushTemp: 1
	34	<FB 00 02> pushTemp: 0 inVectorAt: 2
	37	<40> pushTemp: 0
	38	<A0> send: value:value:
	39	<FC 00 02> storeIntoTemp: 0 inVectorAt: 2
	42	<5E> blockReturn

The last literal in a CompiledMethod must be its methodClassAssociation, a binding whose value is the class the method is installed in.  The methodClassAssociation is used to implement super sends.  If a method contains no super send then its methodClassAssociation may be nil (as would be the case for example of methods providing a pool of inst var accessors).  

By convention the penultimate literal of a method is either its selector or an instance of AdditionalMethodState.  AdditionalMethodState holds the method's selector and any pragmas and properties of the method.  AdditionalMethodState may also be used to add instance variables to a method, albeit ones held in the method's AdditionalMethodState.  Subclasses of CompiledMethod that want to add state should subclass AdditionalMethodState to add the state they want, and implement methodPropertiesClass on the class side of the CompiledMethod subclass to answer the specialized subclass of AdditionalMethodState.  Enterprising programmers are encouraged to try and implement this support automatically through suitable modifications to the compiler and class builder.
"
Class {
	#name : #CompiledMethod,
	#superclass : #CompiledCode,
	#type : #compiledMethod,
	#category : #'Kernel-Methods'
}

{ #category : #constants }
CompiledMethod class >> abstractMarkers [
	^ #(subclassResponsibility shouldNotImplement)
]

{ #category : #'full block bootstrap' }
CompiledMethod class >> addCompiledCodeAndCompiledBlock [
	| cmHash cmInstCount cc |
	"Ensure that
		- CompiledMethod is a subclass of CompiledCode
		- CompiledMethod has a sibling called CompiledBlock,
		- CompiledMethod's class vars are moved to CompiledCode
		- CompiledMethod preserves its identityHash and instances"
	self compiledCodeAndCompiledBlockArePresent ifTrue:
		[^self].
	cmHash := CompiledMethod identityHash.
	cmInstCount := CompiledMethod instanceCount.
	cc := CompiledMethod variableByteSubclass: #CompiledCode
			instanceVariableNames: ''
			classVariableNames: ''
			poolDictionaries: ''
			category: 'Kernel-Methods'.
	self assert: cc == (ByteArray variableByteSubclass: #CompiledCode
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'Kernel-Methods').
	self assert: cc typeOfClass == #compiledMethod.
	cc ensureClassPool.
	CompiledMethod classPool keys do:
		[:classVar|
		cc classPool declare: classVar from: CompiledMethod classPool].
	self assert: CompiledMethod classPool isEmpty.
	CompiledMethod superclass: cc.
	CompiledMethod class superclass: cc class.
	cc addSubclass: CompiledMethod.
	self assert: cmHash = CompiledMethod identityHash.
	self assert: cmInstCount = CompiledMethod instanceCount.
	self assert: (CompiledMethod inheritsFrom: cc).
	self assert: (CompiledMethod class inheritsFrom: cc class).
	cc variableByteSubclass: #CompiledBlock
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'Kernel-Methods'.
	self assert: self compiledCodeAndCompiledBlockArePresent
]

{ #category : #'full block bootstrap' }
CompiledMethod class >> compiledCodeAndCompiledBlockArePresent [
	^((Smalltalk classNamed: #CompiledCode) notNil
	   and: [((Smalltalk classNamed: #CompiledCode) subclasses collect: [:ea| ea name])
						= #(CompiledMethod CompiledBlock)])
]

{ #category : #constants }
CompiledMethod class >> disabledMarker [
	^ #shouldNotImplement
]

{ #category : #'accessing class hierarchy' }
CompiledMethod class >> methodPropertiesClass [
	"Answer the class to use to create a method's properties, which can be a poor man's way
	 to add instance variables to subclassses of CompiledMethod.  Subclasses of CompiledMethod
	 should define a corresponding subclass of AdditionalMethodState that adds any instance variables
	 required, and override this method to answer that class."
	^AdditionalMethodState
]

{ #category : #'instance creation' }
CompiledMethod class >> primitive: primNum numArgs: numArgs numTemps: numTemps stackSize: stackSize literals: literals bytecodes: bytecodes trailer: trailerBytes [
	"Create method with given attributes.  numTemps includes numArgs.  stackSize does not include numTemps."

	| compiledMethod |
	compiledMethod := self
		newBytes: bytecodes size
		trailerBytes: trailerBytes 
		nArgs: numArgs
		nTemps: numTemps
		nStack: stackSize
		nLits: literals size
		primitive: primNum.
	(WriteStream with: compiledMethod)
		position: compiledMethod initialPC - 1;
		nextPutAll: bytecodes.
	literals withIndexDo: [:obj :i | compiledMethod literalAt: i put: obj].
	^ compiledMethod
]

{ #category : #evaluating }
CompiledMethod class >> receiver: receiver withArguments: argArray executeMethod: compiledMethod [
	"Execute compiledMethod against the receiver and the arguments in argArray"

	<primitive: 188 error: ec>
	self primitiveFailed
]

{ #category : #constants }
CompiledMethod class >> subclassResponsibilityMarker [
	^ #subclassResponsibility
]

{ #category : #'instance creation' }
CompiledMethod class >> toReturnConstant: index trailerBytes: trailer [
	"Answer an instance of me that is a quick return of the constant
	indexed in (true false nil -1 0 1 2)."

	^self newBytes: 3 trailerBytes: trailer nArgs: 0 nTemps: 0 nStack: 0 nLits: 2 primitive: 256 + index
]

{ #category : #'instance creation' }
CompiledMethod class >> toReturnField: field trailerBytes: trailer [
	"Answer an instance of me that is a quick return of the instance variable 
	indexed by the argument, field."

	^self newBytes: 3 trailerBytes: trailer nArgs: 0 nTemps: 0 nStack: 0 nLits: 2 primitive: 264 + field
]

{ #category : #'instance creation' }
CompiledMethod class >> toReturnSelf [
	"Answer an instance of me that is a quick return of the instance (^self)."

	^ self toReturnSelfTrailerBytes: CompiledMethodTrailer empty
]

{ #category : #'instance creation' }
CompiledMethod class >> toReturnSelfTrailerBytes: trailer [
	"Answer an instance of me that is a quick return of the instance (^self)."

	^self newBytes: 3 trailerBytes: trailer nArgs: 0 nTemps: 0 nStack: 0 nLits: 2 primitive: 256
]

{ #category : #printing }
CompiledMethod >> abstractSymbolic [
	"Answer a String that contains a list of all the byte codes in a method with a
	 short description of each, using relative addresses and not including code bytes."

	| aStream |
	aStream := WriteStream on: (String new: 1000).
	self longPrintRelativeOn: aStream indent: 0.
	^aStream contents
]

{ #category : #literals }
CompiledMethod >> allLiteralsDo: aBlock [
	"Overwritten to skip certain (raw) literals."
		
	" Exclude method selector (or properties) and the method's class."
	1 to: self numLiterals - 2 do: [:index |
		(self literalAt: index) allLiteralsDo: aBlock].

	"Enumerate method selector only through additional method state."
	self penultimateLiteral isMethodProperties
		ifTrue: [self penultimateLiteral allLiteralsDo: aBlock].
	
	"Enumerate special selectors."
	self flag: #todo.
	
	"Enumerate special literals such as true and false."
	self flag: #todo.
]

{ #category : #'source code management' }
CompiledMethod >> checkOKToAdd: size at: filePosition [
	"Issue several warnings if the end of the changes file is approaching
	a fixed size limit, and finally halt with an error if the limit is reached."

	^ SourceFiles checkOKToAdd: size at: filePosition

]

{ #category : #decompiling }
CompiledMethod >> compilerClass [
	^self methodClass 
		ifNil: [Compiler] 
		ifNotNil: [:class | class compilerClass].
]

{ #category : #closures }
CompiledMethod >> containsBlockClosures [
	^self scanner scanFor: self encoderClass createClosureScanBlock
]

{ #category : #'source code management' }
CompiledMethod >> copyWithSourceCode: sourceCode [
	"Create a copy of the receiver whose source is embedded in the method.  Used for breakpoints."
	^self copyWithTrailerBytes: (CompiledMethodTrailer new sourceCode: sourceCode)
]

{ #category : #'source code management' }
CompiledMethod >> copyWithTempNames: tempNames [
	"Minimal temp name copy that only works for methods containing no temporaries or blocks with arguments.
	Used by the Traits system for creating conflict and required methdos that generate warnings.
	For generic use use copyWithTempsFromMethodNode:"
	| tempString |
	tempString := String streamContents:
					[:str|
					tempNames
						do: [:temp| str nextPutAll: temp]
						separatedBy: [str space].
					str space].
	^self copyWithTrailerBytes: (CompiledMethodTrailer new tempNames: tempString)				

]

{ #category : #'source code management' }
CompiledMethod >> copyWithTempsFromMethodNode: aMethodNode [
	^self copyWithTrailerBytes: (
		CompiledMethodTrailer new tempNames: aMethodNode schematicTempNamesString)
]

{ #category : #copying }
CompiledMethod >> copyWithTrailerBytes: trailer [
	"Testing:
		CompiledMethod >> #copyWithTrailerBytes:
			copyWithTempsFromMethodNode: (CompiledMethod >> #copyWithTrailerBytes:) methodNode"
	| copy end start |
	start := self initialPC.
	end := self endPC.
	copy := trailer createMethod: end - start + 1 class: self class header: self header.
	1 to: self numLiterals do:
		[:i | | lit |
		lit := self literalAt: i.
		copy literalAt: i put: ((lit isCompiledCode and: [lit isCompiledBlock])
								ifTrue: [lit copyWithOuterCode: copy]
								ifFalse: [lit])].
	start to: end do: [:i | copy at: i put: (self at: i)].
	copy postCopy.
	^copy
]

{ #category : #printing }
CompiledMethod >> dateMethodLastSubmitted [
	"Answer a Date object indicating when a method was last submitted.  If there is no date stamp, return nil"
	"(CompiledMethod compiledMethodAt: #dateMethodLastSubmitted) dateMethodLastSubmitted"

	| aStamp tokens |
	aStamp := self timeStamp.
	tokens := aStamp findBetweenSubStrs: ' 
'.  "space is expected delimiter, but cr is sometimes seen, though of mysterious provenance"
	^ tokens size > 1
		ifTrue:
			[[tokens second asDate] ifError: [nil]]
		ifFalse:
			[nil]
]

{ #category : #printing }
CompiledMethod >> decompileString [
	^self decompile decompileString
]

{ #category : #decompiling }
CompiledMethod >> decompileWithTemps [
	"Return the decompiled parse tree that represents self, but with the temp names obtained
	 either by compiling the sourcecode, or directly if the method has temps in its trailer."

	| class selector tempNames source |
	class := self methodClass ifNil: [Object].
	selector := self selector ifNil: [self defaultSelector].

	self holdsTempNames
		ifTrue: [tempNames := self tempNamesString]
		ifFalse:
			[| compiler |
			 "No source file or no source (e.g. doits) and no temp names
			 -- decompile without temp names "
			((self fileIndex > 0 and: [(SourceFiles at: self fileIndex) isNil])
			or: [(source := self getSourceFromFile) isNil]) ifTrue:
				[^self decompile].
			compiler := class newCompiler.
			compiler parser encoderClass: self encoderClass.
			tempNames := (compiler
								parse: source asString
								in: class
								notifying: nil)
									generate: CompiledMethodTrailer empty;
									schematicTempNamesString].

	^(self decompilerClass new withTempNames: tempNames)
		decompile: selector
		in: class
		method: self methodForDecompile
]

{ #category : #decompiling }
CompiledMethod >> decompilerClass [
	^self compilerClass decompilerClass
]

{ #category : #accessing }
CompiledMethod >> defaultSelector [ 
	"Invent and answer an appropriate message selector (a Symbol) for me, 
	that is, one that will parse with the correct number of arguments."

	^#DoIt numArgs: self numArgs
]

{ #category : #accessing }
CompiledMethod >> dragLabel [
	"The label we use for dragging compiled methods"
	^self methodClass name, '>>', self selector
]

{ #category : #closures }
CompiledMethod >> embeddedBlockClosures [
	| bms extractor scanner endPC encoderClass |
	bms := OrderedCollection new.
	scanner := self scanner.
	extractor := ClosureExtractor withAction: [:c| bms add: c] andScanner: scanner.
	endPC := self endPC.
	encoderClass := self encoderClass.
	[scanner pc <= endPC] whileTrue:
		[encoderClass interpretNextInstructionFor: extractor in: scanner].
	^bms
]

{ #category : #comparing }
CompiledMethod >> equivalentTo: aCompiledMethod [
	| parseTree |
	^self = aCompiledMethod
	or: [self class == aCompiledMethod class
		and: [self numArgs = aCompiledMethod numArgs
		and: [self numLiterals = aCompiledMethod numLiterals
		and: [parseTree := self decompile.
			(parseTree isKindOf: MethodNode)
				ifTrue: [parseTree asString = aCompiledMethod decompile asString "Standard compiler"]
				ifFalse: [parseTree = aCompiledMethod decompile "RB parse trees, we hope"]]]]]
]

{ #category : #'source code management' }
CompiledMethod >> fileIndex [
	^SourceFiles fileIndexFromSourcePointer: self sourcePointer
]

{ #category : #'source code management' }
CompiledMethod >> filePosition [
	^SourceFiles filePositionFromSourcePointer: self sourcePointer
]

{ #category : #'source code management' }
CompiledMethod >> getPreambleFrom: aFileStream at: endPosition [
	"This method is an ugly hack. This method assumes that source files have ASCII-compatible encoding and that preambles contain no non-ASCII characters."

	| chunkSize chunk |
	chunkSize := 160 min: endPosition.
	[
		| index |
		chunk := aFileStream
			position: (endPosition - chunkSize + 1 max: 0);
			basicNext: chunkSize.
		(index := chunk lastIndexOf: $! startingAt: chunk size) ~= 0 ifTrue: [
			^chunk copyFrom: index + 1 to: chunk size ].
		chunkSize := chunkSize * 2.
		chunkSize <= endPosition ] whileTrue.
	^chunk
]

{ #category : #'source code management' }
CompiledMethod >> getSourceFor: selector in: class [
	"Retrieve or reconstruct the source code for this method."
	| trailer source |
	(self properties includesKey: #source) ifTrue:
		[^self properties at: #source].
	trailer := self trailer.

	trailer tempNames ifNotNil: [:namesString | 
		"Magic sources -- decompile with temp names"
		^ ((class decompilerClass new withTempNames: namesString)
				decompile: selector in: class method: self methodForDecompile)
			decompileString].
	
	trailer sourceCode ifNotNil: [:code | ^ code ].
	
	trailer hasSourcePointer ifFalse: [
		"No source pointer -- decompile without temp names"
		^ (class decompilerClass new decompile: selector in: class method: self methodForDecompile)
			decompileString].

	"Situation normal;  read the sourceCode from the file"
	source := [self getSourceFromFileAt: trailer sourcePointer]
				on: Error
		"An error can happen here if, for example, the changes file has been truncated by an aborted download.  The present solution is to ignore the error and fall back on the decompiler.  A more thorough solution should probably trigger a systematic invalidation of all source pointers past the end of the changes file.  Consider that, as time goes on, the changes file will eventually grow large enough to cover the lost code, and then instead of falling into this error case, random source code will get returned."
				do: [ :ex | ex return: nil].
		
	^source ifNil: [
			"Something really wrong -- decompile blind (no temps)"
			 (class decompilerClass new decompile: selector in: class method: self methodForDecompile)
				decompileString]
]

{ #category : #'source code management' }
CompiledMethod >> getSourceFromFile [
	
	^self getSourceFromFileAt: self sourcePointer
]

{ #category : #'source code management' }
CompiledMethod >> getSourceFromFileAt: sourcePointer [
	
	| position index |
	position := SourceFiles filePositionFromSourcePointer: sourcePointer.
	position = 0 ifTrue: [ ^nil ].
	index := SourceFiles fileIndexFromSourcePointer: sourcePointer.
	^(RemoteString newFileNumber: index position: position)
		text
]

{ #category : #scanning }
CompiledMethod >> hasInstVarRef [
	"Answer whether the method references an instance variable."

	| scanner end printer |

	scanner := InstructionStream on: self.
	printer := InstVarRefLocator new.
	end := self endPC.

	[scanner pc <= end] whileTrue: [
		(printer interpretNextInstructionUsing: scanner) ifTrue: [^true].
	].
	^false
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> hasPragma: aSymbol [

	^ (self pragmaAt: aSymbol) notNil
]

{ #category : #testing }
CompiledMethod >> hasReportableSlip [
	"Answer whether the receiver contains anything that should be brought 
	to the attention of the author when filing out. Customize the lists here 
	to suit your preferences. If slips do not get reported in spite of your 
	best efforts here, make certain that the Preference 'checkForSlips' is set 
	to true."
	#(#doOnlyOnce: #halt #halt: #hottest #printDirectlyToDisplay #toRemove #personal #urgent  #haltOnce #haltOnce: #haltIf: )
		do: [:aLit | (self hasLiteral: aLit)
				ifTrue: [^ true]].
	#(#Transcript #AA #BB #CC #DD #EE )
		do: [:aSymbol |
			| assoc |
			(assoc := Smalltalk globals
						associationAt: aSymbol
						ifAbsent: [])
				ifNotNil: [(self hasLiteral: assoc)
						ifTrue: [^ true]]].
	^ false
]

{ #category : #comparing }
CompiledMethod >> hasSameLiteralsAs: aMethod [
	"Answer whether the receiver has the same sequence of literals as the argument.
	 Compare the last literal, which is the class association, specially so as not to
	 differentiate between otherwise identical methods installed in different classes.
	 Compare the first literal carefully if it is the binding informaiton for an FFI or
	 external primitive call.  Don't compare all of the state so that linked and unlinked
	 methods are still considered equal."
	| numLits |
	numLits := self numLiterals.
	numLits = aMethod numLiterals ifFalse: [^false].
	1 to: numLits do:
		[:i| | lit1 lit2 |
		lit1 := self literalAt: i.
		lit2 := aMethod literalAt: i.
		(lit1 == lit2 or: [lit1 literalEqual: lit2]) ifFalse:
			[(i = 1 and: [#(117 120) includes: self primitive])
				ifTrue:
					[lit1 isArray
						ifTrue:
							[(lit2 isArray and: [(lit1 first: 2) = (lit2 first: 2)]) ifFalse:
								[^false]]
						ifFalse: "ExternalLibraryFunction"
							[(lit1 analogousCodeTo: lit2) ifFalse:
								[^false]]]
				ifFalse:
					[i = (numLits - 1)
						ifTrue: "properties"
							[(self properties analogousCodeTo: aMethod properties)
								ifFalse: [^false]]
						ifFalse: "last literal (methodClassAssociation) of class-side methods is not unique"
								"last literal of CompiledBlock is outerMethod and may not be unique."
							[(self isCompiledBlock
							  and: [lit1 isCompiledCode
							  and: [lit2 isCompiledCode]]) ifTrue:
								[^true].
							(i = numLits
							 and: [lit1 isVariableBinding and: [lit1 value isBehavior
							 and: [lit2 isVariableBinding and: [lit2 value isBehavior]]]]) ifFalse:
								[^false]]]]].
	^true
]

{ #category : #printing }
CompiledMethod >> headerDescription [
	"Answer a description containing the information about the form of the
	 receiver and the form of the context needed to run the receiver."

	^(ByteString new: 128) writeStream
		print: self header; cr;
		nextPutAll: '"primitive: '; print: self primitive; cr;
		nextPutAll: ' numArgs: '; print: self numArgs; cr;
		nextPutAll: ' numTemps: '; print: self numTemps; cr;
		nextPutAll: ' numLiterals: '; print: self numLiterals; cr;
		nextPutAll: ' frameSize: '; print: self frameSize; cr;
		nextPutAll: ' bytecodeSet: '; nextPutAll: self bytecodeSetName;
		nextPut: $"; cr;
		contents
]

{ #category : #'source code management' }
CompiledMethod >> holdsTempNames [
	"Are tempNames stored in trailer bytes"

	^ self trailer hasTempNames
]

{ #category : #accessing }
CompiledMethod >> homeMethod [
	"Answer the home method associated with the receiver.
	 This is polymorphic with closure, CompiledBlock, Context etc"

	^self
]

{ #category : #literals }
CompiledMethod >> indexOfLiteral: literal [
	"Answer the literal index of the argument, literal, or zero if none."
	2 to: self numLiterals - 1 "exclude selector/properties + methodClass"
	   do:
		[:index |
		literal == (self objectAt: index) ifTrue: [^index - 1]].
	^0
]

{ #category : #testing }
CompiledMethod >> isAbstract [
	| marker |
	marker := self markerOrNil.
	^ marker notNil and: [self class abstractMarkers includes: marker].
]

{ #category : #testing }
CompiledMethod >> isBlueBookCompiled [
	"Answer whether the receiver was compiled using the old Smalltalk-80 blocks
	 compiler.  This is used to help DebuggerMethodMap choose which mechanisms
	 to use to inspect (debug) activations of the receiver."

	^self encoderClass supportsClosures not
]

{ #category : #testing }
CompiledMethod >> isClosureCompiled [
	"Answer whether the receiver was compiled using the closure compiler.
	 This is used to help DebuggerMethodMap choose which mechanisms to
	 use to inspect (debug) activations of the receiver."

	^self encoderClass supportsClosures
]

{ #category : #testing }
CompiledMethod >> isCompiledMethod [

	^ true
]

{ #category : #testing }
CompiledMethod >> isDeprecated [
	"Note that #literalsDo: is faster than #hasLiteral: (and #hasLiteral:scanForSpecial:). We already know that 'self deprecated' should be the first statement in a deprecated method, which is directly accessible in this method's literals. No need to check compiled blocks or other nested structures. We expand the implementation of #literalsDo: here to gain twice the speed.
	
	Note that both #isQuick and is-this-method check make no sense performance-wise. Maybe bench again in the future."
	
	| literal |
	1 to: self numLiterals do: [:index |
		((literal := self literalAt: index) == #deprecated: or: [ literal == #deprecated ])
			ifTrue: [ ^true ] ].
	^ false
]

{ #category : #testing }
CompiledMethod >> isDisabled [
	^ self isDisabled: self markerOrNil
]

{ #category : #testing }
CompiledMethod >> isDisabled: marker [
	^ marker == self class disabledMarker
]

{ #category : #testing }
CompiledMethod >> isImplicitlyRequired [
	^ self isImplicitlyRequired: self markerOrNil
]

{ #category : #testing }
CompiledMethod >> isInstalled [
	self methodClass ifNotNil:
		[:class|
		self selector ifNotNil:
			[:selector|
			^self == (class methodDict at: selector ifAbsent: [])]].
	^false
]

{ #category : #testing }
CompiledMethod >> isLinkedNamedPrimitive [
	"Answer if the receiver invokes a named primitive, and the method is linked to an actual primitive.
	 For example if the method hasn't yet been used in the current session, it won't be linked"
	^self isNamedPrimitive and: [(self literalAt: 1) fourth ~= 0]
	
	"self systemNavigation browseAllSelect: [:m| m isLinkedNamedPrimitive]"
]

{ #category : #testing }
CompiledMethod >> isNamedPrimitive [
	"Answer if the receiver invokes a named primitive."
	^self primitive = 117
	
	"self systemNavigation browseAllSelect: [:m| m isNamedPrimitive]"
]

{ #category : #testing }
CompiledMethod >> isQuick [
	"Answer whether the receiver is a quick return (of self or of an instance 
	variable)."
	^ self primitive between: 256 and: 519
]

{ #category : #testing }
CompiledMethod >> isReturnField [
	"Answer whether the receiver is a quick return of an instance variable."
	^ self primitive between: 264 and: 519
]

{ #category : #testing }
CompiledMethod >> isReturnSelf [
	"Answer whether the receiver is a quick return of self."

	^ self primitive = 256
]

{ #category : #testing }
CompiledMethod >> isReturnSpecial [
	"Answer whether the receiver is a quick return of self or constant."

	^ self primitive between: 256 and: 263
]

{ #category : #testing }
CompiledMethod >> isSubclassResponsibility [
	^ self isSubclassResponsibility: self markerOrNil
]

{ #category : #testing }
CompiledMethod >> isSubclassResponsibility: marker [
	^ marker == self class subclassResponsibilityMarker
]

{ #category : #'source code management' }
CompiledMethod >> linesOfCode [
	"An approximate measure of lines of code.
	Includes comments, but excludes empty lines."
	| lines |
	lines := 0.
	self getSource asString lineIndicesDo: [:start :endWithoutDelimiters :end |
		endWithoutDelimiters > start ifTrue: [lines := lines+1]].
	^lines
]

{ #category : #literals }
CompiledMethod >> literalStrings [
	| litStrs |
	litStrs := OrderedCollection new: self numLiterals.
	self literalsDo:
		[:lit | 
		(lit isVariableBinding)
			ifTrue: [litStrs addLast: lit key]
			ifFalse: [(lit isSymbol)
				ifTrue: [litStrs addAll: lit keywords]
				ifFalse: [litStrs addLast: lit printString]]].
	^ litStrs
]

{ #category : #printing }
CompiledMethod >> longPrintOn: aStream indent: tabs [
	"List of all the byte codes in a method with a short description of each" 

	self isQuick ifTrue: 
		[self isReturnSpecial ifTrue:
			[^ aStream tab: tabs; nextPutAll: 'Quick return ' , 
				(#('self' 'true' 'false' 'nil' '-1' '0' '1' '2') at: self primitive - 255)].
		^ aStream nextPutAll: 'Quick return field ' , self returnField printString , ' (0-based)'].

	self primitive = 0 ifFalse: [
		aStream tab: tabs.
		self printPrimitiveOn: aStream.
	].
	(InstructionPrinter on: self) indent: tabs; printInstructionsOn: aStream.

]

{ #category : #printing }
CompiledMethod >> longPrintRelativeOn: aStream indent: tabs [
	"List of all the byte codes in a method with a short description of each" 

	self isQuick ifTrue: 
		[^self longPrintOn: aStream indent: tabs].
	self primitive = 0 ifFalse:
		[aStream tab: tabs. self printPrimitiveOn: aStream].
	(RelativeInstructionPrinter on: self)
		indent: tabs;
		printCode: false;
		printInstructionsOn: aStream.

]

{ #category : #private }
CompiledMethod >> markerOrNil [
	"If I am a marker method, answer the symbol used to mark me.  Otherwise
	 answer nil. What is a marker method?  It is method with body like 
		'self subclassResponsibility' or '^ self subclassResponsibility' 
	used to indicate ('mark') a special property."

	^self encoderClass markerOrNilFor: self
]

{ #category : #accessing }
CompiledMethod >> method [
	"Answer the home method associated with the receiver.
	 This is polymorphic with closure, CompiledBlock, Context etc"

	^self
]

{ #category : #accessing }
CompiledMethod >> methodClass [
	"answer the class that I am installed in"
	^(self literalAt: self numLiterals) value.
]

{ #category : #accessing }
CompiledMethod >> methodClass: aClass [
	"set the class binding in the last literal to aClass"
	self literalAt: self numLiterals put: aClass binding
]

{ #category : #accessing }
CompiledMethod >> methodClassAssociation [
	"answer the association to the class that I am installed in, or nil if none."
	^self literalAt: self numLiterals
]

{ #category : #accessing }
CompiledMethod >> methodClassAssociation: aBinding [
	"sets the association to the class that I am installed in"
	^self literalAt: self numLiterals put: aBinding
]

{ #category : #decompiling }
CompiledMethod >> methodForDecompile [
	"This is a hook to allow recursive methods like MwMethodWrapper to avoid infinite recursion."
	^self
]

{ #category : #accessing }
CompiledMethod >> methodHome [
	"The behavior (trait/class) this method was originally defined in. 
	Can be different from methodClass if the method was recompiled."
	^self properties methodHome
]

{ #category : #decompiling }
CompiledMethod >> methodNode [
	"Return the parse tree that represents self. If parsing fails, decompile the method."
	| aClass source |
	aClass := self methodClass.
	source := self
				getSourceFor: (self selector ifNil: [self defaultSelector])
				in: aClass.
	^[(aClass newParser
		encoderClass: self encoderClass;
		parse: source class: aClass)
			sourceText: source;
			yourself]
		on: SyntaxErrorNotification
		do: [:ex | ex return: self decompileWithTemps]
]

{ #category : #decompiling }
CompiledMethod >> methodNodeFormattedAndDecorated: decorate [
	"Answer a method node made from pretty-printed (and colorized, if decorate is true) 
	 source text."

	| class source node  |
	
	source := self getSourceFromFile.
	class := self methodClass ifNil: [self sourceClass].
	source ifNil: [^self decompile].
	source := class prettyPrinterClass 
				format: source
				in: class
				notifying: nil
				decorated: decorate.
	node := class newParser parse: source class: class.
	node sourceText: source.
	^node
]

{ #category : #closures }
CompiledMethod >> nestedBlockMethods [
	"Answer a collection of the block methods of blocks within the receiver, if any."
	| nestedBlockMethods iterator |
	nestedBlockMethods := OrderedCollection new.
	iterator := [:m| | nLits |
				nLits := m numLiterals.
				2 to: (m isCompiledBlock ifTrue: [nLits] ifFalse: [nLits - 1]) do:
					[:index | | lit |
					lit := m objectAt: index.
					lit isCompiledCode ifTrue:
						[iterator value: (nestedBlockMethods add: lit)]]].
	iterator value: self.
	^nestedBlockMethods

]

{ #category : #'file in\/out' }
CompiledMethod >> objectForDataStream: refStrm [
	"Reconfigure pragma. Example: #(#FFTPlugin #primitiveFFTTransformData 0 0). See FFT >> #pluginTransformData:."

	self primitive = 117 ifTrue: [(self literalAt: 1) at: 4 put: 0].
]

{ #category : #decompiling }
CompiledMethod >> parserClass [
	^self methodClass 
		ifNil: [Compiler parserClass] 
		ifNotNil: [:class | class parserClass].
]

{ #category : #private }
CompiledMethod >> penultimateLiteral [
	"Answer the penultimate literal of the receiver, which holds either
	 the receiver's selector or its properties (which will hold the selector)."
	| pIndex |
	^(pIndex := self numLiterals - 1) > 0 
		ifTrue: [self literalAt: pIndex]
		ifFalse: [nil]
]

{ #category : #private }
CompiledMethod >> penultimateLiteral: anObject [
	"Set the penultimate literal of the receiver, which holds either the
	 receiver's selector or its properties (which will hold the selector).
	 If it is an AdditionalMethodState set the state's ownership to this
	 method"
	| pIndex |
	(pIndex := self numLiterals - 1) <= 0 ifTrue:
		[self error: 'insufficient literals'].
	self literalAt: pIndex put: anObject.
	anObject isMethodProperties ifTrue:
		[(anObject method ~~ nil
		  and: [anObject method ~~ self
		  and: [anObject method penultimateLiteral == anObject]]) ifTrue:
			[self error: 'a method''s AdditionalMethodState should not be shared'].
		 anObject setMethod: self.
		 anObject pragmas do: [:p| p setMethod: self]]
]

{ #category : #copying }
CompiledMethod >> postCopy [
	| penultimateLiteral |
	(penultimateLiteral := self penultimateLiteral) isMethodProperties ifTrue:
		[self penultimateLiteral: penultimateLiteral copy].
	self encoderClass supportsFullBlocks ifTrue:
		[1 to: self numLiterals - 2 do:
			[:index| | lit |
			 (lit := self literalAt: index) isCompiledCode ifTrue:
				[lit outerCode: self; postCopy]]]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> pragmaAt: aKey [
	"Answer the pragma with selector aKey, or nil if none."
	| propertiesOrSelector |
	^(propertiesOrSelector := self penultimateLiteral) isMethodProperties
		ifTrue: [propertiesOrSelector at: aKey ifAbsent: nil]
		ifFalse: [nil]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> pragmas [
	| selectorOrProperties |
	^(selectorOrProperties := self penultimateLiteral) isMethodProperties
		ifTrue: [selectorOrProperties pragmas]
		ifFalse: [#()]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> pragmasAt: aSelector [
	^self pragmas select: [:p| p keyword = aSelector]
]

{ #category : #printing }
CompiledMethod >> preamble [
	"Return the preamble of this method stored in the source files."

	^SourceFiles
		fileIndexAndPositionFromSourcePointer: self sourcePointer
		do: [ :fileIndex :filePosition |
			fileIndex = 0
				ifTrue: [ String new "no source pointer for this method" ]
				ifFalse: [
					(CurrentReadOnlySourceFiles at: fileIndex)
						ifNil: [ String new "sources file not available" ]
						ifNotNil: [ :file |
							self
								getPreambleFrom: file
								at: (0 max: filePosition - 3) ] ] ]
]

{ #category : #accessing }
CompiledMethod >> primitive [
	"Answer the primitive index associated with the receiver.
	 Zero indicates that this is not a primitive method."
	| initialPC |
	^(self header anyMask: 65536) "Is the hasPrimitive? flag set?"
		ifTrue: [(self at: (initialPC := self initialPC) + 1) + ((self at: initialPC + 2) bitShift: 8)]
		ifFalse: [0]
]

{ #category : #printing }
CompiledMethod >> primitiveErrorVariableName [
	"Answer the primitive error code temp name, or nil if none."
	self primitive > 0 ifTrue:
		[self pragmas do:
			[:pragma| | kwds ecIndex |
			((kwds := pragma keyword keywords) first = 'primitive:'
			and: [(ecIndex := kwds indexOf: 'error:') > 0]) ifTrue:
				[^pragma argumentAt: ecIndex]]].
	^nil
]

{ #category : #printing }
CompiledMethod >> printPrimitiveOn: aStream [
	"Print the primitive on aStream"
	| primIndex primDecl |
	(primIndex := self primitive) = 0 ifTrue:
		[^self].
	primIndex = 120 ifTrue: "External call spec"
		[^aStream print: (self literalAt: 1); cr].
	aStream nextPutAll: '<primitive: '.
	primIndex = 117
		ifTrue:
			[primDecl := self literalAt: 1.
			 (primDecl at: 2) asString printOn: aStream.
			 (primDecl at: 1) ifNotNil:
				[:moduleName|
				aStream nextPutAll:' module: '.
				moduleName asString printOn: aStream]]
		ifFalse:
			[aStream print: primIndex].
	self primitiveErrorVariableName ifNotNil:
		[:primitiveErrorVariableName|
		 aStream nextPutAll: ' error: '; nextPutAll: primitiveErrorVariableName].
	aStream nextPut: $>; cr
]

{ #category : #accessing }
CompiledMethod >> properties [
	"Answer the method properties of the receiver."
	| propertiesOrSelector |
	^(propertiesOrSelector := self penultimateLiteral) isMethodProperties
		ifTrue: [propertiesOrSelector]
		ifFalse: [self class methodPropertiesClass forMethod: self selector: propertiesOrSelector]
]

{ #category : #accessing }
CompiledMethod >> properties: aMethodProperties [
	"Set the method-properties of the receiver to aMethodProperties."
	self literalAt: self numLiterals - 1
		put: (aMethodProperties isEmpty
				ifTrue: [aMethodProperties selector]
				ifFalse: [aMethodProperties
							setMethod: self;
							yourself])
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> propertyKeysAndValuesDo: aBlock [
	"Enumerate the receiver with all the keys and values."

	| propertiesOrSelector |
	(propertiesOrSelector := self penultimateLiteral) isMethodProperties ifTrue:
		[propertiesOrSelector propertyKeysAndValuesDo: aBlock]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> propertyValueAt: propName [
	| propertiesOrSelector |
	^(propertiesOrSelector := self penultimateLiteral) isMethodProperties
		ifTrue: [propertiesOrSelector propertyValueAt: propName ifAbsent: nil]
		ifFalse: [nil]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> propertyValueAt: propName ifAbsent: aBlock [
	| propertiesOrSelector |
	^(propertiesOrSelector := self penultimateLiteral) isMethodProperties
		ifTrue: [propertiesOrSelector propertyValueAt: propName ifAbsent: aBlock]
		ifFalse: [aBlock value]
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> propertyValueAt: propName put: propValue [
	"Set or add the property with key propName and value propValue.
	 If the receiver does not yet have a method properties create one and replace
	 the selector with it.  Otherwise, either relace propValue in the method properties
	 or replace method properties with one containing the new property."
	| propertiesOrSelector |
	(propertiesOrSelector := self penultimateLiteral) isMethodProperties ifFalse:
		[self penultimateLiteral: (self class methodPropertiesClass
									selector: propertiesOrSelector
									with: (Association
											key: propName asSymbol
											value: propValue)).
		^propValue].
	(propertiesOrSelector includesProperty: propName) ifTrue:
		[^propertiesOrSelector at: propName put: propValue].
	self penultimateLiteral: (propertiesOrSelector
								copyWith: (Association
											key: propName asSymbol
											value: propValue)).
	^propValue
]

{ #category : #'source code management' }
CompiledMethod >> putSource: sourceStr fromParseNode: methodNode class: class category: catName
	inFile: fileIndex priorMethod: priorMethod [

	^ self putSource: sourceStr fromParseNode: methodNode inFile: fileIndex withPreamble:
			[:file | class printCategoryChunk: catName on: file priorMethod: priorMethod.
			file cr]
]

{ #category : #'source code management' }
CompiledMethod >> putSource: sourceStr fromParseNode: methodNode class: class category: catName
	withStamp: changeStamp inFile: fileIndex priorMethod: priorMethod [

	^ self putSource: sourceStr fromParseNode: methodNode inFile: fileIndex withPreamble:
			[:file |
			class printCategoryChunk: catName on: file
				withStamp: changeStamp priorMethod: priorMethod.
			file cr]
]

{ #category : #'source code management' }
CompiledMethod >> putSource: sourceStr fromParseNode: methodNode inFile: fileIndex withPreamble: preambleBlock [
	"Store the source code for the receiver on an external file.
	If no sources are available, i.e., SourceFile is nil, then store
	temp names for decompilation at the end of the method.
	If the fileIndex is 1, print on *.sources;  if it is 2, print on *.changes,
	in each case, storing a 4-byte source code pointer at the method end."

	| file remoteString |
	(SourceFiles == nil or: [(file := SourceFiles at: fileIndex) == nil]) ifTrue:
		[^self becomeForward: (self copyWithTempsFromMethodNode: methodNode)].

	Smalltalk assureStartupStampLogged.
	file setToEnd.

	preambleBlock value: file.  "Write the preamble"
	remoteString := RemoteString newString: sourceStr onFileNumber: fileIndex toFile: file.
	file nextChunkPut: ' '.
	InMidstOfFileinNotification signal ifFalse: [file flush].
	self checkOKToAdd: sourceStr size at: remoteString position.
	self setSourcePosition: remoteString position inFile: fileIndex
]

{ #category : #scanning }
CompiledMethod >> readsField: varIndex [ 
	"Answer whether the receiver loads the instance variable indexed by the argument."

	| varIndexCode scanner |
	varIndexCode := varIndex - 1.
	self isQuick ifTrue: [^ self isReturnField and: [self returnField = varIndexCode]].
	
	self codeLiteralsDo: [:compiledCode | 
		scanner := InstructionStream on: compiledCode.
		(scanner scanFor: (self encoderClass instVarReadScanBlockFor: varIndexCode using: scanner))
			ifTrue: [^ true]].

	^ false
]

{ #category : #scanning }
CompiledMethod >> readsRef: variableBinding [ 
	"Answer whether the receiver reads the value of the argument."
	"eem 5/24/2008 Rewritten to no longer assume the compler uses the
	 most compact encoding available (for EncoderForLongFormV3 support)."
	
	| litIndex scanner |
	(litIndex := self indexOfLiteral: variableBinding) = 0
		ifTrue: [^false].
	
	self codeLiteralsDo: [:compiledCode | 
		scanner := InstructionStream on: compiledCode.
		(scanner scanFor: (self encoderClass bindingReadScanBlockFor: litIndex - 1 using: scanner))
			ifTrue: [^ true]].
	
	^ false
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> removeProperty: propName [
	"Remove the property propName if it exists.
	 Do _not_ raise an error if the property is missing."
	| value newAdditionalState |
	value := self propertyValueAt: propName ifAbsent: [^nil].
	newAdditionalState := self penultimateLiteral copyWithout:
									(Association
										key: propName
										value: value).
	self penultimateLiteral: (newAdditionalState isEmpty
								ifTrue: [newAdditionalState selector]
								ifFalse: [newAdditionalState]).
	^value
]

{ #category : #'accessing-pragmas & properties' }
CompiledMethod >> removeProperty: propName ifAbsent: aBlock [
	"Remove the property propName if it exists.
	 Answer the evaluation of aBlock if the property is missing."
	| value newAdditionalState |
	value := self propertyValueAt: propName ifAbsent: [^aBlock value].
	newAdditionalState := self penultimateLiteral copyWithout:
									(Association
										key: propName
										value: value).
	self penultimateLiteral: (newAdditionalState isEmpty
								ifTrue: [newAdditionalState selector]
								ifFalse: [newAdditionalState]).
	^value
]

{ #category : #private }
CompiledMethod >> replace: oldSelector with: newSelector in: aText [
	| oldKeywords newKeywords args newSelectorWithArgs startOfSource lastSelectorToken |
	oldKeywords := oldSelector keywords.
	newKeywords := (newSelector ifNil: [self defaultSelector]) keywords.
	self assert: oldKeywords size = newKeywords size.
	args := self methodClass newParser parseParameterNames: aText string.
	newSelectorWithArgs := String streamContents: [:stream |
		newKeywords withIndexDo: [:keyword :index |
			stream nextPutAll: keyword.
			stream space.
			args size >= index ifTrue: [
				stream nextPutAll: (args at: index); space]]].
	lastSelectorToken := args isEmpty
		ifFalse: [args last]
		ifTrue: [oldKeywords last].
	startOfSource := (aText string
		indexOfSubCollection: lastSelectorToken startingAt: 1) + lastSelectorToken size.
	^newSelectorWithArgs withBlanksTrimmed asText , (aText copyFrom: startOfSource to: aText size)
]

{ #category : #accessing }
CompiledMethod >> returnField [
	"Answer the index of the instance variable returned by a quick return 
	method."
	| prim |
	prim := self primitive.
	prim < 264
		ifTrue: [self error: 'only meaningful for quick-return']
		ifFalse: [^ prim - 264]
]

{ #category : #scanning }
CompiledMethod >> scanForInstructionPattern: tuple [
	"Convenient use of scanForInstructionSequence:
	 e.g. self systemNavigation browseAllSelect: [:m| m scanForInstructionPattern: #((pushConstant: true) (send:super:numArgs: spilled: false 1))]
	        self systemNavigation browseAllSelect: [:m| m scanForInstructionPattern: #((send:super:numArgs: arguments false 0) (send:super:numArgs: = false 1))]"
	| first firstArgs second secondArgs third thirdArgs |
	^(InstructionStream on: self) scanForInstructionSequence:
		(tuple size caseOf: {
			[1]	-> [first := tuple first.
					firstArgs := first allButFirst.
					first := first first.
					[:a|
					 a selector == first and: [a arguments = firstArgs]]].
			[2]	-> [first := tuple first.
					firstArgs := first allButFirst.
					second := tuple second.
					secondArgs := second allButFirst.
					first := first first.
					second := second first.
					[:a :b|
					 a selector == first and: [a arguments = firstArgs
					 and: [b selector == second and: [b arguments = secondArgs]]]]].
			[3]	-> [first := tuple first.
					firstArgs := first allButFirst.
					second := tuple second.
					secondArgs := second allButFirst.
					third := tuple third.
					thirdArgs := third allButFirst.
					first := first first.
					second := second first.
					third := third first.
					[:a :b :c|
					 a selector == first and: [a arguments = firstArgs
					 and: [b selector == second and: [b arguments = secondArgs
					 and: [c selector == third and: [c arguments = thirdArgs]]]]]]] })
]

{ #category : #scanning }
CompiledMethod >> scanForInstructionSequence: naryBlock [
	"naryBlock is a block taking one or more arguments.
	 Evaluate it for each sequence of instructions of length
	 n in the receiver until naryBlock evaluates to true.
	 Answer if naryBlock evaluated to true."
	^(InstructionStream on: self) scanForInstructionSequence: naryBlock
"
self systemNavigation browseAllSelect: [:m | m scanForInstructionSequence: [:msg| msg selector = #send:super:numArgs: and: [msg arguments second]]] localTo: thisContext class
"
]

{ #category : #accessing }
CompiledMethod >> searchForClass [
	"search me in all classes, if found, return my class. Slow!"
	self systemNavigation allBehaviorsDo: [:class | 
		(class methodDict keyAtIdentityValue: self ifAbsent: [nil]) ifNotNil: [^class]].
	^nil.
]

{ #category : #accessing }
CompiledMethod >> searchForSelector [
	"search me in all classes, if found, return my selector. Slow!"
	self systemNavigation allBehaviorsDo: [:class | 
		| selector |
		(selector := class methodDict keyAtIdentityValue: self ifAbsent: [nil]) ifNotNil: [^selector]].
	^nil.
]

{ #category : #accessing }
CompiledMethod >> selector [
	"Answer a method's selector.  This is either the penultimate literal,
	 or, if the method has any properties or pragmas, the selector of
	 the AdditionalMethodState stored in the penultimate literal."
	| penultimateLiteral | 
	^(penultimateLiteral := self penultimateLiteral) isMethodProperties
		ifTrue: [penultimateLiteral selector]
		ifFalse: [penultimateLiteral]
]

{ #category : #accessing }
CompiledMethod >> selector: aSelector [
	"Set a method's selector.  This is either the penultimate literal,
	 or, if the method has any properties or pragmas, the selector of
	 the MethodProperties stored in the penultimate literal."
	| penultimateLiteral nl | 
	(penultimateLiteral := self penultimateLiteral) isMethodProperties
		ifTrue: [penultimateLiteral selector: aSelector]
		ifFalse: [(nl := self numLiterals) < 2 ifTrue:
					[self error: 'insufficient literals to hold selector'].
				self literalAt: nl - 1 put: aSelector]
]

{ #category : #'source code management' }
CompiledMethod >> setSourcePointer: srcPointer [
	"We can't necessarily change the trailer of existing method, since
	 it could have a completely different format. If so, generate a copy
	 with a new trailer, containing a srcPointer, and then become it."
	| newTrailer myTrailer |
	myTrailer := self trailer.
	srcPointer = 0
		ifTrue: "catch the common case of setting the source pointer to 0 when already 0"
			[myTrailer sourcePointer = 0 ifTrue:
				[^self].
			 newTrailer := CompiledMethodTrailer empty]
		ifFalse:
			[newTrailer := CompiledMethodTrailer new sourcePointer: srcPointer].
	(myTrailer size = newTrailer size
	 and: [myTrailer kind = newTrailer kind]) ifTrue:
		[^newTrailer copyToMethod: self].

	^self becomeForward: (self copyWithTrailerBytes: newTrailer)
]

{ #category : #'source code management' }
CompiledMethod >> setSourcePosition: position inFile: fileIndex [ 
	self setSourcePointer: (SourceFiles sourcePointerFromFileIndex: fileIndex andPosition: position)
]

{ #category : #'source code management' }
CompiledMethod >> sourceClass [
	"Get my receiver class (method class) from the preamble of my source.  Return nil if not found."

	^ [(Compiler evaluate: (self sourceFileStream backChunk "blank"; backChunk "preamble")) theClass] on: Error do: [nil]
]

{ #category : #'source code management' }
CompiledMethod >> sourceFileStream [ 
	"Answer the sources file stream with position set at the beginning of my source string"

	| pos |
	(pos := self filePosition) = 0 ifTrue: [^ nil].
	^ (RemoteString newFileNumber: self fileIndex position: pos) fileStream
]

{ #category : #'source code management' }
CompiledMethod >> sourcePointer [
	"Answer the integer which can be used to find the source file and position for this method.
	The actual interpretation of this number is up to the SourceFileArray stored in the global variable SourceFiles."

	^ self trailer sourcePointer

]

{ #category : #'source code management' }
CompiledMethod >> sourceSelector [
	"Answer my selector extracted from my source.  If no source answer nil"

	| sourceString |
	sourceString := self getSourceFromFile ifNil: [^ nil].
	^self methodClass newParser parseSelector: sourceString
]

{ #category : #printing }
CompiledMethod >> storeLiteralsOn: aStream forClass: aBehavior [
	"Store the literals referenced by the receiver on aStream, each terminated by a space."

	| literal |
	2 to: self numLiterals + 1 do:
		[:index |
		 aBehavior storeLiteral: (self objectAt: index) on: aStream.
		 aStream space]
]

{ #category : #'source code management' }
CompiledMethod >> tempNames [
	^self debuggerMap tempNamesForMethod: self
]

{ #category : #'source code management' }
CompiledMethod >> tempNamesString [
	"Answer the schematicTempNames string, or nil if receiver has no temps names encoded in trailer"
	^ self trailer tempNames
]

{ #category : #printing }
CompiledMethod >> timeStamp [
	"Answer the authoring time-stamp for the given method, retrieved from the sources or changes file. Answer the empty string if no time stamp is available."
	"(CompiledMethod compiledMethodAt: #timeStamp) timeStamp"

	| preamble stamp tokens tokenCount |
	stamp := nil.
	preamble := self preamble.
	tokens := (preamble findString: 'methodsFor:' startingAt: 1) > 0
		ifTrue: [Scanner new scanTokens: preamble]
		ifFalse: [#()  "ie cant be back ref"].
	(((tokenCount := tokens size) between: 7 and: 8) and: [(tokens at: tokenCount - 5) == #methodsFor:])
		ifTrue:
			[(tokens at: tokenCount - 3) == #stamp:
				ifTrue: ["New format gives change stamp and unified prior pointer"
						stamp := tokens at: tokenCount - 2]].
	((tokenCount between: 5 and: 6) and: [(tokens at: tokenCount - 3) == #methodsFor:])
		ifTrue:
			[(tokens at: tokenCount  - 1) == #stamp:
				ifTrue: ["New format gives change stamp and unified prior pointer"
					stamp := tokens at: tokenCount]].
	^stamp ifNil: [ String new ]

]

{ #category : #testing }
CompiledMethod >> usesClosureBytecodes [
	"Answer whether the receiver was compiled using the closure compiler.
	 This is used to help DebuggerMethodMap choose which mechanisms to
	 use to inspect activations of the receiver.
	 This method answers false negatives in that it only identifies methods
	 that use the new BlockClosure bytecodes.
	 But since methods that don't create blocks have essentially the same
	 code when compiled with either compiler this makes little difference."

	^self encoderClass supportsClosures
]

{ #category : #evaluating }
CompiledMethod >> valueWithReceiver: aReceiver arguments: anArray [ 

	^self class receiver: aReceiver withArguments: anArray executeMethod: self
]

{ #category : #converting }
CompiledMethod >> withoutPrimitive [
	"Answers a copy of self without primitive call.
	That may serve for example for testing fallback code."
	
	| copy skipPrimitiveCall |
	self primitive = 0 ifTrue: [^self].
	skipPrimitiveCall := 3.
	copy := CompiledMethod 
		newMethod: self basicSize - self initialPC + 1 - skipPrimitiveCall
		header: (self header bitClear: 16r10000).
	1 to: self numLiterals do: [:index| copy literalAt: index put: (self literalAt: index)].
	self initialPC + skipPrimitiveCall to: self size do: [:index | copy at: index - skipPrimitiveCall put: (self at: index)].
	copy postCopy.
	^copy
]

{ #category : #scanning }
CompiledMethod >> writesField: varIndex [
	"Answer whether the receiver stores into the instance variable indexed by the argument."

	| varIndexCode scanner |
	self isQuick ifTrue: [^ false].
	varIndexCode := varIndex - 1.
	
	self codeLiteralsDo: [:compiledCode | 
		scanner := InstructionStream on: compiledCode.
		(scanner scanFor: (self encoderClass instVarWriteScanBlockFor: varIndex - 1 using: scanner))
			ifTrue: [^ true]].
	
	^ false
]

{ #category : #scanning }
CompiledMethod >> writesRef: variableBinding [ 
	"Answer whether the receiver writes the value of the argument."
	"eem 5/24/2008 Rewritten to no longer assume the compler uses the
	 most compact encoding available (for EncoderForLongFormV3 support)."
	
	| litIndex scanner |
	(litIndex := self indexOfLiteral: variableBinding) = 0
		ifTrue: [^ false].
	
	self codeLiteralsDo: [:compiledCode | 
		scanner := InstructionStream on: compiledCode.
		(scanner scanFor: (self encoderClass bindingWriteScanBlockFor: litIndex - 1 using: scanner))
			ifTrue: [^ true]].

	^ false
]

{ #category : #'file in\/out' }
CompiledMethod >> zapSourcePointer [

	"clobber the source pointer since it will be wrong"
	| copy |
	copy := self copyWithTrailerBytes: CompiledMethodTrailer empty.
	self becomeForward: copy.
	^ copy

]
