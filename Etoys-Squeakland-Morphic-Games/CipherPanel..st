"
The CipherPanel, as its name suggests, is a tool for decoding simple substitution codes, such as are presented on the puzzle pages of many Sunday newspapers.  Most of the capability is inherited from the two WordGame classes used.  To try it out, choose newMorph/Games/CipherPanel in a morphic project, or execute, in any project:

	CipherPanel new openInWorld

"
Class {
	#name : #CipherPanel,
	#superclass : #WordGamePanelMorph,
	#instVars : [
		'originalText',
		'quote',
		'originalMorphs',
		'decodingMorphs'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'parts bin' }
CipherPanel class >> descriptionForPartsBin [
	^ self partName:	'Cipher' translatedNoop
		categories:		{'Games' translatedNoop}
		documentation:	'The Cipher Panel: A playground for cryptograms, by Dan Ingalls' translatedNoop
]

{ #category : #'as yet unclassified' }
CipherPanel class >> encode: aString [
	"CipherPanel encode: 'Now is the time for all good men to come to the aid of their country.'"

	| dict repeat |
	dict := Dictionary new.
	repeat := true.
	[repeat] whileTrue:
		[repeat := false.
		($A to: $Z) with: ($A to: $Z) shuffled do:
			[:a :b | a = b ifTrue: [repeat := true].
			dict at: a put: b]].
	^ aString asUppercase collect: [:a | dict at: a ifAbsent: [a]]
]

{ #category : #'new-morph participation' }
CipherPanel class >> includeInNewMorphMenu [

	^ true
]

{ #category : #'instance creation' }
CipherPanel class >> new [
	"NOTE: Use newFromQuote: rather than new to create new CipherPanels"

	^ self newFromQuote: self sampleString

" Here are some other examples...
World addMorph: (CipherPanel newFromQuote: 'BPFFXY LZY PK ROY RPBY PG XPAY HOYG EJCM SXJROYK FJG''R APR QCR PR''K EJC HOJ GYYF ROY LXRYMLRPJGK.  KJCMSY CGNGJHG')

World addMorph: (CipherPanel newFromQuote: 'Y FRV TRK HJRH QVL QS HJL BPLRHLTH WZLRTXPLT YV ZYSL YT OQYVB MJRH WLQWZL TRK KQX FRVVQH OQ.')

World addMorph: (CipherPanel newFromQuote: 'XI''H SAZRG: SDCIZCIZT EZDEAZ TD CDI SGZRIZ EGDPGZHH.')

World addMorph: (CipherPanel newFromQuote: 'PY MOJ WPMMWJ MZGYR ZL MOJ GZSWH PM''R YZ RZZYJS HZYJ MOBY RBPH.')

World addMorph: (CipherPanel newFromQuote: 'PYSLHYA DJP VBHHLXYAA BPY BGNBMA PLUVQ LX AQMGY; QVY HPLXSLHBG LXUPYCLYXQA BPY NBPK BXC DPLYXCGM AKLGYA.')

World addMorph: (CipherPanel newFromQuote: 'U HWVS RJ AHOST RLO FOOQOST TJUSM AJIO LOVNC WUXRUSM VST HWVCUSM LVSTZVWW. -- TVNUT WORROEIVS VXROE LUA KGUSRGHWO-ZCHVAA LOVER JHOEVRUJS')
"
]

{ #category : #'as yet unclassified' }
CipherPanel class >> newFromQuote: encodedString [
	"Use this to creat new panels instead of new."

	^ super new encodedQuote: encodedString
]

{ #category : #'as yet unclassified' }
CipherPanel class >> randomComment [
	"CipherPanel randomComment"
	"Generate cryptic puzzles from method comments in the system"
	| c s |
	s := 'none'.
	[s = 'none']
		whileTrue: [s := ((c := SystemNavigation new allClasses atRandom) selectors
						collect: [:sel | (c firstCommentAt: sel) asString])
						detect: [:str | str size between: 100 and: 200]
						ifNone: ['none' translated]].
	^ s
]

{ #category : #'as yet unclassified' }
CipherPanel class >> sampleString [
	^
'E SGJC OSCVC LICGNV, ENGRCV, JEVEMAV. E SGJC OSEV QGVVEMA XMI [SMWWDHMML] ... EO''V HMALCIXKW OM SGJC VMNCOSEAR OSGO EAVQEICV GAL LIEJCV DMK. -- ZGIZIG VOICEVGAL'
]

{ #category : #'as yet unclassified' }
CipherPanel class >> tedsHack [  
	"Generate cryptic puzzles from method comments in the system"
	(self newFromQuote: (self encode: (self randomComment))) openInWorld

"CipherPanel tedsHack"
]

{ #category : #menu }
CipherPanel >> addMenuItemsTo: aMenu hand: aHandMorph [ 
	aMenu
		add: 'show cipher help' translated
		target: self
		action: #showHelpWindow.
	aMenu
		add: 'show cipher hints' translated
		target: self
		action: #showHintsWindow.
	aMenu
		add: 'clear cipher typing' translated
		target: self
		action: #clearTyping.
	aMenu
		add: 'enter a new cipher' translated
		target: self
		action: #enterANewCipher.
	aMenu
		add: 'quote from Squeak' translated
		target: self
		action: #squeakCipher
]

{ #category : #menu }
CipherPanel >> buttonRow [
	| row aButton |
	row := AlignmentMorph newRow color: self color;
				 hResizing: #shrinkWrap;
				 vResizing: #shrinkWrap.
	#('show help' 'show hints' 'clear typing' 'enter a new cipher' 'quote from Squeak' ) translatedNoop
		with: #(#showHelpWindow #showHintsWindow #clearTyping #enterANewCipher #squeakCipher )
		do: [:label :selector | 
			aButton := SimpleButtonMorph new target: self.
			aButton color: Color transparent;
				 borderWidth: 1;
				 borderColor: Color black.
			aButton actionSelector: selector.
			aButton label: label translated.
			row addMorphBack: aButton.
			row addTransparentSpacerOfSize: 3 @ 0].
	^ row
]

{ #category : #menu }
CipherPanel >> cipherStats [

	| letterCounts digraphs d digraphCounts |
	letterCounts := (quote copyWithout: Character space) asBag sortedCounts.
	digraphs := Bag new.
	quote withIndexDo:
		[:c :i |
		i < quote size ifTrue:
			[d := quote at: i+1.
			(c ~= Character space and: [d ~= Character space]) ifTrue:
				[digraphs add: (String with: c with: d)]]].
	digraphCounts := digraphs sortedCounts.
	^ String streamContents:
		[:strm |
		1 to: 10 do:
			[:i |
			strm cr; tab; nextPut: (letterCounts at: i) value.
			strm tab; print: (letterCounts at: i) key.
			(digraphCounts at: i) key > 1 ifTrue:
				[strm tab; tab; tab; nextPutAll: (digraphCounts at: i) value.
				strm tab; print: (digraphCounts at: i) key]]]
]

{ #category : #defaults }
CipherPanel >> clearTyping [
	self isClean
		ifTrue: [^ self].
	(self confirm: 'Are you sure you want to discard all typing?' translated)
		ifFalse: [^ self].
	super clearTyping
]

{ #category : #initialization }
CipherPanel >> encodedQuote: aString [ 
	"World addMorph: CipherPanel new"
	| morph prev |
	aString isEmpty
		ifTrue: [^ self].
	(letterMorphs isNil
			or: [self isClean])
		ifFalse: [(self confirm: 'Are you sure you want to discard all typing?' translated)
				ifFalse: [^ self]].
	haveTypedHere := false.
	quote := aString asUppercase.
	prev := nil.
	originalMorphs := quote asArray
				collectWithIndex: [:c :i | WordGameLetterMorph new plain indexInQuote: i id1: nil;
						
						setLetter: (quote at: i)].
	letterMorphs := OrderedCollection new.
	decodingMorphs := quote asArray
				collectWithIndex: [:c :i | (quote at: i) isLetter
						ifTrue: [morph := WordGameLetterMorph new underlined indexInQuote: i id1: nil.
							morph
								on: #mouseDown
								send: #mouseDownEvent:letterMorph:
								to: self.
							morph
								on: #keyStroke
								send: #keyStrokeEvent:letterMorph:
								to: self.
							letterMorphs addLast: morph.
							morph predecessor: prev.
							prev
								ifNotNil: [prev successor: morph].
							prev := morph]
						ifFalse: [WordGameLetterMorph new plain indexInQuote: i id1: nil;
								
								setLetter: (quote at: i)]].
	self color: originalMorphs first color.
	self extent: 500 @ 500
]

{ #category : #menu }
CipherPanel >> enterANewCipher [
	self clearTyping;
		encodedQuote: (FillInTheBlank request: 'Type a cipher text to work on here below...' translated)
]

{ #category : #geometry }
CipherPanel >> extent: newExtent [ 
	"Lay out with word wrap, alternating bewteen decoded and encoded lines."
	"Currently not tolerant of narrow (less than a word) margins"

	| w h relLoc topLeft thisWord i m corner row firstWord |
	self removeAllMorphs.
	w := originalMorphs first width - 1.  h := originalMorphs first height * 2 + 10.
	topLeft := self position + self borderWidth + (0@10).
	thisWord := OrderedCollection new.
	i := 1.  firstWord := true.  relLoc := 0@0.  corner := topLeft.
	[i <= originalMorphs size] whileTrue:
		[m := originalMorphs at: i.
		thisWord addLast: ((decodingMorphs at: i) position: topLeft + relLoc).
		thisWord addLast: (m position: topLeft + relLoc + (0@m height)).
		(m letter = Character space or: [i = originalMorphs size])
			ifTrue: [self addAllMorphs: thisWord.
					corner := corner max: thisWord last bounds bottomRight.
					thisWord reset.  firstWord := false].
		relLoc := relLoc + (w@0).
		(relLoc x + w) > newExtent x
			ifTrue: [firstWord
						ifTrue: ["No spaces -- force a line break"
								thisWord removeLast; removeLast.
								self addAllMorphs: thisWord.
								corner := corner max: thisWord last bounds bottomRight]
						ifFalse: [i := i - (thisWord size//2) + 1].
					thisWord reset.  firstWord := true.
					relLoc := 0@(relLoc y + h)]
			ifFalse: [i := i + 1]].
	row := self buttonRow. row fullBounds.
	self addMorph: row.
	super extent: (corner - topLeft) + (self borderWidth * 2) + (0@row height+10).
	row align: row bounds bottomCenter with: self bounds bottomCenter - (0@2).
]

{ #category : #'parts bin' }
CipherPanel >> initializeToStandAlone [ 
	super initializeToStandAlone.
	self encodedQuote: self class sampleString
]

{ #category : #defaults }
CipherPanel >> keyCharacter: aLetter atIndex: indexInQuote nextFocus: nextFocus [

	| encodedLetter |
	encodedLetter := quote at: indexInQuote.
	originalMorphs with: decodingMorphs do:
		[:e :d | e letter = encodedLetter ifTrue: [d setLetter: aLetter color: Color red]].

]

{ #category : #menu }
CipherPanel >> showHelpWindow [
	((PluggableTextMorph new setText: 'The Cipher Panel displays an encrypted message.  The encryption is a simple substitution code;  each letter of the alphabet has been changed to a different one.

You can solve the cipher by clicking above any letter in the message, and typing the letter you think it should be.  The Cipher Panel automatically makes the same substitution anywhere else that letter occurs in the encoded message.

If you are having trouble, you can use the command menu to ''show cipher hints''.  That will display how many of each letter occurs, which is often a help in solving ciphers.' translated )
		embeddedInMorphicWindowLabeled: 'About the Cipher Panel' translated)
		setWindowColor: (Color
				r: 1.0
				g: 0.6
				b: 0.0);
		 openInWorld: self world extent: 389 @ 209
]

{ #category : #menu }
CipherPanel >> showHintsWindow [
	((PluggableTextMorph new setText: 'Most bodies of english text follow a general pattern of letter usage.  The following are the most common letters, in approximate order of frequency:
	E  T  A  O  N  I  R  S  H
The following are the most common digraphs:
	EN  ER  RE  NT  TH  ON  IN

The message you are trying to decode has the following specific statistics:' translated , self cipherStats , '

Good luck!' translated)
		embeddedInMorphicWindowLabeled: 'Some Useful Statistics' translated)
		setWindowColor: (Color
				r: 1.0
				g: 0.6
				b: 0.0);
		 openInWorld: self world extent: 318 @ 326
]

{ #category : #menu }
CipherPanel >> squeakCipher [
	self encodedQuote: (CipherPanel encode: (CipherPanel randomComment))
]
