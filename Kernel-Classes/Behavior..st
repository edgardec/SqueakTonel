"
My instances describe the behavior of other objects. I provide the minimum state necessary for compiling methods, and creating and running instances. Most objects are created as instances of the more fully supported subclass, Class, but I am a good starting point for providing instance-specific behavior (as in Metaclass).
"
Class {
	#name : #Behavior,
	#superclass : #Object,
	#instVars : [
		'superclass',
		'methodDict',
		'format'
	],
	#classVars : [
		'ObsoleteSubclasses'
	],
	#category : #'Kernel-Classes'
}

{ #category : #testing }
Behavior class >> canZapMethodDictionary [
	"Return false since zapping the method dictionary of Behavior class or its subclasses will cause the system to fail."
	^false
]

{ #category : #'class initialization' }
Behavior class >> cleanUp [
	"Flush the obsolete subclasses."

	self flushObsoleteSubclasses
]

{ #category : #'class initialization' }
Behavior class >> flushObsoleteSubclasses [
	"Behavior flushObsoleteSubclasses"
	ObsoleteSubclasses finalizeValues.
]

{ #category : #'class initialization' }
Behavior class >> initialize [
	"Behavior initialize"
	"Never called for real"
	ObsoleteSubclasses
		ifNil: [self initializeObsoleteSubclasses]
		ifNotNil: [| newDict | 
			newDict := WeakKeyToCollectionDictionary newFrom: ObsoleteSubclasses.
			newDict rehash.
			ObsoleteSubclasses := newDict]
]

{ #category : #'class initialization' }
Behavior class >> initializeObsoleteSubclasses [
	ObsoleteSubclasses := WeakKeyToCollectionDictionary new.
]

{ #category : #'accessing method dictionary' }
Behavior >> >> selector [ 
	"Answer the compiled method associated with the argument, selector (a 
	Symbol), a message selector in the receiver's method dictionary. If the 
	selector is not in the dictionary, create an error notification."

	^self compiledMethodAt: selector

]

{ #category : #'obsolete subclasses' }
Behavior >> addObsoleteSubclass: aClass [
	"Weakly remember that aClass was a subclass of the receiver and is now obsolete"
	| obs |

	obs := ObsoleteSubclasses at: self ifAbsent:[WeakArray new].
	(obs includes: aClass) ifTrue:[^self].
	obs := obs copyWithout: nil.
	obs := obs copyWith: aClass.
	ObsoleteSubclasses at: self put: obs.

]

{ #category : #'adding\/removing methods' }
Behavior >> addSelector: selector withMethod: compiledMethod [ 
	^ self addSelector: selector withMethod: compiledMethod notifying: nil
]

{ #category : #'adding\/removing methods' }
Behavior >> addSelector: selector withMethod: compiledMethod notifying: requestor [
	^ self basicAddSelector: selector withMethod: compiledMethod
]

{ #category : #'adding\/removing methods' }
Behavior >> addSelectorSilently: selector withMethod: compiledMethod [
	self basicAddSelector: selector withMethod: compiledMethod.
]

{ #category : #'instance creation' }
Behavior >> adoptInstance: anObject [
	"Change the class of anObject to me.
	Primitive (found in Cog and new VMs)  follows the same rules as primitiveChangeClassTo:, but returns the class rather than the modified instance"

	<primitive: 160 error: ec>
	ec == #'no modification' ifTrue:
		[^self modificationForbiddenAdopting: anObject].
	self primitiveFailed
]

{ #category : #'accessing instances and variables' }
Behavior >> allClassVarNames [
	"Answer a Set of the names of the receiver's and the receiver's ancestor's 
	class variables."

	^superclass allClassVarNames
]

{ #category : #'accessing instances and variables' }
Behavior >> allInstVarNames [
	"Answer an Array of the names of the receiver's instance variables. The 
	Array ordering is the order in which the variables are stored and 
	accessed by the interpreter."

	| vars |
	superclass == nil
		ifTrue: [vars := self instVarNames copy]	"Guarantee a copy is answered."
		ifFalse: [vars := superclass allInstVarNames , self instVarNames].
	^vars
]

{ #category : #'accessing instances and variables' }
Behavior >> allInstances [
	"Answer all instances of the receiver."
	<primitive: 177>
	"The primitive can fail because memory is low.  If so, fall back on the old
	 enumeration code, which gives the system a chance to GC and/or grow.
	 Because aBlock might change the class of inst (for example, using become:),
	 it is essential to compute next before aBlock value: inst."
	| inst insts next |
	insts := WriteStream on: (Array new: 64).
	inst := self someInstance.
	[inst == nil] whileFalse:
		[next := inst nextInstance.
		 (inst == insts or: [inst == insts originalContents]) ifFalse: [insts nextPut: inst].
		 inst := next].
	^insts contents
]

{ #category : #enumerating }
Behavior >> allInstancesDo: aBlock [
	"Evaluate aBlock with each of the current instances of the receiver."
	| instances inst next |
	instances := self allInstancesOrNil.
	instances ifNotNil:
		[instances do: aBlock.
		 ^self].
	"allInstancesOrNil can fail because memory is low.  If so, fall back on the old
	 enumeration code.  Because aBlock might change the class of inst (for example,
	 using become:), it is essential to compute next before aBlock value: inst."
	inst := self someInstance.
	[inst == nil] whileFalse:
		[next := inst nextInstance.
		 aBlock value: inst.
		 inst := next]
]

{ #category : #enumerating }
Behavior >> allInstancesOrNil [
	"Answer all instances of the receiver, or nil if the primitive
	 fails, which it may be due to being out of memory."
	<primitive: 177>
	^nil
]

{ #category : #'accessing method dictionary' }
Behavior >> allSelectors [
    "Answer all selectors understood by instances of the receiver"

    ^(Array streamContents: [ :stream |
        self withAllSuperclassesDo: [ :aClass |
            aClass selectorsDo: [ :each | 
                stream nextPut: each ] ] ]) asIdentitySet
]

{ #category : #'accessing method dictionary' }
Behavior >> allSelectorsBelow: topClass [ 
	| coll |
	coll := IdentitySet new.
	self withAllSuperclassesDo: 
			[:aClass | 
			aClass = topClass
				ifTrue: [^ coll ]
				ifFalse: [aClass selectorsDo: [ :sel | coll add: sel ]]].
	^ coll
	


]

{ #category : #'accessing instances and variables' }
Behavior >> allSharedPools [
	"Answer a Set of the names of the pools (Dictionaries or SharedPool subclasses) that the receiver and the receiver's ancestors share."

	^superclass allSharedPools
]

{ #category : #'accessing instances and variables' }
Behavior >> allSubInstances [ 
	"Answer a list of all current instances of the receiver and all of its subclasses."
	| aCollection |
	aCollection := OrderedCollection new.
	self allSubInstancesDo:
		[:x | x == aCollection ifFalse: [aCollection add: x]].
	^ aCollection
]

{ #category : #enumerating }
Behavior >> allSubInstancesDo: aBlock [ 
	"Evaluate the argument, aBlock, for each of the current instances of the 
	receiver and all its subclasses."

	self allInstancesDo: aBlock.
	self allSubclassesDo: [:sub | sub allInstancesDo: aBlock]
]

{ #category : #'accessing class hierarchy' }
Behavior >> allSubclasses [
	"Answer a Collection of the receiver's and the receiver's descendent's subclasses. "

	| scan scanTop |
	scan := OrderedCollection withAll: self subclasses.
	scanTop := 1.
	[scanTop > scan size]
		whileFalse: [scan addAll: (scan at: scanTop) subclasses.
			scanTop := scanTop + 1].
	^ scan
]

{ #category : #enumerating }
Behavior >> allSubclassesDo: aBlock [ 
	"Evaluate the argument, aBlock, for each of the receiver's subclasses."

	self subclassesDo: 
		[:cl | 
		aBlock value: cl.
		cl allSubclassesDo: aBlock]
]

{ #category : #enumerating }
Behavior >> allSubclassesDoGently: aBlock [ 
	"Evaluate the argument, aBlock, for each of the receiver's subclasses."

	self subclassesDoGently: 
		[:cl | 
		cl isInMemory ifTrue: [
			aBlock value: cl.
			cl allSubclassesDoGently: aBlock]]
]

{ #category : #'accessing class hierarchy' }
Behavior >> allSubclassesWithLevelDo: classAndLevelBlock startingLevel: level [ 
	"Walk the tree of subclasses, giving the class and its level"

	classAndLevelBlock value: self value: level.
	self == Class ifTrue:  [^ self].  "Don't visit all the metaclasses"
	"Visit subclasses in alphabetical order"
	self subclasses
		sort: [ :a :b | a name <= b name ];
		do: [ :subclass | 
			subclass
				allSubclassesWithLevelDo: classAndLevelBlock
				startingLevel: level + 1 ]
]

{ #category : #'accessing class hierarchy' }
Behavior >> allSuperclasses [
	"Answer an OrderedCollection of the receiver's and the receiver's  
	ancestor's superclasses. The first element is the receiver's immediate  
	superclass, followed by its superclass; the last element is Object."
	| temp |
	^ superclass == nil
		ifTrue: [ OrderedCollection new]
		ifFalse: [temp := superclass allSuperclasses.
			temp addFirst: superclass.
			temp]
]

{ #category : #enumerating }
Behavior >> allSuperclassesDo: aBlock [ 
	"Evaluate the argument, aBlock, for each of the receiver's superclasses."

	superclass == nil
		ifFalse: [aBlock value: superclass.
				superclass allSuperclassesDo: aBlock]
]

{ #category : #'Backstop-Traits' }
Behavior >> allTraits [
	"Backstop. When traits are unloaded there are no traits hiding here."
	^#()
]

{ #category : #'user interface' }
Behavior >> allUnreferencedInstanceVariables [
	"Return a list of the instance variables known to the receiver which are not referenced in the receiver or any of its subclasses OR superclasses"

	^ self allInstVarNames reject: [:ivn |
		| definingClass |		
		definingClass := self classThatDefinesInstanceVariable: ivn.
		definingClass withAllSubclasses anySatisfy: [:class |  
				(class whichSelectorsAccess: ivn asSymbol) notEmpty]]
]

{ #category : #compiling }
Behavior >> allowUnderscoreAssignments [
	"Return true if the receiver and its subclasses should be allowed to use underscore as assignment operator. Returning nil here means that the compiler should use the system-wide default preference. Also see #allowUnderscoreSelectors.

	Combinations: If both preferences are false, underscore is illegal. If both preferences are true, underscore assignment needs the be surrounded by spaces and a single underscore cannot be used as selector."
	^nil
]

{ #category : #'accessing instances and variables' }
Behavior >> allowsSubInstVars [
	"Classes that allow instances to change classes among its subclasses will want to override this and return false, so inst vars are not accidentally added to its subclasses."

	^ true
]

{ #category : #'adding\/removing methods' }
Behavior >> basicAddSelector: selector withMethod: compiledMethod [ 
	"Add the message selector with the corresponding compiled method to the 
	receiver's method dictionary.
	Do this without sending system change notifications"

	self methodDict at: selector put: compiledMethod.
	compiledMethod
		methodClass: self;
		selector: selector.

	"Now flush Squeak's method cache for this selector"
	selector flushCache
]

{ #category : #'instance creation' }
Behavior >> basicNew [
	"Primitive. Answer an instance of the receiver (which is a class) with no 
	 indexable variables. Fail if the class is indexable. Essential. See Object 
	 documentation whatIsAPrimitive.
	
	 If the primitive fails because space is low then the scavenger will run
	 before the method is activated.  Check that space was low and retry
	 via handleFailingBasicNew if so."

	<primitive: 70 error: ec>
	ec == #'insufficient object memory' ifTrue:
		[^self handleFailingBasicNew].
	self isVariable ifTrue: [^self basicNew: 0].
	self primitiveFailed
]

{ #category : #'instance creation' }
Behavior >> basicNew: sizeRequested [
	"Primitive. Answer an instance of this class with the number of indexable
	 variables specified by the argument, sizeRequested.  Fail if this class is not
	 indexable or if the argument is not a positive Integer, or if there is not
	 enough memory available. Essential. See Object documentation whatIsAPrimitive.
	
	 If the primitive fails because space is low then the scavenger will run before the
	 method is activated.  Check args and retry via handleFailingBasicNew: if they're OK."

	<primitive: 71 error: ec>
	(ec == #'insufficient object memory') ifTrue:
		[^self handleFailingBasicNew: sizeRequested].
	(ec == #'bad argument') ifTrue:
		[self error: self printString, ' called #basicNew: with invalid argument ', sizeRequested].
	self isVariable ifFalse:
		[self error: self printString, ' cannot have variable sized instances'].
	self primitiveFailed
]

{ #category : #'adding\/removing methods' }
Behavior >> basicRemoveSelector: selector [ 
	"Assuming that the argument, selector (a Symbol), is a message selector 
	in my method dictionary, remove it and its method. Returns the old method
	if found, nil otherwise."

	| oldMethod |
	oldMethod := self methodDict at: selector ifAbsent: [^ nil].
	self methodDict removeKey: selector.

	"Now flush Squeak's method cache for this selector"
	selector flushCache.
	^oldMethod
]

{ #category : #compiling }
Behavior >> binding [
	^ nil -> self
]

{ #category : #'testing method dictionary' }
Behavior >> bindingOf: varName [
	"Answer the binding of some variable resolved in the scope of the receiver"
	^superclass bindingOf: varName
]

{ #category : #'testing method dictionary' }
Behavior >> bindingOf: varName environment: anEnvironment [
	^superclass bindingOf: varName environment: anEnvironment
]

{ #category : #'accessing instances and variables' }
Behavior >> byteSizeOfInstance [
	"Answer the total memory size of an instance of the receiver."

	<primitive: 181 error: ec>
	self isVariable ifTrue:
		[^self byteSizeOfInstanceOfSize: 0].
	self primitiveFailed
]

{ #category : #'accessing instances and variables' }
Behavior >> byteSizeOfInstanceOfSize: basicSize [
	"Answer the total memory size of an instance of the receiver
	 with the given number of indexable instance variables."

	<primitive: 181 error: ec>
	self isVariable
		ifTrue: "If the primitive overflowed answer a close approximation"
			[(basicSize isInteger
			  and: [basicSize >= 16r1000000]) ifTrue:
				[^2 * (self byteSizeOfInstanceOfSize: basicSize + 1 // 2)
				   - (self byteSizeOfInstanceOfSize: 0)]]
		ifFalse:
			[basicSize = 0 ifTrue:
				[^self byteSizeOfInstance]].
	self primitiveFailed
]

{ #category : #'testing method dictionary' }
Behavior >> canUnderstand: selector [ 
	"Answer whether the receiver can respond to the message whose selector 
	is the argument. The selector can be in the method dictionary of the 
	receiver's class or any of its superclasses."

	(self includesSelector: selector) ifTrue: [^true].
	superclass == nil ifTrue: [^false].
	^superclass canUnderstand: selector
]

{ #category : #testing }
Behavior >> canZapMethodDictionary [
	"Return true if it is safe to zap the method dictionary on #obsolete"
	^true
]

{ #category : #'testing method dictionary' }
Behavior >> classBindingOf: varName [
	"Answer the binding of some variable resolved in the scope of the receiver's class"
	^self bindingOf: varName
]

{ #category : #'testing method dictionary' }
Behavior >> classBindingOf: varName environment: anEnvironment [
	^self bindingOf: varName environment: anEnvironment
]

{ #category : #accessing }
Behavior >> classDepth [

	superclass ifNil: [^ 1].
	^ superclass classDepth + 1
]

{ #category : #'accessing instances and variables' }
Behavior >> classVarNames [
	"Answer a collection of the receiver's class variable names."

	^#()
]

{ #category : #'initialize-release' }
Behavior >> cleanUp [
	"Clean out any caches and other state that should be flushed when trying to get an image into a pristine state. Subclasses may override #cleanUp: to provide different levels of cleanliness"

]

{ #category : #'initialize-release' }
Behavior >> cleanUp: aggressive [
	"Clean out any caches and other state that should be flushed when trying to get an image into a pristine state. The argument should be used to indicate how aggressive the cleanup should be. Some subclasses may act differently depending on its value - for example, ChangeSet will only delete all unused and reinitialize the current change set if we're asking it to be aggressive."

	^self cleanUp
]

{ #category : #'accessing method dictionary' }
Behavior >> commentsAt:  selector [
	"Answer a string representing the first comment in the method associated with selector.  Return an empty string if the relevant source file is not available, or if the method's source code does not contain a comment.  Not smart enough to bypass quotes in string constants, but does map doubled quote into a single quote."


	^self commentsIn:  (self sourceCodeAt: selector) asString.
	
"Behavior commentsAt: #commentsAt:"
]

{ #category : #'accessing method dictionary' }
Behavior >> commentsIn: sourceString [
	"Return the comments as a collection of strings in sourceString. This method along with #nextQuotePosIn:startingFrom: is wrong, because it assumes that all double quote characters are comment delimiters, but even this method has a double quote which is not part of any method comment. Also this method has nothing to do with the Behavior itself. Probably CompiledMethod is the best place for this."
	
	| commentStart nextQuotePos someComments aPos |
	(sourceString includes: $") ifFalse: [^#()].
	someComments:= OrderedCollection new.
	aPos:=1.
	nextQuotePos:= 0.
	[commentStart := sourceString findString: '"' startingAt: aPos.
	nextQuotePos:= self nextQuotePosIn: sourceString startingFrom: commentStart.
	(commentStart ~= 0 and: [nextQuotePos >commentStart])] whileTrue: [
		commentStart ~= nextQuotePos ifTrue: [
			someComments add: ((sourceString copyFrom: commentStart + 1 to: nextQuotePos - 1) copyReplaceAll: '""' with: '"').].
	aPos := nextQuotePos+1].
	^someComments
]

{ #category : #compiling }
Behavior >> compile: code [ 
	"Compile the argument, code, as source code in the context of the 
	receiver. Create an error notification if the code can not be compiled. 
	The argument is either a string or an object that converts to a string or a 
	PositionableStream on an object that converts to a string."

	^self compile: code notifying: nil
]

{ #category : #compiling }
Behavior >> compile: code environment: anEnvironment notifying: requestor trailer: bytes ifFail: failBlock [
	"Compile code in another Environment without logging the source in the changes file"

	| methodNode |
	methodNode  := self newCompiler
				compile: code
				in: self
				environment: anEnvironment
				notifying: requestor
				ifFail: failBlock.
	^ CompiledMethodWithNode generateMethodFromNode: methodNode trailer: bytes.
]

{ #category : #compiling }
Behavior >> compile: code notifying: requestor [ 
	"Compile the argument, code, as source code in the context of the 
	receiver and insEtall the result in the receiver's method dictionary. The 
	second argument, requestor, is to be notified if an error occurs. The 
	argument code is either a string or an object that converts to a string or 
	a PositionableStream. This method also saves the source code."
	
	| methodAndNode |
	methodAndNode  := self
		compile: code "a Text"
		notifying: requestor
		trailer: (self defaultMethodTrailerIfLogSource: true)
		ifFail: [^nil].
	methodAndNode method putSource: code fromParseNode: methodAndNode node inFile: 2
			withPreamble: [:f | f cr; nextPut: $!; nextChunkPut: 'Behavior method'; cr].
	self addSelector: methodAndNode selector withMethod: methodAndNode method notifying: requestor.
	^ methodAndNode selector
]

{ #category : #compiling }
Behavior >> compile: code notifying: requestor trailer: bytes ifFail: failBlock [
	"Compile code without logging the source in the changes file"

	| methodNode |
	methodNode  := self newCompiler
				compile: code
				in: self
				notifying: requestor
				ifFail: failBlock.
	^ CompiledMethodWithNode generateMethodFromNode: methodNode trailer: bytes.
]

{ #category : #compiling }
Behavior >> compileAll [
	^ self compileAllFrom: self
]

{ #category : #compiling }
Behavior >> compileAllFrom: oldClass [
	"Compile all the methods in the receiver's method dictionary.
	 This validates sourceCode and variable references and forces
	 all methods to use the current bytecode set"

	"ar 7/10/1999: Use oldClass selectors not self selectors"
	oldClass selectorsDo: [:sel | self recompile: sel from: oldClass]
]

{ #category : #'accessing method dictionary' }
Behavior >> compiledMethodAt: selector [ 
	"Answer the compiled method associated with the argument, selector (a 
	Symbol), a message selector in the receiver's method dictionary. If the 
	selector is not in the dictionary, create an error notification."

	^ self methodDict at: selector
]

{ #category : #'accessing method dictionary' }
Behavior >> compiledMethodAt: selector ifAbsent: aBlock [
	"Answer the compiled method associated with the argument, selector (a Symbol), a message selector in the receiver's method dictionary. If the selector is not in the dictionary, return the value of aBlock"

	^ self methodDict at: selector ifAbsent: aBlock
]

{ #category : #compiling }
Behavior >> compilerClass [
	"Answer a compiler class appropriate for source methods of this class."

	^Compiler
]

{ #category : #'accessing method dictionary' }
Behavior >> compress [
	"Compact the method dictionary of the receiver."

	self methodDict compact
]

{ #category : #'accessing method dictionary' }
Behavior >> compressedSourceCodeAt: selector [
	"(Paragraph compressedSourceCodeAt: #displayLines:affectedRectangle:) size 721 1921
	Paragraph selectors inject: 0 into: [:tot :sel | tot + (Paragraph compressedSourceCodeAt: sel) size] 13606 31450"
	| rawText parse |
	rawText := (self sourceCodeAt: selector) asString.
	parse := self newCompiler parse: rawText in: self notifying: nil.
	^ rawText compressWithTable:
		((selector keywords ,
		parse tempNames ,
		self instVarNames ,
		#(self super ifTrue: ifFalse:) ,
		((0 to: 7) collect:
			[:i | String streamContents:
				[:s | s cr. i timesRepeat: [s tab]]]) ,
		(self compiledMethodAt: selector) literalStrings)
			sorted: [:a :b | a size > b size])
]

{ #category : #copying }
Behavior >> copyOfMethodDictionary [
	"Return a copy of the receiver's method dictionary"

	^ self methodDict copy
]

{ #category : #'user interface' }
Behavior >> crossReference [
	"Answer an Array of arrays of size 2 whose first element is a message selector in the receiver's method dictionary and whose second element is a set of all message selectors in the method dictionary whose methods send a message with that selector. Subclasses are not included."

	^self selectors asArray sort collect: [:x | Array
			with: (String with: Character cr), x 
			with: (self whichSelectorsReferTo: x)]

	"Point crossReference."
]

{ #category : #compiling }
Behavior >> decompile: selector [ 
	"Find the compiled code associated with the argument, selector, as a 
	message selector in the receiver's method dictionary and decompile it. 
	Answer the resulting source code as a string. Create an error notification 
	if the selector is not in the receiver's method dictionary."

	^self decompilerClass new decompile: selector in: self
]

{ #category : #compiling }
Behavior >> decompilerClass [
	"Answer a decompiler class appropriate for compiled methods of this class."

	^ self compilerClass decompilerClass
]

{ #category : #copying }
Behavior >> deepCopy [
	"Behavior are shared rather than copied."

	^ self
]

{ #category : #compiling }
Behavior >> defaultMethodTrailer [
	^ CompiledMethodTrailer empty
]

{ #category : #compiling }
Behavior >> defaultMethodTrailerIfLogSource: logSource [

	logSource ifFalse: [ ^self defaultMethodTrailer ].
	^CompiledMethodTrailer sourcePointerInFile: 2
]

{ #category : #printing }
Behavior >> defaultNameStemForInstances [
	"Answer a basis for external names for default instances of the receiver.
	For classees, the class-name itself is a good one."

	^ self name
]

{ #category : #'accessing instances and variables' }
Behavior >> elementSize [
	"Answer the size in bytes of an element in the receiver.  The formats are
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (Context BlockClosure AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	| instSpec |
	instSpec := self instSpec.
	instSpec < 9 ifTrue: [^Smalltalk wordSize].
	instSpec >= 16 ifTrue: [^1].
	instSpec >= 12 ifTrue: [^2].
	instSpec >= 10 ifTrue: [^4].
	^8
]

{ #category : #'initialize-release' }
Behavior >> emptyMethodDictionary [

	^ MethodDictionary new
]

{ #category : #accessing }
Behavior >> environment [
	"Return the environment in which the receiver is declared"
	^Smalltalk globals
]

{ #category : #compiling }
Behavior >> evaluatorClass [
	"Answer an evaluator class appropriate for evaluating expressions in the 
	context of this class."

	^Compiler
]

{ #category : #'accessing method dictionary' }
Behavior >> firstCommentAt:  selector [
	"Answer a string representing the first comment in the method associated with selector.  Return an empty string if the relevant source file is not available, or if the method's source code does not contain a comment.  Not smart enough to bypass quotes in string constants, but does map doubled quote into a single quote."

	|someComments|
	someComments := self commentsAt: selector.
	^someComments isEmpty ifTrue: [''] ifFalse: [someComments first]


"Behavior firstCommentAt: #firstCommentAt:"
]

{ #category : #'accessing method dictionary' }
Behavior >> firstPrecodeCommentFor:  selector [
	"If there is a comment in the source code at the given selector that preceeds the body of the method, return it here, else return nil"

	| parser source tree |
	"Behavior firstPrecodeCommentFor: #firstPrecodeCommentFor:"
	(#(Comment Definition Hierarchy) includes: selector)
		ifTrue:
			["Not really a selector"
			^ nil].
	source := self sourceCodeAt: selector asSymbol ifAbsent: [^ nil].
	parser := self newParser.
	tree := 
		parser
			parse: (ReadStream on: source)
			class: self
			noPattern: false
			notifying: nil
			ifFail: [^ nil].
	^ (tree comment ifNil: [^ nil]) first
]

{ #category : #private }
Behavior >> flushCache [
	"Tell the interpreter to remove the contents of its method lookup cache, if it has 
	one.  Essential.  See Object documentation whatIsAPrimitive."

	<primitive: 89>
	self primitiveFailed
]

{ #category : #'accessing method dictionary' }
Behavior >> formalHeaderPartsFor: "olive [ oil" aSelector
	"RELAX!  The warning you may have just seen about possibly having a bad source file does not apply here, because this method *intends* to have its source code start with a comment.
	This method returns a collection giving the parts in the formal declaration for aSelector.  This parse is in support of schemes in which adjutant properties of a method can be declared via special comments secreted in the formal header
	The result will have
     	3 elements for a simple, argumentless selector.
		5 elements for a single-argument selector
		9 elements for a two-argument selector
		13 elements for a three-argument, selector
		etc...

	The syntactic elements are:

		1		comment preceding initial selector fragment

		2		first selector fragment
		3		comment following first selector fragment  (nil if selector has no arguments)

        ----------------------  (ends here for, e.g., #copy)

		4		first formal argument
		5		comment following first formal argument (nil if selector has only one argument)

        ----------------------  (ends here for, e.g., #copyFrom:)

		6		second keyword
		7		comment following second keyword
		8		second formal argument
		9		comment following second formal argument (nil if selector has only two arguments)

         ----------------------  (ends here for, e.g., #copyFrom:to:)

	Any nil element signifies an absent comment.
	NOTE: The comment following the final formal argument is *not* successfully retrieved by this method in its current form, though it can be obtained, if needed, by other means (e.g. calling #firstPrecodeCommentFor:).  Thus, the *final* element in the structure returned by this method is always going to be nil."

	^ Scanner new scanMessageParts: (self methodHeaderFor: aSelector)

"
	Behavior class formalHeaderPartsFor: #formalHeaderPartsFor:
"


	
]

{ #category : #'accessing method dictionary' }
Behavior >> formalParametersAt: aSelector [
	"Return the names of the arguments used in this method."

	| source |
	source := self sourceCodeAt: aSelector ifAbsent: [^ #()].	"for now"
	^self newParser parseParameterNames: source
]

{ #category : #accessing }
Behavior >> format [
	"Answer an Integer that encodes the kinds and numbers of variables of 
	 instances of the receiver.  The format is (currently) composed of two fields,
	 a 16-bit instSize, in the least significant bits, specifying the number of named
	 inst vars, if any, and a 5-bit format field, describing the kind of class.  c.f. instSpec.
		(msb)<5 bit format><16 bit #fixed fields>(lsb)"

	^format
]

{ #category : #printing }
Behavior >> formatterClass [
	 ^self compilerClass
]

{ #category : #'testing method dictionary' }
Behavior >> fullyImplementsVocabulary: aVocabulary [
	"Answer whether instances of the receiver respond to all the messages in aVocabulary"

	(aVocabulary encompassesAPriori: self) ifTrue: [^ true].
	aVocabulary allSelectorsInVocabulary do:
		[:aSelector | (self canUnderstand: aSelector) ifFalse: [^ false]].
	^ true
]

{ #category : #private }
Behavior >> handleFailingBasicNew [
	"handleFailingBasicNew gets sent after basicNew has failed and allowed
	 a scavenging garbage collection to occur.  The scavenging collection
	 will have happened as the VM is activating the (failing) basicNew.  If
	 handleFailingBasicNew fails then the scavenge failed to reclaim sufficient
	 space and a global garbage collection is required.  Retry after garbage
	 collecting and growing memory if necessary.

	 Primitive. Answer an instance of this class with the number of indexable
	 variables specified by the argument, sizeRequested.  Fail if this class is not
	 indexable or if the argument is not a positive Integer, or if there is not
	 enough memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 70>
	Smalltalk garbageCollect < 1048576 ifTrue:
		[Smalltalk growMemoryByAtLeast: 1048576].
	^self handleFailingFailingBasicNew "retry after global garbage collect"
]

{ #category : #private }
Behavior >> handleFailingBasicNew: sizeRequested [
	"handleFailingBasicNew: gets sent after basicNew: has failed and allowed
	 a scavenging garbage collection to occur.  The scavenging collection
	 will have happened as the VM is activating the (failing) basicNew:.  If
	 handleFailingBasicNew: fails then the scavenge failed to reclaim sufficient
	 space and a global garbage collection is required.  Retry after garbage
	 collecting and growing memory if necessary.

	 Primitive. Answer an instance of this class with the number of indexable
	 variables specified by the argument, sizeRequested.  Fail if this class is not
	 indexable or if the argument is not a positive Integer, or if there is not
	 enough memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 71>
	| bytesRequested |
	bytesRequested := self byteSizeOfInstanceOfSize: sizeRequested.
	Smalltalk garbageCollect < bytesRequested ifTrue:
		[Smalltalk growMemoryByAtLeast: bytesRequested].
	"retry after global garbage collect and possible grow"
	^self handleFailingFailingBasicNew: sizeRequested
]

{ #category : #private }
Behavior >> handleFailingFailingBasicNew [
	"This basicNew gets sent after handleFailingBasicNew: has done a full
	 garbage collection and possibly grown memory.  If this basicNew fails
	 then the system really is low on space, so raise the OutOfMemory signal.

	 Primitive. Answer an instance of this class with the number of indexable
	 variables specified by the argument, sizeRequested.  Fail if this class is not
	 indexable or if the argument is not a positive Integer, or if there is not
	 enough memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 70>
	"space must be low"
	OutOfMemory signal.
	^self basicNew  "retry if user proceeds"
]

{ #category : #private }
Behavior >> handleFailingFailingBasicNew: sizeRequested [
	"This basicNew: gets sent after handleFailingBasicNew: has done a full
	 garbage collection and possibly grown memory.  If this basicNew: fails
	 then the system really is low on space, so raise the OutOfMemory signal.

	 Primitive. Answer an instance of this class with the number of indexable
	 variables specified by the argument, sizeRequested.  Fail if this class is not
	 indexable or if the argument is not a positive Integer, or if there is not
	 enough memory available. Essential. See Object documentation whatIsAPrimitive."

	<primitive: 71>
	"space must be low."
	OutOfMemory signal.
	^self basicNew: sizeRequested  "retry if user proceeds"
]

{ #category : #'testing method dictionary' }
Behavior >> hasMethods [
	"Answer whether the receiver has any methods in its method dictionary."

	^ self methodDict size > 0
]

{ #category : #'Backstop-Traits' }
Behavior >> hasTraitComposition [
	"Backstop. When traits are unloaded we never have a trait composition"
	^false
]

{ #category : #comparing }
Behavior >> hash [
	^ self name hash
]

{ #category : #comparing }
Behavior >> identityHash [
	"Answer a SmallInteger whose value is related to the receiver's identity.
	 Behavior implements identityHash to allow the VM to use an object representation which
	 does not include a direct reference to an object's class in an object.  If the VM is using
	 this implementation then classes are held in a class table and instances contain the index
	 of their class in the table.  A class's class table index is its identityHash so that an instance
	 can be created without searching the table for a class's index.  The VM uses this primitive
	 to enter the class into the class table, assigning its identityHash with an as yet unused
	 class table index. If this primitive fails it means that the class table is full.  In Spur as of
	 2014 there are 22 bits of classTable index and 22 bits of identityHash per object.

	 Primitive. Essential. Do not override. See Object documentation whatIsAPrimitive."

	<primitive: 175>
	self primitiveFailed
]

{ #category : #'testing class hierarchy' }
Behavior >> includesBehavior: aClass [
	^self == aClass or:[self inheritsFrom: aClass]
]

{ #category : #'testing method dictionary' }
Behavior >> includesLocalSelector: aSymbol [
	^self includesSelector: aSymbol
]

{ #category : #'testing method dictionary' }
Behavior >> includesSelector: aSymbol [ 
	"Answer whether the message whose selector is the argument is in the 
	method dictionary of the receiver's class."

	^ self methodDict includesKey: aSymbol
]

{ #category : #'testing class hierarchy' }
Behavior >> inheritsFrom: aClass [ 
	"Answer whether the argument, aClass, is on the receiver's superclass 
	chain."

	| aSuperclass |
	aSuperclass := superclass.
	[aSuperclass == nil]
		whileFalse: 
			[aSuperclass == aClass ifTrue: [^true].
			aSuperclass := aSuperclass superclass].
	^false
]

{ #category : #'initialize-release' }
Behavior >> initialize [
	"moved here from the class side's #new"
	self methodDictionary: self emptyMethodDictionary.
	self superclass: Object.
	self setFormat: Object format
]

{ #category : #'instance creation' }
Behavior >> initializedInstance [
	"Answer an instance of the receiver which in some sense is initialized.  In the case of Morphs, this will yield an instance that can be attached to the Hand after having received the same kind of basic initialization that would be obtained from an instance chosen from the 'new morph' menu.   Return nil if the receiver is reluctant for some reason to return such a thing"

	^ self new
]

{ #category : #testing }
Behavior >> instSize [
	"Answer the number of named instance variables
	(as opposed to indexed variables) of the receiver.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>"
	^format bitAnd: 16rFFFF
]

{ #category : #testing }
Behavior >> instSpec [
	"Answer the instance specification part of the format that defines what kind of object
	 an instance of the receiver is.  The formats are
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (Context BlockClosure AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable	(DoubleWordArray et al)
		10-11	= 32-bit indexable	(WordArray et al)			(includes one odd bit, unused in 32-bit instances)
		12-15	= 16-bit indexable	(DoubleByteArray et al)		(includes two odd bits, one unused in 32-bit instances)
		16-23	= 8-bit indexable	(ByteArray et al)			(includes three odd bits, one unused in 32-bit instances)
		24-31	= compiled code	(CompiledCode et al)		(includes three odd bits, one unused in 32-bit instances)

	 Note that in the VM instances also have a 5 bit format field that relates to their class's format.
	 Formats 11, 13-15, 17-23 & 25-31 are unused in classes but used in instances to define the
	 number of elements missing up to the slot size.  For example, a 2-byte ByteString instance
	 has format 18 in 32 bits, since its size is one 32-bit slot - 2 bytes ((18 bitAnd: 3) = 2), and
	 22 in 64 bits, since its size is one 64-bit slot - 6 bytes ((22 bitAnd: 7) = 6).
	 Formats 24-31 are for compiled code which is a combination of pointers and bytes.  The number of pointers is
	 determined by literal count field of the method header, which is the first field of the object and must be a SmallInteger. 
	 The literal count field occupies the least significant 15 bits of the method header, allowing up to 32,767 pointer fields,
	 not including the header."
	^(format bitShift: -16) bitAnd: 16r1F
]

{ #category : #'accessing instances and variables' }
Behavior >> instVarIndexFor: instVarName ifAbsent: aBlock [
	"Answer the index of the named instance variable."
	
	^self allInstVarNames indexOf: instVarName ifAbsent: aBlock
]

{ #category : #'accessing instances and variables' }
Behavior >> instVarNames [
	"Answer an Array of the instance variable names. Behaviors must make 
	up fake local instance variable names because Behaviors have instance 
	variables for the purpose of compiling methods, but these are not named 
	instance variables."

	| mySize superSize |
	mySize := self instSize.
	superSize := 
		superclass == nil
			ifTrue: [0]
			ifFalse: [superclass instSize].
	mySize = superSize ifTrue: [^#()].	
	^(superSize + 1 to: mySize) collect: [:i | 'inst' , i printString]
]

{ #category : #compiling }
Behavior >> instVarNamesAndOffsetsDo: aBinaryBlock [
	"This is part of the interface between the compiler and a class's instance or field names.
	 The class should enumerate aBinaryBlock with the instance variable name strings and
	 their integer offsets.  The order is important. Names evaluated later will override the
	 same names occurring earlier."

	"Nothing to do here; ClassDescription introduces named instance variables"
	^self
]

{ #category : #'accessing instances and variables' }
Behavior >> instanceCount [
	"Answer the number of instances of the receiver that are currently in 
	use."

	| count |
	count := 0.
	self allInstancesDo: [:x | count := count + 1].
	^count
]

{ #category : #testing }
Behavior >> isBehavior [
	"Return true if the receiver is a behavior"
	^true
]

{ #category : #testing }
Behavior >> isBits [
	"Answer whether the receiver contains just bits (not pointers).
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>
	 where the 5-bit inst spec is
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (Context BlockClosure AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	^self instSpec >= 7
]

{ #category : #testing }
Behavior >> isBytes [
	"Answer whether the receiver's instances have indexed 8-bit integer instance variables.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>
	 where the 5-bit inst spec is
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (Context BlockClosure AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	^self instSpec >= 16
]

{ #category : #testing }
Behavior >> isCompiledMethodClass [
	"Answer whether the receiver has compiled method instances that mix pointers and bytes."
	^self instSpec >= 24
]

{ #category : #testing }
Behavior >> isEphemeronClass [
	"Answer whether the receiver has ephemeral instance variables.  The garbage collector will
	 fire (queue for finalization) any ephemeron whose first instance variable is not referenced
	 other than from the transitive closure of references from ephemerons. Hence referring to
	 an object from the first inst var of an ephemeron will cause the ephemeron to fire when
	 the rest of the system does not refer to the object and that object is ready to be collected.
	 Since references from the remaining inst vars of an ephemeron will not prevent the ephemeron
	 from firing, ephemerons may act as the associations in weak dictionaries such that the value
	 (e.g. properties attached to the key) will not prevent firing when the key is no longer referenced
	 other than from ephemerons.  Ephemerons can therefore be used to implement instance-based
	 pre-mortem finalization."
	^self instSpec = 5
]

{ #category : #testing }
Behavior >> isFixed [
	"Answer whether the receiver does not have a variable (indexable) part."

	^self isVariable not
]

{ #category : #testing }
Behavior >> isImmediateClass [
	"Answer whether the receiver has immediate instances.  Immediate instances
	 store their value in their object pointer, not in an object body.  Hence immediates
	 take no space and are immutable.  The immediates are distinguished by tag bits
	 in the pointer. They include SmallIntegers and Characters.  Hence in the 32-bit
	 system SmallIntegers are 31-bit signed integers and Characters are 30-bit
	 unsigned character codes."
	^self instSpec = 7
]

{ #category : #testing }
Behavior >> isLongs [
	"Answer whether the receiver's instances have indexed 64-bit integer instance variables.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>
	 where the 5-bit inst spec is
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (Context BlockClosure AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	^self instSpec = 9
]

{ #category : #testing }
Behavior >> isMeta [
	^ false
]

{ #category : #testing }
Behavior >> isObsolete [
	"Return true if the receiver is obsolete."
	^self instanceCount = 0
]

{ #category : #testing }
Behavior >> isPointers [
	"Answer whether the receiver contains just pointers (not bits)."

	^self isBits not
]

{ #category : #testing }
Behavior >> isShorts [
	"Answer whether the receiver's instances have indexed 16-bit integer instance variables.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>
	 where the 5-bit inst spec is
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (Context BlockClosure AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	^self instSpec = 12
]

{ #category : #testing }
Behavior >> isVariable [
	"Answer whether the receiver has indexable variables.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>
	 where the 5-bit inst spec is
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (Context BlockClosure AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	| instSpec |
	instSpec := self instSpec.
	^instSpec >= 2 and: [instSpec <= 4 or: [instSpec >= 9]]
]

{ #category : #testing }
Behavior >> isWeak [
	"Answer whether the receiver has contains weak references."
	^ self instSpec = 4
]

{ #category : #testing }
Behavior >> isWords [
	"Answer whether the receiver's instances have indexed 32-bit integer instance variables.
	 Above Cog Spur the class format is
		<5 bits inst spec><16 bits inst size>
	 where the 5-bit inst spec is
			0	= 0 sized objects (UndefinedObject True False et al)
			1	= non-indexable objects with inst vars (Point et al)
			2	= indexable objects with no inst vars (Array et al)
			3	= indexable objects with inst vars (Context BlockClosure AdditionalMethodState et al)
			4	= weak indexable objects with inst vars (WeakArray et al)
			5	= weak non-indexable objects with inst vars (ephemerons) (Ephemeron)
			6	= unused
			7	= immediates (SmallInteger, Character)
			8	= unused
			9	= 64-bit indexable
		10-11	= 32-bit indexable (Bitmap)
		12-15	= 16-bit indexable
		16-23	= 8-bit indexable
		24-31	= compiled methods (CompiledMethod)"
	^self instSpec = 10
]

{ #category : #'testing class hierarchy' }
Behavior >> kindOfSubclass [
	"Answer a String that is the keyword that describes the receiver's kind of subclass,
	 either a regular subclass, a variableSubclass, a variableByteSubclass,
	 a variableWordSubclass, a weakSubclass, an ephemeronSubclass or an immediateSubclass.
	 c.f. typeOfClass & instSpec"
	^(#(' subclass: '
		' subclass: '
		' variableSubclass: '
		' variableSubclass: '
		' weakSubclass: '
		' ephemeronSubclass: '
		nil
		' immediateSubclass: '
		nil
		' variableDoubleWordSubclass: '
		' variableWordSubclass: '		nil
		' variableDoubleByteSubclass: '	nil nil nil
		' variableByteSubclass: '		nil nil nil nil nil nil nil
		' variableByteSubclass: '		nil nil nil nil nil nil nil )
			at: self instSpec + 1) ifNil:
				[self error: 'invalid class type']
]

{ #category : #printing }
Behavior >> literalScannedAs: scannedLiteral environment: anEnvironment notifying: requestor [
	"Postprocesses a literal scanned by Scanner scanToken (esp. xLitQuote).
	If scannedLiteral is not an association, answer it.
	Else, if it is of the form:
		nil->#NameOfMetaclass
	answer nil->theMetaclass, if any has that name, else report an error.
	Else, if it is of the form:
		#NameOfGlobalVariable->anythiEng
	answer the global, class, or pool association with that nameE, if any, else
	add it to Undeclared a answer the new Association."

	| key value |
	(scannedLiteral isVariableBinding)
		ifFalse: [^ scannedLiteral].
	key := scannedLiteral key.
	value := scannedLiteral value.
	key ifNil: "###<metaclass soleInstance name>"
		[(self bindingOf: value environment: anEnvironment) ifNotNil:
			[:assoc|
			(assoc value isKindOf: Behavior) ifTrue: 
				[^ nil->assoc value class]].
			 requestor notify: 'No such metaclass'.
			 ^false].
	(key isSymbol) ifTrue: "##<global var name>"
		[(self bindingOf: key environment: anEnvironment) ifNotNil:
			[:assoc | ^assoc].
		^ anEnvironment undeclared: key].
	requestor notify: '## must be followed by a non-local variable name'.
	^false

"	Form literalScannedAs: 14 notifying: nil 14
	Form literalScannedAs: #OneBitForm notiEfying: nil  OneBitForm
	Form literalScannedAs: ##OneBitForm notifying: nil  OneBitForm->a Form
	Form literalScannedAs: ##Form notifying: nil   Form->Form
	Form literalScannedAs: ###Form notifying: nil   nilE->Form class
"
]

{ #category : #'adding\/removing methods' }
Behavior >> localSelectors [
	"Return a set of selectors defined locally."
	^ self selectors

]

{ #category : #printing }
Behavior >> longPrintOn: aStream [
	"Append to the argument, aStream, the names and values of all of the receiver's instance variables.  But, not useful for a class with a method dictionary."

	aStream nextPutAll: '<<too complex to show>>'; cr.
]

{ #category : #'accessing method dictionary' }
Behavior >> lookupSelector: selector [
	"Look up the given selector in my methodDictionary.
	Return the corresponding method if found.
	Otherwise chase the superclass chain and try again.
	Return nil if no method is found."
	| lookupClass |
	lookupClass := self.
	[lookupClass == nil]
		whileFalse: 
			[(lookupClass includesSelector: selector)
				ifTrue: [^ lookupClass compiledMethodAt: selector].
			lookupClass := lookupClass superclass].
	^ nil
]

{ #category : #accessing }
Behavior >> methodDict [
	methodDict == nil ifTrue: [self recoverFromMDFaultWithTrace].
	^ methodDict
]

{ #category : #'accessing method dictionary' }
Behavior >> methodDict: aDictionary [
	methodDict := aDictionary
]

{ #category : #'accessing method dictionary' }
Behavior >> methodDictionary [
	"Convenience"
	^self methodDict
]

{ #category : #'accessing method dictionary' }
Behavior >> methodDictionary: aDictionary [
	self methodDict: aDictionary
]

{ #category : #'accessing method dictionary' }
Behavior >> methodHeaderFor: selector [ 
	"Answer the string corresponding to the method header for the given selector"

	| sourceString parser |
	sourceString := self ultimateSourceCodeAt: selector ifAbsent: [self standardMethodHeaderFor: selector].
	(parser := self newParser) parseSelector: sourceString.
	^ sourceString asString copyFrom: 1 to: (parser endOfLastToken min: sourceString size)

	"Behavior methodHeaderFor: #methodHeaderFor: "

]

{ #category : #'accessing method dictionary' }
Behavior >> methodsDo: aBlock [
	"Evaluate aBlock for all the compiled methods in my method dictionary."

	^ self methodDict valuesDo: aBlock
]

{ #category : #'read-only objects' }
Behavior >> modificationForbiddenAdopting: anObject [
	^(BinaryModificationForbidden new
		mirror: self
		object: anObject
		index: nil
		newValue: nil
		retrySelector: #adoptInstance:) signal
]

{ #category : #accessing }
Behavior >> name [
	"Answer a String that is the name of the receiver."
	^'a subclass of ', superclass name
]

{ #category : #'instance creation' }
Behavior >> new [
	"Answer a new initialized instance of the receiver (which is a class) with no indexable variables. Fail if the class is indexable."

	^ self basicNew initialize

]

{ #category : #'instance creation' }
Behavior >> new: sizeRequested [ 
	"Answer an initialized instance of this class with the number of indexable
	variables specified by the argument, sizeRequested."

	^ (self basicNew: sizeRequested) initialize  
]

{ #category : #compiling }
Behavior >> newCompiler [
	"Answer a Compiler suitable for compiling this Behavior"
	^self compilerClass new parser: self newParser
]

{ #category : #compiling }
Behavior >> newParser [
	"Answer a Parser suitable for parsing source code in this Behavior"
	^self parserClass new
]

{ #category : #'accessing method dictionary' }
Behavior >> nextQuotePosIn: sourceString startingFrom: commentStart [
	| pos nextQuotePos |
	pos := commentStart + 1.
	[((nextQuotePos := sourceString findString: '"' startingAt: pos) == (sourceString findString: '""' startingAt: pos)) and: [nextQuotePos ~= 0]]
		whileTrue:
			[pos := nextQuotePos + 2].
	^nextQuotePos
]

{ #category : #'initialize-release' }
Behavior >> nonObsoleteClass [
	"Attempt to find and return the current version of this obsolete class"

	| obsName |
	obsName := self name.
	[obsName beginsWith: 'AnObsolete']
		whileTrue: [obsName := obsName copyFrom: 'AnObsolete' size + 1 to: obsName size].
	^ self environment at: obsName asSymbol
]

{ #category : #'initialize-release' }
Behavior >> obsolete [
	"Invalidate and recycle local methods,
	e.g., zap the method dictionary if can be done safely."
	self canZapMethodDictionary
		ifTrue: [self methodDict: self emptyMethodDictionary].
]

{ #category : #'obsolete subclasses' }
Behavior >> obsoleteSubclasses [
	"Return all the weakly remembered obsolete subclasses of the receiver"
	| obs |
	obs := ObsoleteSubclasses at: self ifAbsent: [^ #()].
	^ obs copyWithout: nil
]

{ #category : #compiling }
Behavior >> parserClass [
	"Answer a parser class to use for parsing method headers."

	^self compilerClass parserClass
]

{ #category : #copying }
Behavior >> postCopy [
	super postCopy.
	self methodDict: self methodDict copy
]

{ #category : #'accessing method dictionary' }
Behavior >> precodeCommentOrInheritedCommentFor: selector [ 
	"Answer a string representing the first comment in the method associated 
	with selector, considering however only comments that occur before the 
	beginning of the actual code. If the version recorded in the receiver is 
	uncommented, look up the inheritance chain. Return nil if none found."
	| aSuper aComment |
	^ (aComment := self firstPrecodeCommentFor: selector) isEmptyOrNil
		ifTrue: [(self == Behavior
					or: [superclass == nil
							or: [(aSuper := superclass whichClassIncludesSelector: selector) == nil]])
				ifFalse: [aSuper precodeCommentOrInheritedCommentFor: selector]
			"ActorState precodeCommentOrInheritedCommentFor: #printOn:"]
		ifFalse: [aComment]
]

{ #category : #printing }
Behavior >> prettyPrinterClass [
	^self compilerClass
]

{ #category : #printing }
Behavior >> printHierarchy [
	"Answer a description containing the names and instance variable names 
	of all of the subclasses and superclasses of the receiver."

	| aStream index |
	index := 0.
	aStream := WriteStream on: (String new: 16).
	self allSuperclasses reverseDo: 
		[:aClass | 
		aStream crtab: index.
		index := index + 1.
		aStream nextPutAll: aClass name.
		aStream space.
		aStream print: aClass instVarNames].
	aStream cr.
	self printSubclassesOn: aStream level: index.
	^aStream contents
]

{ #category : #printing }
Behavior >> printOn: aStream [ 
	"Refer to the comment in Object|printOn:." 

	aStream nextPutAll: 'a descendent of '.
	superclass printOn: aStream
]

{ #category : #printing }
Behavior >> printWithClosureAnalysisOn: aStream [ 
	"Refer to the comment in Object|printOn:." 

	aStream nextPutAll: 'a descendent of '.
	superclass printWithClosureAnalysisOn: aStream
]

{ #category : #compiling }
Behavior >> recompile: selector [
	"Compile the method associated with selector in the receiver's method dictionary."
	^self recompile: selector from: self
]

{ #category : #compiling }
Behavior >> recompile: selector from: oldClass [
	"Compile the method associated with selector in the receiver's method dictionary."
	"ar 7/10/1999: Use oldClass compiledMethodAt: not self compiledMethodAt:"
	| method trailer methodNode |
	method := oldClass compiledMethodAt: selector.
	trailer := method trailer.
	methodNode := self newCompiler
				compile: (oldClass sourceCodeAt: selector)
				in: self
				notifying: nil
				ifFail: [^ self].   "Assume OK after proceed from SyntaxError"
	selector == methodNode selector ifFalse: [self error: 'selector changed!'].
	self basicAddSelector: selector withMethod: (methodNode generate: trailer).

]

{ #category : #compiling }
Behavior >> recompileChanges [
	"Compile all the methods that are in the changes file.
	This validates sourceCode and variable references and forces
	methods to use the current bytecode set"

	self selectorsAndMethodsDo:
		[:sel :m | m fileIndex > 1 ifTrue:
			[self recompile: sel from: self]]
]

{ #category : #compiling }
Behavior >> recompileNonResidentMethod: method atSelector: selector from: oldClass [
	"Recompile the method supplied in the context of this class."

	| trailer methodNode |
	trailer := method trailer.
	methodNode := self newCompiler
			compile: (method getSourceFor: selector in: oldClass)
			in: self
			notifying: nil
			ifFail: ["We're in deep doo-doo if this fails (syntax error).
				Presumably the user will correct something and proceed,
				thus installing the result in this methodDict.  We must
				retrieve that new method, and restore the original (or remove)
				and then return the method we retrieved."
				^ self error: 'see comment'].
	selector == methodNode selector ifFalse: [self error: 'selector changed!'].
	^ methodNode generate: trailer

]

{ #category : #'obsolete subclasses' }
Behavior >> removeAllObsoleteSubclasses [
	"Remove all the obsolete subclasses of the receiver"
	ObsoleteSubclasses removeKey: self ifAbsent: [].

]

{ #category : #'obsolete subclasses' }
Behavior >> removeObsoleteSubclass: aClass [
	"Remove aClass from the weakly remembered obsolete subclasses"
	| obs |
	obs := ObsoleteSubclasses at: self ifAbsent:[^ self].
	(obs includes: aClass) ifFalse:[^self].
	obs := obs copyWithout: aClass.
	obs := obs copyWithout: nil.
	ObsoleteSubclasses at: self put: obs
]

{ #category : #'adding\/removing methods' }
Behavior >> removeSelector: aSelector [ 
	"Assuming that the argument, selector (a Symbol), is a message selector 
	in my method dictionary, remove it and its method."
	^self basicRemoveSelector: aSelector

]

{ #category : #'adding\/removing methods' }
Behavior >> removeSelectorSilently: selector [ 
	"Remove selector without sending system change notifications"

	^ SystemChangeNotifier uniqueInstance doSilently: [self removeSelector: selector].
]

{ #category : #'accessing method dictionary' }
Behavior >> rootStubInImageSegment: imageSegment [ 

	^ ImageSegmentRootStub new
		xxSuperclass: superclass
		format: format
		segment: imageSegment
]

{ #category : #enumerating }
Behavior >> selectSubclasses: aBlock [ 
	"Evaluate the argument, aBlock, with each of the receiver's (next level) 
	subclasses as its argument. Collect into a Set only those subclasses for 
	which aBlock evaluates to true. In addition, evaluate aBlock for the 
	subclasses of each of these successful subclasses and collect into the set 
	those for which aBlock evaluates true. Answer the resulting set."

	| aSet |
	aSet := Set new.
	self allSubclasses do: 
		[:aSubclass | 
		(aBlock value: aSubclass) ifTrue: [aSet add: aSubclass]].
	^aSet
]

{ #category : #enumerating }
Behavior >> selectSuperclasses: aBlock [ 
	"Evaluate the argument, aBlock, with the receiver's superclasses as the 
	argument. Collect into an OrderedCollection only those superclasses for 
	which aBlock evaluates to true. In addition, evaluate aBlock for the 
	superclasses of each of these successful superclasses and collect into the 
	OrderedCollection ones for which aBlock evaluates to true. Answer the 
	resulting OrderedCollection."

	| aSet |
	aSet := Set new.
	self allSuperclasses do: 
		[:aSuperclass | 
		(aBlock value: aSuperclass) ifTrue: [aSet add: aSuperclass]].
	^aSet
]

{ #category : #'accessing method dictionary' }
Behavior >> selectors [
	"Answer a collection of all the message selectors specified in the receiver's 
	method dictionary."

	^ self methodDict keys
]

{ #category : #'accessing method dictionary' }
Behavior >> selectorsAndMethodsDo: selectorAndMethodBlock [
	"Evaluate the two argument selectorAndMethodBlock for all the selector/method pairs in my method dictionary."

	^ self methodDict keysAndValuesDo: selectorAndMethodBlock
]

{ #category : #'accessing method dictionary' }
Behavior >> selectorsDo: selectorBlock [
	"Evaluate selectorBlock for all the message selectors in my method dictionary."

	^ self methodDict keysDo: selectorBlock
]

{ #category : #'accessing method dictionary' }
Behavior >> selectorsWithArgs: numberOfArgs [
	"Return all selectors defined in this class that take this number of arguments"

	^ self selectors select: [:selector | selector numArgs = numberOfArgs]
]

{ #category : #private }
Behavior >> setFormat: aFormatInstanceDescription [
	"only use this method with extreme care since it modifies the format of the class 
     ie a description of the number of instance variables and whether the class is
     compact, variable sized"

	format := aFormatInstanceDescription


]

{ #category : #'accessing instances and variables' }
Behavior >> sharedPools [
	"Answer a Set of the names of the pools (Dictionaries) that the receiver 
	shares.
	9/12/96 tk  sharedPools have an order now"

	^ OrderedCollection new
]

{ #category : #testing }
Behavior >> shouldNotBeRedefined [
	"Answer if the receiver should not be redefined.
	 The assumption is that classes in Smalltalk specialObjects and 
	 instance-specific Behaviors should not be redefined"

	^(Smalltalk specialObjectsArray
		identityIndexOf: self
		ifAbsent: [(self isKindOf: self) ifTrue: [1] ifFalse: [0]]) ~= 0
]

{ #category : #'system startup' }
Behavior >> shutDown [
	"This message is sent on system shutdown to registered classes"

]

{ #category : #'system startup' }
Behavior >> shutDown: quitting [
	"This message is sent on system shutdown to registered classes"
	^self shutDown.
]

{ #category : #'accessing instances and variables' }
Behavior >> someInstance [
	"Primitive. Answer the first instance in the enumeration of all instances 
	of the receiver. Fails if there are none. Essential. See Object 
	documentation whatIsAPrimitive."

	<primitive: 77>
	^nil
]

{ #category : #'accessing method dictionary' }
Behavior >> sourceCodeAt: selector [

	^ (self methodDict at: selector) getSourceFor: selector in: self
]

{ #category : #'accessing method dictionary' }
Behavior >> sourceCodeAt: selector ifAbsent: aBlock [

	^ (self methodDict at: selector ifAbsent: [^ aBlock value]) getSourceFor: selector in: self
]

{ #category : #compiling }
Behavior >> sourceCodeTemplate [
	"Answer an expression to be edited and evaluated in order to define 
	methods in this class or trait."

	^'message selector and argument names
	"comment stating purpose of message"

	| temporary variable names |
	statements'
]

{ #category : #testing }
Behavior >> sourceMatchesBytecodeAt: selector [
	"Answers true if the source code at the selector compiles to the bytecode at the selector, and false otherwise. Implemented to detect an error where Monticello did not recompile sources when the class shape changed"
	"This code was copied from #recompile:from:, with few changes. Several methods would benefit from a method which turned a selector and class into a CompiledMethod, without  installing it into the methodDictionary"

	| method trailer methodNode |
	method := self compiledMethodAt: selector.
	trailer := method trailer.
	methodNode := self newCompiler
				compile: (self sourceCodeAt: selector)
				in: self
				notifying: nil
				ifFail: [^ false].   "Assume OK after proceed from SyntaxError"
	selector == methodNode selector ifFalse: [self error: 'selector changed!'].
	^ (methodNode generate: trailer) = method
]

{ #category : #'accessing method dictionary' }
Behavior >> sourceMethodAt: selector [ 
	"Answer the paragraph corresponding to the source code for the 
	argument."

	^(self sourceCodeAt: selector) asText makeSelectorBoldIn: self
]

{ #category : #'accessing method dictionary' }
Behavior >> sourceMethodAt: selector ifAbsent: aBlock [
	"Answer the paragraph corresponding to the source code for the 
	argument."

	^ (self sourceCodeAt: selector ifAbsent: [^ aBlock value]) asText makeSelectorBoldIn: self
]

{ #category : #private }
Behavior >> spaceUsed [
	"Answer a rough estimate of number of bytes used by this class and its metaclass. Does not include space used by class variables."

	| space |
	space := 0.
	self methodsDo: [:method |
		space := space + 16.  "dict and org'n space"
		space := space + (method size + 6 "hdr + avg pad").
		method literalsDo: [:lit |
			(lit isMemberOf: Array) ifTrue: [space := space + ((lit size + 1) * 4)].
			(lit isMemberOf: Float) ifTrue: [space := space + 12].
			(lit isMemberOf: ByteString) ifTrue: [space := space + (lit size + 6)].
			(lit isMemberOf: LargeNegativeInteger) ifTrue: [space := space + ((lit size + 1) * 4)].
			(lit isMemberOf: LargePositiveInteger) ifTrue: [space := space + ((lit size + 1) * 4)]]].
		^ space
]

{ #category : #'accessing method dictionary' }
Behavior >> standardMethodHeaderFor: aSelector [
	| args |
	args := (1 to: aSelector numArgs)	collect:[:i| 'arg', i printString].
	args size = 0 ifTrue:[^aSelector asString].
	args size = 1 ifTrue:[^aSelector,' arg1'].
	^String streamContents:[:s|
		(aSelector findTokens:':') with: args do:[:tok :arg|
			s nextPutAll: tok; nextPutAll:': '; nextPutAll: arg; nextPutAll:' '.
		].
	].

]

{ #category : #'system startup' }
Behavior >> startUp [
	"This message is sent to registered classes when the system is coming up."

]

{ #category : #'system startup' }
Behavior >> startUp: resuming [
	"This message is sent to registered classes when the system is coming up.
	 resuming will be true if a snapshot is being resumed.  resuming will be false
	 if the system is merely reinitializing after writing a snapshot."
	^self startUp
]

{ #category : #'system startup' }
Behavior >> startUpFrom: endiannessHasToBeFixed [
	"Override this when a per-instance startUp message needs to be sent.  For example, to correct the order of 16-bit non-pointer data when it came from a different endian machine."

	^ nil
]

{ #category : #printing }
Behavior >> storeLiteral: aCodeLiteral on: aStream [
	"Store aCodeLiteral on aStream, changing an Association to ##GlobalName
	 or ###MetaclassSoleInstanceName format if appropriate"
	| key value |
	(aCodeLiteral isVariableBinding)
		ifFalse:
			[aCodeLiteral storeOn: aStream.
			 ^self].
	key := aCodeLiteral key.
	(key isNil and: [(value := aCodeLiteral value) isMemberOf: Metaclass])
		ifTrue:
			[aStream nextPutAll: '###'; nextPutAll: value soleInstance name.
			 ^self].
	(key isSymbol and: [(self bindingOf: key) notNil])
		ifTrue:
			[aStream nextPutAll: '##'; nextPutAll: key.
			 ^self].
	aCodeLiteral storeOn: aStream
]

{ #category : #accessing }
Behavior >> subclassDefinerClass [
	"Answer an evaluator class appropriate for evaluating definitions of new 
	subclasses of this class."

	^Compiler
]

{ #category : #'accessing instances and variables' }
Behavior >> subclassInstVarNames [
	"Answer a Set of the names of the receiver's subclasses' instance 
	variables."
	| vars |
	vars := Set new.
	self allSubclasses do: [:aSubclass | vars addAll: aSubclass instVarNames].
	^vars
]

{ #category : #'accessing class hierarchy' }
Behavior >> subclasses [
	"slow implementation since Behavior does not keep trace of subclasses"
	
	^ self class allInstances  select: [:each | each superclass = self ]
]

{ #category : #'accessing class hierarchy' }
Behavior >> superclass [
	"Answer the receiver's superclass, a Class."

	^superclass
]

{ #category : #'accessing class hierarchy' }
Behavior >> superclass: aClass [ 
	"Change the receiver's superclass to be aClass."
	"Note: Do not use 'aClass isKindOf: Behavior' here
		in case we recompile from Behavior itself."
	(aClass == nil or: [aClass isBehavior])
		ifTrue: [superclass := aClass.
				Object flushCache]
		ifFalse: [self error: 'superclass must be a class-describing object']
]

{ #category : #'initialize-release' }
Behavior >> superclass: aClass methodDictionary: mDict format: fmt [
	"Basic initialization of the receiver.
	Must only be sent to a new instance; else we would need Object flushCache."
	superclass := aClass.
	format := fmt.
	methodDict := mDict.
]

{ #category : #'accessing method dictionary' }
Behavior >> supermostPrecodeCommentFor: selector [ 
	"Answer a string representing the precode comment in the most distant 
	superclass's implementation of the selector. Return nil if none found."
	| aSuper superComment |
	(self == Behavior
			or: [superclass == nil
					or: [(aSuper := superclass whichClassIncludesSelector: selector) == nil]])
		ifFalse: ["There is a super implementor"
			superComment := aSuper supermostPrecodeCommentFor: selector].
	^ superComment
		ifNil: [self firstPrecodeCommentFor: selector
			"ActorState supermostPrecodeCommentFor: #printOn:"]
]

{ #category : #'Backstop-Traits' }
Behavior >> traitComposition [
	"Backstop. When traits are unloaded we never have a trait composition"
	^#()
]

{ #category : #'Backstop-Traits' }
Behavior >> traitCompositionString [
	"Backstop. Monticello needs a traitCompositionString even with traits unloaded"
	^'{}'
]

{ #category : #accessing }
Behavior >> typeOfClass [
	"Answer a symbol uniquely describing the type of the receiver. c.f. kindOfSubclass, instSpec"
	^(#(normal
		normal
		variable
		variable
		weak
		ephemeron
		nil
		immediate
		nil
		longs
		words				nil
		shorts				nil nil nil
		bytes				nil nil nil nil nil nil nil
		compiledMethod	nil nil nil nil nil nil nil)
			at: self instSpec + 1) ifNil:
				[self error: 'invalid class type']
]

{ #category : #'accessing method dictionary' }
Behavior >> ultimateSourceCodeAt: selector ifAbsent: aBlock [
	"Return the source code at selector, deferring to superclass if necessary"
	^ self sourceCodeAt: selector ifAbsent:
		[superclass
			ifNil:
				[aBlock value]
			 ifNotNil:
				[superclass ultimateSourceCodeAt: selector ifAbsent: aBlock]]
]

{ #category : #'user interface' }
Behavior >> unreferencedInstanceVariables [
	"Return a list of the instance variables defined in the receiver which are not referenced in the receiver or any of its subclasses."

	^ self instVarNames select:
		[:ivn |
		self withAllSubclasses allSatisfy:
			[:class |  (class whichSelectorsAccess: ivn) isEmpty]]
]

{ #category : #compiling }
Behavior >> variablesAndOffsetsDo: aBinaryBlock [
	"This is the interface between the compiler and a class's instance or field names.  The
	 class should enumerate aBinaryBlock with the field definitions (with nil offsets) followed
	 by the instance variable name strings and their integer offsets (1-relative).  The order is
	 important; names evaluated later will override the same names occurring earlier."

	"Only need to do instance variables here.  CProtoObject introduces field definitions."
	self instVarNamesAndOffsetsDo: aBinaryBlock
]

{ #category : #copying }
Behavior >> veryDeepCopyWith: deepCopier [
	"Return self.  Must be created, not copied.  Do not record me."
]

{ #category : #queries }
Behavior >> whichClassDefinesClassVar: aString [ 
	Symbol hasInterned: aString ifTrue: [ :aSymbol |
		^self whichSuperclassSatisfies: 
			[:aClass | 
			aClass classVarNames anySatisfy: [:each | each = aSymbol]]].
	^nil
]

{ #category : #queries }
Behavior >> whichClassDefinesInstVar: aString [ 
	^self 
		whichSuperclassSatisfies: [:aClass | aClass instVarNames includes: aString]
]

{ #category : #'testing method dictionary' }
Behavior >> whichClassIncludesSelector: aSymbol [ 
	"Answer the class on the receiver's superclass chain where the 
	argument, aSymbol (a message selector), will be found. Answer nil if none found."
	"Rectangle whichClassIncludesSelector: #inspect."
	(self includesSelector: aSymbol)
		ifTrue: [^ self].
	superclass == nil
		ifTrue: [^ nil].
	^ superclass whichClassIncludesSelector: aSymbol
]

{ #category : #'testing method dictionary' }
Behavior >> whichMethodsStoreInto: instVarName [ 
	"Answer a collection of CompiledMethod whose methods access the argument, instVarName, as a named instance variable."
	
	| instVarIndex |
	instVarIndex := self instVarIndexFor: instVarName ifAbsent: [ ^Array new ].
	^self methodDict values select: [:eachMethod | eachMethod writesField: instVarIndex ]
	
	"Point whichMethodsStoreInto: 'x'."
]

{ #category : #'testing method dictionary' }
Behavior >> whichSelectorsAccess: instVarName [ 
	"Answer a collection of selectors whose methods access the argument, instVarName, as a named instance variable."
	"Point whichSelectorsAccess: 'x'."
	
	| instVarIndex |
	instVarIndex := self instVarIndexFor: instVarName ifAbsent: [ ^Array new ].
	^Array streamContents: [ :stream |
		self selectorsAndMethodsDo: [ :selector :method |
			((method readsField: instVarIndex) or: [
				method writesField: instVarIndex ]) ifTrue: [
					stream nextPut: selector ] ] ]

]

{ #category : #queries }
Behavior >> whichSelectorsRead: instVarName [ 
	"Answer a Set of selectors whose methods access the argument, 
	instVarName, as a named instance variable."
	^self whichSelectorsAccess: instVarName
]

{ #category : #'testing method dictionary' }
Behavior >> whichSelectorsReferTo: literal [ 
	"Answer a Set of selectors whose methods access the argument as a literal. Note that we cannot use #systemNavigation because this method should not depend on the 'System' package."

	| who canBeSpecial |
	canBeSpecial := BytecodeEncoder canBeSpecialLiteral: literal.
	who := IdentitySet new.
	self selectorsAndMethodsDo: [:selector :method |
		(method hasLiteral: literal scanForSpecial: canBeSpecial)
			ifTrue: [who add: selector]].
	^ who

	"Rectangle whichSelectorsReferTo: #+."
]

{ #category : #'testing method dictionary' }
Behavior >> whichSelectorsStoreInto: instVarName [ 
	"Answer a collection of selectors whose methods access the argument, instVarName, as a named instance variable."
	
	| instVarIndex |
	instVarIndex := self instVarIndexFor: instVarName ifAbsent: [ ^Array new ].
	^ self methodDict keys select: 
		[:sel | (self methodDict at: sel) writesField: instVarIndex]

	"Point whichSelectorsStoreInto: 'x'."
]

{ #category : #queries }
Behavior >> whichSuperclassSatisfies: aBlock [ 
	(aBlock value: self) ifTrue: [^self].
	^superclass isNil 
		ifTrue: [nil]
		ifFalse: [superclass whichSuperclassSatisfies: aBlock]
]

{ #category : #'user interface' }
Behavior >> withAllSubAndSuperclassesDo: aBlock [

	self withAllSubclassesDo: aBlock.
	self allSuperclassesDo: aBlock.

]

{ #category : #'accessing class hierarchy' }
Behavior >> withAllSubclasses [
	"Answer a Collection of the receiver, the receiver's descendent's, and the  
	receiver's descendent's subclasses."

	^ self allSubclasses addFirst: self;
		 yourself
]

{ #category : #enumerating }
Behavior >> withAllSubclassesDo: aBlock [ 
	"Evaluate the argument, aBlock, for the receiver and each of its 
	subclasses."

	aBlock value: self.
	self allSubclassesDo: aBlock
]

{ #category : #enumerating }
Behavior >> withAllSuperAndSubclassesDo: aBlock [
	self allSuperclassesDo: aBlock.
	aBlock value: self.
	self allSubclassesDo: aBlock
]

{ #category : #enumerating }
Behavior >> withAllSuperAndSubclassesDoGently: aBlock [
	self allSuperclassesDo: aBlock.
	aBlock value: self.
	self allSubclassesDoGently: aBlock
]

{ #category : #'accessing class hierarchy' }
Behavior >> withAllSuperclasses [
	"Answer an OrderedCollection of the receiver and the receiver's 
	superclasses. The first element is the receiver, 
	followed by its superclass; the last element is Object."

	| temp |
	temp := self allSuperclasses.
	temp addFirst: self.
	^ temp
]

{ #category : #enumerating }
Behavior >> withAllSuperclassesDo: aBlock [ 
	"Evaluate the argument, aBlock, for each of the receiver's superclasses."
	aBlock value: self.
	superclass == nil
		ifFalse: [superclass withAllSuperclassesDo: aBlock]
]

{ #category : #'accessing method dictionary' }
Behavior >> zapAllMethods [
	"Remove all methods in this class which is assumed to be obsolete"

	methodDict := self emptyMethodDictionary.
	self class isMeta ifTrue: [self class zapAllMethods]
]
