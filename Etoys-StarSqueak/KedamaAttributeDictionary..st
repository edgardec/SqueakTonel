Class {
	#name : #KedamaAttributeDictionary,
	#superclass : #Object,
	#instVars : [
		'dictionaries'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #all }
KedamaAttributeDictionary >> getAttribute: aSymbol of: anObject [

	| attributes |
	attributes := dictionaries at: anObject ifAbsent: [^ nil].
	^ attributes at: aSymbol ifAbsent: [nil].

]

{ #category : #all }
KedamaAttributeDictionary >> initialize [

	dictionaries := IdentityDictionary new.

]

{ #category : #all }
KedamaAttributeDictionary >> setAttribute: aSymbol of: anObject to: value [

	| attributes |
	attributes := dictionaries at: anObject ifAbsentPut: [IdentityDictionary new].
	attributes at: aSymbol put: value.


]
