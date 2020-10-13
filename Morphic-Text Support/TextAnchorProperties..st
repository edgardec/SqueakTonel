"
A TextAnchorProperties describes the positioning of a morph in a text document included through a TextAnchor. The properties describe:
- general alignment of the morph (e.g. within the line or relative to the document)
- vertical alignment within a line
- padding applied in addition to the vertical alignment
- whether it consumes horizontal space when layouted inline

"
Class {
	#name : #TextAnchorProperties,
	#superclass : #Object,
	#instVars : [
		'padding',
		'verticalAlignmentLine',
		'verticalAlignmentMorph',
		'consumesHorizontalSpace',
		'relativePosition',
		'anchorLayout',
		'positionInDocument',
		'morphBaselineGetter'
	],
	#category : #'Morphic-Text Support'
}

{ #category : #menu }
TextAnchorProperties >> addTextAnchorMenuItems: topMenu hand: aHand for: aMorph [

	| layoutTypeMenu anchorMenu morphAlignmentMenu lineAlignmentMenu |
	layoutTypeMenu := MenuMorph new defaultTarget: self.
	layoutTypeMenu 
		addUpdating: #hasInlineAnchorString 
		target: self
		selector: #toggleInlineAnchorIn:
		argumentList: {aMorph}.
	layoutTypeMenu 
		addUpdating: #hasDocumentAnchorString 
		target: self
		selector: #toggleDocumentAnchorIn:
		argumentList: {aMorph}.
		
	morphAlignmentMenu := MenuMorph new defaultTarget: self.
	#(morphAlignmentIsBottomString #bottom 
	morphAlignmentIsBaselineString #baseline 
	morphAlignmentIsCenterString #center  
	morphAlignmentIsTopString #top) pairsDo: [:labelGetter :alignment |
		morphAlignmentMenu 
			addUpdating: labelGetter 
			target: self
			selector: #changeMorphAlignmentFor:to:
			argumentList: {aMorph . alignment}].
	
	lineAlignmentMenu := MenuMorph new defaultTarget: self.
	#(lineAlignmentIsBottomString #bottom 
	lineAlignmentIsBaselineString #baseline 
	lineAlignmentIsCenterString #center  
	lineAlignmentIsTopString #top) pairsDo: [:labelGetter :alignment |
		lineAlignmentMenu 
			addUpdating: labelGetter 
			target: self
			selector: #changeLineAlignmentFor:to:
			argumentList: {aMorph . alignment}].
		
	anchorMenu := MenuMorph new defaultTarget: self.
	anchorMenu add: 'layout type' translated subMenu: layoutTypeMenu.
	anchorMenu add: 'morph vertical alignment' translated subMenu: morphAlignmentMenu.
	anchorMenu add: 'line vertical alignment' translated subMenu: lineAlignmentMenu.
		
	topMenu ifNotNil: [topMenu add: 'text anchor' translated subMenu: anchorMenu].
	^ anchorMenu
]

{ #category : #accessing }
TextAnchorProperties >> anchorLayout [
	"See anchorLayout:"

	^ anchorLayout ifNil: [self defaultAnchorLayout]
]

{ #category : #accessing }
TextAnchorProperties >> anchorLayout: aSymbolOrNil [
	"Anchor layout determines how the morph is embedded into the text.
	
	document:	The morph is placed relative to the complete document. 
	The relative position is in relation to the document topLeft.
	inline: The moph is layouted inline. The position of the morph is 
	determined through verticalAlignment and consumesHorizontalSpace."
	
	self assert: (#(document inline nil) includes: aSymbolOrNil).
	^ anchorLayout := aSymbolOrNil
]

{ #category : #private }
TextAnchorProperties >> assertValidAlignment: aSymbol [
	^ #(top center baseline bottom) includes: aSymbol
]

{ #category : #menu }
TextAnchorProperties >> changeLineAlignmentFor: aMorph to: aSymbol [

	self verticalAlignmentLine: aSymbol.
	self updateOwnerOf: aMorph.
]

{ #category : #menu }
TextAnchorProperties >> changeMorphAlignmentFor: aMorph to: aSymbol [

	self verticalAlignmentMorph: aSymbol.
	self updateOwnerOf: aMorph.
]

{ #category : #accessing }
TextAnchorProperties >> consumesHorizontalSpace [

	^ consumesHorizontalSpace ifNil: [true]
]

{ #category : #accessing }
TextAnchorProperties >> consumesHorizontalSpace: aBoolean [

	^ consumesHorizontalSpace := aBoolean
]

{ #category : #accessing }
TextAnchorProperties >> defaultAnchorLayout [

	^ #inline
]

{ #category : #'default values' }
TextAnchorProperties >> defaultVerticalAlignment [

	^ #(center center)
]

{ #category : #menu }
TextAnchorProperties >> hasDocumentAnchorString [

	^ (self anchorLayout == #document
			ifTrue: ['<on>']
			ifFalse: ['<off>'])
		, 'document' translated
]

{ #category : #menu }
TextAnchorProperties >> hasInlineAnchorString [

	^ (self anchorLayout == #inline
			ifTrue: ['<on>']
			ifFalse: ['<off>'])
		, 'inline' translated
]

{ #category : #testing }
TextAnchorProperties >> hasPositionInDocument [

	^ self positionInDocument notNil
]

{ #category : #'accessing - padding' }
TextAnchorProperties >> horizontalPadding [

	^ self padding left + self padding right
]

{ #category : #menu }
TextAnchorProperties >> lineAlignmentIsBaselineString [

	^ (self verticalAlignmentLine = #baseline 
			ifTrue: ['<on>']
			ifFalse: ['<off>']) 
		, 'baseline' translated
]

{ #category : #menu }
TextAnchorProperties >> lineAlignmentIsBottomString [

	^ (self verticalAlignmentLine = #bottom 
			ifTrue: ['<on>']
			ifFalse: ['<off>']) 
		, 'bottom' translated
]

{ #category : #menu }
TextAnchorProperties >> lineAlignmentIsCenterString [

	^ (self verticalAlignmentLine = #center 
			ifTrue: ['<on>']
			ifFalse: ['<off>']) 
		, 'center' translated
]

{ #category : #menu }
TextAnchorProperties >> lineAlignmentIsTopString [

	^ (self verticalAlignmentLine = #top 
			ifTrue: ['<on>']
			ifFalse: ['<off>']) 
		, 'top' translated
]

{ #category : #menu }
TextAnchorProperties >> morphAlignmentIsBaselineString [

	^ (self verticalAlignmentMorph = #baseline 
			ifTrue: ['<on>']
			ifFalse: ['<off>']) 
		, 'baseline' translated
]

{ #category : #menu }
TextAnchorProperties >> morphAlignmentIsBottomString [

	^ (self verticalAlignmentMorph = #bottom 
			ifTrue: ['<on>']
			ifFalse: ['<off>']) 
		, 'bottom' translated
]

{ #category : #menu }
TextAnchorProperties >> morphAlignmentIsCenterString [

	^ (self verticalAlignmentMorph = #center 
			ifTrue: ['<on>']
			ifFalse: ['<off>']) 
		, 'center' translated
]

{ #category : #menu }
TextAnchorProperties >> morphAlignmentIsTopString [

	^ (self verticalAlignmentMorph = #top 
			ifTrue: ['<on>']
			ifFalse: ['<off>']) 
		, 'top' translated
]

{ #category : #accessing }
TextAnchorProperties >> morphBaselineGetter [

	^ morphBaselineGetter
]

{ #category : #accessing }
TextAnchorProperties >> morphBaselineGetter: aSymbol [
	"This sets the callback send to the anchored morph to determine the baseline
	of the morph. The baseline should be the distance from the top of the anchored
	morph. This can be used, e.g. when having formula morphs inside a text."

	morphBaselineGetter := aSymbol
]

{ #category : #'accessing - padding' }
TextAnchorProperties >> padding [

	^ padding ifNil: [0@0 corner: 0@0]
]

{ #category : #'accessing - padding' }
TextAnchorProperties >> padding: numberOrPointOrRectangle [

	| newPadding |
	newPadding := numberOrPointOrRectangle.
	newPadding isPoint ifTrue: [
		newPadding := newPadding corner: newPadding].
	newPadding isNumber ifTrue: [
		newPadding := newPadding@newPadding corner: newPadding@newPadding].
	^ padding := newPadding
]

{ #category : #accessing }
TextAnchorProperties >> positionInDocument [

	^ positionInDocument
]

{ #category : #accessing }
TextAnchorProperties >> positionInDocument: aPoint [
	"See anchorLayout:"
	 
	^ positionInDocument := aPoint
]

{ #category : #menu }
TextAnchorProperties >> toggleDocumentAnchorIn: aMorph [
	"Change the anchor from/to document anchoring"

	| newType |
	newType := self anchorLayout == #document 
		ifTrue: [#inline]
		ifFalse: [ #document].
	self anchorLayout: newType.
	self updateOwnerOf: aMorph.
	
]

{ #category : #menu }
TextAnchorProperties >> toggleInlineAnchorIn: aMorph [
	"Change the anchor from/to line anchoring"

	| newType |
	newType := self anchorLayout == #inline 
		ifTrue: [#document]
		ifFalse: [#inline]. 
	self anchorLayout: newType.
	self updateOwnerOf: aMorph.
]

{ #category : #private }
TextAnchorProperties >> updateOwnerOf: aMorph [

	aMorph owner isTextMorph ifTrue: [
		aMorph owner 
			anchorMorph: aMorph
			at: aMorph position
			type: self anchorLayout]	
]

{ #category : #accessing }
TextAnchorProperties >> verticalAlignment: symbolOrTuple [
	"This method accepts tuples in which the first element designates 
	which part of the morph is aligned to which part of the text line which 
	the second element designates.

	morph baseline allows for the morph to set its own baseline (see morphBaselineGetter:)"
	symbolOrTuple isSymbol
		ifTrue:
			[ self 
				verticalAlignmentMorph: symbolOrTuple; 
				verticalAlignmentLine: symbolOrTuple ]
		ifFalse: 
			[  self 
				verticalAlignmentMorph: symbolOrTuple first ;
				verticalAlignmentLine: symbolOrTuple second ]
]

{ #category : #accessing }
TextAnchorProperties >> verticalAlignmentLine [
	"The vertical position within the line of text where the anchor point of the morph, specified by #verticalAlignmentMorph, should be attached."

	^ verticalAlignmentLine ifNil: [ #center ]
]

{ #category : #accessing }
TextAnchorProperties >> verticalAlignmentLine: aSymbol [
	"The vertical position within the line of text where the anchor point of the morph, specified by #verticalAlignmentMorph, should be attached."

	self assertValidAlignment: aSymbol.
	verticalAlignmentLine := aSymbol
]

{ #category : #accessing }
TextAnchorProperties >> verticalAlignmentMorph [
	"The vertical position of the embedded Morph where it anchors to a line of text, its position within that line specified by #verticalAlignmentLine.."

	^ verticalAlignmentMorph ifNil: [ #center ]
]

{ #category : #accessing }
TextAnchorProperties >> verticalAlignmentMorph: aSymbol [
	"The vertical position of the embedded Morph where it anchors to a line of text, its position within that line specified by #verticalAlignmentLine.."

	self assertValidAlignment: aSymbol.
	verticalAlignmentMorph := aSymbol
]

{ #category : #'accessing - padding' }
TextAnchorProperties >> verticalPadding [

	self verticalAlignmentMorph = #top 		ifTrue: [^ self padding top].
	self verticalAlignmentMorph = #bottom 	ifTrue: [^ self padding bottom].
	^ 0
]
