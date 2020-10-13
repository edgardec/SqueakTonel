"
I am a controller for SceneViews. I support gestures for scrolling, click-selection, and area selection of scene glyphs. (See the class comment in GestureController for more details about gestures.) I also support construction operations such as inserting new glyphs and merging glyphs to make them share a common point.

The mapping of gestures to actions is as follows (see GestureController comment for more about gestures):

  Click:
	click on glyph				select glyph
	shift-click on glyph			toggle selection of that glyph
	click on background			clear selection
  Double click:
	double-click on glyph			inspect glyph
	double-click on background		select all
  Hold/Drag/Sweep:
	hold (no movement)			yellow-button menu
	drag (up/left movement)		scrolling hand
	sweep (down/right movement)	select glyphs in region
	shift-sweep					toggle selection of glyphs in region

"
Class {
	#name : #MorphWorldController,
	#superclass : #Controller,
	#category : #'Etoys-Squeakland-ST80-Morphic'
}

{ #category : #'control defaults' }
MorphWorldController >> controlActivity [
	"Do one step of the Morphic interaction loop. Called repeatedly while window is active."

	model doOneCycle.

]

{ #category : #'basic control sequence' }
MorphWorldController >> controlInitialize [
	"This window is becoming active."

	true ifTrue: [model becomeTheActiveWorldWith: nil].

	model canvas ifNil: [  "i.e., only on first entry"
		"In case of, eg, inspect during balloon help..."
		model submorphsDo: [:m |  "delete any existing balloons"
			(m isKindOf: BalloonMorph) ifTrue: [m delete]].

		model handsDo: [:h | h initForEvents].
		view displayView].  "initializes the WorldMorph's canvas"

]

{ #category : #'basic control sequence' }
MorphWorldController >> controlLoop [ 
	"Overridden to keep control active when the hand goes out of the view"

	| db |
	[self viewHasCursor  "working in the window"
		or: [Sensor noButtonPressed  "wandering with no button pressed"
		or: [model primaryHand submorphs size > 0  "dragging something outside"]]]
		whileTrue:   "... in other words anything but clicking outside"
			[self controlActivity.

			"Check for reframing since we hold control here"
			db := view superView displayBox.
			view superView controller checkForReframe.
			db = view superView displayBox ifFalse:
				[self controlInitialize "reframe world if bounds changed"]].

]

{ #category : #'basic control sequence' }
MorphWorldController >> controlTerminate [ 
	"This window is becoming inactive; restore the normal cursor."

	Cursor normal show.
	super controlTerminate.
]

{ #category : #'control defaults' }
MorphWorldController >> isControlActive [

	^ sensor redButtonPressed or: [self viewHasCursor]
]
