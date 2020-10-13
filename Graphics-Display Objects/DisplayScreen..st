"
There is only one instance of me, Display. It is a global and is used to handle general user requests to deal with the whole display screen. 
	Although I offer no protocol, my name provides a way to distinguish this special instance from all other Forms. This is useful, for example, in dealing with saving and restoring the system.
	To change the depth of your Display...
		Display newDepth: 16.
		Display newDepth: 8.
		Display newDepth: 1.
Valid display depths are 1, 2, 4, 8, 16 and 32.  It is suggested that you run with your monitors setting the same, for better speed and color fidelity.  Note that this can add up to 4Mb for the Display form.  Finally, note that newDepth: ends by executing a 'ControlManager restore' which currently terminates the active process, so nothing that follows in the doit will get executed.

Depths 1, 2, 4 and 8 bits go through a color map to put color on the screen, but 16 and 32-bit color use the pixel values directly for RGB color (5 and 8 bits per, respectivlely).  The color choice an be observed by executing Color fromUser in whatever depth you are using.

"
Class {
	#name : #DisplayScreen,
	#superclass : #Form,
	#instVars : [
		'clippingBox',
		'extraRegions'
	],
	#classVars : [
		'DeferringUpdates',
		'DisplayChangeSignature',
		'DisplayIsFullScreen'
	],
	#category : #'Graphics-Display Objects'
}

{ #category : #snapshots }
DisplayScreen class >> actualScreenDepth [
	<primitive: 'primitiveScreenDepth'>
	^ Display depth
]

{ #category : #snapshots }
DisplayScreen class >> actualScreenSize [
	<primitive: 106>
	^ 640@480
]

{ #category : #'display box access' }
DisplayScreen class >> boundingBox [
	"Answer the bounding box for the form representing the current display 
	screen."

	^Display boundingBox
]

{ #category : #'display box access' }
DisplayScreen class >> checkForNewScreenSize [
	"Check whether the screen size has changed and if so take appropriate actions"

	Display isVirtualScreen ifTrue: [^Display checkForNewScreenSize].

	Display extent = DisplayScreen actualScreenSize
		ifFalse: [Display restore].
]

{ #category : #'display box access' }
DisplayScreen class >> depth: depthInteger width: widthInteger height: heightInteger fullscreen: aBoolean [
	"Force Squeak's window (if there's one) into a new size and depth."
	"DisplayScreen depth: 8 width: 1024 height: 768 fullscreen: false"

	"August 2019: This method will be deprecated in the future! Use the HostWindowPlugin instead if possible.
	
	This method is still the only way to change the size of the display, when the image is started with the -vm-display-none flag, because
(1) you still have a Display, hurray!, and (2) HostWindowPlugin will refuse to notice that, because you don't have any windows."

	<primitive: 92>
	self primitiveFailed
]

{ #category : #'screen modes' }
DisplayScreen class >> displayIsFullScreen [

	^ DisplayIsFullScreen ifNil: [DisplayIsFullScreen := false]
]

{ #category : #'screen modes' }
DisplayScreen class >> fullScreenOff [

	Display fullScreenMode: (DisplayIsFullScreen := false).
	self checkForNewScreenSize.

]

{ #category : #'screen modes' }
DisplayScreen class >> fullScreenOn [

	Display fullScreenMode: (DisplayIsFullScreen := true).
	self checkForNewScreenSize.
]

{ #category : #'host window access' }
DisplayScreen class >> hostWindowExtent: aPoint [
	
	^ self
		primitiveWindow: self hostWindowIndex
		width: aPoint x
		height: aPoint y
]

{ #category : #'host window access' }
DisplayScreen class >> hostWindowIndex [
	"By convention, the reference to the primary Squeak display window is 1.
	The host window plugin may use different conventions for references to
	windows. In general, the handles for references to host windows should be
	considered as meaningful only to the VM plugin, with host window index 1
	being a special case of a well known handle value."

	^ 1
]

{ #category : #'host window access' }
DisplayScreen class >> hostWindowTitle: aString [

	^ self
		primitiveWindow: self hostWindowIndex
		title: aString squeakToUtf8
]

{ #category : #testing }
DisplayScreen class >> isDeferringUpdates [

	^ DeferringUpdates == true
]

{ #category : #'primitives - host window access' }
DisplayScreen class >> primitiveWindow: id title: titleString [

	<primitive: 'primitiveHostWindowTitle' module: 'HostWindowPlugin'>
	^self primitiveFailed
]

{ #category : #'primitives - host window access' }
DisplayScreen class >> primitiveWindow: id width: width height: height [

	<primitive: 'primitiveHostWindowSizeSet' module: 'HostWindowPlugin'>
	^self primitiveFailed
]

{ #category : #'display box access' }
DisplayScreen class >> setNewScreenSize: aPoint [
	"Ensure that the Display is set to the given extent."
	
	self hostWindowExtent: aPoint.
	self checkForNewScreenSize.
	
	"In the Windows version of the host window plugin, the extent currently includes window decorations. Therefore, we need two attempts to ensure that the Display extent is aPoint. Note that this is a bug in the plugin."
	(Display extent x < aPoint x or: [Display extent y < aPoint y]) ifTrue: [
		self hostWindowExtent: 2*aPoint - Display extent.
		self checkForNewScreenSize].
]

{ #category : #'screen modes' }
DisplayScreen class >> toggleFullScreen [
	"Toggle between full screen and windowed mode."
	
	self displayIsFullScreen
		ifTrue: [self fullScreenOff]
		ifFalse: [self fullScreenOn].
]

{ #category : #displaying }
DisplayScreen >> addExtraRegion: aRectangle for: regionDrawer [
	"Register the given rectangle as a region which is drawn by the specified region drawer. The region will be excluded from any updates when #forceDamageToScreen: is called. Note that the rectangle is only valid for a single update cycle; once #forceDamageToScreen: has been called, the region drawer and its region are being removed from the list"
	extraRegions ifNil:[extraRegions := #()].
	extraRegions := extraRegions copyWith: (Array with: regionDrawer with: aRectangle).

]

{ #category : #private }
DisplayScreen >> beDisplay [
	"Primitive. Tell the interpreter to use the receiver as the current display 
	image. Fail if the form is too wide to fit on the physical display. 
	Essential. See Object documentation whatIsAPrimitive."

	<primitive: 102>
	self primitiveFailed
]

{ #category : #other }
DisplayScreen >> boundingBox [
	clippingBox == nil
		ifTrue: [clippingBox := super boundingBox].
	^ clippingBox
]

{ #category : #other }
DisplayScreen >> clippingTo: aRect do: aBlock [
	"Display clippingTo: Rectangle fromUser do:
	[ScheduledControllers restore: Display fullBoundingBox]"
	| saveClip |
	saveClip := clippingBox.
	clippingBox := aRect.
	aBlock value.
	clippingBox := saveClip
]

{ #category : #displaying }
DisplayScreen >> copyBits: rect from: sf at: destOrigin clippingBox: clipRect rule: cr fillColor: hf [ 
	(BitBlt
		destForm: self
		sourceForm: sf
		fillColor: hf
		combinationRule: cr
		destOrigin: destOrigin
		sourceOrigin: rect origin
		extent: rect extent
		clipRect: (clipRect intersect: clippingBox)) copyBits
]

{ #category : #displaying }
DisplayScreen >> copyBits: rect from: sf at: destOrigin clippingBox: clipRect rule: cr fillColor: hf map: map [
	((BitBlt
		destForm: self
		sourceForm: sf
		fillColor: hf
		combinationRule: cr
		destOrigin: destOrigin
		sourceOrigin: rect origin
		extent: rect extent
		clipRect: (clipRect intersect: clippingBox)) colorMap: map) copyBits
]

{ #category : #private }
DisplayScreen >> copyFrom: aForm [
	"Take on all state of aForm, with complete sharing"

	super copyFrom: aForm.
	clippingBox := super boundingBox
]

{ #category : #'blitter defaults' }
DisplayScreen >> defaultBitBltClass [
	"Return the BitBlt version to use when I am active"
	^BitBlt
]

{ #category : #'blitter defaults' }
DisplayScreen >> defaultWarpBltClass [
	"Return the WarpBlt version to use when I am active"
	^WarpBlt
]

{ #category : #other }
DisplayScreen >> deferUpdates: aBoolean [
	| wasDeferred |
	"Set the deferUpdates flag in the virtual machine. When this flag is true, BitBlt operations on the Display are not automatically propagated to the screen. If this underlying platform does not support deferred updates, this primitive will fail. Answer whether updates were deferred before if the primitive succeeds, nil if it fails."

	wasDeferred := DeferringUpdates == true.
	DeferringUpdates := aBoolean.
	^(self primitiveDeferUpdates: aBoolean) ifNotNil: [wasDeferred]
]

{ #category : #other }
DisplayScreen >> deferUpdatesIn: aRectangle while: aBlock [
	| result |
	(self deferUpdates: true) ifTrue: [^aBlock value].
	result := aBlock value.
	self deferUpdates: false.
	self forceToScreen: aRectangle.
	^result
]

{ #category : #other }
DisplayScreen >> displayChangeSignature [

	^DisplayChangeSignature
]

{ #category : #private }
DisplayScreen >> findAnyDisplayDepth [
	"Return any display depth that is supported on this system."
	^self findAnyDisplayDepthIfNone:[
		"Ugh .... now this is a biggie - a system that does not support
		any of the Squeak display depths at all."
		Smalltalk
			logSqueakError:'Fatal error: This system has no support for any display depth at all.'
			inContext: thisContext .
		Smalltalk quitPrimitive. "There is no way to continue from here"
	].
]

{ #category : #private }
DisplayScreen >> findAnyDisplayDepthIfNone: aBlock [
	"Return any display depth that is supported on this system.
	If there is none, evaluate aBlock."
	#(1 2 4 8 16 32 -1 -2 -4 -8 -16 -32) do:[:bpp|
		(self supportsDisplayDepth: bpp) ifTrue:[^bpp].
	].
	^aBlock value
]

{ #category : #displaying }
DisplayScreen >> flash: aRectangle [ 
	"Flash the area of the screen defined by the given rectangle."

	self reverse: aRectangle.
	self forceDisplayUpdate.
	(Delay forMilliseconds: 50) wait.
	self reverse: aRectangle.
	self forceDisplayUpdate.

]

{ #category : #displaying }
DisplayScreen >> flash: aRectangle andWait: msecs [
	"Flash the area of the screen defined by the given rectangle."

	self reverse: aRectangle.
	self forceDisplayUpdate.
	(Delay forMilliseconds: msecs) wait.
	self reverse: aRectangle.
	self forceDisplayUpdate.
	(Delay forMilliseconds: msecs) wait.

]

{ #category : #displaying }
DisplayScreen >> flashAll: rectangleList andWait: msecs [
	"Flash the areas of the screen defined by the given rectangles."

	rectangleList do: [:aRectangle | self reverse: aRectangle].
	self forceDisplayUpdate.
	(Delay forMilliseconds: msecs) wait.
	rectangleList do: [:aRectangle | self reverse: aRectangle].
	self forceDisplayUpdate.
	(Delay forMilliseconds: msecs) wait.

]

{ #category : #displaying }
DisplayScreen >> forceDamageToScreen: allDamage [
	"Force all the damage rects to the screen."
	| regions rectList |
	rectList := allDamage.
	"Note: Reset extra regions at the beginning to prevent repeated errors"
	regions := extraRegions.
	extraRegions := nil.
	regions ifNotNil:[
		"exclude extra regions"
		regions do:[:drawerAndRect| | excluded remaining |
			excluded := drawerAndRect at: 2.
			remaining := WriteStream on: #().
			rectList do:[:r|
				remaining nextPutAll:(r areasOutside: excluded)].
			rectList := remaining contents].
	].
	rectList do:[:r| self forceToScreen: r].
	regions ifNotNil:[
		"Have the drawers paint what is needed"
		regions do:[:drawerAndRect| (drawerAndRect at: 1) forceToScreen].
	].
]

{ #category : #other }
DisplayScreen >> forceDisplayUpdate [
	"On platforms that buffer screen updates, force the screen to be updated immediately. On other platforms, or if the primitive is not implemented, do nothing."

	<primitive: 231>
	"do nothing if primitive fails"
]

{ #category : #other }
DisplayScreen >> forceToScreen [
	"Force the entire display area to the screen"
	^self forceToScreen: self boundingBox
]

{ #category : #other }
DisplayScreen >> forceToScreen: aRectangle [
	"Force the given rectangular section of the Display to be copied to the screen. The primitive call does nothing if the primitive is not implemented. Typically used when the deferUpdates flag in the virtual machine is on; see deferUpdates:."

	self primShowRectLeft: aRectangle left
		right: aRectangle right
		top: aRectangle top
		bottom: aRectangle bottom.

]

{ #category : #other }
DisplayScreen >> fullBoundingBox [
	^ super boundingBox
]

{ #category : #other }
DisplayScreen >> fullScreenMode: aBoolean [
	"On platforms that support it, set full-screen mode to the value of the argument. (Note: you'll need to restore the Display after calling this primitive."
	"Display fullScreenMode: true. Display newDepth: Display depth"

	<primitive: 233>
	self primitiveFailed

]

{ #category : #other }
DisplayScreen >> height [
	^ self boundingBox height
]

{ #category : #testing }
DisplayScreen >> isDisplayScreen [
	^true
]

{ #category : #other }
DisplayScreen >> newDepth: pixelSize [
"
	Display newDepth: 8.
	Display newDepth: 1.
"
	| area need |
	
	(self supportsDisplayDepth: pixelSize)
		ifFalse:[^self inform:'Display depth ', pixelSize printString, ' is not supported on this system'].

	pixelSize = self nativeDepth ifTrue: [^ self  "no change"].
	pixelSize abs < self depth ifFalse:
		["Make sure there is enough space"
		area := self boundingBox area. "pixels"

		need := (area * (pixelSize abs - self depth) // 8)  "new bytes needed"
				+ Smalltalk lowSpaceThreshold.
		(Smalltalk garbageCollectMost <= need
			and: [Smalltalk garbageCollect <= need])
			ifTrue: [self error: 'Insufficient free space']].

	Display setExtent: Display extent depth: pixelSize.
	Display beDisplay.

	Project current ifNotNil: [:p |
		p
			displayDepthChanged;
			displaySizeChanged].
]

{ #category : #'disk I\/O' }
DisplayScreen >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a reference to the Display in the other system instead.  "

	"A path to me"
	dp := DiskProxy global: #Display selector: #yourself args: #().
	refStrm replace: self with: dp.
	^ dp

]

{ #category : #private }
DisplayScreen >> primRetryShowRectLeft: l right: r top: t bottom: b [
	"Copy the given rectangular section of the Display to to the screen. This primitive is not implemented on all platforms. Do nothing if it fails. "

	<primitive: 127>
	"do nothing if primitive fails"

]

{ #category : #private }
DisplayScreen >> primShowRectLeft: l right: r top: t bottom: b [
	"Copy the given rectangular section of the Display to to the screen. This primitive is not implemented on all platforms. If this fails, retry integer coordinates."

	<primitive: 127>
	"if this fails, coerce coordinates to integers and try again"
	self primRetryShowRectLeft: l truncated
		right: r rounded
		top: t truncated
		bottom: b rounded.

]

{ #category : #other }
DisplayScreen >> primSupportsDisplayDepth: pixelDepth [
	"Return true if this pixel depth is supported on the current host platform.
	Primitive. Optional."
	<primitive: 91>
	^#(1 2 4 8 16 32) includes: pixelDepth
]

{ #category : #other }
DisplayScreen >> primitiveDeferUpdates: aBoolean [
	"Set the deferUpdates flag in the virtual machine. When this flag is true, BitBlt operations on the Display are not automatically propagated to the screen. If this underlying platform does not support deferred updates, this primitive will fail. Answer the receiver if the primitive succeeds, nil if it fails."

	<primitive: 126>
	^ nil  "answer nil if primitive fails"

]

{ #category : #'initialize-release' }
DisplayScreen >> release [
	"I am no longer Display. Release any resources if necessary"
]

{ #category : #other }
DisplayScreen >> restore [

	self setExtent: self class actualScreenSize depth: self nativeDepth.
	self beDisplay.
	
	Project current ifNotNil: [:p| p displaySizeChanged].
]

{ #category : #other }
DisplayScreen >> restoreAfter: aBlock [
	"Evaluate the block, wait for a mouse click, and then restore the screen."

	aBlock ensure: [
		Sensor waitButton.
		self restore].
]

{ #category : #private }
DisplayScreen >> setExtent: aPoint depth: bitsPerPixel [  "DisplayScreen startUp"
	"This method is critical.  If the setExtent fails, there will be no
	proper display on which to show the error condition..."
	"ar 5/1/1999: ... and that is exactly why we check for the available display depths first."

	"RAA 27 Nov 99 - if depth and extent are the same and acceptable, why go through this.
	also - record when we change so worlds can tell if it is time to repaint"

	(depth == bitsPerPixel and: [aPoint = self extent and: 
					[self supportsDisplayDepth: bitsPerPixel]]) ifFalse: [
		bits := nil.  "Free up old bitmap in case space is low"
		DisplayChangeSignature := (DisplayChangeSignature ifNil: [0]) + 1.
		(self supportsDisplayDepth: bitsPerPixel)
			ifTrue:[super setExtent: aPoint depth: bitsPerPixel]
			ifFalse:[(self supportsDisplayDepth: bitsPerPixel negated)
				ifTrue:[super setExtent: aPoint depth: bitsPerPixel negated]
				ifFalse:["Search for a suitable depth"
					super setExtent: aPoint depth: self findAnyDisplayDepth]].
	].
	clippingBox := super boundingBox
]

{ #category : #'initialize-release' }
DisplayScreen >> shrink [ 
	"Reduce the memory footprint of this display object before being stored into the .image file."
	
	self setExtent: 240@120 depth: self depth.
]

{ #category : #other }
DisplayScreen >> supportedDisplayDepths [
	"Return all pixel depths supported on the current host platform."
	^#(1 2 4 8 16 32 -1 -2 -4 -8 -16 -32) select: [:d | self supportsDisplayDepth: d]
]

{ #category : #other }
DisplayScreen >> supportsDisplayDepth: pixelDepth [
	"Return true if this pixel depth is supported on the current host platform."
	Smalltalk platformName = 'Mac OS' ifTrue: [^pixelDepth abs = 32]. "Work around VM bug"
	^self primSupportsDisplayDepth: pixelDepth
]

{ #category : #other }
DisplayScreen >> usableArea [
	"Answer the usable area of the receiver.  5/22/96 sw."

	^ self boundingBox deepCopy
]

{ #category : #other }
DisplayScreen >> width [
	^ self boundingBox width
]
