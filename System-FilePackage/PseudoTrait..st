"
Like a PseudoClass, but standing in for a Trait. Works identically to PseudoClass otherwise.
"
Class {
	#name : #PseudoTrait,
	#superclass : #PseudoClass,
	#category : #'System-FilePackage'
}

{ #category : #testing }
PseudoTrait >> isTrait [
	^ true
]
