"
This class implements a morph which can behave as four different objects depending on the the following two facts:
- is it OPEN or CLOSED?
- is it SEGMENTED or SMOOTHED.

1. The OPEN and SEGMENTED variant looks like polyline.

2. The OPEN and SMOOTHED variant looks like spline (kind of curve)

3. The CLOSED and SEGMENTED variant looks like polygon. This is actually what you get when you do
	PolygonMorph new openInWorld
You get a triangle. See below how to manipulate these objects...

4. The CLOSED and SMOOTHED variant looks like blob (???)

Prototypes of this morph can also be found in ""Object Catalog"". Several (different variants) of this object are among ""Basic"" morphs.

Explore the assiciated morph-menu. It enables you
- to toggle showing of ""handles"". They make it possible to
	- reposition already existing vertices (by moving yellow handles)
	- create new vertices (by moving green handles)
	- delete already existing vertices (by dragging and dropping one yellow handle closely
	  nearby the adjacent yellow handle
  Handles can be made visible/hidden by shift+leftclicking the morph. This way it is possible
  to quickly show handles, adjust vertices and then again hide handles.
- making closed polygon open, i.e. converting it to a curve (and vice versa)
- toggle smoothed/segmented line/outline
- set up custom dashing (for line, curves or borders of closed polygons
- set up custom arrow-heads (for lines resp. curves)

------------------------------------------------------------------------------------------
Implementation notes:

This class combines the old Polygon and Curve classes.

The 1-bit fillForm to make display and containment tests reasonably fast.  However, this functionality is in the process of being supplanted by balloon capabilities, which should eventually provide anti-aliasing as well.

wiz 7/18/2004 21:26
s have made some changes to this class to

1) correct some bugs associated with one vertex polygons.

2) prepare for some enhancements with new curves.

3) add shaping items to menu.
"
Class {
	#name : #PolygonMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'vertices',
		'closed',
		'filledForm',
		'arrows',
		'arrowForms',
		'smoothCurve',
		'curveState',
		'borderDashSpec',
		'handles',
		'borderForm'
	],
	#category : #'Morphic-Basic'
}

{ #category : #'instance creation' }
PolygonMorph class >> arrowPrototype [
	"Answer an instance of the receiver that will serve as a prototypical arrow"

	| aa |
	aa := self new. 
	aa vertices: (Array with: 0@0 with: 40@40) 
		color: Color black 
		borderWidth: 2 
		borderColor: Color black.
	"aa setProperty: #noNewVertices toValue: true."
	"Revert to expected behavior. Remove vestigial code."
	aa makeForwardArrow.		"is already open"
	aa computeBounds.
	^ aa
]

{ #category : #'parts bin' }
PolygonMorph class >> descriptionForPartsBin [
	^ self partName:	'Polygon' translatedNoop
		categories:		{'Graphics' translatedNoop. 'Basic' translatedNoop}
		documentation:	'A series of connected line segments, which may be a closed solid, or a zig-zag line.  Shift-click to get handles and move the points.' translatedNoop
]

{ #category : #'instance creation' }
PolygonMorph class >> fromHand: hand [
	"Let the user draw a polygon, clicking at each vertex, and ending
		by clicking within 5 of the first point..."
	| p1 poly oldVerts pN opposite |
	Cursor crossHair showWhile:
		[[Sensor anyButtonPressed] whileFalse:
			[self currentWorld displayWorldSafely; runStepMethods].
		p1 := Sensor cursorPoint].
	opposite := (Display colorAt: p1) negated.
	opposite = Color transparent ifTrue: [opposite := Color red].
	(poly := LineMorph from: p1 to: p1 color: opposite width: 2) openInWorld.
	oldVerts := {p1}.
	self currentWorld displayWorldSafely; runStepMethods.
	
	[[Sensor anyButtonPressed] whileTrue:
		[pN := Sensor cursorPoint.
		poly setVertices: (oldVerts copyWith: pN).
		self currentWorld displayWorldSafely; runStepMethods].
	(oldVerts size > 1 and: [(pN dist: p1) < 5]) ifTrue:
		[hand position: Sensor cursorPoint.  "Done -- update hand pos"
		^ (poly setVertices: (poly vertices copyWith: p1)) delete].
	oldVerts := poly vertices.
	[Sensor anyButtonPressed] whileFalse:
		[pN := Sensor cursorPoint.
		poly setVertices: (oldVerts copyWith: pN).
		self currentWorld displayWorldSafely; runStepMethods]] repeat
]

{ #category : #'instance creation' }
PolygonMorph class >> fromHandFreehand: hand [
	"Let the user draw a polygon, holding the mouse down, and ending
		by clicking within 5 of the first point..."
	| p1 poly pN opposite |
	Cursor crossHair showWhile:
		[[Sensor anyButtonPressed] whileFalse:
			[self currentWorld displayWorldSafely; runStepMethods].
		p1 := Sensor cursorPoint].
	opposite := (Display colorAt: p1) negated.
	opposite = Color transparent ifTrue: [opposite := Color red].
	(poly := LineMorph from: p1 to: p1 color: opposite width: 2) openInWorld.
	self currentWorld displayWorldSafely; runStepMethods.
	[Sensor anyButtonPressed] whileTrue:
			[pN := Sensor cursorPoint.
			(pN dist: poly vertices last) > 3 ifTrue:
				[poly setVertices: (poly vertices copyWith: pN).
				self currentWorld displayWorldSafely; runStepMethods]].
	hand position: Sensor cursorPoint.  "Done -- update hand pos"
	^ (poly setVertices: (poly vertices copyWith: p1)) delete
]

{ #category : #'instance creation' }
PolygonMorph class >> shapeFromPen: penBlock color: c borderWidth: bw borderColor: bc [
	"World addMorph: (PolygonMorph
		shapeFromPen: [:p | p hilbert: 4 side: 5. p go: 5.
						p hilbert: 4 side: 5. p go: 5]
		color: Color red borderWidth: 1 borderColor: Color black)"

	| pen |
	penBlock value: (pen := PenPointRecorder new).
	^ (self vertices: pen points asArray color: c borderWidth: bw borderColor: bc)
		quickFill: false
]

{ #category : #'instance creation' }
PolygonMorph class >> vertices: verts color: c borderWidth: bw borderColor: bc [
	^ self basicNew beStraightSegments vertices: verts color: c borderWidth: bw borderColor: bc
]

{ #category : #menu }
PolygonMorph >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add morph-specific items to the given menu which was invoked by the given hand.  This method provides is invoked both from the halo-menu and from the control-menu regimes."

	super addCustomMenuItems: aMenu hand: aHandMorph.
	aMenu addUpdating: #handlesShowingPhrase target: self action: #showOrHideHandles.
	vertices size > 2 ifTrue:
		[aMenu addUpdating: #openOrClosePhrase target: self action: #makeOpenOrClosed].

	aMenu addUpdating: #smoothPhrase target: self action: #toggleSmoothing.
	aMenu addLine.
	aMenu add: 'specify dashed line' translated action:  #specifyDashedLine.

	self isOpen ifTrue:
		[aMenu addLine.
		aMenu addWithLabel: '---' enablement: [self isOpen and: [arrows ~~ #none]] action:  #makeNoArrows.
		aMenu addWithLabel: '-->' enablement: [self isOpen and: [arrows ~~ #forward]] action:  #makeForwardArrow.
		aMenu addWithLabel: '<--' enablement: [self isOpen and: [arrows ~~ #back]] action:  #makeBackArrow.
		aMenu addWithLabel: '<->' enablement: [self isOpen and: [arrows ~~ #both]] action:  #makeBothArrows.
		aMenu add: 'customize arrows' translated action: #customizeArrows:.
		(self hasProperty: #arrowSpec)
			ifTrue: [aMenu add: 'standard arrows' translated action: #standardArrows]].
]

{ #category : #'rotate scale and flex' }
PolygonMorph >> addFlexShellIfNecessary [
	"When scaling or rotating from a halo, I can do this without a flex shell"

	^ self

]

{ #category : #editing }
PolygonMorph >> addHandles [
	"Put moving handles at the vertices. Put adding handles at
	edge midpoints.
	Moving over adjacent vertex and dropping will delete a
	vertex. "
	| tri |
	self removeHandles.
	handles := OrderedCollection new.
	tri := Array
				with: 0 @ -4
				with: 4 @ 3
				with: -3 @ 3.
	vertices
		withIndexDo: [:vertPt :vertIndex | 
			| handle |
			handle := EllipseMorph
						newBounds: (Rectangle center: vertPt extent: 8 @ 8)
						color: (self handleColorAt: vertIndex) .
			handle
				on: #mouseMove
				send: #dragVertex:event:fromHandle:
				to: self
				withValue: vertIndex.
			handle
				on: #mouseUp
				send: #dropVertex:event:fromHandle:
				to: self
				withValue: vertIndex.
				handle
				on: #click
				send: #clickVertex:event:fromHandle:
				to: self
				withValue: vertIndex.
			self addMorph: handle.
			handles addLast: handle.
			(closed
					or: [1 = vertices size
						"Give a small polygon a chance to grow. 
						-wiz"
					or: [vertIndex < vertices size]])
				ifTrue: [| newVert |
					newVert := PolygonMorph
								vertices: (tri
										collect: [:p | p + (vertPt
													+ (vertices atWrap: vertIndex + 1) // 2)])
								color: Color green
								borderWidth: 1
								borderColor: Color black.
					newVert
						on: #mouseDown
						send: #newVertex:event:fromHandle:
						to: self
						withValue: vertIndex.
					self addMorph: newVert.
					handles addLast: newVert]].
	self isCurvy
		ifTrue: [self updateHandles; layoutChanged].
	self changed
]

{ #category : #menu }
PolygonMorph >> addPolyArrowMenuItems: aMenu hand: aHandMorph [ 
aMenu addLine.
			aMenu
				addWithLabel: '---'
				enablement: [self isOpen
						and: [arrows ~~ #none]]
				action: #makeNoArrows.
			aMenu
				addWithLabel: '-->'
				enablement: [self isOpen
						and: [arrows ~~ #forward]]
				action: #makeForwardArrow.
			aMenu
				addWithLabel: '<--'
				enablement: [self isOpen
						and: [arrows ~~ #back]]
				action: #makeBackArrow.
			aMenu
				addWithLabel: '<->'
				enablement: [self isOpen
						and: [arrows ~~ #both]]
				action: #makeBothArrows.
			aMenu add: 'customize arrows' translated action: #customizeArrows:.
			(self hasProperty: #arrowSpec)
				ifTrue: [aMenu add: 'standard arrows' translated action: #standardArrows]
]

{ #category : #menu }
PolygonMorph >> addPolyLIneCurveMenuItems: aMenu hand: aHandMorph [ 

	aMenu addLine;
				addUpdating: #openOrClosePhrase
				target: self
				action: #makeOpenOrClosed.
			
			aMenu
				addUpdating: #smoothOrSegmentedPhrase
				target: self
				action: #toggleSmoothing.
]

{ #category : #menu }
PolygonMorph >> addPolyShapingMenuItems: aMenu hand: aHandMorph [ 
	aMenu addLine.
			aMenu
				addWithLabel: 'make inscribed diamondOval'
				enablement: [self isClosed ]
				action: #diamondOval.
			aMenu
				addWithLabel: 'make enclosing rectangleOval'
				enablement: [self isClosed ]
					action: #rectOval.
					
]

{ #category : #drawing }
PolygonMorph >> areasRemainingToFill: aRectangle [
	"Could be improved by quick check of inner rectangle"

	^ Array with: aRectangle
]

{ #category : #private }
PolygonMorph >> arrowBoundsAt: endPoint from: priorPoint [ 
	"Answer a triangle oriented along the line from priorPoint to endPoint."
	| d v angle wingBase arrowSpec length width |
	v := endPoint - priorPoint.
	angle := v degrees.
	d := self borderWidth max: 1.
	arrowSpec := self valueOfProperty: #arrowSpec ifAbsent: [5@4].
	length := arrowSpec x abs.  width := arrowSpec y abs.
	wingBase := endPoint + (Point r: d * length degrees: angle + 180.0).
	arrowSpec x >= 0
		ifTrue: [^ {	endPoint.
					wingBase + (Point r: d * width degrees: angle + 125.0).
					wingBase + (Point r: d * width degrees: angle - 125.0) }]
		ifFalse: ["Negative length means concave base."
				^ {	endPoint.
					wingBase + (Point r: d * width degrees: angle + 125.0).
					wingBase.
					wingBase + (Point r: d * width degrees: angle - 125.0) }]
]

{ #category : #private }
PolygonMorph >> arrowForms [
	"ArrowForms are computed only upon demand"
	arrowForms
		ifNotNil: [^ arrowForms].
	arrowForms := Array new.
	self hasArrows
		ifFalse: [^ arrowForms].
	(arrows == #forward
			or: [arrows == #both])
		ifTrue: [arrowForms := arrowForms
						copyWith: (self computeArrowFormAt: vertices last from: self nextToLastPoint)].
	(arrows == #back
			or: [arrows == #both])
		ifTrue: [arrowForms := arrowForms
						copyWith: (self computeArrowFormAt: vertices first from: self nextToFirstPoint)].
	^ arrowForms
]

{ #category : #menu }
PolygonMorph >> arrowLength: aLength [
	"Assumes that I have exactly two vertices"

	| theta horizontalOffset verticalOffset newTip delta |
	delta := vertices second - vertices first.
	theta := delta theta.
	horizontalOffset := aLength * (theta cos).
	verticalOffset := aLength * (theta sin).
	newTip := vertices first + (horizontalOffset @ verticalOffset).
	self verticesAt: 2 put: newTip
]

{ #category : #menu }
PolygonMorph >> arrowSpec: specPt [
	"Specify a custom arrow for this line.
	specPt x abs gives the length of the arrow (point to base) in terms of borderWidth.
	If specPt x is negative, then the base of the arrow will be concave.
	specPt y abs gives the width of the arrow.
	The standard arrow is equivalent to arrowSpec: 5@4.
	See arrowBoundsAt:From: for details."

	self setProperty: #arrowSpec toValue: specPt.
	self computeBounds
]

{ #category : #menu }
PolygonMorph >> arrows [
	^arrows
]

{ #category : #geometry }
PolygonMorph >> arrowsContainPoint: aPoint [
	"Answer an Array of two Booleans that indicate whether the given point is inside either arrow"

	| retval f |

	retval := { false . false }.
	(super containsPoint: aPoint) ifFalse: [^ retval ].
	(closed or: [arrows == #none or: [vertices size < 2]]) ifTrue: [^ retval].

	(arrows == #forward or: [arrows == #both]) ifTrue: [	"arrowForms first has end form"
		f := self arrowForms first.
		retval at: 2 put: ((f pixelValueAt: aPoint - f offset) > 0)
	].
	(arrows == #back or: [arrows == #both]) ifTrue: [ "arrowForms last has start form"
		f := self arrowForms last.
		retval at: 1 put: ((f pixelValueAt: aPoint - f offset) > 0)
	].
	^retval.
]

{ #category : #initialization }
PolygonMorph >> beSmoothCurve [

	smoothCurve == true ifFalse:
		[smoothCurve := true.
		self computeBounds]
]

{ #category : #initialization }
PolygonMorph >> beStraightSegments [

	smoothCurve == false ifFalse:
		[smoothCurve := false.
		self computeBounds]
]

{ #category : #accessing }
PolygonMorph >> borderColor: aColor [ 
	"Recompute fillForm and borderForm if translucency of border changes."
	
	super borderColor: aColor.

	(self borderColor isColor and: [self borderColor isTranslucentColor]) 
		== (aColor isColor and: [aColor isTranslucentColor]) 
			ifFalse: [self releaseCachedState]
]

{ #category : #dashes }
PolygonMorph >> borderDashOffset [
	borderDashSpec size < 4 ifTrue: [^0.0].
	^(borderDashSpec fourth) asFloat
]

{ #category : #accessing }
PolygonMorph >> borderDashSpec [
	^ borderDashSpec
]

{ #category : #private }
PolygonMorph >> borderForm [
	"A form must be created for drawing the border whenever the borderColor is translucent."

	| borderCanvas |
	borderForm ifNotNil: [^ borderForm].
	borderCanvas := (Display defaultCanvasClass extent: bounds extent depth: 1)
		shadowColor: Color black.
	borderCanvas translateBy: bounds topLeft negated
		during:[:tempCanvas| self drawBorderOn: tempCanvas].
	borderForm := borderCanvas form.
	self arrowForms do:
		[:f |  "Eliminate overlap between line and arrowheads if transparent."
		borderForm copy: f boundingBox from: f to: f offset - self position rule: Form erase].
	^ borderForm
]

{ #category : #accessing }
PolygonMorph >> borderStyle: aBorderStyle [

	super borderStyle: aBorderStyle.
	self computeBounds
]

{ #category : #accessing }
PolygonMorph >> borderWidth: anInteger [

	super borderWidth: anInteger.
	self computeBounds
]

{ #category : #geometry }
PolygonMorph >> bounds: newBounds [
	"This method has to be reimplemented since self extent: will also change self bounds origin,
	super bounds would leave me in wrong position when container is growing.
	Always change extent first then position"
	
	self extent: newBounds extent; position: newBounds topLeft

]

{ #category : #attachments }
PolygonMorph >> boundsSignatureHash [
	^(vertices - (self positionInWorld))  hash

]

{ #category : #'visual properties' }
PolygonMorph >> canHaveFillStyles [
	"Return true if the receiver can have general fill styles; not just colors.
	This method is for gradually converting old morphs."
	^true
]

{ #category : #editing }
PolygonMorph >> clickVertex: ix event: evt fromHandle: handle [
	"Backstop for MixedCurveMorph"
]

{ #category : #geometry }
PolygonMorph >> closestPointTo: aPoint [ 
	| closestPoint minDist |
	closestPoint := minDist := nil.
	self lineSegmentsDo: 
			[:p1 :p2 | | dist curvePoint | 
			curvePoint := aPoint nearestPointOnLineFrom: p1 to: p2.
			dist := curvePoint dist: aPoint.
			(closestPoint isNil or: [dist < minDist]) 
				ifTrue: 
					[closestPoint := curvePoint.
					minDist := dist]].
	^closestPoint
]

{ #category : #geometry }
PolygonMorph >> closestSegmentTo: aPoint [
	"Answer the starting index of my (big) segment nearest to aPoint"
	| closestPoint minDist vertexIndex closestVertexIndex |
	vertexIndex := 0.
	closestVertexIndex := 0.
	closestPoint := minDist := nil.
	self lineSegmentsDo:
		[:p1 :p2 | | dist curvePoint | 
		(p1 = (self vertices at: vertexIndex + 1))
			ifTrue: [ vertexIndex := vertexIndex + 1 ].
		curvePoint := aPoint nearestPointOnLineFrom: p1 to: p2.
		dist := curvePoint dist: aPoint.
		(closestPoint == nil or: [dist < minDist])
			ifTrue: [closestPoint := curvePoint.
					minDist := dist.
					closestVertexIndex := vertexIndex. ]].
	^ closestVertexIndex
]

{ #category : #smoothing }
PolygonMorph >> coefficients [
	"Compute an array for the coefficients."
	| verts vertXs vertYs slopeXs slopeYs coefficients |
	curveState
		ifNotNil: [^ curveState at: 1].
	verts := self vertices.
	verts size < 1
		ifTrue: [^ self].
	"Less than three points handled as segments by our 
	lineSegmentsDo:"
	(self isCurvier)
		ifFalse: [closed
				ifTrue: [verts := verts , verts first asOrderedCollection]].
	coefficients := {
		vertXs := verts collect: [:p | p x asFloat].
		slopeXs := self slopes: vertXs.
		vertXs changeInSlopes: slopeXs.
		vertXs changeOfChangesInSlopes: slopeXs.
		vertYs := verts collect: [:p | p y asFloat].
		slopeYs := self slopes: vertYs.
		vertYs changeInSlopes: slopeYs.
		vertYs changeOfChangesInSlopes: slopeYs.
		Array new: verts size withAll: 12}.
	coefficients
		at: 9
		put: ((1 to: verts size)
				collect: [:i | (coefficients cubicPointPolynomialAt: i) bestSegments]).
	(self isCurvier)
		ifFalse: [closed
				ifTrue: [coefficients := coefficients
								collect: [:each | each allButLast]]].
	curveState := {coefficients. nil. nil}.
	self computeNextToEndPoints.
	^ coefficients
]

{ #category : #private }
PolygonMorph >> computeArrowFormAt: endPoint from: priorPoint [ 
	"Compute a triangle oriented along the line from priorPoint to  
	endPoint. Then draw those lines in a form and return that  
	form, with appropriate offset"

	| p1 pts box arrowForm bb origin |
	pts := self arrowBoundsAt: endPoint from: priorPoint.
	box := ((pts first rect: pts last) encompass: (pts second)) expandBy: 1.
	arrowForm := Form extent: box extent asIntegerPoint.
	bb := (BitBlt toForm: arrowForm)
				sourceForm: nil;
				fillColor: Color black;
				combinationRule: Form over;
				width: 1;
				height: 1.
	origin := box topLeft.
	p1 := pts last - origin.
	pts do: 
			[:p | 
			bb drawFrom: p1 to: p - origin.
			p1 := p - origin].
	arrowForm convexShapeFill: Color black.
	^arrowForm offset: box topLeft
]

{ #category : #private }
PolygonMorph >> computeBounds [
	| oldBounds delta excludeHandles |
	
	self flag: #refactor. "mt: Make it lazy like all layout policies in Morph. See #fullBounds and #doLayoutIn:."
	
	vertices ifNil: [^ self].

	self changed.
	oldBounds := bounds.
	self releaseCachedState.
	bounds := self curveBounds expanded copy.
	self arrowForms do:
		[:f | bounds swallow: (f offset extent: f extent)].
	handles ifNotNil: [self updateHandles].

	"since we are directly updating bounds, see if any ordinary submorphs exist and move them accordingly"
	(oldBounds notNil and: [(delta := bounds origin - oldBounds origin) ~= (0@0)]) ifTrue: [
		excludeHandles := IdentitySet new.
		handles ifNotNil: [excludeHandles addAll: handles].
		self submorphsDo: [ :each |
			(excludeHandles includes: each) ifFalse: [
				each position: each position + delta
			].
		].
	].
	self layoutChanged.
	self changed.

]

{ #category : #smoothing }
PolygonMorph >> computeNextToEndPoints [
	| pointAfterFirst pointBeforeLast |
	pointAfterFirst := nil.
	self lineSegmentsDo: 
			[:p1 :p2 | 
			pointAfterFirst ifNil: [pointAfterFirst := p2 asIntegerPoint].
			pointBeforeLast := p1 asIntegerPoint].
	curveState at: 2 put: pointAfterFirst.
	curveState at: 3 put: pointBeforeLast
]

{ #category : #'geometry testing' }
PolygonMorph >> containsPoint: aPoint [
	(super containsPoint: aPoint) ifFalse: [^ false].

	closed & color isTransparent not ifTrue:
		[^ (self filledForm pixelValueAt: aPoint - self topLeft + 1) > 0].

	self lineSegmentsDo:
		[:p1 :p2 |
		(aPoint onLineFrom: p1 to: p2 within: (3 max: self borderWidth+1//2) asFloat)
				ifTrue: [^ true]].

	self arrowForms do:
		[:f | (f pixelValueAt: aPoint - f offset) > 0 ifTrue: [^ true]].

	^ false
]

{ #category : #'objects from disk' }
PolygonMorph >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	smoothCurve ifNil: [smoothCurve := false].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #rounding }
PolygonMorph >> cornerStyle: aSymbol [ 
	"Set the receiver's corner style.  But, in this case, do *not*"

	self removeProperty: #cornerStyle.
	self changed
]

{ #category : #accessing }
PolygonMorph >> couldHaveRoundedCorners [
	^ false
]

{ #category : #private }
PolygonMorph >> curveBounds [
	"Compute the bounds from actual curve traversal, with 
	leeway for borderWidth. 
	Also note the next-to-first and next-to-last points for arrow 
	directions."
	"wiz - to avoid roundoff errors we return unrounded curvebounds."
	"we expect our receiver to take responsibility for approriate rounding adjustment."
	"hint: this is most likely 'self curveBounds expanded' "
	| pointAfterFirst pointBeforeLast  oX oY cX cY |
	self isCurvy
		ifFalse: [^ (Rectangle encompassing: vertices)
				expandBy: self borderWidth * 0.5 ].
	curveState := nil.
	"Force recomputation"
	"curveBounds := vertices first corner: vertices last."
	pointAfterFirst := nil.
	self
		lineSegmentsDo: [:p1 :p2 | 
			pointAfterFirst isNil
				ifTrue: [pointAfterFirst := p2 floor .
					oX := cX := p1 x.
					oY := cY := p1 y. ].
			"curveBounds := curveBounds encompass: p2 ."
			oX:= oX min: p2 x.
			cX := cX max: p2 x.
			oY := oY min: p2 y.
			cY := cY max: p2 y.
			pointBeforeLast := p1 floor ].
	curveState at: 2 put: pointAfterFirst.
	curveState at: 3 put: pointBeforeLast.
	^ ( oX @ oY corner: cX @ cY )  expandBy: self borderWidth * 0.5 
]

{ #category : #menu }
PolygonMorph >> customizeArrows: evt [
	| handle origin aHand |
	aHand := evt ifNil: [self primaryHand] ifNotNil: [evt hand].
	origin := aHand position.
	(handle := HandleMorph new)
		forEachPointDo:
			[:newPoint | handle removeAllMorphs.
			handle addMorph:
				(LineMorph from: origin to: newPoint color: Color black width: 1).
			self arrowSpec: (newPoint - origin) / 5.0]
		lastPointDo:
			[:newPoint | handle deleteBalloon.
			self halo ifNotNil: [:halo | halo addHandles].].
	aHand attachMorph: handle.
	handle setProperty: #helpAtCenter toValue: true.
	handle showBalloon:
'Move cursor left and right
to change arrow length and style.
Move it up and down to change width.
Click when done.' hand: evt hand.
	handle startStepping
]

{ #category : #dashes }
PolygonMorph >> dashedBorder [
	^borderDashSpec
	"A dash spec is a 3- or 5-element array with
		{ length of normal border color.
		length of alternate border color.
		alternate border color.
		starting offset.
		amount to add to offset at each step }
	Starting offset is usually = 0, but changing it moves the dashes along the curve."

]

{ #category : #dashes }
PolygonMorph >> dashedBorder: dashSpec [
	"A dash spec is a 3- or 5-element array with
		{ length of normal border color.
		length of alternate border color.
		alternate border color.
		starting offset.
		amount to add to offset at each step }
	Starting offset is usually = 0, but changing it moves the dashes along the curve."

	borderDashSpec := dashSpec.
	self changed
]

{ #category : #attachments }
PolygonMorph >> defaultAttachmentPointSpecs [
	^{ 
		{ #firstVertex } .
		{ #midpoint  } .
		{ #lastVertex }
	}
]

{ #category : #initialization }
PolygonMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"

	^ Color black

"Until September 2007, this had long been...
	^ Color
		r: 0.0
		g: 0.419
		b: 0.935"
]

{ #category : #initialization }
PolygonMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color orange
]

{ #category : #editing }
PolygonMorph >> deleteVertexAt: anIndex [
	"This acts as a backstop for MixedCurveMorph."
			self
				setVertices: (vertices
						copyReplaceFrom: anIndex
						to: anIndex
						with: Array new).
						
]

{ #category : #smoothing }
PolygonMorph >> derivs: a first: point1 second: point2 third: point3 [ 
	"Compute the first, second and third derivitives (in coeffs) from
	the Points in this Path (coeffs at: 1 and coeffs at: 5)."

	| len v anArray |
	len := a size.
	len < 2 ifTrue: [^self].
	len > 2 
		ifTrue: 
			[v := Array new: len.
			v at: 1 put: 4.0.
			anArray := Array new: len.
			anArray at: 1 put: 6.0 * (a first - (a second * 2.0) + (a third)).
			2 to: len - 2
				do: 
					[:i | 
					v at: i put: 4.0 - (1.0 / (v at: i - 1)).
					anArray at: i
						put: 6.0 * ((a at: i) - ((a at: i + 1) * 2.0) + (a at: i + 2)) 
								- ((anArray at: i - 1) / (v at: i - 1))].
			point2 at: len - 1 put: (anArray at: len - 2) / (v at: len - 2).
			len - 2 to: 2
				by: 0 - 1
				do: 
					[:i | 
					point2 at: i
						put: ((anArray at: i - 1) - (point2 at: i + 1)) / (v at: i - 1)]].
	point2 at: 1 put: (point2 at: len put: 0.0).
	1 to: len - 1
		do: 
			[:i | 
			point1 at: i
				put: (a at: i + 1) - (a at: i) 
						- (((point2 at: i) * 2.0 + (point2 at: i + 1)) / 6.0).
			point3 at: i put: (point2 at: i + 1) - (point2 at: i)]
]

{ #category : #shaping }
PolygonMorph >> diamondOval [
	"Set my vertices to an array of edge midpoint vertices. 
	Order of vertices is in the tradion of warpblt quads."
	| b r |
	b := self bounds.
	r := {b leftCenter. b bottomCenter. b rightCenter. b topCenter}.
	self setVertices: r
]

{ #category : #editing }
PolygonMorph >> dragVertex: ix event: evt fromHandle: handle [
	| p |
	p := self isCurve
		ifTrue: [evt cursorPoint]
		ifFalse: [self griddedPoint: evt cursorPoint].
	handle position: p - (handle extent//2).
	self verticesAt: ix put: p.

]

{ #category : #editing }
PolygonMorph >> dragVertex: arg1 fromHandle: arg2 vertIndex: arg3 [
	"Reorder the arguments for existing event handlers"
	(arg3 isMorph and:[arg3 eventHandler notNil]) ifTrue:[arg3 eventHandler fixReversedValueMessages].
	^self dragVertex: arg1 event: arg2 fromHandle: arg3
]

{ #category : #drawing }
PolygonMorph >> drawArrowOn: aCanvas at: endPoint from: priorPoint [ 
	"Draw a triangle oriented along the line from priorPoint to  
	endPoint. Answer the wingBase."

	| pts spec wingBase |
	pts := self arrowBoundsAt: endPoint from: priorPoint.
	wingBase := pts size = 4 
				ifTrue: [pts third]
				ifFalse: [(pts copyFrom: 2 to: 3) average].
	spec := self valueOfProperty: #arrowSpec ifAbsent: [5 @ 4].
	spec x sign = spec y sign 
		ifTrue: [aCanvas drawPolygon: pts fillStyle: self borderColor]
		ifFalse: 
			[aCanvas 
				drawPolygon: pts
				fillStyle: Color transparent
				borderWidth: (self borderWidth + 1) // 2
				borderColor: self borderColor].
	^wingBase
]

{ #category : #drawing }
PolygonMorph >> drawArrowsOn: aCanvas [ 
	"Answer (possibly modified) endpoints for border drawing"
	"ArrowForms are computed only upon demand"
	| array |

	self hasArrows
		ifFalse: [^ #() ].
	"Nothing to do"

	array := Array with: vertices first with: vertices last.

	"Prevent crashes for #raised or #inset borders"
	self borderColor isColor
		ifFalse: [ ^array ].

	(arrows == #forward or: [arrows == #both])
		ifTrue: [ array at: 2 put: (self
				drawArrowOn: aCanvas
				at: vertices last
				from: self nextToLastPoint) ].

	(arrows == #back or: [arrows == #both])
		ifTrue: [ array at: 1 put: (self
				drawArrowOn: aCanvas
				at: vertices first
				from: self nextToFirstPoint) ].

	^array
]

{ #category : #drawing }
PolygonMorph >> drawBorderOn: aCanvas [ 
	self
		drawClippedBorderOn: aCanvas
		usingEnds: (Array with: vertices first with: vertices last)
]

{ #category : #drawing }
PolygonMorph >> drawBorderOn: aCanvas usingEnds: anArray [ 
	"Display my border on the canvas."
	"NOTE: Much of this code is also copied in  
	drawDashedBorderOn:  
	(should be factored)"
	| bigClipRect style |
	borderDashSpec
		ifNotNil: [^ self drawDashedBorderOn: aCanvas usingEnds: anArray].
	style := self borderStyle.
	bigClipRect := aCanvas clipRect expandBy: self borderWidth + 1 // 2.
	self
		lineSegmentsDo: [:p1 :p2 | | p2i p1i | 
			p1i := p1 asIntegerPoint.
			p2i := p2 asIntegerPoint.
			self hasArrows
				ifTrue: ["Shorten line ends so as not to interfere with tip  
					of arrow."
					((arrows == #back
								or: [arrows == #both])
							and: [p1 = vertices first])
						ifTrue: [p1i := anArray first asIntegerPoint].
					((arrows == #forward
								or: [arrows == #both])
							and: [p2 = vertices last])
						ifTrue: [p2i := anArray last asIntegerPoint]].
			(closed
					or: ["bigClipRect intersects: (p1i rect: p2i)  
						optimized:"
						((p1i min: p2i)
							max: bigClipRect origin)
							<= ((p1i max: p2i)
									min: bigClipRect corner)])
				ifTrue: [style
						drawLineFrom: p1i
						to: p2i
						on: aCanvas]]
]

{ #category : #drawing }
PolygonMorph >> drawClippedBorderOn: aCanvas usingEnds: anArray [ 
	aCanvas clipBy: self bounds during:[:cc| self drawBorderOn: cc usingEnds: anArray].
]

{ #category : #drawing }
PolygonMorph >> drawDashedBorderOn: aCanvas [ 
	self
		drawDashedBorderOn: aCanvas
		usingEnds: (Array with: vertices first with: vertices last)
]

{ #category : #drawing }
PolygonMorph >> drawDashedBorderOn: aCanvas usingEnds: anArray [ 
	"Display my border on the canvas. NOTE: mostly copied from  
	drawBorderOn:"
	| bevel topLeftColor bottomRightColor bigClipRect lineColor segmentOffset |
	(self borderColor isNil
			or: [self borderColor isColor
					and: [self borderColor isTransparent]])
		ifTrue: [^ self].
	lineColor := self borderColor.
	bevel := false.
	"Border colors for bevelled effects depend on CW ordering of  
	vertices"
	self borderStyle style == #raised
		ifTrue: [topLeftColor := self color lighter.
			bottomRightColor := self color darker.
			bevel := true].
	self borderStyle style == #inset
		ifTrue: [topLeftColor := owner colorForInsets darker.
			bottomRightColor := owner colorForInsets lighter.
			bevel := true].
	bigClipRect := aCanvas clipRect expandBy: self borderWidth + 1 // 2.
	segmentOffset := self borderDashOffset.
	self
		lineSegmentsDo: [:p1 :p2 | | p1i p2i | 
			p1i := p1 asIntegerPoint.
			p2i := p2 asIntegerPoint.
			self hasArrows
				ifTrue: ["Shorten line ends so as not to interfere with tip  
					of arrow."
					((arrows == #back
								or: [arrows == #both])
							and: [p1 = vertices first])
						ifTrue: [p1i := anArray first asIntegerPoint].
					((arrows == #forward
								or: [arrows == #both])
							and: [p2 = vertices last])
						ifTrue: [p2i := anArray last asIntegerPoint]].
			(closed
					or: ["bigClipRect intersects: (p1i rect: p2i)  
						optimized:"
						((p1i min: p2i)
							max: bigClipRect origin)
							<= ((p1i max: p2i)
									min: bigClipRect corner)])
				ifTrue: [bevel
						ifTrue: [lineColor := (p1i quadrantOf: p2i)
											> 2
										ifTrue: [topLeftColor]
										ifFalse: [bottomRightColor]].
					segmentOffset := aCanvas
								line: p1i
								to: p2i
								width: self borderWidth
								color: lineColor
								dashLength: self borderDashSpec first
								secondColor: self borderDashSpec third
								secondDashLength: self borderDashSpec second
								startingOffset: segmentOffset]]
]

{ #category : #drawing }
PolygonMorph >> drawOn: aCanvas [ 
	"Display the receiver, a spline curve, approximated by straight 
	line segments."
	| array |
	vertices size < 1
		ifTrue: [self error: 'a polygon must have at least one point'].
	closed ifTrue:
		[aCanvas drawPolygon: self getVertices fillStyle: self fillStyle.
		aCanvas isShadowDrawing ifTrue: [^ self]].
	array := self drawArrowsOn: aCanvas.
	self drawClippedBorderOn: aCanvas usingEnds: array.

]

{ #category : #drawing }
PolygonMorph >> drawOnFormCanvas: aCanvas [ 
	"Display the receiver, a spline curve, approximated by straight line segments."

	| |
	vertices size < 1 ifTrue: [self error: 'a polygon must have at least one point'].
	closed & color isTransparent not
		ifTrue: [aCanvas stencil: self filledForm at: self bounds topLeft - 1 color: self color].
	(self borderColor isColor and: [self borderColor isTranslucentColor])
		ifTrue: [aCanvas stencil: self borderForm at: self bounds topLeft
						color: self borderColor]
		ifFalse: [self drawBorderOn: aCanvas].
	self arrowForms do:
		[:f | aCanvas stencil: f at: f offset
			color: (self borderColor isColor ifTrue: [self borderColor] ifFalse: [self color])]
]

{ #category : #editing }
PolygonMorph >> dropVertex: ix event: evt fromHandle: handle [
	"Leave vertex in new position. If dropped ontop another vertex delete this one.
	Check for too few vertices before deleting. The alternative 
				is not pretty -wiz"
	| p |
	p := vertices at: ix.
	(vertices size >= 2
			and: ["check for too few vertices before deleting. The alternative 
				is not pretty -wiz"
				((vertices atWrap: ix - 1)
						dist: p)
						< 3
					or: [((vertices atWrap: ix + 1)
							dist: p)
							< 3]])
		ifTrue: ["Drag a vertex onto its neighbor means delete"
				self deleteVertexAt: ix .].
	evt shiftPressed
		ifTrue: [self removeHandles]
		ifFalse: [self addHandles
			"remove then add to recreate"]
]

{ #category : #editing }
PolygonMorph >> dropVertex: arg1 fromHandle: arg2 vertIndex: arg3 [
	"Reorder the arguments for existing event handlers"
	(arg3 isMorph and:[arg3 eventHandler notNil]) ifTrue:[arg3 eventHandler fixReversedValueMessages].
	^self dropVertex: arg1 event: arg2 fromHandle: arg3
]

{ #category : #attachments }
PolygonMorph >> endShapeColor: aColor [
	self borderColor: aColor.
	self isClosed ifTrue: [ self color: aColor ].
]

{ #category : #attachments }
PolygonMorph >> endShapeWidth: aWidth [
	| originalWidth originalVertices transform |
	originalWidth := self valueOfProperty: #originalWidth ifAbsentPut: [ self borderWidth isZero ifFalse: [ self borderWidth ] ifTrue: [ 2 ] ].
	self borderWidth: aWidth.
	originalVertices := self valueOfProperty: #originalVertices ifAbsentPut: [
		self vertices collect: [ :ea | (ea - (self referencePosition)) rotateBy: self heading degreesToRadians about: 0@0 ]
	].
	transform := MorphicTransform offset: 0@0 angle: self heading degreesToRadians scale: originalWidth / aWidth.
	self setVertices: (originalVertices collect: [ :ea |
		((transform transform: ea) + self referencePosition) asIntegerPoint
	]).
	self computeBounds.
]

{ #category : #geometry }
PolygonMorph >> extent: newExtent [ 
	"Not really advisable, but we can preserve most of the geometry if we don't
	shrink things too small."
	| safeExtent center |
	center := self referencePosition.
	safeExtent := newExtent max: 20@20.
	self setVertices: (vertices collect:
		[:p | p - center * (safeExtent asFloatPoint / (bounds extent max: 1@1)) + center])
]

{ #category : #'visual properties' }
PolygonMorph >> fillStyle [
	"Answer the receiver's fillStyle.  For an *open* polygon, we return the borderColor, provided it's a true color rather than something strange like the symbol #raised."

	| aColor |
	self isOpen
		ifTrue:
			[(aColor := self borderColor) isColor ifTrue: [^ aColor]].   "easy access to line color from halo -- di's old note"
	
	^ super fillStyle
]

{ #category : #'visual properties' }
PolygonMorph >> fillStyle: newColor [

	self isOpen
		ifTrue: [^ self borderColor: newColor asColor "easy access to line color from halo"]
		ifFalse: [^ super fillStyle: newColor]
]

{ #category : #private }
PolygonMorph >> filledForm [
	"Note: The filled form is actually 2 pixels bigger than bounds, and the point corresponding to this morphs' position is at 1@1 in the form.  This is due to the details of the fillig routines, at least one of which requires an extra 1-pixel margin around the outside.  Computation of the filled form is done only on demand."
	| bb origin |
	closed ifFalse: [^ filledForm := nil].
	filledForm ifNotNil: [^ filledForm].
	filledForm := Form extent: bounds extent+2.

	"Draw the border..."
	bb := (BitBlt toForm: filledForm) sourceForm: nil; fillColor: Color black;
			combinationRule: Form over; width: 1; height: 1.
	origin := bounds topLeft asIntegerPoint-1.
	self lineSegmentsDo: [:p1 :p2 | bb drawFrom: p1 asIntegerPoint-origin
										to: p2 asIntegerPoint-origin].

	"Fill it in..."
	filledForm convexShapeFill: Color black.

	(self borderColor isColor and: [self borderColor isTranslucentColor]) ifTrue:
		["If border is stored as a form, then erase any overlap now."
		filledForm copy: self borderForm boundingBox from: self borderForm
			to: 1@1 rule: Form erase].

	^ filledForm
]

{ #category : #attachments }
PolygonMorph >> firstVertex [
	^vertices first
]

{ #category : #geometry }
PolygonMorph >> flipHAroundX: centerX [
	"Flip me horizontally around the center.  If centerX is nil, compute my center of gravity."

	| cent |
	cent := centerX 
		ifNil: [bounds center x
			"cent := 0.
			vertices do: [:each | cent := cent + each x].
			cent asFloat / vertices size"]		"average is the center"
		ifNotNil: [centerX].
	self setVertices: (vertices collect: [:vv |
			((vv x - cent) * -1 + cent) @ vv y]) reversed.
]

{ #category : #geometry }
PolygonMorph >> flipVAroundY: centerY [
	"Flip me vertically around the center.  If centerY is nil, compute my center of gravity."

	| cent |
	cent := centerY 
		ifNil: [bounds center y
			"cent := 0.
			vertices do: [:each | cent := cent + each y].
			cent asFloat / vertices size"]		"average is the center"
		ifNotNil: [centerY].
	self setVertices: (vertices collect: [:vv |
			vv x @ ((vv y - cent) * -1 + cent)]) reversed.
]

{ #category : #private }
PolygonMorph >> getVertices [

	smoothCurve ifFalse: [^ vertices].

	"For curves, enumerate the full set of interpolated points"
	^ Array streamContents:
		[:s | self lineSegmentsDo: [:pt1 :pt2 | s nextPut: pt1]]
]

{ #category : #editing }
PolygonMorph >> handleColorAt: vertIndex [
      "This is a backstop for MixedCurveMorph"

^ Color yellow

]

{ #category : #'event handling' }
PolygonMorph >> handlesMouseDown: evt [

	^ (super handlesMouseDown: evt) or: [evt shiftPressed]
]

{ #category : #menu }
PolygonMorph >> handlesShowingPhrase [
	"Answer a phrase characterizing whether handles are showing or not."

	^ (self showingHandles ifTrue: ['<yes>'] ifFalse: ['<no>']), ('show handles' translated)
]

{ #category : #testing }
PolygonMorph >> hasArrows [
	"Are all the conditions meet for having arrows?"
	^ (closed
		or: [arrows == #none
				or: [vertices size < 2]]) not
]

{ #category : #'rotate scale and flex' }
PolygonMorph >> heading [
	"Overwritten to store the angle in #forwardDirection."

	^ self rotationDegrees
]

{ #category : #'rotate scale and flex' }
PolygonMorph >> heading: newHeading [
	"Overwritten to store the angle in #forwardDirection."

	self rotationDegrees: newHeading.
]

{ #category : #private }
PolygonMorph >> includesHandle: aMorph [

	handles ifNil: [^ false].
	^ handles includes: aMorph
]

{ #category : #initialization }
PolygonMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	vertices := Array
				with: 5 @ 0
				with: 20 @ 10
				with: 0 @ 20.
	closed := true.
	smoothCurve := false.
	arrows := #none.
	self computeBounds
]

{ #category : #editing }
PolygonMorph >> insertVertexAt: anIndex put: aValue [
	"This serves as a hook and a backstop for MixedCurveMorph."
	self setVertices: (vertices copyReplaceFrom: anIndex + 1 to: anIndex 
									with: (Array with: aValue)).
]

{ #category : #'debug and other' }
PolygonMorph >> installModelIn: aWorld [
	aWorld isWorldMorph ifTrue: [self addHandles]
]

{ #category : #geometry }
PolygonMorph >> intersectionWithLineSegmentFromCenterTo: aPoint [ 
	^self closestPointTo: aPoint
]

{ #category : #geometry }
PolygonMorph >> intersectionsWith: aRectangle [
	"Answer a Set of points where the given Rectangle intersects with me.
	Ignores arrowForms."

	| retval |
	retval := IdentitySet new: 4.
	(self bounds intersects: aRectangle) ifFalse: [^ retval].

	self lineSegmentsDo: [ :lp1 :lp2 | | polySeg |
		polySeg := LineSegment from: lp1 to: lp2.
		aRectangle lineSegmentsDo: [ :rp1 :rp2 | | rectSeg int |
			rectSeg := LineSegment from: rp1 to: rp2.
			int := polySeg intersectionWith: rectSeg.
			int ifNotNil: [ retval add: int ].
		].
	].

	^retval

]

{ #category : #geometry }
PolygonMorph >> intersects: aRectangle [ 
	"Answer whether any of my segments intersects aRectangle, which is in World coordinates."
	| rect |
	(super intersects: aRectangle) ifFalse: [ ^false ].
	rect := self bounds: aRectangle in: self world.
	self
		lineSegmentsDo: [:p1 :p2 | (rect intersectsLineFrom: p1 to: p2)
				ifTrue: [^ true]].
	^ false
]

{ #category : #geometry }
PolygonMorph >> isBordered [
	^false
]

{ #category : #access }
PolygonMorph >> isClosed [
	^ closed
]

{ #category : #access }
PolygonMorph >> isCurve [
	^ smoothCurve
]

{ #category : #testing }
PolygonMorph >> isCurvier [
	"Test used by smoothing routines.  If true use true closed curve splines for closed curves. If not mimic old stodgy curveMorph curves with one sharp bend.. Override this routine in classes where backward compatability is still needed."
	^ CurvierMorph drawCurvier
]

{ #category : #testing }
PolygonMorph >> isCurvy [
	"Test for significant curves.  
	Small smoothcurves in practice are straight."
	^ smoothCurve
		and: [vertices size > 2]
]

{ #category : #testing }
PolygonMorph >> isLineMorph [
	^closed not
]

{ #category : #access }
PolygonMorph >> isOpen [
	^ closed not
]

{ #category : #'dropping\/grabbing' }
PolygonMorph >> justDroppedInto: newOwner event: evt [

	| delta |
	(newOwner isKindOf: PasteUpMorph) ifTrue:
		["Compensate for border width so that gridded drop
			is consistent with gridded drag of handles."
		delta := self borderWidth+1//2.
		self position: (newOwner gridPoint: self position + delta) - delta].
	^ super justDroppedInto: newOwner event: evt
]

{ #category : #attachments }
PolygonMorph >> lastVertex [
	^vertices last
]

{ #category : #geometry }
PolygonMorph >> lineBorderColor [
	^self borderColor
]

{ #category : #geometry }
PolygonMorph >> lineBorderColor: aColor [
	self borderColor: aColor
]

{ #category : #geometry }
PolygonMorph >> lineBorderWidth [

	^self borderWidth
]

{ #category : #geometry }
PolygonMorph >> lineBorderWidth: anInteger [

	self borderWidth: anInteger
]

{ #category : #geometry }
PolygonMorph >> lineColor [
	^self borderColor
]

{ #category : #geometry }
PolygonMorph >> lineColor: aColor [
	self borderColor: aColor
]

{ #category : #private }
PolygonMorph >> lineSegments [
	| lineSegments |
	lineSegments := OrderedCollection new.
	self lineSegmentsDo: [:p1 :p2 | lineSegments addLast: (Array with: p1 with: p2)].
	^ lineSegments
]

{ #category : #smoothing }
PolygonMorph >> lineSegmentsDo: endPointsBlock [ 
	"Emit a sequence of segment endpoints into endPointsBlock."
	"Unlike the method this one replaces we expect the curve 
	coefficents not the dirivatives"
	"Also unlike the replaced method the smooth closed curve
	does 
	not need an extra vertex. 
	We take care of the extra endpoint here. Just like for 
	segmented curves."
	| cs x y beginPoint |
	vertices size < 1
		ifTrue: [^ self].
	"test too few vertices first"
	self isCurvy
		ifFalse: [beginPoint := nil.
			"smoothCurve 
			ifTrue: [cs := self coefficients]."
			"some things still depend on smoothCurves having 
			curveState"
			vertices
				do: [:vert | 
					beginPoint
						ifNotNil: [endPointsBlock value: beginPoint value: vert].
					beginPoint := vert].
			(closed
					or: [vertices size = 1])
				ifTrue: [endPointsBlock value: beginPoint value: vertices first].
			^ self].
	"For curves we include all the interpolated sub segments."
	"self assert: [(vertices size > 2 )].	"
	cs := self coefficients.
	beginPoint := (x := cs first first) @ (y := cs fifth first).
	(closed
		ifTrue: [1 to: cs first size]
		ifFalse: [1 to: cs first size - 1])
		do: [:i | | x1 y1 endPoint n y2 t x3 y3 x2 | 
			"taylor series coefficients"
			x1 := cs second at: i.
			y1 := cs sixth at: i.
			x2 := cs third at: i.
			y2 := cs seventh at: i.
			x3 := cs fourth at: i.
			y3 := cs eighth at: i.
			n := cs ninth at: i.
			"guess n 
			n := 5 max: (x2 abs + y2 abs * 2.0 + (cs third atWrap:
			i 
			+ 1) abs + (cs seventh atWrap: i + 1) abs / 100.0) 
			rounded."
			1
				to: n - 1
				do: [:j | 
					t := j asFloat / n asFloat.
					endPoint := x3 * t + x2 * t + x1 * t + x @ (y3 * t + y2 * t + y1 * t + y).
					endPointsBlock value: beginPoint value: endPoint.
					beginPoint := endPoint].
			endPoint := (x := cs first atWrap: i + 1) @ (y := cs fifth atWrap: i + 1).
			endPointsBlock value: beginPoint value: endPoint.
			beginPoint := endPoint]
]

{ #category : #geometry }
PolygonMorph >> lineWidth [

	^self borderWidth
]

{ #category : #geometry }
PolygonMorph >> lineWidth: anInteger [

	self borderWidth: (anInteger rounded max: 1)
]

{ #category : #caching }
PolygonMorph >> loadCachedState [
	"Prepare for fast response -- next page of a book?"
	self filledForm.
	self arrowForms
]

{ #category : #menu }
PolygonMorph >> makeBackArrow [
	arrows := #back.
	self computeBounds
]

{ #category : #menu }
PolygonMorph >> makeBothArrows [
	arrows := #both.
	self computeBounds
]

{ #category : #menu }
PolygonMorph >> makeClosed [
	closed := true.
	handles ifNotNil: [self removeHandles; addHandles].
	self computeBounds
]

{ #category : #menu }
PolygonMorph >> makeForwardArrow [
	arrows := #forward.
	self computeBounds
]

{ #category : #menu }
PolygonMorph >> makeNoArrows [
	arrows := #none.
	self computeBounds
]

{ #category : #menu }
PolygonMorph >> makeOpen [
	closed := false.
	handles ifNotNil: [self removeHandles; addHandles].
	self computeBounds
]

{ #category : #access }
PolygonMorph >> makeOpenOrClosed [
	"toggle the open/closed status of the receiver"
	closed ifTrue: [self makeOpen] ifFalse: [self makeClosed]
]

{ #category : #geometry }
PolygonMorph >> merge: aPolygon [ 
	"Expand myself to enclose the other polygon.  (Later merge overlapping or disjoint in a smart way.)  For now, the two polygons must share at least two vertices.  Shared vertices must come one after the other in each polygon.  Polygons must not overlap."

	| shared mv vv hv xx |
	shared := vertices select: [:mine | aPolygon vertices includes: mine].
	shared size < 2 ifTrue: [^nil].	"not sharing a segment"
	mv := vertices asOrderedCollection.
	[shared includes: mv first] whileFalse: 
			["rotate them"

			vv := mv removeFirst.
			mv addLast: vv].
	hv := aPolygon vertices asOrderedCollection.
	[mv first = hv first] whileFalse: 
			["rotate him until same shared vertex is first"

			vv := hv removeFirst.
			hv addLast: vv].
	[shared size > 2] whileTrue: 
			[shared := shared asOrderedCollection.
			(self 
				mergeDropThird: mv
				in: hv
				from: shared) ifNil: [^nil]].
	"works by side effect on the lists"
	(mv second) = hv last 
		ifTrue: 
			[mv
				removeFirst;
				removeFirst.
			^self setVertices: (hv , mv) asArray].
	(hv second) = mv last 
		ifTrue: 
			[hv
				removeFirst;
				removeFirst.
			^self setVertices: (mv , hv) asArray].
	(mv second) = (hv second) 
		ifTrue: 
			[hv removeFirst.
			mv remove: (mv second).
			xx := mv removeFirst.
			^self setVertices: (hv , (Array with: xx) , mv reversed) asArray].
	mv last = hv last 
		ifTrue: 
			[mv removeLast.
			hv removeFirst.
			^self setVertices: (mv , hv reversed) asArray].
	^nil
]

{ #category : #geometry }
PolygonMorph >> mergeDropThird: mv in: hv from: shared [ 
	"We are merging two polygons.  In this case, they have at least three identical shared vertices.  Make sure they are sequential in each, and drop the middle one from vertex lists mv, hv, and shared.  First vertices on lists are identical already."

	"know (mv first = hv first)"

	| mdrop vv |
	(shared includes: (mv at: mv size - 2)) 
		ifTrue: [(shared includes: mv last) ifTrue: [mdrop := mv last]]
		ifFalse: 
			[(shared includes: mv last) 
				ifTrue: [(shared includes: mv second) ifTrue: [mdrop := mv first]]].
	(shared includes: (mv third)) 
		ifTrue: [(shared includes: mv second) ifTrue: [mdrop := mv second]].
	mdrop ifNil: [^nil].
	mv remove: mdrop.
	hv remove: mdrop.
	shared remove: mdrop.
	[shared includes: mv first] whileFalse: 
			["rotate them"

			vv := mv removeFirst.
			mv addLast: vv].
	[mv first = hv first] whileFalse: 
			["rotate him until same shared vertex is first"

			vv := hv removeFirst.
			hv addLast: vv]
]

{ #category : #access }
PolygonMorph >> midVertices [
	"Return and array of midpoints for this line or closed curve"
	| midPts nextVertIx tweens |
	vertices size < 2
		ifTrue: [^ vertices].
	midPts := OrderedCollection new.
	nextVertIx := 2.
	tweens := OrderedCollection new.
	tweens add: vertices first asIntegerPoint.
	"guarantee at least two points."
	self
		lineSegmentsDo: [:p1 :p2 | 
			tweens addLast: p2 asIntegerPoint.
			p2
					= (vertices atWrap: nextVertIx)
				ifTrue: ["Found endPoint."
					midPts addLast: (tweens atWrap: tweens size + 1 // 2)
							+ (tweens at: tweens size // 2 + 1) // 2.
					"wiz 6/19/2004 20:11 adjusted to handle  
					one segment properly"
					tweens := OrderedCollection new.
					tweens add: p2 asIntegerPoint.
					"guarantee at least two points."
					nextVertIx := nextVertIx + 1]].
	^ midPts asArray
]

{ #category : #attachments }
PolygonMorph >> midpoint [
	"Answer the midpoint along my segments"
	| middle |
	middle := self totalLength.
	middle < 2 ifTrue: [ ^ self center ].
	middle := middle / 2.
	self lineSegmentsDo: [ :a :b | | dist |
		dist := (a dist: b).
		middle < dist
			ifTrue: [ ^(a + ((b - a) * (middle / dist))) asIntegerPoint ].
		middle := middle - dist.
	].
	self error: 'can''t happen'
]

{ #category : #'event handling' }
PolygonMorph >> mouseDown: evt [
	"Handle a mouse-down event."

	^ (evt shiftPressed and: [(self hasProperty: #activateOnShift) not])
		ifTrue: [((owner isKindOf: PolygonMorph) and: [owner includesHandle: self])
					ifTrue: ["Prevent insertion handles from getting edited"
							^ super mouseDown: evt].
				self toggleHandles.
				handles ifNil: [^ self].
				vertices withIndexDo:  "Check for click-to-drag at handle site"
					[:vertPt :vertIndex |
					((handles at: vertIndex*2-1 ifAbsent: [ ^self ]) containsPoint: evt cursorPoint) ifTrue:
						["If clicked near a vertex, jump into drag-vertex action"
						evt hand newMouseFocus: (handles at: vertIndex*2-1)]]]
		ifFalse: [super mouseDown: evt]
]

{ #category : #editing }
PolygonMorph >> newVertex: ix event: evt fromHandle: handle [
	"Insert a new vertex and fix everything up! Install the drag-handle of the new vertex as recipient of further mouse events."

	| pt |
	"(self hasProperty: #noNewVertices) ifFalse:
		[pt := evt cursorPoint.
		self setVertices: (vertices copyReplaceFrom: ix + 1 to: ix with: (Array with: pt)).
		evt hand newMouseFocus: (handles at: ((ix + 1) * 2) - 1)]"
	"modified to remove now vestigial test. see PolygonMorph class>>arrowprototype"
	pt := evt cursorPoint.
	self  insertVertexAt: ix put:  pt .
	evt hand newMouseFocus: (handles at: ((ix + 1) * 2) - 1)
]

{ #category : #editing }
PolygonMorph >> newVertex: arg1 fromHandle: arg2 afterVert: arg3 [
	"Reorder the arguments for existing event handlers"
	(arg3 isMorph and:[arg3 eventHandler notNil]) ifTrue:[arg3 eventHandler fixReversedValueMessages].
	^self newVertex: arg1 event: arg2 fromHandle: arg3
]

{ #category : #geometry }
PolygonMorph >> nextDuplicateVertexIndex [
	vertices
		doWithIndex: [:vert :index | ((index between: 2 and: vertices size - 1)
					and: [| epsilon v1 v2 | 
						v1 := vertices at: index - 1.
						v2 := vertices at: index + 1.
						epsilon := ((v1 x - v2 x) abs max: (v1 y - v2 y) abs)
									// 32 max: 1.
						vert
							onLineFrom: v1
							to: v2
							within: epsilon])
				ifTrue: [^ index]].
	^ 0
]

{ #category : #smoothing }
PolygonMorph >> nextToFirstPoint [
	"For arrow direction"
	self isCurvy
		ifTrue: [curveState
				ifNil: [self coefficients].
			^ curveState second]
		ifFalse: [^ vertices second]
]

{ #category : #smoothing }
PolygonMorph >> nextToLastPoint [
	"For arrow direction"
	self isCurvy
		ifTrue: [curveState
				ifNil: [self coefficients].
			^ curveState third]
		ifFalse: [^ vertices at: vertices size - 1]
]

{ #category : #attachments }
PolygonMorph >> nudgeForLabel: aRectangle [
	"Try to move the label off me. Prefer labels on the top and right."

	| i flags nudge |
	(self bounds intersects: aRectangle) ifFalse: [^ 0 @ 0 ].
	flags := 0.
	nudge := 0 @ 0.
	i := 1.
	aRectangle lineSegmentsDo: [ :rp1 :rp2 | | rectSeg |
		rectSeg := LineSegment from: rp1 to: rp2.
		self straightLineSegmentsDo: [ :lp1 :lp2 | | polySeg int |
			polySeg := LineSegment from: lp1 to: lp2.
			int := polySeg intersectionWith: rectSeg.
			int ifNotNil: [ flags := flags bitOr: i ].
		].
		i := i * 2.
	].
	"Now flags has bitflags for which sides"
	nudge := flags caseOf: {
"no intersection"
		[ 2r0000 ] -> [ 0 @ 0 ].
"2 adjacent sides only" 
		[ 2r1001 ] -> [ 1 @ 1 ].
		[ 2r0011 ] -> [ -1 @ 1 ].
		[ 2r1100 ] -> [ 1 @ -1 ].
		[ 2r0110 ] -> [ -1 @ -1 ].
"2 opposite sides only" 
		[ 2r1010 ] -> [ 0 @ -1 ].
		[ 2r0101 ] -> [ 1 @ 0 ].
"only 1 side" 
		[ 2r1000 ] -> [ -1 @ 0 ].
		[ 2r0001 ] -> [ 0 @ -1 ].
		[ 2r0010 ] -> [ 1 @ 0 ].
		[ 2r0100 ] -> [ 0 @ 1 ].
"3 sides" 
		[ 2r1011 ] -> [ 0 @ 1 ].
		[ 2r1101 ] -> [ 1 @ 0 ].
		[ 2r1110 ] -> [ 0 @ -1 ].
		[ 2r0111 ] -> [ -1 @ 0 ].
 "all sides" 
		[ 2r1111 ] -> [ 1 @ -1 "move up and to the right" ].
	}.
	^nudge
]

{ #category : #access }
PolygonMorph >> openOrClosePhrase [
	"Answer a string indicating whether the receiver is open or closed."

	^ (closed ifTrue: ['<yes>'] ifFalse: ['<no>']), 'closed' translated
]

{ #category : #private }
PolygonMorph >> privateMoveBy: delta [
	super privateMoveBy: delta.
	vertices := vertices collect: [:p | p + delta].
	self arrowForms do: [:f | f offset: f offset + delta].
	curveState := nil.  "Force recomputation"
	(self valueOfProperty: #referencePosition) ifNotNil:
		[:oldPos | self setProperty: #referencePosition toValue: oldPos + delta]
]

{ #category : #menu }
PolygonMorph >> quickFill: ignored [
]

{ #category : #shaping }
PolygonMorph >> rectOval [
	"Set my vertices to an array of corner vertices.
	Order of vertices is in the tradion of warpblt quads."

	self setVertices: self bounds corners.
]

{ #category : #geometry }
PolygonMorph >> reduceVertices [
	"Reduces the vertices size, when 3 vertices are on the same line with a 
	little epsilon. Based on code by Steffen Mueller"
	| dup |
	[ (dup := self nextDuplicateVertexIndex) > 0 ] whileTrue: [
		self setVertices: (vertices copyWithoutIndex: dup)
	].
	^vertices size.
]

{ #category : #'rotate scale and flex' }
PolygonMorph >> referencePosition [ 
	"Return the current reference position of the receiver"
	^ self valueOfProperty: #referencePosition ifAbsent: [super referencePosition]

]

{ #category : #caching }
PolygonMorph >> releaseCachedState [
	super releaseCachedState.
	filledForm := nil.
	arrowForms := nil.
	borderForm := nil.
	curveState := nil.
	(self hasProperty: #flex) ifTrue:
		[self removeProperty: #unflexedVertices;
			removeProperty: #flex].

]

{ #category : #menu }
PolygonMorph >> removeHandles [
	"tk 9/2/97 allow it to be called twice (when nil already)"

	handles ifNotNil: [
		handles do: [:h | h delete].
		handles := nil].
]

{ #category : #dashes }
PolygonMorph >> removeVertex: aVert [
	"Make sure that I am not left with less than two vertices"
	| newVertices |
	vertices size < 2 ifTrue: [ ^self ].
	newVertices := vertices copyWithout: aVert.
	newVertices size caseOf: {
		[1] -> [ newVertices := { newVertices first . newVertices first } ].
		[0] -> [ newVertices := { aVert . aVert } ]
	} otherwise: [].
	self setVertices: newVertices 

]

{ #category : #'debug and other' }
PolygonMorph >> rotateTestFlip: aBool [ 
	"Return one copy of me for each vertex using each vertex as  
	the  
	starting point.  
	Vary to border color to destinguish the copies.  
	This tests closed curves for their consistency.  
	The flip boolean tests the reversed rotations."
	| len colors verts flip |
	verts := self vertices.
	flip := aBool == true
				ifTrue: [1]
				ifFalse: [0].
	len := verts size.
	colors := Color wheel: len*2 .
	(1 to: len)
		do: [:i | | j | (self copy
				borderColor: (colors at: (j:=i * 2 - flip));
				 yourself)
				setVertices: (verts flipRotated: j);
				 openInWorld]
]

{ #category : #'rotate scale and flex' }
PolygonMorph >> rotationCenter [
	"Return the rotation center of the receiver. The rotation center defines the relative offset inside the receiver's bounds for locating the reference position."
	| refPos |
	refPos := self valueOfProperty: #referencePosition
		ifAbsent: [^ 0.5@0.5].
	^ (refPos - self bounds origin) / self bounds extent asFloatPoint
]

{ #category : #'rotate scale and flex' }
PolygonMorph >> rotationCenter: aPointOrNil [
	"Set the new rotation center of the receiver. The rotation center defines the relative offset inside the receiver's bounds for locating the reference position."
	| box |
	aPointOrNil isNil
		ifTrue: [self removeProperty: #referencePosition]
		ifFalse: [box := self bounds.
				self setProperty: #referencePosition
					toValue: box origin + (aPointOrNil * box extent)]

]

{ #category : #'rotate scale and flex' }
PolygonMorph >> rotationDegrees [

	^ self forwardDirection
]

{ #category : #'rotate scale and flex' }
PolygonMorph >> rotationDegrees: degrees [ 
	| flex center |
	(center := self valueOfProperty: #referencePosition) ifNil:
		[self setProperty: #referencePosition toValue: (center := self bounds center)].
	flex := (MorphicTransform offset: center negated)
			withAngle: (degrees - self forwardDirection) degreesToRadians.
	self setVertices: (vertices collect: [:v | (flex transform: v) - flex offset]).
	self forwardDirection: degrees.


]

{ #category : #menu }
PolygonMorph >> setRotationCenterFrom: aPoint [
	"Polygons store their referencePosition."
	self setProperty: #referencePosition toValue: aPoint
]

{ #category : #private }
PolygonMorph >> setVertices: newVertices [
	vertices := newVertices.
	handles ifNotNil: [self removeHandles; addHandles].
	self computeBounds
]

{ #category : #menu }
PolygonMorph >> showOrHideHandles [
	self showingHandles
		ifTrue:	[self removeHandles]
		ifFalse:	[self addHandles]
]

{ #category : #menu }
PolygonMorph >> showingHandles [
	^ handles notNil
]

{ #category : #smoothing }
PolygonMorph >> slopes: knots [ 
	"Choose slopes according to state of polygon and preferences"
	self isCurvy
		ifFalse: [^ knots segmentedSlopes].
	^ (closed
			and: [self isCurvier])
		ifTrue: [knots closedCubicSlopes]
		ifFalse: [knots naturalCubicSlopes]
]

{ #category : #access }
PolygonMorph >> smoothOrSegmentedPhrase [
				| lineName |
	lineName := (closed
						ifTrue: ['outline']
						ifFalse: ['line']) translated.

			^ self isCurve
				ifTrue: ['make segmented {1}' translated format: {lineName}]
				ifFalse: ['make smooth {1}' translated format: {lineName}].
]

{ #category : #menu }
PolygonMorph >> specifyDashedLine [

	| executableSpec newSpec |
	executableSpec := UIManager default
		request:
'Enter a dash specification as
{ major dash length. minor dash length. minor dash color }
The major dash will have the normal border color.
A blank response will remove the dash specification.
[Note: You may give 5 items as, eg, {10. 5. Color white. 0. 3}
where the 4th ityem is zero, and the 5th is the number of pixels
by which the dashes will move in each step of animation]' translated
		initialAnswer: '{ 10. 5. Color red }'.
	executableSpec isEmpty ifTrue:
		[^ self stopStepping; dashedBorder: nil].
	newSpec := [Compiler evaluate: executableSpec] ifError:
		[^ self stopStepping; dashedBorder: nil].
	newSpec first isNumber & newSpec second isNumber & newSpec third isColor ifFalse:
		[^ self stopStepping; dashedBorder: nil].
	newSpec size = 3 ifTrue:
		[^ self stopStepping; dashedBorder: newSpec].
	(newSpec size = 5 and: [newSpec fourth isNumber & newSpec fifth isNumber]) ifTrue:
		[^ self dashedBorder: newSpec; startStepping].

]

{ #category : #menu }
PolygonMorph >> standardArrows [

	self removeProperty: #arrowSpec.
	self computeBounds
]

{ #category : #'stepping and presenter' }
PolygonMorph >> step [
	borderDashSpec ifNil: [^super step].
	borderDashSpec size < 5 ifTrue: [^super step].

	"Only for dashed lines with creep"
	borderDashSpec at: 4 put: (borderDashSpec fourth) + borderDashSpec fifth.
	self changed.
	^super step
]

{ #category : #'stepping and presenter' }
PolygonMorph >> stepTime [
	"Answer the desired time between steps in milliseconds."

	^ self topRendererOrSelf player ifNotNil: [10] ifNil: [100]

	"NB:  in all currently known cases, polygons are not actually wrapped  in TransformationMorphs, so the #topRendererOrSelf call above is probably redundant, but is retained for safety."
]

{ #category : #smoothing }
PolygonMorph >> straightLineSegmentsDo: endPointsBlock [
	"Emit a sequence of segment endpoints into endPointsBlock.
	Work the same way regardless of whether I'm curved."
	| beginPoint |
	beginPoint := nil.
		vertices do:
			[:vert | beginPoint ifNotNil:
				[endPointsBlock value: beginPoint
								value: vert].
			beginPoint := vert].
		(closed or: [vertices size = 1])
			ifTrue: [endPointsBlock value: beginPoint
									value: vertices first].
]

{ #category : #geometry }
PolygonMorph >> straighten [
	self setVertices: { vertices first . vertices last }
]

{ #category : #menu }
PolygonMorph >> toggleHandles [

	handles ifNil: [self addHandles] ifNotNil: [self removeHandles].


]

{ #category : #menu }
PolygonMorph >> toggleSmoothing [

	smoothCurve := smoothCurve not.
	handles ifNotNil: [self removeHandles; addHandles].
	self computeBounds
]

{ #category : #attachments }
PolygonMorph >> totalLength [
	"Answer the full length of my segments. Can take a long time if I'm curved."
	| length |
	length := 0.
	self lineSegmentsDo: [ :a :b | length := length + (a dist: b) ].
	^length.
]

{ #category : #private }
PolygonMorph >> transformVerticesFrom: oldOwner to: newOwner [
	| oldTransform newTransform world newVertices |
	world := self world.
	oldTransform := oldOwner
		ifNil: [ IdentityTransform new ]
		ifNotNil: [ oldOwner transformFrom: world ].
	newTransform := newOwner
		ifNil: [ IdentityTransform new ]
		ifNotNil: [ newOwner transformFrom: world ].
	newVertices := vertices collect: [ :ea | newTransform globalPointToLocal:
		(oldTransform localPointToGlobal: ea) ].
	self setVertices: newVertices.

]

{ #category : #geometry }
PolygonMorph >> transformedBy: aTransform [
	self setVertices: (self vertices collect:[:v| aTransform localPointToGlobal: v])
]

{ #category : #menu }
PolygonMorph >> unrotatedLength [
	"If the receiver bears rotation without a transformation morph, answer what its length in the direction it is headed is"

	vertices size = 2 ifTrue:
		[^ (vertices second - vertices first) r].

	^ ((PolygonMorph new setVertices: vertices) rotationDegrees: self rotationDegrees negated) height
]

{ #category : #menu }
PolygonMorph >> unrotatedLength: aLength [
	"If the receiver bears rotation without a transformation morph, answer what its length in the direction it is headed is"

	vertices size = 2 ifTrue: [^ self arrowLength: aLength].

	self setVertices: ((((PolygonMorph new setVertices: vertices) rotationDegrees: self rotationDegrees negated) height: aLength) rotationDegrees: 0) vertices
]

{ #category : #menu }
PolygonMorph >> unrotatedWidth [
	"If the receiver bears rotation without a transformation morph, answer what its length in the direction it is headed is"
	
	vertices size = 2 ifTrue: [^ self borderWidth].
	^ ((PolygonMorph new setVertices: vertices) rotationDegrees: self rotationDegrees negated) width
]

{ #category : #menu }
PolygonMorph >> unrotatedWidth: aWidth [
	"If the receiver bears rotation without a transformation morph, answer what its length in the direction it is headed is"

	self borderWidth: aWidth
]

{ #category : #editing }
PolygonMorph >> updateHandles [
	self isCurvy
		ifTrue: [handles first center: vertices first.
			handles last center: vertices last.
			self midVertices
				withIndexDo: [:midPt :vertIndex | (closed
							or: [vertIndex < vertices size])
						ifTrue: [| newVert |
							newVert := handles atWrap: vertIndex * 2.
							newVert position: midPt - (newVert extent // 2)]]]
		ifFalse: [vertices
				withIndexDo: [:vertPt :vertIndex |
					| oldVert | 
					oldVert := handles at: vertIndex * 2 - 1.
					oldVert position: vertPt - (oldVert extent // 2).
					(closed
							or: [vertIndex < vertices size])
						ifTrue: [| newVert |
							newVert := handles at: vertIndex * 2.
							newVert position: vertPt
									+ (vertices atWrap: vertIndex + 1) - newVert extent // 2 + (1 @ -1)]]]
]

{ #category : #dashes }
PolygonMorph >> vertexAt: n [
	^vertices at: (n min: vertices size).
]

{ #category : #access }
PolygonMorph >> vertices [
	^ vertices
]

{ #category : #initialization }
PolygonMorph >> vertices: verts color: aColor borderWidth: borderWidthInteger borderColor: anotherColor [ 
	super initialize.
""
	vertices := verts.
	color := aColor.
		
	closed := vertices size > 2.
	arrows := #none.

	self borderStyle
		color: anotherColor;
		width: borderWidthInteger.

	self computeBounds
]

{ #category : #editing }
PolygonMorph >> verticesAt: anInteger put: aPoint [

	self vertices at: anInteger put: aPoint asFloatPoint.
	self computeBounds
]

{ #category : #'stepping and presenter' }
PolygonMorph >> wantsSteps [
	super wantsSteps ifTrue: [^true].

	"For crawling ants effect of dashed line."
	borderDashSpec ifNil: [^false].
	^borderDashSpec size = 5 and: [(borderDashSpec fifth) > 0]
]
