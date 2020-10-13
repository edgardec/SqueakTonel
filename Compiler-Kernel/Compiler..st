"
The compiler accepts Smalltalk source code and compiles it with respect to a given class. The user of the compiler supplies a context so that temporary variables are accessible during compilation. If there is an error, a requestor (usually a kind of StringHolderController) is sent the message notify:at:in: so that the error message can be displayed. If there is no error, then the result of compilation is a MethodNode, which is the root of a parse tree whose nodes are kinds of ParseNodes. The parse tree can be sent messages to (1) generate code for a CompiledMethod (this is done for compiling methods or evaluating expressions); (2) pretty-print the code (for formatting); or (3) produce a map from object code back to source code (used by debugger program-counter selection). See also Parser, Encoder, ParseNode.
"
Class {
	#name : #Compiler,
	#superclass : #Object,
	#instVars : [
		'parser',
		'cue'
	],
	#category : #'Compiler-Kernel'
}

{ #category : #accessing }
Compiler class >> couldEvaluate: anObject [
	"Answer true if anObject can be passed to my various #evaluate: methods."
	^anObject isString or: [ anObject isText or: [ anObject isStream ]]
]

{ #category : #accessing }
Compiler class >> decompilerClass [
	^Decompiler
]

{ #category : #evaluating }
Compiler class >> evaluate: textOrString [ 
	"See Compiler|evaluate:for:notifying:logged:. If a compilation error occurs, 
	a Syntax Error view is created rather than notifying any requestor. 
	Compilation is carried out with respect to nil, i.e., no object, and the 
	invocation is not logged."

	^self evaluate: textOrString for: nil
]

{ #category : #evaluating }
Compiler class >> evaluate: aString environment: anEnvironment [
	^  self new
		evaluateCue: (CompilationCue
			source: aString
			environment: anEnvironment)
		ifFail: [^ nil]
]

{ #category : #'evaluating logged' }
Compiler class >> evaluate: aString environment: anEnvironment logged: aBoolean [
	^ self new
		evaluateCue: (CompilationCue
			source: aString
			environment: anEnvironment)
		ifFail: [^ nil]
		logged: aBoolean
]

{ #category : #evaluating }
Compiler class >> evaluate: textOrString for: anObject [  
	"See Compiler|evaluate:for:notifying:. If a compilation error occurs, 
	a Syntax Error view is created rather than notifying any requestor."

	^self evaluate: textOrString for: anObject notifying: nil
]

{ #category : #'evaluating logged' }
Compiler class >> evaluate: textOrString for: anObject logged: logFlag [ 
	"See Compiler|evaluate:for:notifying:logged:. If a compilation error occurs, 
	a Syntax Error view is created rather than notifying any requestor."

	^self evaluate: textOrString for: anObject notifying: nil logged: logFlag
]

{ #category : #evaluating }
Compiler class >> evaluate: textOrString for: anObject notifying: aController [
	"Compile and execute the argument, textOrString with respect to the class 
	of anObject. If a compilation error occurs, notify aController."

	^ self new
		evaluate: textOrString
		in: nil
		to: anObject
		notifying: aController
		ifFail: [^nil]
]

{ #category : #'evaluating logged' }
Compiler class >> evaluate: textOrString for: anObject notifying: aController logged: logFlag [
	"Compile and execute the argument, textOrString with respect to the class 
	of anObject. If a compilation error occurs, notify aController. If both 
	compilation and execution are successful then, if logFlag is true, log 
	(write) the text onto a system changes file so that it can be replayed if 
	necessary."

	^ self new
				evaluate: textOrString
				in: nil
				to: anObject
				notifying: aController
				ifFail: [^nil]
				logged: logFlag.
]

{ #category : #'evaluating logged' }
Compiler class >> evaluate: textOrString in: anEnvironment notifying: aController logged: logFlag [
	"Compile and execute the argument, textOrString in anEnvironment.
	If a compilation error occurs, notify aController. If both 
	compilation and execution are successful then, if logFlag is true, log 
	(write) the text onto a system changes file so that it can be replayed if 
	necessary."

	^ self new
				evaluate: textOrString
				in: anEnvironment
				notifying: aController
				logged: logFlag.
]

{ #category : #'evaluating logged' }
Compiler class >> evaluate: textOrString logged: logFlag [ 
	"See Compiler|evaluate:for:notifying:logged:. If a compilation error occurs, 
	a Syntax Error view is created rather than notifying any requestor. 
	Compilation is carried out with respect to nil, i.e., no object."

	^self evaluate: textOrString for: nil logged: logFlag
]

{ #category : #evaluating }
Compiler class >> evaluate: textOrString notifying: aController [
	"See Compiler|evaluate:for:notifying:logged:. Compilation is carried out 
	with respect to nil, i.e., no object."

	^self evaluate: textOrString for: nil notifying: aController
]

{ #category : #'evaluating logged' }
Compiler class >> evaluate: textOrString notifying: aController logged: logFlag [ 
	"See Compiler|evaluate:for:notifying:logged:. Compilation is carried out 
	with respect to nil, i.e., no object."

	^self evaluate: textOrString for: nil notifying: aController logged: logFlag
]

{ #category : #evaluating }
Compiler class >> format: textOrStream in: aClass notifying: aRequestor [
	^self new format: textOrStream in: aClass notifying: aRequestor
]

{ #category : #evaluating }
Compiler class >> format: textOrStream in: aClass notifying: aRequestor decorated: aBoolean [
	^self new format: textOrStream in: aClass notifying: aRequestor decorated: aBoolean
]

{ #category : #'class initialization' }
Compiler class >> initialize [
	"For the benefit of MC running a required script in the proper order."
	self recompileAll.
]

{ #category : #accessing }
Compiler class >> new [
	^ super new parser: self newParser
]

{ #category : #accessing }
Compiler class >> parserClass [
	"Answer a parser class to use for parsing methods compiled by instances of the receiver."

	^Parser
]

{ #category : #utilities }
Compiler class >> recompileAll [	"Compiler recompileAll"
	"Recompile all classes and traits in the system.
	 After recompilation invoke the postRecompileAction on any "

	| classesWithRecompileActions |
	classesWithRecompileActions := OrderedCollection new.
	Smalltalk allClassesAndTraits "This is unordered; I find that unsatisfactory and fragile, because
								    if there is a bug it could be difficult to reproduce. eem 10/8/2019"
		do: [:classOrTrait |
			classOrTrait compileAll.
			(classOrTrait class includesSelector: #postRecompileAction) ifTrue:
				[classesWithRecompileActions addLast: classOrTrait]] 
		displayingProgress:[:classOrTrait| 'Recompiling ', classOrTrait].

	classesWithRecompileActions do: [:classOrTrait| classOrTrait postRecompileAction]
]

{ #category : #utilities }
Compiler class >> recompileAllFrom: firstName [ 
	"Recompile all classes, starting with given name."
	| classesWithRecompileActions |
	classesWithRecompileActions := OrderedCollection new.

	Smalltalk allClassesDo: 
		[:class |
		class name >= firstName ifTrue: 
			[Transcript show: class name; cr.
			 class compileAll.
			 (class class includesSelector: #postRecompileAction) ifTrue:
				[classesWithRecompileActions addLast: class]]].

	classesWithRecompileActions do:
		[:classOrTrait| classOrTrait postRecompileAction]

	"Compiler recompileAllFrom: 'AAABodyShop'"
]

{ #category : #private }
Compiler >> classForReceiver: receiver context: contextOrNil [
	"Answer the class to compile in for a receiver and aContext.
	 If aContext is non-nil use its receiver's class (if we use the context's
	 methodClass we may exclude instance variables of the receiver).
	 Access the class of the receiver via the mirror primitive to avoid issues with proxies."

	^thisContext objectClass: (contextOrNil ifNil: [receiver] ifNotNil: [contextOrNil receiver])
]

{ #category : #'public access' }
Compiler >> compile: aCue ifFail: failBlock [ 
	"Answer a MethodNode. If the MethodNode can not be created, notify 
	the requestor in the contxt. If the requestor is nil, evaluate failBlock 
	instead. The MethodNode is the root  of a parse tree. It can be told 
	to generate a CompiledMethod to be installed in the method dictionary 
	of the class specified by the context."
	
	^self
		compileCue: aCue
		noPattern: false
		ifFail: failBlock 
]

{ #category : #'public access' }
Compiler >> compile: textOrStream in: aClass environment: anEnvironment notifying: aRequestor ifFail: failBlock [ 
	"Answer a MethodNode for the argument, textOrStream. If the 
	MethodNode can not be created, notify the argument, aRequestor; if 
	aRequestor is nil, evaluate failBlock instead. The MethodNode is the root 
	of a parse tree. It can be told to generate a CompiledMethod to be 
	installed in the method dictionary of the argument, aClass."

	^self
		compileCue: (CompilationCue
			source: textOrStream
			class: aClass
			environment: anEnvironment
			requestor: aRequestor)
		noPattern: false
		ifFail: failBlock

]

{ #category : #'public access' }
Compiler >> compile: textOrStream in: aClass notifying: aRequestor ifFail: failBlock [ 
	"Answer a MethodNode for the argument, textOrStream. If the 
	MethodNode can not be created, notify the argument, aRequestor; if 
	aRequestor is nil, evaluate failBlock instead. The MethodNode is the root 
	of a parse tree. It can be told to generate a CompiledMethod to be 
	installed in the method dictionary of the argument, aClass."

	^self
		compileCue: (CompilationCue
			source: textOrStream
			class: aClass
			requestor: aRequestor)
		noPattern: false
		ifFail: failBlock

]

{ #category : #private }
Compiler >> compileCue: aCue noPattern: aBoolean ifFail: failBlock [ 
	"Answer a MethodNode corresponding to cue source.
	If the MethodNode can not be created, notify the cue requestor.
	If the cue requestor is nil, evaluate failBlock instead.
	The MethodNode is the root  of a parse tree.
	It can be told to generate a CompiledMethod
	- either to be evaluated in cue context if aBoolean is true, with cue receiver as method receiver,
	- or to be installed in the method dictionary of the target class specified by the cue if aBoolean is false."
	
	self setCue: aCue.
	^self translateNoPattern: aBoolean	ifFail: failBlock
]

{ #category : #'public access' }
Compiler >> compileNoPattern: textOrStream in: aClass context: aContext environment: anEnvironment notifying: aRequestor ifFail: failBlock [
	"Similar to #compile:in:notifying:ifFail:, but the compiled code is
	expected to be a do-it expression, with no message pattern,
	and it will be in an explicit environment."

	^self
		compileCue: (CompilationCue
			source: textOrStream
			context: aContext
			class: aClass
			environment: anEnvironment
			requestor: aRequestor)
		noPattern: true
		ifFail: failBlock

]

{ #category : #'public access' }
Compiler >> compileNoPattern: textOrStream in: aClass context: aContext notifying: aRequestor ifFail: failBlock [
	"Similar to #compile:in:notifying:ifFail:, but the compiled code is
	expected to be a do-it expression, with no message pattern."

	^self
		compileCue: (CompilationCue
			source: textOrStream
			context: aContext
			class: aClass
			requestor: aRequestor)
		noPattern: true
		ifFail: failBlock

]

{ #category : #'public access' }
Compiler >> compileNoPattern: textOrStream in: aClass notifying: aRequestor ifFail: failBlock [
	"Similar to #compile:in:notifying:ifFail:, but the compiled code is
	expected to be a do-it expression, with no message pattern."

	^self
		compileCue: (CompilationCue
			source: textOrStream
			class: aClass
			requestor: aRequestor)
		noPattern: true
		ifFail: failBlock

]

{ #category : #'public access' }
Compiler >> compiledMethodFor: textOrStream in: aContext to: receiver notifying: aRequestor ifFail: failBlock [
	"Compiles the sourceStream into a parse tree, then generates code
	 into a method, and answers it.  If receiver is not nil, then the text can
	 refer to instance variables of that receiver (the Inspector uses this).
	 If aContext is not nil, the text can refer to temporaries in that context
	 (the Debugger uses this). If aRequestor is not nil, then it will receive a 
	 notify:at: message before the attempt to evaluate is aborted."

	| methodNode method |
	methodNode := self
		compileNoPattern: textOrStream
		in: (self classForReceiver: receiver context: aContext)
		context: aContext
		notifying: aRequestor
		ifFail: [^failBlock value].
	method := self interactive
		ifTrue: [ methodNode generateWithTempNames ] 
		ifFalse: [ methodNode generate ].
	^method
]

{ #category : #'public access logging' }
Compiler >> compiledMethodFor: textOrStream in: aContext to: receiver notifying: aRequestor ifFail: failBlock logged: logFlag [
	"Compiles the sourceStream into a parse tree, then generates code
	 into a method, and answers it.  If receiver is not nil, then the text can
	 refer to instance variables of that receiver (the Inspector uses this).
	 If aContext is not nil, the text can refer to temporaries in that context
	 (the Debugger uses this). If aRequestor is not nil, then it will receive a 
	 notify:at: message before the attempt to evaluate is aborted."

	| method |
	method := self
		compiledMethodFor: textOrStream
		in: aContext
		to: receiver
		notifying: aRequestor
		ifFail: [^failBlock value].
	logFlag ifTrue:
		[SystemChangeNotifier uniqueInstance evaluated: cue stringToLog context: aContext].
	^method
]

{ #category : #'public access' }
Compiler >> evaluate: textOrString [ 
	"See evaluate:for:notifying:logged:. If a compilation error occurs, 
	a Syntax Error view is created rather than notifying any requestor. 
	Compilation is carried out with respect to nil, i.e., no object, and the 
	invocation is not logged."

	^self evaluate: textOrString for: nil
]

{ #category : #'public access' }
Compiler >> evaluate: textOrString for: anObject [
	"See evaluate:for:notifying:logged:. If a compilation error occurs, 
	a Syntax Error view is created rather than notifying any requestor."

	^self evaluate: textOrString for: anObject notifying: nil
]

{ #category : #'public access logging' }
Compiler >> evaluate: textOrString for: anObject logged: logFlag [ 
	"See evaluate:for:notifying:logged:. If a compilation error occurs, 
	a Syntax Error view is created rather than notifying any requestor."

	^self evaluate: textOrString for: anObject notifying: nil logged: logFlag
]

{ #category : #'public access' }
Compiler >> evaluate: textOrString for: anObject notifying: aController [
	"Compile and execute the argument, textOrString with respect to the class 
	of anObject. If a compilation error occurs, notify aController."

	^ self
		evaluate: textOrString
		in: nil
		to: anObject
		notifying: aController
		ifFail: [^nil]
]

{ #category : #'public access logging' }
Compiler >> evaluate: textOrString for: anObject notifying: aController logged: logFlag [
	"Compile and execute the argument, textOrString with respect to the class 
	of anObject. If a compilation error occurs, notify aController. If both 
	compilation and execution are successful then, if logFlag is true, log 
	(write) the text onto a system changes file so that it can be replayed if 
	necessary."

	^ self
		evaluate: textOrString
		in: nil
		to: anObject
		notifying: aController
		ifFail: [^nil]
		logged: logFlag.
]

{ #category : #'public access logging' }
Compiler >> evaluate: textOrStream in: aContext environment: anEnvironment notifying: aRequestor ifFail: failBlock logged: logFlag [
	"Compiles the sourceStream into a parse tree, then generates code into
	 a method. If aContext is not nil, the text can refer to temporaries in that
	 context (the Debugger uses this). If aRequestor is not nil, then it will receive
	 a notify:at: message before the attempt to evaluate is aborted. Finally, the 
	 compiled method is invoked from here via withArgs:executeMethod:, hence
	 the system no longer creates Doit method litter on errors."
	^self
		evaluateCue: (CompilationCue
			source: textOrStream
			context: aContext
			receiver: nil
			class: UndefinedObject
			environment: anEnvironment
			requestor: aRequestor)
		ifFail: failBlock
		logged: logFlag
]

{ #category : #'public access logging' }
Compiler >> evaluate: textOrString in: anEnvironment notifying: aController logged: logFlag [ 
	"Compile and execute the argument, textOrString in anEnvironment.
	If a compilation error occurs, notify aController. If both 
	compilation and execution are successful then, if logFlag is true, log 
	(write) the text onto a system changes file so that it can be replayed if 
	necessary."

	^self
		evaluate: textOrString
		in: nil
		environment: anEnvironment
		notifying: aController
		ifFail: [^nil]
		logged: logFlag
]

{ #category : #'public access' }
Compiler >> evaluate: aString in: aContext to: aReceiver [
	"evaluate aString in the given context, and return the result.  2/2/96 sw"
	^self
		evaluate: aString
		in: aContext
		to: aReceiver
		notifying: nil
		ifFail: [^ #failedDoit]
]

{ #category : #'public access logging' }
Compiler >> evaluate: textOrStream in: aContext to: receiver environment: anEnvironment notifying: aRequestor ifFail: failBlock logged: logFlag [
	"Same as #evaluate:in:to:notifying:ifFail:logged: but with an explicit environment"
	^self
		evaluateCue: (CompilationCue
			source: textOrStream
			context: aContext
			receiver: receiver
			class: (self classForReceiver: receiver context: aContext)
			environment: anEnvironment
			requestor: aRequestor)
		ifFail: failBlock
		logged: logFlag
]

{ #category : #'public access' }
Compiler >> evaluate: textOrStream in: aContext to: receiver notifying: aRequestor ifFail: failBlock [
	"Compiles the sourceStream into a parse tree, then generates code into
	 a method. If aContext is not nil, the text can refer to temporaries in that
	 context (the Debugger uses this). If aRequestor is not nil, then it will receive
	 a notify:at: message before the attempt to evaluate is aborted. Finally, the 
	 compiled method is invoked from here via withArgs:executeMethod:, hence
	 the system no longer creates Doit method litter on errors."
	
	| theClass |
	theClass := self classForReceiver: receiver context: aContext.
	^self
		evaluateCue: (CompilationCue
			source: textOrStream
			context: aContext
			receiver: receiver
			class: theClass
			environment: theClass environment
			requestor: aRequestor)
		ifFail: failBlock
]

{ #category : #'public access logging' }
Compiler >> evaluate: textOrStream in: aContext to: receiver notifying: aRequestor ifFail: failBlock logged: logFlag [
	"Compiles the sourceStream into a parse tree, then generates code into
	 a method. If aContext is not nil, the text can refer to temporaries in that
	 context (the Debugger uses this). If aRequestor is not nil, then it will receive
	 a notify:at: message before the attempt to evaluate is aborted. Finally, the 
	 compiled method is invoked from here via withArgs:executeMethod:, hence
	 the system no longer creates Doit method litter on errors."
	| theClass |
	theClass := self classForReceiver: receiver context: aContext.
	^self
		evaluateCue: (CompilationCue
			source: textOrStream
			context: aContext
			receiver: receiver
			class: theClass
			environment: theClass environment
			requestor: aRequestor)
		ifFail: failBlock
		logged: logFlag
]

{ #category : #'public access logging' }
Compiler >> evaluate: textOrString logged: logFlag [ 
	"See evaluate:for:notifying:logged:. If a compilation error occurs, 
	a Syntax Error view is created rather than notifying any requestor. 
	Compilation is carried out with respect to nil, i.e., no object."

	^self evaluate: textOrString for: nil logged: logFlag
]

{ #category : #'public access' }
Compiler >> evaluate: textOrString notifying: aController [
	"See evaluate:for:notifying:. Compilation is carried out 
	with respect to nil, i.e., no object."

	^self evaluate: textOrString for: nil notifying: aController
]

{ #category : #'public access logging' }
Compiler >> evaluate: textOrString notifying: aController logged: logFlag [ 
	"See evaluate:for:notifying:logged:. Compilation is carried out 
	with respect to nil, i.e., no object."

	^self evaluate: textOrString for: nil notifying: aController logged: logFlag
]

{ #category : #private }
Compiler >> evaluateCue: aCue ifFail: failBlock [
	"Compiles the cue source into a parse tree, then generates code into
	a method. Finally, the compiled method is invoked from here via 	withArgs:executeMethod:, hence the system no longer creates Doit method
	litter on errors."

	| methodNode method value |
	methodNode := self compileCue: aCue noPattern: true ifFail: [^failBlock value].

	method := self interactive
				ifTrue: [methodNode generateWithTempNames]
				ifFalse: [methodNode generate].

	value := cue receiver
				withArgs: (cue context ifNil: [#()] ifNotNil: [{cue context}])
				executeMethod: method.
	^ value

]

{ #category : #private }
Compiler >> evaluateCue: aCue ifFail: failBlock logged: logFlag [
	"Compiles the cue source into a parse tree, then generates code into
	a method. Finally, the compiled method is invoked from here via 	withArgs:executeMethod:, hence the system no longer creates Doit method
	litter on errors."

	| value |
	value := self evaluateCue: aCue ifFail: [^failBlock value].
	logFlag ifTrue:
		[SystemChangeNotifier uniqueInstance evaluated: cue stringToLog context: cue context].
	^ value

]

{ #category : #'public access' }
Compiler >> format: textOrStream in: aClass notifying: aRequestor [
	"Compile a parse tree from the argument, textOrStream. Answer a string containing the original code, formatted nicely.  If aBoolean is true, then decorate the resulting text with color and hypertext actions"

	| aNode |
	self from: textOrStream
		class: aClass
		notifying: aRequestor.
	aNode := self formatNoPattern: false ifFail: [^ nil].

	"aSymbol == #colorPrint ifTrue:
		[^aNode asColorizedSmalltalk80Text]." "deprecating #colorPrint in favor of Shout --Ron Spengler"

	^aNode decompileString
]

{ #category : #'public access' }
Compiler >> format: textOrStream in: aClass notifying: aRequestor decorated: aBoolean [
	"Compile a parse tree from the argument, textOrStream. Answer a string containing the original code, formatted nicely.  If aBoolean is true, then decorate the resulting text with color and hypertext actions"
	| aNode |
	self from: textOrStream
		class: aClass
		notifying: aRequestor.
	aNode := self formatNoPattern: false ifFail: [^ nil].
	^ aBoolean
		ifTrue: [aNode decompileText]
		ifFalse: [aNode decompileString]
]

{ #category : #'public access' }
Compiler >> formatNoPattern: textOrStream environment: env [
	"Pretty-print a code snippet. Removes leading 'DoIt' and the '^' in the last statement. To be used in workspace-like tools."
	
	| aNode |
	self setCue: (CompilationCue
		source: textOrStream
		environment: env).
		
	aNode := self formatNoPattern: true ifFail: [^ nil].

	^ (aNode decompileString lines allButFirst "DoIt" collect: [:ea |
		ea allButFirst "tab" in: [:result | (result beginsWith: '^ ') ifTrue: [result allButFirst: 2] ifFalse: [result]]])
			joinSeparatedBy: String cr
]

{ #category : #private }
Compiler >> formatNoPattern: noPattern ifFail: failBlock [
	^(self parser
		parseCue: cue 
		noPattern: noPattern
		ifFail: [^failBlock value]) preen
]

{ #category : #private }
Compiler >> from: textOrStream class: aClass notifying: req [
	self setCue:
		(CompilationCue
			source: textOrStream
			class: aClass
			requestor: req)

]

{ #category : #private }
Compiler >> interactive [
	"The compilation is interactive if there is a requestor and that requestor does either not care or explicitly allow interactive error correction."
	
	^ cue requestor notNil
		and: [(cue requestor respondsTo: #wantsInteractiveErrorCorrection) not
			or: [cue requestor perform: #wantsInteractiveErrorCorrection]]
]

{ #category : #'public access' }
Compiler >> parse: textOrStream in: aClass notifying: req [
	"Compile the argument, textOrStream, with respect to the class, aClass, and
	 answer the MethodNode that is the root of the resulting parse tree.  Notify the
	 argument, req, if an error occurs. The failBlock is defaulted to an empty block."

	self from: textOrStream class: aClass notifying: req.
	^self parser
		parseCue: cue
		noPattern: false
		ifFail: []
]

{ #category : #'public access' }
Compiler >> parser [

	parser ifNil: [parser := (cue getClass ifNil: [self class]) newParser].
	^parser
]

{ #category : #'public access' }
Compiler >> parser: aParser [

	parser := aParser
]

{ #category : #'public access' }
Compiler >> parserClass: aParserClass [

	parser := aParserClass new
]

{ #category : #private }
Compiler >> setCue: aCue [
	cue := aCue
]

{ #category : #private }
Compiler >> translate: ignored noPattern: noPattern ifFail: failBlock [
	^self translateNoPattern: noPattern ifFail: failBlock
]

{ #category : #'public access' }
Compiler >> translate: aStream noPattern: noPattern ifFail: failBlock parser: parser [
	| tree |
	tree := parser
			parseCue: cue 
			noPattern: noPattern
			ifFail: [^ failBlock value].
	^ tree
]

{ #category : #private }
Compiler >> translateNoPattern: noPattern ifFail: failBlock [
	^self parser
		parseCue: cue 
		noPattern: noPattern
		ifFail: [^failBlock value]
]
