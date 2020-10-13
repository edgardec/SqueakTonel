"
Responsible for real-estate management on the screen, which is to say, controlling where new windows appear, with what sizes, etc.  5/20/96 sw
"
Class {
	#name : #RealEstateAgent,
	#superclass : #Object,
	#classVars : [
		'PlaceWindowsAtPointer',
		'ReverseStaggerOffset',
		'ScaleFactor',
		'StaggerOffset',
		'StaggerOrigin',
		'StandardSize',
		'StandardWindowOrigins'
	],
	#category : #'System-Support'
}

{ #category : #preferences }
RealEstateAgent class >> applyUserInterfaceTheme [

	ScaleFactor := nil.
	
]

{ #category : #utilities }
RealEstateAgent class >> assignCollapseFrameFor: aSSView [ 
	"Offer up a location along the left edge of the screen for a collapsed SSView. Make sure it doesn't overlap any other collapsed frames."

	| grid otherFrames topLeft viewBox collapsedFrame extent newFrame verticalBorderDistance top |
	grid := 8.
	verticalBorderDistance := 8.
	aSSView isMorph
		ifTrue: [otherFrames := (SystemWindow windowsIn: aSSView world satisfying: [:w | w ~= aSSView])
						collect: [:w | w collapsedFrame]
						thenSelect: [:rect | rect notNil].
				viewBox := self maximumUsableAreaInWorld: aSSView world]
		ifFalse: [otherFrames := ScheduledControllers scheduledWindowControllers
						collect: [:aController | aController view ~= aSSView ifTrue: [aController view collapsedFrame]]
						thenSelect: [:rect | rect notNil].
				viewBox := Display boundingBox].
	collapsedFrame := aSSView collapsedFrame.
	extent := collapsedFrame notNil
				ifTrue: [collapsedFrame extent]
				ifFalse: [aSSView isMorph
					ifTrue: [aSSView getRawLabel width + aSSView labelWidgetAllowance @ (aSSView labelHeight + 2)]
					ifFalse: [(aSSView labelText extent x + 70) @ aSSView labelHeight
							min: aSSView labelDisplayBox extent]].
	collapsedFrame notNil
		ifTrue: [(otherFrames anySatisfy: [:f | collapsedFrame intersects: f])
				ifFalse: ["non overlapping"
					^ collapsedFrame]].
	top := viewBox top + verticalBorderDistance.
	[topLeft := viewBox left @ top.
	newFrame := topLeft extent: extent.
	newFrame bottom <= (viewBox height - verticalBorderDistance)]
		whileTrue: 
			[(otherFrames anySatisfy: [:w | newFrame intersects: w])
				ifFalse: ["no overlap"
					^ newFrame].
			top := top + grid].
	"If all else fails... (really to many wins here)"
	aSSView isMorph
		ifTrue:[ Project current showWorldMainDockingBar ifTrue:[^ (0 @ Project current world mainDockingBars first height) extent: extent]].
	^ 0 @ 0 extent: extent
]

{ #category : #utilities }
RealEstateAgent class >> assignCollapsePointFor: aSSView [
	"Offer up a location along the left edge of the screen for a collapsed SSView.
	Make sure it doesn't overlap any other collapsed frames."

	| grid otherFrames y free topLeft viewBox |
	grid := 24.  "should be mult of 8, since manual move is gridded by 8"
	aSSView isMorph
		ifTrue: [otherFrames := (SystemWindow windowsIn: aSSView world satisfying: [:w | true])
					collect: [:w | w collapsedFrame]
					thenSelect: [:rect | rect notNil].
				viewBox := self maximumUsableAreaInWorld: aSSView world]
		ifFalse: [otherFrames := ScheduledControllers scheduledWindowControllers
					collect: [:aController | aController view collapsedFrame]
					thenSelect: [:rect | rect notNil].
				viewBox := Display boundingBox].
	y := viewBox top.
	[(y := y + grid) <= (viewBox height - grid)]
		whileTrue:
		[topLeft := viewBox left@y.
		free := true.
		otherFrames do: [:w | free := free & (topLeft ~= w topLeft)].
		free ifTrue: [^ topLeft]].
	"If all else fails..."
	^ 0 @ 0
]

{ #category : #'display scale' }
RealEstateAgent class >> defaultIconExtent [
	"Scaling. Like in #scaleFactor, we need a reference extent for scaling icons."
	
	^ 16@16
]

{ #category : #'framing - private' }
RealEstateAgent class >> initialFrameAtPointerFor: aView initialExtent: scaledExtent world: aWorld [
	^(aWorld cursorPoint - (50@10)	"puts use with the mouse ptr just to the right of the menu button"
		extent: scaledExtent)
			translatedAndSquishedToBeWithin: (self maximumUsableAreaInWorld: aWorld)
]

{ #category : #framing }
RealEstateAgent class >> initialFrameFor: aView initialExtent: initialExtent world: aWorld [
	| scaledExtent |
	scaledExtent := (initialExtent * self scaleFactor) rounded.

	self placeWindowsAtPointer ifTrue: 
		[^self initialFrameAtPointerFor: aView initialExtent: scaledExtent world: aWorld].

	^ Preferences reverseWindowStagger
		ifTrue: [self strictlyStaggeredInitialFrameFor: aView initialExtent: scaledExtent world: aWorld]
		ifFalse: [self normalInitialFrameFor: aView initialExtent: scaledExtent world: aWorld]
]

{ #category : #framing }
RealEstateAgent class >> initialFrameFor: aView world: aWorld [
	"Find a plausible initial screen area for the supplied view.  See called method."

	^ self initialFrameFor: aView initialExtent: aView initialExtent world: aWorld
]

{ #category : #'class initialization' }
RealEstateAgent class >> initialize [
	"Initialize the class variables in the receiver.  5/22/96 sw"
	"RealEstateAgent initialize"

	StaggerOffset := 6 @ 20.
	ReverseStaggerOffset := -6 @ 20.
	StaggerOrigin := 200 @ 30.
	StandardSize := 600@400.
]

{ #category : #accessing }
RealEstateAgent class >> maximumUsableArea [

	^ self maximumUsableAreaInWorld: Project current world
]

{ #category : #accessing }
RealEstateAgent class >> maximumUsableAreaInWorld: aWorldOrNil [

	| allowedArea |
	allowedArea := Display usableArea.
	aWorldOrNil ifNotNil: [
		Smalltalk isMorphic ifTrue: [
			allowedArea := allowedArea intersect: aWorldOrNil visibleClearArea.
			(((Smalltalk classNamed: 'Flaps') ifNil: [false] ifNotNil: [:cls | cls anyFlapsVisibleIn: aWorldOrNil])
				and: [self respondsTo: #reduceByFlaps:])
					ifTrue: [allowedArea := self reduceByFlaps: allowedArea]]].
	^allowedArea
]

{ #category : #'framing - private' }
RealEstateAgent class >> normalInitialFrameFor: aView initialExtent: initialExtent world: aWorld [
	"Find a plausible initial screen area for the supplied view, which should be a StandardSystemView, taking into account the 'reverseWindowStagger' Preference, the size needed, and other windows currently on the screen."

	| allOrigins screenRight screenBottom putativeOrigin putativeFrame allowedArea staggerOrigin otherFrames |

	allowedArea := self maximumUsableAreaInWorld: aWorld.
	screenRight := allowedArea right.
	screenBottom := allowedArea bottom.

	otherFrames := Smalltalk isMorphic
		ifTrue: [(SystemWindow windowsIn: aWorld satisfying: [:w | w isCollapsed not])
					collect: [:w | w bounds]]
		ifFalse: [ScheduledControllers scheduledWindowControllers
				select: [:aController | aController view ~~ nil]
				thenCollect: [:aController | aController view isCollapsed
								ifTrue: [aController view expandedFrame]
								ifFalse: [aController view displayBox]]].

	allOrigins := otherFrames collect: [:f | f origin].
	(self standardPositionsInWorld: aWorld) do:  "First see if one of the standard positions is free"
		[:aPosition | (allOrigins includes: aPosition)
			ifFalse:
				[^ (aPosition extent: initialExtent) translatedAndSquishedToBeWithin: allowedArea]].

	staggerOrigin := (self standardPositionsInWorld: aWorld) first.  "Fallback: try offsetting from top left"
	putativeOrigin := staggerOrigin.

	[putativeOrigin := putativeOrigin + StaggerOffset.
	putativeFrame := putativeOrigin extent: initialExtent.
	(putativeFrame bottom < screenBottom) and:
					[putativeFrame right < screenRight]]
				whileTrue:
					[(allOrigins includes: putativeOrigin)
						ifFalse:
							[^ (putativeOrigin extent: initialExtent) translatedAndSquishedToBeWithin: allowedArea]].
	^ (self scrollBarSetback @ self screenTopSetback extent: initialExtent) translatedAndSquishedToBeWithin: allowedArea
]

{ #category : #preferences }
RealEstateAgent class >> placeWindowsAtPointer [
	"Value of the place-windows-at-pointer preference."
	<preference: 'Place Windows At Pointer'
		category: 'windows'
		description: 'When true, place new windows near the mouse pointer'
		type: #Boolean>
	^PlaceWindowsAtPointer ifNil: [false]
]

{ #category : #preferences }
RealEstateAgent class >> placeWindowsAtPointer: aBool [
	"Value of the place-windows-at-pointer preference."
	PlaceWindowsAtPointer := aBool
]

{ #category : #'display scale' }
RealEstateAgent class >> scaleFactor [
	"Use the default font height to calculate some factor. Better than nothing..."
	
	^ ScaleFactor ifNil: [ScaleFactor := (TextStyle defaultFont height / 14 "reference value")]
]

{ #category : #settings }
RealEstateAgent class >> screenTopSetback [
	Smalltalk isMorphic
		ifTrue: [^ 0]
		ifFalse: [^ 18]
]

{ #category : #settings }
RealEstateAgent class >> scrollBarSetback [
	Smalltalk isMorphic
		ifTrue: [^ 16-3]  "width = 16; inset from border by 3"
		ifFalse: [^ 24]
]

{ #category : #accessing }
RealEstateAgent class >> standardPositions [
	
	self error: 'please use #standardPositionsInWorld:'
]

{ #category : #accessing }
RealEstateAgent class >> standardPositionsInWorld: aWorldOrNil [
	"Return a list of standard window positions -- this may have one, two, or four of them, depending on the size and shape of the display screen.  "

	| anArea aList  midX midY |

	anArea := self maximumUsableAreaInWorld: aWorldOrNil.

	midX := self scrollBarSetback +   ((anArea width - self scrollBarSetback)  // 2).
	midY := self screenTopSetback + ((anArea height - self screenTopSetback) // 2).
	aList := OrderedCollection with: (self scrollBarSetback @ self screenTopSetback).
	self windowColumnsDesired > 1
		ifTrue:
			[aList add: (midX @ self screenTopSetback)].
	self windowRowsDesired > 1
		ifTrue:
			[aList add: (self scrollBarSetback @ (midY+self screenTopSetback)).
			self windowColumnsDesired > 1 ifTrue:
				[aList add: (midX @ (midY+self screenTopSetback))]].
	^ aList
]

{ #category : #accessing }
RealEstateAgent class >> standardSize [
	^ StandardSize
]

{ #category : #accessing }
RealEstateAgent class >> standardSize: extent [
	StandardSize := extent
]

{ #category : #settings }
RealEstateAgent class >> standardWindowExtent [
	"Answer the standard default extent for new windows.  "

	| effectiveExtent width strips height grid allowedArea maxLevel extent |
	effectiveExtent := self maximumUsableArea extent
					- (self scrollBarSetback @ self screenTopSetback).
	Preferences reverseWindowStagger ifTrue:
		["NOTE: following copied from strictlyStaggeredInitialFrameFor:"
		allowedArea := self maximumUsableArea insetBy: (
			self scrollBarSetback @ self screenTopSetback extent: 0@0
		).
		"Number to be staggered at each corner (less on small screens)"
		maxLevel := allowedArea area > 300000 ifTrue: [3] ifFalse: [2].
		"Amount by which to stagger (less on small screens)"
		grid := allowedArea area > 500000 ifTrue: [40] ifFalse: [20].
		extent := (allowedArea extent - (grid*(maxLevel+1*2) + (grid//2))) min: StandardSize "600@400".
		(extent y < 300) ifTrue: [^ (extent x)@300 ].
		^ extent].
	width := (strips := self windowColumnsDesired) > 1
		ifTrue:
			[effectiveExtent x // strips]
		ifFalse:
			[(3 * effectiveExtent x) // 4].
	height := (strips := self windowRowsDesired) > 1
		ifTrue:
			[effectiveExtent y // strips]
		ifFalse:
			[(3 * effectiveExtent y) //4].
	^ width @ height

"RealEstateAgent standardWindowExtent"
]

{ #category : #'framing - private' }
RealEstateAgent class >> strictlyStaggeredInitialFrameFor: aStandardSystemView initialExtent: initialExtent world: aWorld [
	"This method implements a staggered window placement policy that I (di) like.
	Basically it provides for up to 4 windows, staggered from each of the 4 corners.
	The windows are staggered so that there will always be a corner visible."

	| allowedArea grid initialFrame otherFrames cornerSel corner delta putativeCorner free maxLevel |

	allowedArea :=(self maximumUsableAreaInWorld: aWorld)
		insetBy: (self scrollBarSetback @ self screenTopSetback extent: 0@0).
	"Number to be staggered at each corner (less on small screens)"
	maxLevel := allowedArea area > 300000 ifTrue: [3] ifFalse: [2].
	"Amount by which to stagger (less on small screens)"
	grid := allowedArea area > 500000 ifTrue: [40] ifFalse: [20].
	initialFrame := 0@0 extent: ((initialExtent
							"min: (allowedArea extent - (grid*(maxLevel+1*2) + (grid//2))))
							min: 600@400")).
	otherFrames := Smalltalk isMorphic
		ifTrue: [(SystemWindow windowsIn: aWorld satisfying: [:w | w isCollapsed not])
					collect: [:w | w bounds]]
		ifFalse: [ScheduledControllers scheduledWindowControllers
				select: [:aController | aController view ~~ nil]
				thenCollect: [:aController | aController view isCollapsed
								ifTrue: [aController view expandedFrame]
								ifFalse: [aController view displayBox]]].
	0 to: maxLevel do:
		[:level | 
		1 to: 4 do:
			[:ci | cornerSel := #(topLeft topRight bottomRight bottomLeft) at: ci.
			corner := allowedArea perform: cornerSel.
			"The extra grid//2 in delta helps to keep title tabs distinct"
			delta := (maxLevel-level*grid+(grid//2)) @ (level*grid).
			1 to: ci-1 do: [:i | delta := delta rotateBy: #right centerAt: 0@0]. "slow way"
			putativeCorner := corner + delta.
			free := true.
			otherFrames do:
				[:w |
				free := free & ((w perform: cornerSel) ~= putativeCorner)].
			free ifTrue:
				[^ (initialFrame align: (initialFrame perform: cornerSel)
								with: putativeCorner)
						 translatedAndSquishedToBeWithin: allowedArea]]].
	"If all else fails..."
	^ (self scrollBarSetback @ self screenTopSetback extent: initialFrame extent)
		translatedAndSquishedToBeWithin: allowedArea
]

{ #category : #preferences }
RealEstateAgent class >> themeProperties [

	^ {
		{ #scaleFactor. 'Scaling & Hi-DPI'. 'The factor to scale geometry such as window extent.' }.
	}
]

{ #category : #settings }
RealEstateAgent class >> windowColumnsDesired [
	"Answer how many separate vertical columns of windows are wanted.  5/22/96 sw"
	^ Preferences reverseWindowStagger
		ifTrue:
			[1]
		ifFalse:
			[(self maximumUsableArea width > 640)
				ifTrue:
					[2]
				ifFalse:
					[1]]
]

{ #category : #settings }
RealEstateAgent class >> windowRowsDesired [
	"Answer how many separate horizontal rows of windows are wanted.  5/22/96 sw"
	^ Preferences reverseWindowStagger
		ifTrue:
			[1]
		ifFalse:
			[(self maximumUsableArea height > 480)
				ifTrue:
					[2]
				ifFalse:
					[1]]
]

{ #category : #preferences }
RealEstateAgent >> applyUserInterfaceTheme [

	"Ignore. Only class-side cache."
]

{ #category : #preferences }
RealEstateAgent >> canApplyUserInterfaceTheme [
	"See class side."
	
	^ false
]
