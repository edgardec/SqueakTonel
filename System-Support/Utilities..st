"
A repository for general and miscellaneous utilities; much of what is here are in effect global methods that don't naturally attach to anything else.  1/96 sw
"
Class {
	#name : #Utilities,
	#superclass : #Object,
	#classVars : [
		'AuthorInitials',
		'AuthorName',
		'CommonRequestStrings',
		'LastStats',
		'ScrapsBook'
	],
	#category : #'System-Support'
}

{ #category : #'common requests' }
Utilities class >> appendToCommonRequests: aString [
	self commonRequestStrings: (CommonRequestStrings contents, String cr, aString)

"Utilities appendToCommonRequests: 'self beep'"

]

{ #category : #identification }
Utilities class >> authorInitials [
	"Answer the initials to be used to identify the current code author.  "

	[AuthorInitials isEmpty] whileTrue: [self setAuthorInitials].
	^ AuthorInitials
]

{ #category : #identification }
Utilities class >> authorInitials: aString [

	AuthorInitials := aString.

	"Case of being reset due to, eg, copy of image."
	aString isEmpty ifTrue: [AuthorName := '']
]

{ #category : #identification }
Utilities class >> authorInitialsPerSe [
	"Answer the currently-prevailing author initials, such as they, empty or not"

	^ AuthorInitials
]

{ #category : #identification }
Utilities class >> authorName [
	AuthorName ifEmpty: [self setAuthorName].
	^ AuthorName
]

{ #category : #identification }
Utilities class >> authorName: aString [
	AuthorName := aString
]

{ #category : #identification }
Utilities class >> authorNamePerSe [

	^ AuthorName
]

{ #category : #miscellaneous }
Utilities class >> awaitMouseUpIn: box repeating: doBlock ifSucceed: succBlock [
	"The mouse has gone down in box; track the mouse, inverting the box while it's within, and if, on mouse up, the cursor was still within the box, execute succBlock.  While waiting for the mouse to come up, repeatedly execute doBlock. 5/11/96 sw
	6/10/96 sw: call new method that adds extra feature"

	^ self awaitMouseUpIn: box whileMouseDownDo: doBlock whileMouseDownInsideDo: [] ifSucceed: succBlock
]

{ #category : #miscellaneous }
Utilities class >> awaitMouseUpIn: box whileMouseDownDo: doBlock1 whileMouseDownInsideDo: doBlock2 ifSucceed: succBlock [
	"The mouse has gone down in box; track the mouse, inverting the box while it's within, and if, on mouse up, the cursor was still within the box, execute succBlock.  While waiting for the mouse to come up, repeatedly execute doBlock1, and also, if the cursor is within the box, execute doBlock2.  6/10/96 sw
3/31/00 JMM added logic to stop multiple redraws"

	| p inside lightForm darkForm isLight |

	p := Sensor cursorPoint.
	inside := box insetBy: 1.
	isLight := true.
	lightForm := Form fromDisplay: inside.
	darkForm := lightForm deepCopy reverse.
	[Sensor anyButtonPressed] whileTrue:
		[doBlock1 value.
		(box containsPoint: (p := Sensor cursorPoint))
			ifTrue: [doBlock2 value.
					isLight ifTrue: 
						[isLight := false.
						darkForm displayAt: inside origin]]
			ifFalse: [isLight ifFalse:
						[isLight := true.
						lightForm displayAt: inside origin]]].
	(box containsPoint: p)
		ifTrue: [lightForm displayAt: inside origin.
				^ succBlock value]

]

{ #category : #identification }
Utilities class >> changeStamp [ 
	"Answer a string to be pasted into source code to mark who changed it and when."
	^ self authorInitials , ' ' , Date today mmddyyyy, ' ',
		(String streamContents: [:s | Time now print24: true showSeconds: false on: s])
]

{ #category : #identification }
Utilities class >> changeStampPerSe [
	"Answer a string to be pasted into source code to mark who changed it and when."
	^String streamContents:
		[ : stream | 
		self authorInitialsPerSe isEmptyOrNil
			ifTrue: [ '·' ]
			ifFalse: [ self authorInitialsPerSe ].
		stream
			 space ;
			 nextPutAll: Date today mmddyyyy ;
			 space.
		(String streamContents:
			[ : s | 
			Time now
				print24: true
				on: s ])
			copyFrom: 1
			to: 5 ]
]

{ #category : #'summer97 additions' }
Utilities class >> chooseFileWithSuffix: aSuffix [
	"Utilities chooseFileWithSuffix: '.gif'"
	| aList aName |
	aList := FileDirectory default fileNamesMatching: '*', aSuffix.
	aList size > 0
		ifTrue:
			[aName := UIManager default chooseFrom: aList values: aList title: 'Choose a file'.
			^ aName]
		ifFalse:
			[self inform: 'Sorry, there are no files
whose names end with "', aSuffix, '".'.
			^ nil]
]

{ #category : #'summer97 additions' }
Utilities class >> chooseFileWithSuffixFromList: aSuffixList withCaption: aCaption [
	"Pop up a list of all files in the default directory which have a suffix in the list.  Return #none if there are none; return nil if the user backs out of the menu without making a choice."
	"Utilities chooseFileWithSuffixFromList: #('.gif' '.jpg')"
	| aList aName |
	aList := OrderedCollection new.
	aSuffixList do:
		[:aSuffix | aList addAll: (FileDirectory default fileNamesMatching: '*', aSuffix)].
	^ aList size > 0
		ifTrue:
			[aName := UIManager default chooseFrom: aList values: aList title: aCaption.
			aName]
		ifFalse:
			[#none]
]

{ #category : #'summer97 additions' }
Utilities class >> classCategoriesStartingWith: aPrefix [
	"Answer a list of system class categories beginning with the given prefix"

	"Utilities classCategoriesStartingWith: 'Files'"

	^ SystemOrganization categories select:
		[:aCat | (aCat asString findString:  aPrefix startingAt: 1) = 1]
]

{ #category : #'class initialization' }
Utilities class >> cleanUp: aggressive [

	aggressive ifTrue: [
		self authorInitials: String empty.
		self authorName: String empty.
		CommonRequestStrings := nil].
]

{ #category : #miscellaneous }
Utilities class >> cleanseOtherworldlySteppers [
	"If the current project is a morphic one, then remove from its steplist those morphs that are not really in the world"

	| old delta |
	Smalltalk isMorphic ifTrue:
		[old := self currentWorld stepListSize.
		self currentWorld steppingMorphsNotInWorld do: [:m | m delete].
		self currentWorld cleanseStepList.
		(delta := (old - self currentWorld stepListSize)) > 0 ifTrue:
			[Transcript cr; show: (delta asString, ' morphs removed from steplist')]]

	"Utilities cleanseOtherworldlySteppers"
]

{ #category : #'common requests' }
Utilities class >> commonRequestStrings [

	(CommonRequestStrings == nil or: [CommonRequestStrings isKindOf: Array])
		ifTrue: [self initializeCommonRequestStrings].
	^ CommonRequestStrings
]

{ #category : #'common requests' }
Utilities class >> commonRequestStrings: aString [
	"Initialize the common request strings from aString.  "

	CommonRequestStrings := StringHolder new contents: aString
]

{ #category : #miscellaneous }
Utilities class >> convertCRtoLF: fileName [
	"Convert the given file to LF line endings. Put the result in a file with the extention '.lf'"

	| in out c justPutCR |
	in := (FileStream readOnlyFileNamed: fileName) binary.
	out :=  (FileStream newFileNamed: fileName, '.lf') binary.
	justPutCR := false.
	[in atEnd] whileFalse: [
		c := in next.
		c = 10
			ifTrue: [
				out nextPut: 13.
				justPutCR := true]
			ifFalse: [
				(justPutCR and: [c = 10]) ifFalse: [out nextPut: c].
				justPutCR := false]].
	in close.
	out close.

]

{ #category : #identification }
Utilities class >> copyrightNotice [
	^ 'Copyright 1985-96, Apple Computer, Inc.'
]

{ #category : #miscellaneous }
Utilities class >> createPageTestWorkspace [
	"Used to generate a workspace window for testing page up and page down stuff."
	"Utilities createPageTestWorkspace"

	| numberOfLines maxStringLength minLineCounterSize lineCounterSize offsetSize stream headerConstant prevStart prevStrLen prevLineNumber |
	numberOfLines := 400.
	maxStringLength := 22.
	minLineCounterSize := 3.
	lineCounterSize := (numberOfLines log asInteger + 1) max: minLineCounterSize.
	offsetSize := 5.
	stream := String new writeStream.
	headerConstant := lineCounterSize + 1 + offsetSize + 1.
	prevStart := headerConstant negated.
	prevStrLen := 0.
	prevLineNumber := 0.
	numberOfLines timesRepeat: [ | log stringLen pad lineNumber charIndex start |
		stringLen := maxStringLength atRandom max: 1.
		lineNumber := prevLineNumber + 1.
		start := prevStart + prevStrLen + headerConstant + 1.
		prevStart := start.
		prevStrLen := stringLen.
		prevLineNumber := lineNumber.
		log := lineNumber log asInteger.
		pad := lineCounterSize - log - 1.
		pad timesRepeat: [stream nextPutAll: '0'].
		stream nextPutAll: lineNumber printString.
		stream space.
		log := start log asInteger.
		pad := offsetSize - log - 1.
		pad timesRepeat: [stream nextPutAll: '0'].
		stream nextPutAll: start printString.
		stream space.
		charIndex := 'a' first asInteger.
		stringLen timesRepeat: [ | char |
			char := Character value: charIndex.
			charIndex := charIndex + 1.
			stream nextPut: char].
		lineNumber = numberOfLines ifFalse: [stream cr]
		].
	UIManager default edit: stream contents label: 'Test Data'.

]

{ #category : #identification }
Utilities class >> dateStamp [
	"Utilities dateStamp"
	^ Date today mmddyyyy, ' ',
		((String streamContents: [:s | Time now print24: true on: s]) copyFrom: 1 to: 5)
]

{ #category : #identification }
Utilities class >> dateTimeSuffix [
	"Answer a string which indicates the date and time, intended for use in building fileout filenames, etc."

	"Utilities dateTimeSuffix"
	^Preferences twentyFourHourFileStamps
		ifFalse:
			[self monthDayTimeStringFrom: Time totalSeconds]
		ifTrue:
			[self monthDayTime24StringFrom: Time totalSeconds]
]

{ #category : #miscellaneous }
Utilities class >> decimalPlacesForFloatPrecision: precision [
	"Answer the number of decimal places that correspond to the given floatPrecision"

	^ (#(1 0.1 0.01 0.001 0.0001 0.00001 0.000001 0.0000001 0.00000001 0.000000001) indexOf: precision ifAbsent: [ ^precision log negated floor ]) - 1

"
#(1 0.1 0.01 0.001 0.0001 0.00001 0.000001 0.0000001 0.00000001 0.000000001) collect: [:prec | Utilities decimalPlacesForFloatPrecision: prec]
"
]

{ #category : #miscellaneous }
Utilities class >> decommissionTheAllCategory [
	"Utilities decommissionTheAllCategory"
	"Moves all methods that are in a category named 'all' into the default 'as yet unclassified' category"

	| methodCount classCount |
	self flag: #ShouldBeMovedIntoClassOrganization. "sd"
	methodCount := 0.
	classCount := 0.
	self systemNavigation allBehaviorsDo:
		[:aClass | | org any | org := aClass organization.
			any := false.
			aClass selectorsDo:
				[:aSelector | | aCategory |
					aCategory := org categoryOfElement: aSelector.
					aCategory = #all ifTrue:
						[org classify: aSelector under: ClassOrganizer default suppressIfDefault: false.
						methodCount := methodCount + 1.
						any := true]].
			any ifTrue: [classCount := classCount + 1].
			org removeEmptyCategories].
	Transcript cr; show: methodCount printString, ' methods in ', classCount printString, ' classes moved
from "all" to "as yet unclassified"'

]

{ #category : #miscellaneous }
Utilities class >> doesMethod: aSelector forClass: aClass bearInitials: initials [
	"Answer whether a method bears the given initials at the head of its time stamp"

	| aTimeStamp implementingClass aMethod |
	implementingClass := aClass whichClassIncludesSelector: aSelector.
	implementingClass ifNil: [^ false].
	(aMethod := implementingClass compiledMethodAt: aSelector)
		ifNil: [^ false].
	^ (aTimeStamp := aMethod timeStamp) notNil and:
		[aTimeStamp beginsWith: initials]
]

{ #category : #debugging }
Utilities class >> doesNotUnderstand: aMessage [
	"A temporary expedient for revectoring various messages formerly sent to Utilities that now are instead implemented by Flaps; this is only for the benefit of pre-existing buttons and menu items that were set up to call the old interface"

	| aSelector |
	aSelector := aMessage selector.
	(#(addLocalFlap explainFlaps addMenuFlap addPaintingFlap addStackToolsFlap addGlobalFlap offerGlobalFlapsMenu toggleWhetherToUseGlobalFlaps ) includes: aSelector)
		ifTrue:
			[^ self inform: 
'Sorry, this is an obsolete menu.  Please
dismiss it and get a fresh one.  Thank you'].

	^ super doesNotUnderstand: aMessage
]

{ #category : #'common requests' }
Utilities class >> editCommonRequestStrings [
	"Let the user edit the common request strings.  2/1/96 sw"

	CommonRequestStrings openLabel: 'Common Request Strings'
]

{ #category : #'common requests' }
Utilities class >> eval: aString [
	"Evaluate the string in a neutral context, and under certain circumstances print the 
	result in the transcript"

	| result |
	result := Compiler new evaluate: aString in: nil to: nil.
	(result isNumber) | (result isString)
		ifTrue:
			[Transcript cr; nextPutAll: result printString]
]

{ #category : #identification }
Utilities class >> fixStamp: changeStamp [ 
	| parts |
	parts := changeStamp findTokens: ' '.
	(parts size > 0 and: [parts last first isLetter]) ifTrue:
		["Put initials first in all time stamps..."
		^ String streamContents:
				[:s | s nextPutAll: parts last.
				parts allButLast do: [:p | s space; nextPutAll: p]]].
	^ changeStamp
]

{ #category : #miscellaneous }
Utilities class >> fixUpProblemsWithAllCategory [
	"Moves all methods that are in formally classified a category named '-- all --' into the default 'as yet unclassified' category"

	"Utilities fixUpProblemsWithAllCategory"

	| methodCount classCount |
	self flag: #ShouldBeMovedInClassOrganization.
	methodCount := 0.
	classCount := 0.
	self systemNavigation allBehaviorsDo:
		[:aClass | | org any | org := aClass organization.
			(org categories includes: #'-- all --') ifTrue:
				[any := false.
				aClass selectorsDo:
					[:aSelector | | aCategory |
						aCategory := org categoryOfElement: aSelector.
						aCategory = #'-- all --' ifTrue:
							[org classify: aSelector under: ClassOrganizer default suppressIfDefault: false.
							Transcript cr; show: aClass name, ' >> ', aSelector.
							methodCount := methodCount + 1.
							any := true]].
			any ifTrue: [classCount := classCount + 1].
			org removeEmptyCategories]].
	Transcript cr; show: methodCount printString, ' methods in ', classCount printString, ' classes moved from "-- all --" to "as yet unclassified"'

]

{ #category : #miscellaneous }
Utilities class >> floatPrecisionForDecimalPlaces: places [
	"Answer the floatPrecision that corresponds to the given number of decimal places"

	^ places caseOf:
			{[0]->[1] .
			[1]-> [0.1] . 
			[2]-> [0.01] .
			[3]-> [0.001] .
			[4]-> [0.0001] .
			[5]-> [0.00001] .
			[6]-> [0.000001] .
			[7]-> [0.0000001] .
			[8]-> [0.00000001] .
			[9]-> [0.000000001].
			[10]->[0.0000000001]}
		otherwise:
			[(10.0 raisedTo: places negated) asFloat]

"
(0 to: 6) collect: [:i | Utilities floatPrecisionForDecimalPlaces: i]
(-10 to: 20) collect: [:i | Utilities floatPrecisionForDecimalPlaces: i]
"
]

{ #category : #miscellaneous }
Utilities class >> garbageCollectAndReport [
	"Do a garbage collection, and report results to the user."

	| reportString |
	reportString := String streamContents:
		[:aStream | 
			aStream 
				nextPutAll: 'The following amounts of memory are still available:' translated;
				cr.
			aStream nextPutAll: Smalltalk bytesLeftString.
			Smalltalk at: #Command ifPresent:
				[:cmdClass | | cc |
				(cc := cmdClass instanceCount) > 0 ifTrue:
					[aStream 
						cr; 
						nextPutAll: '(note: there are ';
						print: cc;
						nextPutAll: ' undo record(s) present in your';
						cr;
						nextPutAll: 'system; purging them may free up more space.)']]].
			
	self inform: reportString

]

{ #category : #'summer97 additions' }
Utilities class >> graphicsFileSuffixes [
	"Answer a list of filename suffixes which signal file content which we are able to internalize"

	^#('.gif' '.bmp' '.jpg' '.jpeg' '.jpe', '.form')
]

{ #category : #'user interface' }
Utilities class >> informUser: aString during: aBlock [
	"Display a message above (or below if insufficient room) the cursor during execution of the given block. This is now handled by UIManager."
	"Utilities informUser: 'Just a sec!' during: [(Delay forSeconds: 1) wait]"
	^UIManager default informUser: aString during: aBlock.
]

{ #category : #'user interface' }
Utilities class >> informUserDuring: aBlock [
	"Display a message above (or below if insufficient room) the cursor during execution of the given block. This is now handled by UIManager."
	"Utilities informUserDuring:[:bar|
		#(one two three) do:[:info|
			bar value: info.
			(Delay forSeconds: 1) wait]]"
	^UIManager default informUserDuring: aBlock
]

{ #category : #'class initialization' }
Utilities class >> initialize [
	(self classVarNames includes: 'ScrapsBook') ifTrue: [self removeClassVarName: 'ScrapsBook'].
]

{ #category : #'common requests' }
Utilities class >> initializeCommonRequestStrings [
	"Initialize the common request strings, a directly-editable list of expressions that can be evaluated from the 'do...' menu."

	CommonRequestStrings := StringHolder new contents: 
'Utilities emergencyCollapse.
Utilities closeAllDebuggers.
RecentMessages default revertMostRecent.
-
MCFileBasedRepository flushAllCaches
-
Sensor keyboard.
ParagraphEditor abandonChangeText.
Cursor normal show.
-
CommandHistory resetAllHistory.
Project allInstancesDo: [:p | p displayDepth: 16].
ScriptingSystem inspectFormDictionary.
Form fromUser bitEdit.
Display border: (0@0 extent: 640@480) width: 2.
-
Undeclared inspect.
Undeclared removeUnreferencedKeys; inspect.
Transcript clear.
GIFReadWriter grabScreenAndSaveOnDisk.
FrameRateMorph new openInHand.
-
Utilities reconstructTextWindowsFromFileNamed: ''TW''.
Utilities storeTextWindowContentsToFileNamed: ''TW''.
ChangeSet removeEmptyUnnamedChangeSets.
ChangesOrganizer reorderChangeSets.
-
ActiveWorld installVectorVocabulary.
ActiveWorld abandonVocabularyPreference.'

"Utilities initializeCommonRequestStrings"
]

{ #category : #debugging }
Utilities class >> inspectCollection: aCollection notifying: aView [
	aCollection size = 0 
		ifTrue: [aView notNil 
			ifTrue: [^ aView flash]
			ifFalse: [^ self]].
	aCollection size = 1
		ifTrue: [aCollection first inspect]
		ifFalse: [aCollection asArray inspect]
]

{ #category : #miscellaneous }
Utilities class >> instanceComparisonsBetween: fileName1 and: fileName2 [
	"For differential results, run printSpaceAnalysis twice with different fileNames,
	then run this method...
		SpaceTally new printSpaceAnalysis: 0 on: 'STspace.text1'.
			--- do something that uses space here ---
		SpaceTally new printSpaceAnalysis: 0 on: 'STspace.text2'.
		Utilities instanceComparisonsBetween: 'STspace.text1' and: 'STspace.text2'"

	| instCountDict report f aString items className newInstCount oldInstCount newSpace oldPair oldSpace |
	instCountDict := Dictionary new.
	report := String new writeStream.
	f := FileStream readOnlyFileNamed: fileName1.
	[f atEnd] whileFalse:
		[aString := f nextLine.
		items := aString findTokens: ' '.
		(items size = 4 or: [items size = 5]) ifTrue:
			[instCountDict at: items first put: (Array with: items third asNumber with: items fourth asNumber)]].
	f close.

	f := FileStream readOnlyFileNamed: fileName2.
	[f atEnd] whileFalse:
		[aString := f nextLine.
		items := aString findTokens: ' '.
		(items size = 4 or: [items size = 5]) ifTrue:
			[className := items first.
			newInstCount := items third asNumber.
			newSpace := items fourth asNumber.
			oldPair := instCountDict at: className ifAbsent: [nil].
			oldInstCount := oldPair ifNil: [0] ifNotNil: [oldPair first].
			oldSpace := oldPair ifNil: [0] ifNotNil: [oldPair second].
			oldInstCount ~= newInstCount ifTrue:
				[report nextPutAll: (newInstCount - oldInstCount) printString; tab; nextPutAll: (newSpace - oldSpace) printString; tab; nextPutAll: className asString; cr]]].
	f close.

	(StringHolder new contents: report contents)
		openLabel: 'Instance count differentials between ', fileName1, ' and ', fileName2
]

{ #category : #miscellaneous }
Utilities class >> keyLike: aString satisfying: aBlock [
	"Return a key like aString that satisfies aBlock.  The block should provide a test for acceptability -- typically the test is about whether the key is already in use.  aBlock should return a boolean.  8/11/96 sw"

	| stemAndSuffix suffix stem newKey |
	(aBlock value: aString) ifTrue: [^ aString].
	stemAndSuffix := aString stemAndNumericSuffix.
	suffix := stemAndSuffix last + 1.
	stem := stemAndSuffix first.
	[aBlock value: (newKey := stem, suffix printString)]
		whileFalse:
			[suffix := suffix + 1].
	^ newKey

]

{ #category : #miscellaneous }
Utilities class >> keyLike: aString withTrailing: trailerString satisfying: aBlock [
	"Return a key like (aString, trailerString) that satisfies aBlock.  The block should provide a test for acceptability -- typically the test is about whether the key is already in use.  aBlock should return a boolean.  8/11/96 sw"

	| stemAndSuffix suffix stem composite |
	composite := aString, trailerString.
	(aBlock value: composite) ifTrue: [^ composite].
	stemAndSuffix := aString stemAndNumericSuffix.
	suffix := stemAndSuffix last + 1.
	stem := stemAndSuffix first.
	[aBlock value: (composite := stem, suffix printString, trailerString)]
		whileFalse:
			[suffix := suffix + 1].
	^ composite

]

{ #category : #identification }
Utilities class >> methodsWithInitials: targetInitials [
	"Based on a do-it contributed to the Squeak mailing list by Göran Hultgen:
 Browse methods whose initials (in the time-stamp, as logged to disk) match the given initials.
 Print out the complete time-stamp table to the Transcript.
 Answer a list of (initials -> count) associations.

CAUTION: It may take several minutes for this to complete."

	"Time millisecondsToRun: [Utilities methodsWithInitials: 'bf']"

	| initials timeStamp  allSubmitters |
	initials := ''.
	timeStamp := ''.
	allSubmitters := Bag new.
	self systemNavigation
		browseAllSelect:
			[:cm |
				timeStamp := cm timeStamp.
				initials := timeStamp isEmpty
					ifTrue:
						['']
					ifFalse:
						[timeStamp substrings first].
				initials := initials isEmpty
					ifTrue:
						['<no time stamp>']
					ifFalse:
						[initials first isDigit
							ifTrue:
								['<date>']
							ifFalse:
								[initials]].
				allSubmitters add: initials.
				(initials = targetInitials)]
		name: ('Methods with initials ', targetInitials)
		autoSelect: nil.

	allSubmitters sortedCounts do: [:elem | Transcript cr; show: elem asString].
	^ allSubmitters

]

{ #category : #identification }
Utilities class >> monthDayTime24StringFrom: aSecondCount [
	| aDate aTime |
	"From the date/time represented by aSecondCount, produce a string which indicates the date and time in the compact form
             ddMMMhhmm		where dd is a two-digit day-of-month, MMM is the alpha month abbreviation and hhmm is the time on a 24-hr clock.

          Utilities monthDayTime24StringFrom: Time primSecondsClock
"

	aDate := Date fromSeconds: aSecondCount.
	aTime := Time fromSeconds: aSecondCount \\ 86400.

	^ (aDate dayOfMonth asTwoCharacterString), 
		(aDate monthName copyFrom: 1 to: 3), 
		(aTime hhmm24)
]

{ #category : #identification }
Utilities class >> monthDayTimeStringFrom: aSecondCount [
	| aDate aTime |
	"From the date/time represented by aSecondCount, produce a string which indicates the date and time in the form:
		ddMMMhhmmPP	  where:
							dd is a two-digit day-of-month,
							MMM is the alpha month abbreviation,
							hhmm is the time,
							PP is either am or pm

          Utilities monthDayTimeStringFrom: Time primSecondsClock
"

	aDate := Date fromSeconds: aSecondCount.
	aTime := Time fromSeconds: aSecondCount \\ 86400.

	^ (aDate dayOfMonth asTwoCharacterString), 
		(aDate monthName copyFrom: 1 to: 3), 
		((aTime hours \\ 12) asTwoCharacterString), 
		(aTime minutes asTwoCharacterString),
		(aTime hours > 12 ifTrue: ['pm'] ifFalse: ['am'])
]

{ #category : #miscellaneous }
Utilities class >> nextClockwiseSideAfter: aSide [
 	aSide == #left ifTrue:
		[^ #top].
	aSide == #right ifTrue:
		[^ #bottom].
	aSide == #top ifTrue:
		[^ #right].
	^ #left
]

{ #category : #'recent method submissions' }
Utilities class >> numberOfRecentSubmissionsToStore [
	self deprecated: 'Use RecentMessages >> #numberOfRecentSubmissionsToStore'.
	^ RecentMessages numberOfRecentSubmissionsToStore.
]

{ #category : #'recent method submissions' }
Utilities class >> numberOfRecentSubmissionsToStore: aNumber [
	self deprecated: 'Use RecentMessages >> #numberOfRecentSubmissionsToStore'.
	RecentMessages numberOfRecentSubmissionsToStore: aNumber.
]

{ #category : #'common requests' }
Utilities class >> offerCommonRequests [
	"Offer up the common-requests menu.  If the user chooses one, then evaluate it, and -- provided the value is a number or string -- show it in the Transcript."

	"Utilities offerCommonRequests"

	| reply result index normalItemCount strings lines |

	Smalltalk isMorphic ifTrue: [^ self offerCommonRequestsInMorphic].

	(CommonRequestStrings == nil or: [CommonRequestStrings isKindOf: Array])
		ifTrue:
			[self initializeCommonRequestStrings].
	
	strings := CommonRequestStrings contents.
	lines := strings asString lines copyWith: 'edit this menu'.
	normalItemCount := lines size - 1.
	
	index := UIManager default 
		chooseFrom: lines
		lines: (Array with: normalItemCount).

	index = 0 ifTrue: [^ self].
	index > normalItemCount ifTrue:
		[^ self editCommonRequestStrings].

	reply := lines at: index.
	reply size = 0 ifTrue: [^ self].

	result := Compiler evaluate: reply.
	(result isNumber) | (result isString)
		ifTrue:
			[Transcript cr; nextPutAll: result printString]
]

{ #category : #'common requests' }
Utilities class >> offerCommonRequestsInMorphic [
	"Offer up the common-requests menu.  If the user chooses one, then evaluate it, and -- provided the value is a number or string -- show it in the Transcript."

	"Utilities offerCommonRequests"

	| aMenu  strings |

	(CommonRequestStrings == nil or: [CommonRequestStrings isKindOf: Array])
		ifTrue:
			[self initializeCommonRequestStrings].
	strings := CommonRequestStrings contents.
	aMenu := MenuMorph new.
	aMenu title: 'Common Requests' translated.
	aMenu addStayUpItem.
	strings asString linesDo:
		[:aString |
			aString = '-'
				ifTrue:
					[aMenu addLine]
				ifFalse:
					[aMenu add: (aString ifEmpty: [' ']) target: self selector: #eval: argument: aString]].

	aMenu addLine.
	aMenu add: 'edit this list' translated target: self action: #editCommonRequestStrings.
	aMenu popUpInWorld: self currentWorld
]

{ #category : #'support windows' }
Utilities class >> openStandardWorkspace [ 
	"Open up a throwaway workspace with useful expressions in it.  1/22/96 sw"
	"Utilities openStandardWorkspace"

	(StringHolder new contents: self standardWorkspaceContents)
		openLabel: 'Useful Expressions ', Date today printString
]

{ #category : #'user interface' }
Utilities class >> openUpdateButton [
	PluggableButtonMorph new
		label: 'Load Code Updates';
		model: MCMcmUpdater;
		action: #updateFromServer;
		openInHand
]

{ #category : #miscellaneous }
Utilities class >> oppositeCornerFrom: aCorner [
	"Answer the corner diagonally opposite to aCorner.  6/27/96 sw"

	aCorner == #topLeft
		ifTrue:
			[^ #bottomRight].
	aCorner == #topRight
		ifTrue:
			[^ #bottomLeft].
	aCorner == #bottomLeft
		ifTrue:
			[^ #topRight].
	^ #topLeft
]

{ #category : #miscellaneous }
Utilities class >> oppositeModeTo: aMode [
 	aMode == #readOnly ifTrue: [^ #writeOnly].
	aMode == #writeOnly ifTrue: [^ #readOnly].
	^ aMode
]

{ #category : #miscellaneous }
Utilities class >> oppositeSideTo: aSide [
 	aSide == #left ifTrue:
		[^ #right].
	aSide == #right ifTrue:
		[^ #left].
	aSide == #top ifTrue:
		[^ #bottom].
	^ #top
]

{ #category : #'finding pointers' }
Utilities class >> pointersTo: anObject [
	"Find all occurrences in the system of pointers to the argument anObject."
	"(Utilities pointersTo: Browser) inspect."
	^ self pointersTo: anObject except: #()

]

{ #category : #'finding pointers' }
Utilities class >> pointersTo: anObject except: objectsToExclude [ 
	"Find all occurrences in the system of pointers to the argument
	anObject. Remove objects in the exclusion list from the
	results. "
	^ anObject inboundPointersExcluding: objectsToExclude
]

{ #category : #'finding pointers' }
Utilities class >> pointersToItem: index of: anArray [
	"Find all occurrences in the system of pointers to the given element of the given array. This is useful for tracing up a pointer chain from an inspector on the results of a previous call of pointersTo:. To find out who points to the second element of the results, one would evaluate:

	Utilities pointersToItem: 2 of: self

in the inspector."
	^ self pointersTo: (anArray at: index) except: (Array with: anArray)
]

{ #category : #'recent method submissions' }
Utilities class >> recentMethodSubmissions [
	"Answer the list of recent method submissions, in order.  5/16/96 sw"
	self deprecated: 'Use RecentMessages default methodReferences'.
	^ RecentMessages default methodReferences.
]

{ #category : #'class initialization' }
Utilities class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#Utilities. #recentSubmissionsWindow. 	'Recent' translatedNoop.		'A message browser that tracks the most recently-submitted methods' translatedNoop}
						forFlapNamed: 'Tools'.]
]

{ #category : #investigations }
Utilities class >> reportSenderCountsFor: selectorList [ 
	"Produce a report on the number of senders of each of the selectors in 
	the list. 1/27/96 sw"
	| total report |
	total := 0.
	report := '
'.
	selectorList
		do: [:selector | | thisSize | 
			thisSize := (self systemNavigation allCallsOn: selector) size.
			report := report , thisSize printString , String tab , selector printString , String cr.
			total := total + thisSize].
	report := report , '--- ------------------
'.
	report := report , total printString , String tab , 'TOTAL
'.
	^ report
]

{ #category : #'recent method submissions' }
Utilities class >> revertLastMethodSubmission [
	self deprecated: 'Use RecentMessages default revertMostRecent'.
	RecentMessages default revertMostRecent.
]

{ #category : #identification }
Utilities class >> setAuthorInitials [
	"Put up a dialog allowing the user to specify the author's initials.  "

	self authorInitials:
		(UIManager default request: 'Please type your initials: ' translated
					initialAnswer: AuthorInitials)
]

{ #category : #identification }
Utilities class >> setAuthorName [
	AuthorName := UIManager default 
			request: 'Please type your name:' translated
			initialAnswer: 'Your Name' translated
]

{ #category : #miscellaneous }
Utilities class >> setClassAndSelectorFrom: messageIDString in: csBlock [
	"Decode strings of the form <className> [class] <selectorName>.   If <className> does not exist as a class, use nil for the class in the block"

	| aStream aClass maybeClass sel |

	(messageIDString isKindOf: MethodReference) ifTrue: [
		^messageIDString setClassAndSelectorIn: csBlock
	].

	aStream := ReadStream on: messageIDString.
	aClass := Smalltalk at: (aStream upTo: $ ) asSymbol ifAbsent: [nil].
	maybeClass := aStream upTo: $ .
	sel := aStream upTo: $ .
	((maybeClass = 'class') & (sel size ~= 0))
		ifTrue:
			[aClass
				ifNil:
					[csBlock value: nil value: sel asSymbol]
				ifNotNil:
					[csBlock value: aClass class value: sel asSymbol]]
		ifFalse:
			[csBlock value: aClass value: maybeClass asSymbol]


"
Utilities setClassAndSelectorFrom: 'Utilities class oppositeModeTo:' in: [:aClass :aSelector | Transcript cr; show: 'Class = ', aClass name printString, ' selector = ', aSelector printString].

Utilities setClassAndSelectorFrom: 'MessageSet setClassAndSelectorIn:' in: [:aClass :aSelector | Transcript cr; show: 'Class = ', aClass name printString, ' selector = ', aSelector printString].
"

]

{ #category : #'fetching updates' }
Utilities class >> setSystemVersion: aConfig [
	self deprecated: 'Use MCConfiguration >> #setSystemVersion'.
	aConfig setSystemVersion.
]

{ #category : #'fetching updates' }
Utilities class >> setSystemVersionFromConfig: aConfig [
	self deprecated: 'Use MCConfiguration >> #setSystemVersion'.
	aConfig setSystemVersion.
]

{ #category : #'graphical support' }
Utilities class >> showFormsAcrossTopOfScreen: aFormList [
	"Display the given array of forms across the top of the screen, wrapping to subsequent lines if needed.    Useful for example for looking at sets of rotations and animations.  6/10/96 sw"

	| position maxHeight screenBox ceiling |

	position := 20.
	maxHeight := 0.
	ceiling := 0.
	screenBox := Display boundingBox.
	aFormList do:
		[:elem | elem displayAt: (position @ ceiling).
			maxHeight := maxHeight max: elem boundingBox height.
			position := position + elem boundingBox width + 5.
			position > (screenBox right - 100) ifTrue:
				[position := 20.
				ceiling := ceiling + maxHeight + 10.
				maxHeight := 0]]
]

{ #category : #'graphical support' }
Utilities class >> showFormsDictAcrossTopOfScreen: formDict [
	"Display the given Dictionary of forms across the top of the screen, wrapping to subsequent lines if needed.  Beneath each, put the name of the associated key."

	"Utilities showFormsDictAcrossTopOfScreen: HaloIcons"

	| screenBox position maxHeight ceiling |

	position := 20.
	maxHeight := 0.
	ceiling := 0.
	screenBox := Display boundingBox.
	formDict associationsDo:
		[:assoc | | box elem labelWidth keyString h |
			(elem := assoc value) displayAt: (position @ ceiling).
			box := elem boundingBox.
			h := box height.
			keyString := (assoc key isString) ifTrue: [assoc key] ifFalse: [assoc key printString].
			keyString displayAt: (position @ (ceiling + h)).
			labelWidth := TextStyle default defaultFont widthOfString: keyString.
			maxHeight := maxHeight max: h.
			position := position + (box width max: labelWidth) + 5.
			position > (screenBox right - 100) ifTrue:
				[position := 20.
				ceiling := ceiling + maxHeight + 15.
				maxHeight := 0]]
]

{ #category : #'support windows' }
Utilities class >> standardWorkspaceContents [
	^ self class firstCommentAt: #standardWorkspaceContents

	"ChangeList browseRecentLog.
ChangeList browseRecent: 2000.

Preferences editAnnotations.
Flaps reinstateDefaultFlaps. 

(FileStream oldFileNamed: 'Lives of the Wolves') edit.
(FileStream oldFileNamed: 'tuesdayFixes.cs') fileIn.
ChangeList browseFile: 'myChanges.st'.

TextStyle default fontAt: 7 put: (StrikeFont new readMacFontHex: 'Cairo 18').

StandardSystemView doCacheBits.  ""restore fast windows mode in mvc""

Symbol selectorsContaining: 'rsCon'.
SystemNavigation default browseMethodsWhoseNamesContain: 'screen'.

Browser newOnClass: Utilities.
Browser fullOnClass: SystemDictionary.

FormView allInstances inspect.
StandardSystemView someInstance inspect.

Utilities storeTextWindowContentsToFileNamed: 'TextWindows'.

ScriptingSystem resetStandardPartsBin.

SystemOrganization categoryOfElement: #Controller. 
ParagraphEditor organization categoryOfElement: #changeEmphasis.

Cursor wait showWhile: [Sensor waitButton].

Smalltalk bytesLeft asStringWithCommas.
ByteSymbol instanceCount.
Time millisecondsToRun:
	[SystemNavigation default allCallsOn: #asOop].
MessageTally spyOn: [SystemNavigation default allCallsOn: #asOop].

"

"Utilities openStandardWorkspace"
]

{ #category : #miscellaneous }
Utilities class >> steplistToolsWorkspace [
	^ ((StringHolder new contents:  'self currentWorld listOfSteppingMorphs asArray inspectWithLabel: ''stepping morphs''.
Utilities cleanseOtherworldlySteppers.
self currentWorld steppingMorphsNotInWorld do: [:m | m delete].
self currentWorld stepListSummary.
self currentWorld stepListSize.
self currentHand attachMorph: FrameRateMorph new') openLabel: 'Steplist workspace')

setWindowColor: (Color r: 0.9 g: 0.7 b: 0.5);
			openInWorld: self currentWorld extent: (550 @ 140)

"Utilities steplistToolsWorkspace"
]

{ #category : #miscellaneous }
Utilities class >> storeTextWindowContentsToFileNamed: aName [
	"Utilities storeTextWindowContentsToFileNamed: 'TextWindows'"
	| aDict aRefStream |

	aDict := Project current textWindows..
	aDict size = 0 ifTrue: [^ self inform: 'no windows found to export.'].
	aRefStream := ReferenceStream fileNamed: aName.
	aRefStream nextPut: aDict.
	aRefStream close.
	self inform: 'Done!  ', aDict size printString, ' window(s) exported.'
]

{ #category : #'geometry testing' }
Utilities class >> triangle: points containsPoint: p [
	" Computes if p is in the triangle defined by points.
	p should be a Point, and points should be an array with three Points.
	I took the algorithm from the bottom of this page: 
		http://www.blackpawn.com/texts/pointinpoly/default.html "

	| a b c v0 v1 v2 dot00 dot01 dot02 dot11 dot12 denom invDenom u v |
	a := points first.
	b := points second.
	c := points third.
	" Compute vectors "
	v0 := c - a.
	v1 := b - a.
	v2 := p - a.
	" Compute dot products "
	dot00 := v0 dotProduct: v0.
	dot01 := v0 dotProduct: v1.
	dot02 := v0 dotProduct: v2.
	dot11 := v1 dotProduct: v1.
	dot12 := v1 dotProduct: v2.
	" Compute barycentric coordinates "
	denom := dot00 * dot11 - (dot01 * dot01).
	denom = 0 ifTrue: [ ^false ].
	invDenom := 1 / denom.
	u := (dot11 * dot02 - (dot01 * dot12)) * invDenom.
	v := (dot00 * dot12 - (dot01 * dot02)) * invDenom.
	" Check if point is in triangle "
	^u >= 0 and: [ v >= 0 and: [ u + v <= 1 ] ]
]

{ #category : #'class initialization' }
Utilities class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #'fetching updates' }
Utilities class >> updateFromServer [
	"Update the image by loading all pending updates from the server."
	self deprecated: 'Use MCMcmUpdater updateFromServer'.
	MCMcmUpdater updateFromServer.
]

{ #category : #identification }
Utilities class >> useAuthorInitials: temporaryAuthorInitials during: aBlock [

	| originalAuthorInitials |
	originalAuthorInitials := AuthorInitials.
	^[ AuthorInitials := temporaryAuthorInitials.
	    aBlock value ]
		ensure: [ AuthorInitials := originalAuthorInitials ]
	
]

{ #category : #identification }
Utilities class >> useAuthorName: temporaryAuthorName during: aBlock [

	| originalAuthorName |
	originalAuthorName := AuthorName.
	^[ AuthorName := temporaryAuthorName.
	    aBlock value ]
		ensure: [ AuthorName := originalAuthorName ]
	
]
