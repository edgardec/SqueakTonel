Class {
	#name : #ScriptCompiler,
	#superclass : #Compiler,
	#category : #'Etoys-Squeakland-System-Compiler'
}

{ #category : #accessing }
ScriptCompiler class >> parserClass [

	^ ScriptParser
]

{ #category : #'as yet unclassified' }
ScriptCompiler >> compile: textOrStream in: aClass notifying: aRequestor ifFail: failBlock [
	
	self parserClass: ScriptParser.
	^ super compile: textOrStream in: aClass notifying: aRequestor ifFail: failBlock
]

{ #category : #'as yet unclassified' }
ScriptCompiler >> compile: textOrStream in: aClass notifying: aRequestor ifFail: failBlock for: anInstance [
	"Answer a MethodNode for the argument, textOrStream. If the 
	MethodNode can not be created, notify the argument, aRequestor; if 
	aRequestor is nil, evaluate failBlock instead. The MethodNode is the root 
	of a parse tree. It can be told to generate a CompiledMethod to be 
	installed in the method dictionary of the argument, aClass."

	self parserClass: ScriptParser.
	^ self parser
		parse: textOrStream readStream
		class: aClass
		noPattern: false
		context: nil
		notifying: aRequestor
		ifFail: [^ failBlock value] for: anInstance.

]

{ #category : #'as yet unclassified' }
ScriptCompiler >> evaluate: textOrStream in: aContext to: receiver notifying: aRequestor ifFail: failBlock logged: logFlag [
	"Compiles the sourceStream into a parse tree, then generates code into a 
	method. This method is then installed in the receiver's class so that it 
	can be invoked. In other words, if receiver is not nil, then the text can 
	refer to instance variables of that receiver (the Inspector uses this). If 
	aContext is not nil, the text can refer to temporaries in that context (the 
	Debugger uses this). If aRequestor is not nil, then it will receive a 
	notify:at: message before the attempt to evaluate is aborted."

	| methodNode method value toLog itsSelectionString itsSelection |
	methodNode :=  self parser new
		parse: textOrStream readStream
		class: (self classForReceiver: receiver context: aContext)
		noPattern: true
		context: aContext
		notifying: aRequestor
		ifFail: [^ failBlock value]
		for: receiver.
	method := methodNode generate: (CompiledMethodTrailer empty sourceCode: methodNode sourceText; yourself).
	self interactive ifTrue:
		[method := method copyWithTempNames: methodNode tempNames].
	
	value := receiver
				withArgs: (aContext ifNil: [#()] ifNotNil: [{aContext}])
				executeMethod: method.
	logFlag ifTrue:
		[toLog := ((aRequestor respondsTo: #selection)  and:
			[(itsSelection := aRequestor selection) notNil] and:
			[(itsSelectionString := itsSelection asString) isEmptyOrNil not] )
			ifTrue:
				[itsSelectionString]
			ifFalse:
				[textOrStream readStream contents].

		SystemChangeNotifier uniqueInstance evaluated: toLog context: aContext].

	^value
]
