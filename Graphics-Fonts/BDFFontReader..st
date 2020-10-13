"
I am a conversion utility for reading X11 Bitmap Distribution Format fonts.  My code is derived from the multilingual Squeak changeset written by OHSHIMA Yoshiki (ohshima@is.titech.ac.jp), although all support for fonts with more than 256 glyphs has been ripped out.  See http://www.is.titech.ac.jp/~ohshima/squeak/squeak-multilingual-e.html .

My class methods contain tools for fetching BDF source files from a well-known archive site, batch conversion to Squeak's .sf2 format, and installation of these fonts as TextStyles.  Also, the legal notices for the standard 75dpi fonts I process this way are included as ""x11FontLegalNotices'.
"
Class {
	#name : #BDFFontReader,
	#superclass : #Object,
	#instVars : [
		'file',
		'properties'
	],
	#category : #'Graphics-Fonts'
}

{ #category : #'file creation' }
BDFFontReader class >> convertFilesNamed: fileName toFamilyNamed: familyName inDirectoryNamed: dirName [
		"BDFFontReader convertFilesNamed: 'helvR' toFamilyNamed: 'Helvetica' inDirectoryNamed: '' "

	"This utility converts X11 BDF font files to Squeak .sf2 StrikeFont files."

	"For this utility to work as is, the BDF files must be named 'familyNN.bdf',
	and must reside in the directory named by dirName (use '' for the current directory).
	The output StrikeFont files will be named familyNN.sf2, and will be placed in the
	current directory."

	| allFontNames dir |
	"Check for matching file names."
	dir := dirName isEmpty
		ifTrue: [FileDirectory default]
		ifFalse: [FileDirectory default directoryNamed: dirName].
	allFontNames := dir fileNamesMatching: fileName , '##.bdf'.
	allFontNames isEmpty ifTrue: [^ self error: 'No files found like ' , fileName , 'NN.bdf'].
	
	UIManager default informUserDuring: [:info |
		allFontNames do: [:fname | | f sizeChars | 
			info value: 'Converting ', familyName, ' BDF file ', fname, ' to SF2 format'.
			sizeChars := (fname copyFrom: fileName size + 1 to: fname size) copyUpTo: $. .

			f := StrikeFont new readBDFFromFile: (dir fullNameFor: fname) name: familyName, sizeChars.
			f writeAsStrike2named: familyName, sizeChars, '.sf2'.
		].
	]
]

{ #category : #'resource download' }
BDFFontReader class >> convertX11FontsToStrike2 [  "BDFFontReader convertX11FontsToStrike2"
	"Given a set of standard X11 BDF font files (probably downloaded via BDFFontReader downloadFonts), produce .sf2 format fonts.  The source and destination directory is the current directory."

	"Charter currently tickles a bug in the BDF parser.  Skip it for now."
	"self convertFilesNamed: 'charR' toFamilyNamed: 'Charter' inDirectoryNamed: ''."

	self convertFilesNamed: 'courR' toFamilyNamed: 'Courier' inDirectoryNamed: ''.
	self convertFilesNamed: 'helvR' toFamilyNamed: 'Helvetica' inDirectoryNamed: ''.

	self convertFilesNamed: 'lubR' toFamilyNamed: 'LucidaBright' inDirectoryNamed: ''.
	self convertFilesNamed: 'luRS' toFamilyNamed: 'Lucida' inDirectoryNamed: ''.
	self convertFilesNamed: 'lutRS' toFamilyNamed: 'LucidaTypewriter' inDirectoryNamed: ''.

	self convertFilesNamed: 'ncenR' toFamilyNamed: 'NewCenturySchoolbook' inDirectoryNamed: ''.
	self convertFilesNamed: 'timR' toFamilyNamed: 'TimesRoman' inDirectoryNamed: ''.
]

{ #category : #'resource download' }
BDFFontReader class >> downloadFonts [  "BDFFontReader downloadFonts"
	"Download a standard set of BDF sources from x.org.  
	The combined size of these source files is around 1.2M; after conversion 
	to .sf2 format they may be deleted."

	| heads tails filenames baseUrl basePath |
	heads := #( 'charR' 'courR' 'helvR' 'lubR' 'luRS' 'lutRS' 'ncenR' 'timR' ).
	tails := #( '08' '10' '12' '14' '18' '24').

	filenames := OrderedCollection new.
	heads do: [:head |
		filenames addAll: (tails collect: [:tail | head , tail , '.bdf'])
	].
	baseUrl := 'http://cvsweb.xfree86.org/cvsweb/*checkout*/xc/fonts/bdf/75dpi/' asUrl.
	basePath := baseUrl path.

	filenames do: [:filename |
		| document newPath newUrl |
		newUrl := baseUrl shallowCopy.
		newPath := OrderedCollection newFrom: basePath.

		newPath addLast: filename.
		newUrl path: newPath.

		UIManager default informUser: 'Fetching ' , filename during: 
			[document := newUrl retrieveContents].

		MultiByteFileStream newFileNamed: filename do: [ :f |
			f 
				wantsLineEndConversion: true;
				nextPutAll: document content ]
	].

]

{ #category : #documentation }
BDFFontReader class >> gettingAndInstallingTheFonts [

	"Download the 1.3M of BDF font source files from x.org:

		BDFFontReader downloadFonts.

	Convert them to .sf2 StrikeFont files:

		BDFFontReader convertX11FontsToStrike2.

	Install them into the system as TextStyles:

		BDFFontReader installX11Fonts.

	Read the legal notices in 'BDFFontReader x11FontLegalNotices' before
	redistributing images containing these fonts."
]

{ #category : #'resource download' }
BDFFontReader class >> installX11Fonts [ "BDFFontReader installX11Fonts"
	"Installs previously-converted .sf2 fonts into the TextConstants dictionary.  This makes them available as TextStyles everywhere in the image."

	| families |
	families := #( 'Courier' 'Helvetica' 'LucidaBright' 'Lucida' 'LucidaTypewriter' 'NewCenturySchoolbook' 'TimesRoman' ).

	families do: [:family | | fontArray textStyle |
		fontArray := StrikeFont readStrikeFont2Family: family.
		textStyle := TextStyle fontArray: fontArray.
		TextConstants at: family asSymbol put: textStyle.
	].

]

{ #category : #'file creation' }
BDFFontReader class >> openFileNamed: fileName [
	^self new openFileNamed: fileName
]

{ #category : #reading }
BDFFontReader >> errorFileFormat [
	self error: 'malformed bdf format'
]

{ #category : #reading }
BDFFontReader >> errorUnsupported [
	self error: 'unsupported bdf'
]

{ #category : #reading }
BDFFontReader >> getLine [
	^file nextLine
]

{ #category : #initialize }
BDFFontReader >> initialize [
	properties := Dictionary new.
]

{ #category : #initialize }
BDFFontReader >> openFileNamed: fileName [
	file := MultiByteFileStream readOnlyFileNamed: fileName.
	file wantsLineEndConversion: true
]

{ #category : #reading }
BDFFontReader >> read [
	| xTable strikeWidth glyphs ascent descent minAscii maxAscii maxWidth chars charsNum height form encoding bbx array width blt lastAscii pointSize ret stream |
	form := encoding := bbx := nil.
	self readAttributes.
	height := Integer readFromString: ((properties at: #FONTBOUNDINGBOX) at: 2).
	ascent := Integer readFromString: (properties at: #'FONT_ASCENT') first.
	descent := Integer readFromString: (properties at: #'FONT_DESCENT') first.
	pointSize := (Integer readFromString: (properties at: #'POINT_SIZE') first) // 10.
	
	maxWidth := 0.
	minAscii := 9999.
	strikeWidth := 0.
	maxAscii := 0.

	charsNum := Integer readFromString: (properties at: #CHARS) first.
	chars := Set new: charsNum.

	1 to: charsNum do: [:i |
		array := self readOneCharacter.
		stream := ReadStream on: array.
		form := stream next.
		encoding := stream next.
		bbx := stream next.
		form ifNotNil: [
			width := bbx at: 1.
			maxWidth := maxWidth max: width.
			minAscii := minAscii min: encoding.
			maxAscii := maxAscii max: encoding.
			strikeWidth := strikeWidth + width.
			chars add: array.
		].
	].

	chars := chars sorted: [:x :y | (x at: 2) <= (y at: 2)].
	charsNum := chars size. "undefined encodings make this different"

	charsNum > 256 ifTrue: [
		"it should be 94x94 charset, and should be fixed width font"
		strikeWidth := 94*94*maxWidth.
		maxAscii := 94*94.
		minAscii := 0.
		xTable := XTableForFixedFont new.
		xTable maxAscii: 94*94.
		xTable width: maxWidth.
	] ifFalse: [
		xTable := (Array new: 258) atAllPut: 0.
	].

	glyphs := Form extent: strikeWidth@height.
	blt := BitBlt toForm: glyphs.
	lastAscii := 0.
	
	charsNum > 256 ifTrue: [
		1 to: charsNum do: [:i |
			stream := ReadStream on: (chars at: i).
			form := stream next.
			encoding := stream next.
			bbx := stream next.
			encoding := ((encoding // 256) - 33) * 94 + ((encoding \\ 256) - 33).
			blt copy: ((encoding * maxWidth)@0 extent: maxWidth@height)
				from: 0@0 in: form.
		].
	] ifFalse: [
		1 to: charsNum do: [:i |
			stream := ReadStream on: (chars at: i).
			form := stream next.
			encoding := stream next.
			bbx := stream next.
			lastAscii+1 to: encoding-1 do: [:a | xTable at: a+2 put: (xTable at: a+1)].
			blt copy: (((xTable at: encoding+1)@(ascent - (bbx at: 2) - (bbx at: 4)))
					extent: (bbx at: 1)@(bbx at: 2))
				from: 0@0 in: form.
			xTable at: encoding+2 put: (xTable at: encoding+1)+(bbx at: 1).
			lastAscii := encoding.
		]
	].

	ret := Array new: 8.
	ret at: 1 put: xTable.
	ret at: 2 put: glyphs.
	ret at: 3 put: minAscii.
	ret at: 4 put: maxAscii.
	ret at: 5 put: maxWidth.
	ret at: 6 put: ascent.
	ret at: 7 put: descent.
	ret at: 8 put: pointSize.
	^ret.
" ^{xTable. glyphs. minAscii. maxAscii. maxWidth. ascent. descent. pointSize}"

]

{ #category : #reading }
BDFFontReader >> readAttributes [
	| str a |
	"I don't handle double-quotes correctly, but it works"
	file reset.
	[file atEnd] whileFalse: [
		str := self getLine.
		(str beginsWith: 'STARTCHAR') ifTrue: [file skip: (0 - str size - 1). ^self].
		a := str substrings.
		properties at: a first asSymbol put: a allButFirst.
	].
	self error: 'file seems corrupted'.
]

{ #category : #reading }
BDFFontReader >> readChars [
	| strikeWidth ascent descent minAscii maxAscii maxWidth chars charsNum height form encoding bbx array width pointSize stream |
	form := encoding := bbx := nil.
	self readAttributes.
	height := Integer readFromString: ((properties at: #FONTBOUNDINGBOX) at: 2).
	ascent := Integer readFromString: (properties at: #'FONT_ASCENT') first.
	descent := Integer readFromString: (properties at: #'FONT_DESCENT') first.
	pointSize := (Integer readFromString: (properties at: #'POINT_SIZE') first) // 10.
	
	maxWidth := 0.
	minAscii := 9999.
	strikeWidth := 0.
	maxAscii := 0.

	charsNum := Integer readFromString: (properties at: #CHARS) first.
	chars := Set new: charsNum.

	1 to: charsNum do: [:i |
		array := self readOneCharacter.
		stream := ReadStream on: array.
		form := stream next.
		encoding := stream next.
		bbx := stream next.
		form ifNotNil: [
			width := bbx at: 1.
			maxWidth := maxWidth max: width.
			minAscii := minAscii min: encoding.
			maxAscii := maxAscii max: encoding.
			strikeWidth := strikeWidth + width.
			chars add: array.
		].
	].

	^chars sorted: [:x :y | (x at: 2) <= (y at: 2)]
]

{ #category : #reading }
BDFFontReader >> readOneCharacter [
	| str a encoding bbx form bits hi low pos |
	((str := self getLine) beginsWith: 'ENDFONT') ifTrue: [^ {nil. nil. nil}].
	(str beginsWith: 'STARTCHAR') ifFalse: [self errorFileFormat].
	((str := self getLine) beginsWith: 'ENCODING') ifFalse: [self errorFileFormat].
	encoding := Integer readFromString: str substrings second.
	(self getLine beginsWith: 'SWIDTH') ifFalse: [self errorFileFormat].
	(self getLine beginsWith: 'DWIDTH') ifFalse: [self errorFileFormat].
	
	((str := self getLine) beginsWith: 'BBX') ifFalse: [self errorFileFormat].
	a := str substrings.
	bbx := (2 to: 5) collect: [:i | Integer readFromString: (a at: i)].
	((str := self getLine) beginsWith: 'ATTRIBUTES') ifTrue: [str := self getLine].
	(str beginsWith: 'BITMAP') ifFalse: [self errorFileFormat].

	form := Form extent: (bbx at: 1)@(bbx at: 2).
	bits := form bits.
	pos := 0.
	1 to: (bbx at: 2) do: [:t |
		1 to: (((bbx at: 1) - 1) // 8 + 1) do: [:i |
			hi := (('0123456789ABCDEF' indexOf: (file next asUppercase)) - 1) bitShift: 4.
			low := ('0123456789ABCDEF' indexOf: (file next asUppercase)) - 1.
			
			bits byteAt: (pos+i) put: (hi+low).
		].
		file next ~= Character cr ifTrue: [self errorFileFormat].
		pos := pos + ((((bbx at: 1) // 32) + 1) * 4).
	].

	(self getLine beginsWith: 'ENDCHAR') ifFalse: [self errorFileFormat].

	encoding < 0 ifTrue: [^{nil. nil. nil}].
	^{form. encoding. bbx}.
	
	
	
]
