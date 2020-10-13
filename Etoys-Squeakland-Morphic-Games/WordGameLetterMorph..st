"
WordGameLetterMorph implements letter boxes for type-in and display of letter in word games.  Several variant displays are supported, depending on the setting of style, and blanks can be displayed as black boxes or empty letter boxes.

Default support for type-in is distributed between this class and WordGamePaneMorph

letter			the Character stored in this morph.
				Can be either blank or nil as well as a letter.
indexInQuote	a retained copy of the index of this character
				Facilitates responses to, eg, clicking or typing in this box.
				If indexInQuote==nil, then this is displayed as a black box
predecessor		another LetterMorph or nil
				Used for linked typing and, eg, word selection
successor		another LetterMorph or nil
				Used for linked typing and, eg, word selection
style			a Symbol, one of #(plain boxed underlined)
				Boxed and underlined display further depends on whether
				the id strings are nil or not.
				Each format has an associated default size

The following two variables are also submorphs, as are the id strings if present.
letterMorph		a StringMorph for displaying the letter
				Used when changing the letter to be displayed
lineMorph		a PolygonMorph used to display the underline
				and also to place the id string in underlined format
"
Class {
	#name : #WordGameLetterMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'letter',
		'originalLetter',
		'idString',
		'linkedLetters',
		'predecessor',
		'successor',
		'indexInQuote',
		'lineMorph',
		'letterMorph',
		'style'
	],
	#classVars : [
		'IDFont',
		'IDHeight',
		'LetterFont',
		'LetterHeight'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'new-morph participation' }
WordGameLetterMorph class >> includeInNewMorphMenu [

	^ false
]

{ #category : #'class initialization' }
WordGameLetterMorph class >> initialize [  "WordGameLetterMorph initialize"

	IDFont := StrikeFont familyName: 'ComicPlain' size: 13.
	IDHeight := IDFont height.
	LetterFont := StrikeFont familyName: 'ComicBold' size: 19.
	LetterHeight := LetterFont height.


]

{ #category : #'style inits' }
WordGameLetterMorph >> boxed [

	style := #boxed
]

{ #category : #'event handling' }
WordGameLetterMorph >> handlesKeyboard: evt [
	^ true
]

{ #category : #initialization }
WordGameLetterMorph >> id2: idString [
	"Add further clue id for acrostic puzzles."

	| idMorph |
	idString ifNotNil:
		[idMorph := StringMorph contents: idString font: IDFont.
		idMorph align: idMorph bounds topRight with: self bounds topRight + (-1@ -1).
		self addMorph: idMorph].


]

{ #category : #accessing }
WordGameLetterMorph >> indexInQuote [

	^ indexInQuote
]

{ #category : #initialization }
WordGameLetterMorph >> indexInQuote: qi id1: aString [ 
	"Initialize me with the given index and an optional aString"
	| idMorph y |
	style = #boxed
		ifTrue: [aString isNil
				ifTrue: [self extent: 18 @ 16;
						 borderWidth: 1]
				ifFalse: [self extent: 26 @ 24;
						 borderWidth: 1]]
		ifFalse: [aString isNil
				ifTrue: [self extent: 18 @ 16;
						 borderWidth: 0]
				ifFalse: [self extent: 18 @ 26;
						 borderWidth: 0]].
	qi
		ifNil: [^ self color: Color gray].
	"blank"
	self color: self normalColor.
	indexInQuote := qi.
	style == #underlined
		ifTrue: [y := self bottom - 2.
			aString
				ifNotNil: [y := y - IDFont ascent + 2].
			lineMorph := PolygonMorph
						vertices: {self left + 2 @ y. self right - 3 @ y}
						color: Color gray
						borderWidth: 1
						borderColor: Color gray.
			self addMorph: lineMorph.
			aString
				ifNil: [^ self].
			idMorph := StringMorph contents: aString font: IDFont.
			idMorph align: idMorph bounds bottomCenter with: self bounds bottomCenter + (0 @ (IDFont descent - 1)).
			self addMorphBack: idMorph]
		ifFalse: [aString
				ifNil: [^ self].
			idMorph := StringMorph contents: aString font: IDFont.
			idMorph align: idMorph bounds topLeft with: self bounds topLeft + (2 @ -1).
			self addMorph: idMorph
			" 
			World addMorph: (WordGameLetterMorph new boxed  
			indexInQuote: 123 id1: '123';  
			id2: 'H'; setLetter: $W).  
			World addMorph: (WordGameLetterMorph new underlined  
			indexInQuote: 123 id1: '123';  
			setLetter: $W).  
			World addMorph: (WordGameLetterMorph new underlined  
			indexInQuote: 123 id1: nil;  
			setLetter: $W). 
			"]
]

{ #category : #accessing }
WordGameLetterMorph >> isBlank [
	^indexInQuote isNil
]

{ #category : #'event handling' }
WordGameLetterMorph >> keyboardFocusChange: boolean [

	| panel |
	boolean ifFalse:
		[panel := self nearestOwnerThat: [:m | m respondsTo: #checkForLostFocus].
		panel ifNotNil: [panel checkForLostFocus]]
]

{ #category : #accessing }
WordGameLetterMorph >> letter [

	^ letter
]

{ #category : #linking }
WordGameLetterMorph >> morphsInWordDo: aBlock [ 
	aBlock value: self.
	(successor isNil or: [successor isBlank]) ifTrue: [^self].
	successor morphsInWordDo: aBlock
]

{ #category : #linking }
WordGameLetterMorph >> nextTypeableLetter [

	successor ifNil: [^ self].
	successor isBlank ifTrue: [^ successor nextTypeableLetter].
	^ successor
]

{ #category : #initialization }
WordGameLetterMorph >> normalColor [

	^ Color r: 1.0 g: 0.8 b: 0.2

]

{ #category : #'style inits' }
WordGameLetterMorph >> plain [

	style := #plain
]

{ #category : #accessing }
WordGameLetterMorph >> predecessor [

	^ predecessor
]

{ #category : #accessing }
WordGameLetterMorph >> predecessor: pred [

	predecessor := pred

]

{ #category : #linking }
WordGameLetterMorph >> previousTypeableLetter [

	predecessor ifNil: [^ self].
	predecessor isBlank ifTrue: [^ predecessor previousTypeableLetter].
	^ predecessor
]

{ #category : #initialization }
WordGameLetterMorph >> setLetter: aLetter [

	^ self setLetter: aLetter color: Color black

]

{ #category : #initialization }
WordGameLetterMorph >> setLetter: aLetter color: aColor [ 
	letterMorph ifNotNil: [letterMorph delete].
	letter := aLetter.
	letter ifNil: [^letterMorph := nil].
	letterMorph := StringMorph contents: aLetter asString font: LetterFont.
	letterMorph color: aColor.
	style == #boxed 
		ifTrue: 
			[letterMorph align: letterMorph bounds bottomCenter
				with: self bounds bottomCenter + (0 @ (LetterFont descent - 2))]
		ifFalse: 
			[lineMorph isNil 
				ifTrue: 
					[letterMorph align: letterMorph bounds bottomCenter
						with: self bounds bottomCenter + (0 @ (LetterFont descent - 4))]
				ifFalse: 
					[letterMorph align: letterMorph bounds bottomCenter
						with: self center x @ (lineMorph top + LetterFont descent)]].
	self addMorphBack: letterMorph
]

{ #category : #linking }
WordGameLetterMorph >> startOfWord [
	(predecessor isNil or: [predecessor isBlank]) ifTrue: [^self].
	^predecessor startOfWord
]

{ #category : #accessing }
WordGameLetterMorph >> successor [

	^ successor
]

{ #category : #accessing }
WordGameLetterMorph >> successor: succ [

	successor := succ

]

{ #category : #'style inits' }
WordGameLetterMorph >> underlined [

	style := #underlined
]

{ #category : #typing }
WordGameLetterMorph >> unhighlight [

	(self isBlank or: [self color = self normalColor])
		ifFalse: [self color: self normalColor]
]
