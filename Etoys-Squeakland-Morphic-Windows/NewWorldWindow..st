Class {
	#name : #NewWorldWindow,
	#superclass : #SystemWindow,
	#category : #'Etoys-Squeakland-Morphic-Windows'
}

{ #category : #panes }
NewWorldWindow >> addMorph: aMorph frame: relFrame [
	| cc |
	cc := aMorph color.
	super addMorph: aMorph frame: relFrame.
	aMorph color: cc.
]

{ #category : #stepping }
NewWorldWindow >> amendSteppingStatus [
]

{ #category : #initialization }
NewWorldWindow >> openInWorld: aWorld [
	| xxx |
	"This msg and its callees result in the window being activeOnlyOnTop"

	xxx := RealEstateAgent initialFrameFor: self world: aWorld.

	"Bob say: 'opening in ',xxx printString,' out of ',aWorld bounds printString.
	6 timesRepeat: [Display flash: xxx andWait: 300]."

	self bounds: xxx.
	^self openAsIsIn: aWorld.
]

{ #category : #label }
NewWorldWindow >> setStripeColorsFrom: paneColor [
	"Since our world may be *any* color, try to avoid really dark colors so title will show"

	| revisedColor |
	stripes ifNil: [^ self].
	revisedColor := paneColor atLeastAsLuminentAs: 0.1 .
	self isActive ifTrue:
		[stripes second 
			color: revisedColor; 
			borderColor: stripes second color darker.
		stripes first 
			color: stripes second borderColor darker;
			borderColor: stripes first color darker.
		^ self].
	"This could be much faster"
	stripes second 
		color: revisedColor; 
		borderColor: revisedColor.
	stripes first 
		color: revisedColor; 
		borderColor: revisedColor
]

{ #category : #color }
NewWorldWindow >> setWindowColor: incomingColor [
	| existingColor aColor |

	incomingColor ifNil: [^ self].  "it happens"
	aColor := incomingColor asNontranslucentColor.
	(aColor = ColorPickerMorph perniciousBorderColor 
		or: [aColor = Color black]) ifTrue: [^ self].
	existingColor := self paneColorToUse.
	existingColor ifNil: [^ Beeper beep].
	self setStripeColorsFrom: aColor
		

]

{ #category : #'resize\/collapse' }
NewWorldWindow >> spawnReframeHandle: event [
	"The mouse has crossed a pane border.  Spawn a reframe handle."
	| resizer localPt pt ptName newBounds |

	allowReframeHandles ifFalse: [^ self].
	owner ifNil: [^ self  "Spurious mouseLeave due to delete"].
	(self isActive not or: [self isCollapsed]) ifTrue:  [^ self].
	((self world ifNil: [^ self]) firstSubmorph isKindOf: NewHandleMorph) ifTrue:
		[^ self  "Prevent multiple handles"].

"Transcript show: event hand printString,'  ',event hand world printString,
		'  ',self world printString,' ',self outermostWorldMorph printString; cr; cr."
	pt := event cursorPoint.
	self bounds forPoint: pt closestSideDistLen:
		[:side :dist :len |  "Check for window side adjust"
		dist <= 2  ifTrue: [ptName := side]].
	ptName ifNil:
		["Check for pane border adjust"
		^ self spawnPaneFrameHandle: event].
	#(topLeft bottomRight bottomLeft topRight) do:
		[:corner |  "Check for window corner adjust"
		(pt dist: (self bounds perform: corner)) < 20 ifTrue: [ptName := corner]].

	resizer := NewHandleMorph new
		followHand: event hand
		forEachPointDo:
			[:p | localPt := self pointFromWorld: p.
			newBounds := self bounds
				withSideOrCorner: ptName
				setToPoint: localPt
				minExtent: self minimumExtent.
			self fastFramingOn 
			ifTrue:
				[self doFastWindowReframe: ptName]
			ifFalse:
				[self bounds: newBounds.
				(Preferences roundedWindowCorners
					and: [#(bottom right bottomRight) includes: ptName])
					ifTrue:
					["Complete kluge: causes rounded corners to get painted correctly,
					in spite of not working with top-down displayWorld."
					ptName = #bottom ifFalse:
						[self invalidRect: (self bounds topRight - (6@0) extent: 7@7)].
					ptName = #right ifFalse:
						[self invalidRect: (self bounds bottomLeft - (0@6) extent: 7@7)].
					self invalidRect: (self bounds bottomRight - (6@6) extent: 7@7)]]]
		lastPointDo:
			[:p | ].
	self world addMorph: resizer.
	resizer startStepping.

]

{ #category : #panes }
NewWorldWindow >> updatePaneColors [
	"Useful when changing from monochrome to color display"

	self setStripeColorsFrom: self paneColorToUse.

	"paneMorphs do: [:p | p color: self paneColorToUse]."	"since pane is a world, skip this"

]

{ #category : #testing }
NewWorldWindow >> wantsSteps [
	
	^true
]
