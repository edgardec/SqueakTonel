"
See PDA comment. 
"
Class {
	#name : #PDARecord,
	#superclass : #Object,
	#instVars : [
		'key',
		'description',
		'otherFields'
	],
	#category : #'Etoys-Squeakland-Morphic-PDA'
}

{ #category : #comparing }
PDARecord >> <= other [

	^ (description compare: other description) <= 2  "Case-insensitive"
]

{ #category : #'as text' }
PDARecord >> allFieldsWithValuesDo: nameValueBlock [

	self sharedFieldsWithValuesDo: nameValueBlock.
	otherFields ifNotNil:
		[otherFields associationsDo:
			[:assn | nameValueBlock value: assn key value: assn value]]
]

{ #category : #'as text' }
PDARecord >> asListItem [

	^ description copyUpTo: Character cr
]

{ #category : #'as text' }
PDARecord >> asText [

	^ String streamContents:
		[:s | self allFieldsWithValuesDo:
			[:field :value | s nextPutAll: field; nextPutAll: ': '; store: value; cr]]
]

{ #category : #description }
PDARecord >> description [
	"Return the value of description"
	^ description
]

{ #category : #description }
PDARecord >> description: newValue [
	"Assign newValue to description."

	description := newValue.
]

{ #category : #key }
PDARecord >> key [
	"Return the value of key"
	^ key
]

{ #category : #key }
PDARecord >> key: newValue [
	"Assign newValue to key."

	key := newValue.
]

{ #category : #key }
PDARecord >> matchesKey: aString [

	key ifNil: [^ true].  "unkeyed items show up as 'all' "
	(aString = 'all' or: [key = 'all']) ifTrue: [^ true].
	^ key = aString
]

{ #category : #key }
PDARecord >> matchesKey: aString andMatchesDate: aDate [
	"May be overridden for efficiency"
	^ (self matchesKey: aString) and: [self matchesDate: aDate]
]

{ #category : #'other fields' }
PDARecord >> otherFields [
	"Return the value of otherFields"
	^ otherFields
]

{ #category : #'other fields' }
PDARecord >> otherFields: newValue [
	"Assign newValue to otherFields."

	otherFields := newValue.
]

{ #category : #printing }
PDARecord >> printOn: aStream [

	super printOn: aStream.
	aStream space; nextPutAll: self asListItem
]

{ #category : #'as text' }
PDARecord >> readField: fieldName fromString: aString fields: sharedFields base: instVarBase [
	"This message should be overridden in subclasses to recognize the types for the various fields.  If a fieldName is not recognized below, super will invoke this method at the end."

	(sharedFields includes: fieldName) ifTrue:
		[^ self instVarAt: instVarBase + (sharedFields indexOf: fieldName)
				put: (Compiler evaluate: aString)].

	otherFields ifNil: [otherFields := Dictionary new].
	otherFields at: fieldName put: (Compiler evaluate: aString)

]

{ #category : #'as text' }
PDARecord >> readFrom: aText [
	| buffer tokenStream fieldName token |
	tokenStream := ReadStream on: (Scanner new scanTokens: aText asString).
	buffer := WriteStream on: (String new: 500).
	fieldName := nil.
	self sharedFieldsWithBaseDo:
		[:fields :instVarBase |  
		[tokenStream atEnd] whileFalse:
			[token := tokenStream next.
			((token isSymbol) and: [token endsWith: ':'])
				ifTrue: [fieldName ifNotNil:
							[self readField: fieldName fromString: buffer contents
								fields: fields base: instVarBase].
						buffer reset.  fieldName := token allButLast]
				ifFalse: [(token isSymbol)
							ifTrue: [buffer nextPutAll: token; space]
							ifFalse: [buffer print: token; space]]].
		self readField: fieldName fromString: buffer contents
			fields: fields base: instVarBase]
]

{ #category : #key }
PDARecord >> rekey: oldKey to: newKey [

	key = oldKey ifTrue: [key := newKey]
]

{ #category : #'as text' }
PDARecord >> sharedFieldsWithBaseDo: fieldsAndBaseBlock [

	| fields base |
	fields := self class allInstVarNames allButFirst: (base := PDARecord superclass instSize).
	fieldsAndBaseBlock value: fields value: base
]

{ #category : #'as text' }
PDARecord >> sharedFieldsWithValuesDo: nameValueBlock [

	self sharedFieldsWithBaseDo:
		[:fields :instVarBase |
		fields withIndexDo:
			[:field :i | field = 'otherFields' ifFalse:
				[nameValueBlock value: field value: (self instVarAt: instVarBase + i)]]]
]
