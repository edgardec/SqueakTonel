Class {
	#name : #ParseNodeAttribute,
	#superclass : #Object,
	#instVars : [
		'grammarClass',
		'attributeName',
		'type',
		'rules',
		'setter',
		'rawGetter'
	],
	#category : #'Etoys-Squeakland-Tweak-Kedama-ParseTreeTransformer'
}

{ #category : #all }
ParseNodeAttribute >> addRule: aSemanticRule [

	| newRules |
	newRules := Array new: rules size + 1.
	newRules at: 1 put: aSemanticRule.
	newRules replaceFrom: 2 to: newRules size with: rules startingAt: 1.
	rules := newRules.

]

{ #category : #all }
ParseNodeAttribute >> addRules: semanticRules [

	rules := rules, semanticRules.

]

{ #category : #all }
ParseNodeAttribute >> attributeName [

	^ attributeName.

]

{ #category : #all }
ParseNodeAttribute >> attributeName: aSymbol [

	attributeName := aSymbol.
	setter := (attributeName, ':') asSymbol.
	rawGetter := ('raw', attributeName) asSymbol.
	"rawGetter := attributeName asSymbol."


]

{ #category : #all }
ParseNodeAttribute >> grammarClass [

	^ grammarClass.

]

{ #category : #all }
ParseNodeAttribute >> grammarClass: aClass [

	grammarClass := aClass.

]

{ #category : #all }
ParseNodeAttribute >> initialize [

	rules := Array new.

]

{ #category : #all }
ParseNodeAttribute >> printOn: aStream [

	aStream
		nextPutAll: 'Attribute(';
		nextPutAll: attributeName;
		nextPutAll: ', ';
		nextPutAll: grammarClass name;
		nextPutAll: ')'.


]

{ #category : #all }
ParseNodeAttribute >> rawGetter [

	^ rawGetter.

]

{ #category : #all }
ParseNodeAttribute >> rules [

	^ rules.

]

{ #category : #all }
ParseNodeAttribute >> setter [

	^ setter.

]

{ #category : #all }
ParseNodeAttribute >> type [

	^ type.
]

{ #category : #all }
ParseNodeAttribute >> type: aSymbol [

	type := aSymbol.

]
