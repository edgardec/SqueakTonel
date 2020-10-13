Class {
	#name : #PseudoMetaclass,
	#superclass : #PseudoClass,
	#category : #'System-FilePackage'
}

{ #category : #accessing }
PseudoMetaclass >> fullName [
	^self name,' class'
]

{ #category : #accessing }
PseudoMetaclass >> realClass [
	^super realClass class
]

{ #category : #accessing }
PseudoMetaclass >> theNonMetaClass [
	"Sent to a class or metaclass, always return the class"

	^self realClass theNonMetaClass
]
