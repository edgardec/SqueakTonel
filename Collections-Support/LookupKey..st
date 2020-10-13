"
I represent a key for looking up entries in a data structure. Subclasses of me, such as Association, typically represent dictionary entries.
"
Class {
	#name : #LookupKey,
	#superclass : #Magnitude,
	#instVars : [
		'key'
	],
	#category : #'Collections-Support'
}

{ #category : #'instance creation' }
LookupKey class >> key: aKey [ 
	"Answer an instance of me with the argument as the lookup up."

	^self basicNew key: aKey
]

{ #category : #comparing }
LookupKey >> < aLookupKey [ 
	"Refer to the comment in Magnitude|<."

	^key < aLookupKey key
]

{ #category : #comparing }
LookupKey >> = aLookupKey [

	self species = aLookupKey species
		ifTrue: [^key = aLookupKey key]
		ifFalse: [^false]
]

{ #category : #literals }
LookupKey >> allLiteralsDo: aBlock [
	"Treat myself or my key as literal. Do not treat any value (i.e., in Association or Binding) as literal to avoid decending too thoroughly. As a consequence, for example, classes have to be resolved to their class bindings or class names before using them as input in this interface."
	
	aBlock value: self.	
	self key allLiteralsDo: aBlock.
]

{ #category : #bindings }
LookupKey >> beBindingOfType: aClass announcing: aBool [
	"Make the receiver a global binding of the given type"

	self class == aClass ifTrue:[^self].
	self becomeForward: (aClass key: self key value: self value).
	"NOTE: Now self == read-only (e.g., the new binding)"
	^self recompileBindingsAnnouncing: aBool
]

{ #category : #bindings }
LookupKey >> beReadOnlyBinding [
	"Make the receiver (a global read-write binding) be a read-only binding"
	^self beReadOnlyBindingAnnouncing: true
]

{ #category : #bindings }
LookupKey >> beReadOnlyBindingAnnouncing: aBool [
	"Make the receiver (a global read-write binding) be a read-only binding"
	^self beBindingOfType: ReadOnlyVariableBinding announcing: aBool
]

{ #category : #bindings }
LookupKey >> beReadWriteBinding [
	"Make the receiver (a global read-only binding) be a read-write binding"
	^self beReadWriteBindingAnnouncing: true
]

{ #category : #bindings }
LookupKey >> beReadWriteBindingAnnouncing: aBool [
	"Make the receiver (a global read-write binding) be a read-write binding"
	^self beBindingOfType: Association announcing: aBool
]

{ #category : #accessing }
LookupKey >> canAssign [

	^ true
]

{ #category : #comparing }
LookupKey >> hash [
	"Hash is reimplemented because = is implemented."

	^key hash
]

{ #category : #testing }
LookupKey >> isSpecialReadBinding [
	"Return true if this variable binding is read protected, e.g., should not be accessed primitively but rather by sending #value messages"
	^false
]

{ #category : #testing }
LookupKey >> isVariableBinding [
	"Return true if I represent a literal variable binding"
	^true
]

{ #category : #accessing }
LookupKey >> key [
	"Answer the lookup key of the receiver."

	^key
]

{ #category : #accessing }
LookupKey >> key: anObject [ 
	"Store the argument, anObject, as the lookup key of the receiver."

	key := anObject
]

{ #category : #literals }
LookupKey >> literalEqual: otherLiteral [
	"Answer true if the receiver and otherLiteral represent the same literal. 
	
	By default, all lookup keys (such as variable bindings) are literally equal only if identical. This is how variable sharing works, by preserving identity and changing only the value.
	
	Override if you want to be more flexible such as in class bindings."
	
	^ self == otherLiteral
]

{ #category : #accessing }
LookupKey >> name [

	^ self key isString
		ifTrue: [self key]
		ifFalse: [self key printString]
]

{ #category : #printing }
LookupKey >> printOn: aStream [

	key printOn: aStream
]

{ #category : #bindings }
LookupKey >> recompileBindingsAnnouncing: aBool [ 
	"Make the receiver (a global read-write binding) be a read-only binding"

	aBool 
		ifTrue: 
			[UIManager default informUserDuring: 
					[:bar | 
					(self systemNavigation allCallsOn: self) do: 
							[:mref | 
							bar value: 'Recompiling ' , mref asStringOrText.
							mref actualClass recompile: mref methodSymbol]]]
		ifFalse: 
			[(self systemNavigation allCallsOn: self) 
				do: [:mref | mref actualClass recompile: mref methodSymbol]]
]

{ #category : #'filter streaming' }
LookupKey >> writeOnFilterStream: aStream [

	aStream write:key.
]
