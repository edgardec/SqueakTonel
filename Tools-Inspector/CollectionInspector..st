"
I am an Inspector that is specialized for inspecting collections. I provide extended access to the inspected collection's items, such as adding and removing items.

Note that I can directly inspect instances of ArrayedCollection and alike.
"
Class {
	#name : #CollectionInspector,
	#superclass : #Inspector,
	#category : #'Tools-Inspector'
}

{ #category : #'menu - construction' }
CollectionInspector >> addCollectionItemsTo: aMenu [

	aMenu addLine.
	super addCollectionItemsTo: aMenu.
	
	self object isReadOnlyObject ifTrue: [^ self].
	aMenu addTranslatedList: #(
		('refresh list view'			updateFields) "--- useful in non-stepping debugger").
	
	self canAddOrRemoveElements ifFalse: [^ self].
	aMenu addTranslatedList: #(
		-
		('add element...'		addElement)).
					
	self typeOfSelection = #element ifFalse: [^ self].
	aMenu addTranslatedList: #(
		('remove element (x)'	removeSelection)).
]

{ #category : #'menu - commands' }
CollectionInspector >> addElement [

	self addElement: (
		self
			requestObject: 'Enter expression for new object' translated
			orCancel: [^ self]).
]

{ #category : #'menu - commands' }
CollectionInspector >> addElement: anObject [

	self object add: anObject.

	self updateFields.
	self selectFieldSuchThat: [:field | [(field getValueFor: self) == anObject] ifError: [false]].
	self hasSelection ifFalse: [self inform: ('The new element {1} was added.\\Yet, the list of fields is quite long. The new field\got truncated and is thus not visible.' translated withCRs format: {anObject printString})].
]

{ #category : #private }
CollectionInspector >> assertElementSelectedOr: aBlock [

	^ self typeOfSelection = #element
		or: [aBlock cull: self selectedField]
]

{ #category : #private }
CollectionInspector >> canAddOrRemoveElements [
	"For simplicity, treat those properties together. There are no collections that support addition but deny removal of elements."
	
	^ #(add: remove:ifAbsent:) noneSatisfy: [:selector |
		(self object class lookupSelector: selector) hasLiteral: #shouldNotImplement]
]

{ #category : #private }
CollectionInspector >> elementGetterAt: index [

	^ [:collection | collection at: index] 
]

{ #category : #private }
CollectionInspector >> elementIndices [

	^ 1 to: self objectSize
]

{ #category : #private }
CollectionInspector >> elementSetterAt: index [

	^ [:collection :element | collection at: index put: element] 
]

{ #category : #'menu - commands' }
CollectionInspector >> inspectOne [
	"Only list the collection's elements. Ignore any other fields."
	
	self inspectOneOf: self elementIndices.
]

{ #category : #menu }
CollectionInspector >> inspectorKey: aChar from: view [

	^ aChar = $x
		ifTrue: [self removeSelection]
		ifFalse: [super inspectorKey: aChar from: view].
]

{ #category : #private }
CollectionInspector >> objectSize [
	"For robustness. Partially initialized collections may fail to report their size. Useful for the debugger's inspectors."

	^ [self object size] ifError: [0]
]

{ #category : #'menu - commands' }
CollectionInspector >> removeSelectedElement [
	
	self object remove: self selection.
]

{ #category : #'menu - commands' }
CollectionInspector >> removeSelection [
	"Keep the selection stable to support subsequent removals. Be robust against collections that do not allow elements to be removed such as arrays."
	
	| priorSelectionIndex |
	super removeSelection.
	
	self assertElementSelectedOr: [^ self changed: #flash].
	priorSelectionIndex := self selectionIndex.
	
	[self removeSelectedElement]
		ifError: [^ self changed: #flash].
		
	self updateFields.
	self selectionIndex: (priorSelectionIndex min: self fields size).
]

{ #category : #'ui requests' }
CollectionInspector >> requestObject: aMessageString initialAnswer: anAnswerString orCancel: aBlock [

	| input |
	input := Project uiManager
		request: aMessageString
		initialAnswer: anAnswerString.
	input isEmptyOrNil ifTrue: [^ aBlock value].
	^ Compiler evaluate: input for: self object
]

{ #category : #'ui requests' }
CollectionInspector >> requestObject: aMessageString orCancel: aBlock [

	^ self
		requestObject: aMessageString
		initialAnswer: String empty
		orCancel: aBlock
]

{ #category : #selection }
CollectionInspector >> selectElementAt: index [

	self selectFieldSuchThat: [:field | field type = #element and: [field key = index]].
]

{ #category : #selection }
CollectionInspector >> selectedElementIndex [

	self assertElementSelectedOr: [^ nil].
	^ self selectedField key
]

{ #category : #'fields - streaming' }
CollectionInspector >> streamElementsOn: aStream [
	"Create a field for each element in the collection. Use the index' #printString (and not #asString) to reveal the nature of the key, which are usually integers (1, 2, 3, ...), but can be symbols (#apple, #tree, ...) or other objects (aMorph, aSocket, ...) in dictionary-like collections. Maybe #storeString would be even better but can be very expensive to compute."

	self
		streamOn: aStream
		truncate: self elementIndices
		collectFields: [:index |
			(self newFieldForType: #element key: index)
				name: index printString;
				valueGetter: (self elementGetterAt: index);
				valueSetter: (self elementSetterAt: index);
				yourself]
]

{ #category : #'fields - streaming' }
CollectionInspector >> streamIndexedVariablesOn: aStream [
	"Override to rename 'index variables' to the collection's 'elements'."
	
	self streamElementsOn: aStream.
]
