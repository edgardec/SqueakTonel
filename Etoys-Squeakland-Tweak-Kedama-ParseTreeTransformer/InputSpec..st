Class {
	#name : #InputSpec,
	#superclass : #Object,
	#instVars : [
		'type',
		'attributeName',
		'uniqueName',
		'rawGetter'
	],
	#category : #'Etoys-Squeakland-Tweak-Kedama-ParseTreeTransformer'
}

{ #category : #all }
InputSpec >> attributeName [

	^ attributeName.

]

{ #category : #all }
InputSpec >> attributeName: aSymbol [

	attributeName := aSymbol.
	rawGetter := ('raw', attributeName) asSymbol.
	"rawGetter := attributeName asSymbol."

]

{ #category : #all }
InputSpec >> printOn: aStream [

	aStream nextPutAll: 'InputSpec(';
		nextPutAll: attributeName;
		nextPut: $).

]

{ #category : #all }
InputSpec >> rawGetter [

	^ rawGetter.

]

{ #category : #all }
InputSpec >> type [

	^ type.

]

{ #category : #all }
InputSpec >> type: aSymbol [

	"#parentInh, #parentSynth, #parentInhFirstChild, #elderSiblingSynth, #lastChildSynth, #mySynth #myInh, #allChildrenSynth, #intrinsic"
	type := aSymbol.

]

{ #category : #all }
InputSpec >> uniqueName [

	^ uniqueName.

]

{ #category : #all }
InputSpec >> uniqueName: aString [

	uniqueName := aString.

]
