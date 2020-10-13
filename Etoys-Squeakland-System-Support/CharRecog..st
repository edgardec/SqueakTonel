"
Alan Kay's ""one-page"" character recognizer.  Currently hooked up to text panes and to text morphs, such that you can get it started by hitting cmd-r in such text area that currently has focus.  

To reinitialize the recognition dictionary, evaluate

	CharRecog reinitializeCharacterDictionary

 
"
Class {
	#name : #CharRecog,
	#superclass : #Object,
	#instVars : [
		'mp',
		'p',
		'sts',
		'pts',
		'bmin',
		'bmax',
		'op',
		'cPat',
		'in',
		'dirs',
		'ftrs',
		'prevFeatures',
		'textMorph'
	],
	#classVars : [
		'CharacterDictionary'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'Etoys-Squeakland-System-Support'
}

{ #category : #initialization }
CharRecog class >> initialize [
	"Iniitialize the character dictionary if it doesn't exist yet.  2/5/96 sw"

	CharacterDictionary == nil ifTrue:
		[CharacterDictionary := Dictionary new]
]

{ #category : #'saving dictionary' }
CharRecog class >> readRecognizerDictionaryFrom: aFileName [
	"Read a fresh version of the Recognizer dictionary in from a file of the given name.  7/26/96 sw"
	"CharRecog readRecognizerDictionaryFrom: 'RecogDictionary.2 fixed'"

   | aReferenceStream |
   aReferenceStream := ReferenceStream fileNamed: aFileName.
   CharacterDictionary := aReferenceStream next.
   aReferenceStream close.

]

{ #category : #initialization }
CharRecog class >> reinitializeCharacterDictionary [
	"Reset the character dictionary to be empty, ready for a fresh start.  2/5/96 sw"

	CharacterDictionary := Dictionary new

"CharRecog reinitializeCharacterDictionary" 
]

{ #category : #'saving dictionary' }
CharRecog class >> saveRecognizerDictionaryTo: aFileName [
	"Save the current state of the Recognizer dictionary to disk.  7/26/96 sw"

   | aReferenceStream |
aReferenceStream := ReferenceStream fileNamed: aFileName.
   aReferenceStream nextPut: CharacterDictionary.
   aReferenceStream close
]

{ #category : #'historical & disused' }
CharRecog >> directionFrom: p1 to: p2 [ | ex |

"This does 8 directions and is not used in current recognizer"
"get the bounding box"		ex := p2 - p1. "unlike bmax-bmin, this can have negatives"

"Look for degenerate forms first: . - |"
"look for a dot"				ex abs < (3@3) ifTrue: [^' dot... '].
"look for hori line"			((ex y = 0) or: [(ex x/ex y) abs > 2]) ifTrue:
	"look for w-e"					[ex x > 0 ifTrue:[^' we-- ']
	"it's an e-w"						ifFalse:[^' ew-- ']].
"look for vertical line"		((ex x = 0) or: [(ex y/ex x) abs > 2]) ifTrue:
	"look for n-s"				[(ex y > 0) ifTrue:[ ^' ns||']
	"it's a s-n"						ifFalse:[^' sn|| ']].
"look for a diagonal"			(ex x/ex y) abs <= 2 ifTrue:
	"se or ne"					[ex x > 0 ifTrue:[ex y > 0 ifTrue:[^' se// ']. ^' ne// '].
	"sw or nw"									ex y > 0 ifTrue:[^' sw// ']. ^' nw// '].

]

{ #category : #recognizer }
CharRecog >> extractFeatures [ | xl xr yl yh reg px py |
"get extent bounding box"	in := bmax - bmin. 

"Look for degenerate forms first: . - |"
"look for a dot"				in < (3@3) ifTrue: [^' dot... '].

"Feature 5: turns (these are already in ftrs)"

"Feature 4: absolute size"	in < (10@10) ifTrue: [ftrs :=  'SML ', ftrs] ifFalse:
							[in <=  (70@70) ifTrue: [ftrs := 'REG ', ftrs] ifFalse:
							[in > (70@70) ifTrue: [ftrs := 'LRG ', ftrs]]].

"Feature 3: aspect ratio"
	"horizontal shape"		((in y = 0) or: [(in x/in y) abs > 3]) ifTrue:
								[ftrs := 'HOR ', ftrs] ifFalse:
	"vertical shape"			[((in x = 0) or: [(in y/in x) abs >= 3]) ifTrue:
								[ftrs := 'VER ', ftrs] ifFalse:
	"boxy shape"			[((in x/in y) abs <= 3) ifTrue:
								[ftrs := 'BOX ', ftrs.
"Now only for boxes"
"Feature 2: endstroke reg"	ftrs := (self regionOf: (pts last)), ftrs.
							
"Feature 1: startstroke reg"	ftrs := (self regionOf: (pts contents at: 1)), ftrs.]]].

^ftrs




]

{ #category : #recognizer }
CharRecog >> fourDirsFrom:  p1 to: p2 [ | ex |

"get the bounding box"		ex := p2 - p1. "unlike bmax-bmin, this can have negatives"

"Look for degenerate forms first: . - |"
"look for a dot"				ex abs < (3@3) ifTrue: [^' dot... '].
"look for hori line"			((ex y = 0) or: [(ex x/ex y) abs > 1]) ifTrue:
	"look for w-e"					[ex x > 0 ifTrue:[^'WE ']
	"it's an e-w"						ifFalse:[^'EW ']].
"look for vertical line"		((ex x = 0) or: [(ex y/ex x) abs >= 1]) ifTrue:
	"look for n-s"				[(ex y > 0) ifTrue:[ ^'NS ']
	"it's a s-n"						ifFalse:[^'SN ']].

"look for a diagonal			(ex x/ex y) abs <= 2 ifTrue:"
	"se or ne					[ex x > 0 ifTrue:[ex y > 0 ifTrue:[^' se// ']. ^' ne// ']."
	"sw or nw									ex y > 0 ifTrue:[^' sw// ']. ^' nw// ']."

]

{ #category : #'historical & disused' }
CharRecog >> learnPrev [
	"The character recognized before this one was wrong.  (Got here via the gesture for 'wrong'.)  Bring up a dialog box on that char.  8/21/96 tk"

						| old result |
	old := CharacterDictionary at: prevFeatures ifAbsent: [^ ''].
"get right char from user"	result := FillInTheBlank request:
						('Redefine the gesture we thought was "', old asString, '".', '
(Letter or:  tab  cr  wrong  bs  select  caret)
', prevFeatures).

"ignore or..."				(result = '~' | result = '') ifTrue: ['']
"...enter new char"			ifFalse: [
								CharacterDictionary at: prevFeatures 
									put: result].
					"caller erases bad char"
"good char"			^ result
]

{ #category : #'historical & disused' }
CharRecog >> recogPar [ | prv cdir result features char r s t dir |

"Inits"				(p := Pen new) defaultNib: 1; down.
	"for points"		pts := ReadWriteStream on: #().

"Event Loop"	
		[EventSensor default anyButtonPressed] whileFalse: [(EventSensor default peekPosition x < 50) ifTrue: [^''].].

"First-Time"			pts reset.		
"will hold features"		ftrs := ''.

					  (EventSensor default anyButtonPressed) ifTrue:
						[pts nextPut: (bmin := bmax := t := s := sts := EventSensor default peekPosition).
						p place: sts. cdir := nil.

"Each-Time"		[EventSensor default anyButtonPressed] whileTrue:
						[
"ink raw input"			p goto: (r := EventSensor default peekPosition).
"smooth it"				s := (0.5*s) + (0.5*r).
"thin the stream"		((s x - t x) abs > 3 or:[(s y - t y) abs > 3]) ifTrue:
							[ pts nextPut: t. 
"bounding box"			bmin := bmin min: s. bmax := bmax max: s.
"get current dir"				dir := (self fourDirsFrom: t to: s). t := s.
							dir ~= ' dot... ' ifTrue: [
"store new dirs"					cdir ~= dir ifTrue: [ftrs := ftrs, (cdir := dir)]].
"for inked t's" 			p place: t; go: 1; place: r.
							].
 "End Each-Time Loop"	].

"Last-Time"	
"start a new recog for next point"	[CharRecog new recognize] fork.

"save last points"		pts nextPut: t; nextPut: r.
"find rest of features"	features := self extractFeatures.
"find char..."			char := CharacterDictionary at: features ifAbsent:
"...or get from user"			[ result := FillInTheBlank request:
							 'Not recognized. type char, or type ~: ', features.
"ignore or..."				result = '~' ifTrue: ['']
"...enter new char"			ifFalse: [CharacterDictionary at: features put: result. result]].

"control the editor"		(char = 'cr' ifTrue: [Transcript cr] ifFalse:
						[char = 'bs' ifTrue: [Transcript bs] ifFalse:
						[char = 'tab' ifTrue:[Transcript tab] ifFalse:
						[Transcript show: char]]]). 

"End First-Time Loop"	]. 



			   
 
]

{ #category : #'historical & disused' }
CharRecog >> recognize [ | prv cdir result features char r s t dir |

"Alan Kay's recognizer as of 1/31/96.  This version preserved for historical purposes, and also because it's still called by the not-yet-deployed method recogPar.  Within the current image, the recognizer is now called via #recognizeAndDispatch:until:"


"Inits"				(p := Pen new) defaultNib: 1; down.
	"for points"		pts := ReadWriteStream on: #().

"Event Loop"	
					[(EventSensor default peekPosition x) < 50] whileFalse:

"First-Time"			[pts reset.		
"will hold features"		ftrs := ''.

					  (EventSensor default anyButtonPressed) ifTrue:
						[pts nextPut: (bmin := bmax := t := s := sts := EventSensor default peekPosition).
						p place: sts. cdir := nil.

"Each-Time"		[EventSensor default anyButtonPressed] whileTrue:
						[
"ink raw input"			p goto: (r := EventSensor default peekPosition).
"smooth it"				s := (0.5*s) + (0.5*r).
"thin the stream"		((s x - t x) abs > 3 or:[(s y - t y) abs > 3]) ifTrue:
							[ pts nextPut: t. 
"bounding box"			bmin := bmin min: s. bmax := bmax max: s.
"get current dir"				dir := (self fourDirsFrom: t to: s). t := s.
							dir ~= ' dot... ' ifTrue: [
"store new dirs"					cdir ~= dir ifTrue: [ftrs := ftrs, (cdir := dir)]].
"for inked t's" 			p place: t; go: 1; place: r.
							].
 "End Each-Time Loop"	].

"Last-Time"	

"save last points"		pts nextPut: t; nextPut: r.
"find rest of features"	features := self extractFeatures.
"find char..."			char := CharacterDictionary at: features ifAbsent:
"...or get from user"			[ result := FillInTheBlank request:
							 'Not recognized. type char, or type ~: ', features.
"ignore or..."				result = '~' ifTrue: ['']
"...enter new char"			ifFalse: [CharacterDictionary at: features put: result. result]].

"control the editor"		(char = 'cr' ifTrue: [Transcript cr] ifFalse:
						[char = 'bs' ifTrue: [Transcript bs] ifFalse:
						[char = 'tab' ifTrue:[Transcript tab] ifFalse:
						[Transcript show: char]]]). 

"End First-Time Loop"	]. 

"End Event-Loop" ]. 

			   
 
]

{ #category : #recognizer }
CharRecog >> recognizeAndDispatch: charDispatchBlock ifUnrecognized: unrecognizedFeaturesBlock until: terminationBlock [
	"Recognize characters, and dispatch each one found by evaluating charDispatchBlock; proceed until terminationBlock is true.  This method derives directly from Alan's 1/96 #recognize method, but factors out the character dispatch and the termination condition from the main body of the method.  2/2/96 sw.   2/5/96 sw: switch to using a class variable for the character dictionary, and don't put vacuous entries in the dictionary if the user gives an empty response to the prompt, and don't send empty characters onward, and use a variant of the FillInTheBlank that keeps the prompt clear of the working window.  8/17/96 tk: Turn cr, tab, bs into strings so they work.
	 9/18/96 sw: in this variant, the block for handling unrecognized features is handed in as an argument, so that in some circumstances we can avoid putting up a prompt.  unrecognizedFeaturesBlock should be a one-argument block, which is handed in the features and which is expected to return a string which indicates the determined translation -- empty if none."

	| prv cdir features char r s t dir |

"Inits"				(p := Pen new) defaultNib: 1; down.
	"for points"		pts := ReadWriteStream on: #().

"Event Loop"	
					[terminationBlock value] whileFalse:

"First-Time"			[pts reset.		
"will hold features"		ftrs := ''.

					  (EventSensor default anyButtonPressed) ifTrue:
						[pts nextPut: (bmin := bmax := t := s := sts := EventSensor default peekPosition).
						p place: sts. cdir := nil.

"Each-Time"		[EventSensor default anyButtonPressed] whileTrue:
"ink raw input"			[p goto: (r := EventSensor default peekPosition).
"smooth it"				s := (0.5*s) + (0.5*r).
"thin the stream"		((s x - t x) abs > 3 or:[(s y - t y) abs > 3]) ifTrue:
							[pts nextPut: t. 
"bounding box"				bmin := bmin min: s. bmax := bmax max: s.
"get current dir"				dir := (self fourDirsFrom: t to: s). t := s.
							dir ~= ' dot... ' ifTrue:
"store new dirs"					[cdir ~= dir ifTrue: [ftrs := ftrs, (cdir := dir)]].
"for inked t's" 				p place: t; go: 1; place: r]].
 "End Each-Time Loop"

"Last-Time"	
"save last points"		pts nextPut: t; nextPut: r.
"find rest of features"	features := self extractFeatures.
"find char..."			char := CharacterDictionary at: features ifAbsent:
							[unrecognizedFeaturesBlock value: features].

"special chars"		char size > 0 ifTrue:
						[char = 'tab' ifTrue: [char := Tab].
						char = 'cr' ifTrue:	[char := CR].
"must be a string"		char class == Character ifTrue: 
							[char := String with: char].
						char = 'bs' ifTrue:	[char := BS].
"control the editor"		charDispatchBlock value: char]]]
 
]

{ #category : #recognizer }
CharRecog >> recognizeAndDispatch: charDispatchBlock until: terminationBlock [
	"Recognize characters, and dispatch each one found by evaluating charDispatchBlock; proceed until terminationBlock is true. 9/18/96 sw"

	^ self recognizeAndDispatch: charDispatchBlock
		ifUnrecognized: 
			[:features | self stringForUnrecognizedFeatures: features]
		until: terminationBlock
 
]

{ #category : #'historical & disused' }
CharRecog >> recognizeAndPutInTranscript [
	"Call Alan's recognizer repeatedly until the mouse is near the left edge of the screen, and dispatch keystrokes inferred to the Trancript.  2/2/96 sw"

	^ self recognizeAndDispatch:

		[:char | (char = 'cr') ifTrue: [Transcript cr] ifFalse:
						[char = 'bs' ifTrue: [Transcript bs] ifFalse:
						[char = 'tab' ifTrue:[Transcript tab] ifFalse:
						[Transcript show: char]]]]

		until:
			[EventSensor default peekPosition x < 50]

"CharRecog new recognizeAndPutInTranscript"
]

{ #category : #recognizer }
CharRecog >> regionOf: pt [ 

| px py reg xl yl yh xr rg |
"it's some other character"	rg := in/3. 	xl := bmin x + rg x. xr := bmax x - rg x.
"divide box into 9 regions"				yl := bmin y + rg y. yh := bmax y - rg y.

					px := pt x. py := pt y.
					reg := (px < xl ifTrue: [py < yl ifTrue: ['NW ']
										"py >= yl"	ifFalse:[ py < yh ifTrue:['W ']
																	ifFalse: ['SW ']]]
					ifFalse: [px < xr ifTrue: [py < yl ifTrue: ['N ']
													ifFalse: [py < yh ifTrue: ['C ']
																	ifFalse: ['S ']]]
					ifFalse: [py < yl ifTrue: ['NE ']
									ifFalse: [py < yh ifTrue: ['E ']
													ifFalse: ['SE ']]]]).
^reg.
					
]

{ #category : #recognizer }
CharRecog >> stringForUnrecognizedFeatures: features [
	"Prompt the user for what string the current features represent, and return the result.  9/18/96 sw"

	| result |
	result := FillInTheBlank request:
('Not recognized. type char, or "tab", "cr" or "bs",
or hit return to ignore 
', features).

	textMorph ifNotNil:
		[textMorph world displayWorld "take down the FillInTheBlank morph"].

	^ (result = '~' | result = '')
		ifTrue:
			['']
		ifFalse:
			[CharacterDictionary at: features put: result. result]
]

{ #category : #'morphic dockup' }
CharRecog >> textMorph: aTextMorph [
	textMorph := aTextMorph
]
