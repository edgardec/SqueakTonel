Class {
	#name : #EFontBDFFontReaderForRanges,
	#superclass : #EFontBDFFontReader,
	#category : #'Multilingual-Display'
}

{ #category : #ranges }
EFontBDFFontReaderForRanges class >> rangesForGreek [

	^ {
		Array with: 16r1 with: 16rFF.
		Array with: 16r370 with: 16r3FF.
		Array with: 16r1F00 with: 16r1FFF.
		Array with: 16r2000 with: 16r206F.
		Array with: 16r20A0 with: 16r20AF
	}.

]

{ #category : #ranges }
EFontBDFFontReaderForRanges class >> rangesForLatin2 [

	^ {
		Array with: 0 with: 16r17F.
		Array with: 16r2B0 with: 16r2FF.
		Array with: 16r2000 with: 16r206F.
		Array with: 16r2122 with: 16r2122.
		Array with: 16rFFFF with: 16rFFFF. "sentinel"
	}.

]

{ #category : #ranges }
EFontBDFFontReaderForRanges >> additionalRangesForJapanese [

	| basics |
	basics := {
		Array with: 16r5C with: 16rFF3C.
		Array with: 16r3013 with: 16rFFFD.
	}.
	^ basics

]

{ #category : #ranges }
EFontBDFFontReaderForRanges >> additionalRangesForKorean [

	| basics |
	basics := {
		Array with: 16rA1 with: 16rFFE6C.
		Array with: 16r3000 with: 16rFFFD.
	}.
	^ basics

]

{ #category : #ranges }
EFontBDFFontReaderForRanges >> override: chars with: otherFileName ranges: pairArray transcodingTable: table additionalRange: additionalRange [

	| other rangeStream newChars currentRange |
	other := BDFFontReader openFileNamed: otherFileName.

	rangeStream := ReadStream on: pairArray.
	currentRange := rangeStream next.

	newChars := PluggableSet new.
	newChars hashBlock: [:elem | (elem at: 2) hash].
	newChars equalBlock: [:a :b | (a at: 2) = (b at: 2)].

	other readChars do: [:array | | code u j form | 
		code := array at: 2.
		"code printStringHex printString displayAt: 0@0."
		code > currentRange last ifTrue: [
			[rangeStream atEnd not and: [currentRange := rangeStream next. currentRange last < code]] whileTrue.
			rangeStream atEnd ifTrue: [
				newChars addAll: chars.
				^ newChars.
			].
		].
		(code between: currentRange first and: currentRange last) ifTrue: [
			form := array at: 1.
			form ifNotNil: [
				j := array at: 2.
				u := table at: (((j // 256) - 33 * 94 + ((j \\ 256) - 33)) + 1).
				u ~= -1 ifTrue: [
					array at: 2 put: u.
					newChars add: array.
					additionalRange do: [:e | | newArray |
						e first = (array at: 2) ifTrue: [
							newArray := array shallowCopy.
							newArray at: 2 put: e second.
							newChars add: newArray
						].
					]
				].
			].
		].
	].

	self error: 'should not reach here'.

]

{ #category : #ranges }
EFontBDFFontReaderForRanges >> rangesForGreek [

	^ self class rangesForGreek

]

{ #category : #ranges }
EFontBDFFontReaderForRanges >> rangesForJapanese [

	| basics etc |
	basics := {
		Array with: 16r5C with: 16r5C.
		Array with: 16rA2 with: 16rA3.
		Array with: 16rA7 with: 16rA8.
		Array with: 16rAC with: 16rAC.
		Array with: 16rB0 with: 16rB1.
		Array with: 16rB4 with: 16rB4.
		Array with: 16rB6 with: 16rB6.
		Array with: 16rD7 with: 16rD7.
		Array with: 16rF7 with: 16rF7
	}.
	etc := {
		Array with: 16r370 with: 16r3FF. "greek"
		Array with: 16r400 with: 16r52F. "cyrillic"
		Array with: 16r1D00 with: 16r1D7F. "phonetic"
		Array with: 16r1E00 with: 16r1EFF. "latin extended additional"
		Array with: 16r2000 with: 16r206F. "general punctuation"
		Array with: 16r20A0 with: 16r20CF. "currency symbols"
		Array with: 16r2100 with: 16r214F. "letterlike"
		Array with: 16r2150 with: 16r218F. "number form"
		Array with: 16r2190 with: 16r21FF. "arrows"
		Array with: 16r2200 with: 16r22FF. "math operators"
		Array with: 16r2300 with: 16r23FF. "misc tech"
		Array with: 16r2460 with: 16r24FF. "enclosed alnum"
		Array with: 16r2500 with: 16r257F. "box drawing"
		Array with: 16r2580 with: 16r259F. "box elem"
		Array with: 16r25A0 with: 16r25FF. "geometric shapes"
		Array with: 16r2600 with: 16r26FF. "misc symbols"
		Array with: 16r2700 with: 16r27BF. "dingbats"
		Array with: 16r27C0 with: 16r27EF. "misc math A"
		Array with: 16r27F0 with: 16r27FF. "supplimental arrow A"
		Array with: 16r2900 with: 16r297F. "supplimental arrow B"
		Array with: 16r2980 with: 16r29FF. "misc math B"
		Array with: 16r2A00 with: 16r2AFF. "supplimental math op"
		Array with: 16r2900 with: 16r297F. "supplimental arrow B"
		Array with: 16r2E80 with: 16r2EFF. "cjk radicals suppliment"
		Array with: 16r2F00 with: 16r2FDF. "kangxi radicals"
		Array with: 16r3000 with: 16r303F. "cjk symbols"
		Array with: 16r3040 with: 16r309F. "hiragana"
		Array with: 16r30A0 with: 16r30FF. "katakana"
		Array with: 16r3190 with: 16r319F. "kanbun"
		Array with: 16r31F0 with: 16r31FF. "katakana extension"
		Array with: 16r3200 with: 16r32FF. "enclosed CJK"
		Array with: 16r3300 with: 16r33FF. "CJK compatibility"
		Array with: 16r3400 with: 16r4DBF. "CJK unified extension A"
		Array with: 16r4E00 with: 16r9FAF. "CJK ideograph"
		Array with: 16rF900 with: 16rFAFF. "CJK compatiblity ideograph"
		Array with: 16rFE30 with: 16rFE4F. "CJK compatiblity forms"
		Array with: 16rFF00 with: 16rFFEF. "half and full"
		Array with: 16rFFFF with: 16rFFFF. "sentinel"
	}.

	^ basics, etc.

]

{ #category : #ranges }
EFontBDFFontReaderForRanges >> rangesForKorean [

	| basics etc |
	basics := {
		Array with: 16rA1 with: 16rFF
	}.
	etc := {
		Array with: 16r100 with: 16r17F. "extended latin"
		Array with: 16r370 with: 16r3FF. "greek"
		Array with: 16r400 with: 16r52F. "cyrillic"
		Array with: 16r2000 with: 16r206F. "general punctuation"
		Array with: 16r2100 with: 16r214F. "letterlike"
		Array with: 16r2150 with: 16r218F. "number form"
		Array with: 16r2190 with: 16r21FF. "arrows"
		Array with: 16r2200 with: 16r22FF. "math operators"
		Array with: 16r2300 with: 16r23FF. "misc tech"
		Array with: 16r2460 with: 16r24FF. "enclosed alnum"
		Array with: 16r2500 with: 16r257F. "box drawing"
		Array with: 16r2580 with: 16r259F. "box elem"
		Array with: 16r25A0 with: 16r25FF. "geometric shapes"
		Array with: 16r2600 with: 16r26FF. "misc symbols"
		Array with: 16r3000 with: 16r303F. "cjk symbols"
		Array with: 16r3040 with: 16r309F. "hiragana"
		Array with: 16r30A0 with: 16r30FF. "katakana"
		Array with: 16r3190 with: 16r319F. "kanbun"
		Array with: 16r31F0 with: 16r31FF. "katakana extension"
		Array with: 16r3200 with: 16r32FF. "enclosed CJK"
		Array with: 16r3300 with: 16r33FF. "CJK compatibility"
		Array with: 16r4E00 with: 16r9FAF. "CJK ideograph"
		Array with: 16rAC00 with: 16rD7AF. "Hangul Syllables"
		Array with: 16rF900 with: 16rFAFF. "CJK compatiblity ideograph"
		Array with: 16rFF00 with: 16rFFEF. "half and full"
	}.

	^ basics, etc.

]

{ #category : #ranges }
EFontBDFFontReaderForRanges >> rangesForLatin2 [

	^ {
		Array with: 0 with: 16r17F.
		Array with: 16r2B0 with: 16r2FF.
		Array with: 16r2000 with: 16r206F.
		Array with: 16r2122 with: 16r2122.
		Array with: 16rFFFF with: 16rFFFF. "sentinel"
	}.

]

{ #category : #reading }
EFontBDFFontReaderForRanges >> readCharactersInRanges: ranges storeInto: chars [

	| array form code rangeStream currentRange |
	rangeStream := ReadStream on: ranges.
	currentRange := rangeStream next.
	[
		array := self readOneCharacter.
		array second ifNil: [^ self].
		code := array at: 2.
		code > currentRange last ifTrue: [
			[rangeStream atEnd not and: [currentRange := rangeStream next. currentRange last < code]] whileTrue.
			rangeStream atEnd ifTrue: [^ self].
		].
		(code between: currentRange first and: currentRange last) ifTrue: [
			form := array at: 1.
			form ifNotNil: [
				chars add: array.
			].
		].
	] repeat

]

{ #category : #reading }
EFontBDFFontReaderForRanges >> readRanges: ranges [

	| xTable glyphs ascent descent chars charsNum height form blt lastAscii pointSize ret lastValue start end encoding bbx strikeWidth minAscii maxAscii maxWidth |
	form := encoding := bbx := nil.
	self initialize.
	self readAttributes.
	height := Integer readFromString: ((properties at: #FONTBOUNDINGBOX) at: 2).
	ascent := Integer readFromString: (properties at: #'FONT_ASCENT') first.
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

	self readCharactersInRanges: ranges storeInto: chars.

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
	start := (ranges collect: [:r | r first]) min.
	end := (ranges collect: [:r | r second]) max + 3.

	xTable := SparseLargeTable new: end chunkSize: 64 arrayClass: Array base: start +1 defaultValue: -1.
	lastAscii := start.
	xTable at: lastAscii + 2 put: 0.
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
	xTable at: xTable size put: (xTable at: xTable size - 1).
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

{ #category : #reading }
EFontBDFFontReaderForRanges >> readRanges: ranges overrideWith: otherFileName otherRanges: otherRanges additionalOverrideRange: additionalRange [

	| xTable glyphs ascent descent chars charsNum height form blt lastAscii pointSize ret lastValue start end encoding bbx strikeWidth minAscii maxAscii maxWidth |
	form := encoding := bbx := nil.
	self initialize.
	self readAttributes.
	height := Integer readFromString: ((properties at: #FONTBOUNDINGBOX) at: 2).
	ascent := Integer readFromString: (properties at: #'FONT_ASCENT') first.
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

	self readCharactersInRanges: ranges storeInto: chars.
	chars := self override: chars with: otherFileName ranges: otherRanges transcodingTable: (UCSTable jisx0208Table) additionalRange: additionalRange.

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
	start := ((ranges collect: [:r | r first]), (additionalRange collect: [:r2 | r2 first])) min.
	end := ((ranges collect: [:r | r second]), (additionalRange collect: [:r2 | r2 second])) max + 3.
	"xRange := Array with: (Array with: ((ranges collect: [:r | r first]), (additionalRange collect: [:r2 | r2 first])) min
						with: (((ranges collect: [:r | r second]), (additionalRange collect: [:r2 | r2 second])) max + 2))."
	"xTable := XTableForUnicodeFont new
		ranges: xRange."
	xTable := SparseLargeTable new: end chunkSize: 64 arrayClass: Array base: start defaultValue: -1.
	lastAscii := start.
	xTable at: lastAscii + 2 put: 0.
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
	xTable at: xTable size put: (xTable at: xTable size - 1).
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
