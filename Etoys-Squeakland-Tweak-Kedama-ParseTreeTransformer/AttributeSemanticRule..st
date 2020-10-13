Class {
	#name : #AttributeSemanticRule,
	#superclass : #Object,
	#instVars : [
		'inputSpecs',
		'output',
		'selector',
		'ruleText'
	],
	#category : #'Etoys-Squeakland-Tweak-Kedama-ParseTreeTransformer'
}

{ #category : #all }
AttributeSemanticRule >> inputSpecs [

	^ inputSpecs.

]

{ #category : #all }
AttributeSemanticRule >> inputSpecs: inputs [

	inputSpecs := inputs.

]

{ #category : #all }
AttributeSemanticRule >> output [

	^ output.

]

{ #category : #all }
AttributeSemanticRule >> output: attr [

	output := attr.

]

{ #category : #all }
AttributeSemanticRule >> printOn: aStream [

	aStream nextPutAll: 'Rule(';
		nextPutAll: output grammarClass name; 
		nextPut: $.;
		nextPutAll: output attributeName;
		nextPutAll: ' := ';
		nextPutAll: (selector ifNil: ['nil']);
		nextPut: $(.
	inputSpecs do: [:in |
		in printOn: aStream
	].
	aStream nextPutAll: '))'.

]

{ #category : #all }
AttributeSemanticRule >> ruleText [

	^ ruleText.

]

{ #category : #all }
AttributeSemanticRule >> ruleText: text [

	ruleText := text.

]

{ #category : #all }
AttributeSemanticRule >> selector [

	^ selector.

]

{ #category : #all }
AttributeSemanticRule >> selector: aSymbol [

	selector := aSymbol.


]

{ #category : #all }
AttributeSemanticRule >> shouldBundleArgs [

	^ inputSpecs size = 1 and: [inputSpecs first type = #allChildrenSynth].

]
