"
This class is for switching external prim calls (primitiveExternalCall) on and off.

It is best suited for plugin testing purposes with temporarily switching plugin calls off and on. For permanently switching plugin calls off while preserving the possibility to switch them on later, you should use PCCByCompilation instead.

It works by manipulating literals in the CompiledMethods:
	Disabling works by changing the function index in the first literal of the CompiledMethod to a negative value (-2). This leads to a fast fail (value -2 is used for disabling to make a difference to the standard failed value of -1).
	Enabling works by changing the function index in the first literal of the CompiledMethod to 0, followed by flushing the method cache. This enforces a fresh lookup.

Please look into superclass PrimCallControllerAbstract for more info and the user interface.

Structure:
 No instVars here: look into superclass.
"
Class {
	#name : #PCCByLiterals,
	#superclass : #PrimCallControllerAbstract,
	#category : #'Tests-PrimCallController'
}

{ #category : #'ui testing' }
PCCByLiterals >> existsCallIn: aMethodRef [ 
	"Here >>existsCompiledCallIn: (see also comment there) is sufficient to 
	query for all enabled, failed and disabled prim calls; for the by 
	compiler version it is not sufficient for disabled ones."
	^ self existsCompiledCallIn: aMethodRef
]

{ #category : #'ui testing' }
PCCByLiterals >> existsDisabledCallIn: aMethodRef [ 
	^ (self existsCompiledCallIn: aMethodRef)
		and: [(aMethodRef compiledMethod literals first at: 4)
				= -2]
]

{ #category : #'ui querying' }
PCCByLiterals >> extractCallModuleNames: aMethodRef [ 
	^ (self existsCallIn: aMethodRef)
		ifTrue: [self extractCallModuleNamesFromLiterals: aMethodRef]
]

{ #category : #'ui querying' }
PCCByLiterals >> methodsWithCall [
	^ self methodsWithCompiledCall
]

{ #category : #'ui querying' }
PCCByLiterals >> methodsWithDisabledCall [
	^ self methodsWithCompiledCall
		select: [:mRef | (mRef compiledMethod literals first at: 4)
				= -2]
]

{ #category : #'private user interface' }
PCCByLiterals >> privateDisableCallIn: aMethodRef [ 
	"Disables enabled or failed external prim call by filling function ref 
	literal with special fail value, will be called by superclass."
	aMethodRef compiledMethod literals first at: 4 put: -2
]

{ #category : #'private user interface' }
PCCByLiterals >> privateEnableCallIn: aMethodRef [
	"Enables disabled external prim call."
	self privateEnableViaLiteralIn: aMethodRef
]
