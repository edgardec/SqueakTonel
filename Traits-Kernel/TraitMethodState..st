"
Additional method state for trait provided methods.
"
Class {
	#name : #TraitMethodState,
	#superclass : #AdditionalMethodState,
	#type : #variable,
	#instVars : [
		'originalTraitMethod'
	],
	#category : #'Traits-Kernel'
}

{ #category : #accessing }
TraitMethodState >> methodHome [
	"The behavior (trait/class) this method was originally defined in. 
	Derived from the originalTraitMethod if any."
	^originalTraitMethod ifNil:[super methodHome] ifNotNil:[:m| m methodHome]
]

{ #category : #accessing }
TraitMethodState >> originalTraitMethod [
	"The original method from the trait"
	^originalTraitMethod
]

{ #category : #accessing }
TraitMethodState >> originalTraitMethod: aCompiledMethod [
	"The original method from the trait"
	originalTraitMethod := aCompiledMethod
]

{ #category : #accessing }
TraitMethodState >> originalTraitOrClass [
	"The original trait for this method"
	^originalTraitMethod originalTraitOrClass
]
