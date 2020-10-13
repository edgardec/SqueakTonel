Class {
	#name : #EFontBDFFontReader,
	#superclass : #BDFFontReader,
	#category : #'Multilingual-Display'
}

{ #category : #reading }
EFontBDFFontReader >> readCharactersInRangeFrom: start to: stop totalNums: upToNum storeInto: chars [

	| array form code |
	1 to: upToNum do: [:i |
		array := self readOneCharacter.
		code := array at: 2.
		code > stop ifTrue: [^ self].
		(code between: start and: stop) ifTrue: [
			form := array at: 1.
			form ifNotNil: [
				chars add: array.
			].
		].
	].

]

{ #category : #reading }
EFontBDFFontReader >> readFrom: start to: end [

	| xTable glyphs ascent descent chars charsNum height form blt lastAscii pointSize ret lastValue encoding bbx strikeWidth minAscii maxAscii maxWidth |
	form := encoding := bbx := nil.
	self initialize.
	self readAttributes.
	height := Integer readFromString: ((properties at: #FONTBOUNDINGBOX) at: 2).
	ascent := Integer readFromString: (properties at: #'FONT_ASCENT')  first.
	descent := Integer readFromString: (properties at: #'FONT_DESCENT') first.
	(properties includesKey: #'POINT_SIZE') ifTrue: [
		pointSize := (Integer readFromString: (properties at: #'POINT_SIZE') first) // 10.
	] ifFalse: [
		pointSize := (ascent + descent) * 72 // 96.
	].
		
	
	maxWidth := 0.
	minAscii := 16r200000.
	strikeWidth := 0.
	maxAscii := 0.

	charsNum := Integer readFromString: (properties at: #CHARS) first.
	chars := Set new: charsNum.

	self readCharactersInRangeFrom: start to: end totalNums: charsNum storeInto: chars.

	chars := chars sorted: [:x :y | (x at: 2) <= (y at: 2)].
	charsNum := chars size. "undefined encodings make this different"

	chars do: [:array | | width |
		encoding := array at: 2.
		bbx := array at: 3..
		width := bbx at: 1.
		maxWidth := maxWidth max: width.
		minAscii := minAscii min: encoding.
		maxAscii := maxAscii max: encoding.
		strikeWidth := strikeWidth + width.
	].
	glyphs := Form extent: strikeWidth@height.
	blt := BitBlt toForm: glyphs.
	"xTable := XTableForUnicodeFont new ranges: (Array with: (Array with: start with: end))."
	xTable := SparseLargeTable new: end + 3 chunkSize: 32 arrayClass: Array base: start + 1 defaultValue: -1.
	lastAscii := start.	
	1 to: charsNum do: [:i |
		form := (chars at: i) first.
		encoding := (chars at: i) second.
		bbx := (chars at: i) third.
		"lastAscii+1 to: encoding-1 do: [:a | xTable at: a+2 put: (xTable at: a+1)]."
		lastValue := xTable at: lastAscii + 1 + 1.
		xTable at: encoding + 1 put: lastValue.
		blt copy: (((xTable at: encoding+1)@(ascent - (bbx at: 2) - (bbx at: 4)))
				extent: (bbx at: 1)@(bbx at: 2))
			from: 0@0 in: form.
		xTable at: encoding+2 put: (xTable at: encoding+1)+(bbx at: 1).
		lastAscii := encoding.
	].

	xTable zapDefaultOnlyEntries.
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
