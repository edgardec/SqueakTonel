"
My instances specify the starting and stopping points in a String of a composed line. The step is always 1.
"
Class {
	#name : #TextLineInterval,
	#superclass : #Interval,
	#instVars : [
		'internalSpaces',
		'paddingWidth',
		'lineHeight',
		'baseline'
	],
	#pools : [
		'TextConstants'
	],
	#category : #'ST80-Support'
}

{ #category : #'instance creation' }
TextLineInterval class >> start: startInteger stop: stopInteger internalSpaces: spacesInteger paddingWidth: padWidthInteger [
	"Answer an instance of me with the arguments as the start, stop points, 
	number of spaces in the line, and width of the padding."
	| newSelf |
	newSelf := super from: startInteger to: stopInteger by: 1.
	^newSelf internalSpaces: spacesInteger paddingWidth: padWidthInteger
]

{ #category : #comparing }
TextLineInterval >> = line [

	self species = line species
		ifTrue: [^((start = line first and: [stop = line last])
				and: [internalSpaces = line internalSpaces])
				and: [paddingWidth = line paddingWidth]]
		ifFalse: [^false]
]

{ #category : #accessing }
TextLineInterval >> baseline [
	^ baseline
]

{ #category : #accessing }
TextLineInterval >> internalSpaces [
	"Answer the number of spaces in the line."

	^internalSpaces
]

{ #category : #accessing }
TextLineInterval >> internalSpaces: spacesInteger [ 
	"Set the number of spaces in the line to be spacesInteger."

	internalSpaces := spacesInteger
]

{ #category : #private }
TextLineInterval >> internalSpaces: spacesInteger paddingWidth: padWidthInteger [

	internalSpaces := spacesInteger.
	paddingWidth := padWidthInteger
]

{ #category : #scanning }
TextLineInterval >> justifiedPadFor: spaceIndex font: aFont [
	"Compute the width of pad for a given space in a line of justified text."

	| pad |
	internalSpaces = 0 ifTrue: [^0].
	^(aFont notNil and:[aFont isSubPixelPositioned])
		ifTrue:[paddingWidth * 1.0 / internalSpaces]
		ifFalse:[
			pad := paddingWidth // internalSpaces.
			spaceIndex <= (paddingWidth \\ internalSpaces)
				ifTrue: [pad + 1]
				ifFalse: [pad]]
]

{ #category : #scanning }
TextLineInterval >> justifiedTabDeltaFor: spaceIndex [ 
	"Compute the delta for a tab in a line of justified text, so tab falls 
	somewhere plausible when line is justified."

	| pad extraPad |
	internalSpaces = 0 ifTrue: [^0].
	pad := paddingWidth // internalSpaces.
	extraPad := paddingWidth \\ internalSpaces.
	spaceIndex <= extraPad
		ifTrue: [^spaceIndex * (pad + 1)]
		ifFalse: [^extraPad * (pad + 1) + (spaceIndex - extraPad * pad)]
]

{ #category : #accessing }
TextLineInterval >> lineHeight [
	^ lineHeight
]

{ #category : #private }
TextLineInterval >> lineHeight: height baseline: ascent [

	lineHeight := height.
	baseline := ascent
]

{ #category : #accessing }
TextLineInterval >> paddingWidth [
	"Answer the amount of space to be added to the font."

	^paddingWidth
]

{ #category : #accessing }
TextLineInterval >> paddingWidth: padWidthInteger [ 
	"Set the amount of space to be added to the font to be padWidthInteger."

	paddingWidth := padWidthInteger
]

{ #category : #updating }
TextLineInterval >> slide: delta [ 
	"Change the starting and stopping points of the line by delta."

	start := start + delta.
	stop := stop + delta
]

{ #category : #accessing }
TextLineInterval >> stop: stopInteger [ 
	"Set the stopping point in the string of the line to be stopInteger."

	stop := stopInteger
]
