Class {
	#name : #PCXReadWriter,
	#superclass : #ImageReadWriter,
	#instVars : [
		'version',
		'encoding',
		'colorPlanes',
		'isGrayScale',
		'width',
		'height',
		'bitsPerPixel',
		'colorPalette',
		'rowByteSize'
	],
	#category : #'Graphics-Files'
}

{ #category : #'image reading\/writing' }
PCXReadWriter class >> typicalFileExtensions [
	"Answer a collection of file extensions (lowercase) which files that I can read might commonly have"
	^#('pcx')
]

{ #category : #accessing }
PCXReadWriter >> nextImage [
	"Read in the next PCX image from the stream."

	| bytes form |
	self readHeader.
	bytes := self readBody.
	colorPalette := self readPalette.
	self close.
	form := ColorForm extent: width@height depth: bitsPerPixel.
	(Form new hackBits: bytes) displayOn: (Form new hackBits: form bits).
	form colors: colorPalette.
	^ form

]

{ #category : #'private-decoding' }
PCXReadWriter >> nextWord [
	^self next + (self next bitShift: 8)
]

{ #category : #'private-decoding' }
PCXReadWriter >> readBody [

	| array scanLine rowBytes position byte count pad |
	pad := #(0 3 2 1) at: (width \\ 4 + 1).
	array := ByteArray new: ((width + pad) * height * bitsPerPixel) // 8.
	scanLine := ByteArray new: rowByteSize.
	position := 1.
	1 to: height do:
		[:line |
		rowBytes := 0.
		[rowBytes < rowByteSize] whileTrue:
			[byte := self next.
			byte < 16rC0
				ifTrue:
					[rowBytes := rowBytes + 1.
					scanLine at: rowBytes put: byte]
				ifFalse:
					[count := byte - 16rC0.
					byte := self next.
					1 to: count do: [:i | scanLine at: rowBytes + i put: byte].
					rowBytes := rowBytes + count]].
		array
			replaceFrom: position
			to: position + width - 1
			with: scanLine
			startingAt: 1.
		position := position + width + pad].
	^ array

]

{ #category : #'private-decoding' }
PCXReadWriter >> readHeader [

	| xMin xMax yMin yMax |
	self next.	"skip over manufacturer field"
	version := self next.
	encoding := self next.
	bitsPerPixel := self next.
	xMin := self nextWord.
	yMin := self nextWord.
	xMax := self nextWord.
	yMax := self nextWord.
	width := xMax - xMin + 1.
	height := yMax - yMin + 1.
	self next: 4. "skip over device resolution"
	self next: 49. "skip over EGA color palette"
	colorPlanes := self next.
	rowByteSize := self nextWord.
	isGrayScale := (self next: 2) = 2.
	self next: 58. "skip over filler"




]

{ #category : #'private-decoding' }
PCXReadWriter >> readPalette [

	| r g b array |
	self next = 12 ifFalse: [self error: 'no Color Palette!'].
	array := Array new: (1 bitShift: bitsPerPixel).
	1 to: array size do:
		[:i |
		r := self next.  g := self next.  b := self next.
		array at: i put: (Color r: r g: g b: b range: 255)].
	^ array.

]
