Class {
	#name : #XBMReadWriter,
	#superclass : #ImageReadWriter,
	#instVars : [
		'width',
		'height'
	],
	#classVars : [
		'Flipbits'
	],
	#category : #'Graphics-Files'
}

{ #category : #'class initialization' }
XBMReadWriter class >> initialize [
	"XBMReadWriter initialize"
	Flipbits := (0 to: 255) collect:
		[:n |  "Compute the bit-reversal of the 8-bit value, n"
		| flippedByte |
		flippedByte := 0.
		0 to: 7 do: 
			[:i | 
			flippedByte := flippedByte bitOr: ((n >> i bitAnd: 1) << (7-i))].
			flippedByte]
]

{ #category : #'class initialization' }
XBMReadWriter class >> typicalFileExtensions [
	"Answer a collection of file extensions (lowercase) which files that I can read might commonly have"
	^#('xbm')
]

{ #category : #accessing }
XBMReadWriter >> nextImage [
	"Read in the next xbm image from the stream."
	| form long incount chunks byteWidth pad fourway outcount total |
	stream reset.
	stream ascii.
	self readHeader.
	form := ColorForm extent: width@height depth: 1.
	incount := 0.	outcount :=1.
	chunks := Array new: 4.	byteWidth := width + 7 // 8.
	total := byteWidth * height.
	byteWidth > 4
		ifTrue: [ pad := byteWidth \\ 4]
		ifFalse: [ pad := 4 - byteWidth ].
	fourway := 0.
	[(incount = total)] whileFalse: [
		incount := incount + 1.
		fourway := fourway + 1.
		chunks at: fourway put: (Flipbits at: ((self parseByteValue) +1)).
		(pad > 0 and: [(incount \\ byteWidth) = 0]) ifTrue: [
			1 to: pad do:
				[:q |	
  			fourway := fourway + 1.	
			chunks at: fourway put: 0]
		].
		fourway = 4 ifTrue: [
			long := Integer
				byte1: (chunks at: 4)
				byte2: (chunks at: 3)
				byte3: (chunks at: 2)
				byte4: (chunks at: 1).
			(form bits) at: outcount put: long.
			fourway := 0.
			outcount := outcount + 1].
		].
	 ^ form 
]

{ #category : #private }
XBMReadWriter >> parseByteValue [
	"skip over separators and return next bytevalue parsed as a C language number:
		0ddd is an octal digit.
		0xddd is a hex digit.
		ddd is decimal."
	| source mybase |
	stream skipSeparators.
	source := stream upToAnyOf: CharacterSet separators.
	source = '0' ifTrue: [^0]..
	mybase := 10. "Base 10 default"
	source := source asUppercase readStream.
	(source peekFor: $0) ifTrue: [
		mybase := 8. "Octal or Hex, say its Octal unless overridden."
		(source peekFor: $X) ifTrue: [
			mybase := 16. "Ah.  It's Hex."
			]
		].
	^ Integer readFrom: source base: mybase
]

{ #category : #private }
XBMReadWriter >> readHeader [
	"Set width and height, and position stream at start of bytes"
	| number setwidth setheight fieldName |
	setwidth := setheight := false.
		[((stream atEnd) or: [setwidth and: [setheight]])]
		whileFalse: [
	  	self skipCComments.
		(stream nextMatchAll: '#define ') ifFalse: [^ false].
		(stream skipTo: $_) ifFalse: [^ false].
		fieldName := String streamContents:
			[:source |
			[(stream atEnd) or: [ stream peek isSeparator ]]
				whileFalse: [ source nextPut: stream next]].
	  	(fieldName = 'width') ifTrue: [
			stream skipSeparators.
			number := Integer readFrom: stream.
			(number > 0) ifTrue: [setwidth := true].
	  		width := number.].
		(fieldName = 'height') ifTrue: [
			stream skipSeparators.
			number := Integer readFrom: stream.
			(number > 0) ifTrue: [setheight := true].
			height := number.
			].
		].
	(setwidth & setheight) ifFalse: [^ false].
	^ stream skipTo: ${

]

{ #category : #private }
XBMReadWriter >> skipCComments [
	[ stream skipSeparators.
	stream peekFor: $/ ] whileTrue: [
		stream next.		"skip next *"
		[ (stream skipTo: $*) ifFalse: [ ^false ].
			stream peekFor: $/ ] whileFalse ]
]

{ #category : #accessing }
XBMReadWriter >> understandsImageFormat [
	"Test to see if the image stream format is understood by this decoder.	This should be implemented in each subclass of ImageReadWriter so that	a proper decoder can be selected without ImageReadWriter having to know about all possible image file types."
	| first |
	stream ascii.
	self skipCComments.
	first := (stream next: 7) asString.
	stream binary.
	^ (first = '#define')
]
