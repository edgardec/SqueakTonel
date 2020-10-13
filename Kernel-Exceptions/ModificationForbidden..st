"
This error is raised when attempting to mutate a read-only object.

My instances describe the necessary state to be able to reproduce the modification via the #retryModification protocol.

Instance Variables
	mirror:				<Context | Behavior | Array>
	object:				<Object>
	fieldIndex:			<SmallInteger | nil>
	newValue:			<Object>
	resumptionValue:	<Object>
	retrySelector:		<Symbol>

mirror
	- the object that will perform the modification on object if modificationRetried

object
	- read-only object that attempted to mutate

fieldIndex
	- index of the field in the object mutated, relevant for the corresponding selector

newValue
	- value that was attempted to be stored into the read-only object

resumptionValue
	- value that will be returned when the ModificationForbidden is resumed

retrySelector
	- selector that can be used to reproduce the mutation (#object:basicAt:put:, #object:instVarAt:put:, etc.)
"
Class {
	#name : #ModificationForbidden,
	#superclass : #Error,
	#instVars : [
		'mirror',
		'object',
		'fieldIndex',
		'newValue',
		'retrySelector',
		'resumptionValue'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #accessing }
ModificationForbidden >> fieldIndex [
	^fieldIndex
]

{ #category : #printing }
ModificationForbidden >> indexedMessageText [

	^ 'Cannot modify field {2} of read-only object {1}' translated
		format: {
			self printObject: object.
			fieldIndex }
]

{ #category : #'priv handling' }
ModificationForbidden >> isResumable [

	^ true
]

{ #category : #printing }
ModificationForbidden >> messageText [
	"Overwritten to initialize the message text to a standard text if it has not yet been set"
	
	^ messageText ifNil: [ messageText := self standardMessageText ]
]

{ #category : #accessing }
ModificationForbidden >> mirror [
	^mirror
]

{ #category : #accessing }
ModificationForbidden >> mirror: aContext object: anObject index: index newValue: value resumptionValue: valueToResumeWith retrySelector: selector [

	mirror := aContext.
	object := anObject.
	fieldIndex := index.
	newValue := value.
	retrySelector := selector.
	resumptionValue := valueToResumeWith
]

{ #category : #accessing }
ModificationForbidden >> mirror: aContext object: anObject index: index newValue: value retrySelector: selector [

	mirror := aContext.
	object := anObject.
	fieldIndex := index.
	newValue := value.
	retrySelector := selector.
	resumptionValue := value
]

{ #category : #accessing }
ModificationForbidden >> newValue [
	^newValue
]

{ #category : #printing }
ModificationForbidden >> nonIndexedMessageText [

	^ 'Cannot execute {2} on read-only object {1}' translated
		format: {
			self printObject: object.
			retrySelector printString }
]

{ #category : #accessing }
ModificationForbidden >> object [
	^object
]

{ #category : #private }
ModificationForbidden >> printObject: obj [

	^ [obj printString]
		ifError: ['<cannot print object>' translated]
]

{ #category : #controlling }
ModificationForbidden >> resume [
	"Return from the message that signaled the receiver."

	^ self resume: resumptionValue
]

{ #category : #accessing }
ModificationForbidden >> resumptionValue [
	^resumptionValue
]

{ #category : #accessing }
ModificationForbidden >> resumptionValue: anObject [
	resumptionValue := anObject
]

{ #category : #retrying }
ModificationForbidden >> retryModification [
	fieldIndex
		ifNotNil: [mirror perform: retrySelector with: object with: fieldIndex with: newValue]
		ifNil: [mirror perform: retrySelector with: object with: newValue].
	self resume: resumptionValue
]

{ #category : #retrying }
ModificationForbidden >> retryModificationNoResume [
	fieldIndex
		ifNotNil: [mirror perform: retrySelector with: object with: fieldIndex with: newValue]
		ifNil: [mirror perform: retrySelector with: object with: newValue]
]

{ #category : #accessing }
ModificationForbidden >> retrySelector [
	^retrySelector
]

{ #category : #printing }
ModificationForbidden >> standardMessageText [
	^fieldIndex
		ifNil: [self nonIndexedMessageText]
		ifNotNil: [self indexedMessageText]
]
