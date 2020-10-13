"
A WorldWindow is a SystemWindow whose central area presents an inner Morphic world.

WorldWindows have a red title bar when the world inside is inactive. This changes to green when the world becomes the active world. The world inside becomes activated by clicking in it. When you click outside this world, the parent world resumes control. While its world is inactive, the WorldWindow may be moved and resized like any other.

It would be nice to make the world inside active whenever the WorldWindow was active, but this presents difficulties in moving and resizing, probably related to use of the global World instead of self world in many methods.

This facility is mainly the work of Bob Arning, with a number of tweaks by DI.

"
Class {
	#name : #WorldWindow,
	#superclass : #SystemWindow,
	#category : #'Etoys-Squeakland-Morphic-Worlds'
}

{ #category : #'as yet unclassified' }
WorldWindow class >> test1 [
	"WorldWindow test1."

	| window world |
	world := WiWPasteUpMorph newWorldForProject: nil.
	window := (WorldWindow labelled: 'Inner World') model: world.
	window addMorph: world.
	world hostWindow: window.
	window openInWorld

]

{ #category : #'as yet unclassified' }
WorldWindow class >> test2 [
	"WorldWindow test2."

	| window world scrollPane |
	world := WiWPasteUpMorph newWorldForProject: nil.
	window := (WorldWindow labelled: 'Scrollable World') model: world.
	window addMorph: (scrollPane := ScrollPane new model: world)
		frame: (0@0 extent: 1.0@1.0).
	scrollPane scroller addMorph: world.
	world hostWindow: window.
	window openInWorld

]

{ #category : #menu }
WorldWindow >> buildWindowMenu [

	| aMenu |
	aMenu := super buildWindowMenu.
	{640@480. 800@600. 832@624. 1024@768} do: [ :each |
		aMenu 
			add: each x printString,' x ',each y printString 
			target: self 
			selector: #extent: 
			argument: each + (0@self labelHeight).
	].
	^aMenu
]

{ #category : #'resize\/collapse' }
WorldWindow >> collapseOrExpand [

	super collapseOrExpand.
	isCollapsed ifFalse: [model becomeTheActiveWorldWith: nil]
]

{ #category : #geometry }
WorldWindow >> extent: x [

	super extent: x.
	model ifNil: [^self].
	model extent: self panelRect extent.
]

{ #category : #layout }
WorldWindow >> fullBounds [

	^self bounds
]

{ #category : #'event handling' }
WorldWindow >> mouseUp: evt [

	(self panelRect containsPoint: evt cursorPoint)
		ifTrue: [model becomeTheActiveWorldWith: evt]
]

{ #category : #initialization }
WorldWindow >> openInWorld: aWorld [
	"This msg and its callees result in the window being activeOnlyOnTop"
	self bounds: (RealEstateAgent initialFrameFor: self world: aWorld).
	self firstSubmorph position: (self left + 1) @ (self top + self labelHeight).
	^self openAsIsIn: aWorld
]
