"
This is the unit test for the class Text. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #TextTest,
	#superclass : #ClassTestCase,
	#category : #'CollectionsTests-Text'
}

{ #category : #fixtures }
TextTest >> fixturesFormat [

	^ {
		{ '\{ \} \\ foo {1} bar {2}' asText
				addAttribute: TextEmphasis bold from: 3 to: 10;
				addAttribute: TextEmphasis italic from: 12 to: 18;
				yourself.
			#(12 'string').
			'{ } \ foo 12 bar string' asText
				addAttribute: TextEmphasis bold from: 2 to: 7;
				addAttribute: TextEmphasis italic from: 9 to: 14;
				yourself }.
		{ '\{ \} \\ foo {2} bar {1}' asText.
			{ 'string' asText
				addAttribute: TextEmphasis bold from: 2 to: 4;
				yourself.
				12 }.
			'{ } \ foo 12 bar string' asText
				addAttribute: TextEmphasis bold from: 19 to: 21;
				yourself }.
		{ '\{1}' asText.
			#().
			'{1}' asText }.
		{ '\{1}{1}' asText allBold.
			{ $a asText
				addAttribute: TextEmphasis italic;
				yourself }.
			'{1}a' asText allBold
				addAttribute: TextEmphasis italic from: 4 to: 4;
				yourself }.
		{ 'foo' asText.
			#().
			'foo' asText }.
	}
]

{ #category : #fixtures }
TextTest >> fixturesFormatErrors [

	^ #(
		'{1 }'
		'{1abc}'
		'{ 1}'
		'{ 1.0 }'
		'{1'
		'{1 foo'
		'{2}'
		'{0}'
		'{-0}'
		'{-1}'
	)
]

{ #category : #tests }
TextTest >> test01ColorAt [

	| text |
	text := Text fromString: 'Hello'.
	self assert: Color black equals: (text colorAt: 1).
	self should: [text colorAt: 1 ifNone: [Error signal]] raise: Error.

	text := Text string: 'Hello' attribute: (TextColor color: Color gray).
	self assert: Color gray equals: (text colorAt: 1).
	
]

{ #category : #tests }
TextTest >> test02Format [

	self fixturesFormat do: [ :fixture | | expectedResult actualResult |
		expectedResult := fixture third.
		actualResult := fixture first format: fixture second.
		self
			assert: expectedResult equals: actualResult;
			assert: expectedResult runs size equals: actualResult runs size.
		1 to: expectedResult size do: [ :i |
			self
				assert: (expectedResult attributesAt: i) asSet
				equals: (actualResult attributesAt: i) asSet ] ]
]

{ #category : #tests }
TextTest >> test03FormatErrors [

	self fixturesFormatErrors do: [ :each |
		self should: [ each asText format: { 'x' } ] raise: Error ]
]

{ #category : #tests }
TextTest >> test04AddAttribute [

	| text attributeOne attributeTwo |
	text := Text fromString: 'abc'.
	attributeOne := TextEmphasis bold.
	attributeTwo := TextColor color: Color yellow.

	1 to: text size do: [:index |
		self assert: (text attributesAt: index) isEmpty].	

	text addAttribute: attributeOne.
	1 to: text size do: [:index |
		self assert: {attributeOne} equals: (text attributesAt: index)].

	text addAttribute: attributeTwo.
	1 to: text size do: [:index |
		self assert: {attributeOne. attributeTwo} equals: (text attributesAt: index)].

]

{ #category : #tests }
TextTest >> test05AddAttributeFromTo [

	| text attributeOne attributeTwo |
	attributeOne := TextEmphasis bold.
	attributeTwo := TextColor color: Color yellow.

	text := Text fromString: 'abc'.
	self assert: (text attributesAt: 1) isEmpty.	
	self assert: (text attributesAt: 2) isEmpty.	
	self assert: (text attributesAt: 3) isEmpty.	

	text addAttribute: attributeOne from: 2 to: 3.
	self assert: (text attributesAt: 1) isEmpty.	
	self assert: {attributeOne} equals: (text attributesAt: 2).
	self assert: {attributeOne} equals: (text attributesAt: 3).
	
	text addAttribute: attributeTwo from: 1 to: 2.
	self assert: {attributeTwo} equals: (text attributesAt: 1).	
	self assert: {attributeOne. attributeTwo} equals: (text attributesAt: 2).
	self assert: {attributeOne} equals: (text attributesAt: 3).

]

{ #category : #tests }
TextTest >> test06AddAllAttributes [

	| text attributeOne attributeTwo |
	attributeOne := TextEmphasis bold.
	attributeTwo := TextColor color: Color yellow.

	text := Text fromString: 'abc'.
	self assert: (text attributesAt: 1) isEmpty.	
	self assert: (text attributesAt: 2) isEmpty.	
	self assert: (text attributesAt: 3) isEmpty.	

	text addAllAttributes: {attributeOne. attributeTwo}.
	self assert: {attributeOne. attributeTwo} equals: (text attributesAt: 1).	
	self assert: {attributeOne. attributeTwo} equals: (text attributesAt: 2).
	self assert: {attributeOne. attributeTwo} equals: (text attributesAt: 3).
]

{ #category : #tests }
TextTest >> test07AddAllAttributesFromTo [

	| text attributeOne attributeTwo |
	attributeOne := TextEmphasis bold.
	attributeTwo := TextColor color: Color yellow.

	text := Text fromString: 'abc'.
	self assert: (text attributesAt: 1) isEmpty.	
	self assert: (text attributesAt: 2) isEmpty.	
	self assert: (text attributesAt: 3) isEmpty.	

	text addAllAttributes: {attributeOne. attributeTwo} from: 2 to: 3.
	self assert: (text attributesAt: 1) isEmpty.	
	self assert: {attributeOne. attributeTwo} equals: (text attributesAt: 2).
	self assert: {attributeOne. attributeTwo} equals: (text attributesAt: 3).
]

{ #category : #'tests - runs checking' }
TextTest >> testSetStringSetRunsChecking [
	"Normal case of creating a Text from a string and a run array with matching size"

	| aString runs aText newText |
	aString := 'The best way to predict the future'.
	runs := (RunArray runs: #(4 4 8 7 5 6) values: ((Array new: 6) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); at: 6 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); yourself)).

	self assert: aString size = runs size.

	aText := (Text string: 'The best way to predict the future' runs: (RunArray runs: #(4 4 8 7 5 6) values: ((Array new: 6) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); at: 6 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); yourself))).

	newText := Text basicNew setString: aString setRunsChecking: runs.
	self assert: newText equals: aText.
	self assert: newText runs size = aString size.
	self assert: runs equals: newText runs.
	self assert: 6 equals: aText runs values size.
	self assert: 6 equals: newText runs values size.



]

{ #category : #'tests - runs checking' }
TextTest >> testSetStringSetRunsCheckingLongRuns [
	"Creating text from a string and a long run array should create a valid Text instance,
	and should retain text styling if possible."

	| aString aText newText lastRunTooLong oneRunTooMany |
	aString := 'The best way to predict the future'.
	lastRunTooLong := (RunArray runs: #(4 4 8 7 5 100) values: ((Array new: 6) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); at: 6 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); yourself)).

	self deny: aString size = lastRunTooLong size.

	oneRunTooMany := (RunArray runs: #(4 4 8 7 5 6 4) values: ((Array new: 7) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); at: 6 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 7 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself)).

	self deny: aString size = oneRunTooMany size.

	aText := (Text string: 'The best way to predict the future' runs: (RunArray runs: #(4 4 8 7 5 6) values: ((Array new: 6) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); at: 6 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); yourself))).

	self assert: 6 equals: aText runs values size.

	newText := Text basicNew setString: aString setRunsChecking: lastRunTooLong.
	self assert: newText equals: aText.
	self assert: newText runs size = aString size.
	self assert: 6 equals: newText runs values size.

	newText := Text basicNew setString: aString setRunsChecking: oneRunTooMany.
	self assert: newText equals: aText.
	self assert: newText runs size = aString size.
	self assert: 6 equals: newText runs values size.




]

{ #category : #'tests - runs checking' }
TextTest >> testSetStringSetRunsCheckingShortRuns [
	"Creating text from a string and a short run array should create a valid Text instance,
	and should retain text styling if possible."

	| aString aText newText lastRunTooShort missingLastRun |
	aString := 'The best way to predict the future'.
	lastRunTooShort := (RunArray runs: #(4 4 8 7 5 1) values: ((Array new: 6) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); at: 6 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); yourself)).

	self deny: aString size = lastRunTooShort size.

	missingLastRun := (RunArray runs: #(4 4 8 7 5) values: ((Array new: 5) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); yourself)).

	self deny: aString size = missingLastRun size.

	aText := (Text string: 'The best way to predict the future' runs: (RunArray runs: #(4 4 8 7 5 6) values: ((Array new: 6) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); at: 6 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); yourself))).

	self assert: 6 equals: aText runs values size.

	"Compensate for short run array, either by adding a run or by extending length
	of the last run. In either case, the run array should have size of 6 or greater, not
	size 1 as would be the case if the text formatting had been discarded."
	newText := Text basicNew setString: aString setRunsChecking: lastRunTooShort.
	self assert: newText equals: aText.
	self assert: newText runs size = aString size.
	self assert: newText runs values size >= 6.
	self assert: 7 equals: newText runs values size. "add one run to account for missing run length"

	newText := Text basicNew setString: aString setRunsChecking: missingLastRun.
	self assert: newText equals: aText. "n.b. Two Texts are considered equal if they have the same characters"
	self assert: newText runs size = aString size.
	self assert: 6 equals: newText runs values size.



]

{ #category : #'tests - fileIn\/Out' }
TextTest >> testWriteReadChunk [
	"Create a text from string and runs with matching lenghts. Verify that writing to
	chunk format and reading from that chunk results in a copy of the original text."

	| aString runs aText chunk readFromChunk |
	aString := 'The best way to predict the future'.
	runs := (RunArray runs: #(4 4 8 7 5 6) values: ((Array new: 6) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); at: 6 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); yourself)).

	self assert: aString size = runs size.
	aText := Text basicNew setString: aString setRunsChecking: runs.
	chunk := '' writeStream nextChunkPutWithStyle: aText; yourself; contents.
	readFromChunk := UTF8TextConverter new nextChunkTextFromStream: (ReadStream on: chunk).

	self assert: readFromChunk equals: aText.
	self assert: readFromChunk runs size = aString size.
	self assert: runs equals: readFromChunk runs.
	self assert: 6 equals: aText runs values size.
	self assert: 6 equals: readFromChunk runs values size.

]

{ #category : #'tests - fileIn\/Out' }
TextTest >> testWriteReadChunkShortRunCount [
	"Create a text from string and runs, where the string length is less than the
	runs length. This is a condition that might occur if a chunk fileout was edited
	by hand, leaving runs that extend beyond the bounds of the run array. In this
	case, the fileIn should result in a reasonable Text instance without errors related
	to the runs that exceed the string length."

	| aString runs aText chunk readFromChunk |
	aString := 'The best way to predict'.  " the future".
	runs := (RunArray runs: #(4 4 8 7 5) values: ((Array new: 5) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); yourself)).

	self deny: aString size = runs size.
	aText := Text basicNew setString: aString setRunsChecking: runs.
	chunk := '' writeStream nextChunkPutWithStyle: aText; yourself; contents.
	readFromChunk := UTF8TextConverter new nextChunkTextFromStream: (ReadStream on: chunk).

	self assert: readFromChunk equals: aText.
	self assert: readFromChunk runs size = aString size.
	self assert: readFromChunk runs size > 1.
	self assert: 4 equals: aText runs values size.
	self assert: 4 equals: readFromChunk runs values size.

]

{ #category : #'tests - fileIn\/Out' }
TextTest >> testWriteReadChunkShortRunLength [
	"Create a text from string and runs, where the run length is less than the string
	length. The fileIn should result in a reasonable Text instance without errors related
	to the run length mismatch."

	| aString runs aText chunk readFromChunk |
	aString := 'The best way to predict the future'.
	runs := (RunArray runs: #(4 4 8 7 5 1) values: ((Array new: 6) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); at: 6 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); yourself)).

	self deny: aString size = runs size.
	aText := Text basicNew setString: aString setRunsChecking: runs.
	chunk := '' writeStream nextChunkPutWithStyle: aText; yourself; contents.
	readFromChunk := UTF8TextConverter new nextChunkTextFromStream: (ReadStream on: chunk).

	self assert: readFromChunk equals: aText.
	self assert: readFromChunk runs size = aString size.
	self assert: readFromChunk runs size > 1.
	self assert: aText runs values size equals: readFromChunk runs values size.

]

{ #category : #'tests - fileIn\/Out' }
TextTest >> testWriteReadChunkShortString [
	"Create a text from string and runs, where the run entries are fewer than required
	to match the string length. The fileIn should result in a reasonable Text instance
	without errors related to the run length mismatch."

	| aString runs aText chunk readFromChunk |
	aString := 'The best way to predict the future'.
	runs := (RunArray runs: #(4 4 8 7 5 6) values: ((Array new: 6) at: 1 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 1; yourself); yourself); at: 2 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 3 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 3; yourself); yourself); at: 4 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); at: 5 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 4; yourself); yourself); at: 6 put: ((Array new: 1) at: 1 put: (TextFontChange basicNew instVarAt: 1 put: 2; yourself); yourself); yourself)).

	self assert: aString size = runs size.
	aText := Text basicNew setString: aString setRunsChecking: runs.
	chunk := '' writeStream nextChunkPutWithStyle: aText; yourself; contents.
	readFromChunk := UTF8TextConverter new nextChunkTextFromStream: (ReadStream on: chunk).

	self assert: readFromChunk equals: aText.
	self assert: readFromChunk runs size = aString size.
	self assert: readFromChunk runs size > 1.
	self assert: aText runs values size equals: readFromChunk runs values size.

]
