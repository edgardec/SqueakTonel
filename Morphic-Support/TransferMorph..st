"
This is a Morph that is used to visually indicate the progress of a drag operation, and also as a container for various bits of drag state information.

It polls the shift state in its step method to update its copy state (shift pressed = should copy).

And if you hit the Escape key while dragging, it aborts the drag operation.
"
Class {
	#name : #TransferMorph,
	#superclass : #Morph,
	#instVars : [
		'transferType',
		'passenger',
		'draggedMorph',
		'source',
		'dropNotifyRecipient',
		'resultRecipient',
		'copy'
	],
	#classVars : [
		'CopyPlusIcon'
	],
	#category : #'Morphic-Support'
}

{ #category : #'class initialization' }
TransferMorph class >> initIcons [
	"TransferMorph initIcons"

	CopyPlusIcon := Form
		extent: 16@16
		depth: 8
		fromArray: #( 0 0 65535 0 0 0 16768220 4278190080 0 0 16768220 4278190080 0 255 4294958300 4294967040 0 65500 3705461980 3705462015 0 65500 3705461980 3705462015 0 255 4294958300 4294967295 0 0 16768220 4278190080 0 0 16768220 4278190080 0 0 65535 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
		offset: 0@0
]

{ #category : #'class initialization' }
TransferMorph class >> initialize [
	"TransferMorph initialize"

	self initIcons
]

{ #category : #'instance creation' }
TransferMorph class >> withPassenger: anObject [ 

	^ self
		withPassenger: anObject
		from: nil
]

{ #category : #'instance creation' }
TransferMorph class >> withPassenger: anObject from: source [ 
	
	^ self new
		passenger: anObject;
		source: source;
		yourself
]

{ #category : #'dropping\/grabbing' }
TransferMorph >> aboutToBeGrabbedBy: aHand [ 
	"The receiver is being grabbed by a hand.                           
	Perform necessary adjustments (if any) and return the actual morph    
	     that should be added to the hand."
	"Since this morph has been initialized automatically with bounds origin   
	     0@0, we have to move it to aHand position."
	super aboutToBeGrabbedBy: aHand.

	self align: self fullBounds topLeft with: aHand position + (aHand extent // 3).
	aHand newKeyboardFocus: self.
]

{ #category : #private }
TransferMorph >> animationForMoveSuccess: success [ 
	| start stop slideForm |
	success
		ifTrue: [^ self]
		ifFalse: 
			[start := self fullBounds origin.
			stop := self source bounds origin].
	start = stop ifTrue: [^ self].
	slideForm := self imageFormForRectangle: ((self fullBounds origin corner: self fullBounds corner + self activeHand shadowOffset)
					merge: self activeHand bounds).
	slideForm offset: 0 @ 0.
	slideForm
		slideWithFirstFrom: start
		to: stop
		nSteps: 12
		delay: 20
]

{ #category : #updating }
TransferMorph >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	self setDefaultParameters.
]

{ #category : #'event handling' }
TransferMorph >> doCopy [

	copy := true.
	self updateCopyIcon.
]

{ #category : #'event handling' }
TransferMorph >> doMove [

	copy := false.
	self updateCopyIcon.
]

{ #category : #accessing }
TransferMorph >> dragTransferType [
	^transferType
]

{ #category : #accessing }
TransferMorph >> dragTransferType: aSymbol [
	transferType := aSymbol
]

{ #category : #initialization }
TransferMorph >> initialize [

	super initialize.

	self
		changeTableLayout;
		listDirection: #leftToRight;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		layoutInset: 3;
		cellGap: 3;
		wrapCentering: #center;
		cellPositioning: #leftCenter;
		setProperty: #indicateKeyboardFocus toValue: #never.
	
	self doMove.
	
	self on: #keyStroke send: #keyStroke: to: self.
	self on: #keyUp send: #updateFromUserInputEvent: to: self.
	self on: #keyDown send: #updateFromUserInputEvent: to: self.

	self setDefaultParameters.
]

{ #category : #'dropping\/grabbing' }
TransferMorph >> justDroppedInto: targetMorph event: anEvent [ 
	"If only world wants this TransferMorph, treat it as unaccepted (see also >>delete)."
	super
		justDroppedInto: targetMorph
		event: anEvent.
	self animationForMoveSuccess: true.
	self delete
]

{ #category : #'event handling' }
TransferMorph >> keyStroke: evt [
	"Abort the drag on an escape"

	evt keyCharacter = Character escape ifTrue: [self delete].
]

{ #category : #'dropping\/grabbing' }
TransferMorph >> morphToDropInPasteUp: aPasteUpMorph [
	^ aPasteUpMorph morphToDropForTransferMorph: self
]

{ #category : #accessing }
TransferMorph >> passenger [
	^passenger
]

{ #category : #accessing }
TransferMorph >> passenger: anObject [

	passenger := anObject.

	self
		removeAllMorphs;
		addMorph: passenger asDraggableMorph;
		updateCopyIcon;
		setDefaultParameters.
]

{ #category : #initialization }
TransferMorph >> setDefaultParameters [

	self
		borderWidth: (self userInterfaceTheme borderWidth ifNil: [1]);
		borderColor: (self userInterfaceTheme borderColor ifNil: [Color r: 0.46 g: 0.46 b: 0.353]);
		color: (self userInterfaceTheme color ifNil: [Color r: 0.92 g: 0.92 b: 0.706]);
		cornerStyle: (MenuMorph roundedMenuCorners ifTrue: [#rounded] ifFalse: [#square]).
		
	self updateGradient.
]

{ #category : #accessing }
TransferMorph >> shouldCopy [
	^copy
]

{ #category : #accessing }
TransferMorph >> shouldMove [
	^ self shouldCopy not
]

{ #category : #accessing }
TransferMorph >> source [
	^source
]

{ #category : #accessing }
TransferMorph >> source: anObject [
	source := anObject
]

{ #category : #'dropping\/grabbing' }
TransferMorph >> undoGrabCommand [
	^nil
]

{ #category : #private }
TransferMorph >> updateCopyIcon [

	(self submorphNamed: #tmCopyIcon)
		ifNil: [self shouldCopy ifTrue: [
			self addMorphFront: (ImageMorph new image: CopyPlusIcon; name: #tmCopyIcon; yourself)]]
		ifNotNil: [:copyIcon | self shouldCopy ifFalse: [
			copyIcon delete]]
]

{ #category : #'event handling' }
TransferMorph >> updateFromUserInputEvent: evt [

	evt shiftPressed
		ifTrue: [self doCopy]
		ifFalse: [self doMove].
]

{ #category : #updating }
TransferMorph >> updateGradient [

	| cc fill |

	MenuMorph gradientMenu ifFalse: [^ self].

	self fullBounds.
	
	cc := self color.
	fill := GradientFillStyle ramp: {
		0.0 -> Color white.
		0.10 -> (cc mixed: 0.5 with: Color white).
		0.5 -> cc.
		0.8 -> cc twiceDarker}.
	fill
		origin: self topLeft;
		direction: 0@self height.
	self fillStyle: fill.
]

{ #category : #'dropping\/grabbing' }
TransferMorph >> wantsToBeDroppedInto: aMorph [
	^ aMorph isWorldMorph
		ifTrue: [ aMorph hasTransferMorphConverter ]
		ifFalse: [ super wantsToBeDroppedInto: aMorph ]
]
