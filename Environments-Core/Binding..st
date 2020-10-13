Class {
	#name : #Binding,
	#superclass : #LookupKey,
	#category : #'Environments-Core'
}

{ #category : #'system management' }
Binding class >> convertInstances [
	| new old |
	old := Binding allInstances.
	new := old collect: [:ea | ClassBinding key: ea key value: ea value].
	old elementsForwardIdentityTo: new.
	
	old := ReadOnlyVariableBinding allInstances.
	new := old collect: [:ea | ClassBinding key: ea key value: ea value].
	old elementsForwardIdentityTo: new.
	
	Environment allInstancesDo:
		[:env |
		#('contents' 'bindings' 'public' 'undeclared') do:
			[:var || dict |
			old := Array new writeStream.
			new := Array new writeStream.
			dict := env instVarNamed: var.
			dict associations do:
				[:binding |
				binding class == Association ifTrue:
					[old nextPut: binding.
					new nextPut: binding key => binding value]].
			old contents elementsForwardIdentityTo: new contents]]
]

{ #category : #comparing }
Binding >> analogousCodeTo: anObject [
	"For MethodProperties comparison."
	^anObject isVariableBinding
	  and: [self key = anObject key
	  and: [self value = anObject value]]
]

{ #category : #accessing }
Binding >> canAssign [
	^ true
]

{ #category : #testing }
Binding >> isSpecialReadBinding [
	^ false
]

{ #category : #testing }
Binding >> isSpecialWriteBinding [
	^ false
]

{ #category : #'objects from disk' }
Binding >> objectForDataStream: refStrm [
	"I am about to be written on an object file.  I am a global, so write a proxy that 
	will hook up with the same resource in the destination system."

	| dp |
	dp := DiskProxy 
		global: #Smalltalk 
		selector: #associationOrUndeclaredAt: 
		args: (Array with: key).
	refStrm replace: self with: dp.
	^ dp
]

{ #category : #printing }
Binding >> printOn: aStream [
	key printOn: aStream.
	aStream nextPutAll: '=>'.
	self value printOn: aStream
]

{ #category : #accessing }
Binding >> source [
	^ self
]
