"
I implement the diff algorithm. I can show the differences between two texts. See my method comments for further information.

Instance Variables
	xLines:				<Array>
	yLines:				<Array>
	ignoreLineEndings:	<Boolean>

xLines
	- an Array of DiffElements which is created from the first input text

yLines
	- an Array of DiffElements which is created from the second input text
	
ignoreLineEndings
	- a Boolean describing whether lines only differing in the line endings should be reported as a difference, or not
"
Class {
	#name : #TextDiffBuilder,
	#superclass : #Object,
	#instVars : [
		'xLines',
		'yLines',
		'ignoreLineEndings'
	],
	#classVars : [
		'IgnoreLineEndings',
		'InsertTextAttributes',
		'NormalTextAttributes',
		'RemoveTextAttributes'
	],
	#category : #'System-FilePackage'
}

{ #category : #preferences }
TextDiffBuilder class >> applyUserInterfaceTheme [

	NormalTextAttributes := nil.
	InsertTextAttributes := nil.
	RemoveTextAttributes := nil.
]

{ #category : #'instance creation' }
TextDiffBuilder class >> buildDisplayPatchFrom: sourceText to: destinationText [

	^(self from: sourceText to: destinationText) buildDisplayPatch
]

{ #category : #'instance creation' }
TextDiffBuilder class >> buildDisplayPatchFrom: sourceText to: destinationText inClass: sourceClass prettyDiffs: prettyDiffs [
	
	^((sourceClass notNil and: [ prettyDiffs ])
		ifFalse: [ self from: sourceText to: destinationText ]
		ifTrue: [
			PrettyTextDiffBuilder
				from: sourceText
				to: destinationText
				inClass: sourceClass ]) buildDisplayPatch
]

{ #category : #'instance creation' }
TextDiffBuilder class >> from: sourceText to: destinationText [

	^self from: sourceText to: destinationText ignoreLineEndings: self ignoreLineEndings
]

{ #category : #'instance creation' }
TextDiffBuilder class >> from: sourceText to: destinationText ignoreLineEndings: ignoreLineEndings [

	^self new
		from: sourceText to: destinationText ignoreLineEndings: ignoreLineEndings;
		yourself
]

{ #category : #preferences }
TextDiffBuilder class >> ignoreLineEndings [
	"Answer a boolean telling if line endings differences should be ignored or emphasized"
	
	<preference: 'ignoreLineEndings'
		category: 'TextDiff'
		description: 'When enabled, source code differences in line endings will be ignored.'
		type: #Boolean>
	^IgnoreLineEndings ifNil: [ false ]
]

{ #category : #preferences }
TextDiffBuilder class >> ignoreLineEndings: aBoolean [
	"Set the preference telling if line endings differences should be ignored or emphasized"
	
	IgnoreLineEndings := aBoolean
]

{ #category : #preferences }
TextDiffBuilder class >> themeProperties [

	^ {
		{ #insertTextAttributes. 'Styling'. 'Text attributes to use when a patch was inserted.' }.
		{ #normalTextAttributes. 'Styling'. 'Text attributes to use when text did not change.' }.
		{ #removeTextAttributes. 'Styling'. 'Text attributes to use when a patch was removed.' }.
	}
]

{ #category : #updating }
TextDiffBuilder >> applyUserInterfaceTheme [
	"My class-side cache is invalidated there. My dependents have to invoke my services again."
]

{ #category : #'creating patches' }
TextDiffBuilder >> buildDisplayPatch [

	| stream result |
	stream := AttributedTextStream new.
	
	"Lazy initialize the text attributes cache."
	NormalTextAttributes ifNil: [NormalTextAttributes := self userInterfaceTheme normalTextAttributes
		ifNil: [{TextEmphasis normal}]].
	InsertTextAttributes ifNil: [InsertTextAttributes := self userInterfaceTheme insertTextAttributes
		ifNil: [{TextColor red}]].
	RemoveTextAttributes ifNil: [RemoveTextAttributes := self userInterfaceTheme removeTextAttributes
		ifNil: [{TextEmphasis struckOut. TextColor blue}]].
	
	self 
		patchSequenceDoIfMatch: [ :string |
			self print: string withAttributes: NormalTextAttributes on: stream ]
		ifInsert: [ :string |
			self print: string withAttributes: InsertTextAttributes on: stream ]
		ifRemove: [ :string |
			self print: string withAttributes: RemoveTextAttributes on: stream ].
	result := stream contents.
	(result notEmpty
	and: [result last = Character cr
	and: [(self lastIsCR: xLines) not
	and: [(self lastIsCR: yLines) not]]]) ifTrue:
		[result := result allButLast].
	^result
]

{ #category : #'creating patches' }
TextDiffBuilder >> buildPatchSequence [
	"This method is only implemented for backwards compatibility and testing."

	^Array streamContents: [ :stream |
		self 
			patchSequenceDoIfMatch: [ :string |
				stream nextPut: #match -> (string copyWithout: Character cr) ]
			ifInsert: [ :string | 
				stream nextPut: #insert -> (string copyWithout: Character cr) ]
			ifRemove: [ :string | 
				stream nextPut: #remove -> (string copyWithout: Character cr) ] ]
]

{ #category : #updating }
TextDiffBuilder >> canApplyUserInterfaceTheme [

	^ false
]

{ #category : #private }
TextDiffBuilder >> findMatches [
	"I find the matching pairs of xLines and yLines. First I filter out all lines that can't have a pair, then I find the longest common subsequence of the remaining elements. Finally I mark the matching pairs."

	| temp lcs xFilteredLines yFilteredLines xNumbers yNumbers |
	"Filter out all lines that can't have a pair."
	temp := yLines asSet.
	xFilteredLines := xLines select: [ :each |
		temp includes: each ].
	xFilteredLines size = 0 ifTrue: [ ^self ].
	temp := xLines asSet.
	yFilteredLines := yLines select: [ :each |
		temp includes: each ].
	yFilteredLines size = 0 ifTrue: [ ^self ].
	"Map all lines to SmallIntegers, because they can be compared faster."
	temp := Dictionary new.
	xNumbers := xFilteredLines collect: [ :each |
		temp at: each ifAbsentPut: [ temp size ] ].
	yNumbers := yFilteredLines collect: [ :each |
		temp at: each ifAbsentPut: [ temp size ] ].
	temp := nil.
	"Find the longest common subsequence."
	lcs := self lcsFor: xNumbers and: yNumbers.
	"Mark the matching pairs."
	[ lcs == nil ] whileFalse: [
		(xFilteredLines at: (lcs at: 1)) matches: (yFilteredLines at: (lcs at: 2)).
		lcs := lcs at: 3 ]
]

{ #category : #initialize }
TextDiffBuilder >> from: xString to: yString [

	self from: xString to: yString ignoreLineEndings: self class ignoreLineEndings
]

{ #category : #initialize }
TextDiffBuilder >> from: xString to: yString ignoreLineEndings: aBoolean [

	ignoreLineEndings := aBoolean.
	xLines := self split: xString asString.
	yLines := self split: yString asString.
	self findMatches
]

{ #category : #'creating patches' }
TextDiffBuilder >> ignoreLineEndings: aBoolean [

	ignoreLineEndings := aBoolean
]

{ #category : #private }
TextDiffBuilder >> lastIsCR: linesArray [
	| last |
	^linesArray notEmpty
	 and: [(last := linesArray last string) notEmpty
	 and: [last last = Character cr or: [last endsWith: String crlf]]]
]

{ #category : #private }
TextDiffBuilder >> lcsFor: xFilteredLines and: yFilteredLines [
	"I find one of the longest common subsequences of my arguments. I assume that none of my arguments are empty. I return nil, or an Array which represents a list. The first two elements are the matching ''line'' numbers, the third (and last) is the next node in the list, or nil, if there are no more elements. The list contains the longest common subsequence. I'm a modified version of the Greedy LCS/SES Algorithm from the 6th page of 'An O(ND) Difference Algorithm and Its Variations (1986)' by Eugene W. Myers."

	| n m v lcss max index lcs x y |
	n := xFilteredLines size.
	m := yFilteredLines size.
	max := m + n.
	v := Array new: 2 * max + 1.
	lcss := Array new: 2 * max + 1.
	"Unrolled first iteration (d = 0, k = 0)"
	index := max + 2.
	y := x := v at: index put: 0.	
	lcs := lcss at: index.
	[ x < n and: [ y < m and: [ (xFilteredLines at: x + 1) = (yFilteredLines at: y + 1) ] ] ]
		whileTrue: [ lcs := { x := x + 1. y := y + 1. lcs } ].
	x >= n ifTrue: [ y >= m ifTrue: [ ^lcs ] ].
	v at: max + 1 put: x.
	lcss at: max + 1 put: lcs.
	1 to: max do: [ :d |
		"Unrolled lowest diagonal checks (k = -d)."
		index := max - d + 2.
		x := v at: index.
		y := x + d.
		lcs := lcss at: index.
		[ x < n and: [ y < m and: [ (xFilteredLines at: x + 1) = (yFilteredLines at: y + 1) ] ] ]
			whileTrue: [ lcs := { x := x + 1. y := y + 1. lcs } ].
		x >= n ifTrue: [ y >= m ifTrue: [ ^lcs ] ].
		v at: max - d + 1 put: x.
		lcss at: max - d + 1 put: lcs.
		"Inner diagonals. (k in [2-d..d-2])"
		2 - d to: d - 2 by: 2 do: [ :k |
			index := max + k.
			(v at: index) < (v at: index + 2)
				ifTrue: [ x := v at: (index := index + 2) ]
				ifFalse: [ x := (v at: index) + 1 ].
			y := x - k.
			lcs := lcss at: index.
			[ x < n and: [ y < m and: [ (xFilteredLines at: x + 1) = (yFilteredLines at: y + 1) ] ] ]
				whileTrue: [ lcs := { x := x + 1. y := y + 1. lcs } ].
			x >= n ifTrue: [ y >= m ifTrue: [ ^lcs ] ].
			v at: max + k + 1 put: x.
			lcss at: max + k + 1 put: lcs ].
		"Unrolled highest diagonal checks (k = d)."
		index := max + d.
		x := (v at: index) + 1.
		y := x - d.
		lcs := lcss at: index.
		[ x < n and: [ y < m and: [ (xFilteredLines at: x + 1) = (yFilteredLines at: y + 1) ] ] ]
			whileTrue: [ lcs := { x := x + 1. y := y + 1. lcs } ].
		x >= n ifTrue: [ y >= m ifTrue: [ ^lcs ] ].
		v at: max + d + 1 put: x.
		lcss at: max + d + 1 put: lcs ].
	self error "We should never reach this point."
]

{ #category : #'creating patches' }
TextDiffBuilder >> patchSequenceDoIfMatch: matchBlock ifInsert: insertBlock ifRemove: removeBlock [
	"I'm the general purpose method to iterate through the patch sequence. See my senders to learn how to use me."

	| xLine xLineStream |
	xLineStream := xLines readStream.
	yLines do: [ :yLine | 
		yLine hasMatch 
			ifFalse: [ insertBlock value: yLine string  ]
			ifTrue: [
				[ (xLine := xLineStream next) == nil or: [ xLine == yLine match  ] ]
					whileFalse: [ removeBlock value: xLine string ].
				matchBlock value: yLine string ] ].
	[ (xLine := xLineStream next) == nil ] whileFalse: [
		removeBlock value: xLine string ]
]

{ #category : #private }
TextDiffBuilder >> print: aString withAttributes: attributes on: stream [

	stream
		currentAttributes: attributes;
		nextPutAll: aString.
	(aString notEmpty and: [ 
		aString last = Character cr or: [
			aString endsWith: String crlf ] ]) 
				ifFalse: [ stream cr ]
]

{ #category : #private }
TextDiffBuilder >> split: aString [
	"I return an Array of DiffElements containing the strings which are the lines extracted from aString. All lines contain the line separator characters, or not depending on preference."

	^Array streamContents: [ :stream |
		ignoreLineEndings
			ifTrue: [
				aString lineIndicesDo: [ :start :endWithoutSeparators :end |
					stream nextPut: (DiffElement string: (aString copyFrom: start to: endWithoutSeparators)) ] ]
			ifFalse: [
				aString lineIndicesDo: [ :start :endWithoutSeparators :end |
					stream nextPut: (DiffElement string: (aString copyFrom: start to: end)) ] ] ]
]
