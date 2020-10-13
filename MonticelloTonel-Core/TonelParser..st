"
I'm a parser for tonel files. 
I parse a class with the following format: 

Tonel spec
====

    [comment]
    type { typeDefinition }
    (
        [{ methodMetadata }]
        method [
            methodBody ] 
    )*


comment
---
""
comment string
""
is optional (but it should be there, in good design ;)

type
---
Class|Trait|Extension

typeDefinition
---
a STON file with class/trait/extension metadata

methodMetadata
---
a STON file with method metadata
is optional (but also, recommended)

method
---
method declaration as this: 

Class[ class] >> selector

methodBody 
---
the method body (we do not parse contents, that's class builder task)
"
Class {
	#name : #TonelParser,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#category : #'MonticelloTonel-Core'
}

{ #category : #'instance creation' }
TonelParser class >> on: aStream [ 
	^ self new 
		stream: aStream;
		yourself
]

{ #category : #parsing }
TonelParser class >> parseStream: aStream [ 
	^ (self on: aStream) start
]

{ #category : #parsing }
TonelParser class >> parseString: aString [ 
	^ self parseStream: aString readStream
]

{ #category : #private }
TonelParser >> cleanSelector: aString [
	"BEWARE: I'm doing some heave assumptions here: I'm removing just ONE space (in case there 
	 is one) because I expect this to be a file generated by tonel, and tonel adds one space 
	 before start with the method body to make the format more readable. 
	 But of course this is not very good :("
	^ (aString last = Character space
		ifTrue: [ aString allButLast ]
		ifFalse: [ aString ]) 
		withoutLeadingBlanks
]

{ #category : #parsing }
TonelParser >> comment [
	^ (TonelCommentScanner on: stream) scan
]

{ #category : #'private factory' }
TonelParser >> definitionForType: aString [ 
	aString = TonelWriter classLabel ifTrue: [ ^ MCClassDefinition ].
	aString = TonelWriter traitLabel ifTrue: [ ^ MCTraitDefinition ].	
	aString = TonelWriter extensionLabel ifTrue: [ ^ nil ].
	
	TonelParseError signal: 'Unknown type declaration.'
]

{ #category : #parsing }
TonelParser >> document [
	^ { 
	self typeDef.
	self methodDefList.
	 } 
	flattened
	select: #notNil
]

{ #category : #private }
TonelParser >> extractSelector: aString [
	| separators selectorStream keywords |
	
	separators := { 
		Character space. 
		Character tab. 
		Character lf. 
		Character newPage. 
		Character cr. 
		$:}.

	keywords := Array new writeStream.
	selectorStream := (self removeComments: aString) readStream.

	[ selectorStream atEnd ]
	whileFalse: [ | word ch |
		word := String new writeStream.
		[ selectorStream atEnd not and: [ (separators includes: (ch := selectorStream next)) not ] ]
		whileTrue: [ word nextPut: ch ].
		ch = $: ifTrue: [ word nextPut: ch ]. 
		word contents withBlanksTrimmed ifNotEmpty: [ :v | keywords nextPut: v ] ].
	keywords := keywords contents.

	^ (keywords size <= 2 
		ifTrue: [ keywords first]
		ifFalse: [ (keywords pairsCollect: [ :keyword :argument | keyword ]) join ])
		asSymbol

]

{ #category : #'private testing' }
TonelParser >> hasStatefulTraits [
	"Pharo has stateful traits starting on version 7"
	
	^ SystemVersion current major >= 7
]

{ #category : #'private testing' }
TonelParser >> isSeparator: aCharacter [ 
	^ aCharacter isSeparator
]

{ #category : #parsing }
TonelParser >> metadata [
	| result ch count |
	
	result := String new writeStream.

	count := 0.
	stream peek = ${ ifFalse: [ TonelParseError signal: 'Can''t parse metadata' ].	
	[ stream atEnd ]
	whileFalse: [ 
		ch := stream next.
		result nextPut: ch.
		ch = ${ ifTrue: [ count := count +1 ].
		ch = $} ifTrue: [ count := count -1 ].
		count = 0 ifTrue: [ ^ STON fromString: result contents ]].

	TonelParseError signal: 'Can''t parse metadata'
]

{ #category : #parsing }
TonelParser >> method [
	| type selector |
	
	type := self untilIncluding: '>>'.
	selector := self cleanSelector: (self untilExcluding: '[').
	type := type withBlanksTrimmed subStrings: ' '.
	type size = 1 ifTrue: [ type := type copyWith: nil ].
	^ { 
		type.
		selector.
	}
]

{ #category : #parsing }
TonelParser >> methodBody [
	"I read a methodbody (what is inside [ ... ])"
	^ (TonelSourceScanner on: stream) scan
		
	
]

{ #category : #parsing }
TonelParser >> methodDef [
	^ self newMethodDefinitionFrom: { 
		self separator.
		self try: [ self metadata ]. 
		self separator. 
		self method. 
		self methodBody 
	}
]

{ #category : #parsing }
TonelParser >> methodDefList [
	| result |
	
	self separator. "to arrive to the end of the file in case there are no methods"
	result := Array new writeStream.
	[ stream atEnd ]
	whileFalse: [ 
		result nextPut: self methodDef.
		"skip possible spaces at the end"
		self separator ].
	
	^ result contents
]

{ #category : #'private factory' }
TonelParser >> newClassDefinitionFrom: anArray [
	| metadata |

	metadata := anArray sixth.
	^ MCClassDefinition
		name: (metadata at: #name)
		superclassName: (metadata at: #superclass)
		traitComposition: (metadata at: #traits ifAbsent: [ '{}' ])
		classTraitComposition: (metadata at: #classTraits ifAbsent: [ '{}' ])
		category: (metadata at: #category)
		instVarNames: (metadata at: #instVars ifAbsent: [ #() ])
		classVarNames: (metadata at: 'classVars' ifAbsent: [ #() ])
		poolDictionaryNames: (metadata at: 'pools' ifAbsent: [ #() ])
		classInstVarNames: (metadata at: 'classInstVars' ifAbsent: [ #() ])
		type: (metadata at: #type ifAbsent: [ #normal ]) asSymbol
		comment: (anArray second ifNil: [ '' ])
		commentStamp: nil
]

{ #category : #'private factory' }
TonelParser >> newMethodDefinitionFrom: anArray [
	| metadata className meta selector source  |
	
	metadata := anArray second ifNil: [ Dictionary new ].
	className := anArray fourth first first.
	meta := anArray fourth first second notNil.
	selector := self extractSelector: anArray fourth second withBlanksTrimmed.
	source := String streamContents: [ :s | 
		s << anArray fourth second.
		anArray fifth ifNotEmpty: [ :src | s << src ] ].
	
	^ MCMethodDefinition
		className: className
		classIsMeta: meta
		selector: selector
		category: (metadata at: #category ifAbsent: [ '' ]) 
		timeStamp: nil
		source: source
]

{ #category : #'private factory' }
TonelParser >> newStatefulTraitDefinitionFrom: anArray [
	| metadata |
	
	metadata := anArray sixth.
	^ MCTraitDefinition
			name: (metadata at: #name)
			traitComposition: (metadata at: #traits ifAbsent: [ '{}' ])
			category: (metadata at: #category)
			instVarNames: (metadata at: #instVars ifAbsent: [ #() ])
			classInstVarNames: (metadata at: #classInstVars ifAbsent: [ #() ])
			comment: (anArray second ifNil: [ '' ])
			commentStamp: nil
]

{ #category : #'private factory' }
TonelParser >> newStatelessTraitDefinitionFrom: anArray [
	| metadata |
	
	metadata := anArray sixth.
	
	self validateStatelessTraitIsBeingRead: metadata.
	
	^ MCTraitDefinition
			name: (metadata at: #name)
			traitComposition: (metadata at: #traits ifAbsent: [ '{}' ])
			category: (metadata at: #category)
			comment: (anArray second ifNil: [ '' ])
			commentStamp: nil
]

{ #category : #'private factory' }
TonelParser >> newTraitDefinitionFrom: anArray [
	| metadata traitDefs |
	
	metadata := anArray sixth.
	traitDefs := { 
		self hasStatefulTraits 
			ifTrue: [ self newStatefulTraitDefinitionFrom: anArray ]
			ifFalse: [ self newStatelessTraitDefinitionFrom: anArray ] }.
			
	metadata 
		at: #classTraits
		ifPresent: [ :classTraits |
			traitDefs := traitDefs copyWith: (MCClassTraitDefinition
 				baseTraitName: (metadata at: #name)
 				classTraitComposition: classTraits
				category: (metadata at: #category)) ].
			
	^ traitDefs
]

{ #category : #'private factory' }
TonelParser >> newTypeDefinitionFrom: anArray [
	| typeClass |
	
	typeClass := self definitionForType: anArray fourth.
	typeClass = MCClassDefinition ifTrue: [ ^ self newClassDefinitionFrom: anArray ].
	typeClass = MCTraitDefinition ifTrue: [ ^ self newTraitDefinitionFrom: anArray ].	
	"is extension, no type"
	^ nil
]

{ #category : #private }
TonelParser >> removeComments: original [
	| newStream readStream inComment |
	
	newStream := original copy writeStream.
	readStream := original readStream.
	inComment := false.
	
	[ readStream atEnd ] whileFalse: [ | ch |
		
		ch := readStream next.
		
		(ch = $") ifTrue:[
			inComment := inComment not.
			ch := readStream next.
		].
		
		(inComment or:[ ch isNil]) ifFalse: [ newStream nextPut: ch	 ]
	].
	
	^ newStream contents
]

{ #category : #parsing }
TonelParser >> separator [
	[ stream atEnd not and: [ self isSeparator: stream peek ] ]
	whileTrue: [ stream next ].
	^ nil
]

{ #category : #accessing }
TonelParser >> start [
	^ self document
]

{ #category : #accessing }
TonelParser >> stream: aStream [ 
	stream := aStream
]

{ #category : #'private parsing' }
TonelParser >> try: aBlock [
	^ self 
		try: aBlock 
		onSuccess: [ :parsedValue | parsedValue ] 
		onFailure: [ nil ]
]

{ #category : #'private parsing' }
TonelParser >> try: aBlock onFailure: failureBlock [
	^ self 
		try: aBlock 
		onSuccess: [ :parsedValue |  parsedValue ] 
		onFailure: failureBlock
]

{ #category : #'private parsing' }
TonelParser >> try: aBlock onSuccess: successBlock [
	^ self 
		try: aBlock 
		onSuccess: successBlock 
		onFailure: [ nil ]
]

{ #category : #'private parsing' }
TonelParser >> try: aBlock onSuccess: successBlock onFailure: failureBlock [
	| pos |
	
	pos := stream position.
	[ ^ successBlock value: aBlock value ]
	on: TonelParseError 
	do: [ :e | 
		stream position: pos.
		^ failureBlock value ]. 
	
]

{ #category : #parsing }
TonelParser >> type [
	self try: [ self word: 'Class' ] onSuccess: [ :word | ^ word  ].
	self try: [ self word: 'Trait' ] onSuccess: [ :word | ^ word  ].
	self try: [ self word: 'Extension' ] onSuccess: [ :word | ^ word  ].
	
	"at end"
	TonelParseError signal: 'Can''t parse type.'	

]

{ #category : #parsing }
TonelParser >> typeDef [
	^ self newTypeDefinitionFrom: { 
		self separator.
		self try: [ self comment ]. 
		self separator. 
		self type. 
		self separator. 
		self try: [ self metadata ] 
	} 
	
		
]

{ #category : #'private parsing' }
TonelParser >> untilExcluding: aCollection [
	| result |
	result := stream upToAll: aCollection.
	stream position: stream position - aCollection size.
	^ result
]

{ #category : #'private parsing' }
TonelParser >> untilIncluding: aCollection [
	^ stream upToAll: aCollection
]

{ #category : #private }
TonelParser >> validateStatelessTraitIsBeingRead: metadata [
	| vars |
	
	vars := Set new.
	vars 
		addAll: (metadata at: #instVars ifAbsent: [ #() ]);
		addAll: (metadata at: #classInstVars ifAbsent: [ #() ]).
	
	vars ifNotEmpty: [ 
		self error: 'Trying to load a stateful trait in a stateless version.' ]
]

{ #category : #'private parsing' }
TonelParser >> word: aString [
	| result |
	result := stream next: aString size.
	result = aString
		ifFalse: [ TonelParseError signal: 'Can''t parse ', aString ].
	^ result
]