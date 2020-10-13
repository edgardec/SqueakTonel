"
I am a view used to display a Scene. I may be scrolled by adjusting my offset. My default controller is SceneController.

SceneViews encapsulate the notion of a changing foreground and a fixed background during interactive updates. During an interaction (such as dragging), some of the glyphs will not change location or appearance. These are part of the ""background"". All glyphs that may change (the ""foreground"" glyphs) are painted against this unchanging backdrop during the interaction.

Instance Variables:
	offset				the current offset of this view (used for scrolling)
	enclosingRect 		a rectangle large enough to contain all the objects in the scene, plus a small border (this is a cache that must be recomputed when glyphs are moved, added, or removed from the scene)
	backgroundForm		a <Form> containing the fixed background
	visibleForeground		the glyphs that are changing but not selected during an interaction
	selectedForeground	the selected glyphs that are changing during an interaction
"
Class {
	#name : #MorphWorldView,
	#superclass : #View,
	#classVars : [
		'FullColorWhenInactive'
	],
	#category : #'Etoys-Squeakland-ST80-Morphic'
}

{ #category : #'instance creation' }
MorphWorldView class >> convertToMVCWiWPasteUpMorph [
	"
MorphWorldView convertToMVCWiWPasteUpMorph
"

	| current w newModel topView |
	Smalltalk isMorphic ifTrue: [^self inform: 'do this in MVC'].
	current := self allInstances 
				select: [:each | each model class == PasteUpMorph].
	current do: 
			[:oldWorldView | 
			w := MVCWiWPasteUpMorph newWorldForProject: nil.
			w
				color: oldWorldView model color;
				addAllMorphs: oldWorldView model submorphs.
			newModel := CautiousModel new initialExtent: 300 @ 300.
			topView := self fullColorWhenInactive 
						ifTrue: [ColorSystemView new]
						ifFalse: [StandardSystemView new].
			topView
				model: newModel;
				label: oldWorldView topView label;
				borderWidth: 1;
				addSubView: (self new model: w);
				backgroundColor: w color.
			topView controller openNoTerminate.
			topView reframeTo: (oldWorldView topView expandedFrame 
						expandBy: (0 @ 0 extent: 0 @ topView labelHeight)).
			oldWorldView topView controller closeAndUnscheduleNoTerminate].
	ScheduledControllers restore.
	Processor terminateActive
]

{ #category : #'instance creation' }
MorphWorldView class >> fullColorWhenInactive [

	FullColorWhenInactive ifNil: [FullColorWhenInactive := true].
	^ FullColorWhenInactive

]

{ #category : #'instance creation' }
MorphWorldView class >> fullColorWhenInactive: fullColor [
	"MorphWorldView fullColorWhenInactive: true"
	"If FullColorWhenInactive is true then WorldMorphViews will created inside StandardSystemViews that cache their contents in full-color when the window is inactive. If it is false, only a half-tone gray approximation of the colors will be cached to save space."

	FullColorWhenInactive := fullColor.

	"Retroactively convert all extant windows"
	((fullColor ifTrue: [StandardSystemView] ifFalse: [ColorSystemView])
		allInstances select:
			[:v | v subViews notNil and: [v subViews isEmpty not and: [v firstSubView isKindOf: MorphWorldView]]])
		do: [:v | v uncacheBits.
			v controller toggleTwoTone]
]

{ #category : #'instance creation' }
MorphWorldView class >> openOn: aMorphWorld [
	"Open a view on the given WorldMorph."

	self openOn: aMorphWorld label: 'A Morphic World'.
]

{ #category : #'instance creation' }
MorphWorldView class >> openOn: aWorldMorph label: aString [
	"Open a view with the given label on the given WorldMorph."
	^ self openOn: aWorldMorph label: aString model: (CautiousModel new initialExtent: aWorldMorph initialExtent)
]

{ #category : #'instance creation' }
MorphWorldView class >> openOn: aWorldMorph label: aString cautionOnClose: aBoolean [
	"Open a view with the given label on the given WorldMorph."
	| aModel |
	aModel := aBoolean
		ifTrue:		[CautiousModel new]
		ifFalse:		[WorldViewModel new].
	^ self openOn: aWorldMorph label: aString model: (aModel initialExtent: aWorldMorph initialExtent)
]

{ #category : #'instance creation' }
MorphWorldView class >> openOn: aWorldMorph label: aString extent: aPoint [
	"Open a view with the given label and extent on the given WorldMorph."

	^ self openOn: aWorldMorph
		label: aString
		model: (CautiousModel new initialExtent: aPoint)

]

{ #category : #'instance creation' }
MorphWorldView class >> openOn: aWorldMorph label: aString model: aModel [ 
	"Open a view with the given label on the given WorldMorph."

	| topView |
	topView := self fullColorWhenInactive 
				ifTrue: [topView := ColorSystemView new]
				ifFalse: [topView := StandardSystemView new].
	topView
		model: aModel;
		label: aString;
		borderWidth: 1;
		addSubView: (self new model: aWorldMorph);
		backgroundColor: aWorldMorph color.
	"minimumSize: aWorldMorph extent + (2@2); "	"add border width"
	topView controller open
]

{ #category : #'instance creation' }
MorphWorldView class >> openWorld [

	| w |
	(w := MVCWiWPasteUpMorph newWorldForProject: nil).
	w bounds: (0@0 extent: 400@300).
	self openOn: w
		label: 'A Morphic World'
		extent: w fullBounds extent + 2.

]

{ #category : #'instance creation' }
MorphWorldView class >> openWorldWith: aMorph labelled: labelString [

	| w |
	(w := MVCWiWPasteUpMorph newWorldForProject: nil) addMorph: aMorph.
	w extent: aMorph fullBounds extent.
	w startSteppingSubmorphsOf: aMorph.
	self openOn: w
		label: labelString
		extent: w fullBounds extent + 2.

]

{ #category : #private }
MorphWorldView >> computeInsetDisplayBox [
	"This overrides the same method in View.  (It avoids using displayTransform: because it can return inaccurate results, causing a MorphWorldView's inset display box to creep inward when resized.)"

	^superView insetDisplayBox insetBy: borderWidth
]

{ #category : #deEmphasizing }
MorphWorldView >> deEmphasizeView [ 
	"This window is becoming inactive."

	Cursor normal show.    "restore the normal cursor"
	model deEmphasizeViewMVC: self topView cacheBitsAsTwoTone.

]

{ #category : #'controller access' }
MorphWorldView >> defaultControllerClass [

	^ MorphWorldController
]

{ #category : #displaying }
MorphWorldView >> displayView [
	"This method is called by the system when the top view is framed or moved."
	| topView |
	model viewBox: self insetDisplayBox.
	self updateSubWindowExtent.
	topView := self topView.
	(topView == ScheduledControllers scheduledControllers first view
		or: [topView cacheBitsAsTwoTone not])
		ifTrue: [model displayWorldSafely]
		ifFalse: [model displayWorldAsTwoTone].  "just restoring the screen"
]

{ #category : #updating }
MorphWorldView >> update: symbol [

	^ symbol == #newColor
		ifTrue: [self topView backgroundColor: model color dominantColor; uncacheBits; display]
		ifFalse: [super update: symbol].

]

{ #category : #'as yet unclassified' }
MorphWorldView >> updateSubWindowExtent [
	"If this MorphWorldView represents a single Morphic SystemWindow, then update that window to match the size of the WorldView."

	| numMorphs subWindow scrollBarWidth |
	numMorphs := model submorphs size.
	"(Allow for the existence of an extra NewHandleMorph (for resizing).)"
	(numMorphs = 0 or: [numMorphs > 2]) ifTrue: [^self].
	subWindow := model submorphs detect: [:ea | ea respondsTo: #label]
				ifNone: [^self].
	superView label = subWindow label ifFalse: [^self].
	scrollBarWidth := (Preferences valueOfFlag: #inboardScrollbars) 
				ifTrue: [0]
				ifFalse: [14]. 
	subWindow position: model position + (scrollBarWidth @ -16).	"adjust for WiW changes"
	subWindow extent: model extent - (scrollBarWidth @ -16).
	subWindow isActive ifFalse: [subWindow activate]
]
