"
The purpose of this class is to carry along with theinformation in a regular method node the further information that it was parsed from an laternate dialect of Squeak.  Which dialect that was is carried as a symbol in the dialect variable.
"
Class {
	#name : #DialectMethodNode,
	#superclass : #MethodNode,
	#instVars : [
		'dialect'
	],
	#category : #'Etoys-Squeakland-System-Compiler'
}

{ #category : #'as yet unclassified' }
DialectMethodNode >> setDialect: dialectSymbol [

	dialect := dialectSymbol
]

{ #category : #'as yet unclassified' }
DialectMethodNode >> test: arg1 with: arg2 [ 
	^ 3 between: arg1 and: arg2
]
