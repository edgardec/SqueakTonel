"
My instances provide space-efficient storage of data which tends to be constant over long runs of the possible indices. Essentially repeated values are stored singly and then associated with a ""run"" length that denotes the number of consecutive occurrences of the value.

My two important variables are
	runs	An array of how many elements are in each run
	values	An array of what the value is over those elements

The variables lastIndex, lastRun and lastOffset cache the last access
so that streaming through RunArrays is not an N-squared process.

Many complexities of access can be bypassed by using the method
	RunArray withStartStopAndValueDo:
"
Class {
	#name : #RunArray,
	#superclass : #ArrayedCollection,
	#instVars : [
		'runs',
		'values',
		'lastIndex',
		'lastRun',
		'lastOffset'
	],
	#category : #'Collections-Arrayed'
}

{ #category : #'instance creation' }
RunArray class >> new [

	^self runs: Array new values: Array new
]

{ #category : #'instance creation' }
RunArray class >> new: aSize [
	^ self new: aSize withAll: nil
]

{ #category : #'instance creation' }
RunArray class >> new: size withAll: value [ 
	"Answer a new instance of me, whose every element is equal to the
	argument, value."

	size = 0 ifTrue: [^self new].
	^self runs: (Array with: size) values: (Array with: value)
]

{ #category : #'instance creation' }
RunArray class >> newFrom: aCollection [ 
	"Answer an instance of me containing the same elements as aCollection."

	| newCollection |
	newCollection := self new.
	aCollection do: [:x | newCollection addLast: x].
	^newCollection

"	RunArray newFrom: {1. 2. 2. 3}
	{1. $a. $a. 3} as: RunArray
	({1. $a. $a. 3} as: RunArray) values
"
]

{ #category : #'instance creation' }
RunArray class >> readFrom: aStream [
	"Answer an instance of me as described on the stream, aStream."

	| size runs values |
	size := aStream nextWord.
	runs := Array new: size.
	values := Array new: size.
	1 to: size do:
		[:x |
		runs at: x put: aStream nextWord.
		values at: x put: aStream nextWord].
	^ self runs: runs values: values
]

{ #category : #'instance creation' }
RunArray class >> runs: newRuns values: newValues [ 
	"Answer an instance of me with runs and values specified by the 
	arguments."

	| instance |
	instance := self basicNew.
	instance setRuns: newRuns setValues: newValues.
	^instance
]

{ #category : #'instance creation' }
RunArray class >> scanFrom: strm [
	"Read the style section of a fileOut or sources file.  nextChunk has already been done.  We need to return a RunArray of TextAttributes of various kinds.  These are written by the implementors of writeScanOn:"
	| runs values attrList char |
	(strm peekFor: $( ) ifFalse: [^ nil].
	runs := OrderedCollection new.
	[strm skipSeparators.
	 strm peekFor: $)] whileFalse: 
		[runs add: (Number readFrom: strm)].
	values := OrderedCollection new.	"Value array"
	attrList := OrderedCollection new.	"Attributes list"
	[(char := strm peek) == nil] whileFalse: [
		(char isSeparator or: [ char = $! ])
			ifTrue: [ "n.b. Skip $! to meet expectations of RunArrayTest>>testScanFromTrailer.
					The example string used in that test does not seem to match the implemention
					of the fileOut serialization, but the test may be right and the implementation
					wrong. In any case, relax the parsing here to meet the test expectations, and to
					be more consistent with the original version of this method that assumed any
					unexpected charater to be a separator. -dtl Jan 2014"
				strm next "space, cr do nothing"]
			ifFalse: [char == $,
					ifTrue: [strm next.
						values add: attrList asArray.
						attrList reset ]
					ifFalse: [attrList add:  (TextAttribute newFrom: strm)]
				]
		].
	values add: attrList asArray.
	^ self runs: runs asArray values: (values copyFrom: 1 to: runs size) asArray
"
RunArray scanFrom: (ReadStream on: '(14 50 312)f1,f1b,f1LInteger +;i')
"
]

{ #category : #copying }
RunArray >> , aRunArray [ 
	"Answer a new RunArray that is a concatenation of the receiver and
	aRunArray."

	| new newRuns |
	(aRunArray isMemberOf: RunArray)
		ifFalse: 
			[new := self copy.
			"attempt to be sociable"
			aRunArray do: [:each | new addLast: each].
			^new].
	runs size = 0 ifTrue: [^aRunArray copy].
	aRunArray runs size = 0 ifTrue: [^self copy].
	(values at: values size) ~= (aRunArray values at: 1)
		ifTrue: [^RunArray
					runs: runs , aRunArray runs
					values: values , aRunArray values].
	newRuns := runs
					copyReplaceFrom: runs size
					to: runs size
					with: aRunArray runs.
	newRuns at: runs size put: (runs at: runs size) + (aRunArray runs at: 1).
	^RunArray
		runs: newRuns
		values: 
			(values
				copyReplaceFrom: values size
				to: values size
				with: aRunArray values)
]

{ #category : #comparing }
RunArray >> = anObject [ 
	self == anObject ifTrue: [^ true].
	^anObject class == self class
		and:
			[(runs hasEqualElements: anObject runs)
			 and: [values hasEqualElements: anObject values]]
]

{ #category : #adding }
RunArray >> add: value withOccurrences: times [
	"Add value as the last element of the receiver, the given number of times"
	times = 0 ifTrue: [ ^self ].
	lastIndex := nil.  "flush access cache"
	(runs size=0 or: [values last ~= value])
	  ifTrue:
		[runs := runs copyWith: times.
		values := values copyWith: value]
	  ifFalse:
		[runs at: runs size put: runs last+times]
]

{ #category : #adding }
RunArray >> addFirst: value [
	"Add value as the first element of the receiver."
	lastIndex := nil.  "flush access cache"
	(runs size=0 or: [values first ~= value])
	  ifTrue:
		[runs := {1}, runs.
		values := {value}, values]
	  ifFalse:
		[runs at: 1 put: runs first+1]
]

{ #category : #adding }
RunArray >> addLast: value [
	"Add value as the last element of the receiver."
	lastIndex := nil.  "flush access cache"
	(runs size=0 or: [values last ~= value])
	  ifTrue:
		[runs := runs copyWith: 1.
		values := values copyWith: value]
	  ifFalse:
		[runs at: runs size put: runs last+1].
	^value
]

{ #category : #accessing }
RunArray >> at: index [

	self at: index setRunOffsetAndValue: [:run :offset :value | 
		offset < 0 ifTrue: [ self errorSubscriptBounds: index ].
		offset >= (runs at: run) ifTrue: [ self errorSubscriptBounds: index ].
		^value]
]

{ #category : #accessing }
RunArray >> at: index put: aValue [ 
	"Set an element of the RunArray"
	| runIndex offsetInRun lastValue runLength runReplacement valueReplacement iStart iStop |
	index isInteger
		ifFalse: [self errorNonIntegerIndex].
	(index >= 1
			and: [index <= self size])
		ifFalse: [self errorSubscriptBounds: index].
	self
		at: index
		setRunOffsetAndValue: [:run :offset :value | 
			runIndex := run.
			offsetInRun := offset.
			lastValue := value].
	aValue = lastValue
		ifTrue: [^ aValue].
	runLength := runs at: runIndex.
	runReplacement := Array
				with: offsetInRun
				with: 1
				with: runLength - offsetInRun - 1.
	valueReplacement := Array
				with: lastValue
				with: aValue
				with: lastValue.
	iStart := offsetInRun = 0
				ifTrue: [2]
				ifFalse: [1].
	iStop := offsetInRun = (runLength - 1)
				ifTrue: [2]
				ifFalse: [3].
	self
		setRuns: (runs copyReplaceFrom: runIndex to: runIndex with: (runReplacement copyFrom: iStart to: iStop))
		setValues: (values copyReplaceFrom: runIndex to: runIndex with: (valueReplacement copyFrom: iStart to: iStop)).
	self coalesce.
	^ aValue
]

{ #category : #private }
RunArray >> at: index setRunOffsetAndValue: aBlock [ 
	"Supply all run information to aBlock."
	"Tolerates index=0 and index=size+1 for copyReplace: "
	| run limit offset |
	limit := runs size.
	(lastIndex == nil or: [index < lastIndex])
		ifTrue:  "cache not loaded, or beyond index - start over"
			[run := 1.
			offset := index-1]
		ifFalse:  "cache loaded and before index - start at cache"
			[run := lastRun.
			offset := lastOffset + (index-lastIndex)].
	[run <= limit and: [offset >= (runs at: run)]]
		whileTrue: 
			[offset := offset - (runs at: run).
			run := run + 1].
	lastIndex := index.  "Load cache for next access"
	lastRun := run.
	lastOffset := offset.
	run > limit
		ifTrue: 
			["adjustment for size+1"
			run := run - 1.
			offset := offset + (runs at: run)].
	^aBlock
		value: run	"an index into runs and values"
		value: offset	"zero-based offset from beginning of this run"
		value: (values at: run)	"value for this run"
]

{ #category : #accessing }
RunArray >> atPin: index [

	self at: index setRunOffsetAndValue: [:run :offset :value | ^value]
]

{ #category : #adding }
RunArray >> coalesce [
	"Try to combine adjacent runs"
	| ind |
	ind := 2.
	[ind > values size] whileFalse: [
		(values at: ind-1) = (values at: ind) 
			ifFalse: [ind := ind + 1]
			ifTrue: ["two are the same, combine them"
				values := values copyReplaceFrom: ind to: ind with: #().
				runs at: ind-1 put: (runs at: ind-1) + (runs at: ind).
				runs := runs copyReplaceFrom: ind to: ind with: #().
				"self error: 'needed to combine runs' "]].
			
]

{ #category : #copying }
RunArray >> copyFrom: start to: stop [
	| newRuns run1 run2 offset1 offset2 | 
	stop < start ifTrue: [^RunArray new].
	self at: start setRunOffsetAndValue: [:r :o :value1 | run1 := r. offset1
:= o.  value1].
	self at: stop setRunOffsetAndValue: [:r :o :value2 | run2 := r. offset2
:= o. value2].
	run1 = run2
		ifTrue: 
			[newRuns := Array with: offset2 - offset1 + 1]
		ifFalse: 
			[newRuns := runs copyFrom: run1 to: run2.
			newRuns at: 1 put: (newRuns at: 1) - offset1.
			newRuns at: newRuns size put: offset2 + 1].
	^RunArray runs: newRuns values: (values copyFrom: run1 to: run2)
]

{ #category : #copying }
RunArray >> copyReplaceFrom: start to: stop with: replacement [

	^(self copyFrom: 1 to: start - 1)
		, replacement 
		, (self copyFrom: stop + 1 to: self size)
]

{ #category : #accessing }
RunArray >> first [
	^values at: 1
]

{ #category : #accessing }
RunArray >> last [
	^values at: values size
]

{ #category : #private }
RunArray >> mapValues: mapBlock [
	"NOTE: only meaningful to an entire set of runs"
	
	values := values collect: mapBlock
]

{ #category : #copying }
RunArray >> postCopy [
	super postCopy.
	runs := runs copy.
	values := values copy
]

{ #category : #printing }
RunArray >> printOn: aStream [
	self printNameOn: aStream.
	aStream
		nextPutAll: ' runs: ';
		print: runs;
		nextPutAll: ' values: ';
		print: values
]

{ #category : #adding }
RunArray >> rangeOf: attr startingAt: startPos [
	"Answer an interval that gives the range of attr at index position  startPos. An empty interval with start value startPos is returned when the attribute attr is not present at position startPos.  self size > 0 is assumed, it is the responsibility of the caller to test for emptiness of self.
Note that an attribute may span several adjancent runs. "

	self at: startPos 
		setRunOffsetAndValue: 
            [:run :offset :value | 
               ^(value includes: attr)
                  ifFalse: [startPos to: startPos - 1]
                  ifTrue:
                    [ | firstRelevantPosition lastRelevantPosition idxOfCandidateRun |
                     lastRelevantPosition := startPos - offset + (runs at: run) - 1.
                     firstRelevantPosition := startPos - offset.
                     idxOfCandidateRun := run + 1.
                     [idxOfCandidateRun <= runs size 
                             and: [(values at: idxOfCandidateRun) includes: attr]]
                        whileTrue:
                          [lastRelevantPosition := lastRelevantPosition + (runs at: idxOfCandidateRun).
                           idxOfCandidateRun := idxOfCandidateRun + 1]. 
                     idxOfCandidateRun := run - 1.
                     [idxOfCandidateRun >= 1 
                             and: [(values at: idxOfCandidateRun) includes: attr]]
                        whileTrue:
                          [firstRelevantPosition := firstRelevantPosition - (runs at: idxOfCandidateRun).
                           idxOfCandidateRun := idxOfCandidateRun - 1]. 
 
                    firstRelevantPosition to: lastRelevantPosition]
		  ]
]

{ #category : #adding }
RunArray >> repeatLast: times  ifEmpty: defaultBlock [
	"add the last value back again, the given number of times.  If we are empty, add (defaultBlock value)"
	times = 0 ifTrue: [^self ].
	lastIndex := nil.  "flush access cache"
	(runs size=0)
	  ifTrue:
		[runs := runs copyWith: times.
		values := values copyWith: defaultBlock value]
	  ifFalse:
		[runs at: runs size put: runs last+times] 
]

{ #category : #adding }
RunArray >> repeatLastIfEmpty: defaultBlock [
	"add the last value back again.  If we are empty, add (defaultBlock value)"
	lastIndex := nil.  "flush access cache"
	(runs size=0)
	  ifTrue:[
		 runs := runs copyWith: 1.
		values := values copyWith: defaultBlock value]
	  ifFalse:
		[runs at: runs size put: runs last+1]
]

{ #category : #converting }
RunArray >> reversed [

  ^self class runs: runs reversed values: values reversed
]

{ #category : #accessing }
RunArray >> runLengthAt: index [ 
	"Answer the length remaining in run beginning at index."

	self at: index 
		setRunOffsetAndValue: [:run :offset :value | ^(runs at: run) - offset]
]

{ #category : #private }
RunArray >> runs [

	^runs
]

{ #category : #enumerating }
RunArray >> runsAndValuesDo: aBlock [
	"Evaluate aBlock with run lengths and values from the receiver"
	^runs with: values do: aBlock.
]

{ #category : #enumerating }
RunArray >> runsFrom: start to: stop do: aBlock [
	"Evaluate aBlock with all existing runs in the range from start to stop"
	start > stop ifTrue:[^self].
	self at: start setRunOffsetAndValue:[:firstRun :offset :firstValue|
		| run value index |
		run := firstRun.
		value := firstValue.
		index := start + (runs at: run) - offset.
		[aBlock value: value.
		index <= stop] whileTrue:[
			run := run + 1.
			value := values at: run.
			index := index + (runs at: run)]].

]

{ #category : #private }
RunArray >> setRuns: newRuns setValues: newValues [
	lastIndex := nil.  "flush access cache"
	runs := newRuns asArray.
	values := newValues asArray.
]

{ #category : #accessing }
RunArray >> size [
	| size |
	size := 0.
	1 to: runs size do: [:i | size := size + (runs at: i)].
	^size
]

{ #category : #printing }
RunArray >> storeOn: aStream [

	aStream nextPut: $(.
	aStream nextPutAll: self class name.
	aStream nextPutAll: ' runs: '.
	runs storeOn: aStream.
	aStream nextPutAll: ' values: '.
	values storeOn: aStream.
	aStream nextPut: $)
]

{ #category : #private }
RunArray >> values [
	"Answer the values in the receiver."

	^values
]

{ #category : #accessing }
RunArray >> withStartStopAndValueDo: aBlock [
	| start |
	start := 1.
	runs with: values do:
		[:len : val | | stop |
		stop := start + len - 1.
		aBlock value: start value: stop value: val.
		start := stop + 1]
		
]

{ #category : #printing }
RunArray >> writeOn: aStream [

	aStream nextWordPut: runs size.
	1 to: runs size do:
		[:x |
		aStream nextWordPut: (runs at: x).
		aStream nextWordPut: (values at: x)]
]

{ #category : #printing }
RunArray >> writeScanOn: strm [
	"Write out the format used for text runs in source files. (14 50 312)f1,f1b,f1LInteger +;i"

	strm nextPut: $(.
	runs do: [:rr | rr printOn: strm.  strm space].
	strm skip: -1; nextPut: $).
	values do: [:vv |
		vv do: [:att | att writeScanOn: strm].
		strm nextPut: $,].
	strm skip: -1.  "trailing comma"
]
