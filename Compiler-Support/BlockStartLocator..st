"
A BlockStartLocator is a scanner that locates the block creation bytecodes in a method.  For block creation bytecodes it answers information salient to the kind of block being created, and for all other bytecodes simply answers itself.

Instance Variables

"
Class {
	#name : #BlockStartLocator,
	#superclass : #InstructionClient,
	#category : #'Compiler-Support'
}

{ #category : #'instruction decoding' }
BlockStartLocator >> pushClosureCopyNumCopiedValues: numCopied numArgs: numArgs blockSize: blockSize [
	"Answer the size of the block"
	^blockSize
]

{ #category : #'instruction decoding' }
BlockStartLocator >> pushFullClosure: aCompiledBlock numCopied: numCopied [
	"Answer the block method"
	^aCompiledBlock
]
