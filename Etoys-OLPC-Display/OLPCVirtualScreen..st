"
A custom display screen to allow displaying the high-res OLPC content on a regular display.
"
Class {
	#name : #OLPCVirtualScreen,
	#superclass : #DisplayScreen,
	#instVars : [
		'display',
		'warpBlt',
		'pendingUpdate',
		'zoomOut'
	],
	#classVars : [
		'VirtualScreenExtent'
	],
	#category : #'Etoys-OLPC-Display'
}

{ #category : #installing }
OLPCVirtualScreen class >> defaultVirtualScreenExtent [

	^ 1200@900.

]

{ #category : #installing }
OLPCVirtualScreen class >> initialize [
	"OLPCVirtualScreen initialize"
	Preferences addPreference: #enableVirtualOLPCDisplay categories: #('OLPC') default: false balloonHelp: 'If true, uses the virtual OLPC resolution (1200x900)' projectLocal: true changeInformee: self changeSelector: #virtualDisplayChanged.
	Preferences addPreference: #enablePortraitMode categories: #('OLPC') default: false balloonHelp: 'If true, portrait mode instead of landscape' projectLocal: true changeInformee: self changeSelector: #portraitModeChanged.
	"Smalltalk addToStartUpList: self."
	"self startUp."
	self virtualScreenExtent: 1200@900.

]

{ #category : #installing }
OLPCVirtualScreen class >> install [
	"Install me and my sensor"
	Display := self new.
	Display beDisplay.
	OLPCVirtualSensor install.
]

{ #category : #installing }
OLPCVirtualScreen class >> portraitModeChanged [
	"Toggle portrait mode"
	(Display isKindOf: self) ifTrue:[Display initialize].
]

{ #category : #installing }
OLPCVirtualScreen class >> preferredScreenDepth [

	^ 16.

]

{ #category : #installing }
OLPCVirtualScreen class >> setupIfNeeded [

	self actualScreenSize = self virtualScreenExtent
		ifFalse: [
			(Display class ~= self or: [Display extent ~= self virtualScreenExtent]) ifTrue: [
				self install]]
		ifTrue: [Display class = self ifTrue: [self unInstall]]
]

{ #category : #installing }
OLPCVirtualScreen class >> unInstall [
	"Uninstall me and my sensor"
	EventSensor install.
	Display := DisplayScreen extent: DisplayScreen actualScreenSize depth: self preferredScreenDepth.
	Display beDisplay.
]

{ #category : #installing }
OLPCVirtualScreen class >> virtualDisplayChanged [
	"Update the display"
	Preferences enableVirtualOLPCDisplay 
		ifTrue:[self install]
		ifFalse:[self unInstall].
]

{ #category : #installing }
OLPCVirtualScreen class >> virtualScreenExtent [

	^ VirtualScreenExtent ifNil: [self defaultVirtualScreenExtent].

]

{ #category : #installing }
OLPCVirtualScreen class >> virtualScreenExtent: aPoint [

	VirtualScreenExtent := aPoint

]

{ #category : #private }
OLPCVirtualScreen >> actualDisplay [
	"The display known to the VM"
	^display ifNil: [self]
]

{ #category : #display }
OLPCVirtualScreen >> beDisplay [
	"Make the receiver be the main display"
	display ifNil:[super beDisplay] ifNotNil:[display beDisplay].
]

{ #category : #copying }
OLPCVirtualScreen >> border: rect width: borderWidth rule: rule fillColor: fillColor [
	super border: rect width: borderWidth rule: rule fillColor: fillColor.
	self forceToScreen: rect.
]

{ #category : #display }
OLPCVirtualScreen >> canZoomOut [

	^ display extent x > self extent x and: [display extent y > self extent y]

]

{ #category : #display }
OLPCVirtualScreen >> checkForNewScreenSize [
	| aPoint |
	aPoint := DisplayScreen actualScreenSize.
	aPoint = display extent ifTrue:[^nil].
	display setExtent: aPoint depth: depth.
	display fillColor: (Color gray: 0.2). 
	self setupWarp; forceToScreen.
	display forceToScreen. "to capture the borders"
	Project current world restoreMorphicDisplay.
	Project current world repositionFlapsAfterScreenSizeChange.
]

{ #category : #copying }
OLPCVirtualScreen >> copy: aRect [
 	"Return a new form which derives from the portion of the original form delineated by aRect."
	| newForm |
	newForm := DisplayScreen extent: aRect extent depth: depth.
	^ newForm copyBits: aRect from: self at: 0@0
		clippingBox: newForm boundingBox rule: Form over fillColor: nil
]

{ #category : #copying }
OLPCVirtualScreen >> copyBits: sourceRect from: sourceForm at: destOrigin clippingBox: clipRect rule: rule fillColor: aForm [
	"We need this for the project zoom"
	super copyBits: sourceRect from: sourceForm at: destOrigin clippingBox: clipRect rule: rule fillColor: aForm.
	self forceToScreen: (destOrigin extent: sourceRect extent).
]

{ #category : #display }
OLPCVirtualScreen >> displayOffset [
	"Answer the offset to apply to events for this display"
	display ifNil:[^0@0].
	^(display extent - (self extent / self displayScale)) // 2

]

{ #category : #display }
OLPCVirtualScreen >> displayScale [
	"Answer the scale to apply to events for this display"
	display ifNil:[^1].
	(zoomOut and: [self canZoomOut]) ifTrue: [^ 1].

	^ width / display width max: height / display height
]

{ #category : #display }
OLPCVirtualScreen >> forceDisplayUpdate [
	display ifNil:[super forceDisplayUpdate] ifNotNil:[display forceDisplayUpdate].
]

{ #category : #display }
OLPCVirtualScreen >> forceToScreen: rect [
	"Update the display"
	| dstRect scale |
	display ifNil:[^super forceToScreen: rect].
	scale := self displayScale.
	"Note: We specifically overestimate the clip rect to avoid roundoff problems"
	dstRect := rect intersect: self boundingBox.
	dstRect := (dstRect origin // scale) truncated - 1 corner: (dstRect corner // scale) truncated + 1.
	dstRect := dstRect translateBy: self displayOffset.
	warpBlt clipRect: dstRect.
	warpBlt warpBits.
	display forceToScreen: dstRect.
	pendingUpdate ifTrue:[
		pendingUpdate := false.
		display forceToScreen.
	].
]

{ #category : #initialize }
OLPCVirtualScreen >> initialize [
	"Initialize the receiver"
	| extent |
	pendingUpdate := false.
	zoomOut := false.
	extent := self class virtualScreenExtent.
	Preferences enablePortraitMode ifTrue: [extent := extent transposed].
	super setExtent: extent depth: self class preferredScreenDepth.
	display := DisplayScreen extent: 1@1
			depth: DisplayScreen actualScreenDepth.
	self checkForNewScreenSize.
	self beDisplay; forceToScreen.
	display forceToScreen. "to capture the borders"
]

{ #category : #testing }
OLPCVirtualScreen >> isVirtualScreen [
	"Am I a virtual display screen?"
	^display notNil
]

{ #category : #initialize }
OLPCVirtualScreen >> prepareToEnter: aProject [
	"We need to instantiate the 'correct' OLPC display size here"
	| extent |
	extent := aProject displayExtent.
	extent = self extent ifFalse:[
		super setExtent: extent depth: depth.
		display deferUpdates: true.
		display fillColor: (Color gray: 0.2).
		display deferUpdates: false.
		"ARGH! This is ugly. We need at least one forceToScreen for display to make sure the pending gray regions get flushed to the display. However, if we do it here, then the project zoom will show flicker (this is why we defer updates in the abov code). But if we don't use the zoom, then we never get any information that the project was successfully entered (and some remnants of the previous project will remain). Therefore, we set a flag here and if the project zoom is triggered then it gets reset. Otherwise, we'll flush the entire display the next time anything gets to be redrawn (which is immediately after entering a new project)"
		pendingUpdate := true.
		self setupWarp.
	].
]

{ #category : #copying }
OLPCVirtualScreen >> reverse: rect [
	super reverse: rect.
	self forceToScreen: rect.
]

{ #category : #private }
OLPCVirtualScreen >> setExtent: aPoint depth: bitsPerPixel [
	"We trap this (otherwise ignored) entry point to get informaed about system startup and display installation."
	display ifNil:[self initialize].
]

{ #category : #initialize }
OLPCVirtualScreen >> setupWarp [
	warpBlt := WarpBlt toForm: display.
	warpBlt sourceForm: self.
	warpBlt cellSize: 2.
	warpBlt combinationRule: Form over.
	warpBlt sourceForm: self destRect: (self displayOffset extent: self extent // self displayScale).

]

{ #category : #initialize }
OLPCVirtualScreen >> shrink [
	"Shut me down for saving the image"
	display ifNotNil: [display shrink].
	bits  := nil.

]

{ #category : #transitions }
OLPCVirtualScreen >> zoomIn: goingIn orOutTo: otherImage at: topLeft vanishingPoint: vp [
	"Make sure we cover the full display here"
	| otherDisplay otherWarp otherOffset otherScale |
	pendingUpdate := false.
	otherDisplay := Form extent: display extent depth: 32.
	otherDisplay fillColor: (Color gray: 0.2).
	otherScale := (otherImage width / otherDisplay width 
					max: otherImage height / otherDisplay height) max: 1.

	otherOffset := otherDisplay extent - (otherImage extent / otherScale) // 2.

	otherWarp := WarpBlt toForm: otherDisplay.
	otherWarp sourceForm: otherImage.
	otherWarp cellSize: 2.
	otherWarp combinationRule: Form over.
	otherWarp sourceForm: otherImage destRect: (otherOffset extent: otherImage extent // otherScale).
	otherWarp warpBits.
	display zoomIn: goingIn orOutTo: otherDisplay 
		at: 0@0 vanishingPoint: (vp // self displayScale)+self displayOffset.

]

{ #category : #display }
OLPCVirtualScreen >> zoomOut [

	^ zoomOut
]

{ #category : #display }
OLPCVirtualScreen >> zoomOut: aBoolean [

	"When the physical display is bigger than the virtual display size, we have two options.  One is to zoom in and maximize the visible area and another is to map a pixel to a pixel and show it in smaller area (at the center of screen).  This flag governs them."

	self canZoomOut ifFalse: [^ self].
	zoomOut := aBoolean.
	display fillColor: (Color gray: 0.2). 
	self setupWarp; forceToScreen.
	display forceToScreen. "to capture the borders"
	Project current world restoreMorphicDisplay.
	Project current world repositionFlapsAfterScreenSizeChange.

]
