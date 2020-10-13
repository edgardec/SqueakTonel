"
The CrosticPanel, as its name suggests, is a tool for decoding acrostic puzzles, such as are presented on the puzzle pages of some Sunday newspapers.  Much of the capability is inherited from the two WordGame classes used.  To try it out, choose newMorph/Games/CrosticPanel in a morphic project, or execute, in any project:

	CrosticPanel new openInWorld

The instance variables of this class include...
	letterMorphs (in superclass)  a collection of all the letterMorphs in this panel
	quote		a string, being the entire quote in uppercase with no blanks
	clues		a collection of the clue strings
	answers		a collection of the answer indices.
				For each answer, this is an array of the indices into the quote string.

The final structure of a CrosticPanel is as follows
	self					a CrosticPanel			the overall holder
		quotePanel		a CrosticQuotePanel		holds the grid of letters from the quote
		cluesPanel		an AlignmentMorph		holds most of the clue rows
		cluesCol2		an AlignmentMorph		holds the rest of the clue rows

Each clue row is a horizontal AlignmentMorph with a textMorph and another alignmentMorph full of the letterMorphs for the answer.

"
Class {
	#name : #CrosticPanel,
	#superclass : #WordGamePanelMorph,
	#instVars : [
		'crosticPanel',
		'quotePanel',
		'cluesCol2',
		'answers',
		'quote',
		'clues',
		'cluesPanel'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'parts bin' }
CrosticPanel class >> descriptionForPartsBin [
	^ self partName:	'Crostic' translatedNoop
		categories:		{'Games' translatedNoop}
		documentation:	'The Crostic Panel: A classic word diagram game, by Dan Ingalls' translatedNoop
]

{ #category : #'new-morph participation' }
CrosticPanel class >> includeInNewMorphMenu [

	^ true
]

{ #category : #'instance creation' }
CrosticPanel class >> new [
	"NOTE: Use newFromFile: rather than new to create new CrosticPanels"

	^ self newFromFile: (ReadStream on: self sampleFile)
]

{ #category : #'instance creation' }
CrosticPanel class >> newFromFile: aStream [ 
	"World addMorph: CrosticPanel new"
	"World addMorph: (CrosticPanel newFromFile: (FileStream 
	readOnlyFileNamed: 'first.crostic'))"
	| quoteWithBlanks citation clue numberLine numbers clues answers indexableQuote quotePanel crosticPanel buttonRow quoteWidth |
	aStream next asciiValue = 31 & (aStream next asciiValue = 139)
		ifTrue: ["It's gzipped..."
			aStream skip: -2.
			^ self newFromFile: aStream asUnZippedStream ascii].
	aStream skip: -2.
	quoteWithBlanks := aStream nextLine.
	quoteWithBlanks := quoteWithBlanks asUppercase
				select: [:c | c isLetter
						or: [' -' includes: c]].
	indexableQuote := quoteWithBlanks
				select: [:c | c isLetter].
	citation := aStream nextLine.
	aStream nextLine.
	clues := OrderedCollection new.
	answers := OrderedCollection new.
	[aStream atEnd]
		whileFalse: [clue := aStream nextLine.
			"Transcript cr; show: clue."
			clues addLast: clue.
			numberLine := aStream nextLine.
			numbers := Scanner new scanTokens: numberLine.
			answers addLast: numbers].
	aStream close.
	"Consistency check:"
	(citation asUppercase
			select: [:c | c isLetter])
			= (String
					withAll: (answers
							collect: [:a | indexableQuote at: a first]))
		ifFalse: [self error: 'mal-formed crostic file' translated].
	crosticPanel := super new.
	quotePanel := CrosticQuotePanel new
				quote: quoteWithBlanks
				answers: answers
				cluesPanel: crosticPanel.
	crosticPanel color: quotePanel firstSubmorph color;
		
		quote: indexableQuote
		clues: clues
		answers: answers
		quotePanel: quotePanel.
	buttonRow := crosticPanel buttonRow.
	quoteWidth := crosticPanel width + quotePanel firstSubmorph width max: buttonRow width.
	quotePanel extent: quoteWidth @ 9999.
	crosticPanel addMorph: quotePanel.
	^ crosticPanel breakColumnAndResizeWithButtons: buttonRow
]

{ #category : #'as yet unclassified' }
CrosticPanel class >> oldStyle [
	"return true if we should cross-index all the cells (takes more space)."

	^ false
]

{ #category : #'as yet unclassified' }
CrosticPanel class >> sampleFile [ 
	"If you want to enter a new acrostic, follow this format exactly with regard to CRs and the like, and store it in a file.  Do not double the string quotes as here -- that is only because they are embedded in a string.  Finally, compress the file in the fileList (so it will be easy to transport and hard to read), and name it 'yourName.crostic' so that the 'open' button on the panel will recognize it."
	^
'Men and women do not feel the same way about dirt.  Women for some hormonal reason can see individual dirt molecules, whereas men tend not to notice them until they join together into clumps large enough to support commercial agriculture.
Dave Barry''s Guide to Marriage

Boccaccio''s collection of tales
74 19 175 156 9 122 84 113 104
Wooden instrument of Swiss herders
67 184 153 103 14 142 148 54 3
Evening service
76 99 154 171 89 194 69
Russian-born American anarchist (2 wds)
159 102 177 25 186 134 128 82 50 62 11
Apple-polish (2 wds)
32 190 129 126 179 157 79 170
Visual-gesture means of communication
4 178 27 168 150 185 114
Postponed contest
173 58 77 65 8 124 85
Groundbreaking invention
98 15 116 162 112 37 92 155 70 187
Material used to make English longbows
132 195 28
Gracile
48 191 145 152
Have the effrontery; experience a high (2 wds)
164 61 137 33 17 45
Florentine painter who experimented with perspective
91 181 189 2 20 81 167
Sondheim opus (3 wds)
72 109 147 13 192 165 93 40 115 138 6 63
Spanish rake
108 56 44 133 193 29 125
Emergence  as of an adult butterfly
106 149 59 41 24 135 87 68
Type of rifle (hyph)
111 7 143 73 39 30 105 95 53
Free of charge (3 wds)
176 107 120 130 160 22 46 34 94 71
Pie filling
86 75 136 118 43
Master filmmaker
31 151 174 51 163 144
Longtime sportswriter for the NY Herald tribune (2 wds)
60 140 12 101 55 188 166 121
Birthplace of Erasmus
47 64 141 21 10 180 36 80 1
Mae West classic (3 wds)
127 123 161 110 183 5 139 97 88
Element that glows blue in the dark
100 90 35 182 146 117 169 26
Sturm und Drang writer
158 172 119 16 52 23
Starfish or sea cucumber
18 66 96 83 57 49 78 131 38 42
'
]

{ #category : #menu }
CrosticPanel >> addMenuItemsTo: aMenu hand: aHandMorph [ 
	aMenu
		add: 'show crostic help' translated
		target: self
		action: #showHelpWindow.
	aMenu
		add: 'show crostic hints' translated
		target: self
		action: #showHintsWindow.
	aMenu
		add: 'show crostic errors' translated
		target: self
		action: #showErrors.
	aMenu
		add: 'clear crostic typing' translated
		target: self
		action: #clearTyping.
	aMenu
		add: 'open crostic file...' translated
		target: self
		action: #openFile
]

{ #category : #initialization }
CrosticPanel >> breakColumnAndResizeWithButtons: buttonRow [
	| indexToSplit yToSplit |
	"The column of clues has been laid out, and the crostic panel has been resized to that width and embedded as a submorph.  This method breaks the clues in two, placing the long part to the left of the crostic and the short one below it."

	yToSplit := cluesPanel height + quotePanel height // 2 + self top.
	indexToSplit := cluesPanel submorphs findFirst: [:m | m bottom > yToSplit].
	cluesCol2 := AlignmentMorph newColumn color: self color;
		hResizing: #shrinkWrap; vResizing: #shrinkWrap; layoutInset: 0;
		cellPositioning: #topLeft.
	cluesCol2 addAllMorphs: (cluesPanel submorphs copyFrom: indexToSplit + 1
							to: cluesPanel submorphs size).
	cluesPanel position: self position + self borderWidth + (0 @ 4).
	quotePanel position: self position + (quotePanel width @ 0).
	cluesCol2 position: self position + quotePanel extent + (0 @ 4).
	self addMorph: cluesCol2.
	self addMorph: buttonRow.
	buttonRow align: buttonRow topLeft with: cluesCol2 bottomLeft.
	self extent: 100@100; bounds: ((self fullBounds topLeft - self borderWidth asPoint)
							corner: (self fullBounds bottomRight - (2@0))).

]

{ #category : #menu }
CrosticPanel >> buttonRow [
	| row aButton |
	row := AlignmentMorph newRow color: self color;
				 hResizing: #shrinkWrap;
				 vResizing: #shrinkWrap.
	#('show help' 'show errors' 'show hints' 'clear' 'open...' ) translatedNoop
		with: #(#showHelpWindow #showErrors #showHintsWindow #clearTyping #openFile )
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

{ #category : #defaults }
CrosticPanel >> clearTyping [
	self isClean
		ifTrue: [^ self].
	(self confirm: 'Are you sure you want to discard all typing?' translated)
		ifFalse: [^ self].
	super clearTyping.
	quotePanel clearTyping
]

{ #category : #defaults }
CrosticPanel >> highlight: morph [

	self unhighlight.
	quotePanel unhighlight.
	morph startOfWord morphsInWordDo:
		[:m | m color: Color lightGreen.
		(quotePanel letterMorphs at: m indexInQuote) color: Color lightMagenta].
	morph color: Color green.
	(quotePanel letterMorphs at: morph indexInQuote) color: Color magenta.

]

{ #category : #'parts bin' }
CrosticPanel >> initializeToStandAlone [
	| aStream quoteWithBlanks indexableQuote citation clue numberLine numbers buttonRow quoteWidth |
	super initializeToStandAlone.
	aStream := ReadStream on: self class sampleFile.
	quoteWithBlanks := aStream nextLine.
	quoteWithBlanks := quoteWithBlanks asUppercase
				select: [:c | c isLetter
						or: [' -' includes: c]].
	indexableQuote := quoteWithBlanks
				select: [:c | c isLetter].
	citation := aStream nextLine.
	aStream nextLine.
	clues := OrderedCollection new.
	answers := OrderedCollection new.
	[aStream atEnd]
		whileFalse: [clue := aStream nextLine.
			"Transcript cr; show: clue."
			clues addLast: clue.
			numberLine := aStream nextLine.
			numbers := Scanner new scanTokens: numberLine.
			answers addLast: numbers].
	aStream close.
	"Consistency check:"
	(citation asUppercase
			select: [:c | c isLetter])
			= (String
					withAll: (answers
							collect: [:a | indexableQuote at: a first]))
		ifFalse: [self error: 'mal-formed crostic file' translated].
	quotePanel := CrosticQuotePanel new
				quote: quoteWithBlanks
				answers: answers
				cluesPanel: self.
	self color: quotePanel firstSubmorph color;
		
		quote: indexableQuote
		clues: clues
		answers: answers
		quotePanel: quotePanel.
	buttonRow := self buttonRow.
	quoteWidth := self width + quotePanel firstSubmorph width max: buttonRow width.
	quotePanel extent: quoteWidth @ 9999.
	self addMorph: quotePanel.
	self breakColumnAndResizeWithButtons: buttonRow
]

{ #category : #defaults }
CrosticPanel >> keyCharacter: aLetter atIndex: indexInQuote nextFocus: nextFocus [

	(self letterMorphs at: indexInQuote) setLetter: aLetter.
	(quotePanel letterMorphs at: indexInQuote) setLetter: aLetter.
	self highlight: nextFocus

]

{ #category : #defaults }
CrosticPanel >> lostFocus [

	self unhighlight.
	quotePanel unhighlight
]

{ #category : #menu }
CrosticPanel >> openFile [
	| fileName crostic file |

	fileName := FileChooserDialog openOn: FileDirectory default suffixList: { 'crostic' } label: 'Select a Crostic file...' translated.
	fileName ifNil: [^nil].
	 
	file := FileStream readOnlyFileNamed: fileName.
	crostic := CrosticPanel newFromFile: file.
	file close.
	(self isClean
			or: [self confirm: 'Is it OK to discard this crostic?' translated])
		ifTrue: [self world
				addMorphFront: (crostic position: self position).
			self delete]
		ifFalse: [self world addMorphFront: crostic]
]

{ #category : #initialization }
CrosticPanel >> quote: indexableQuote clues: clueStrings answers: answerIndices quotePanel: panel [

	| row clue answer answerMorph letterMorph prev clueText clueStyle |
	quote := indexableQuote.
	quotePanel := panel.
	clues := clueStrings.
	answers := answerIndices.
	cluesPanel := AlignmentMorph newColumn color: self color;
		hResizing: #shrinkWrap; vResizing: #shrinkWrap;
		cellPositioning: #topLeft; layoutInset: 1.
	letterMorphs := Array new: quotePanel letterMorphs size.
	clueStyle := nil.
	1 to: clues size do:
		[:i |  clue := clues at: i.  answer := answers at: i.
		row := AlignmentMorph newRow cellPositioning: #bottomLeft.
		clueText := (TextMorph newBounds: (0@0 extent: 120@20) color: Color black)
				string: (CrosticPanel oldStyle
							ifTrue: [(($A to: $Z) at: i) asString , '.  ' , clue]
							ifFalse: [clue])
				fontName: 'ComicPlain' size: 13.
		clueStyle ifNil: ["Make up a special style with decreased leading"
						clueStyle := clueText textStyle copy.
						clueStyle gridForFont: 1 withLead: -2].
		clueText text: clueText asText textStyle: clueStyle.  "All clues share same style"
		clueText composeToBounds.
		row addMorphBack: clueText.
		answerMorph := AlignmentMorph newRow layoutInset: 0.
		prev := nil.
		answer do:
			[:n | letterMorph := WordGameLetterMorph new underlined
						indexInQuote: n
						id1: (CrosticPanel oldStyle ifTrue: [n printString] ifFalse: [nil]);
						setLetter: Character space.
			letterMorph on: #mouseDown send: #mouseDownEvent:letterMorph: to: self.
			letterMorph on: #keyStroke send: #keyStrokeEvent:letterMorph: to: self.
			letterMorph predecessor: prev.
			prev ifNotNil: [prev successor: letterMorph].
			prev := letterMorph.
			letterMorphs at: n put: letterMorph.
			answerMorph addMorphBack: letterMorph].
		answerMorph color: answerMorph firstSubmorph color.
		row addMorphBack: answerMorph.
row fullBounds.
		row color: answerMorph firstSubmorph color.
		cluesPanel addMorphBack: row].
	self addMorph: cluesPanel.
	self bounds: cluesPanel fullBounds.

]

{ #category : #menu }
CrosticPanel >> showErrors [

	letterMorphs do:
		[:m | (m letter ~= Character space and: [m letter ~= (quote at: m indexInQuote)])
			ifTrue: [m color: Color red.
					(quotePanel letterMorphs at: m indexInQuote) color: Color red]]
]

{ #category : #menu }
CrosticPanel >> showHelpWindow [
	((PluggableTextMorph new setText: 'The Crostic Panel presents an acrostic puzzle for solution.  As you type in answers for the clues, the letters also get entered in the text of the hidden quote.  Conversely, as you guess words in the quote, those letters will fill in missing places in your answers.  In addition, the first letters of all the answers together form the author''s name and title of the work from which the quote is taken.

If you wish to make up other acrostic puzzles, follow the obvious file format in the sampleFile method.  If you wish to print an acrostic to work it on paper, then change the oldStyle method to return true, and it will properly cross-index all the cells.

Have fun.' translated)
		embeddedInMorphicWindowLabeled: 'About the Crostic Panel' translated)
		setWindowColor: (Color
				r: 1.0
				g: 0.6
				b: 0.0);
		 openInWorld: self world extent: 409 @ 207
]

{ #category : #menu }
CrosticPanel >> showHintsWindow [
	| hints |
	(self confirm: 'As hints, you will be given the five longest answers.
Do you really want to do this?' translated)
		ifFalse: [^ self].
	hints := (answers sorted: [:x :y | x size > y size]) first: 5.
	((PluggableTextMorph new setText: 'The five longest answers are...
' translated
			, (String
					streamContents: [:strm | 
						hints
							do: [:hint | strm cr;
									nextPutAll: (hint
											collect: [:i | quote at: i])].
						strm cr; cr]) , 'Good luck!' translated)
		embeddedInMorphicWindowLabeled: 'Crostic Hints' translated)
		setWindowColor: (Color
				r: 1.0
				g: 0.6
				b: 0.0);
		 openInWorld: self world extent: 198 @ 154
]
