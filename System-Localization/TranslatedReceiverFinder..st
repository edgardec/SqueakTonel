Class {
	#name : #TranslatedReceiverFinder,
	#superclass : #Object,
	#category : #'System-Localization'
}

{ #category : #utilities }
TranslatedReceiverFinder class >> browseNonLiteralReceivers [
	"TranslatedReceiverFinder browseNonLiteralReceivers"
	SystemNavigation default
		browseMessageList: self new nonLiteralReceivers
		name: 'Non literal receivers of #translated'
		autoSelect: 'translated'
]

{ #category : #'japanese locale' }
TranslatedReceiverFinder class >> makeJapaneseTranslationFile [
	| t n |
	NaturalLanguageTranslator initializeKnownPhrases.
	t := TranslatedReceiverFinder new senders.
	n := NaturalLanguageTranslator
				localeID: (LocaleID isoLanguage: 'ja').
	t
		do: [:w | 
			NaturalLanguageTranslator registerPhrase: w.
			self
				at: w
				ifPresent: [:k | n phrase: w translation: k]].
	n saveToFileNamed: 'ja.translation'
]

{ #category : #private }
TranslatedReceiverFinder >> arraySearch: aSymbol fromArray: anArray addTo: aCollection [ 
	"Find literals ahead of aSymbol from arrays in the method."
	"BUG: it can handle just one occurrence"
	"self new arraySearch: #hello fromArray: #(ignore (ignore detected
	hello ignore)) addTo: Set new"
	| index |
	(index := anArray identityIndexOf: aSymbol) > 1
		ifTrue: [aCollection add: (anArray at: index - 1) asString].
	(anArray
		select: [:each | each isMemberOf: Array])
		do: [:each | self
				arraySearch: aSymbol
				fromArray: each
				addTo: aCollection].
	^ aCollection
]

{ #category : #private }
TranslatedReceiverFinder >> arraySearch: aSymbol messageNode: aParseNode addTo: aCollection [ 
	"Find literals ahead of aSymbol from arrays in the method."
	"self new arraySearch: #hello messageNode: (self
	decompile: #arraySearch:messageNode:addTo:) addTo: Set new"
	self flag: #(#ignore #detected #hello ).
	((aParseNode isMemberOf: LiteralNode)
			and: [aParseNode key isMemberOf: Array])
		ifTrue: [self
				arraySearch: aSymbol
				fromArray: aParseNode key
				addTo: aCollection].
	(aParseNode notNil
			and: [aParseNode isLeaf not])
		ifTrue: [aParseNode getAllChildren
				do: [:child | self
						arraySearch: aSymbol
						messageNode: child
						addTo: aCollection]].
	^ aCollection
]

{ #category : #accessing }
TranslatedReceiverFinder >> findWordsWith: aSymbol in: aMethodReference [ 
	"Find words for translation with the symbol in a method. See
	LanguageEditorTest >>testFindTranslatedWords"
	"| message | 
	message := MethodReference new setStandardClass: Morph class
	methodSymbol: #supplementaryPartsDescriptions.
	self new findWordsWIth: #translatedNoop in: message"
	| messages keywords aParseNode |
	aParseNode := aMethodReference decompile.
	"Find from string literal"
	messages := Set new.
	self
		search: aSymbol
		messageNode: aParseNode
		addTo: messages.
	keywords := OrderedCollection new.
	messages
		select: [:aMessageNode | aMessageNode receiver isMemberOf: LiteralNode]
		thenDo: [:aMessageNode | aMessageNode receiver key
				literalStringsDo: [:literal | keywords add: literal]].
	"Find from array literal"
	self
		arraySearch: aSymbol
		messageNode: aParseNode
		addTo: keywords.
	^ keywords
]

{ #category : #accessing }
TranslatedReceiverFinder >> nonLiteralReceivers [
	"self new nonLiteralReceivers"
	| receivers |
	"Answer method references of non literal senders of #translated"
	^ (SystemNavigation default allCallsOn: #translated)
		select: [:message | 
			receivers := OrderedCollection new.
			self search: #translated messageNode: message decompile addTo: receivers.
			receivers
				anySatisfy: [:each | (each receiver isMemberOf: LiteralNode) not]]
]

{ #category : #private }
TranslatedReceiverFinder >> search: aSymbol messageNode: aParseNode addTo: aCollection [ 
	"self new search: #translated messageNode: (Project decompile: #updateLocaleDependentsWithPreviousSupplies:gently:) addTo: OrderedCollection new"

	((aParseNode isMemberOf: MessageNode)
			and: [(aParseNode selector isMemberOf: SelectorNode)
					and: [aParseNode selector key = aSymbol]])
		ifTrue: [aCollection add: aParseNode].
	(aParseNode notNil
			and: [aParseNode isLeaf not])
		ifTrue: [aParseNode getAllChildren
				do: [:child | self
						search: aSymbol
						messageNode: child
						addTo: aCollection]].
	^ aCollection
]

{ #category : #'as yet unclassified' }
TranslatedReceiverFinder >> searchBlockNode: aBlockNode addTo: aCollection [

	aBlockNode statements do: [:e |
		(e isMemberOf: MessageNode) ifTrue: [self searchMessageNode: e addTo: aCollection].
		(e isMemberOf: ReturnNode) ifTrue: [self searchReturnNode: e addTo: aCollection].
	].

]

{ #category : #'as yet unclassified' }
TranslatedReceiverFinder >> searchMessageNode: aMessageNode addTo: aCollection [

	((aMessageNode receiver isMemberOf: LiteralNode) and: [(aMessageNode selector isMemberOf: SelectorNode) and: [aMessageNode selector key = #translated]]) ifTrue: [
		aCollection add: aMessageNode receiver key.
	].

	(aMessageNode receiver isMemberOf: BlockNode) ifTrue: [self searchBlockNode: aMessageNode receiver addTo: aCollection].
	(aMessageNode receiver isMemberOf: MessageNode) ifTrue: [self searchMessageNode: aMessageNode receiver addTo: aCollection].
	(aMessageNode receiver isMemberOf: ReturnNode) ifTrue: [self searchReturnNode: aMessageNode receiver addTo: aCollection].

	aMessageNode arguments do: [:a |
		(a isMemberOf: BlockNode) ifTrue: [self searchBlockNode: a addTo: aCollection].
		(a isMemberOf: MessageNode) ifTrue: [self searchMessageNode: a addTo: aCollection].
		(a isMemberOf: ReturnNode) ifTrue: [self searchReturnNode: a addTo: aCollection].
	].

]

{ #category : #'as yet unclassified' }
TranslatedReceiverFinder >> searchMethodNode: aMethodNode addTo: aCollection [

	(aMethodNode block isMemberOf: BlockNode) ifTrue: [self searchBlockNode: aMethodNode block addTo: aCollection].
	(aMethodNode block isMemberOf: MessageNode) ifTrue: [self searchMessageNode: aMethodNode block addTo: aCollection].
	(aMethodNode block isMemberOf: ReturnNode) ifTrue: [self searchReturnNode: aMethodNode block addTo: aCollection].

]

{ #category : #'as yet unclassified' }
TranslatedReceiverFinder >> searchReturnNode: aReturnNode addTo: aCollection [

	(aReturnNode expr isMemberOf: BlockNode) ifTrue: [self searchBlockNode: aReturnNode expr addTo: aCollection].
	(aReturnNode expr isMemberOf: MessageNode) ifTrue: [self searchMessageNode: aReturnNode expr addTo: aCollection].

]

{ #category : #'as yet unclassified' }
TranslatedReceiverFinder >> senders [

	| m o |
	m := SystemNavigation default allCallsOn: #translated.
	m := m collect: [:e |
		e classIsMeta ifTrue: [
			(Smalltalk at: e classSymbol) class decompile: e methodSymbol.
		] ifFalse: [
			(Smalltalk at: e classSymbol) decompile: e methodSymbol.
		]
	].

	o := OrderedCollection new.
	m do: [:e | self searchMethodNode: e addTo: o].
	^ o sort

]

{ #category : #accessing }
TranslatedReceiverFinder >> stringReceivers [
	"TranslatedReceiverFinder new stringReceivers"
	| stringReceivers messages |
	messages := Set new.
	(SystemNavigation default allCallsOn: #translated)
		do: [:message | self search: #translated messageNode: message decompile addTo: messages].
	stringReceivers := messages
				select: [:each | each receiver isMemberOf: LiteralNode]
				thenCollect: [:each | each receiver key].
	^ stringReceivers asArray sort
]

{ #category : #accessing }
TranslatedReceiverFinder >> stringReceiversWithContext [
	| mrs results rr cls mn t o |
	mrs := SystemNavigation default allCallsOn: #translated.
	results := OrderedCollection new.
	mrs do: [:mr |
		rr := OrderedCollection new.
		cls := Smalltalk at: mr classSymbol.
		rr add: cls category.
		rr add: mr classSymbol.
		rr add: mr methodSymbol.
		mr classIsMeta ifTrue: [
			mn :=  cls class decompile: mr methodSymbol.
		] ifFalse: [
			mn := cls decompile: mr methodSymbol.
		].
		o := OrderedCollection new.
		t := Set new.
		self searchMessageNode: mn addTo: t.
		t do: [ :te |
			(te receiver isMemberOf: LiteralNode) ifTrue: [ 
			    o add: te receiver key.
			].
		].
		o ifNotEmpty: [
			rr add: o.
			results add: rr.
		].
	].
	^ results.


]

{ #category : #accessing }
TranslatedReceiverFinder >> stringReceiversWithContext: aSymbol [
	"Find string receivers for a symbol.
	Answer a collection of aMethodReference -> {keyword. keyword...}"
	"self new stringReceiversWithContext: #translated"
	| keywords methodReferences |
	methodReferences := SystemNavigation default allCallsOn: aSymbol.
	^ methodReferences inject: OrderedCollection new into: [:list :next |
		keywords := self findWordsWith: aSymbol in: next.
		keywords
			ifNotEmpty: [list add: next -> keywords].
		list]

]
