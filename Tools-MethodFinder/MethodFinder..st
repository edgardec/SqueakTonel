"
Find a method in the system from a set of examples.  Done by brute force, trying every possible selector.  Errors are skipped over using ( [3 + 'xyz'] ifError: [^ false] ).
Submit an array of the form ((data1 data2) answer  (data1 data2) answer).

	MethodFinder methodFor: #( (4 3) 7  (0 5) 5  (5 5) 10).

answer:  'data1 + data2'

More generally, use the brace notation to construct live examples.

The program tries data1 as the receiver, and
	tries all other permutations of the data for the receiver and args, and
	tries leaving out one argument, and
	uses all selectors data understands, and
	uses all selectors in all od data's superclasses.

Floating point values must be precise to 0.01 percent, or (X * 0.0001).

If you get an error, you have probably discovered a selector that needs to be removed from the Approved list.  See MethodFinder.initialize.  Please email the Squeak Team.

Only considers 0, 1, 2, and 3 argument messages.  The argument data may have 1 to 5 entries, but only a max of 4 used at a time.  For now, we only test messages that use given number of args or one fewer.  For example, this data (100 true 0.6) would test the receiver plus two args, and the receiver plus one arg, but not any other patterns.

Three sets of selectors:  Approved, AddAndRemove, and Blocks selectors.  When testing a selector in AddAndRemove, deepCopy the receiver.  We do not handle selectors that modify an argument (printOn: etc.).  Blocks is a set of (selector argNumber) where that argument must be a block.

For perform, the selector is tested.  It must be in the Approved list.

do: is not on the Approved list.  It does not produce a result that can be tested.  Type 'do' into the upper pane of the Selector Finder to find messages list that.

[Later, allow the user to supply a block that tests the answer, not just the literal answer.]
	MethodFinder methodFor: { { true. [3]. [4]}. 3}. 
Later allow this to work without the blocks around 3 and 4.
"
Class {
	#name : #MethodFinder,
	#superclass : #Object,
	#instVars : [
		'data',
		'answers',
		'selector',
		'argMap',
		'thisData',
		'mapStage',
		'mapList',
		'expressions',
		'cachedClass',
		'cachedArgNum',
		'cachedSelectorLists'
	],
	#classVars : [
		'AddAndRemove',
		'Approved',
		'Blocks',
		'Dangerous'
	],
	#category : #'Tools-MethodFinder'
}

{ #category : #'class initialization' }
MethodFinder class >> cleanUp: aggressive [

	Approved := nil.
	AddAndRemove := nil.
	Blocks := nil.
]

{ #category : #utility }
MethodFinder class >> methodFor: dataAndAnswers [
	"Return a Squeak expression that computes these answers.  (This method is called by the comment in the bottom pane of a MethodFinder.  Do not delete this method.)"

	| resultOC resultString |
	resultOC := (self new) load: dataAndAnswers; findMessage.
	resultString := String streamContents: [:strm |
		resultOC do: [:exp | strm nextPut: $(; nextPutAll: exp; nextPut: $); space]].
	^ resultString
]

{ #category : #'find a constant' }
MethodFinder >> allNumbers [
	"Return true if all answers and all data are numbers."

	answers do: [:aa | aa isNumber ifFalse: [^ false]].
	thisData do: [:vec |
			vec do: [:nn | nn isNumber ifFalse: [^ false]]].
	^ true
]

{ #category : #access }
MethodFinder >> answers [

	^ answers
]

{ #category : #'arg maps' }
MethodFinder >> argMap [
	^ argMap 
]

{ #category : #initialize }
MethodFinder >> cleanInputs: dataAndAnswerString [
	"Find an remove common mistakes.  Complain when ill formed."

| fixed ddd rs places |
ddd := dataAndAnswerString.
fixed := false.

rs := ReadStream on: ddd, ' '.
places := OrderedCollection new.
[rs upToAll: '#true'.  rs atEnd] whileFalse: [places addFirst: rs position-4]. 
places do: [:pos | ddd := ddd copyReplaceFrom: pos to: pos with: ''.
	fixed := true]. 	"remove #"

rs := ReadStream on: ddd.
places := OrderedCollection new.
[rs upToAll: '#false'.  rs atEnd] whileFalse: [places addFirst: rs position-5]. 
places do: [:pos | ddd := ddd copyReplaceFrom: pos to: pos with: ''.
	fixed := true]. 	"remove #"

fixed ifTrue: [self inform: '#(true false) are Symbols, not Booleans.  
Next time use { true. false }.'].

fixed := false.
rs := ReadStream on: ddd.
places := OrderedCollection new.
[rs upToAll: '#nil'.  rs atEnd] whileFalse: [places addFirst: rs position-3]. 
places do: [:pos | ddd := ddd copyReplaceFrom: pos to: pos with: ''.
	fixed := true]. 	"remove #"

fixed ifTrue: [self inform: '#nil is a Symbol, not the authentic UndefinedObject.  
Next time use nil instead of #nil'].

^ ddd

]

{ #category : #'find a constant' }
MethodFinder >> const [
	| const |
	"See if (^ constant) is the answer"

	"quick test"
	((const := answers at: 1) closeTo: (answers at: 2)) ifFalse: [^ false].
	3 to: answers size do: [:ii | (const closeTo: (answers at: ii)) ifFalse: [^ false]].
	expressions add: '^ ', const printString.
	selector add: #yourself.
	^ true
]

{ #category : #'find a constant' }
MethodFinder >> constDiv [
	| const subTest got |
	"See if (data1 // C) is the answer"

	const := ((thisData at: 1) at: 1) // (answers at: 1).  "May not be right!"
	got := (subTest := MethodFinder new copy: self addArg: const) 
				searchForOne isEmpty not.
	got ifFalse: [^ false]. 

	"replace data2 with const in expressions"
	subTest expressions do: [:exp |
		expressions add: (exp copyReplaceAll: 'data2' with: const printString)].
	selector addAll: subTest selectors.
	^ true
]

{ #category : #'find a constant' }
MethodFinder >> constEquiv [
	| const subTest got jj |
	"See if (data1 = C) or (data1 ~= C) is the answer"

	"quick test"
	((answers at: 1) class superclass == Boolean) ifFalse: [^ false].
	2 to: answers size do: [:ii | 
		((answers at: ii) class superclass == Boolean) ifFalse: [^ false]].

	const := (thisData at: 1) at: 1.
	got := (subTest := MethodFinder new copy: self addArg: const) 
				searchForOne isEmpty not.
	got ifFalse: ["try other polarity for ~~ "
		(jj := answers indexOf: (answers at: 1) not) > 0 ifTrue: [
		const := (thisData at: jj) at: 1.
		got := (subTest := MethodFinder new copy: self addArg: const) 
				searchForOne isEmpty not]]. 
	got ifFalse: [^ false]. 

	"replace data2 with const in expressions"
	subTest expressions do: [:exp |
		expressions add: (exp copyReplaceAll: 'data2' with: const printString)].
	selector addAll: subTest selectors.
	^ true
]

{ #category : #'find a constant' }
MethodFinder >> constLinear [
	| const subTest got denom num slope offset |
	"See if (data1 * C1) + C2 is the answer.  In the form  #(C2 C1) polynomialEval: data1 "

	denom := ((thisData at: 2) at: 1) - ((thisData at: 1) at: 1).
	denom = 0 ifTrue: [^ false].   "will divide by it"
	num := (answers at: 2) - (answers at: 1).

    slope := (num asFloat / denom) reduce.
    offset := ((answers at: 2) - (((thisData at: 2) at: 1) * slope)) reduce.

	const := Array with: offset with: slope.
	got := (subTest := MethodFinder new copy: self addArg: const) 
				searchForOne isEmpty not.
	got ifFalse: [^ false]. 

	"replace data2 with const in expressions"
	subTest expressions do: [:exp |
		expressions add: (exp copyReplaceAll: 'data2' with: const printString)].
	selector addAll: subTest selectors.
	^ true
]

{ #category : #'find a constant' }
MethodFinder >> constMod [
	| subTest low |
	"See if mod, (data1 \\ C) is the answer"

	low := answers max.
	low+1 to: low+20 do: [:const |
		subTest := MethodFinder new copy: self addArg: const.
		(subTest testPerfect: #\\) ifTrue: [
			expressions add: 'data1 \\ ', const printString.
			selector add: #\\.
			^ true]].
	^ false
]

{ #category : #'find a constant' }
MethodFinder >> constMult [
	| const subTest got |
	"See if (data1 * C) is the answer"

	((thisData at: 1) at: 1) = 0 ifTrue: [^ false].
	const := ((answers at: 1) asFloat / ((thisData at: 1) at: 1)) reduce.
	got := (subTest := MethodFinder new copy: self addArg: const) 
				searchForOne isEmpty not.
	got ifFalse: [^ false]. 

	"replace data2 with const in expressions"
	subTest expressions do: [:exp |
		expressions add: (exp copyReplaceAll: 'data2' with: const printString)].
	selector addAll: subTest selectors.
	^ true
]

{ #category : #'find a constant' }
MethodFinder >> constPlus [
	| const subTest got |
	"See if (data1 + C) is the answer"

	const := (answers at: 1) - ((thisData at: 1) at: 1).
	got := (subTest := MethodFinder new copy: self addArg: const) 
				searchForOne isEmpty not.
	got ifFalse: [^ false]. 

	"replace data2 with const in expressions"
	subTest expressions do: [:exp |
		expressions add: (exp copyReplaceAll: 'data2' with: const printString)].
	selector addAll: subTest selectors.
	^ true
]

{ #category : #'find a constant' }
MethodFinder >> constUsingData1Value [
	| subTest |
	"See if (data1 <= C) or (data1 >= C) is the answer"

	"quick test"
	((answers at: 1) class superclass == Boolean) ifFalse: [^ false].
	2 to: answers size do: [:ii | 
		((answers at: ii) class superclass == Boolean) ifFalse: [^ false]].

	thisData do: [:datums | | got const | 
		const := datums first.	"use data as a constant!"
		got := (subTest := MethodFinder new copy: self addArg: const) 
					searchForOne isEmpty not.
		got ifTrue: [
			"replace data2 with const in expressions"
			subTest expressions do: [:exp |
				expressions add: (exp copyReplaceAll: 'data2' with: const printString)].
			selector addAll: subTest selectors.
			^ true]].
	^ false
]

{ #category : #initialize }
MethodFinder >> copy: mthFinder addArg: aConstant [
	| more |
	"Copy inputs and answers, add an additional data argument to the inputs.  The same constant for every example"

	more := Array with: aConstant.
	data := mthFinder data collect: [:argList | argList, more].
	answers := mthFinder answers.
	self load: nil.

]

{ #category : #access }
MethodFinder >> data [

	^ data
]

{ #category : #search }
MethodFinder >> exceptions [
	"Handle some very slippery selectors.
	asSymbol -- want to be able to produce it, but do not want to make every string submitted into a Symbol!" 

	| aSel |
	answers first isSymbol ifFalse: [^ self].
	thisData first first isString ifFalse: [^ self].
	aSel := #asSymbol.
	(self testPerfect: aSel) ifTrue: [
		selector add: aSel.
		expressions add: (String streamContents: [:strm | 
			strm nextPutAll: 'data', argMap first printString.
			aSel keywords doWithIndex: [:key :ind |
				strm nextPutAll: ' ',key.
				(key last == $:) | (key first isLetter not)
					ifTrue: [strm nextPutAll: ' data', 
						(argMap at: ind+1) printString]]])].

]

{ #category : #access }
MethodFinder >> expressions [
	^ expressions
]

{ #category : #search }
MethodFinder >> findMessage [
	"Control the search."

	data do: [:alist |
		(alist isKindOf: SequenceableCollection) ifFalse: [
			^ OrderedCollection with: 'first and third items are not Arrays']].
	Approved ifNil: [self initialize].	"Sets of allowed selectors"
	expressions := OrderedCollection new.
	self search: true.	"multi"
	expressions isEmpty ifTrue: [^ OrderedCollection with: 'no single method does that function'].
	expressions isString ifTrue: [^ OrderedCollection with: expressions].
 	^ expressions
]

{ #category : #initialize }
MethodFinder >> initialize [
	"The methods we are allowed to use.  (MethodFinder new initialize) "

	Approved := Set new.
	AddAndRemove := Set new.
	Blocks := Set new.
	"These modify an argument and are not used by the MethodFinder: longPrintOn: printOn: storeOn: sentTo: storeOn:base: printOn:base: absPrintExactlyOn:base: absPrintOn:base: absPrintOn:base:digitCount: writeOn: writeScanOn: possibleVariablesFor:continuedFrom: printOn:format:"

"Object"  
	#("in class, instance creation" categoryForUniclasses chooseUniqueClassName initialInstance isSystemDefined newFrom: officialClass readCarefullyFrom:
"accessing" at: basicAt: basicSize bindWithTemp: in: size yourself 
"testing" basicType ifNil: ifNil:ifNotNil: ifNotNil: ifNotNil:ifNil: isColor isFloat isFraction isInMemory isInteger isMorph isNil isNumber isPoint isText isTransparent isWebBrowser knownName notNil pointsTo: wantsSteps 
"comparing" = == closeTo: hash identityHash identityHashPrintString ~= ~~ 
"copying" copy shallowCopy 
"dependents access" canDiscardEdits dependents hasUnacceptedEdits 
"updating" changed changed: okToChange update: windowIsClosing 
"printing" fullPrintString isLiteral longPrintString printString storeString stringForReadout stringRepresentation 
"class membership" class isKindOf: isKindOf:orOf: isMemberOf: respondsTo: xxxClass 
"error handling" 
"user interface" addModelMenuItemsTo:forMorph:hand: defaultLabelForInspector fullScreenSize initialExtent modelWakeUp mouseUpBalk: newTileMorphRepresentative windowActiveOnFirstClick windowReqNewLabel: 
"system primitives" asOop instVarAt: instVarNamed: 
"private" 
"associating" -> 
"converting" as: asOrderedCollection asString 
"casing" caseOf: caseOf:otherwise: 
"binding" bindingOf: 
"macpal" contentsChanged currentEvent currentHand currentWorld flash instanceVariableValues scriptPerformer 
"flagging" flag: 
"translation support" "objects from disk" "finalization" ) do: [:sel | Approved add: sel].
	#(at:add: at:modify: at:put: basicAt:put: "NOT instVar:at:"
"message handling" perform: perform:orSendTo: perform:with: perform:with:with: perform:with:with:with: perform:withArguments: perform:withArguments:inSuperclass: 
) do: [:sel | AddAndRemove add: sel].

"Boolean, True, False, UndefinedObject"  
	#("logical operations" & eqv: not xor: |
"controlling" and: ifFalse: ifFalse:ifTrue: ifTrue: ifTrue:ifFalse: or:
"copying" 
"testing" isEmptyOrNil) do: [:sel | Approved add: sel].

"Behavior" 
	#("initialize-release"
"accessing" compilerClass decompilerClass evaluatorClass format methodDict parserClass sourceCodeTemplate subclassDefinerClass
"testing" instSize instSpec isBits isBytes isFixed isPointers isVariable isWeak isWords
"copying"
"printing" defaultNameStemForInstances printHierarchy
"creating class hierarchy"
"creating method dictionary"
"instance creation" basicNew basicNew: new new:
"accessing class hierarchy" allSubclasses allSubclassesWithLevelDo:startingLevel: allSuperclasses subclasses superclass withAllSubclasses withAllSuperclasses
"accessing method dictionary" allSelectors changeRecordsAt: compiledMethodAt: compiledMethodAt:ifAbsent: firstCommentAt: lookupSelector: selectors selectorsDo: selectorsWithArgs: "slow but useful ->" sourceCodeAt: sourceCodeAt:ifAbsent: sourceMethodAt: sourceMethodAt:ifAbsent:
"accessing instances and variables" allClassVarNames allInstVarNames allSharedPools classVarNames instVarNames instanceCount sharedPools someInstance subclassInstVarNames
"testing class hierarchy" inheritsFrom: kindOfSubclass
"testing method dictionary" canUnderstand: classThatUnderstands: hasMethods includesSelector: whichClassIncludesSelector: whichSelectorsAccess: whichSelectorsReferTo: whichSelectorsReferTo:special:byte: whichMethodsStoreInto:
"enumerating"
"user interface") do: [:sel | Approved add: sel].

"ClassDescription"
	#("initialize-release" 
"accessing" classVersion isMeta name theNonMetaClass
"copying" 
"printing" classVariablesString instanceVariablesString sharedPoolsString
"instance variables" checkForInstVarsOK: 
"method dictionary" 
"organization" category organization whichCategoryIncludesSelector:
"compiling" acceptsLoggingOfCompilation wantsChangeSetLogging
"fileIn/Out" definition
"private" ) do: [:sel | Approved add: sel].

"Class"
	#("initialize-release" 
"accessing" classPool
"testing"
"copying" 
"class name" 
"instance variables" 
"class variables" classVarAt: classVariableAssociationAt:
"pool variables" 
"compiling" 
"subclass creation" 
"fileIn/Out" ) do: [:sel | Approved add: sel]. 

"Metaclass"
	#("initialize-release" 
"accessing" isSystemDefined soleInstance
"copying" "instance creation" "instance variables"  "pool variables" "class hierarchy"  "compiling"
"fileIn/Out"  nonTrivial ) do: [:sel | Approved add: sel].

"Context, BlockContext"
	#(receiver client method receiver tempAt: 
"debugger access" pc selector sender shortStack sourceCode tempNames tempsAndValues
"controlling"  "printing" "system simulation" 
"initialize-release" 
"accessing" hasMethodReturn home numArgs
"evaluating" value value:ifError: value:value: value:value:value: value:value:value:value: valueWithArguments:
"controlling"  "scheduling"  "instruction decoding"  "printing" "private"  "system simulation" ) do: [:sel | Approved add: sel].
	#(value: "<- Association has it as a store" ) do: [:sel | AddAndRemove add: sel].

"Message"
	#("inclass, instance creation" selector: selector:argument: selector:arguments:
"accessing" argument argument: arguments sends:
"printing" "sending" ) do: [:sel | Approved add: sel].
	#("private" setSelector:arguments:) do: [:sel | AddAndRemove add: sel].

"Magnitude"
	#("comparing" < <= > >= between:and:
"testing" max: min: min:max: ) do: [:sel | Approved add: sel].

"Date, Time"
	#("in class, instance creation" fromDays: fromSeconds: fromString: newDay:month:year: newDay:year: today
	"in class, general inquiries" dateAndTimeNow dayOfWeek: daysInMonth:forYear: daysInYear: firstWeekdayOfMonth:year: indexOfMonth: leapYear: nameOfDay: nameOfMonth:
"accessing" day leap monthIndex monthName weekday year
"arithmetic" addDays: subtractDate: subtractDays:
"comparing"
"inquiries" dayOfMonth daysInMonth daysInYear daysLeftInYear firstDayOfMonth previous:
"converting" asSeconds
"printing"  mmddyyyy printFormat: 
"private" weekdayIndex 
	"in class, instance creation" fromSeconds: now 
	"in class, general inquiries" dateAndTimeFromSeconds: dateAndTimeNow millisecondClockValue millisecondsToRun: totalSeconds
"accessing" hours minutes seconds
"arithmetic" addTime: subtractTime:
"comparing"
"printing" intervalString print24 
"converting") do: [:sel | Approved add: sel].
	#("private" 
		 ) do: [:sel | AddAndRemove add: sel].

"Number"
	#("in class" readFrom:base: 
"arithmetic" * + - / // \\ abs negated quo: reciprocal rem:
"mathematical functions" arcCos arcSin arcTan arcTan: cos exp floorLog: ln log log: raisedTo: raisedToInteger: sin sqrt squared tan
"truncation and round off" ceiling detentBy:atMultiplesOf:snap: floor roundTo: roundUpTo: rounded truncateTo: truncated
"comparing"
"testing" even isDivisibleBy: isInfinite isNaN isZero negative odd positive sign strictlyPositive
"converting" @ asInteger asNumber asPoint asSmallAngleDegrees degreesToRadians radiansToDegrees
"intervals" to: to:by: 
"printing" printStringBase: storeStringBase: ) do: [:sel | Approved add: sel].

"Integer"
	#("in class" primesUpTo:
"testing" isPowerOfTwo
"arithmetic" alignedTo:
"comparing"
"truncation and round off" atRandom normalize
"enumerating" timesRepeat:
"mathematical functions" degreeCos degreeSin factorial gcd: lcm: take:
"bit manipulation" << >> allMask: anyMask: bitAnd: bitClear: bitInvert bitInvert32 bitOr: bitShift: bitXor: lowBit noMask:
"converting" asCharacter asColorOfDepth: asFloat asFraction asHexDigit
"printing" asStringWithCommas hex hex8 radix:
"system primitives" lastDigit replaceFrom:to:with:startingAt:
"private" "benchmarks" ) do: [:sel | Approved add: sel].

"SmallInteger, LargeNegativeInteger, LargePositiveInteger"
	#("arithmetic" "bit manipulation" highBit "testing" "comparing" "copying" "converting" "printing" 
"system primitives" digitAt: digitLength 
"private" fromString:radix: ) do: [:sel | Approved add: sel].
	#(digitAt:put: ) do: [:sel | AddAndRemove add: sel].

"Float"
	#("arithmetic"
"mathematical functions" reciprocalLogBase2 timesTwoPower:
"comparing" "testing"
"truncation and round off" exponent fractionPart integerPart significand significandAsInteger
"converting" asApproximateFraction asIEEE32BitWord asTrueFraction
"copying") do: [:sel | Approved add: sel].

"Fraction, Random"
	#(denominator numerator reduced next nextValue) do: [:sel | Approved add: sel].
	#(setNumerator:denominator:) do: [:sel | AddAndRemove add: sel].

"Collection"
	#("accessing" anyOne
"testing" includes: includesAllOf: includesAnyOf: includesSubstringAnywhere: isEmpty isSequenceable occurrencesOf:
"enumerating" collect: collect:thenSelect: count: detect: detect:ifNone: detectMax: detectMin: detectSum: inject:into: reject: select: select:thenCollect: intersection:
"converting" asBag asCharacterSet asSet asSortedArray asSortedCollection asSortedCollection:
"printing"
"private" maxSize
"arithmetic"
"math functions" average max median min range sum) do: [:sel | Approved add: sel].
	#("adding" add: addAll: addIfNotPresent:
"removing" remove: remove:ifAbsent: removeAll: removeAllFoundIn: removeAllSuchThat: remove:ifAbsent:) do: [:sel | AddAndRemove add: sel].

"SequenceableCollection"
	#("comparing" hasEqualElements:
"accessing" allButFirst allButLast at:ifAbsent: atAll: atPin: atRandom: atWrap: fifth first fourth identityIndexOf: identityIndexOf:ifAbsent: indexOf: indexOf:ifAbsent: indexOf:startingAt:ifAbsent: indexOfSubCollection:startingAt: indexOfSubCollection:startingAt:ifAbsent: last second sixth third
"removing"
"copying" , copyAfterLast: copyAt:put: copyFrom:to: copyReplaceAll:with: copyReplaceFrom:to:with: copyUpTo: copyUpToLast: copyWith: copyWithout: copyWithoutAll: forceTo:paddingWith: shuffled sorted:
"enumerating" collectWithIndex: findFirst: findLast: pairsCollect: with:collect: withIndexCollect: polynomialEval:
"converting" asArray asDictionary asFloat32Array asFloat64Array asIntegerArray asStringWithCr asWordArray reversed
"private" copyReplaceAll:with:asTokens: ) do: [:sel | Approved add: sel].
	#( swap:with:) do: [:sel | AddAndRemove add: sel].

"ArrayedCollection, Bag"
	#("private" defaultElement 
"sorting" isSorted
"accessing" cumulativeCounts sortedCounts sortedElements "testing" "adding" add:withOccurrences: "removing" "enumerating" 
	) do: [:sel | Approved add: sel].
	#( mergeSortFrom:to:by: sort sort: add: add:withOccurrences:
"private" setDictionary ) do: [:sel | AddAndRemove add: sel].

"Other messages that modify the receiver"
	#(atAll:put: atAll:putAll: atAllPut: atWrap:put: replaceAll:with: replaceFrom:to:with:  removeFirst removeLast) do: [:sel | AddAndRemove add: sel].

	self initialize2.

"
MethodFinder new initialize.
MethodFinder new organizationFiltered: Set
"


]

{ #category : #initialize }
MethodFinder >> initialize2 [
	"The methods we are allowed to use.  (MethodFinder new initialize) "

"Set"
	#("in class" sizeFor:
"testing" "adding" "removing" "enumerating"
"private" array scanFor: 
"accessing" someElement) do: [:sel | Approved add: sel].

"Dictionary, IdentityDictionary, IdentitySet"
	#("accessing" associationAt: associationAt:ifAbsent: at:ifPresent: keyAtIdentityValue: keyAtIdentityValue:ifAbsent: keyAtValue: keyAtValue:ifAbsent: keys
"testing" includesKey: ) do: [:sel | Approved add: sel].
	#(removeKey: removeKey:ifAbsent:
) do: [:sel | AddAndRemove add: sel].

"LinkedList, Interval, MappedCollection"
	#("in class"  from:to: from:to:by:
"accessing" contents) do: [:sel | Approved add: sel].
	#(
"adding" addFirst: addLast:) do: [:sel | AddAndRemove add: sel].

"OrderedCollection, SortedCollection"
	#("accessing" after: before:
"copying" copyEmpty
"adding"  growSize
"removing" "enumerating" "private" 
"accessing" sortBlock) do: [:sel | Approved add: sel].
	#("adding" add:after: add:afterIndex: add:before: addAllFirst: addAllLast: addFirst: addLast:
"removing" removeAt: removeFirst removeLast
"accessing" sortBlock:) do: [:sel | AddAndRemove add: sel].

"Character"
	#("in class, instance creation" allByteCharacters digitValue: new separators
	"accessing untypeable characters" backspace cr enter lf linefeed nbsp newPage space tab
	"constants" alphabet characterTable
"accessing" asciiValue digitValue
"comparing"
"testing" isAlphaNumeric isDigit isLetter isLowercase isSafeForHTTP isSeparator isSpecial isUppercase isVowel tokenish
"copying"
"converting" asIRCLowercase asLowercase asUppercase
	) do: [:sel | Approved add: sel].

"String"
	#("in class, instance creation" crlf fromPacked:
	"primitives" findFirstInString:inSet:startingAt: indexOfAscii:inString:startingAt: 	"internet" valueOfHtmlEntity:
"accessing" byteAt: endsWithDigit findAnySubStr:startingAt: findBetweenSubStrs: findDelimiters:startingAt: findString:startingAt: findString:startingAt:caseSensitive: findTokens: findTokens:includes: findTokens:keep: includesSubstring: includesSubstring:caseSensitive: indexOf:startingAt: indexOfAnyOf: indexOfAnyOf:ifAbsent: indexOfAnyOf:startingAt: indexOfAnyOf:startingAt:ifAbsent: lineCorrespondingToIndex: lineCount lineNumber: skipAnySubStr:startingAt: skipDelimiters:startingAt: startsWithDigit
"comparing" alike: beginsWith: caseSensitiveLessOrEqual: charactersExactlyMatching: compare: crc16 endsWith: endsWithAnyOf: sameAs: startingAt:match:startingAt:
"copying" copyReplaceTokens:with: padded:to:with:
"converting" asByteArray asDate asDisplayText asFileName asHtml asLegalSelector asPacked asParagraph asText asTime asUnHtml asUrl asUrlRelativeTo: capitalized compressWithTable: contractTo: correctAgainst: encodeForHTTP initialIntegerOrNil keywords quoted sansPeriodSuffix splitInteger stemAndNumericSuffix substrings surroundedBySingleQuotes truncateWithElipsisTo: withBlanksTrimmed withFirstCharacterDownshifted withNoLineLongerThan: withSeparatorsCompacted withoutLeadingDigits withoutTrailingBlanks
"displaying" "printing"
"system primitives" compare:with:collated: 
"Celeste" withCRs
"internet" decodeMimeHeader decodeQuotedPrintable unescapePercents withInternetLineEndings withSqueakLineEndings withoutQuoting
"testing" isAllSeparators lastSpacePosition
"paragraph support" indentationIfBlank:
"arithmetic" ) do: [:sel | Approved add: sel].
	#(byteAt:put: translateToLowercase match:) do: [:sel | AddAndRemove add: sel].

"Symbol"
	#("in class, private" hasInterned:ifTrue:
	"access" morePossibleSelectorsFor: possibleSelectorsFor: selectorsContaining: thatStarts:skipping:
"accessing" "comparing" "copying" "converting" "printing" 
"testing" isInfix isKeyword isPvtSelector isUnary) do: [:sel | Approved add: sel].

"Array"
	#("comparing" "converting" evalStrings 
"printing" "private" hasLiteralSuchThat:) do: [:sel | Approved add: sel].

"Array2D"
	#("access" at:at: atCol: atCol:put: atRow: extent extent:fromArray: height width width:height:type:) do: [:sel | Approved add: sel].
	#(at:at:add: at:at:put: atRow:put: ) do: [:sel | AddAndRemove add: sel].

"ByteArray"
	#("accessing" doubleWordAt: wordAt: 
"platform independent access" longAt:bigEndian: shortAt:bigEndian: unsignedLongAt:bigEndian: unsignedShortAt:bigEndian: 
"converting") do: [:sel | Approved add: sel].
	#(doubleWordAt:put: wordAt:put: longAt:put:bigEndian: shortAt:put:bigEndian: unsignedLongAt:put:bigEndian: unsignedShortAt:put:bigEndian:
	) do: [:sel | AddAndRemove add: sel].

"FloatArray"		"Dont know what happens when prims not here"
	false ifTrue: [#("accessing" "arithmetic" *= += -= /=
"comparing"
"primitives-plugin" primAddArray: primAddScalar: primDivArray: primDivScalar: primMulArray: primMulScalar: primSubArray: primSubScalar:
"primitives-translated" primAddArray:withArray:from:to: primMulArray:withArray:from:to: primSubArray:withArray:from:to:
"converting" "private" "user interface") do: [:sel | Approved add: sel].
	].

"IntegerArray, WordArray"
"RunArray"
	#("in class, instance creation" runs:values: scanFrom:
"accessing" runLengthAt: 
"adding" "copying"
"private" runs values) do: [:sel | Approved add: sel].
	#(coalesce repeatLast:ifEmpty: repeatLastIfEmpty:
		) do: [:sel | AddAndRemove add: sel].

"Stream  -- many operations change its state"
	#("testing" atEnd) do: [:sel | Approved add: sel].
	#("accessing" next: nextMatchAll: nextMatchFor: upToEnd
next:put: nextPut: nextPutAll: "printing" print: printHtml:
	) do: [:sel | AddAndRemove add: sel].

"PositionableStream"
	#("accessing" contentsOfEntireFile originalContents peek peekFor: "testing"
"positioning" position ) do: [:sel | Approved add: sel].
	#(nextDelimited: nextLine upTo: position: reset resetContents setToEnd skip: skipTo: upToAll: ) do: [:sel | AddAndRemove add: sel].
	"Because it is so difficult to test the result of an operation on a Stream (you have to supply another Stream in the same state), we don't support Streams beyond the basics.  We want to find the messages that convert Streams to other things."

"ReadWriteStream"
	#("file status" closed) do: [:sel | Approved add: sel].
	#("accessing" next: on: ) do: [:sel | AddAndRemove add: sel].

"WriteStream"
	#("in class, instance creation" on:from:to: with: with:from:to:
		) do: [:sel | Approved add: sel].
	#("positioning" resetToStart
"character writing" crtab crtab:) do: [:sel | AddAndRemove add: sel].

"LookupKey, Association, Link"
	#("accessing" key nextLink) do: [:sel | Approved add: sel].
	#(key: key:value: nextLink:) do: [:sel | AddAndRemove add: sel].

"Point"
	#("in class, instance creation" r:degrees: x:y:
"accessing" x y "comparing" "arithmetic" "truncation and round off"
"polar coordinates" degrees r theta
"point functions" bearingToPoint: crossProduct: dist: dotProduct: eightNeighbors flipBy:centerAt: fourNeighbors grid: nearestPointAlongLineFrom:to: nearestPointOnLineFrom:to: normal normalized octantOf: onLineFrom:to: onLineFrom:to:within: quadrantOf: rotateBy:centerAt: transposed unitVector
"converting" asFloatPoint asIntegerPoint corner: extent: rect:
"transforming" adhereTo: rotateBy:about: scaleBy: scaleFrom:to: translateBy: "copying"
"interpolating" interpolateTo:at:) do: [:sel | Approved add: sel].

"Rectangle"
	#("in class, instance creation" center:extent: encompassing: left:right:top:bottom: 
	merging: origin:corner: origin:extent: 
"accessing" area bottom bottomCenter bottomLeft bottomRight boundingBox center corner corners innerCorners left leftCenter origin right rightCenter top topCenter topLeft topRight
"comparing"
"rectangle functions" adjustTo:along: amountToTranslateWithin: areasOutside: bordersOn:along: encompass: expandBy: extendBy: forPoint:closestSideDistLen: insetBy: insetOriginBy:cornerBy: intersect: merge: pointNearestTo: quickMerge: rectanglesAt:height: sideNearestTo: translatedToBeWithin: withBottom: withHeight: withLeft: withRight: withSide:setTo: withTop: withWidth:
"testing" containsPoint: containsRect: hasPositiveExtent intersects: isTall isWide
"truncation and round off"
"transforming" align:with: centeredBeneath: newRectFrom: squishedWithin: "copying"
	) do: [:sel | Approved add: sel].

"Color"
	#("in class, instance creation" colorFrom: colorFromPixelValue:depth: fromRgbTriplet: gray: h:s:v: r:g:b: r:g:b:alpha: r:g:b:range:
	"named colors" black blue brown cyan darkGray gray green lightBlue lightBrown lightCyan lightGray lightGreen lightMagenta lightOrange lightRed lightYellow magenta orange red transparent veryDarkGray veryLightGray veryVeryDarkGray veryVeryLightGray white yellow
	"other" colorNames indexedColors pixelScreenForDepth: quickHighLight:
"access" alpha blue brightness green hue luminance red saturation
"equality"
"queries" isBitmapFill isBlack isGray isSolidFill isTranslucent isTranslucentColor
"transformations" alpha: dansDarker darker lighter mixed:with: muchLighter slightlyDarker slightlyLighter veryMuchLighter alphaMixed:with:
"groups of shades" darkShades: lightShades: mix:shades: wheel:
"printing" shortPrintString
"other" colorForInsets rgbTriplet
"conversions" asB3DColor asColor balancedPatternForDepth: bitPatternForDepth: closestPixelValue1 closestPixelValue2 closestPixelValue4 closestPixelValue8 dominantColor halfTonePattern1 halfTonePattern2 indexInMap: pixelValueForDepth: pixelWordFor:filledWith: pixelWordForDepth: scaledPixelValue32
"private" privateAlpha privateBlue privateGreen privateRGB privateRed "copying"
	) do: [:sel | Approved add: sel].

"	For each selector that requires a block argument, add (selector argNum) 
		to the set Blocks."
"ourClasses := #(Object Boolean True False UndefinedObject Behavior ClassDescription Class Metaclass MethodContext BlockContext Message Magnitude Date Time Number Integer SmallInteger LargeNegativeInteger LargePositiveInteger Float Fraction Random Collection SequenceableCollection ArrayedCollection Bag Set Dictionary IdentityDictionary IdentitySet LinkedList Interval MappedCollection OrderedCollection SortedCollection Character String Symbol Array Array2D ByteArray FloatArray IntegerArray WordArray RunArray Stream PositionableStream ReadWriteStream WriteStream LookupKey Association Link Point Rectangle Color).
ourClasses do: [:clsName | cls := Smalltalk at: clsName.
	(cls selectors) do: [:aSel |
		((Approved includes: aSel) or: [AddAndRemove includes: aSel]) ifTrue: [
			(cls formalParametersAt: aSel) withIndexDo: [:tName :ind |
				(tName endsWith: 'Block') ifTrue: [
					Blocks add: (Array with: aSel with: ind)]]]]].
"
#((timesRepeat: 1 ) (indexOf:ifAbsent: 2 ) (pairsCollect: 1 ) (mergeSortFrom:to:by: 3 ) (ifNotNil:ifNil: 1 ) (ifNotNil:ifNil: 2 ) (ifNil: 1 ) (at:ifAbsent: 2 ) (ifNil:ifNotNil: 1 ) (ifNil:ifNotNil: 2 ) (ifNotNil: 1 ) (at:modify: 2 ) (identityIndexOf:ifAbsent: 2 ) (sort: 1 ) (sortBlock: 1 ) (detectMax: 1 ) (repeatLastIfEmpty: 1 ) (allSubclassesWithLevelDo:startingLevel: 1 ) (keyAtValue:ifAbsent: 2 ) (in: 1 ) (ifTrue: 1 ) (or: 1 ) (select: 1 ) (inject:into: 2 )  (forPoint:closestSideDistLen: 2 ) (value:ifError: 2 ) (selectorsDo: 1 ) (removeAllSuchThat: 1 ) (keyAtIdentityValue:ifAbsent: 2 ) (detectMin: 1 ) (detect:ifNone: 1 ) (ifTrue:ifFalse: 1 ) (ifTrue:ifFalse: 2 ) (detect:ifNone: 2 ) (hasLiteralSuchThat: 1 ) (indexOfAnyOf:ifAbsent: 2 ) (reject: 1 ) (newRectFrom: 1 ) (removeKey:ifAbsent: 2 ) (at:ifPresent: 2 ) (associationAt:ifAbsent: 2 ) (withIndexCollect: 1 ) (repeatLast:ifEmpty: 2 ) (findLast: 1 ) (indexOf:startingAt:ifAbsent: 3 ) (remove:ifAbsent: 2 ) (ifFalse:ifTrue: 1 ) (ifFalse:ifTrue: 2 ) (caseOf:otherwise: 2 ) (count: 1 ) (collect: 1 ) (sorted: 1 ) (and: 1 ) (asSortedCollection: 1 ) (with:collect: 2 ) (sourceCodeAt:ifAbsent: 2 ) (detect: 1 ) (collectWithIndex: 1 ) (compiledMethodAt:ifAbsent: 2 ) (bindWithTemp: 1 ) (detectSum: 1 ) (indexOfSubCollection:startingAt:ifAbsent: 3 ) (findFirst: 1 ) (sourceMethodAt:ifAbsent: 2 ) (collect:thenSelect: 1 ) (collect:thenSelect: 2 ) (select:thenCollect: 1 ) (select:thenCollect: 2 ) (ifFalse: 1 ) (indexOfAnyOf:startingAt:ifAbsent: 3 ) (indentationIfBlank: 1 ) ) do: [:anArray |
	Blocks add: anArray].

self initialize3.

"
MethodFinder new initialize.
MethodFinder new organizationFiltered: TranslucentColor class 
"
"Do not forget class messages for each of these classes"

]

{ #category : #initialize }
MethodFinder >> initialize3 [
	"additional selectors to consider"

#(asWords threeDigitName ) do: [:sel | Approved add: sel].
]

{ #category : #search }
MethodFinder >> insertConstants [
	"see if one of several known expressions will do it. C is the constant we discover here."
	"C  data1+C  data1*C  data1//C  (data1*C1 + C2) (data1 = C) (data1 ~= C) (data1 <= C) (data1 >= C) 
 (data1 mod C)"

	thisData size >= 2 ifFalse: [^ false].	"need 2 examples"
	(thisData at: 1) size = 1 ifFalse: [^ false].	"only one arg, data1"

	self const ifTrue: [^ true].
	self constUsingData1Value ifTrue: [^ true].
		"(data1 ?? const), where const is one of the values of data1"
		" == ~~ ~= = <= >= "

	self allNumbers ifFalse: [^ false].
	self constMod ifTrue: [^ true].
	self constPlus ifTrue: [^ true].
	self constMult ifTrue: [^ true].
	self constDiv ifTrue: [^ true].
	self constLinear ifTrue: [^ true].
	^ false
]

{ #category : #initialize }
MethodFinder >> load: dataWithAnswers [
	"Find a function that takes the data and gives the answers.  Odd list entries are data for it, even ones are the answers.  nil input means data and answers were supplied already."
"  (MethodFinder new) load: #( (4 3) 7  (-10 5) -5  (-3 11) 8);
		findMessage  "

dataWithAnswers ifNotNil: [
	data := Array new: dataWithAnswers size // 2.
	1 to: data size do: [:ii | data at: ii put: (dataWithAnswers at: ii*2-1)].
	answers := Array new: data size.
	1 to: answers size do: [:ii | answers at: ii put: (dataWithAnswers at: ii*2)]].
data do: [:list | 
	(list isKindOf: SequenceableCollection) ifFalse: [
		^ self inform: 'first and third items are not Arrays'].
	].
argMap := (1 to: data first size) asArray.
data do: [:list | list size = argMap size ifFalse: [
		self inform: 'data arrays must all be the same size']].
argMap size > 4 ifTrue: [self inform: 'No more than a receiver and 
three arguments allowed'].
	"Really only test receiver and three args." 
thisData := data copy.
mapStage := mapList := nil.

]

{ #category : #'arg maps' }
MethodFinder >> makeAllMaps [ 
	"Make a giant list of all permutations of the args.  To find the function, we will try these permutations of the input data.  receiver, args."

	| ii |
	mapList := Array new: argMap size factorial.
	ii := 1.
	argMap permutationsDo: [:perm |
		mapList at: ii put: perm copy.
		ii := ii + 1].
	mapStage := 1.	"about to be bumped"
]

{ #category : #'arg maps' }
MethodFinder >> mapData [ 
	"Force the data through the map (permutation) to create the data to test."

	thisData := data collect: [:realData |
					argMap collect: [:ind | realData at: ind]].
		
]

{ #category : #initialize }
MethodFinder >> noteDangerous [
	"Remember the methods with really bad side effects."

	Dangerous := Set new.
"Object accessing, testing, copying, dependent access, macpal, flagging"
	#(addInstanceVarNamed:withValue: haltIfNil copyAddedStateFrom: veryDeepCopy veryDeepCopyWith: veryDeepFixupWith: veryDeepInner: addDependent: evaluate:wheneverChangeIn: codeStrippedOut: playSoundNamed: isThisEverCalled isThisEverCalled: logEntry logExecution logExit)
		do: [:sel | Dangerous add: sel].

"Object error handling"
	#(cannotInterpret: caseError confirm: confirm:orCancel: doesNotUnderstand: error: halt halt: notify: notify:at: primitiveFailed shouldNotImplement subclassResponsibility)
		do: [:sel | Dangerous add: sel].

"Object user interface"
	#(basicInspect beep inform: inspect inspectWithLabel: notYetImplemented inspectElement )
		do: [:sel | Dangerous add: sel].

"Object system primitives"
	#(become: becomeForward: instVarAt:put: instVarNamed:put: nextInstance nextObject rootStubInImageSegment: someObject tryPrimitive:withArgs:)
		do: [:sel | Dangerous add: sel].

"Object private"
	#(errorImproperStore errorNonIntegerIndex errorNotIndexable errorSubscriptBounds: mustBeBoolean primitiveError: species storeAt:inTempFrame:)
		do: [:sel | Dangerous add: sel].

"Object, translation support"
	#(cCode: cCode:inSmalltalk: cCoerce:to: export: inline: returnTypeC: sharedCodeNamed:inCase: var:declareC:)
		do: [:sel | Dangerous add: sel].

"Object, objects from disk, finalization.  And UndefinedObject"
	#(comeFullyUpOnReload: objectForDataStream: readDataFrom:size: rehash saveOnFile storeDataOn: actAsExecutor executor finalize retryWithGC:until:   suspend)
		do: [:sel | Dangerous add: sel].

"No Restrictions:   Boolean, False, True, "

"Morph"
	#()
		do: [:sel | Dangerous add: sel].

"Behavior"
	#(obsolete confirmRemovalOf: copyOfMethodDictionary storeLiteral:on: addSubclass: removeSubclass: superclass: 
"creating method dictionary" addSelector:withMethod: compile: compile:notifying: compileAll compileAllFrom: compress decompile: defaultSelectorForMethod: methodDictionary: recompile:from: recompileChanges removeSelector: compressedSourceCodeAt: selectorAtMethod:setClass: allInstances allSubInstances inspectAllInstances inspectSubInstances thoroughWhichSelectorsReferTo:special:byte: "enumerating" allInstancesDo: allSubInstancesDo: allSubclassesDo: allSuperclassesDo: selectSubclasses: selectSuperclasses: subclassesDo: withAllSubclassesDo:
   "too slow->" crossReference removeUninstantiatedSubclassesSilently "too slow->" unreferencedInstanceVariables
"private" flushCache format:variable:words:pointers: format:variable:words:pointers:weak: format:variable:bitsUnitSize:pointers:weak: printSubclassesOn:level: basicRemoveSelector: addSelector:withMethod:notifying: addSelectorSilently:withMethod:)
		do: [:sel | Dangerous add: sel].

"CompiledMethod"
	#(defaultSelector)
		do: [:sel | Dangerous add: sel].

"Others "
	#("no tangible result" do: associationsDo:  
"private" adaptToCollection:andSend: adaptToNumber:andSend: adaptToPoint:andSend: adaptToString:andSend: instVarAt:put: asDigitsToPower:do: combinations:atATimeDo: doWithIndex: pairsDo: permutationsDo: reverseDo: reverseWith:do: with:do: withIndexDo: asDigitsAt:in:do: combinationsAt:in:after:do: errorOutOfBounds permutationsStartingAt:do: fromUser)
		do: [:sel | Dangerous add: sel].


	#(    fileOutPrototype addSpareFields makeFileOutFile )
		do: [:sel | Dangerous add: sel].
	#(recompile:from: recompileAllFrom: recompileChanges asPrototypeWithFields: asPrototype addInstanceVarNamed:withValue: addInstanceVariable addClassVarName: removeClassVarName: findOrAddClassVarName: instanceVariableNames: )
		do: [:sel | Dangerous add: sel].

 
]

{ #category : #initialize }
MethodFinder >> organizationFiltered: aClass [
	"Return the organization of the class with all selectors defined in superclasses removed.  (except those in Object)"

	| org str |
	org := aClass organization deepCopy.
	Dangerous do: [:sel |
			org removeElement: sel].
	Approved do: [:sel |
			org removeElement: sel].
	AddAndRemove do: [:sel |
			org removeElement: sel].
	str := org printString copyWithout: $(.
	str := '(', (str copyWithout: $) ).
	str := str replaceAll: $' with: $".
	^ str

]

{ #category : #'arg maps' }
MethodFinder >> permuteArgs [ 
	"Run through ALL the permutations.  First one was as presented."

	data first size <= 1 ifTrue: [^ false].	"no other way"
	mapList ifNil: [self makeAllMaps].
	mapStage := mapStage + 1.
	mapStage > mapList size ifTrue: [^ false].
	argMap := mapList at: mapStage.
	self mapData.
	^ true
	
]

{ #category : #search }
MethodFinder >> search: multi [
	"if Multi is true, collect all selectors that work."
	selector := OrderedCollection new.	"list of them"
	self simpleSearch.
	multi not & (selector isEmpty not) ifTrue:[^ selector].

	[self permuteArgs] whileTrue:
		[self simpleSearch.
		multi not & (selector isEmpty not) ifTrue: [^ selector]].

	self insertConstants.
	"(selector isEmpty not) ifTrue: [^ selector]].    expression is the answer, not a selector"
	^ #()
]

{ #category : #search }
MethodFinder >> searchForOne [
	"Look for and return just one answer"

	expressions := OrderedCollection new.
	self search: false.	"non-multi"
	^ expressions
			
]

{ #category : #access }
MethodFinder >> selectors [
	"Note the inst var does not have an S on the end"

	^ selector
]

{ #category : #search }
MethodFinder >> simpleSearch [
	"Run through first arg's class' selectors, looking for one that works."

| class supers listOfLists |
self exceptions.
class := thisData first first class.
"Cache the selectors for the receiver class"
(class == cachedClass and: [cachedArgNum = ((argMap size) - 1)]) 
	ifTrue: [listOfLists := cachedSelectorLists]
	ifFalse: [supers := class withAllSuperclasses.
		listOfLists := OrderedCollection new.
		supers do: [:cls |
			listOfLists add: (cls selectorsWithArgs: (argMap size) - 1)].
		cachedClass := class.
		cachedArgNum := (argMap size) - 1.
		cachedSelectorLists := listOfLists].
listOfLists do: [:selectorList |
	selectorList do: [:aSel |
		(selector includes: aSel) ifFalse: [
			((Approved includes: aSel) or: [AddAndRemove includes: aSel]) ifTrue: [
				(self testPerfect: aSel) ifTrue: [
					selector add: aSel.
					expressions add: (String streamContents: [:strm | 
						strm nextPutAll: 'data', argMap first printString.
						aSel keywords doWithIndex: [:key :ind |
							strm nextPutAll: ' ',key.
							(key last == $:) | (key first isLetter not)
								ifTrue: [strm nextPutAll: ' data', 
									(argMap at: ind+1) printString]]])
					]]]]].

]

{ #category : #initialize }
MethodFinder >> test2: anArray [
	"look for bad association"

	anArray do: [:sub |
		sub class == Association ifTrue: [
			(#('true' '$a' '2' 'false') includes: sub value printString) ifFalse: [
				self error: 'bad assn'].
			(#('3' '5.6' 'x' '''abcd''') includes: sub key printString) ifFalse: [
				self error: 'bad assn'].
		].
		sub class == Array ifTrue: [
			sub do: [:element | 
				element isString ifTrue: [element first asciiValue < 32 ifTrue: [
						self error: 'store into string in data']].
				element class == Association ifTrue: [
					element value class == Association ifTrue: [
						self error: 'bad assn']]]].
		sub class == Date ifTrue: [sub year isInteger ifFalse: [
				self error: 'stored into input date!!']].
		sub class == Dictionary ifTrue: [
				sub size > 0 ifTrue: [
					self error: 'store into dictionary']].
		sub class == OrderedCollection ifTrue: [
				sub size > 4 ifTrue: [
					self error: 'store into OC']].
		].
]

{ #category : #initialize }
MethodFinder >> test3 [
	"find the modification of the caracter table"

	(#x at: 1) asciiValue = 120 ifFalse: [self error: 'Character table mod'].
]

{ #category : #initialize }
MethodFinder >> testFromTuple: nth [
	"verify that the methods allowed don't crash the system.  Try N of each of the fundamental types.  up to 4 of each kind." 

| objects nonRepeating even other aa cnt |
objects := #((1 4 17 42) ($a $b $c $d) ('one' 'two' 'three' 'four')
	(x + rect: new) ((a b 1 4) (c 1 5) ($a 3 d) ()) (4.5 0.0 3.2 100.3)
	).

objects := objects, {{true. false. true. false}. {Point. SmallInteger. Association. Array}.
	{Point class. SmallInteger class. Association class. Array class}.
	"{ 4 blocks }."
	{Date today. '1 Jan 1950' asDate. '25 Aug 1987' asDate. '1 Jan 2000' asDate}.
	{'15:16' asTime. '1:56' asTime. '4:01' asTime. '6:23' asTime}.
	{Dictionary new. Dictionary new. Dictionary new. Dictionary new}.
	{#(a b 1 4) asOrderedCollection. #(c 1 5) asOrderedCollection. 
		#($a 3 d) asOrderedCollection. #() asOrderedCollection}.
	{3 -> true. 5.6 -> $a. #x -> 2. 'abcd' -> false}.
	{9 @ 3 extent: 5 @ 4. 0 @ 0 extent: 45 @ 9. -3 @ -7 extent: 2 @ 2. 4 @ 4 extent: 16 @ 16}.
	{Color red.  Color blue. Color black. Color gray}}.

self test2: objects.
"rec+0, rec+1, rec+2, rec+3 need to be tested.  " 
cnt := 0.
nth to: 4 do: [:take |
	nonRepeating := OrderedCollection new.
	objects do: [:each |
		nonRepeating addAll: (each copyFrom: 1 to: take)].
	"all combinations of take, from nonRepeating"
	even := true.
	nonRepeating combinations: take atATimeDo: [:tuple |
		even ifTrue: [other := tuple shallowCopy]
			ifFalse: [self load: (aa := Array with: tuple with: 1 with: other with: 7).
				(cnt := cnt + 1) \\ 50 = 0 ifTrue: [
					Transcript cr; show: aa first printString].
				self search: true.
				self test2: aa.
				self test2: nonRepeating.
				"self test2: objects"].
		even := even not].
	].
]

{ #category : #search }
MethodFinder >> testPerfect: aSelector [
	"Try this selector! Return true if it answers every example perfectly.  Take the args in the order they are.  Do not permute them.  Survive errors.  later cache arg lists."

| sz argList val rec activeSel perform |
	"Transcript cr; show: aSelector.		debug"
perform := aSelector beginsWith: 'perform:'.
sz := argMap size.
1 to: thisData size do: [:ii | "each example set of args"
	argList := (thisData at: ii) copyFrom: 2 to: sz.
	perform
		ifFalse: [activeSel := aSelector]
		ifTrue: [activeSel := argList first.	"what will be performed"
			((Approved includes: activeSel) or: [AddAndRemove includes: activeSel])
				ifFalse: [^ false].	"not approved"
			aSelector == #perform:withArguments: 
				ifTrue: [activeSel numArgs = (argList at: 2) basicSize "avoid error" 
							ifFalse: [^ false]]
				ifFalse: [activeSel numArgs = (aSelector numArgs - 1) 
							ifFalse: [^ false]]].
	1 to: sz do: [:num | 
		(Blocks includes: (Array with: activeSel with: num)) ifTrue: [
			(argList at: num) isBlock ifFalse: [^ false]]].
	rec := (AddAndRemove includes: activeSel) 
			ifTrue: [(thisData at: ii) first isSymbol ifTrue: [^ false].
						"vulnerable to modification"
				(thisData at: ii) first copyTwoLevel] 	"protect from damage"
			ifFalse: [(thisData at: ii) first].
	val := [[rec perform: aSelector withArguments: argList]
				on: Deprecation do: [ :ex | ex resume ]] 
					ifError: [:aString :aReceiver | 
							"self test3."
							"self test2: (thisData at: ii)."
							^ false].
	"self test3."
	"self test2: (thisData at: ii)."
	((answers at: ii) closeTo: val) ifFalse: [^ false].
	].
^ true
]

{ #category : #initialize }
MethodFinder >> testRandom [
	"verify that the methods allowed don't crash the system.  Pick 3 or 4 from a mixed list of the fundamental types." 

	| objects other aa cnt take tuple fName sss random |
	objects := #(
		(1 4 17 42) ($a $b $c $d) ('one' 'two' 'three' 'four')
		(x + rect: new) ((a b 1 4) (c 1 5) ($a 3 d) ()) (4.5 0.0 3.2 100.3)
	).

	objects := objects, {{true. false. true. false}. {Point. SmallInteger. Association. Array}.
		{Point class. SmallInteger class. Association class. Array class}.
		"{ 4 blocks }."
		{Date today. '1 Jan 1950' asDate. '25 Aug 1987' asDate. '1 Jan 2000' asDate}.
		{'15:16' asTime. '1:56' asTime. '4:01' asTime. '6:23' asTime}.
		{Dictionary new. Dictionary new. Dictionary new. Dictionary new}.
		{#(a b 1 4) asOrderedCollection. #(c 1 5) asOrderedCollection. 
			#($a 3 d) asOrderedCollection. #() asOrderedCollection}.
		{3 -> true. 5.6 -> $a. #x -> 2. 'abcd' -> false}.
		{9 @ 3 extent: 5 @ 4. 0 @ 0 extent: 45 @ 9. -3 @ -7 extent: 2 @ 2. 4 @ 4 extent: 16 @ 16}.
		{Color red.  Color blue. Color black. Color gray}}.

	self test2: objects.
	"rec+0, rec+1, rec+2, rec+3 need to be tested.  " 
	fName := (FileDirectory default fileNamesMatching: '*.ran') first.
	sss := fName splitInteger first.
	random := Random seed: sss.
	cnt := 0.
	
	[take := #(3 4) atRandom: random.
	tuple := (1 to: take) collect: [:ind | (objects atRandom: random) atRandom: random].
	other := (1 to: take) collect: [:ind | (objects atRandom: random) atRandom: random].
	self load: (aa := Array with: tuple with: 1 with: other with: 7).
	((cnt := cnt + 1) \\ 10 = 0) " | (cnt > Skip)" ifTrue:
		[Transcript cr; show: cnt printString; tab; tab; show: aa first printString].
	cnt > (Smalltalk at: #StopHere) ifTrue: [self halt].		"stop just before crash"
	cnt > (Smalltalk at: #Skip)
		ifTrue:
			["skip this many at start"
			self search: true.
			self test2: aa first.  self test2: (aa at: 3).
			"self test2: objects"]] repeat.
	
]

{ #category : #'arg maps' }
MethodFinder >> thisData [
	^ thisData 
]

{ #category : #initialize }
MethodFinder >> verify [
	"Test a bunch of examples"
	"	MethodFinder new verify    "
Approved ifNil: [self initialize].	"Sets of allowed selectors"
(MethodFinder new load: #( (0) 0  (30) 0.5  (45) 0.707106  (90) 1)
	) searchForOne asArray = #('data1 degreeSin') ifFalse: [self error: 'should have found it'].
(MethodFinder new load:  { { true. [3]. [4]}. 3.  { false. [0]. [6]}. 6}
	) searchForOne asArray = #('data1 ifTrue: data2 ifFalse: data3') ifFalse: [
		self error: 'should have found it'].
(MethodFinder new load: {#(1). true. #(2). false. #(5). true. #(10). false}
	) searchForOne asArray = #('data1 odd') ifFalse: [self error: 'should have found it'].
		"will correct the date type of #true, and complain"
(MethodFinder new load: #((4 2) '2r100'   (255 16) '16rFF'    (14 8) '8r16')
	) searchForOne asArray = 
		#('data1 radix: data2' 'data1 printStringBase: data2' 'data1 storeStringBase: data2')
			  ifFalse: [self error: 'should have found it'].	
(MethodFinder new load: {{Point x: 3 y: 4}. 4.  {Point x: 1 y: 5}. 5}
	) searchForOne asArray = #('data1 y') ifFalse: [self error: 'should have found it'].	
(MethodFinder new load: #(('abcd') $a  ('TedK') $T)
	) searchForOne asArray = #('data1 asCharacter' 'data1 first' 'data1 anyOne')
		 ifFalse: [self error: 'should have found it'].	
(MethodFinder new load: #(('abcd' 1) $a  ('Ted ' 3) $d )
	) searchForOne asArray = #('data1 at: data2' 'data1 atPin: data2' 'data1 atWrap: data2')
		ifFalse: [self error: 'should have found it'].	
(MethodFinder new load: #(((12 4 8)) 24  ((1 3 6)) 10 )
	) searchForOne asArray=  #('data1 sum') ifFalse: [self error: 'should have found it'].	
		"note extra () needed for an Array object as an argument"

(MethodFinder new load: #((14 3) 11  (-10 5) -15  (4 -3) 7)
	) searchForOne asArray = #('data1 - data2') ifFalse: [self error: 'should have found it'].
(MethodFinder new load: #((4) 4  (-10) 10 (-3) 3 (2) 2 (-6) 6 (612) 612)
	) searchForOne asArray = #('data1 abs') ifFalse: [self error: 'should have found it'].
(MethodFinder new load: {#(4 3). true.  #(-7 3). false.  #(5 1). true.  #(5 5). false}
	) searchForOne asArray = #('data1 > data2') ifFalse: [self error: 'should have found it'].	
(MethodFinder new load: #((5) 0.2   (2) 0.5)
	) searchForOne asArray = #('data1 reciprocal') ifFalse: [self error: 'should have found it'].	
(MethodFinder new load: #((12 4 8) 2  (1 3 6) 2  (5 2 16) 8)
	) searchForOne asArray = #()     " '(data3 / data2) ' want to be able to leave out args"  
		ifFalse: [self error: 'should have found it'].	
(MethodFinder new load: #((0.0) 0.0  (1.5) 0.997495  (0.75) 0.681639)
	) searchForOne asArray = #('data1 sin') ifFalse: [self error: 'should have found it'].	
(MethodFinder new load: #((7 5) 2   (4 5) 4   (-9 4) 3)
	) searchForOne asArray = #('data1 \\ data2') ifFalse: [self error: 'should have found it'].	

(MethodFinder new load: #((7) 2   (4) 2 )
	) searchForOne asArray = #('^ 2')  ifFalse: [self error: 'should have found it'].	
(MethodFinder new load: {#(7). true.   #(4.1).  true.   #(1.5). false}
	) searchForOne asArray = #('data1 >= 4.1') ifFalse: [self error: 'should have found it'].	
(MethodFinder new load: #((35) 3   (17) 1   (5) 5)
	) searchForOne asArray = #('data1 \\ 8') ifFalse: [self error: 'should have found it'].	
(MethodFinder new load: #((36) 7   (50) 10 )
	) searchForOne asArray = #('data1 quo: 5' 'data1 // 5') ifFalse: [
		self error: 'should have found it'].	
(MethodFinder new load: #( ((2 3) 2) 8   ((2 3) 5) 17 )
	) searchForOne asArray = #('data1 polynomialEval: data2') ifFalse: [
		self error: 'should have found it'].	
(MethodFinder new load: #((2) 8   (5) 17 )
	) searchForOne asArray = #('#(2 3) polynomialEval: data1') ifFalse: [
		self error: 'should have found it'].	

]
