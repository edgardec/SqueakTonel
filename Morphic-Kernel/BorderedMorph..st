"
BorderedMorph introduce borders to morph. Borders have the instanceVariables borderWidth and borderColor.
 
BorderedMorph new borderColor: Color red; borderWidth: 10; openInWorld.

BorderedMorph also have a varaity of border styles: simple, inset, raised, complexAltFramed, complexAltInset, complexAltRaised, complexFramed, complexInset, complexRaised.
These styles are set using the classes BorderStyle, SimpleBorder, RaisedBorder, InsetBorder and ComplexBorder.

BorderedMorph new borderStyle: (SimpleBorder width: 1 color: Color white); openInWorld.
BorderedMorph new borderStyle: (BorderStyle inset width: 2); openInWorld.



"
Class {
	#name : #BorderedMorph,
	#superclass : #Morph,
	#instVars : [
		'borderWidth',
		'borderColor'
	],
	#category : #'Morphic-Kernel'
}

{ #category : #geometry }
BorderedMorph >> acquireBorderWidth: aBorderWidth [
	"Gracefully acquire the new border width, keeping the interior area intact and not seeming to shift"

	| delta |
	(delta := aBorderWidth- self borderWidth) = 0 ifTrue: [^ self].
	self bounds: ((self bounds origin - (delta @ delta)) corner: (self bounds corner + (delta @ delta))).
	self borderWidth: aBorderWidth.
]

{ #category : #menu }
BorderedMorph >> addBorderStyleMenuItems: aMenu hand: aHandMorph [
	"Add border-style menu items"

	| subMenu |
	subMenu := MenuMorph new defaultTarget: self.
	"subMenu addTitle: 'border' translated."
	subMenu addStayUpItemSpecial.
	subMenu addList: 
		{{'border color...' translated. #changeBorderColor:}.
		{'border width...' translated. #changeBorderWidth:}}.
	subMenu addLine.
	BorderStyle borderStyleChoices do:
		[:sym | (self borderStyleForSymbol: sym)
			ifNotNil:
				[subMenu add: sym translated target: self selector: #setBorderStyle: argument: sym]].
	aMenu add: 'border style' translated subMenu: subMenu

]

{ #category : #'resize handling' }
BorderedMorph >> addCornerGrips [
	self
		addMorphBack: (TopLeftGripMorph new target: self; position: self position).
	self
		addMorphBack: (TopRightGripMorph new target: self; position: self position).
	self
		addMorphBack: (BottomLeftGripMorph new target: self;position: self position).
	self
		addMorphBack: (BottomRightGripMorph new target: self;position: self position)
]

{ #category : #'resize handling' }
BorderedMorph >> addEdgeGrips [
	"Add resizers along the four edges of the receiver"

	self
		addMorphBack: (TopGripMorph new target: self;position: self position).
	self
		addMorphBack: (BottomGripMorph new target: self;position: self position).
	self
		addMorphBack: (RightGripMorph new target: self;position: self position).
	self
		addMorphBack: (LeftGripMorph new target: self;position: self position).
]

{ #category : #'resize handling' }
BorderedMorph >> addMorph: aMorph fullFrame: aLayoutFrame [
	"Add aMorph according to aLayoutFrame."

	self cellGap > 0 ifTrue: [
		| left right bottom top spacing |

		spacing := self cellGap.
		left := aLayoutFrame leftOffset.
		right := aLayoutFrame rightOffset.

		bottom := aLayoutFrame bottomOffset.
		top := aLayoutFrame topOffset.
		
		"Add a spacing to the frame if it is not top or leftmost."
		aLayoutFrame leftFraction = 0
			ifFalse: [left := left + spacing]
			ifTrue: [
				"Expect another, resizable widget besides me if I have a fixed width."
				aLayoutFrame hasFixedWidth ifTrue: [right := right - spacing]].
		aLayoutFrame topFraction = 0
			ifFalse: [top := top + spacing]
			ifTrue: [
				"Expect another, resizable widget besides me if I have a fixed height."
				aLayoutFrame hasFixedHeight ifTrue: [bottom := bottom - spacing]].
			
		aLayoutFrame
			topOffset: top;
			bottomOffset: bottom;
			leftOffset: left;
			rightOffset: right].
	
	super addMorph: aMorph fullFrame: aLayoutFrame.
	
	self wantsPaneSplitters ifTrue: [self addPaneSplitters].
]

{ #category : #'resize handling' }
BorderedMorph >> addPaneHSplitterAtBottomOfRow: someMorphs [

	| targetY minX maxX splitter |
	targetY := someMorphs first layoutFrame bottomFraction.

	minX := (someMorphs detectMin: [:each | each layoutFrame leftFraction]) layoutFrame leftFraction.
	maxX := (someMorphs detectMax: [:each | each layoutFrame rightFraction]) layoutFrame rightFraction.

	splitter := ProportionalSplitterMorph new beSplitsTopAndBottom; yourself.
	splitter layoutFrame: (LayoutFrame
		fractions: (minX @ targetY corner: maxX @ targetY)
		offsets: (someMorphs first layoutFrame leftOffset @ 0 
			corner: someMorphs first layoutFrame rightOffset @ AbstractResizerMorph gripThickness)).

	self addMorphBack: (splitter position: self position).
]

{ #category : #'resize handling' }
BorderedMorph >> addPaneHSplitters [

	| remaining targetY sameY |
	remaining := self paneMorphs reject: [:each |
		each layoutFrame bottomFraction = 1
			or: [each layoutFrame hasFixedHeight]].
	[remaining notEmpty] whileTrue:
		[targetY := remaining first layoutFrame bottomFraction.
		sameY := self paneMorphs select: [:each | each layoutFrame bottomFraction = targetY].
		self addPaneHSplitterAtBottomOfRow: sameY.
		remaining := remaining copyWithoutAll: sameY]
]

{ #category : #'resize handling' }
BorderedMorph >> addPaneSplitters [

	self removePaneSplitters.
	
	self addPaneVSplitters.
	self addPaneHSplitters.	

	self linkSubmorphsToSplitters
]

{ #category : #'resize handling' }
BorderedMorph >> addPaneVSplitterAtRightOfColumn: someMorphs [

	| targetX minY maxY splitter |
	targetX := someMorphs first layoutFrame rightFraction.
	
	minY := (someMorphs detectMin: [:each | each layoutFrame topFraction]) layoutFrame topFraction.
	maxY := (someMorphs detectMax: [:each | each layoutFrame bottomFraction]) layoutFrame bottomFraction.
	
	splitter := ProportionalSplitterMorph new beSplitsLeftAndRight; yourself.
	splitter layoutFrame: (LayoutFrame
		fractions: (targetX @ minY corner: targetX @ maxY)
		offsets: (0 @ (someMorphs first layoutFrame topOffset)
			corner: (AbstractResizerMorph gripThickness@ (someMorphs first layoutFrame bottomOffset)))).

	self addMorphBack: (splitter position: self position).
]

{ #category : #'resize handling' }
BorderedMorph >> addPaneVSplitters [

	| remaining targetX sameX |
	remaining := self paneMorphs reject: [:each |
		each layoutFrame rightFraction = 1
			or: [each layoutFrame hasFixedWidth]].
	[remaining notEmpty] whileTrue:
		[targetX := remaining first layoutFrame rightFraction.
		sameX := self paneMorphs select: [:each | each layoutFrame rightFraction = targetX].
		self addPaneVSplitterAtRightOfColumn: sameX.
		remaining := remaining copyWithoutAll: sameX]
]

{ #category : #drawing }
BorderedMorph >> areasRemainingToFill: aRectangle [
	"Fixed here to test the fillStyle rather than color for translucency.
	Since can have a translucent fillStyle while the (calculated) color is not."
	
	self fillStyle isTranslucent
		ifTrue: [^ Array with: aRectangle].
	self wantsRoundedCorners
		ifTrue: [(self borderWidth > 0
					and: [self borderColor isColor
							and: [self borderColor isTranslucent]])
				ifTrue: [^ aRectangle
						areasOutside: (self innerBounds intersect: self boundsWithinCorners)]
				ifFalse: [^ aRectangle areasOutside: self boundsWithinCorners]]
		ifFalse: [(self borderWidth > 0
					and: [self borderColor isColor
							and: [self borderColor isTranslucent]])
				ifTrue: [^ aRectangle areasOutside: self innerBounds]
				ifFalse: [^ aRectangle areasOutside: self bounds]]

]

{ #category : #accessing }
BorderedMorph >> borderColor: aColorOrSymbolOrNil [

	super borderColor: aColorOrSymbolOrNil.

	self flag: #compatibility. "mt: For older code, update the instance variables. Should be removed in the future."
	borderColor := self borderStyle color.
]

{ #category : #initialization }
BorderedMorph >> borderInitialize [
	"initialize the receiver state related to border"

	self borderStyle: (
		self defaultBorderStyle
			baseColor: self defaultBorderColor;
			width: self defaultBorderWidth;
			trackColorFrom: self;
			yourself).
]

{ #category : #initialization }
BorderedMorph >> borderInset [
	"Change border to inset. Preserve width and color."
	
	self borderStyle: (
		BorderStyle inset
			width: self borderStyle width;
			baseColor: Color transparent;
			trackColorFrom: self;
			yourself).
]

{ #category : #initialization }
BorderedMorph >> borderRaised [
	"Change border to inset. Preserve width and color."
	
	self borderStyle: (
		BorderStyle raised
			width: self borderStyle width;
			baseColor: Color transparent;
			trackColorFrom: self;
			yourself).
]

{ #category : #initialization }
BorderedMorph >> borderSimple [
	"Change border to simple. Preserve width and color."
	
	self borderStyle: (
		BorderStyle simple
			width: self borderStyle width;
			baseColor: self borderStyle color; "Override any raised/inset specials."
			trackColorFrom: self;
			yourself).
]

{ #category : #accessing }
BorderedMorph >> borderStyle: aBorderStyle [ 

	super borderStyle: aBorderStyle.

	self flag: #compatibility. "mt: For older code, update the instance variables. Should be removed in the future."
	borderWidth := self borderStyle width.
	borderColor := self borderStyle color.
]

{ #category : #accessing }
BorderedMorph >> borderWidth: anInteger [
	
	super borderWidth: anInteger.
		
	self flag: #compatibility. "mt: For older code, update the instance variables. Should be removed in the future."
	borderWidth := self borderStyle width.
]

{ #category : #menu }
BorderedMorph >> changeBorderColor: evt [
	| aHand |
	aHand := evt ifNotNil: [evt hand] ifNil: [self primaryHand].
	self changeColorTarget: self selector: #borderColor: originalColor: self borderColor hand: aHand
]

{ #category : #menu }
BorderedMorph >> changeBorderWidth: evt [
	| handle origin aHand newWidth oldWidth |
	aHand := evt ifNil: [self primaryHand] ifNotNil: [evt hand].
	origin := aHand position.
	oldWidth := self borderWidth.
	(handle := HandleMorph new)
		forEachPointDo:
			[:newPoint | handle removeAllMorphs.
			handle addMorph:
				(LineMorph from: origin to: newPoint color: Color black width: 1).
			newWidth := (newPoint - origin) r asInteger // 5.
			self borderWidth: newWidth]
		lastPointDo:
			[:newPoint | handle deleteBalloon.
			self halo ifNotNil: [:halo | halo addHandles].
			self rememberCommand:
				(Command new cmdWording: 'border change' translated;
					undoTarget: self selector: #borderWidth: argument: oldWidth;
					redoTarget: self selector: #borderWidth: argument: newWidth)].
	aHand attachMorph: handle.
	handle setProperty: #helpAtCenter toValue: true.
	handle showBalloon:
'Move cursor farther from
this point to increase border width.
Click when done.' translated hand: evt hand.
	handle startStepping
]

{ #category : #geometry }
BorderedMorph >> closestPointTo: aPoint [
	"account for round corners. Still has a couple of glitches at upper left and right corners"
	| pt |
	pt := self bounds pointNearestTo: aPoint.
	self wantsRoundedCorners ifFalse: [ ^pt ].
	self bounds corners with: (self bounds insetBy: 6) corners do: [ :out :in |
		(pt - out) abs < (6@6)
			ifTrue: [ ^(in + (Point r: 5.0 degrees: (pt - in) degrees)) asIntegerPoint ].
	].
	^pt.
]

{ #category : #initialization }
BorderedMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color black
]

{ #category : #initialization }
BorderedMorph >> defaultBorderStyle [
	^ BorderStyle simple
]

{ #category : #initialization }
BorderedMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 2
]

{ #category : #'resize handling' }
BorderedMorph >> doFastWindowReframe: ptName [

	| newBounds |
	"For fast display, only higlight the rectangle during loop"
	newBounds := self bounds newRectButtonPressedDo: [:f | 
		f 
			withSideOrCorner: ptName
			setToPoint: (self pointFromWorld: Sensor cursorPoint)
			minExtent: self minimumExtent].
	self bounds: newBounds.
	^newBounds.
]

{ #category : #'resize handling' }
BorderedMorph >> fastFramingOn [

	^ Preferences fastDragWindowForMorphic
]

{ #category : #printing }
BorderedMorph >> fullPrintOn: aStream [
	aStream nextPutAll: '('.
	super fullPrintOn: aStream.
	aStream nextPutAll: ') setBorderWidth: '; print: self borderWidth;
		nextPutAll: ' borderColor: ' , (self colorString: self borderColor)
]

{ #category : #'resize handling' }
BorderedMorph >> grips [

	^ self submorphsSatisfying: [:each | each isKindOf: CornerGripMorph]
]

{ #category : #accessing }
BorderedMorph >> hasTranslucentColor [
	"Answer true if this any of this morph is translucent but not transparent."

	(self color isColor and: [self color isTranslucentColor]) ifTrue: [^ true].
	(self borderColor isColor and: [self borderColor isTranslucentColor]) ifTrue: [^ true].
	^ false

]

{ #category : #initialization }
BorderedMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
""
	self borderInitialize
]

{ #category : #geometry }
BorderedMorph >> intersectionWithLineSegmentFromCenterTo: aPoint [
	"account for round corners. Still has a couple of glitches at upper left and right corners"
	| pt |
	pt := super intersectionWithLineSegmentFromCenterTo: aPoint.
	self wantsRoundedCorners ifFalse: [ ^pt ].
	self bounds corners with: (self bounds insetBy: 6) corners do: [ :out :in |
		(pt - out) abs < (6@6)
			ifTrue: [ ^(in + (Point r: 5.0 degrees: (pt - in) degrees)) asIntegerPoint ].
	].
	^pt.
]

{ #category : #'resize handling' }
BorderedMorph >> linkSubmorphsToSplitters [

	self splitters do: [:splitter |
		splitter splitsTopAndBottom ifTrue: [
			self submorphsDo: [:morph |
					((morph ~= splitter
						and: [morph layoutFrame bottomFraction = splitter layoutFrame topFraction])
						and: [morph layoutFrame hasFixedHeight not
							or: [(morph layoutFrame topOffset) < 0]])
								ifTrue: [splitter addLeftOrTop: morph].
					((morph ~= splitter
						and: [morph layoutFrame topFraction = splitter layoutFrame bottomFraction])
						and: [morph layoutFrame hasFixedHeight not
							or: [(morph layoutFrame bottomOffset) > 0]])
								ifTrue: [splitter addRightOrBottom: morph]]].
		splitter splitsLeftAndRight ifTrue: [
			self submorphsDo: [:morph |
					((morph ~= splitter
						and: [morph layoutFrame rightFraction = splitter layoutFrame leftFraction])
						and: [morph layoutFrame hasFixedWidth not
							or: [(morph layoutFrame leftOffset) < 0]])
								ifTrue: [splitter addLeftOrTop: morph].
					((morph ~= splitter 
						and: [morph layoutFrame leftFraction = splitter layoutFrame rightFraction])
						and: [morph layoutFrame hasFixedWidth not
							or: [(morph layoutFrame rightOffset) > 0]])
								ifTrue: [splitter addRightOrBottom: morph]]]]
]

{ #category : #'resize handling' }
BorderedMorph >> paneMorphs [

	^ self submorphs copyWithoutAll: self splitters
]

{ #category : #'resize handling' }
BorderedMorph >> removeCornerGrips [

	| corners |
	corners := self submorphsSatisfying: [:each | each isKindOf: CornerGripMorph].
	corners do: [:each | each delete]
]

{ #category : #'resize handling' }
BorderedMorph >> removePaneSplitters [

	self splitters do: [:each | each delete]
]

{ #category : #'resize handling' }
BorderedMorph >> splitters [

	^ self submorphsSatisfying: [:each | each isKindOf: ProportionalSplitterMorph]
]

{ #category : #accessing }
BorderedMorph >> useRoundedCorners [
	self cornerStyle: #rounded
]

{ #category : #accessing }
BorderedMorph >> useSquareCorners [
	self cornerStyle: #square
]

{ #category : #'resize handling' }
BorderedMorph >> wantsPaneSplitters [

	^ self valueOfProperty: #allowPaneSplitters ifAbsent: [false]
]

{ #category : #'resize handling' }
BorderedMorph >> wantsPaneSplitters: aBoolean [

	self setProperty: #allowPaneSplitters toValue: aBoolean.
]
