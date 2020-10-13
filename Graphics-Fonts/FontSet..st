"
FontSet provides a mechanism for storing a set of fonts as a class that can be conveniently filedOut, filedIn, and installed as a TextStyle.

The most common use is...
	Find a font you like.
	Use BitFont to convert a bunch of sizes to data files named, eg, LovelyNN.BF
	Use FontSet convertFontsNamed: 'Lovely' to produce a FontSet named Lovely.
	FileOut that FontSet for later use.
	Use Lovely installAsTextStyle to make all sizes available in a TextStyle
		named #Lovely in the TextConstants dictionary.
	Use ctrl-k in any text pane to select the new Lovely style for that paragraph.
	Then use cmd-1 through 5 or cmd-k to set the point-size for any selection.

"
Class {
	#name : #FontSet,
	#superclass : #Object,
	#category : #'Graphics-Fonts'
}

{ #category : #compiling }
FontSet class >> acceptsLoggingOfCompilation [
	"Dont log sources for my subclasses, so as not to waste time
	and space storing printString versions of the string literals."

	^ self == FontSet
]

{ #category : #compiling }
FontSet class >> compileFont: strikeFont [ 
	| tempName literalString header sizeStr familyName |
	tempName := 'FontTemp.sf2'.
	strikeFont writeAsStrike2named: tempName.
	literalString := (Base64MimeConverter mimeEncode: (FileStream readOnlyFileNamed: tempName) binary) contents fullPrintString.
	sizeStr := strikeFont pointSize asString.
	familyName := strikeFont name first: (strikeFont name findLast: [:x | x isDigit not]).

	header := 'size' , sizeStr , '
	^ self fontNamed: ''' , familyName , sizeStr , ''' fromMimeLiteral:
' .
	self class
		compile: header , literalString
		classified: 'fonts'
		notifying: nil.
	FileDirectory default deleteFileNamed: tempName

]

{ #category : #'as yet unclassified' }
FontSet class >> convertFontsNamed: familyName [  "FontSet convertFontsNamed: 'Palatino' "
	^ self convertFontsNamed: familyName inDirectoryNamed: ''
]

{ #category : #converting }
FontSet class >> convertFontsNamed: familyName inDirectoryNamed: dirName [
		"FontSet convertFontsNamed: 'Tekton' inDirectoryNamed: 'Tekton Fonts' "
	"This utility is for use after you have used BitFont to produce data files 
	for the fonts you wish to use.  It will read the BitFont files and build
	a fontset class from them.  If one already exists, the sizes that can be
	found will be overwritten."
	"For this utility to work as is, the BitFont data files must be named 'familyNN.BF',
	and must reside in the directory named by dirName (use '' for the current directory)."

	| allFontNames fontSet dir |
	"Check first for matching file names and usable FontSet class name."
	dir := dirName isEmpty
		ifTrue: [FileDirectory default]
		ifFalse: [FileDirectory default directoryNamed: dirName].
	allFontNames := dir fileNamesMatching: familyName , '##.BF'.
	allFontNames isEmpty ifTrue: [^ self error: 'No files found like ' , familyName , 'NN.BF'].
	fontSet := self fontSetClass: familyName.
	allFontNames do:
		[:each |
		Transcript cr; show: each.
		fontSet compileFont: (StrikeFont new readFromBitFont: (dir fullNameFor: each))]
]

{ #category : #converting }
FontSet class >> convertTextStyleNamed: aString [
	| style fontSet |
	(style := TextStyle named: aString) ifNil: [^ self error: 'unknown text style ' , aString].
	fontSet := self fontSetClass: aString.
	style fontArray do: [:each | fontSet compileFont: each]
]

{ #category : #'filein\/out' }
FontSet class >> fileOut [
	"FileOut and then change the properties of the file so that it won't be
	treated as text by, eg, email attachment facilities"

	super fileOut.
	(FileStream oldFileNamed: self name , '.st') setFileTypeToObject; close
]

{ #category : #private }
FontSet class >> fontCategory [
	^ #'Graphics-Fonts'
]

{ #category : #private }
FontSet class >> fontName [

	self flag: #bob.		"temporary hack until I figure out what's happening here"
	(self name beginsWith: superclass name) ifFalse: [^self name].
	^ (self name copyFrom: superclass name size + 1 to: self name size) asSymbol
]

{ #category : #installing }
FontSet class >> fontNamed: fontName fromLiteral: aString [
	"NOTE -- THIS IS AN OBSOLETE METHOD THAT MAY CAUSE ERRORS.

The old form of fileOut for FontSets produced binary literal strings which may not be accurately read in systems with support for international character sets.  If possible, file the FontSet out again from a system that produces the newer MIME encoding (current def of compileFont:), and uses the corresponding altered version of this method.  If this is not easy, then
	file the fontSet into an older system (3.7 or earlier),
	assume it is called FontSetZork...
	execute FontSetZork installAsTextStyle.
	copy the compileFont: method from this system into that older one.
	remove the class FontSetZork.
	Execute:  FontSet convertTextStyleNamed: 'Zork', and see that it creates a new FontSetZork.
	FileOut the new class FontSetZork.
	The resulting file should be able to be read into this system.
"

	^ StrikeFont new 
		name: fontName;
		readFromStrike2Stream: (ReadStream on: aString asByteArray)
]

{ #category : #installing }
FontSet class >> fontNamed: fontName fromMimeLiteral: aString [
	"This method allows a font set to be captured as sourcecode in a subclass.
	The string literals will presumably be created by printing, eg,
		(FileStream readOnlyFileNamed: 'Palatino24.sf2') contentsOfEntireFile,
		and following the logic in compileFont: to encode and add a heading.

	See the method installAsTextStyle to see how this can be used."

	^ StrikeFont new 
		name: fontName;
		readFromStrike2Stream: (Base64MimeConverter mimeDecodeToBytes: aString readStream)
]

{ #category : #private }
FontSet class >> fontSetClass: aString [
	| className fontSet |
	className := (self name , (aString select: [:c | c isAlphaNumeric]) capitalized) asSymbol.
	fontSet := Smalltalk
		at: className
		ifAbsentPut: [self
			subclass: className
			instanceVariableNames: ''
			classVariableNames: ''
			poolDictionaries: ''
			category: self fontCategory].
	(fontSet inheritsFrom: self) ifFalse: [^ self error: 'The name ' , className , ' is already in use'].
	^ fontSet
]

{ #category : #installing }
FontSet class >> installAsDefault [  "FontSetNewYork installAsDefault"
	(UIManager default confirm: 'Do you want to install
''' , self fontName , ''' as default font?')
		ifFalse: [^ self].
	self installAsTextStyle.
	"TextConstants at: #OldDefaultTextStyle put: TextStyle default."
	TextConstants at: #DefaultTextStyle put: (TextStyle named: self fontName).
	#(ListParagraph PopUpMenu StandardSystemView) do:[:className|
		Smalltalk at: className ifPresent:[:aClass| aClass initialize].
	].
]

{ #category : #installing }
FontSet class >> installAsTextStyle [  "FontSetNewYork installAsTextStyle"
	| selectors |
	(TextConstants includesKey: self fontName) ifTrue:
		[(self confirm: 
self fontName , ' is already defined in TextConstants.
Do you want to replace that definition?')
			ifFalse: [^ self]].
	selectors := (self class selectors select: [:s | s beginsWith: 'size']) sort
		 replace: [:each | self perform: each].
	TextConstants
		at: self fontName
		put: (TextStyle fontArray: selectors)
]

{ #category : #installing }
FontSet class >> size: pointSize fromLiteral: aString [ 
	"This method allows a font set to be captured as sourcecode in a subclass.
	The string literals will presumably be created by printing, eg,
		(FileStream readOnlyFileNamed: 'Palatino24.sf2') contentsOfEntireFile,
		and then pasting into a browser after a heading like, eg,
size24
	^ self size: 24 fromLiteral:
	'--unreadable binary data--'

	See the method installAsTextStyle to see how this can be used."

	"This method is old and for backward compatibility only.
	please use fontNamed:fromLiteral: instead."

	self flag: #bob.	"used in Alan's projects"
	^(StrikeFont new)
		name: self fontName , (pointSize < 10 
							ifTrue: ['0' , pointSize printString]
							ifFalse: [pointSize printString]);
		readFromStrike2Stream: ((RWBinaryOrTextStream with: aString)
					reset;
					binary);
		yourself
]
