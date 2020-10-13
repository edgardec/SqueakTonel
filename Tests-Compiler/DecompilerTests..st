"
Apparently the decompiler does not really work totally.
Here are a bunch of methods that can help improving the decompiler:
	- blockingClasses return class for which it is impossible to decompile methods 
	- failures are problems that lead to a DNU
	- decompilerDiscrepancies are the results of running decompileTestHelper..as you see the pattern 	
	is quite present.
"
Class {
	#name : #DecompilerTests,
	#superclass : #LongTestCase,
	#category : #'Tests-Compiler'
}

{ #category : #utilities }
DecompilerTests >> basePackagePrefixes [

	^ #(
		'Kernel' "includes KernelTests"
		'Collections' "includes CollectionsTests"
		'Chronology'
		'Compiler'
		'Environments'
		'Traits'
		'PackageInfo'
		
		'Graphics' "includes GraphicsTests"
		'Balloon' "includes BalloonTests"
		'TrueType'

		'Sound'		

		'Network' "includes NetworkTests"
		'WebClient'
		'SqueakSSL'
		'XML'

		'Files'
		'Compression'
		'Regex'
		'System'
		
		'ST80' "includes ST80Tests"
		'Morphic' "includes MorphicTests and MorphicExtras"
		'Etoys'
		
		'Installer'
		'Monticello'
		'VersionNumber'
		'UpdateStream'
		'SMBase'
		'SMLoader'
		'Squeak-Version'
						
		'GetText' 
		'Multilingual' "includes MultilingualTests"		
		'Help' "includes HelpSystem"

		'ToolBuilder'
		'Tools'
		'CommandLine' 
		'Nebraska' 
		'PreferenceBrowser'
		'Protocols'
		'SUnit'
		'ScriptLoader'
		'Services'
		'Shout'
 
		'Tests'
		'ReleaseBuilder'
	)
]

{ #category : #utilities }
DecompilerTests >> checkDecompileMethod: oldMethod [
	
	| cls selector oldMethodNode methodNode newMethod oldCodeString newCodeString |
	cls := oldMethod methodClass.
	selector := oldMethod selector.
	oldMethodNode := (cls decompilerClass new withTempNames: oldMethod methodNode schematicTempNamesString)
							decompile: selector
							in: cls
							method: oldMethod methodForDecompile.
	[oldMethodNode properties includesKey: #warning] whileTrue:
		[oldMethodNode properties removeKey: #warning].
	oldCodeString := oldMethodNode decompileString.
	methodNode := [[| compiler |
					   compiler := cls newCompiler.
					   compiler parser encoderClass: oldMethod encoderClass.
					   compiler
						compile: oldCodeString
						in: cls
						notifying: nil
						ifFail: []]
						on: SyntaxErrorNotification
						do: [:ex|
							ex errorMessage = 'Cannot store into' ifTrue:
								[ex return: #badStore].
							ex pass]]
						on: OutOfScopeNotification
						do: [:ex| ex return: #badStore].
	"Ignore cannot store into block arg errors; they're not our issue."
	methodNode ~~ #badStore ifTrue:
		[newMethod := methodNode generate.
		 newCodeString := ((cls decompilerClass new withTempNames: methodNode schematicTempNamesString)
								decompile: selector
								in: cls
								method: newMethod methodForDecompile) decompileString.
		 "(StringHolder new textContents:
			(TextDiffBuilder buildDisplayPatchFrom: oldCodeString to: newCodeString))
				openLabel: 'Decompilation Differences for ', cls name,'>>',selector"
		 "(StringHolder new textContents:
			(TextDiffBuilder buildDisplayPatchFrom: oldMethod abstractSymbolic to: newMethod abstractSymbolic))
				openLabel: 'Bytecode Differences for ', cls name,'>>',selector"
		 self assert: (oldCodeString = newCodeString
					or: [(Scanner new scanTokens: oldCodeString) = (Scanner new scanTokens: newCodeString)])
			description: cls name asString, ' ', selector asString
			resumable: true]
]

{ #category : #utilities }
DecompilerTests >> classNames [
	"A list of the classes in most of the base packages; excluding EToys arbitrarily for now"
	
	| prefixes |
	prefixes := self basePackagePrefixes.
	^Smalltalk globals allClassesAndTraits
		select:
			[:classOrTrait|
			 classOrTrait category
				ifNil: [false]
				ifNotNil: 
					[:category|
					 prefixes anySatisfy: [:packageRoot| category beginsWith: packageRoot]]]
		thenCollect:
			[:classOrTrait| classOrTrait name]
]

{ #category : #utilities }
DecompilerTests >> decompileClassesSelect: aBlock [

	CurrentReadOnlySourceFiles cacheDuring:
		[ (self classNames select: aBlock) do:
			[ :cn | | class |
			(class := Smalltalk classNamed: cn) selectorsAndMethodsDo:
				[ :selector :method |
				(self isUnacceptableExtension: selector inClass: class) ifFalse:
					[(self exceptionClassForFailureFor: class selector: selector)
						ifNil: [ self checkDecompileMethod: method ]
						ifNotNil:
							[ :exceptionClass |
							self
								should: [ self checkDecompileMethod: method ]
								raise: exceptionClass ] ] ] ] ]
]

{ #category : #utilities }
DecompilerTests >> decompileStringForParseTree: aMethodNode [
	"Renumber the temps in the tree in parse tree order to eliminate that as a source of extraneous difference."
	| visited count counter |
	visited := IdentitySet new.
	count := 0.
	counter := [:temp|
				(visited includes: temp) ifFalse:
					[temp name: 't', (count := count + 1) printString.
					 visited add: temp]].
	aMethodNode nodesDo:
		[:node|
		(node == aMethodNode or: [node isBlockNode and: [node optimized not]]) ifTrue:
			[node arguments do: counter].
		node isTemp ifTrue:
			[counter value: node]].
	
	aMethodNode nodesDo:
		[:node|
		(node == aMethodNode or: [node isBlockNode and: [node optimized not]]) ifTrue:
			[node temporaries do: counter.
			 node temporaries: (node temporaries sorted: ParseNode tempSortBlock) ]].
	^aMethodNode decompileString
]

{ #category : #utilities }
DecompilerTests >> decompilerFailures [
	"Here is the list of failures: either a syntax error, a hard error or some failure to decompile correctly.
	 Collected initially via 
		DecompilerTestFailuresCollector new computeFailures.
	 But can be maintained manually."

	"class name, selector, error class name or nil"
	^#(
		#(BrowserCommentTextMorph showPane SyntaxErrorNotification) 
		#(CodeHolder getSelectorAndSendQuery:to:with: SyntaxErrorNotification) 
		#(DecompilerTests testDecompileUnreachableParameter Error) 
		#(MVCToolBuilder setLayout:in: SyntaxErrorNotification) "same-name block-local temps in optimized blocks"
		#(PNGReadWriter copyPixelsGray: SyntaxErrorNotification)
		#(SHMCClassDefinition withAllSuperclassesDo: SyntaxErrorNotification)), "same-name block-local temps in optimized blocks"
	 (Scanner allowBlockArgumentAssignment
		ifTrue: [#()]
		ifFalse:
			[#(
		#(NebraskaSenderMorph hideField: SyntaxErrorNotification)) "assigns into block argument"])
]

{ #category : #utilities }
DecompilerTests >> exceptionClassForFailureFor: class selector: selector [
	
	^self decompilerFailures
		detect: [ :each | each first = class name and: [ each second = selector ] ]
		ifFound: [ :each | each third ifNotNil: [ Smalltalk classNamed: each third ] ]
		ifNone: [ nil ]
]

{ #category : #failures }
DecompilerTests >> expectedFailures [
	^ #(testDecompileUnreachableParameter)
]

{ #category : #utilities }
DecompilerTests >> isUnacceptableExtension: selector inClass: class [
	"Filter-out extensions outside the base packages"
	| category |
	category := class whichCategoryIncludesSelector: selector.
	^category notEmpty
	 and: [category first == $*
	 and: [category := category allButFirst.
		self basePackagePrefixes noneSatisfy: [:prefix| category beginsWith: prefix]]]
]

{ #category : #running }
DecompilerTests >> tearDown [
	self class removeSelector: #loopWithMovingLimit
]

{ #category : #tests }
DecompilerTests >> testDecompileAnswerToDoLoop [
	"This is a non regression test for Compiler-nice.224."
	"DecompilerTests new testDecompileAnswerToDoLoop"
	| sourceCode mn decompiledCode  |
	sourceCode := '^nil to: 3 do: [:i| i class]'.
	mn := self class newCompiler compileNoPattern: sourceCode in: self class notifying: nil ifFail: [self error: 'failed'].
	decompiledCode := mn generateWithTempNames decompileWithTemps asString.
	
	"This to avoid getting fooled by changes in decompilation due to code formatting preferences."
	decompiledCode := decompiledCode copyReplaceAll: {Character cr. Character tab. Character tab } with: ' '.
	decompiledCode := decompiledCode copyReplaceAll: '^ ' with: '^'.
	decompiledCode := decompiledCode copyReplaceAll: ' |' with: '|'.
	self
		assert: (decompiledCode endsWith: sourceCode)
		description: 'decompilation should match source'.
]

{ #category : #tests }
DecompilerTests >> testDecompileLoopWithMovingLimit [
	"This is a non regression test for http://bugs.squeak.org/view.php?id=7093"
	
	| decompiledCode sourceCode |
	sourceCode := 'loopWithMovingLimit
	"This loop might be decompiled as a to:do: but should not because it does modify its limit"
	| n i |
	n := 4.
	i := 1.
	[i <= n] whileTrue: [
		n := n - 1.
		i := i + 1].
	^n'.
	self class compileSilently: sourceCode.
	self assert: (self class includesSelector: #loopWithMovingLimit).
	self assert: 2 equals: (self perform: #loopWithMovingLimit).
	decompiledCode := self class decompile: #loopWithMovingLimit.
	self class compileSilently: decompiledCode decompileString.
	self
		assert: 2
		equals: (self perform: #loopWithMovingLimit)
		description: 'result from decompiledCode should not differ from sourceCode'.
]

{ #category : #'failing decompile tests' }
DecompilerTests >> testDecompileUnreachableParameter [
	"The call to #value: is unreachable because both blocks in the #ifTrue:ifFalse: send force a return."
	[self value: (true ifTrue: [^true] ifFalse: [^false])] decompile.
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesAAtoAM [
	self decompileClassesSelect: [:cn| cn first = $A and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesANtoAZ [
	self decompileClassesSelect: [:cn| cn first = $A and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesBAtoBM [
	self decompileClassesSelect: [:cn| cn first = $B and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesBNtoBZ [
	self decompileClassesSelect: [:cn| cn first = $B and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesCAtoCM [
	self decompileClassesSelect: [:cn| cn first = $C and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesCNtoCZ [
	self decompileClassesSelect: [:cn| cn first = $C and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesDAtoDM [
	self decompileClassesSelect: [:cn| cn first = $D and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesDNtoDZ [
	self decompileClassesSelect: [:cn| cn first = $D and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesEAtoEM [
	self decompileClassesSelect: [:cn| cn first = $E and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesENtoEZ [
	self decompileClassesSelect: [:cn| cn first = $E and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesFAtoFM [
	self decompileClassesSelect: [:cn| cn first = $F and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesFNtoFZ [
	self decompileClassesSelect: [:cn| cn first = $F and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesGAtoGM [
	self decompileClassesSelect: [:cn| cn first = $G and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesGNtoGZ [
	self decompileClassesSelect: [:cn| cn first = $G and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesHAtoHM [
	self decompileClassesSelect: [:cn| cn first = $H and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesHNtoHZ [
	self decompileClassesSelect: [:cn| cn first = $H and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesIAtoIM [
	self decompileClassesSelect: [:cn| cn first = $I and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesINtoIZ [
	self decompileClassesSelect: [:cn| cn first = $I and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesJAtoJM [
	self decompileClassesSelect: [:cn| cn first = $J and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesJNtoJZ [
	self decompileClassesSelect: [:cn| cn first = $J and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesKAtoKM [
	self decompileClassesSelect: [:cn| cn first = $K and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesKNtoKZ [
	self decompileClassesSelect: [:cn| cn first = $K and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesLAtoLM [
	self decompileClassesSelect: [:cn| cn first = $L and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesLNtoLZ [
	self decompileClassesSelect: [:cn| cn first = $L and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesMAtoMM [
	self decompileClassesSelect: [:cn| cn first = $M and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesMNtoMZ [
	self decompileClassesSelect: [:cn| cn first = $M and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesNAtoNM [
	self decompileClassesSelect: [:cn| cn first = $N and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesNNtoNZ [
	self decompileClassesSelect: [:cn| cn first = $N and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesOAtoOM [
	self decompileClassesSelect: [:cn| cn first = $O and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesONtoOZ [
	self decompileClassesSelect: [:cn| cn first = $O and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesPAtoPM [
	self decompileClassesSelect: [:cn| cn first = $P and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesPNtoPZ [
	self decompileClassesSelect: [:cn| cn first = $P and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesQAtoQM [
	self decompileClassesSelect: [:cn| cn first = $Q and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesQNtoQZ [
	self decompileClassesSelect: [:cn| cn first = $Q and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesRAtoRM [
	self decompileClassesSelect: [:cn| cn first = $R and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesRNtoRZ [
	self decompileClassesSelect: [:cn| cn first = $R and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesSAtoSM [
	self decompileClassesSelect: [:cn| cn first = $S and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesSNtoSZ [
	self decompileClassesSelect: [:cn| cn first = $S and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesTAtoTM [
	self decompileClassesSelect: [:cn| cn first = $T and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesTNtoTZ [
	self decompileClassesSelect: [:cn| cn first = $T and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesUAtoUM [
	self decompileClassesSelect: [:cn| cn first = $U and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesUNtoUZ [
	self decompileClassesSelect: [:cn| cn first = $U and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesVAtoVM [
	self decompileClassesSelect: [:cn| cn first = $V and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesVNtoVZ [
	self decompileClassesSelect: [:cn| cn first = $V and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesWAtoWM [
	self decompileClassesSelect: [:cn| cn first = $W and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesWNtoWZ [
	self decompileClassesSelect: [:cn| cn first = $W and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesXAtoXM [
	self decompileClassesSelect: [:cn| cn first = $X and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesXNtoXZ [
	self decompileClassesSelect: [:cn| cn first = $X and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesYAtoYM [
	self decompileClassesSelect: [:cn| cn first = $Y and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesYNtoYZ [
	self decompileClassesSelect: [:cn| cn first = $Y and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesZAtoZM [
	self decompileClassesSelect: [:cn| cn first = $Z and: [cn second asUppercase <= $M]]
]

{ #category : #tests }
DecompilerTests >> testDecompilerInClassesZNtoZZ [
	self decompileClassesSelect: [:cn| cn first = $Z and: [cn second asUppercase > $M]]
]

{ #category : #tests }
DecompilerTests >> testRemoteTemp [
	| aBlock |
	aBlock := Compiler evaluate: '| x y |  [:a :b | x := a. y := b. x+y]'.
	
	"This should not fail."
	aBlock decompile
	
]
