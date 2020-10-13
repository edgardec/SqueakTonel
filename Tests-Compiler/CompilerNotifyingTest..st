"
A CompilerNotifyingTest is a TestCase for checking that Compiler/Parser notifications are inserted at the right place in a TextEditor.

Instance Variables
	expectedErrorPositions:		<Array of: Integer>
	expectedErrors:		<Array of: String>
	failure:		<Object>
	morph:		<TextMorph>
	text:		<String>

errorPositions
	- the position where error text should be inserted for each chunk of text evaluated

errors
	- the error text that should be inserted on evaluation of each chunk of text evaluated

failure
	- an object returned in case of evaluation error and whose identity can be uniquely recognized as a failure
	
morph
	- the Morph holding the text
	
text
	- the string containing all the chunks to be evaluated (separated by %)
	  and the expected error messages (`enclosed in back quotes`)
	  this text will be stripped of the error messages before being evaluated.


"
Class {
	#name : #CompilerNotifyingTest,
	#superclass : #TestCase,
	#instVars : [
		'text',
		'morph',
		'expectedErrors',
		'expectedErrorPositions',
		'failure'
	],
	#category : #'Tests-Compiler'
}

{ #category : #history }
CompilerNotifyingTest class >> lastStoredRun [
	^ ((Dictionary new) add: (#failures->((Set new) add: #testTooManyArguments; add: #testifTrueBlockWithArgument; add: #testMissingArgumentAfterAMessageKey; add: #testTooManyLiterals; add: #testAlltogether; add: #testUnmatchedLocalTempDeclarationInABlock; add: #testUnmatchedExpressionParenthesis; add: #testCaseOtherwiseBlockWithArgument; yourself)); add: (#errors->((Set new) add: #testTooManyTemporaries; yourself)); add: (#passed->((Set new) add: #testUnmatchedBraceArray; add: #testTooLargeAnIntegerInALiteralByteArray; add: #testDigitTooLargeForARadix; add: #testInvalidLiteralCharacter; add: #testAssignmentOfSelf; add: #testInvalidPrimitive; add: #testInvalidExternalFunctionDeclaration; add: #testMissingExpressionAfterAReturn; add: #testInvalidRadix; add: #testMissingArgumentAfterABinaryMessage; add: #testMissingPeriodSeparatorBetweenStatements; add: #testCascadeInASuperSend; add: #testATempShadowingAnotherTemp; add: #testExtraneousStatementAfterAReturnInABlock; add: #testLiteralCharacterMissing; add: #testUnmatchedCommentQuote; add: #testInvalidPattern; add: #testUnmatchedByteArrayBracket; add: #testUnmatchedLiteralParenthesis; add: #testUnmatchedLocalTempDeclaration; add: #testExpectedExpressionInBraceArray; add: #testInvalidPragma; add: #testMissingSeparatorBetweenBlockArgumentAndStatements; add: #testMissingBlockArgumentName; add: #testMissingMessageAfterACascade; add: #testUnmatchedStringQuote; add: #testTempDoubledDefined; add: #testMissingExpression; add: #testUnmatchedBlockBracket; add: #testEmptyCaseStatement; yourself)); add: (#timeStamp->'22 February 2012 3:52:10 am' asTimeStamp); yourself)
]

{ #category : #private }
CompilerNotifyingTest >> enumerateAllSelections [
	1 to: self numberOfSelections do: [:n |
		self assert: (self evaluateSelectionNumber: n) == failure.
		self assert: ((expectedErrors at: n) = morph editor selection asString).
		self assert: ((expectedErrorPositions at: n) = morph editor startIndex).
		morph editor cut].
]

{ #category : #private }
CompilerNotifyingTest >> evaluateSelection [
	^(nil class evaluatorClass new)
		evaluate: morph editor selectionAsStream
		in: nil
		to: nil
		notifying: morph editor
		ifFail: [^failure]
	
]

{ #category : #private }
CompilerNotifyingTest >> evaluateSelectionNumber: n [
	| i start stop |
	i := start := 1.
	[stop := morph text indexOf: $% startingAt: start + 1 ifAbsent: morph text size + 1.
	i = n]
		whileFalse:
			[i := i + 1.
			start := stop + 1].
	morph editor selectFrom: start to: stop - 1.
	^self evaluateSelection
	
]

{ #category : #failures }
CompilerNotifyingTest >> expectedFailures [
	"For these tests, the Compiler does not insert the notification where it would be most informative."
	
	^#(
		"Notifying before the literal (which can be a message send) would be more informative"
		testTooManyLiterals
		
		"Notifying right before the 16th argument would be informative"
		testTooManyArguments
		
		"Notifying before the extraneous argument in the right block woul be useful"
		testifTrueBlockWithArgument  testCaseOtherwiseBlockWithArgument
		)
]

{ #category : #'initialize-release' }
CompilerNotifyingTest >> initializeTextWithoutError [
	"Remove the errors from the text to be compiled and answer the text without errors.
	Meanwhile, collect the expected error messages and their expected position."

	| input output errorStream positionStream |
	input := text readStream.
	output := (String new: text size) writeStream.
	errorStream := (Array new: self numberOfSelections) writeStream.
	positionStream := (Array new: self numberOfSelections) writeStream.
	
	[output nextPutAll: (input upTo: $`).
	input atEnd]
		whileFalse:
			[positionStream nextPut: output position + 1.
			errorStream nextPut: (input upTo: $`)].
	expectedErrors := errorStream contents.
	expectedErrorPositions := positionStream contents.
	^output contents
]

{ #category : #private }
CompilerNotifyingTest >> numberOfSelections [
	^(text occurrencesOf: $%) + 1
]

{ #category : #running }
CompilerNotifyingTest >> setUp [
	failure := Object new.
]

{ #category : #'initialize-release' }
CompilerNotifyingTest >> setUpForErrorsIn: aTextWithErrorsEnclosedInBackQuote [
	"Extract the expectedErrors, the expectedErrorPositions and set up a TextMorph containing the text without errors.
	each section separated by % in aTextWithErrorsEnclosedInBackQuote will be evaluated separately.
	The expected error message should lie in aTextWithErrorsEnclosedInBackQuote at the expected position, and enclosed in back quotes."
	text := aTextWithErrorsEnclosedInBackQuote.
	
	"Enclose error messages in double quotes to support syntax highlighting."
	text := text copyReplaceAll: '` ' with: '` "'.
	text := text copyReplaceAll: '>`' with: '>"`'.
	
	morph := TextMorph new contents: self initializeTextWithoutError asText.
]

{ #category : #tests }
CompilerNotifyingTest >> testATempShadowingAnotherTemp [
	self setUpForErrorsIn: '| x | x := 1. ^[ | ` Name already used in this method ->`x | x ]'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testAlltogether [
	"Initialize for all known error conditions.
	Note that the chunk to be evaluated are separated by %, and expected errors enclosed in back quotes."
	
	self setUpForErrorsIn: '  "First, the senders of #offEnd:"
#` Unmatched bracket ->`[ 1 2 %
#[ 1 2 ` 8-bit integer or right bracket expected ->`256 4]%
$` A Character was expected ->`%
1+2   ` Unmatched comment quote ->`"unfinished comment%
#` Unmatched parenthesis ->`( 1 2%
#` Unmatched parenthesis ->`( 1 2 %
^nil printString ,  ` Unmatched string quote ->`''unfinished string%
	"Then, the senders of #expected:"
2r` a digit between 0 and 1 expected ->`3%
| x | x := ` Expression expected ->`%
[ :x : ` Argument name expected ->`1]%
[ :x ` Vertical bar expected ->`x + 1 ]%
[:x | 1 ` Period or right bracket expected ->`( 1 ) ]%
{ 1. 2` Period or right brace expected ->`%
{ 1. 2 ` Period or right brace expected ->`%
{ 1. 2 ` Period or right brace expected ->`3 %
{ 1. 2. ` Variable or expression or right brace expected ->`| x | %
super yourself` Cascading not expected ->`; yourself%
nil yourself; ` Cascade expected ->`^ 2%
	"#externalFunctionDeclaration is skipped, this cannot be evaluated"
1 to: ` Argument expected ->`:=%
1 +` Argument expected ->`%
1 + ` Argument expected ->`* 2 + 3%
1+(2 ` right parenthesis expected ->`.  %
1 + 2 ` Nothing more expected ->`^nil%
	"#pattern:inContext: skipped, cannot be evaluated"
	"#pragmaLiteral: #pragmaSequence #pragmaStatement skipped, cannot be evaluated"
(  ` expression expected ->`. 2  . )%
( 1  ` right parenthesis expected ->`. 2  . )%
	"#primitive:error: #primitive:module:error: skipped, cannot be evaluated"
^ ` Expression to return expected ->`. 1 + 2%
[ ^1 ` End of block expected ->`2]%
| x y ` Vertical bar expected ->`%
[:z | | x y ` Vertical bar expected ->`]%
1` an integer greater than 1 as valid radix expected ->`r0'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testAssignmentOfSelf [
	self setUpForErrorsIn: '` Cannot store into ->`self := 1. ^self'.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testCascadeInASuperSend [
	self setUpForErrorsIn: 'super yourself` Cascading not expected ->`; yourself'.
	self enumerateAllSelections
]

{ #category : #'tests - block arguments' }
CompilerNotifyingTest >> testCaseOtherwiseBlockWithArgument [
	self setUpForErrorsIn: 'nil caseOf: { [nil] -> [1] } otherwise: [:x` <- otherwise arg of caseOf:otherwise: has too many arguments ->` | 2 ]. ^nil '.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testDigitTooLargeForARadix [
	self setUpForErrorsIn: '2r` a digit between 0 and 1 expected ->`3'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testEmptyCaseStatement [
	self setUpForErrorsIn: '^ nil caseOf: { ` At least one case required ->`} '.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testExpectedExpressionInBraceArray [
	self setUpForErrorsIn: '{ 1. 2 ` Period or right brace expected ->`3 }'.
	self enumerateAllSelections.
	self setUpForErrorsIn: '{ 1. 2. ` Variable or expression or right brace expected ->`| x | x}'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testExtraneousStatementAfterAReturnInABlock [
	self setUpForErrorsIn: '[ ^1 ` End of block expected ->`2]'.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testInvalidExternalFunctionDeclaration [
	"Not implemented yet.
	#externalFunctionDeclaration skipped, cannot be evaluated"
]

{ #category : #tests }
CompilerNotifyingTest >> testInvalidLiteralCharacter [
	self setUpForErrorsIn: '^ #yourself , #` Invalid literal character ->`) , #end'.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testInvalidPattern [
	"Not implemented yet.
	#pattern:inContext: skipped, cannot be evaluated"
]

{ #category : #tests }
CompilerNotifyingTest >> testInvalidPragma [
	"Not implemented yet.
	#pragmaLiteral: #pragmaSequence #pragmaStatement #pragmaPrimitives skipped, cannot be evaluated"
]

{ #category : #tests }
CompilerNotifyingTest >> testInvalidPrimitive [
	"Not implemented yet.
	##primitive:error: #primitive:module:error: skipped, cannot be evaluated"
]

{ #category : #tests }
CompilerNotifyingTest >> testInvalidRadix [
	self setUpForErrorsIn: '1` an integer greater than 1 as valid radix expected ->`r0'.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testLiteralCharacterMissing [
	self setUpForErrorsIn: '$` A Character was expected ->`'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testMissingArgumentAfterABinaryMessage [
	self setUpForErrorsIn: '1 +` Argument expected ->`'.
	self enumerateAllSelections.
	self setUpForErrorsIn: '1 + ` Argument expected ->`* 2 + 3'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testMissingArgumentAfterAMessageKey [
	self setUpForErrorsIn: '1 to: ` Argument expected ->`:='.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testMissingBlockArgumentName [
	self setUpForErrorsIn: '[ :x : ` Argument name expected ->`1]'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testMissingExpression [
	self setUpForErrorsIn: '| x | x := ` Expression expected ->`'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testMissingExpressionAfterAReturn [
	self setUpForErrorsIn: '^ ` Expression to return expected ->`. 1 + 2'.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testMissingMessageAfterACascade [
	self setUpForErrorsIn: 'nil yourself; ` Cascade expected ->`^ 2'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testMissingPeriodSeparatorBetweenStatements [
	self setUpForErrorsIn: '1 + 2 ` Nothing more expected ->`^nil'.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testMissingSeparatorBetweenBlockArgumentAndStatements [
	self setUpForErrorsIn: '[ :x ` Vertical bar expected ->`x + 1 ]'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testTempDoubledDefined [
	self setUpForErrorsIn: '| x ` Name already used in this method ->`x | x := 1. ^x'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testTooLargeAnIntegerInALiteralByteArray [
	self setUpForErrorsIn: '#[ 1 2 ` 8-bit integer or right bracket expected ->`256 4 5]'.
	self enumerateAllSelections
]

{ #category : #'tests - byteCode limits' }
CompilerNotifyingTest >> testTooManyArguments [
	self setUpForErrorsIn: '^[:x1 :x2 :x3 :x4 :x5 :x6 :x7 :x8 :x9 :x10 :x11 :x12 :x13 :x14 :x15 ` Too many arguments ->`:x16 :x17 | ]'.
	self enumerateAllSelections.
]

{ #category : #'tests - byteCode limits' }
CompilerNotifyingTest >> testTooManyLiterals [
	self setUpForErrorsIn: '{#(1). #(2). #(3). #(4). #(5). #(6). #(7). #(8). #(9). #(10). #(11). #(12). #(13). #(14). #(15). #(16). #(17). #(18). #(19). #(20). #(21). #(22). #(23). #(24). #(25). #(26). #(27). #(28). #(29). #(30). #(31). #(32). #(33). #(34). #(35). #(36). #(37). #(38). #(39). #(40). #(41). #(42). #(43). #(44). #(45). #(46). #(47). #(48). #(49). #(50). #(51). #(52). #(53). #(54). #(55). #(56). #(57). #(58). #(59). #(60). #(61). #(62). #(63). #(64). #(65). #(66). #(67). #(68). #(69). #(70). #(71). #(72). #(73). #(74). #(75). #(76). #(77). #(78). #(79). #(80). #(81). #(82). #(83). #(84). #(85). #(86). #(87). #(88). #(89). #(90). #(91). #(92). #(93). #(94). #(95). #(96). #(97). #(98). #(99). #(100). #(101). #(102). #(103). #(104). #(105). #(106). #(107). #(108). #(109). #(110). #(111). #(112). #(113). #(114). #(115). #(116). #(117). #(118). #(119). #(120). #(121). #(122). #(123). #(124). #(125). #(126). #(127). #(128). #(129). #(130). #(131). #(132). #(133). #(134). #(135). #(136). #(137). #(138). #(139). #(140). #(141). #(142). #(143). #(144). #(145). #(146). #(147). #(148). #(149). #(150). #(151). #(152). #(153). #(154). #(155). #(156). #(157). #(158). #(159). #(160). #(161). #(162). #(163). #(164). #(165). #(166). #(167). #(168). #(169). #(170). #(171). #(172). #(173). #(174). #(175). #(176). #(177). #(178). #(179). #(180). #(181). #(182). #(183). #(184). #(185). #(186). #(187). #(188). #(189). #(190). #(191). #(192). #(193). #(194). #(195). #(196). #(197). #(198). #(199). #(200). #(201). #(202). #(203). #(204). #(205). #(206). #(207). #(208). #(209). #(210). #(211). #(212). #(213). #(214). #(215). #(216). #(217). #(218). #(219). #(220). #(221). #(222). #(223). #(224). #(225). #(226). #(227). #(228). #(229). #(230). #(231). #(232). #(233). #(234). #(235). #(236). #(237). #(238). #(239). #(240). #(241). #(242). #(243). #(244). #(245). #(246). #(247). #(248). #(249). #(250). #(251). #(252). #(253). #(254). #(255). #(256). `More than 256 literals referenced. 
You must split or otherwise simplify this method.
The 257th literal is: ->`#(257)}'.
	self enumerateAllSelections
]

{ #category : #'tests - byteCode limits' }
CompilerNotifyingTest >> testTooManyTemporaries [
	"Nope, with Closure Compiler, an Error is raised before the Encoder has a chance to notify"
]

{ #category : #tests }
CompilerNotifyingTest >> testUnmatchedBlockBracket [
	self setUpForErrorsIn: 'nil yourself. [` Period or right bracket expected ->`'.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testUnmatchedBraceArray [
	self setUpForErrorsIn: '{ 1. 2` Period or right brace expected ->`'.
	self enumerateAllSelections.
	self setUpForErrorsIn: '{ 1. 2 ` Period or right brace expected ->`'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testUnmatchedByteArrayBracket [
	self setUpForErrorsIn: '#` Unmatched bracket ->`[ 1 2 '.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testUnmatchedCommentQuote [
	self setUpForErrorsIn: '1+2   ` Unmatched comment quote ->`"unfinished comment'.
	self enumerateAllSelections
]

{ #category : #tests }
CompilerNotifyingTest >> testUnmatchedExpressionParenthesis [
	self setUpForErrorsIn: '1+(2 ` right parenthesis expected ->`. '.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testUnmatchedLiteralParenthesis [
	self setUpForErrorsIn: '#` Unmatched parenthesis ->`( 1 2'.
	self enumerateAllSelections.
	self setUpForErrorsIn: '#` Unmatched parenthesis ->`( 1 2 '.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testUnmatchedLocalTempDeclaration [
	self setUpForErrorsIn: '| x y ` Vertical bar expected ->`'.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testUnmatchedLocalTempDeclarationInABlock [
	self setUpForErrorsIn: '[:z | | x y ` Vertical bar expected ->`]'.
	self enumerateAllSelections.
]

{ #category : #tests }
CompilerNotifyingTest >> testUnmatchedStringQuote [
	self setUpForErrorsIn: '^nil printString ,  ` Unmatched string quote ->`''unfinished string'.
	self enumerateAllSelections
]

{ #category : #'tests - block arguments' }
CompilerNotifyingTest >> testifTrueBlockWithArgument [
	self setUpForErrorsIn: 'true ifTrue: [:x` <- argument of ifTrue: has too many arguments ->` | 1 + 1 ]'.
	self enumerateAllSelections.
	self setUpForErrorsIn: 'true ifTrue: [:x` <- argument of ifTrue: has too many arguments ->` :y | 1 + 1 ]'.
	self enumerateAllSelections.
]
