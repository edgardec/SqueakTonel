"
A SpecialSelectorNode is a subclass of SelectorNode that handles the special selectors, a high static and/or dynamic frequency set of selectors that are assigned their own bytecodes.  Special selectors both save space in the literal frame and allow an interpreter to implement these sends directly for certain classes of receiver and argument, for example the SmallIntegers, a technique known as static receiver prediction.
"
Class {
	#name : #SpecialSelectorNode,
	#superclass : #SelectorNode,
	#category : #'Compiler-ParseNodes'
}

{ #category : #'code generation' }
SpecialSelectorNode >> emitCode: stack args: nArgs encoder: encoder super: supered [
	"Generate a special selector send.
	 A super send of a special selector must be handled like a normal send.
	 This is handled in MessageNode>>sizeCodeForValue: by mapping any
	 SpecialSelectorNodes used in super sends into normal SelectorNodes."
	supered ifTrue: [self invalidSuperSendError].
	stack pop: nArgs.
	encoder genSendSpecial: code numArgs: nArgs
]

{ #category : #'code generation' }
SpecialSelectorNode >> forSuperSend [
	"Answer the receiver or a derivative, suitable for use in a super send."

	"Excuse the code negation nonsense.  It is a vestige of a very concise but now
	 obsolete back-end bytecode encoding scheme. We're working on removing it."
	^SelectorNode new
		key: key
		code: SendType negated
		index: index
]

{ #category : #private }
SpecialSelectorNode >> invalidSuperSendError [
	self error: 'special selectors can only be used for ordinary sends'
]

{ #category : #'code generation' }
SpecialSelectorNode >> resetForBlockGeneration [
	"Reset the receiver to an unassigned state such that its index
	 in the encoder's literalStream is as yet to be determined."
	index := nil
]

{ #category : #'code generation' }
SpecialSelectorNode >> sizeCode: encoder args: nArgs super: supered [
	"Size a special selector send.
	 A super send of a special selector must be handled like a normal send.
	 This is handled in MessageNode>>sizeCodeForValue: by mapping any
	 SpecialSelectorNodes used in super sends into normal SelectorNodes."
	supered ifTrue: [self invalidSuperSendError].
	^encoder sizeSendSpecial: code numArgs: nArgs
]
