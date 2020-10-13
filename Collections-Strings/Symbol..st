"
I represent Strings that are created uniquely. Thus, someString asSymbol == someString asSymbol.
"
Class {
	#name : #Symbol,
	#superclass : #String,
	#classVars : [
		'NewSymbols',
		'SymbolTable'
	],
	#category : #'Collections-Strings'
}

{ #category : #'class initialization' }
Symbol class >> allSymbolTablesDo: aBlock [
	
	| originalNewSymbols originalSymbolTable |
	originalNewSymbols := NewSymbols.
	originalSymbolTable := SymbolTable.
	originalNewSymbols do: aBlock.
	originalSymbolTable do: aBlock.
]

{ #category : #'class initialization' }
Symbol class >> allSymbolTablesDo: aBlock after: aSymbol [

	| originalNewSymbols originalSymbolTable |
	originalNewSymbols := NewSymbols.
	originalSymbolTable := SymbolTable.
	(originalNewSymbols includes: aSymbol) 
		ifTrue: [
			originalNewSymbols do: aBlock after: aSymbol.
			originalSymbolTable do: aBlock after: aSymbol ]
		ifFalse: [
			originalSymbolTable do: aBlock after: aSymbol.
			originalNewSymbols do: aBlock after: aSymbol ]
	
]

{ #category : #access }
Symbol class >> allSymbols [
	"Answer all interned symbols"
	
	| originalNewSymbols originalSymbolTable |
	originalNewSymbols := NewSymbols.
	originalSymbolTable := SymbolTable.
	^Array
		new: originalNewSymbols slowSize + originalSymbolTable slowSize
		streamContents:[ :stream |
			stream
				nextPutAll: originalNewSymbols;
				nextPutAll: originalSymbolTable ]

]

{ #category : #'class initialization' }
Symbol class >> cleanUp [
	"Flush caches"

	self condenseNewSymbols
]

{ #category : #'class initialization' }
Symbol class >> compactSymbolTable [
	"Reduce the size of the symbol table so that it holds all existing symbols with 25% free space."

	self deprecated: 'Use #condenseNewSymbols instead'.
	self condenseNewSymbols
]

{ #category : #private }
Symbol class >> condenseNewSymbols [
	"Move all symbols from NewSymbols to SymbolTable, and compact SymbolTable."

	| originalNewSymbols originalSymbolTable newNewSymbols newSymbolTable |
	originalNewSymbols := NewSymbols.
	originalSymbolTable := SymbolTable.
	newNewSymbols := WeakSet new.
	newSymbolTable := originalSymbolTable copy
		addAll: originalNewSymbols;
		compact;
		yourself.
	originalNewSymbols == NewSymbols ifFalse: [
		"Some other process has modified the symbols. Try again."
		^self condenseNewSymbols ].
	NewSymbols := newNewSymbols.
	SymbolTable := newSymbolTable
]

{ #category : #'instance creation' }
Symbol class >> empty [
	"A canonicalized empty symbol."
	^ #''
]

{ #category : #'instance creation' }
Symbol class >> findInterned:aString [

	self hasInterned:aString ifTrue:[:symbol| ^symbol].
	^nil.
]

{ #category : #private }
Symbol class >> hasInterned: aString ifTrue: symBlock [ 
	"Answer with false if aString hasnt been interned (into a Symbol),  
	otherwise supply the symbol to symBlock and return true."

	(self lookup: aString)
		ifNil: [ ^false ]
		ifNotNil: [ :symbol |
			symBlock value: symbol.
			^true ]
]

{ #category : #'class initialization' }
Symbol class >> initialize [

	"Symbol initialize"

	Symbol rehash.
	Smalltalk addToShutDownList: self.

]

{ #category : #'instance creation' }
Symbol class >> intern: aStringOrSymbol [ 

	| originalNewSymbols |
	originalNewSymbols := NewSymbols.
	^(self lookup: aStringOrSymbol) ifNil:[
		| aSymbol newNewSymbols |
		aStringOrSymbol isSymbol ifTrue:[
			aSymbol := aStringOrSymbol.
		] ifFalse:[
			aSymbol := (aStringOrSymbol isOctetString ifTrue:[ByteSymbol] ifFalse:[WideSymbol])
							new: aStringOrSymbol size.
			aSymbol string: aStringOrSymbol.
			aSymbol beReadOnlyObject.
		].
		newNewSymbols := originalNewSymbols copyWith: aSymbol.
		originalNewSymbols == NewSymbols
			ifTrue: [
				NewSymbols := newNewSymbols.
				newNewSymbols size > 1000 ifTrue: [ self condenseNewSymbols ].
				aSymbol ]
			ifFalse: [
				"Some other process has modified the symbols. Try again."
				self intern: aStringOrSymbol ] ]
]

{ #category : #'instance creation' }
Symbol class >> lookup: aStringOrSymbol [

	| originalNewSymbols originalSymbolTable |
	originalNewSymbols := NewSymbols.
	originalSymbolTable := SymbolTable.
	^(originalSymbolTable like: aStringOrSymbol) ifNil: [
		 originalNewSymbols like: aStringOrSymbol ]
]

{ #category : #'instance creation' }
Symbol class >> newFrom: aCollection [ 
	"Answer an instance of me containing the same elements as aCollection."

	^ (aCollection as: String) asSymbol

"	Symbol newFrom: {$P. $e. $n}
	{$P. $e. $n} as: Symbol
"
]

{ #category : #private }
Symbol class >> possibleSelectorsFor: misspelled [ 
	"Answer an ordered collection of possible corrections
	for the misspelled selector in order of likelyhood"

	| numArgs candidates lookupString best binary short long first |
	lookupString := misspelled asLowercase. "correct uppercase selectors to lowercase"
	numArgs := lookupString numArgs.
	(numArgs < 0 or: [lookupString size < 2]) ifTrue: [^ OrderedCollection new: 0].
	first := lookupString first.
	short := lookupString size - (lookupString size // 4 max: 3) max: 2.
	long := lookupString size + (lookupString size // 4 max: 3).

	"First assemble candidates for detailed scoring"
	candidates := OrderedCollection new.
	self allSymbolTablesDo: [:s | | ss |
		(((ss := s size) >= short	"not too short"
			and: [ss <= long			"not too long"
					or: [(s at: 1) = first]])	"well, any length OK if starts w/same letter"
			and: [s numArgs = numArgs])	"and numArgs is the same"
			ifTrue: [candidates add: s]].

	"Then further prune these by correctAgainst:"
	best := lookupString correctAgainst: candidates.
	((misspelled last ~~ $:) and: [misspelled size > 1]) ifTrue: [
		binary := misspelled, ':'.		"try for missing colon"
		Symbol hasInterned: binary ifTrue: [:him | best addFirst: him]].
	^ best
]

{ #category : #'instance creation' }
Symbol class >> readFrom: strm [  "Symbol readFromString: '#abc'"

	strm peek = $# ifFalse: [self error: 'Symbols must be introduced by #'].
	^ (Scanner new scan: strm) advance  "Just do what the code scanner does"
]

{ #category : #private }
Symbol class >> rehash [
	"Rebuild the hash table, reclaiming unreferenced Symbols. This method will intern all symbols. You're probably looking for #condenseNewSymbols instead."

	| originalNewSymbols originalSymbolTable newNewSymbols newSymbolTable |
	originalNewSymbols := NewSymbols.
	originalSymbolTable := SymbolTable.
	newNewSymbols := WeakSet new.
	newSymbolTable := WeakSet withAll: self allSubInstances.
	originalNewSymbols == NewSymbols ifFalse: [
		"Some other process has modified the symbols. Try again."
		^self rehash ].
	NewSymbols := newNewSymbols.
	SymbolTable := newSymbolTable
]

{ #category : #access }
Symbol class >> selectorsContaining: aString [
	"Answer a list of selectors that contain aString within them. Case-insensitive. Does return symbols that begin with a capital letter."

	| size selectorList |
	selectorList := OrderedCollection new.
	(size := aString size) = 0 ifTrue: [ ^selectorList ].
	self allSymbolTablesDo: [ :each |
		(each size >= size
			and: [ (each includesSubstring: aString caseSensitive: false) 
			and: [ each numArgs ~= -1 ] ])
				ifTrue: [ selectorList add: each ] ].
	^selectorList

	"Symbol selectorsContaining: 'scon'"
]

{ #category : #access }
Symbol class >> selectorsMatching: aStringPattern [
	"Answer a list of selectors that match aStringPattern within them. Case-insensitive. Does return symbols that begin with a capital letter."

	| selectorList |
	selectorList := OrderedCollection new.
	aStringPattern isEmpty ifTrue: [ ^selectorList ].
	self allSymbolTablesDo: [ :each | 
		((aStringPattern match: each) and: [ each numArgs ~= -1 ])
			ifTrue: [selectorList add: each ] ].
	^selectorList

	"Symbol selectorsMatching: 'parse:*'"
]

{ #category : #private }
Symbol class >> shutDown: aboutToQuit [

	self condenseNewSymbols
]

{ #category : #access }
Symbol class >> thatStarts: leadingCharacters skipping: skipSym [
	"Answer a selector symbol that starts with leadingCharacters.
	Symbols beginning with a lower-case letter handled directly here.
	Ignore case after first char.
	If skipSym is not nil, it is a previous answer; start searching after it.
	If no symbols are found, answer nil.
	Used by Alt-q (Command-q) routines"

	| size firstMatch key |

	size := leadingCharacters size.
	size = 0 ifTrue: [^skipSym ifNil: [#''] ifNotNil: [nil]].

	firstMatch := leadingCharacters at: 1.
	size > 1 ifTrue: [key := leadingCharacters copyFrom: 2 to: size].

	self allSymbolTablesDo: [:each |
			each size >= size ifTrue:
				[
					((each at: 1) == firstMatch and:
						[key == nil or:
							[(each findString: key startingAt: 2 caseSensitive: false) = 2]])
								ifTrue: [^each]
				]
		] after: skipSym.

	^nil

"Symbol thatStarts: 'sf' skipping: nil"
"Symbol thatStarts: 'sf' skipping: #sfpGetFile:with:with:with:with:with:with:with:with:"
"Symbol thatStarts: 'candidate' skipping: nil"

]

{ #category : #access }
Symbol class >> thatStartsCaseSensitive: leadingCharacters skipping: skipSym [
	"Same as thatStarts:skipping: but caseSensitive"
	| size firstMatch key |

	size := leadingCharacters size.
	size = 0 ifTrue: [^skipSym ifNil: [#''] ifNotNil: [nil]].
	firstMatch := leadingCharacters at: 1.
	size > 1 ifTrue: [key := leadingCharacters copyFrom: 2 to: size].
	self allSymbolTablesDo: [:each |
			each size >= size ifTrue:
				[
					((each at: 1) == firstMatch and:
						[key == nil or:
							[(each findString: key startingAt: 2 caseSensitive: true) = 2]])
								ifTrue: [^each]
				]
		] after: skipSym.

	^nil

]

{ #category : #comparing }
Symbol >> = aSymbol [
	"Compare the receiver and aSymbol." 
	self == aSymbol ifTrue: [^ true].
	aSymbol isSymbol ifTrue: [^ false].
	"Use String comparison otherwise"
	^ super = aSymbol
]

{ #category : #'user interface' }
Symbol >> asExplorerString [
	^ self printString
]

{ #category : #converting }
Symbol >> asString [ 
	"Refer to the comment in String|asString."
	| newString |
	newString := self species new: self size.
	newString replaceFrom: 1 to: newString size with: self startingAt: 1.
	^newString
]

{ #category : #converting }
Symbol >> asSymbol [ 
	"Refer to the comment in String|asSymbol."
]

{ #category : #accessing }
Symbol >> at: anInteger put: anObject [ 
	"You cannot modify the receiver."

	self errorNoModification
]

{ #category : #'filter streaming' }
Symbol >> byteEncode:aStream [
	^aStream writeSymbol:self.

]

{ #category : #testing }
Symbol >> canBeToken [
	"Since definition of #tokenish depends on a preference, we want to make sure
	that underscores are always considered tokenish. This is so that selectors created
	when the preference was turned on don't suddenly become invalid when the
	preference is turned off."
	
	^ self allSatisfy: [:c | c = $_ or: [c tokenish]]
]

{ #category : #converting }
Symbol >> capitalized [
	^ self asString capitalized asSymbol
]

{ #category : #copying }
Symbol >> copy [
	"Answer with the receiver, because Symbols are unique."
]

{ #category : #evaluating }
Symbol >> cull: anObject [ 

	^anObject perform: self
]

{ #category : #private }
Symbol >> errorNoModification [

	self error: 'symbols can not be modified.'
]

{ #category : #'system primitives' }
Symbol >> flushCache [
	"Tell the interpreter to remove all entries with this symbol as a selector from its method lookup cache, if it has one.  This primitive must be called whenever a method is defined or removed.
	NOTE:  Only one of the two selective flush methods needs to be used.
	Squeak 2.3 and later uses 116 (See CompiledMethod flushCache)."

	<primitive: 119>

]

{ #category : #testing }
Symbol >> includesKey: sym [
	^self == sym.
]

{ #category : #testing }
Symbol >> isBinary [
	^ self isInfix.
]

{ #category : #testing }
Symbol >> isDoIt [

	^ (self == #DoIt) or: [self == #DoItIn:].
]

{ #category : #testing }
Symbol >> isInfix [
	"Answer whether the receiver is an infix message selector."

	^ self precedence = 2
]

{ #category : #testing }
Symbol >> isKeyword [
	"Answer whether the receiver is a message keyword."

	^ self precedence = 3
]

{ #category : #printing }
Symbol >> isOrientedFill [
	"Needs to be implemented here because symbols can occupy 'color' slots of morphs."

	^ false
]

{ #category : #testing }
Symbol >> isPvtSelector [
	"Answer whether the receiver is a private message selector, that is,
	begins with 'pvt' followed by an uppercase letter, e.g. pvtStringhash."

	^ (self beginsWith: 'pvt') and: [self size >= 4 and: [(self at: 4) isUppercase]]
]

{ #category : #testing }
Symbol >> isSymbol [
	^ true 
]

{ #category : #testing }
Symbol >> isUnary [
	"Answer whether the receiver is an unary message selector."

	^ self precedence = 1
]

{ #category : #'system primitives' }
Symbol >> numArgs: n [
	"Answer a string that can be used as a selector with n arguments.
	 TODO: need to be extended to support shrinking and for selectors like #+ " 

	| numArgs offset |.
	(numArgs := self numArgs) >= n ifTrue: [ ^self ].
	numArgs = 0
		ifTrue: [ offset := 1 ]
		ifFalse: [ offset := 0 ].
	^(String new: n - numArgs + offset * 5 + offset + self size streamContents: [ :stream |
		stream nextPutAll: self.
		numArgs = 0 ifTrue: [ stream nextPut: $:. ].
		numArgs + offset + 1 to: n do: [ :i | stream nextPutAll: 'with:' ] ]) asSymbol
]

{ #category : #accessing }
Symbol >> precedence [
	"Answer the receiver's precedence, assuming it is a valid Smalltalk
	message selector or 0 otherwise.  The numbers are 1 for unary,
	2 for binary and 3 for keyword selectors."

	self size = 0 ifTrue: [ ^ 0 ].
	self first canBeIdentifierInitial ifFalse: [ ^ 2 ].
	self last = $: ifTrue: [ ^ 3 ].
	^ 1
]

{ #category : #accessing }
Symbol >> replaceFrom: start to: stop with: replacement startingAt: repStart [

	self errorNoModification
]

{ #category : #accessing }
Symbol >> selector [
	^ self
]

{ #category : #copying }
Symbol >> shallowCopy [
	"Answer with the receiver, because Symbols are unique."
]

{ #category : #printing }
Symbol >> storeOn: aStream [ 

	aStream nextPut: $#.
	(Scanner isLiteralSymbol: self)
		ifTrue: [aStream nextPutAll: self]
		ifFalse: [super storeOn: aStream]
]

{ #category : #private }
Symbol >> string: aString [

	1 to: aString size do: [:j | super at: j put: (aString at: j)].
	^self  
]

{ #category : #evaluating }
Symbol >> value: anObject [ 
	^anObject perform: self.
]

{ #category : #evaluating }
Symbol >> value: anObject value: anotherObject [

	^anObject perform: self with: anotherObject
]

{ #category : #copying }
Symbol >> veryDeepCopy [
	"Overridden for performance."
	^ self
]

{ #category : #copying }
Symbol >> veryDeepCopyWith: deepCopier [
	"Return self.  I am immutable in the Morphic world.  Do not record me."
]

{ #category : #converting }
Symbol >> withFirstCharacterDownshifted [
	"Answer an object like the receiver but with first character downshifted if necessary"

	^self asString withFirstCharacterDownshifted asSymbol
]
