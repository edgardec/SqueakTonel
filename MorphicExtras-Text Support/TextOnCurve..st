"
This subclass of Paragraph composes and displays text along a segmented line or curve.  It does this by using all the normal text composition machinery, but just to lay text out for each segment of the curve in question.  The display process is somewhat complicated, as it involves rotating the text for each segment, and then merging it into the destination Form with background, selection highlight, and transparency all handled correctly.

Because TextMorph flushes its paragraph to save space, the enduring specification of curve layout (direction, baseline, and margin) must be stored in the container.
"
Class {
	#name : #TextOnCurve,
	#superclass : #NewParagraph,
	#instVars : [
		'lastCharacterIndex',
		'curve'
	],
	#classVars : [
		'CachedWarpColor',
		'CachedWarpDepth',
		'CachedWarpMap'
	],
	#category : #'MorphicExtras-Text Support'
}

{ #category : #'class initialization' }
TextOnCurve class >> cleanUp [
	"Flush caches"

	self reset.
]

{ #category : #accessing }
TextOnCurve class >> reset [
	"TextOnCurve reset"
	CachedWarpMap := CachedWarpDepth := CachedWarpColor := nil
]

{ #category : #private }
TextOnCurve >> adjustRightX [
 "No-op for this class. TextOnCurve have computes bounds differently"
]

{ #category : #display }
TextOnCurve >> asParagraphForPostscript [

	^ self as: TextOnCurvePS
]

{ #category : #selection }
TextOnCurve >> characterBlockAtPoint: aPoint [ 
	"Answer a CharacterBlock for the character in the text at aPoint."
	| curvePoint cb |
	self textSegmentsDo:
		[:line :destRect :segStart :segAngle | | sourcePoint |
		(destRect containsPoint: aPoint) ifTrue:
			["It's in the destRect; now convert to source coords"
			sourcePoint := self pointInLine: line forDestPoint: aPoint
							segStart: segStart segAngle: segAngle.
			cb := (CharacterBlockScanner new text: text textStyle: textStyle)
				characterBlockAtPoint: (sourcePoint adhereTo: line rectangle)
				index: nil in: line.
			(sourcePoint x between: line left and: line right) ifTrue:
				["Definitely in this segment"
				^ cb]]].
	"Point is off curve -- try again with closest point on curve"
	curvePoint := curve closestPointTo: aPoint.
	curvePoint = aPoint ifFalse:
		[^ self characterBlockAtPoint: curvePoint].
	"If all else fails, at least return something acceptable."
	^ cb ifNil: [self defaultCharacterBlock]
]

{ #category : #composition }
TextOnCurve >> composeAll [
	self composeLinesFrom: firstCharacterIndex
		withLines: OrderedCollection new
		atY: container top.
]

{ #category : #composition }
TextOnCurve >> composeLinesFrom: start to: stop delta: delta into: newLines priorLines: priorLines
	atY: startingY [

	^ self composeLinesFrom: start withLines: newLines atY: startingY
]

{ #category : #composition }
TextOnCurve >> composeLinesFrom: startingIndex withLines: startingLines atY: startingY [ 
	"Here we determine the 'lines' of text that will fit along each segment of the curve. For each line, we determine its rectangle, then the dest wuadrilateral that it willbe rotated to.  Then, we take the outer hull to determine a dest rectangle for WarpBlt.  In addition we need the segment pivot point and angle, from which the source quadrilateral may be computed."

	| charIndex scanner line firstLine curveSegments segIndex pa pb segLen lineRect textSegments segDelta segAngle destRect destQuad i oldBounds |
	(oldBounds := container bounds) ifNotNil: [curve invalidRect: oldBounds].
	charIndex := startingIndex.
	lines := startingLines.
	curveSegments := curve lineSegments.
	container textDirection < 0 
		ifTrue: 
			[curveSegments := curveSegments reversed 
						collect: [:seg | Array with: (seg second) with: seg first]].
	textSegments := OrderedCollection new.
	scanner := SegmentScanner new text: text textStyle: textStyle.
	segIndex := 1.	"For curves, segIndex is just an index."
	firstLine := true.
	pa := curveSegments first first.
	[charIndex <= text size and: [segIndex <= curveSegments size]] whileTrue: 
			[curve isCurve ifFalse: [pa := (curveSegments at: segIndex) first].
			pb := (curveSegments at: segIndex) last.
			segDelta := pb - pa.	"Direction of this segment"
			segLen := segDelta r.
			lineRect := 0 @ 0 extent: segLen asInteger @ textStyle lineGrid.
			line := scanner 
						composeFrom: charIndex
						inRectangle: lineRect
						firstLine: firstLine
						leftSide: true
						rightSide: true.
			line setRight: scanner rightX.
			line width > 0 
				ifTrue: 
					[lines addLast: line.
					segAngle := segDelta theta.
					destQuad := line rectangle corners collect: 
									[:p | 
									(p translateBy: pa - (0 @ (line baseline + container baseline))) 
										rotateBy: segAngle negated
										about: pa].
					destRect := Rectangle encompassing: destQuad.
					textSegments addLast: (Array 
								with: destRect truncated
								with: pa
								with: segAngle).
					pa := pa + ((pb - pa) * line width / segLen).
					charIndex := line last + 1].
			segIndex := segIndex + 1.
			firstLine := false].
	lines isEmpty 
		ifTrue: 
			["No space in container or empty text"

			line := (TextLine 
						start: startingIndex
						stop: startingIndex - 1
						internalSpaces: 0
						paddingWidth: 0)
						rectangle: (0 @ 0 extent: 10 @ textStyle lineGrid);
						lineHeight: textStyle lineGrid baseline: textStyle baseline.
			lines := Array with: line.
			textSegments addLast: (Array 
						with: (curve vertices first extent: line rectangle extent)
						with: curve vertices first
						with: 0.0)].
	"end of segments, now attempt word break."
	lines last last < text size 
		ifTrue: 
			[
			[lines size > 1 
				and: [(text at: (i := lines last last) + 1) ~= Character space]] 
					whileTrue: 
						[i = lines last first 
							ifTrue: 
								[lines removeLast.
								textSegments removeLast]
							ifFalse: [lines last stop: i - 1]]].
	lines := lines asArray.
	container textSegments: textSegments asArray.
	curve invalidRect: container bounds.
	^maxRightX
]

{ #category : #selection }
TextOnCurve >> containsPoint: aPoint [
	"Return true if aPoint is in the actual text areas."
	self textSegmentsDo:
		[:line :destRect :segStart :segAngle |
		(destRect containsPoint: aPoint) ifTrue:
			["It's in the destRect; now check if really in text area"
			(line rectangle containsPoint:
				(self pointInLine: line forDestPoint: aPoint
					segStart: segStart segAngle: segAngle))
				ifTrue: [^ true]]].
	^ false
]

{ #category : #display }
TextOnCurve >> displayOn: aCanvas using: displayScanner at: somePosition [
	"Send all visible lines to the displayScanner for display"
	| warp lineRect lineCanvas backgroundColor lineForm leftInRun sourceQuad maxExtent |
	"most of these temps are initialized lazily and need to be at the method level - do not move into the block below!"
	warp := nil.
	self textSegmentsDo:
		[:line :destRect :segStart :segAngle |
		false ifTrue:
			["Show the dest rects for debugging..."
			aCanvas frameRectangle: destRect width: 1 color: Color black].
		(aCanvas isVisible: destRect) ifTrue:
			[warp ifNil:
				["Lazy initialization because may not have to display at all."
				maxExtent := lines inject: lines first rectangle extent 
					into: [:maxWid :lin | maxWid max: lin rectangle extent].
				lineForm := Form extent: maxExtent depth: aCanvas depth.
				displayScanner setDestForm: lineForm.
				lineRect := lineForm boundingBox.
				leftInRun := 0.
				backgroundColor := (curve borderWidth > 10
							ifTrue: [curve color]
							ifFalse: [curve owner isHandMorph
									ifTrue: [curve owner owner color]
									ifFalse: [curve owner color]]) dominantColor.
				warp := (aCanvas warpFrom: lineRect corners toRect: lineRect)
						cellSize: 2;  "installs a colormap if smoothing > 1"
						sourceForm: lineForm.
				warp colorMap: (self warpMapForDepth: aCanvas depth
									withTransparentFor: backgroundColor).
				lineCanvas := lineForm getCanvas].
			sourceQuad := destRect innerCorners collect:
				[:p | self pointInLine: line forDestPoint: p
						segStart: segStart segAngle: segAngle].
			lineForm fill: lineForm boundingBox fillColor: backgroundColor.
			self displaySelectionInLine: line on: lineCanvas.
			leftInRun := displayScanner displayLine: line offset: 0@0 leftInRun: leftInRun.
			warp sourceQuad: sourceQuad destRect: (destRect translateBy: aCanvas origin).
			warp warpBits]].

]

{ #category : #accessing }
TextOnCurve >> extent [
	^ curve bounds extent
]

{ #category : #private }
TextOnCurve >> moveBy: delta [
	positionWhenComposed := (positionWhenComposed ifNil: [ container origin ]) + delta.
	container := container translateBy: delta

]

{ #category : #private }
TextOnCurve >> pointInLine: line forDestPoint: p segStart: segStart segAngle: segAngle [
	^ (p rotateBy: segAngle about: segStart)
			translateBy: (0@(line baseline + container baseline)) - segStart
]

{ #category : #caching }
TextOnCurve >> releaseCachedState [
	super releaseCachedState.
	CachedWarpMap := CachedWarpDepth := CachedWarpColor := nil
]

{ #category : #selection }
TextOnCurve >> selectionRectsFrom: characterBlock1 to: characterBlock2 [
	"Return an array of rectangles encompassing the area
	between the two character blocks, presumably a selection."
	| rects |
	rects := OrderedCollection new.
	self textSegmentsDo:
		[:line :destRect :segStart :segAngle |
		(characterBlock1 stringIndex <= line last
			and: [characterBlock2 stringIndex >= line first]) ifTrue:
			[rects addLast: destRect].
		line first > characterBlock2 stringIndex ifTrue:
			[^ rects]].
	^ rects
]

{ #category : #accessing }
TextOnCurve >> textOwner: theCurve [
	curve := theCurve
]

{ #category : #private }
TextOnCurve >> textSegmentsDo: blockForLineDestPivotAngle [ 
	| segments segSpec |
	(segments := container textSegments) ifNil: [^self].
	1 to: lines size
		do: 
			[:i | 
			segSpec := segments at: i.
			blockForLineDestPivotAngle 
				value: (lines at: i)
				value: (segSpec first)
				value: (segSpec second)
				value: (segSpec third)]
]

{ #category : #private }
TextOnCurve >> warpMapForDepth: destDepth withTransparentFor: bkgndColor [ 
	(CachedWarpDepth = destDepth and: [CachedWarpColor = bkgndColor]) 
		ifTrue: 
			["Map is OK as is -- return it"

			^CachedWarpMap].
	(CachedWarpMap isNil or: [CachedWarpDepth ~= destDepth]) 
		ifTrue: 
			["Have to recreate the map"

			CachedWarpMap := Color computeColormapFrom: 32 to: destDepth.
			CachedWarpDepth := destDepth]
		ifFalse: 
			["Map is OK, if we restore prior color substiution"

			CachedWarpMap at: (CachedWarpColor indexInMap: CachedWarpMap)
				put: (CachedWarpColor pixelValueForDepth: destDepth)].
	"Now map the background color into transparent, and return the new map"
	CachedWarpColor := bkgndColor.
	CachedWarpMap at: (CachedWarpColor indexInMap: CachedWarpMap) put: 0.
	^CachedWarpMap
]
