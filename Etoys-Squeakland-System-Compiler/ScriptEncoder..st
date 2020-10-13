Class {
	#name : #ScriptEncoder,
	#superclass : #EncoderForV3PlusClosures,
	#instVars : [
		'referenceObject'
	],
	#category : #'Etoys-Squeakland-System-Compiler'
}

{ #category : #'as yet unclassified' }
ScriptEncoder >> encodePlayer: anObject [

	| n |
	n := referenceObject uniqueNameForReferenceFor: anObject.
	^ self encodeVariable: n.

]

{ #category : #'as yet unclassified' }
ScriptEncoder >> init: class context: ctxt notifying: parser [

	super
		init: (CompilationCue
				source: nil
				context: ctxt
				receiver: nil
				class: class
				environment: Smalltalk environment
				requestor: nil)
		notifying: parser
]

{ #category : #'as yet unclassified' }
ScriptEncoder >> init: class notifying: parser [

	super init: class notifying: parser.
	self referenceObject: Project current world referenceWorld.
]

{ #category : #private }
ScriptEncoder >> lookupInPools: varName ifFound: assocBlock [

	referenceObject referencePool ifNotNil: [:pool |
		(pool bindingOf: varName asSymbol) ifNotNil:[:assoc| 
			assocBlock value: assoc.
			^ true]].
	^ super lookupInPools: varName ifFound: assocBlock.

]

{ #category : #'as yet unclassified' }
ScriptEncoder >> referenceObject: anObject [

	referenceObject := anObject.

]
