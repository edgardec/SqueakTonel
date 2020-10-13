Class {
	#name : #MethodPragmaTest,
	#superclass : #TestCase,
	#category : #'KernelTests-Methods'
}

{ #category : #utilities }
MethodPragmaTest >> assertPragma: aString givesKeyword: aSymbol arguments: anArray [
	| pragma decompiled pragmaString index |
	pragma := self pragma: aString selector: #zork.
	self assert: aSymbol equals: pragma keyword.
	self assert: anArray equals: pragma arguments.
	decompiled := (self class>>#zork) decompile.
	self assert: (decompiled properties pragmas includes: pragma).
	pragmaString := pragma printString.
	"Pragma printString may contain a comment; if so, delete it"
	(index := pragmaString indexOfSubCollection: '> "in ') > 0 ifTrue:
		[pragmaString := pragmaString copyFrom: 1 to: index].
	self assert: (decompiled printString includesSubstring: pragmaString)
]

{ #category : #utilities }
MethodPragmaTest >> compile: aString selector: aSelector [
	self class 
		compileSilently: aSelector , String lf , aString
		classified: self methodCategory.
	^ self class >> aSelector.
]

{ #category : #utilities }
MethodPragmaTest >> methodCategory [
	^ #generated
]

{ #category : #utilities }
MethodPragmaTest >> pragma: aString selector: aSelector [
	^ (self compile: '<' , aString , '>' selector: aSelector)
		pragmas first.
]

{ #category : #utilities }
MethodPragmaTest >> pragma: aSymbol selector: aSelector times: anInteger [
	^ (self 
		compile: (String streamContents: [ :stream | 
			(1 to: anInteger) asArray shuffled do: [ :each | 
				stream 
					nextPut: $<; nextPutAll: aSymbol; space;
					print: each; nextPut: $>; cr ] ])
		selector: aSelector)
			pragmas.
]

{ #category : #running }
MethodPragmaTest >> tearDown [
	(self class organization listAtCategoryNamed: self methodCategory)
		do: [ :each | self class removeSelectorSilently: each ].
	self class organization removeCategory: self methodCategory.
]

{ #category : #'tests-finding' }
MethodPragmaTest >> testAllNamedFromTo [
	| pragmasCompiled pragmasDetected |
	pragmasCompiled := self pragma: #foo: selector: #bar times: 5.
	pragmasDetected := Pragma allNamed: #foo: from: self class to: Object.
	self assert: pragmasDetected = pragmasCompiled.
	
	pragmasDetected := Pragma allNamed: #foo: from: Object to: Object.
	self assert: pragmasDetected isEmpty.
]

{ #category : #'tests-finding' }
MethodPragmaTest >> testAllNamedFromToSortedByArgument [
	| pragmasCompiled pragmasDetected |
	pragmasCompiled := self pragma: #foo: selector: #bar times: 5.
	pragmasDetected := Pragma allNamed: #foo: from: self class to: Object sortedByArgument: 1.
	self assert: pragmasDetected = (pragmasCompiled 
		sort: [ :a :b | (a argumentAt: 1) < (b argumentAt: 1) ])
]

{ #category : #'tests-finding' }
MethodPragmaTest >> testAllNamedFromToSortedUsing [
	| pragmasCompiled pragmasDetected |
	pragmasCompiled := self pragma: #foo: selector: #bar times: 5.
	pragmasDetected := Pragma 
		allNamed: #foo: from: self class to: Object 
		sortedUsing: [ :a :b | (a argumentAt: 1) > (b argumentAt: 1) ].
	self assert: pragmasDetected = (pragmasCompiled 
		sort: [ :a :b | (a argumentAt: 1) > (b argumentAt: 1) ]).
]

{ #category : #'tests-finding' }
MethodPragmaTest >> testAllNamedIn [
	| pragmasCompiled pragmasDetected |
	pragmasCompiled := self pragma: #foo: selector: #bar times: 5.
	pragmasDetected := Pragma allNamed: #foo: in: self class.
	self assert: pragmasDetected = pragmasCompiled.
	
	pragmasDetected := Pragma allNamed: #foo: in: Object.
	self assert: pragmasDetected isEmpty.
]

{ #category : #'tests-finding' }
MethodPragmaTest >> testAllNamedInSortedByArgument [
	| pragmasCompiled pragmasDetected |
	pragmasCompiled := self pragma: #foo: selector: #bar times: 5.
	pragmasDetected := Pragma allNamed: #foo: in: self class sortedByArgument: 1.
	self assert: pragmasDetected = (pragmasCompiled 
		sort: [ :a :b | (a argumentAt: 1) < (b argumentAt: 1) ])
]

{ #category : #'tests-finding' }
MethodPragmaTest >> testAllNamedInSortedUsing [
	| pragmasCompiled pragmasDetected |
	pragmasCompiled := self pragma: #foo: selector: #bar times: 5.
	pragmasDetected := Pragma 
		allNamed: #foo: in: self class 
		sortedUsing: [ :a :b | (a argumentAt: 1) > (b argumentAt: 1) ].
	self assert: pragmasDetected = (pragmasCompiled 
		sort: [ :a :b | (a argumentAt: 1) > (b argumentAt: 1) ]).
]

{ #category : #'tests-pragma' }
MethodPragmaTest >> testArguments [
	| pragma |
	pragma := Pragma keyword: #foo: arguments: #( 123 ).
	self assert: pragma arguments = #( 123 ).
]

{ #category : #'tests-compiler' }
MethodPragmaTest >> testCompileArray [
	self assertPragma: 'foo: #()' givesKeyword: #foo: arguments: #( () ).
	self assertPragma: 'foo: #( foo )' givesKeyword: #foo: arguments: #( ( foo ) ).
	self assertPragma: 'foo: #( foo: )' givesKeyword: #foo: arguments: #( ( foo: ) ).
	self assertPragma: 'foo: #( 12 )' givesKeyword: #foo: arguments: #( ( 12 ) ).
	self assertPragma: 'foo: #( true )' givesKeyword: #foo: arguments: #( ( true ) ).
	
]

{ #category : #'tests-compiler' }
MethodPragmaTest >> testCompileBinary [
	self assertPragma: ' = 1' givesKeyword: #= arguments: #( 1 ).
	self assertPragma: ' , 3' givesKeyword: #, arguments: #( 3 ).
	self assertPragma: ' > 4' givesKeyword: #> arguments: #( 4 ).
	self assertPragma: ' < 5' givesKeyword: #< arguments: #( 5 ).

	self assertPragma: ' == 1' givesKeyword: #== arguments: #( 1 ).
	self assertPragma: ' <> 3' givesKeyword: #<> arguments: #( 3 ).
	self assertPragma: ' >< 4' givesKeyword: #>< arguments: #( 4 ).
	self assertPragma: ' ** 5' givesKeyword: #** arguments: #( 5 )
]

{ #category : #'tests-compiler' }
MethodPragmaTest >> testCompileCharacter [
	self assertPragma: 'foo: $a' givesKeyword: #foo: arguments: #( $a ).
	self assertPragma: 'foo: $ ' givesKeyword: #foo: arguments: { Character space }.
]

{ #category : #'tests-compiler' }
MethodPragmaTest >> testCompileEmpty [
	self assertPragma: 'foo' givesKeyword: #foo arguments: #().
]

{ #category : #'tests-compiler' }
MethodPragmaTest >> testCompileFull [
	self assertPragma: 'foo: 1' givesKeyword: #foo: arguments: #( 1 ).
	self assertPragma: 'foo: 1 bar: 2' givesKeyword: #foo:bar: arguments: #( 1 2 ).
]

{ #category : #'tests-compiler' }
MethodPragmaTest >> testCompileInvalid [
	"Invalid pragmas should properly raise an error."

	self should: [ self compile: '<>' selector: #zork ] raise: SyntaxErrorNotification.
	self should: [ self compile: '<1>' selector: #zork ] raise: SyntaxErrorNotification.	
	self should: [ self compile: '<#123>' selector: #zork ] raise: SyntaxErrorNotification.
	
	self should: [ self compile: '<foo bar>' selector: #zork ] raise: SyntaxErrorNotification.
	self should: [ self compile: '<foo 1>' selector: #zork ] raise: SyntaxErrorNotification.
	self should: [ self compile: '<foo bar zork>' selector: #zork ] raise: SyntaxErrorNotification.
	self should: [ self compile: '<foo bar 1>' selector: #zork ] raise: SyntaxErrorNotification.
	
	self should: [ self compile: '<foo: bar:>' selector: #zork ] raise: SyntaxErrorNotification.
	self should: [ self compile: '<foo: #bar: zork:>' selector: #zork ] raise: SyntaxErrorNotification.
	
	self should: [ self compile: '<<1>' selector: #zork ] raise: SyntaxErrorNotification.
	self should: [ self compile: '<=2>' selector: #zork ] raise: SyntaxErrorNotification.

	self should: [ self compile: '< =1 = >' selector: #zork ] raise: SyntaxErrorNotification.
	self should: [ self compile: '< =1 =2 >' selector: #zork ] raise: SyntaxErrorNotification.
	
	self should: [ self compile: '<foo: String>' selector: #zork ] raise: SyntaxErrorNotification.
	self should: [ self compile: '<foo: Pragma>' selector: #zork ] raise: SyntaxErrorNotification
]

{ #category : #'tests-compiler' }
MethodPragmaTest >> testCompileNumber [
	self assertPragma: 'foo: 123' givesKeyword: #foo: arguments: #( 123 ).
	self assertPragma: 'foo: -123' givesKeyword: #foo: arguments: #( -123 ).
	self assertPragma: 'foo: 12.3' givesKeyword: #foo: arguments: #( 12.3 ).
	self assertPragma: 'foo: -12.3' givesKeyword: #foo: arguments: #( -12.3 ).
]

{ #category : #'tests-compiler' }
MethodPragmaTest >> testCompileString [
	self assertPragma: 'foo: ''''' givesKeyword: #foo: arguments: #( '' ).
	self assertPragma: 'foo: ''bar''' givesKeyword: #foo: arguments: #( 'bar' ).
]

{ #category : #'tests-compiler' }
MethodPragmaTest >> testCompileSymbol [
	self assertPragma: 'foo: #bar' givesKeyword: #foo: arguments: #( bar ).
	self assertPragma: 'foo: #bar:' givesKeyword: #foo: arguments: #( bar: ).
	self assertPragma: 'foo: #bar:zork:' givesKeyword: #foo: arguments: #( bar:zork: ).
]

{ #category : #'tests-compiler' }
MethodPragmaTest >> testCompileTemps [
	"Pragmas should be placeable before and after temps."
	
	self 
		shouldnt: [
			self assert: (self compile: '| temps | <foo>' selector: #zork) 
				pragmas notEmpty ]
		raise: SyntaxErrorNotification.
	self 
		shouldnt: [
			self assert: (self compile: '<foo> | temps |' selector: #zork) 
				pragmas notEmpty ]
		raise: SyntaxErrorNotification.
]

{ #category : #'tests-compiler' }
MethodPragmaTest >> testCompileValue [
	self assertPragma: 'foo: true' givesKeyword: #foo: arguments: #( true ).
	self assertPragma: 'foo: false' givesKeyword: #foo: arguments: #( false ).
	self assertPragma: 'foo: nil' givesKeyword: #foo: arguments: #( nil )
]

{ #category : #'tests-pragma' }
MethodPragmaTest >> testKeyword [
	| pragma |
	pragma := Pragma keyword: #foo: arguments: #( 123 ).
	self assert: pragma keyword = #foo:.
]

{ #category : #'tests-pragma' }
MethodPragmaTest >> testMessage [
	| pragma message |
	pragma := Pragma keyword: #foo: arguments: #( 123 ).
	message := pragma message.
	
	self assert: message selector = #foo:.
	self assert: message arguments = #( 123 ).
]

{ #category : #'tests-method' }
MethodPragmaTest >> testMethod [
	| pragma |
	pragma := self pragma: 'foo' selector: #bar.
	self assert: pragma method == (self class >> #bar).
]

{ #category : #'tests-method' }
MethodPragmaTest >> testMethodClass [
	| pragma |
	pragma := self pragma: 'foo' selector: #bar.
	self assert: pragma methodClass == self class.
]

{ #category : #'tests-compiled' }
MethodPragmaTest >> testNoPragma [
	| method |
	method := self compile: '' selector: #foo.
	self assert: method pragmas = #().
]

{ #category : #'tests-primitives' }
MethodPragmaTest >> testPrimitiveIndexed1 [
	"This test useses the #instVarAt: primitive."
	
	self compile: '<primitive: 74> ^ #inst' selector: #inst.
	self assert: self inst = #inst.
]

{ #category : #'tests-primitives' }
MethodPragmaTest >> testPrimitiveIndexed2 [
	"This test useses the #asOop primitive."

	self compile: '<primitive: 75> ^ #oop' selector: #oop.
	self assert: self oop = self asOop.
]

{ #category : #'tests-primitives' }
MethodPragmaTest >> testPrimitiveNamed1 [
	"This test useses the #primitiveDirectoryLookup primitive."

	self compile: '<primitive: ''primitiveDirectoryLookup'' module: ''FilePlugin''> ^ #lookup' selector: #lookup.
	self assert: self lookup = #lookup.
	

]

{ #category : #'tests-primitives' }
MethodPragmaTest >> testPrimitiveNamed2 [
	"This test useses the #primPathNameDelimiter primitive."

	self compile: '<primitive: ''primitiveDirectoryDelimitor'' module: ''FilePlugin''> ^ #delim' selector: #delim.
	self assert: self delim = FileDirectory primPathNameDelimiter.
	

]

{ #category : #'tests-printing-reformating' }
MethodPragmaTest >> testReformat [
	self assert: (DisplayScreen class compiledMethodAt: #actualScreenDepth) getSource string = 'actualScreenDepth
	<primitive: ''primitiveScreenDepth''>
	^ Display depth'.

	self assert: (DisplayScreen class compiledMethodAt: #actualScreenDepth) getSource string = 'actualScreenDepth
	<primitive: ''primitiveScreenDepth''>
	^ Display depth'.	

]

{ #category : #'tests-method' }
MethodPragmaTest >> testSelector [
	| pragma |
	pragma := self pragma: 'foo' selector: #bar.
	self assert: pragma selector == #bar.
]
