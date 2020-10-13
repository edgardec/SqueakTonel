"
My subclasses are dynamic variables: each subclass represents a variable
whose value persists inside the block passed to #value:during:. There is
no way to change the value inside such a block, but it is possible to
temporarirly rebind it in a nested manner.
"
Class {
	#name : #DynamicVariable,
	#superclass : #ProcessSpecificVariable,
	#category : #'Kernel-Processes-Variables'
}

{ #category : #accessing }
DynamicVariable class >> value: anObject during: aBlock [

	| p oldValue outerScopeWasDynamic |
	p := Processor activeProcess.
	outerScopeWasDynamic := true.
	oldValue := p
		environmentAt: self
		ifAbsent: [outerScopeWasDynamic := false. nil].
	^[
		p environmentAt: self put: anObject.
		aBlock value ] 
			ensure: [ outerScopeWasDynamic
				ifTrue: [p environmentAt: self put: oldValue]
				ifFalse: [p environmentRemoveKey: self ifAbsent: []] ].
]
