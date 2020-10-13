Class {
	#name : #ParseNodeAttributeOccurence,
	#superclass : #ParseNodeAttribute,
	#instVars : [
		'node',
		'value',
		'dependencies',
		'selectedRule',
		'inputSizes',
		'sortInTime',
		'sortOutTime'
	],
	#category : #'Etoys-Squeakland-Tweak-Kedama-ParseTreeTransformer'
}

{ #category : #all }
ParseNodeAttributeOccurence >> addSource: anOccurence [

	dependencies nextPut: anOccurence.

]

{ #category : #all }
ParseNodeAttributeOccurence >> attributeName: aSymbol [

	attributeName := aSymbol.

]

{ #category : #all }
ParseNodeAttributeOccurence >> dependencies [

	^ dependencies contents.

]

{ #category : #all }
ParseNodeAttributeOccurence >> inTime [

	^ sortInTime.

]

{ #category : #all }
ParseNodeAttributeOccurence >> inTime: aValue [

	sortInTime := aValue.

]

{ #category : #all }
ParseNodeAttributeOccurence >> initialize [

	super initialize.
	dependencies := WriteStream on: (Array new: 8).
	sortInTime := -1.
	sortOutTime := -1.

]

{ #category : #all }
ParseNodeAttributeOccurence >> inputSizeAt: index put: size [

	inputSizes at: index put: size.

]

{ #category : #all }
ParseNodeAttributeOccurence >> inputSizes [

	^ inputSizes.

]

{ #category : #all }
ParseNodeAttributeOccurence >> node [

	^ node.

]

{ #category : #all }
ParseNodeAttributeOccurence >> node: aParseNode [

	node := aParseNode.

]

{ #category : #all }
ParseNodeAttributeOccurence >> outTime [

	^ sortOutTime.

]

{ #category : #all }
ParseNodeAttributeOccurence >> outTime: aValue [

	sortOutTime := aValue.
]

{ #category : #all }
ParseNodeAttributeOccurence >> printOn: aStream [

	aStream
		nextPutAll: 'Occurence(';
		nextPutAll: attributeName;
		nextPutAll: ', ';
		nextPutAll: grammarClass name;
		nextPutAll: ', ';
		nextPutAll: (value printString ifNil: ['nil']);
		nextPutAll: ')'.


]

{ #category : #all }
ParseNodeAttributeOccurence >> rawGetter: aSymbol [

	rawGetter := aSymbol.

]

{ #category : #all }
ParseNodeAttributeOccurence >> selectedRule [

	^ selectedRule.

]

{ #category : #all }
ParseNodeAttributeOccurence >> selectedRule: aSemanticRule [

	selectedRule := aSemanticRule.
	inputSizes := Array new: aSemanticRule inputSpecs size.

]

{ #category : #all }
ParseNodeAttributeOccurence >> setter: aSymbol [

	setter := aSymbol.

]

{ #category : #all }
ParseNodeAttributeOccurence >> value [

	^ value.

]

{ #category : #all }
ParseNodeAttributeOccurence >> value: anObject [

	value := anObject.

]
