Class {
	#name : #ScriptParser,
	#superclass : #Parser,
	#instVars : [
		'requestor'
	],
	#category : #'Etoys-Squeakland-System-Compiler'
}

{ #category : #'public access' }
ScriptParser >> encoder [
	^encoder ifNil:
		[encoder := ScriptEncoder new]
]

{ #category : #'as yet unclassified' }
ScriptParser >> parse: sourceStream class: class noPattern: noPattern context: ctxt notifying: req ifFail: aBlock [ 
        "Answer a MethodNode for the argument, sourceStream, that is the root of 
        a parse tree. Parsing is done with respect to the argument, class, to find 
        instance, class, and pool variables; and with respect to the argument, 
        ctxt, to find temporary variables. Errors in parsing are reported to the 
        argument, req, if not nil; otherwise aBlock is evaluated. The argument 
        noPattern is a Boolean that is true if the the sourceStream does not 
        contain a method header (i.e., for DoIts)."

	"Copied from superclass, use ScriptEncoder and give it a referenceWorld. This assumes worldLoading has been set to the right world this player belongs to. --bf 5/4/2010"

         | methNode repeatNeeded myStream parser s p |
        (req notNil and: [RequestAlternateSyntaxSetting signal and: [(sourceStream isKindOf: FileStream) not]])
                ifTrue: [parser := self as: DialectParser]
                ifFalse: [parser := self].
        myStream := sourceStream.
        [repeatNeeded := false.
	   p := myStream position.
	   s := myStream upToEnd.
	   myStream position: p.
        parser init: myStream notifying: req failBlock: [^ aBlock value].
        doitFlag := noPattern.
        failBlock := aBlock.
        [methNode := parser method: noPattern context: ctxt
                                encoder: (ScriptEncoder new init: class context: ctxt notifying: parser;
								referenceObject: Project current world referenceWorld )] 
                on: ParserRemovedUnusedTemps 
                do: 
                        [ :ex | repeatNeeded := (requestor isKindOf: TextEditor) not.
                        myStream := ReadStream on: requestor text string.
                        ex resume].
        repeatNeeded] whileTrue.
        encoder := failBlock := requestor := parseNode := nil. "break cycles & mitigate refct overflow"
	   methNode sourceText: s.
        ^ methNode
]

{ #category : #'as yet unclassified' }
ScriptParser >> parse: sourceStream class: class noPattern: noPattern context: ctxt notifying: req ifFail: aBlock for: anInstance [

         | methNode repeatNeeded myStream parser s p |
        (req notNil and: [RequestAlternateSyntaxSetting signal and: [(sourceStream isKindOf: FileStream) not]])
                ifTrue: [parser := self as: DialectParser]
                ifFalse: [parser := self].
        myStream := sourceStream.
        [repeatNeeded := false.
	   p := myStream position.
	   s := myStream upToEnd.
	   myStream position: p.
        parser init: myStream notifying: req failBlock: [^ aBlock value].
        doitFlag := noPattern.
        failBlock := aBlock.
        [methNode := parser method: noPattern context: ctxt
                                encoder: (ScriptEncoder new init: class context: ctxt notifying: parser;  referenceObject: (anInstance costume ifNotNil: [anInstance costume referenceWorld] ifNil: [Project current world]))] 
                on: ParserRemovedUnusedTemps 
                do: 
                        [ :ex | repeatNeeded := (requestor isKindOf: TextEditor) not.
                        myStream := ReadStream on: requestor text string.
                        ex resume].
        repeatNeeded] whileTrue.
        encoder := failBlock := requestor := parseNode := nil. "break cycles & mitigate refct overflow"
	   methNode sourceText: s.
        ^ methNode
]

{ #category : #'as yet unclassified' }
ScriptParser >> removeUnusedTemps [
	"doing nothing"
]

{ #category : #accessing }
ScriptParser >> requestor [

	^ requestor
]

{ #category : #accessing }
ScriptParser >> requestor: anObject [

	requestor := anObject
]
