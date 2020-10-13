"
I am an Inspector that is specialized for inspecting Dictionarys.
"
Class {
	#name : #DictionaryInspector,
	#superclass : #CollectionInspector,
	#category : #'Tools-Inspector'
}

{ #category : #'menu - commands' }
DictionaryInspector >> addElement [

	self addElement: (self requestKeyOrCancel: [^ self]).
]

{ #category : #'menu - commands' }
DictionaryInspector >> addElement: aKey [

	self object at: aKey put: nil.
	self updateFields.
	
	self selectKey: aKey.
	self hasSelection ifFalse: [self inform: ('The new key {1} was added.\\Yet, the list of fields is quite long. The new field\got truncated and is thus not visible.' translated withCRs format: {aKey printString})].
]

{ #category : #'menu - construction' }
DictionaryInspector >> addFieldItemsTo: aMenu [

	super addFieldItemsTo: aMenu.

	self typeOfSelection = #element ifFalse: [^ self].
	
	aMenu addLine.
	
	self selectedKey isSymbol ifTrue: [
		aMenu addTranslatedList: #(
			('senders of this key'		sendersOfSelectedKey))].
	
	aMenu addTranslatedList: #(
			('inspect key'				inspectKey)
			('rename key'				renameKey)).
							
	self isBindingSelected ifTrue: [
		aMenu addTranslatedList: #(
			-
			('references to binding'		usersOfSelectedBinding		'Browse all users of this binding.'))].
]

{ #category : #private }
DictionaryInspector >> canAddOrRemoveElements [
	"Due to a strange reason, #add: is supported in Dictionary but #remove:ifAbsent: is not."

	^ true
]

{ #category : #private }
DictionaryInspector >> elementIndices [

	^ [ self object keysInOrder ] ifError: [
		"Can occur when debugging Dictionary new"
		Array empty]
]

{ #category : #'menu - commands' }
DictionaryInspector >> inspectKey [
	"Create and schedule an Inspector on the receiver's model's currently selected key."

	self assertElementSelectedOr: [^ self].
	self selectedKey inspect.
]

{ #category : #bindings }
DictionaryInspector >> isBindingSelected [
	"Whether the currently selection association is a binding to a class or global."
	
	^ self selectedKey ifNil: [false] ifNotNil: [:key |
		(self object associationAt: key) isKindOf: Binding]
]

{ #category : #'menu - commands' }
DictionaryInspector >> removeSelectedElement [

	self object removeKey: self selectedKey.
]

{ #category : #'menu - commands' }
DictionaryInspector >> renameKey [

	self assertElementSelectedOr: [^ self changed: #flash].
	self renameKey: (
		self
			requestKeyInitialAnswer: self selectedKey storeString
			orCancel: [^ self]).
]

{ #category : #'menu - commands' }
DictionaryInspector >> renameKey: aKey [

	self assertElementSelectedOr: [^ self changed: #flash].

	(self object includesKey: aKey)
		ifTrue: [(self confirm: 'The target key exists. Do you want to replace it?' translated)
			ifFalse: [^ self]].

	self object
		at: aKey put: self selection;
		removeKey: self selectedKey.
	self updateFields.
	
	self selectKey: aKey.
	self hasSelection ifFalse: [self inform: ('The selected key was renamed to {1}.\\Yet, the list of fields is quite long. The new field\got truncated and is thus not visible.' translated withCRs format: {aKey printString})].
]

{ #category : #'ui requests' }
DictionaryInspector >> requestKeyInitialAnswer: anAnswerString orCancel: aBlock [

	^ self
		requestObject: ('Enter an expression for the new key\such as #tree, ''apple'', and 3+4.' translated withCRs)
		initialAnswer: anAnswerString
		orCancel: aBlock
]

{ #category : #'ui requests' }
DictionaryInspector >> requestKeyOrCancel: aBlock [

	^ self
		requestKeyInitialAnswer: String empty
		orCancel: aBlock
]

{ #category : #selection }
DictionaryInspector >> selectKey: aKey [
	"Overriden to make clear that a dictionary's indices are called 'keys'."
	
	self selectElementAt: aKey.
]

{ #category : #bindings }
DictionaryInspector >> selectedBinding [
	
	^ self selectedKey
		ifNotNil: [:key | self object associationAt: key]
]

{ #category : #selection }
DictionaryInspector >> selectedKey [
	"Overriden to make clear that a dictionary's indices are called 'keys'."

	^ self selectedElementIndex
]

{ #category : #'menu - commands' }
DictionaryInspector >> sendersOfSelectedKey [
	"Create a browser on all senders of the selected key"

	| aKey |
	((aKey := self selectedKey) isSymbol)
		ifFalse: [^ self changed: #flash].
	self systemNavigation browseAllCallsOn: aKey
]

{ #category : #'menu - commands' }
DictionaryInspector >> usersOfSelectedBinding [
	"Create a browser on all references to the association of the current selection."

	self selectedBinding ifNotNil: [:binding |
		self systemNavigation browseAllCallsOn: binding].
]
