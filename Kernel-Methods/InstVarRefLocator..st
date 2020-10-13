"
My job is to scan bytecodes for instance variable references.

BlockClosure allInstances collect: [ :x |
	{x. x method hasInstVarRef}
]
"
Class {
	#name : #InstVarRefLocator,
	#superclass : #InstructionClient,
	#instVars : [
		'bingo'
	],
	#category : #'Kernel-Methods'
}

{ #category : #'initialize-release' }
InstVarRefLocator >> interpretNextInstructionUsing: aScanner [ 
	
	bingo := false.
	aScanner interpretNextInstructionFor: self.
	^bingo
]

{ #category : #'instruction decoding' }
InstVarRefLocator >> popIntoReceiverVariable: offset [ 

	bingo := true
]

{ #category : #'instruction decoding' }
InstVarRefLocator >> pushReceiverVariable: offset [

	bingo := true
]

{ #category : #'instruction decoding' }
InstVarRefLocator >> storeIntoReceiverVariable: offset [ 

	bingo := true
]
