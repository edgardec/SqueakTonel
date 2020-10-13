"
A MethodInterface describes the interface for a single method.  The most generic form is not bound to any particular class or object but rather describes an idealized interface.

	selector					A symbol - the selector being described
	argumentSpecifications	A list of specifications for the formal arguments of the method
	resultSpecification 		A characterization of the return value of the method
	userLevel				
	attributeKeywords		A list of symbols, comprising keywords that the user wishes to
								see on the screen for this method
	defaultStatus			The status to apply to new instances of the class by default
							(#ticking, #paused, #normal, etc.)



"
Class {
	#name : #MethodInterface,
	#superclass : #ObjectWithDocumentation,
	#instVars : [
		'selector',
		'argumentVariables',
		'resultSpecification',
		'receiverType',
		'attributeKeywords',
		'defaultStatus'
	],
	#category : #'Protocols-Kernel'
}

{ #category : #utilities }
MethodInterface class >> firingInterface [
	"Answer an instance of the receiver representing #fire"

	^ self new selector: #fire type: nil setter: nil
]

{ #category : #utilities }
MethodInterface class >> isNullMarker: aMarker [
	"Answer true if aMarker is nil or is one of the symbols in #(none #nil unused missing) -- to service a variety of historical conventions"

	^ aMarker isNil or: [#(none #nil unused missing) includes: aMarker]

"
MethodInterface isNullMarker: nil
MethodInterface isNullMarker: #nil
MethodInterface isNullMarker: #none
MethodInterface isNullMarker: #znak
"
]

{ #category : #initialization }
MethodInterface >> argumentVariables [
	"Answer the list of argumentVariables of the interface"

	^ argumentVariables ifNil: [argumentVariables := OrderedCollection new]
]

{ #category : #initialization }
MethodInterface >> argumentVariables: variableList [
	"Set the argument variables"

	argumentVariables := variableList
]

{ #category : #'attribute keywords' }
MethodInterface >> attributeKeywords [
	"Answer a list of attribute keywords associated with the receiver"

	^ attributeKeywords ifNil: [attributeKeywords := OrderedCollection new]
]

{ #category : #access }
MethodInterface >> companionSetterSelector [
	"If there is a companion setter selector, anwer it, else answer nil"

	^ resultSpecification ifNotNil:
		[resultSpecification companionSetterSelector]
]

{ #category : #initialization }
MethodInterface >> conjuredUpFor: aSelector class: aClass [
	"Initialize the receiver to have the given selector, obtaining whatever info one can from aClass.  This basically covers the situation where no formal definition has been made."

	| parts |
	self initializeFor: aSelector.
	self wording: aSelector.

	receiverType := #unknown.
	parts := aClass formalHeaderPartsFor: aSelector.
	argumentVariables := (1 to: selector numArgs) collect:
		[:anIndex | Variable new name: (parts at: (4 * anIndex)) type: #Object].
	parts last isEmptyOrNil ifFalse: [self documentation: parts last].

]

{ #category : #status }
MethodInterface >> defaultStatus [
	"Answer the receiver's default defaultStatus"

	^ defaultStatus
]

{ #category : #status }
MethodInterface >> defaultStatus: aStatus [
	"Set the receiver's defaultStatus as indicated"

	defaultStatus := aStatus
]

{ #category : #access }
MethodInterface >> elementSymbol [
	"Answer the element symbol, for the purposes of translation"

	^ selector
]

{ #category : #'attribute keywords' }
MethodInterface >> flagAttribute: aSymbol [
	"Mark the receiver as having the given category-keyword"

	(self attributeKeywords includes: aSymbol) ifFalse: [attributeKeywords add: aSymbol]
]

{ #category : #'attribute keywords' }
MethodInterface >> flagAttributes: attributeSymbolList [
	"Mark the receiver has being flagged with all the symbols in the list provided"

	attributeSymbolList do: [:aSym | self flagAttribute: aSym]
]

{ #category : #initialization }
MethodInterface >> initialize [
	"Initialize the receiver"

	super initialize.
	attributeKeywords := OrderedCollection new.
	defaultStatus := #normal.
	argumentVariables := OrderedCollection new

]

{ #category : #initialization }
MethodInterface >> initializeFor: aSelector [
	"Initialize the receiver to have the given selector"

	selector := aSelector.
	attributeKeywords := OrderedCollection new.
	defaultStatus := #normal

]

{ #category : #initialization }
MethodInterface >> initializeSetterFromEToySlotSpec: tuple [
	"tuple holds an old etoy slot-item spec, of the form found in #additionsToViewerCategories methods.   Initialize the receiver to represent the getter of this item"

	selector := tuple ninth.
	self
		wording: ('set ', tuple second);
		helpMessage: ('setter for', tuple third).
	receiverType := #Player.
	argumentVariables := Array with: (Variable new variableType: tuple fourth)
	
]

{ #category : #'attribute keywords' }
MethodInterface >> isFlaggedAs: aSymbol [
	"Answer whether the receiver is flagged with the given trait"

	^ self attributeKeywords includes: aSymbol
]

{ #category : #printing }
MethodInterface >> printOn: aStream [
	"print the receiver on a stream.  Overridden to provide details about wording, selector, result type, and companion setter."

	super printOn: aStream.
	aStream nextPutAll: ' - wording: ';
		print: self wording;
		nextPutAll: ' selector: ';
		print: selector.
	self argumentVariables size > 0 ifTrue:
		[aStream nextPutAll: ' Arguments: '.
		argumentVariables doWithIndex:
			[:aVariable :anIndex | 
				aStream nextPutAll: 'argument #', anIndex printString, ' name = ', aVariable variableName asString, ', type = ', aVariable variableType]].
	resultSpecification ifNotNil:
		[aStream nextPutAll: ' result type = ', resultSpecification resultType asString.
		resultSpecification companionSetterSelector ifNotNil:
			[aStream nextPutAll: ' setter = ', resultSpecification companionSetterSelector asString]]
	
]

{ #category : #access }
MethodInterface >> receiverType [
	"Answer the receiver type"

	^ receiverType ifNil: [receiverType := #unknown]
]

{ #category : #initialization }
MethodInterface >> receiverType: aType [
	"set the receiver type.  Whether the receiverType earns its keep here is not yet well understood.  At the moment, this is unsent"

	receiverType := aType
]

{ #category : #'initialize-release' }
MethodInterface >> releaseCachedState [
	"Sent by player"
]

{ #category : #access }
MethodInterface >> resultType [
	"Answer the result type"

	^ resultSpecification
		ifNotNil:
			[resultSpecification type]
		ifNil:
			[#unknown]
]

{ #category : #initialization }
MethodInterface >> resultType: aType [
	"Set the receiver's resultSpecification to be a ResultType of the given type"

	resultSpecification := ResultSpecification new.
	resultSpecification resultType: aType
]

{ #category : #access }
MethodInterface >> selector [
	"Answer the receiver's selector"

	^ selector
]

{ #category : #'attribute keywords' }
MethodInterface >> selector: aSelector type: aType setter: aSetter [
	"Set the receiver's fields as indicated.  Values of nil or #none for the result type and the setter indicate that there is none"

	selector := aSelector.
	(MethodInterface isNullMarker: aType) ifFalse:
		[resultSpecification := ResultSpecification new.
		resultSpecification resultType: aType.
		(MethodInterface isNullMarker: aSetter) ifFalse:
			[resultSpecification companionSetterSelector: aSetter]]
]

{ #category : #initialization }
MethodInterface >> setNotToRefresh [
	"Set the receiver up not to do periodic refresh."

	resultSpecification ifNotNil: [resultSpecification refetchFrequency: nil]
]

{ #category : #initialization }
MethodInterface >> setToRefetch [
	"Set the receiver up to expect a refetch, assuming it has a result specification"

	resultSpecification ifNotNil: [resultSpecification refetchFrequency: 1]
]

{ #category : #access }
MethodInterface >> typeForArgumentNumber: anArgumentNumber [
	"Answer the data type for the given argument number"

	| aVariable |
	aVariable := self argumentVariables at: anArgumentNumber.
	^ aVariable variableType
]

{ #category : #access }
MethodInterface >> wantsReadoutInViewer [
	"Answer whether the method represented by the receiver is one which should have a readout in a viewer"

	^ resultSpecification notNil and:
		[resultSpecification refetchFrequency notNil]
]
