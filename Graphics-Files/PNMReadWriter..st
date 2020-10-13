"
I am a subclass of ImageReadWriter that decodes portable anymap file formats
(pbm, pgm, ppm and  pam) images.

I accept the #origin pragma for SE files as described in:
Algoritms For Image Processing And Computer Vision. J. R. Parker

Don't work with 2 bytes samples (16 bit grays, > 32 bits color, etc...), 
pam files preliminary support.

f := ImageReadWriter formFromFileNamed: 'Tools:Squeak3.4:Carmen.ppm'.
f morphEdit

Submitted by Javier Diaz Reinoso, Oct/2003
"
Class {
	#name : #PNMReadWriter,
	#superclass : #ImageReadWriter,
	#instVars : [
		'first',
		'type',
		'origin',
		'cols',
		'rows',
		'depth',
		'maxValue',
		'tupleType',
		'pragma'
	],
	#category : #'Graphics-Files'
}

{ #category : #testing }
PNMReadWriter class >> testToSEFile: filename [
	"write SE file with origin
		PNMReadWriter testToSEFile: 'Tools:Squeak3.4:outSE.pbm'.
	"
	| prw f |
	prw := self new.
	prw stream: ((FileStream newFileNamed: filename) binary).
	prw pragma: '#origin 10 10', String lf.
	f := Form fromUser.
	prw nextPutImage: f
]

{ #category : #'image reading\/writing' }
PNMReadWriter class >> typicalFileExtensions [
	"Answer a collection of file extensions (lowercase) which files that I can read might commonly have"
	^#('pbm' 'pgm' 'pnm' 'ppm' 'pam')
]

{ #category : #reading }
PNMReadWriter >> cleanLine [
	"upTo LF or CR, tab as space"

	^stream nextLine ifNotNil: [:line | line replaceAll: Character tab with: Character space]
]

{ #category : #reading }
PNMReadWriter >> getTokenPbm: aCollection [
	"get a number, return rest of collection"
	| line tokens token |
	tokens := aCollection.
	tokens size = 0 ifTrue:[
		[
			line := self pbmGetLine.
			line ifNil:[^{nil . nil}].
			tokens := line findTokens: ' '.
			tokens size = 0
		] whileTrue:[].
	].
	"Transcript cr; show: tokens asString."
	token := tokens removeFirst.
	^{token asInteger . tokens}

]

{ #category : #reading }
PNMReadWriter >> nextImage [
	"read one image"
	| data p |
	first ifNil:[
		first := false.
		data := stream contentsOfEntireFile.
		stream := (RWBinaryOrTextStream with: data) reset.
	]
	ifNotNil:[
		type < 4 ifTrue:[
			self error:'Plain PBM, PGM or PPM have only one image'
		].
	].
	stream ascii.
	p := stream next.
	type := (stream next) asInteger - 48.
	(p = $P and:[type > 0 and:[type < 8]]) ifFalse:[
		self error:'Not a PNM file'
	].
	type = 7 ifTrue:[
		self readHeaderPAM
	]
	ifFalse: [
		self readHeader
	].
	type caseOf: {
		[1] 	->	[^self readPlainBW].
		[2] 	->	[^self readPlainGray].
		[3] 	->	[^self readPlainRGB].
		[4] 	->	[^self readBWreverse: false].
		[5] 	->	[^self readGray].
		[6] 	->	[^self readRGB].
		[7] 	->	[	"PAM"
					(tupleType asUppercase) caseOf: {
						['BLACKANDWHITE'] 		-> [^self readBWreverse: true].
						['GRAYSCALE'] 			-> [^self readGray].
						['RGB'] 					-> [^self readRGB].
						['RGB_ALPHA'] 			-> [^self error:'Not implemented'].
						['GRAYSCALE_ALPHA'] 	-> [^self error:'Not implemented'].
					} otherwise: [^self readData].
				]
	}
]

{ #category : #writing }
PNMReadWriter >> nextPutBW: aForm reverse: flagXor [
	| myType val nBytes bytesRow |
	cols := aForm width.
	rows := aForm height.
	depth := aForm depth.
	"stream position: 0."
	aForm depth = 1 ifTrue:[myType := $4] ifFalse:[myType := $5].
	self writeHeader: myType.
	stream binary.
	nBytes := (cols/8) ceiling.
	bytesRow := (cols/32) ceiling * 4.
	0 to: rows-1 do: [:y | | i |
		i := 1 + (bytesRow*y).
		0 to: nBytes-1 do: [:x |
			val := aForm bits byteAt: i.
			flagXor ifTrue:[val := val bitXor: 16rFF].
			stream nextPut: val.
			i := i+1.
		]
	].

]

{ #category : #writing }
PNMReadWriter >> nextPutGray: aForm [
	| myType val |
	cols := aForm width.
	rows := aForm height.
	depth := aForm depth.
	"stream position: 0."
	aForm depth = 1 ifTrue:[myType := $4] ifFalse:[myType := $5].
	self writeHeader: myType.
	0 to: rows-1 do: [:y |
		0 to: cols-1 do: [:x |
			val := aForm pixelValueAt: x@y.
			stream nextPut: val.
		]
	].

]

{ #category : #writing }
PNMReadWriter >> nextPutImage: aForm [
	aForm unhibernate.
	aForm depth	 caseOf: {
		[1] 		-> [self nextPutBW: aForm reverse: false].
		[16] 	-> [self nextPutRGB: aForm].
		[32] 	-> [self nextPutRGB: aForm].
	} otherwise: [
		(aForm respondsTo: #colors) ifTrue:[
			aForm colors ifNil: [
				self nextPutGray: aForm
			]
			ifNotNil: [
				self nextPutRGB: aForm
			]
		]
		ifFalse:[
			self nextPutGray: aForm
		]
	]
]

{ #category : #writing }
PNMReadWriter >> nextPutRGB: aForm [
	| myType f shift mask |
	cols := aForm width.
	rows := aForm height.
	depth := aForm depth.
	f := aForm.
	depth < 16 ifTrue:[
		f := aForm asFormOfDepth: 32.
		depth := 32.
	].
	myType := $6.
	"stream position: 0."
	self writeHeader: myType.
	depth = 32 ifTrue:[shift := 8. mask := 16rFF] ifFalse:[shift := 5. mask := 16r1F].
	0 to: rows-1 do: [:y |
		0 to: cols-1 do: [:x | | p r g b |
			p := f pixelValueAt: x@y.
			b := p bitAnd: mask. p := p >> shift.
			g := p bitAnd: mask. p := p >> shift.
			r := p bitAnd: mask.
			stream nextPut: r.
			stream nextPut: g.
			stream nextPut: b.
		]
	].

]

{ #category : #accessing }
PNMReadWriter >> origin [
	^origin
]

{ #category : #reading }
PNMReadWriter >> pbmGetLine [
	"Get the next non-comment line from the PBM stream
	Look for 'pragmas' - commands hidden in the comments"
	
 	| line |
	[
		line := self cleanLine.
		line ifNil: [^nil].
		(line size > 0 and:[(line at: 1) = $#]) ifTrue:[
			self pbmParam: line.
		].
		(line size = 0) or:[(line at: 1) = $#]
	]
 	whileTrue: [].
	^line
]

{ #category : #reading }
PNMReadWriter >> pbmParam: line [
	"Look for a parameter hidden in a comment"
	| key tokens |
	tokens := line findTokens: ' '.
	key := (tokens at: 1) asLowercase.
	(key = '#origin' and:[tokens size = 3]) ifTrue:[	"ORIGIN key word"
		"This is for SE files as described in:
		Algoritms For Image Processing And Computer Vision. J. R. Parker"
		origin := ((tokens at: 2) asInteger) @ ((tokens at: 3) asInteger)
	].

]

{ #category : #accessing }
PNMReadWriter >> pragma: s [
	pragma := s
]

{ #category : #reading }
PNMReadWriter >> r: r g: g b: b for: aDepth [
	"integer value according depth"
	| val |
	aDepth = 16 ifTrue: [
		val := (1 << 15) + (r << 10) + (g << 5) + b.
	]
	ifFalse:[
		val := (16rFF << 24) + (r << 16) + (g << 8) + b.
	].
	^val

]

{ #category : #reading }
PNMReadWriter >> readBWreverse: flagXor [
	"B&W for PAM"
	| val form bytesRow nBytes |
	stream binary.
	form := Form extent: cols@rows depth: 1.
	nBytes := (cols/8) ceiling.
	bytesRow := (cols/32) ceiling * 4.
	0 to: rows-1 do: [:y | | i |
		i := 1 + (bytesRow*y).
		0 to: nBytes-1 do: [:x |
			val := stream next.
			flagXor ifTrue:[val := val bitXor: 16rFF].
			form bits byteAt: i put: val.
			i := i+1.
		]
	].
	^form

]

{ #category : #reading }
PNMReadWriter >> readData [
	"generic data"
	| data nBits nBytes val sample |
	stream binary.
	data := OrderedCollection new.
	nBits := maxValue floorLog:2.
	nBytes := (nBits+1) >> 3.
	(nBits+1 rem: 8) > 0 ifTrue:[nBytes := nBytes+1].

	0 to: rows-1 do: [:y |
		0 to: cols-1 do: [:x |
			val := 0.
			1 to: nBytes do: [:n |
				sample := stream next.
				val := val << 8 + sample.
			].
			data add: val.
		]
	].
	^data


]

{ #category : #reading }
PNMReadWriter >> readGray [
	"gray form, return ColorForm with gray ramp"
	| form poker |
	maxValue > 255 ifTrue:[self error:'Gray value > 8 bits not supported in Squeak'].
	stream binary.
	form := ColorForm extent: cols@rows depth: depth.
	form colors: nil.
	poker := BitBlt bitPokerToForm: form.
	0 to: rows-1 do: [:y |
		0 to: cols-1 do: [:x |
			|val|
			val := stream next.
			poker pixelAt: x@y put: val.
		]
	].
	"a better way is using a gamma corrected palette"
	form colors: ((0 to: 255) collect:[:c|
		c > maxValue
			ifTrue:[Color white]
			ifFalse:[Color gray: (c/maxValue) asFloat]]).
	form colors at: 1 put: (Color black).
	^form

]

{ #category : #reading }
PNMReadWriter >> readHeader [
	"read header for pbm, pgm or ppm"
	| tokens aux d c  |
	tokens := OrderedCollection new.
	aux := self getTokenPbm: tokens.
	cols := aux at: 1. tokens := aux at: 2.
	aux := self getTokenPbm: tokens.
	rows := aux at: 1. tokens := aux at: 2.

	(type = 1 or:[type = 4]) ifTrue:[
		maxValue := 1
	]
	ifFalse: [
		aux := self getTokenPbm: tokens.
		maxValue := aux at: 1. tokens := aux at: 2.
	].
	d := {1 . 2 . 4 . 	8 . 		16 . 32}.
	c := {2 . 4 . 16 . 256 . 32768 . 16777216}. 
	(type = 3 or:[type = 6]) ifTrue: [
		maxValue >= 65536 ifTrue:[
			self error:'Pixmap > 48 bits not supported in PPM'
		].
		maxValue >= 256 ifTrue:[
			self error:'Pixmap > 32 bits are not supported in Squeak'
		].
		maxValue < 32 ifTrue:[depth := 16] ifFalse:[depth := 32].
	]
	ifFalse: [
		depth := nil.
		1 to: c size do:[:i| ((c at: i) > maxValue and:[depth = nil]) ifTrue:[depth:=d at: i]].
	].
	Transcript cr; show: 'PBM file class ', type asString, ' size ', cols asString, ' x ', 
		rows asString, ' maxValue =', maxValue asString, ' depth=', depth asString.

]

{ #category : #reading }
PNMReadWriter >> readHeaderPAM [
	"read pam header, not tested"
	| loop |
	tupleType := ''.
	loop := true.
	loop whileTrue:[ | key val tokens line |
		line := self pbmGetLine.
		tokens := line findTokens: ' '.
		tokens size = 2 ifTrue:[
			key := tokens at: 1 asUppercase.
			val := tokens at: 2.
			key caseOf: {
				['WIDTH'] 		-> [cols := val asInteger].
				['HEIGHT'] 		-> [rows := val asInteger].
				['DEPTH'] 		-> [depth := val asInteger].
				['MAXVAL']		-> [maxValue := val asInteger].
				['TUPLETYPE']	-> [tupleType := tupleType, ' ', val].
				['ENDHDR']		-> [loop := false].
			}
		]
	].
	Transcript cr; show: 'PAM file class ', type asString, ' size ', cols asString, ' x ', 
		rows asString, ' maxValue =', maxValue asString, ' depth=', depth asString.

]

{ #category : #reading }
PNMReadWriter >> readPlainBW [
	"plain BW"
	| val form poker |
	form := Form extent: cols@rows depth: depth.
	poker := BitBlt bitPokerToForm: form.
	0 to: rows-1 do: [:y |
		0 to: cols-1 do: [:x |
			[val := stream next. (val = $0 or:[val = $1])] whileFalse:[
				val ifNil:[self error:'End of file reading PBM'].
			].
			poker pixelAt: x@y put: (val asInteger).
		]
	].
	^form

]

{ #category : #reading }
PNMReadWriter >> readPlainGray [
	"plain gray"
	| val form poker aux tokens |
	form := Form extent: cols@rows depth: depth.
	poker := BitBlt bitPokerToForm: form.
	tokens := OrderedCollection new.
	0 to: rows-1 do: [:y |
		0 to: cols-1 do: [:x |
			aux := self getTokenPbm: tokens.
			val := aux at: 1. tokens := aux at: 2.
			poker pixelAt: x@y put: val.
		]
	].
	^form

]

{ #category : #reading }
PNMReadWriter >> readPlainRGB [
	"RGB form, use 32 bits"
	| val form poker tokens aux |
	maxValue > 255 ifTrue:[self error:'RGB value > 32 bits not supported in Squeak'].
	form := Form extent: cols@rows depth: 32.
	poker := BitBlt bitPokerToForm: form.
	tokens := OrderedCollection new.
	0 to: rows-1 do: [:y |
		0 to: cols-1 do: [:x | | r g b|
			aux := self getTokenPbm: tokens. r := aux at: 1. tokens := aux at: 2.
			aux := self getTokenPbm: tokens. g := aux at: 1. tokens := aux at: 2.
			aux := self getTokenPbm: tokens. b := aux at: 1. tokens := aux at: 2.
			val := self r: r g: g b: b for: depth.
			poker pixelAt: x@y put: val.
		]
	].
	^form

]

{ #category : #reading }
PNMReadWriter >> readRGB [
	"RGB form, use 16/32 bits"
	| val form poker sample shift |
	maxValue > 255 ifTrue:[self error:'RGB value > 32 bits not supported in Squeak'].
	stream binary.
	form := Form extent: cols@rows depth: depth.
	poker := BitBlt bitPokerToForm: form.
	depth = 32 ifTrue:[shift := 8] ifFalse:[shift := 5].
	0 to: rows-1 do: [:y |
		0 to: cols-1 do: [:x |
			val := 16rFF.	"no transparency"
			1 to: 3 do: [:i |
				sample := stream next.
				val := val << shift + sample.
			].
			poker pixelAt: x@y put: val.
		]
	].
	^form

]

{ #category : #accessing }
PNMReadWriter >> stream: s [
	stream := s
]

{ #category : #accessing }
PNMReadWriter >> tupleType [
	^tupleType
]

{ #category : #testing }
PNMReadWriter >> understandsImageFormat [
	"P1 to P7"
	| p  |
	p := stream next asCharacter.
	type := stream next - 48.
	^(p = $P and:[type > 0 and:[type < 8]])
	
]

{ #category : #writing }
PNMReadWriter >> writeHeader: myType [
	"this is ascii"
	stream nextPut: ($P asciiValue).
	stream nextPut: (myType asciiValue).
	stream nextPut: 10.		"nl"
	pragma ifNotNil:[
		stream nextPutAll: (pragma asByteArray).
	].
	stream nextPutAll: (cols printString) asByteArray.
	stream nextPut: 32.		" "
	stream nextPutAll: (rows printString) asByteArray.
	stream nextPut: 10.		"nl"
	depth > 1 ifTrue: [| d c maxV |
		d := {1 . 2 . 4  . 8   . 16 . 32}.
		c := {1 . 3 . 15 . 255 . 31 . 255}. 
		maxV := nil.
		1 to: d size do:[:i| ((d at: i) = depth and:[maxV = nil]) ifTrue:[maxV := c at: i]].
		stream nextPutAll: (maxV printString) asByteArray.
		stream nextPut: 10.		"nl"
	]
	
]
