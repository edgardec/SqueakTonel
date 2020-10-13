"
I generate multi-page Postscript files, for example of Book morphs.  The goal is to crete Adobe Document Structuring Conventions compliant, but this is currently not the case.

"
Class {
	#name : #DSCPostscriptCanvas,
	#superclass : #PostscriptCanvas,
	#category : #'MorphicExtras-Postscript Canvases'
}

{ #category : #'page geometry' }
DSCPostscriptCanvas >> defaultImageableArea [
	^ self defaultPageSize insetBy:self defaultMargin.

]

{ #category : #'page geometry' }
DSCPostscriptCanvas >> defaultMargin [  "In Points"
	^ (0.25 * 72) asInteger.

]

{ #category : #'page geometry' }
DSCPostscriptCanvas >> defaultPageSize [
	" This is Letter size in points.  European A4 is 595 @ 842 "
	^ 0 @ 0 extent: ((8.5 @ 11.0) * 72) asIntegerPoint.

]

{ #category : #'morph drawing' }
DSCPostscriptCanvas >> endGStateForMorph: aMorph [ 
	"position the morph on the page "
	morphLevel
			== (topLevelMorph pagesHandledAutomatically
					ifTrue: [2]
					ifFalse: [1])
		ifTrue:  [ target showpage; print: 'grestore'; cr  ]
]

{ #category : #'drawing-general' }
DSCPostscriptCanvas >> fullDraw: aMorph [ 
	(morphLevel = 0 and: [aMorph pagesHandledAutomatically not]) 
		ifTrue: 
			[pages := pages + 1.
			target
				print: '%%Page: 1 1';
				cr].
	super fullDraw: aMorph.
	morphLevel = 0 
		ifTrue: 
			[ self writeTrailer: pages. ]
]

{ #category : #'page geometry' }
DSCPostscriptCanvas >> pageBBox [
	| pageSize offset bbox trueExtent |
	trueExtent := savedMorphExtent * initialScale.
	"this one has been rotated"
	pageSize := self defaultPageSize.
	offset := pageSize extent - trueExtent / 2 max: 0 @ 0.
	bbox := offset extent: trueExtent.
	^ bbox
]

{ #category : #'page geometry' }
DSCPostscriptCanvas >> pageOffset [
	^self pageBBox origin.

]

{ #category : #'morph drawing' }
DSCPostscriptCanvas >> setupGStateForMorph: aMorph [ 
	"position the morph on the page "
	morphLevel
			== (topLevelMorph pagesHandledAutomatically
					ifTrue: [2]
					ifFalse: [1])
		ifTrue:  [ self writePageSetupFor: aMorph ]
]

{ #category : #initialization }
DSCPostscriptCanvas >> writePSIdentifierRotated: rotateFlag [ 
	| morphExtent pageExtent |
	target print: '%!PS-Adobe-2.0'; cr;
		 print: '%%Pages: (atend)'; cr;
		 print: '%%DocumentFonts: (atend)'; cr.
	"Define initialScale so that the morph will fit the page rotated or not"
	savedMorphExtent := morphExtent := rotateFlag
						ifTrue: [psBounds extent transposed]
						ifFalse: [psBounds extent].
	pageExtent := self defaultImageableArea extent asFloatPoint.
	initialScale := (printSpecs isNil
					or: [printSpecs scaleToFitPage])
				ifTrue: [pageExtent x / morphExtent x min: pageExtent y / morphExtent y]
				ifFalse: [1.0].
	target print: '%%BoundingBox: ';
		 write: self defaultImageableArea; cr.
	target print: '%%Title: '; print: self topLevelMorph externalName; cr.
	target print: '%%Creator: '; print: Utilities authorName; cr.
	target print: '%%CreationDate: '; print: Date today asString; space; print: Time now asString; cr.

	target print: '%%Orientation: ';
		
		print: (rotateFlag
				ifTrue: ['Landscape']
				ifFalse: ['Portrait']); cr.
	target print: '%%EndComments'; cr.

]
