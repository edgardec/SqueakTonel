"
A selectionMorph supports the selection of multiple objects in a morphic world or pasteUp.

Structure:
	selectedItems	an OrderedCollection of Morphs
					These are the morphs that have been selected
	slippage		a Point
					Keeps track of actual movement between the 
					steps of gridded movement
	dupLoc		a Point
					Notes the position when first duplicate request occurs from halo
	dupDelta	a Point
					Holds the final delta of the first duplicate plus subsequent moves.

"
Class {
	#name : #SelectionMorph,
	#superclass : #BorderedMorph,
	#instVars : [
		'selectedItems',
		'slippage',
		'dupLoc',
		'dupDelta',
		'itemsAlreadySelected',
		'otherSelection',
		'undoProperties'
	],
	#category : #'Morphic-Support'
}

{ #category : #scripting }
SelectionMorph class >> defaultNameStemForInstances [
	^ 'Selection' translatedNoop
]

{ #category : #'dropping\/grabbing' }
SelectionMorph >> aboutToBeGrabbedBy: aHand [
	slippage := 0@0.
	^ super aboutToBeGrabbedBy: aHand

]

{ #category : #'halo commands' }
SelectionMorph >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add custom menu items to the menu"

	super addCustomMenuItems: aMenu hand: aHandMorph.
	aMenu addList: {
		#-.
		{'place into a row' translated. #organizeIntoRow}.
		{'place into a column' translated. #organizeIntoColumn}.
		#-.
		{'align left edges' translated. #alignLeftEdges}.
		{'align top edges' translated. #alignTopEdges}.
		{'align right edges' translated. #alignRightEdges}.
		{'align bottom edges' translated. #alignBottomEdges}.
		#-.
		{'align centers vertically' translated. #alignCentersVertically}.
		{'align centers horizontally' translated. #alignCentersHorizontally}.
		#-.
		{'distribute vertically' translated. #distributeVertically}.
		{'distribute horizontally' translated. #distributeHorizontally}.
		}



]

{ #category : #'halos and balloon help' }
SelectionMorph >> addHandlesTo: aHaloMorph box: box [
	| onlyThese |
	aHaloMorph haloBox: box.
	onlyThese := #(addDismissHandle: addMenuHandle: addGrabHandle: addDragHandle: addDupHandle: addHelpHandle: addGrowHandle: addFontSizeHandle: addFontStyleHandle: addFontEmphHandle: addRecolorHandle:).
	Preferences haloSpecifications do:
		[:aSpec | (onlyThese includes: aSpec addHandleSelector) ifTrue:
				[aHaloMorph perform: aSpec addHandleSelector with: aSpec]].
	aHaloMorph innerTarget addOptionalHandlesTo: aHaloMorph box: box
]

{ #category : #'halos and balloon help' }
SelectionMorph >> addOptionalHandlesTo: aHalo box: box [
	aHalo addHandleAt: box leftCenter color: Color blue icon: nil
		on: #mouseUp send: #addOrRemoveItems: to: self.
]

{ #category : #'halo commands' }
SelectionMorph >> addOrRemoveItems: handOrEvent [ 
	"Make a new selection extending the current one."

	| hand |
	hand := (handOrEvent isMorphicEvent) 
				ifFalse: [handOrEvent]
				ifTrue: [handOrEvent hand].
	hand 
		addMorphBack: ((self class 
				newBounds: (hand lastEvent cursorPoint extent: 16 @ 16)) 
					setOtherSelection: self).

]

{ #category : #'halo commands' }
SelectionMorph >> alignBottomEdges [
	"Make the bottom coordinate of all my elements be the same"

	| maxBottom |
	maxBottom := (selectedItems collect: [:itm | itm bottom]) max.
	selectedItems do:
		[:itm | itm bottom: maxBottom].

	self changed

]

{ #category : #'halo commands' }
SelectionMorph >> alignCentersHorizontally [
	"Make every morph in the selection have the same vertical center as the topmost item."

	| minLeft leftMost |
	selectedItems size > 1 ifFalse: [^ self].
	minLeft := (selectedItems collect: [:itm | itm left]) min.
	leftMost := selectedItems detect: [:m | m left = minLeft].
	selectedItems do:
		[:itm | itm center: (itm center x @ leftMost center y)].

	self changed

]

{ #category : #'halo commands' }
SelectionMorph >> alignCentersVertically [
	"Make every morph in the selection have the same horizontal center as the topmost item."

	| minTop topMost |
	selectedItems size > 1 ifFalse: [^ self].
	minTop := (selectedItems collect: [:itm | itm top]) min.
	topMost := selectedItems detect: [:m | m top = minTop].
	selectedItems do:
		[:itm | itm center: (topMost center x @ itm center y)].

	self changed

]

{ #category : #'halo commands' }
SelectionMorph >> alignLeftEdges [
	"Make the left coordinate of all my elements be the same"

	| minLeft |
	minLeft := (selectedItems collect: [:itm | itm left]) min.
	selectedItems do:
		[:itm | itm left: minLeft].

	self changed

]

{ #category : #'halo commands' }
SelectionMorph >> alignRightEdges [
	"Make the right coordinate of all my elements be the same"

	| maxRight |
	maxRight := (selectedItems collect: [:itm | itm right]) max.
	selectedItems do:
		[:itm | itm right: maxRight].

	self changed

]

{ #category : #'halo commands' }
SelectionMorph >> alignTopEdges [
	"Make the top coordinate of all my elements be the same"

	| minTop |
	minTop := (selectedItems collect: [:itm | itm top]) min.
	selectedItems do:
		[:itm | itm top: minTop].

	self changed

]

{ #category : #'halos and balloon help' }
SelectionMorph >> balloonHelpTextForHandle: aHandle [
	aHandle eventHandler firstMouseSelector == #addOrRemoveItems:
		ifTrue: [^'Add items to, or remove them from, this selection.'].
	^ super balloonHelpTextForHandle: aHandle
]

{ #category : #accessing }
SelectionMorph >> borderColor: aColor [

	| bordered |
	bordered := selectedItems.
	undoProperties ifNil: [undoProperties := bordered collect: [:m | m borderColor]].
	bordered do: [:m | m borderColor: aColor]
]

{ #category : #undo }
SelectionMorph >> borderColorForItems: colorCollection [

	(selectedItems select: [:m | m isKindOf: BorderedMorph])
		with: colorCollection
		do: [:m :c | m borderColor: c]
]

{ #category : #accessing }
SelectionMorph >> borderWidth: aWidth [

	| bordered |
	bordered := selectedItems select: [:m | m isKindOf: BorderedMorph].
	undoProperties ifNil: [undoProperties := bordered collect: [:m | m borderWidth]].
	bordered do: [:m | m borderWidth: aWidth]
]

{ #category : #undo }
SelectionMorph >> borderWidthForItems: widthCollection [

	(selectedItems select: [:m | m isKindOf: BorderedMorph])
		with: widthCollection
		do: [:m :c | m borderWidth: c]
]

{ #category : #geometry }
SelectionMorph >> bounds: newBounds [
	"Make sure position: gets called before extent:; Andreas' optimization for growing/shrinking in ChangeSet 3119 screwed up selection of morphs from underlying pasteup."

	selectedItems := OrderedCollection new.  "Avoid repostioning items during super position:"
	self position: newBounds topLeft; extent: newBounds extent

]

{ #category : #testing }
SelectionMorph >> couldMakeSibling [
	"Answer whether it is appropriate to ask the receiver to make a sibling"

	^ false
]

{ #category : #initialization }
SelectionMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ self userInterfaceTheme borderColor ifNil: [Color blue twiceDarker alpha: 0.75]
]

{ #category : #initialization }
SelectionMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 2
]

{ #category : #initialization }
SelectionMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ self userInterfaceTheme color ifNil: [Color blue alpha: 0.08]

]

{ #category : #'submorphs-add\/remove' }
SelectionMorph >> delete [
	self setProperty: #deleting toValue: true.
	super delete.
	
]

{ #category : #'submorphs-add\/remove' }
SelectionMorph >> dismissViaHalo [
	selectedItems do: [:m | m dismissViaHalo].
	super dismissViaHalo.
	
]

{ #category : #'halo commands' }
SelectionMorph >> distributeHorizontally [
	"Distribute the empty vertical space in a democratic way."
	| minLeft maxRight totalWidth currentLeft space |

	self selectedItems size > 2
		ifFalse: [^ self].

	minLeft := self selectedItems anyOne left.
	maxRight := self selectedItems anyOne right.
	totalWidth := 0.
	self selectedItems
		do: [:each | 
			minLeft := minLeft min: each left.
			maxRight := maxRight max: each right.
			totalWidth := totalWidth + each width].

	currentLeft := minLeft.
	space := (maxRight - minLeft - totalWidth / (self selectedItems size - 1)) rounded.
	(self selectedItems
		sorted: [:x :y | x left <= y left])
		do: [:each | 
			each left: currentLeft.
			currentLeft := currentLeft + each width + space].

	self changed

]

{ #category : #'halo commands' }
SelectionMorph >> distributeVertically [
	"Distribute the empty vertical space in a democratic way."
	| minTop maxBottom totalHeight currentTop space |
	self selectedItems size > 2
		ifFalse: [^ self].

	minTop := self selectedItems anyOne top.
	maxBottom := self selectedItems anyOne bottom.
	totalHeight := 0.
	self selectedItems
		do: [:each | 
			minTop := minTop min: each top.
			maxBottom := maxBottom max: each bottom.
			totalHeight := totalHeight + each height].

	currentTop := minTop.
	space := (maxBottom - minTop - totalHeight / (self selectedItems size - 1)) rounded.
	(self selectedItems sorted:[:x :y | x top <= y top])
		do: [:each | 
			each top: currentTop.
			currentTop := currentTop + each height + space].

	self changed

]

{ #category : #'halo commands' }
SelectionMorph >> doDup: evt fromHalo: halo handle: dupHandle [

	selectedItems := self duplicateMorphCollection: selectedItems.
	selectedItems do: [:m | self owner addMorph: m].
	dupDelta isNil
		ifTrue: ["First duplicate operation -- note starting location"
				dupLoc := self position.
				evt hand grabMorph: self.
				halo removeAllHandlesBut: dupHandle]
		ifFalse: ["Subsequent duplicate does not grab, but only moves me and my morphs"
				dupLoc := nil.
				self position: self position + dupDelta]

]

{ #category : #private }
SelectionMorph >> doneExtending [

	otherSelection ifNotNil:
		[selectedItems := otherSelection selectedItems , selectedItems.
		otherSelection delete.
		self setOtherSelection: nil].
	self changed.
	self layoutChanged.
	super privateBounds:
		((Rectangle merging: (selectedItems collect: [:m | m fullBounds]))
			expandBy: 8).
	self changed.
	self addHalo.
]

{ #category : #drawing }
SelectionMorph >> drawOn: aCanvas [

	| canvas form1 form2 box |
	super drawOn: aCanvas.
	box := self bounds copy.
	selectedItems do: [:m | box swallow: m fullBounds].
	box := box expandBy: 1.
	canvas := Display defaultCanvasClass extent: box extent depth: 8.
	canvas translateBy: box topLeft negated
		during: [:tempCanvas | selectedItems do: [:m | tempCanvas fullDrawMorph: m]].
	form1 := (Form extent: box extent) copyBits: (0@0 extent: box extent) from: canvas form at: 0@0 colorMap: (Color maskingMap: 8).
	form2 := Form extent: box extent.
	(0@0) fourNeighbors do: [:d | form1 displayOn: form2 at: d rule: Form under].
	form1 displayOn: form2 at: 0@0 rule: Form erase.
	aCanvas stencil: form2
		at: box topLeft
		sourceRect: form2 boundingBox
		color: self borderColor

]

{ #category : #'halo commands' }
SelectionMorph >> duplicate [
	"Make a duplicate of the receiver and havbe the hand grab it"

	selectedItems := self duplicateMorphCollection: selectedItems.
	selectedItems reverseDo: [:m | (owner ifNil: [self currentWorld]) addMorph: m].
	dupLoc := self position.
	self currentHand grabMorph: self.
	self currentWorld presenter flushPlayerListCache.
]

{ #category : #initialization }
SelectionMorph >> extendByHand: aHand [
	"Assumes selection has just been created and added to some pasteUp or world"
	| startPoint handle |

	startPoint := self position.

	handle := NewHandleMorph new followHand: aHand
		forEachPointDo: [:newPoint |
					| localPt |
					localPt := (self transformFrom: self world) globalPointToLocal: newPoint.
					self bounds: (startPoint rect: localPt)
				]
		lastPointDo: [:newPoint |
					selectedItems isEmpty
						ifTrue: [self delete]
						ifFalse: [
							selectedItems size = 1
								ifTrue:[self delete.  selectedItems anyOne addHalo]
								ifFalse:[self doneExtending]
						]
				].

	aHand attachMorph: handle.
	handle startStepping.
]

{ #category : #geometry }
SelectionMorph >> extent: newExtent [
	"Set the receiver's extent   Extend or contract the receiver's selection to encompass morphs within the new extent."

	super extent: newExtent.
	self selectSubmorphsOf: (self pasteUpMorph ifNil: [^ self])
]

{ #category : #viewer }
SelectionMorph >> externalName [
	^ 'Selected {1} objects' translated format:{self selectedItems size}
]

{ #category : #'visual properties' }
SelectionMorph >> fillStyle: aColor [
	undoProperties ifNil: [undoProperties := selectedItems collect: [:m | m fillStyle]].
	selectedItems do: [:m | m fillStyle: aColor]
]

{ #category : #undo }
SelectionMorph >> fillStyleForItems: fillStyleCollection [

	selectedItems with: fillStyleCollection do: [:m :c | m fillStyle: c]
]

{ #category : #'halos and balloon help' }
SelectionMorph >> hasHalo: aBool [ 
	super hasHalo: aBool.
	aBool
		ifFalse: [ (self hasProperty: #deleting) ifFalse: [self delete] ]

]

{ #category : #initialization }
SelectionMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	
	selectedItems := OrderedCollection new.
	itemsAlreadySelected := OrderedCollection new.
	slippage := 0 @ 0
]

{ #category : #testing }
SelectionMorph >> isSelectionMorph [
	^true
]

{ #category : #'dropping\/grabbing' }
SelectionMorph >> justDroppedInto: newOwner event: evt [
	"This message is sent to a dropped morph after it has been dropped on -- and been accepted by -- a drop-sensitive morph"

	selectedItems isEmpty ifTrue:
		["Hand just clicked down to draw out a new selection"
		^ self extendByHand: evt hand].
	dupLoc ifNotNil: [dupDelta := self position - dupLoc].
	selectedItems reverseDo: [:m | 
		WorldState addDeferredUIMessage:
			[m referencePosition: (newOwner localPointToGlobal: m referencePosition).
			newOwner handleDropMorph:
				(DropEvent new setPosition: evt cursorPoint contents: m hand: evt hand)]].
	selectedItems := nil.
	self removeHalo. 
	self halo ifNotNil: [ :halo | halo visible: false ]. 
	self delete.
	evt wasHandled: true
]

{ #category : #menus }
SelectionMorph >> maybeAddCollapseItemTo: aMenu [
	"... don't "
]

{ #category : #'WiW support' }
SelectionMorph >> morphicLayerNumber [
	"helpful for insuring some morphs always appear in front of or  
	behind others. smaller numbers are in front"
	^ 8
]

{ #category : #'halo commands' }
SelectionMorph >> organizeIntoColumn [
	"Place my objects in a column-enforcing container"

	((AlignmentMorph inAColumn: (selectedItems sorted: [:x :y | x top < y top])) setNameTo: 'Column'; color: Color orange muchLighter; enableDragNDrop: true; yourself) openInHand

]

{ #category : #'halo commands' }
SelectionMorph >> organizeIntoRow [
	"Place my objects in a row-enforcing container"

	((AlignmentMorph inARow: (selectedItems sorted: [:x :y | x left < y left])) setNameTo: 'Row'; color: Color orange muchLighter; enableDragNDrop: true; yourself) openInHand

]

{ #category : #testing }
SelectionMorph >> preferredDuplicationHandleSelector [
	"Answer the selector, to be offered as the default in a halo open on me"

	^ #addDupHandle:
]

{ #category : #private }
SelectionMorph >> privateFullMoveBy: delta [

	| griddedDelta griddingMorph |
	selectedItems isEmpty ifTrue: [^ super privateFullMoveBy: delta].
	griddingMorph := self pasteUpMorph.
	griddingMorph ifNil: [^ super privateFullMoveBy: delta].
	griddedDelta := (griddingMorph gridPoint: self position + delta + slippage) -
					(griddingMorph gridPoint: self position).
	slippage := slippage + (delta - griddedDelta).  "keep track of how we lag the true movement."
	griddedDelta = (0@0) ifTrue: [^ self].
	super privateFullMoveBy: griddedDelta.
	selectedItems do:
		[:m | m position: (m position + griddedDelta) ]

]

{ #category : #undo }
SelectionMorph >> refineUndoTarget: target selector: selector arguments: arguments in: refineBlock [
	"Any morph can override this method to refine its undo specification"
	selector == #fillStyle: ifTrue:
		[refineBlock value: target value: #fillStyleForItems: value: {undoProperties}.
		^ undoProperties := nil].
	selector == #borderColor: ifTrue:
		[refineBlock value: target value: #borderColorForItems: value: {undoProperties}.
		^ undoProperties := nil].
	selector == #borderWidth: ifTrue:
		[refineBlock value: target value: #borderWidthForItems: value: {undoProperties}.
		^ undoProperties := nil].
	selector == #undoMove:redo:owner:bounds:predecessor: ifTrue:
		["This is the biggy.  Need to gather parameters for all selected items"
		refineBlock value: target
			value: #undoMove:redo:owner:bounds:predecessor:
			value: {arguments first.
					arguments second.
					selectedItems collect: [:m | m owner].
					selectedItems collect: [:m | m bounds].
					selectedItems collect: [:m | m owner morphPreceding: m]}].
	refineBlock value: target value: selector value: arguments
]

{ #category : #private }
SelectionMorph >> selectSubmorphsOf: aMorph [
	"Given the receiver's current bounds, select submorphs of the indicated pasteup morph that fall entirely within those bounds.  If nobody is within the bounds, delete the receiver."

	| newItems removals |
	newItems := aMorph submorphs select:
		[:m | (bounds containsRect: m fullBounds) 
					and: [m~~self
					and: [(m isKindOf: HaloMorph) not]]].
	otherSelection ifNil: [^ selectedItems := newItems].

	removals := newItems intersection: itemsAlreadySelected.
	otherSelection setSelectedItems: (itemsAlreadySelected copyWithoutAll: removals).
	selectedItems := (newItems copyWithoutAll: removals).
	selectedItems ifEmpty: [self delete]

]

{ #category : #private }
SelectionMorph >> selectedItems [

	^ selectedItems
]

{ #category : #private }
SelectionMorph >> setOtherSelection: otherOrNil [ 
	otherSelection := otherOrNil.
	otherOrNil isNil 
		ifTrue: [super borderColor: Color blue]
		ifFalse: 
			[itemsAlreadySelected := otherSelection selectedItems.
			super borderColor: Color green]
]

{ #category : #private }
SelectionMorph >> setSelectedItems: items [

	selectedItems := items.
	self changed
]

{ #category : #'dropping\/grabbing' }
SelectionMorph >> slideToTrash: evt [
	self delete.
	"selectedItems do: [:m | m slideToTrash: evt]"
]

{ #category : #undo }
SelectionMorph >> undoMove: cmd redo: redo owner: oldOwners bounds: oldBoundses predecessor: oldPredecessors [ 
	"Handle undo and redo of move commands in morphic"

	| item |
	redo 
		ifFalse: 
			["undo sets up the redo state first"

			cmd 
				redoTarget: self
				selector: #undoMove:redo:owner:bounds:predecessor:
				arguments: { 
						cmd.
						true.
						selectedItems collect: [:m | m owner].
						selectedItems collect: [:m | m bounds].
						selectedItems collect: [:m | m owner morphPreceding: m]}].
	1 to: selectedItems size do: 
				[:i | 
				item := selectedItems at: i.
				(oldOwners at: i) ifNotNil: 
						[(oldPredecessors at: i) ifNil: [(oldOwners at: i) addMorphFront: item]
							ifNotNil: [(oldOwners at: i) addMorph: item after: (oldPredecessors at: i)]].
				item bounds: (oldBoundses at: i).
				item isSystemWindow ifTrue: [item beKeyWindow]]
]

{ #category : #accessing }
SelectionMorph >> wantsToBeTopmost [
	"Answer if the receiver want to be one of the topmost objects in 
	its owner"
	^ true
]
