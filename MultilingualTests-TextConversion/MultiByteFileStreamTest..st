Class {
	#name : #MultiByteFileStreamTest,
	#superclass : #TestCase,
	#instVars : [
		'fileName'
	],
	#category : #'MultilingualTests-TextConversion'
}

{ #category : #failures }
MultiByteFileStreamTest >> expectedFailures [
	^ #(testLineEndConversionExpectedFailures)
]

{ #category : #running }
MultiByteFileStreamTest >> tearDown [

	fileName ifNotNil: [
		FileDirectory default deleteFileNamed: fileName ]
]

{ #category : #tests }
MultiByteFileStreamTest >> testAsciiBackChunk [
	
	fileName := 'foobackchunk.txt'.
	MultiByteFileStream forceNewFileNamed: fileName do: [ :file |
		file 
			lineEndConvention: #cr; 
			converter: UTF8TextConverter new;
			cr; nextChunkPut: 'test1' printString;
			cr; nextChunkPut: 'test2' printString.
		self 
			assert: file backChunk = (String cr , 'test2' printString);
			assert: file backChunk = (String cr , 'test1' printString) ]
]

{ #category : #tests }
MultiByteFileStreamTest >> testBinaryUpTo [
	"This is a non regression test for bug http://bugs.squeak.org/view.php?id=6933"
	
	fileName := 'foobug6933'.
	MultiByteFileStream forceNewFileNamed: fileName do: [ :file |
		file
			binary;
			nextPutAll: #[ 1 2 3 4 ] ].
	MultiByteFileStream oldFileNamed: fileName do: [ :file |
		file binary.
		self assert: (file upTo: 3) = #[ 1 2 ] ]
]

{ #category : #tests }
MultiByteFileStreamTest >> testByteTextConverter [

	| byteCharacters converterClasses |
	byteCharacters := Character allByteCharacters.
	converterClasses := ByteTextConverter allSubclasses 
		copyWithoutAll: {ISO8859TextConverter . WinCPTextConverter . MacOSCPTextConverter}. 
	converterClasses do: [ :converterClass |
		| converter stream encoded decoded encoded2 |
		converter := converterClass new.
		stream := byteCharacters readStream.
		"Find bytes that can be decoded by this converter."
		encoded := byteCharacters select: [ :e | (converter nextFromStream: stream) notNil ].
		"Decode those bytes."
		stream := encoded readStream.
		decoded := encoded collect: [ :e | converter nextFromStream: stream ].
		self assert: stream atEnd.
		"Re-encode the decoded bytes using #nextPutAll:toStream:, and check if they match the original bytes."
		encoded2 := String streamContents: [ :writeStream |
			converter nextPutAll: decoded toStream: writeStream ].
		encoded with: encoded2 do: [ :original :reencoded |
			self 
				assert: original charCode = reencoded charCode
				description: [ '{1} could not decode or re-encode {2} using #nextPutAll:toStream:. Instead, it yielded {3}.'
					format: {
						converterClass name.
						original charCode.
						reencoded charCode } ] ].
		"Re-encode the decoded bytes using #nextPut:toStream:, and check if they match the original bytes."
		encoded2 := String streamContents: [ :writeStream |
			decoded do: [:e | converter nextPut: e toStream: writeStream ] ].
		encoded with: encoded2 do: [ :original :reencoded |
			self 
				assert: original charCode = reencoded charCode
				description: [ '{1} could not decode or re-encode {2} using #nextPut:toStream:. Instead, it yielded {3}.'
					format: {
						converterClass name.
						original charCode.
						reencoded charCode } ] ] ]
]

{ #category : #helpers }
MultiByteFileStreamTest >> testLineEndConvention: lineEndConvention withConverter: textConverterClass ifFail: failBlock [

	| expectedResult result |
	[
		MultiByteFileStream forceNewFileNamed: fileName do: [ :file |
			file
				converter: textConverterClass new;
				lineEndConvention: lineEndConvention;
				cr;
				nextPut: Character cr;
				nextPutAll: String cr;
				nextPutAll: String cr asWideString ].
		result := MultiByteFileStream oldFileNamed: fileName do: [ :file |
			file 
				converter: textConverterClass new; 
				contents ].
		expectedResult := String streamContents: [ :stream |
			4 timesRepeat: [ stream perform: lineEndConvention ] ].
		result = expectedResult ifFalse: [
			failBlock value: expectedResult asByteArray value: result asByteArray ] ]
		on: Error
		do: [ :err | failBlock value: err messageText value: err messageText ]
]

{ #category : #tests }
MultiByteFileStreamTest >> testLineEndConversion [

	| failures | 
	fileName := 'foolinendconversion.txt'.
	failures := OrderedCollection new.
	self textConvertersWithLineEndConversionSupport do: [ :textConverterClass |
		textConverterClass encodingNames ifNotEmpty: [
			#(cr lf crlf) do: [ :lineEndConvention |
				self
					testLineEndConvention: lineEndConvention
					withConverter: textConverterClass
					ifFail: [ :expectedResult :result |
						failures add: {
							textConverterClass.
							lineEndConvention.
							expectedResult.
							result } ] ] ] ].
	self assert: failures isEmpty.
	"The code below is here to help you see why those cases fail"
	failures do: [ :failure |
		self
			testLineEndConvention: failure second
			withConverter: failure first
			ifFail: [ :expectedResult :result | self halt ] ].
]

{ #category : #tests }
MultiByteFileStreamTest >> testLineEndConversionExpectedFailures [
	"Copy of #testLineEndConversion checking for missing line conversion implementations.
	 This test and corresponding helpers (see senders) can be removed as soon as all TextConverters support line end conversion. --fn"
	| failures |
	fileName := 'foolinendconversion_failures.txt'.
	failures := OrderedCollection new.
	self textConvertersWithoutLineEndConversionSupport do: [ :textConverterClass |
		textConverterClass encodingNames ifNotEmpty: [
			#(cr lf crlf) do: [ :lineEndConvention |
				self
					testLineEndConvention: lineEndConvention
					withConverter: textConverterClass
					ifFail: [ :expectedResult :result |
						failures add: {
							textConverterClass.
							lineEndConvention.
							expectedResult.
							result } ] ] ] ].
	self assert: failures isEmpty.
	"The code below is here to help you see why those cases fail"
	failures do: [ :failure |
		self
			testLineEndConvention: failure second
			withConverter: failure first
			ifFail: [ :expectedResult :result | self halt ] ].
]

{ #category : #tests }
MultiByteFileStreamTest >> testLineEnding [

	fileName := 'foolinend.txt'.
	MultiByteFileStream forceNewFileNamed: fileName do: [ :file |
		file 
			wantsLineEndConversion: false;
			nextPutAll: 'line 1'; cr;
			nextPutAll: 'line 2'; crlf;
			nextPutAll: 'line 3'; lf;
			nextPutAll: 'line 4' ].
	{
		{#cr.  'line 1' , String cr , 'line 2' , String cr , 'line 3' , String cr , 'line 4'}.
		{#lf.  'line 1' , String cr , 'line 2' , String cr , 'line 3' , String cr , 'line 4'}.
		{#crlf.  'line 1' , String cr , 'line 2' , String cr , 'line 3' , String cr , 'line 4'}.
		{nil.  'line 1' , String cr , 'line 2' , String crlf , 'line 3' , String lf , 'line 4'}
	} do: [:lineEndingResult |
		MultiByteFileStream oldFileNamed: fileName do: [ :file |
			file lineEndConvention: lineEndingResult first.
			self assert: file upToEnd = lineEndingResult last ] ]
]

{ #category : #tests }
MultiByteFileStreamTest >> testLineEndingChunk [
	| failures |
	fileName := 'foolinend.txt'.
	failures := OrderedCollection new.
	MultiByteFileStream forceNewFileNamed: fileName do: [ :file |
		file 
			wantsLineEndConversion: false;
			nextPutAll: 'line 1'; cr;
			nextPutAll: 'line 2'; crlf;
			nextPutAll: 'line 3'; lf;
			nextPutAll: 'line 4'; nextPut: $! ].
	{
		{#cr.  'line 1' , String cr , 'line 2' , String cr , 'line 3' , String cr , 'line 4'}.
		{#lf.  'line 1' , String cr , 'line 2' , String cr , 'line 3' , String cr , 'line 4'}.
		{#crlf.  'line 1' , String cr , 'line 2' , String cr , 'line 3' , String cr , 'line 4'}.
		{nil.  'line 1' , String cr , 'line 2' , String crlf , 'line 3' , String lf , 'line 4'}
	} do: [:lineEndingResult |
		MultiByteFileStream oldFileNamed: fileName do: [ :file | | actual |
			file lineEndConvention: lineEndingResult first.
			lineEndingResult last = (actual := file nextChunk) ifFalse: [
				failures add: (lineEndingResult copyWith: actual).
				].
			] ].
	self assert: failures isEmpty
]

{ #category : #tests }
MultiByteFileStreamTest >> testLineEndingWithWideStrings [

	| cr lf crlf |
	fileName := 'foolinend.txt'.
	cr := String cr asWideString.
	lf := String lf asWideString.
	crlf := String crlf asWideString.
	MultiByteFileStream forceNewFileNamed: fileName do: [ :file |
		file 
			wantsLineEndConversion: false;
			nextPutAll: 'line 1'; nextPutAll: cr;
			nextPutAll: 'line 2'; nextPutAll: crlf;
			nextPutAll: 'line 3'; nextPutAll: lf;
			nextPutAll: 'line 4' ].
	{
		{#cr.  'line 1' , String cr , 'line 2' , String cr , 'line 3' , String cr , 'line 4'}.
		{#lf.  'line 1' , String cr , 'line 2' , String cr , 'line 3' , String cr , 'line 4'}.
		{#crlf.  'line 1' , String cr , 'line 2' , String cr , 'line 3' , String cr , 'line 4'}.
		{nil.  'line 1' , String cr , 'line 2' , String crlf , 'line 3' , String lf , 'line 4'}
	} do: [ :lineEndingResult |
		MultiByteFileStream oldFileNamed: fileName do: [ :file |
			file lineEndConvention: lineEndingResult first.
			self assert: file upToEnd = lineEndingResult last ] ]
]

{ #category : #tests }
MultiByteFileStreamTest >> testMultiByteTextConverter [
	| strings converterClasses |
	strings := {
		String newFrom: ((0 to: 255) collect: [:e | Unicode value: e]).
		String newFrom: ((0 to: 1023) collect: [:e | Unicode value: e]).
	}.
	
	converterClasses := {
		UTF8TextConverter . UTF16TextConverter .
		"CompoundTextConverter ."
		"EUCJPTextConverter . CNGBTextConverter . ShiftJISTextConverter . EUCKRTextConverter"}.
	converterClasses do: [:converterClass |
		strings do: [:string |
			| converter stream |
			converter := converterClass new.
			stream := String new writeStream.
			converter nextPutAll: string toStream: stream.
			stream := stream contents readStream.
			string do: [:e | | decoded |
				decoded := converter nextFromStream: stream.
				self assert: e charCode = decoded charCode].
			self assert: stream atEnd.
	
			stream := String new writeStream.
			string do: [:e | converter nextPut: e toStream: stream].
			stream := stream contents readStream.
			string do: [:e | | decoded |
				decoded := converter nextFromStream: stream.
				self assert: e charCode = decoded charCode].
			self assert: stream atEnd]]
]

{ #category : #tests }
MultiByteFileStreamTest >> testNextLine [

	fileName := 'foonextline.txt'.
	MultiByteFileStream forceNewFileNamed: fileName do: [ :file |
		file
			wantsLineEndConversion: false;
			nextPutAll: 'line 1'; cr;
			nextPutAll: 'line 2'; crlf;
			nextPutAll: 'line 3'; lf;
			nextPutAll: 'line 4' ].
	#(cr lf crlf nil) do: [:lineEnding |
		MultiByteFileStream oldFileNamed: fileName do: [ :file |
			file lineEndConvention: lineEnding.
			self
				assert: file nextLine = 'line 1';
				assert: file nextLine = 'line 2';
				assert: file nextLine = 'line 3';
				assert: file nextLine = 'line 4';
				assert: file nextLine = nil ] ]
]

{ #category : #tests }
MultiByteFileStreamTest >> testNextPutAllStartingAt [

	| result |
	fileName := 'foonextputallstartingat.txt'.
	MultiByteFileStream forceNewFileNamed: fileName do: [ :file |
		{ 'abcde' asWideString. 'abcde' } do: [ :string |
			file 
				next: 1 putAll: string startingAt: 5;
				next: 3 putAll: string startingAt: 2;
				next: 1 putAll: string startingAt: 1 ] ].
	result := StandardFileStream readOnlyFileNamed: fileName do: [ :file |
		file binary; contents ].
	self assert: #[101 98 99 100 97 101 98 99 100 97] equals: result

]

{ #category : #tests }
MultiByteFileStreamTest >> testNextPutAllUtfsStartingAt [

	| result |
	fileName := 'foonextputallstartingat.txt'.
	{'utf-16' . #[0 64 216 0 220 0 216 0 220 1 216 0 220 2] .
	   'utf-32'. #[0 0 0 64 0 1 0 0 0 1 0 1 0 1 0 2]} 
		pairsDo: [:encodingName :encodingResult | 
		MultiByteFileStream forceNewFileNamed: fileName do: [ :file | | string |
			file converter: (TextConverter newForEncoding: encodingName).
			string := self unicodeString.
			file 
				next: 2 putAll: string startingAt: 1;
				next: 1 putAll: string startingAt: 3;
				next: 1 putAll: string startingAt: 4 ].
		result := StandardFileStream readOnlyFileNamed: fileName do: [ :file |
			file binary; contents ].
	
		"See for example: https://unicode-table.com/de/10000/ --pre"
		self assert: encodingResult equals: result]
	
	

]

{ #category : #tests }
MultiByteFileStreamTest >> testNonAsciiBackChunk [
	"Note: this is an expected failure: MultiByteFileStream is not equipped to read back non ASCII String... (no comment)
	As a consequence, never use non ASCII in method category nor in your initials. That would make a few tools blind..."
	
	fileName :=  'foobackchunk.txt'.
	MultiByteFileStream forceNewFileNamed: fileName do: [ :file |
		file 
			lineEndConvention: #cr; 
			converter: UTF8TextConverter new;
			cr; nextChunkPut: 'testé' printString;
			cr; nextChunkPut: 'test' printString.
		self assert: file backChunk = (String cr , 'test' printString).
		self assert: file backChunk = (String cr , 'testé' printString) ]
]

{ #category : #tests }
MultiByteFileStreamTest >> testUpToAllAscii [
	"This test case is inspired by Mantis #4665."
	"Compare to testUpToAllUtf."
	
	| resultA resultB |
	fileName :='testUpToAll.in'.
	FileDirectory default forceNewFileNamed: fileName do: [ :out |
		out nextPutAll: 'A<'. "Encodes to byte sequence 413C" ].

	resultA := FileDirectory default readOnlyFileNamed: fileName do: [ :in |
		in upToAll: '<' ].

	resultB := FileDirectory default readOnlyFileNamed: fileName do: [ :in |
		in upTo: $< ].

	self assert: resultA = resultB

]

{ #category : #tests }
MultiByteFileStreamTest >> testUpToAllNonZeroLength [
	"Ensures that upToAll: correctly skips over the nonzero-length separator."
	
	fileName :='testUpToAll.in'.
	FileDirectory default forceNewFileNamed: fileName do: [ :out |
		out nextPutAll: 231 asCharacter asString, 'a<b<<c' ].

	FileDirectory default readOnlyFileNamed: fileName do: [ :in |
		self assert: in next = 231 asCharacter.
		self assert: (in upToAll: '<<') = 'a<b'.
		self assert: in next = $c ]
]

{ #category : #tests }
MultiByteFileStreamTest >> testUpToAllUtf [
	"This test case is adapted from Mantis #4665."
	"MultiByteFileStream was relying on PositionableStream>>#match: to discover the position immediately following the delimiter collection. It would then use #next: to retrieve a number of *characters* computed as the difference in stream positions. However, stream positions are measured in *bytes*, not characters, so this would lead to misalignment when the skipped text included UTF-8 encoded characters."
	
	| resultA resultB |
	fileName :='testUpToAll.in'.
	FileDirectory default forceNewFileNamed: fileName do: [ :out |
		out nextPutAll: 231 asCharacter asString, '<'. "Encodes to byte sequence C3A73C" ].

	resultA := FileDirectory default readOnlyFileNamed: fileName do: [ :in |
		in upToAll: '<' ].

	resultB := FileDirectory default readOnlyFileNamed: fileName do: [ :in |
		in upTo: $< ].

	self assert: resultA = resultB

]

{ #category : #tests }
MultiByteFileStreamTest >> testUpToAllZeroLength [
	"Ensures that upToAll: behaves correctly with a zero-length separator."
	
	fileName :='testUpToAll.in'.
	FileDirectory default forceNewFileNamed: fileName do: [ :out |
		out nextPutAll: 231 asCharacter asString, 'a<b<<c' ].

	FileDirectory default readOnlyFileNamed: fileName do: [ :in |
		self assert: in next = 231 asCharacter.
		self assert: (in upToAll: '') = ''.
		self assert: in next = $a ]
]

{ #category : #tests }
MultiByteFileStreamTest >> testUpToPositionNonZero [
	"Ensures that upToPosition: behaves correctly with a non-zero-length read."

	fileName := 'testUpToPosition.in'.
	FileDirectory default forceNewFileNamed: fileName do: [ :out |
		out nextPutAll: 231 asCharacter asString, 'a<b' ].

	FileDirectory default readOnlyFileNamed: fileName do: [ :in |
		self assert: in next = 231 asCharacter.
		self assert: (in upToPosition: in position + 2) = 'a<'.
		self assert: in next = $b ]
]

{ #category : #tests }
MultiByteFileStreamTest >> testUpToPositionZero [
	"Ensures that upToPosition: behaves correctly with a zero-length read."

	fileName := 'testUpToPosition.in'.
	FileDirectory default forceNewFileNamed: fileName do: [ :out |
		out nextPutAll: 231 asCharacter asString, 'a<b' ].

	FileDirectory default readOnlyFileNamed: fileName do: [ :in |
		self assert: in next = 231 asCharacter.
		self assert: (in upToPosition: in position) = ''.
		self assert: in next = $a ]
]

{ #category : #helpers }
MultiByteFileStreamTest >> textConvertersWithLineEndConversionSupport [
	self flag: #testLineEndConversionExpectedFailures.
	^ TextConverter allSubclasses difference: self textConvertersWithoutLineEndConversionSupport
]

{ #category : #helpers }
MultiByteFileStreamTest >> textConvertersWithoutLineEndConversionSupport [
	self flag: #testLineEndConversionExpectedFailures.
	^ EUCTextConverter allSubclasses union: {ShiftJISTextConverter. CompoundTextConverter. KOI8RTextConverter}
]

{ #category : #fixtures }
MultiByteFileStreamTest >> unicodeString [

	^ String newFrom: (#(64 65536 65537 65538) collect: [:n | Character codePoint: n])
]
