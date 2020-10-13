"
INTRODUCTION
=========

WebCamMorph together with CameraPlugin (originally from MIT Scratch) provides an easy and cross platform way to use webcam input in Squeak and Etoys. The first version has been created specifically with Etoys in mind. To view a live feed simply drag a ""WebCam"" tile from the ""WebCam"" category in the objects tool. Open up a viewer on the morph and display the ""camera settings"" category to explore the following basic settings:

	""camera is on"": turn the camera on/off.

	""camera number"": usually the default of ""1"" is ok but if you have more than one camera connected then adjust between 1 and 9 for other instances of WebCamMorph.

	""max fps"": leave as is for now. It is unusual for webcams to capture at higher than 30fps. See later for further explanation of how fps is controlled.

	""actual fps"": read-only. Indicates the actual fps being achieved which can depend significantly on lighting conditions and capture resolution...

	""resolution"": webcams can have a range of resolutions but for simplicity three are supported: ""low"" (160x120), ""medium"" (320x240) and ""high"" (640x480). Adjust in good lighting to see if ""actual fps"" increases. 

	""use frame size"": the resolution used for capturing can differ from the resolution used for display. If this setting is true then WebCamMorph is resized to match the camera resolution. If false then you are free to resize it however you want (via the ""resize"" halo button, use shift to preserve aspect ratio)


Beyond viewing a live feed WebCamMorph has been designed to support different uses including simple effects, time-lapse photography, stop-motion animation, character recognition, motion detection and more complex processing of every frame for feature detection. The following information is to help you understand how and why WebCamMorph operates so you can adjust it for your particular needs.


""FRAMES PER SECOND"", LIGHTING & CAMERA RESOLUTION
==================================

The maximum possible frame rate depends on many factors, some of which are outside of our control. Frame rates differ between cameras and usually depend significantly on chosen resolution and lighting conditions. To ensure a balance between capturing every available frame and keeping everything else responsive, WebCamMorph dynamically adjusts the delay between capturing one frame and the next (does not apply when in ""manual capture"" mode, see later). 

WebCams often include automatic compensation for lighting conditions. In low lighting it takes significantly more time for the camera to get a picture than it does in good lighting conditions. For example 30fps may be possible with good lighting compared to 7fps in low lighting. So for best capture rates ensure you have good lighting! 

Cameras have a ""native"" resolution at which frame rates are usually better than for other resolutions. Note though that the native resolution might be *higher*
than the *minimum* resolution available. It pays to experiment with different resolutions to find which one results in the highest frame rate. Use good lighting conditions when experimenting with resolutions.


""MANUAL CAPTURE"" MODE
===============

In simply usage WebCamMorph automatically captures a frame and displays it. To support Etoys scripting a ""manual capture"" mode is provided where you or your script determines when to capture, when to apply effects (or not) and when to update the display. In between these steps you can do anything you want. Note that frames rates will be lower than that in automatic capture mode and that ""skip frames"" (described next) will need adjusting at very low capture rates.

Tip: In manual mode the camera can be turned off. It will be turned on automatically when required and return to it's previous state after a frame has been captured. For capture periods of five seconds or more turning the camera off may save power, which can especially useful when running off batteries. For smaller periods leaving the camera on will avoid some delays and could help speed up webcam related scripts.


""SKIP FRAMES""
========

Webcams and their drivers are typically designed for streaming live video and use internal buffering to help speed things up. At low capture rates the picture can appear to lag real-time because what you see is the next available buffer not the *latest* buffer. So for example if you capture a frame every ten seconds and there are three buffers being used then what you actually see may be thirty seconds old. We have little/no control over the number of buffers used and the actual number can vary between cameras and under different circumstances for the same camera. ""skip frames"" is provided to compensate for buffering so increase it when doing ""manual"" capturing until you see what you expect to see. Typically a setting of 8 is enough but I have had to use 20 with one particular camera in low lighting.


""SNAPSHOTS""
========

Where as ""capturing"" is the process of getting an image from the Camera into Squeak/Etoys, a ""snapshot"" preserves whatever is currently displayed (which may be the captured image after effects have been applied). To store snapshots you need to designate a ""holder"" which at the moment can be either a ""holder"" morph or a ""movie"" morph. Create one of these before proceeding. To assign a holder open up a viewer for WebCamMorph, display the ""snapshot"" category and click in the box at the right of the entry called ""snapshot holder"". The cursor will now resemble a cross-hair and can be clicked on the target holder/movie morph. To take a single snapshot at any time click (!) on the left of ""take snapshot"". In auto-capture mode WebCamMorph can also be set to take multiple consecutive snapshots . First, before turning the camera on, set a sensible limit using ""snapshot limit"" (to avoid using all the computers memory) then set ""auto snapshot"" to true. When the camera is next turned on then snapshots are taken for every frame until ""snapshot limit"" becomes zero. ""snapshot limit"" is automatically decremented but not reset to avoid problems (although you are free to reset it manually or via a script).


""EFFECTS"" - WIP
=========

Similar to snapshots, a holder can be designated as the ""effects holder"". This holder is intended to be populated with ""fx"" morphs (coming soon) which will operate on captured frames prior to displaying. Stay tuned ;-)


CLEARING SNAPSHOT & EFFECTS HOLDERS
=========================

Keeping a link to snapshot or effects holders can tie up resources even after the target holders have been deleted and are no longer visible. To ensure this does not happen designate the WebCamMorph itself as the holder (for method see ""snapshots"" section above).


COMING SOON!
=========

- Built-in basic effects such as brightness, contrast and hue.
- Image ""fx"" morphs for effects such as those found in MIT Scratch and many other types of effects/ image processing.
- More snapshot options, eg, store to file
- Demo projects


"
Class {
	#name : #WebCamMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'camNum',
		'camIsOn',
		'frameExtent',
		'displayForm',
		'resolution',
		'useFrameSize',
		'captureDelayMs',
		'showFPS',
		'framesSinceLastDisplay',
		'lastDisplayTime',
		'fps',
		'orientation'
	],
	#category : #'Etoys-Squeakland-MorphicExtras-WebCam'
}

{ #category : #scripting }
WebCamMorph class >> additionsToViewerCategories [
	"Answer a list of (<categoryName> <list of category specs>) pairs that characterize the phrases this kind of morph wishes to add to various Viewer categories."
	^ #(

	(#'camera' (
		(slot resolution '160x120, 320x240, 640x480 or 1280x960' 
			WebCamResolution readWrite Player getWebCamResolution Player setWebCamResolution:)
		(slot orientation 'Natural (mirrored) or navtive (as from the camera' 
			WebCamOrientation readWrite Player getWebCamOrientation Player setWebCamOrientation:)
		(slot cameraIsOn 'Whether the camera is on/off' Boolean readWrite Player getWebCamIsOn Player setWebCamIsOn:)
		(slot useFrameSize 'Resize the player to match the camera''s frame size' 
			Boolean readWrite Player getUseFrameSize Player setUseFrameSize:)
		(slot lastFrame 'A player with the last frame' Player readOnly	Player getLastFrame unused unused)
		(slot showFPS 'Whether to show the samera''s frames per second' Boolean readWrite Player getShowFPS Player setShowFPS:)
		))
)

]

{ #category : #accessing }
WebCamMorph class >> allOff [
	self allInstancesDo: [:each | each off].
]

{ #category : #'parts bin' }
WebCamMorph class >> descriptionForPartsBin [
	^ self
		partName: 'Camera' translatedNoop
		categories: {'Multimedia' translatedNoop}
		documentation: 'Web camera player.' translatedNoop
		sampleImageForm: self icon
]

{ #category : #'parts bin' }
WebCamMorph class >> icon [
	"Original file: imagecodericon.png"

	^ (PNGReadWriter on: (Base64MimeConverter mimeDecodeToBytes: 
'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
/i957VpDfrfOMwAAAABJRU5ErkJggg=='
	readStream) readStream) nextImage

]

{ #category : #'class initialization' }
WebCamMorph class >> initialize [
	"CameraMorph initialize"


	

]

{ #category : #scripting }
WebCamMorph class >> resolutionFor: aSymbol [
	(#(low medium high hd) includes: aSymbol) ifFalse: [^ 320@240].

	^ {160 @ 120. 320 @ 240. 640 @ 480. 1280 @ 960} 
			at: (WebCamResolution resolutions indexOf: aSymbol)

]

{ #category : #accessing }
WebCamMorph class >> shutDown [
	self allOff.

]

{ #category : #accessing }
WebCamMorph class >> startUp [
	"Try to bring up any instances that were on before shutdown"

]

{ #category : #menu }
WebCamMorph >> addCustomMenuItems: aMenu hand: aHandMorph [ 

	super addCustomMenuItems: aMenu hand: aHandMorph.
	aMenu
		addUpdating: #cameraToggleString action: #toggleCameraOnOff;
		addLine;
		add: 'resolution...' translated subMenu: ([:menu |
			WebCamResolution resolutions do: [:res |
				menu
					add: (resolution == res ifTrue: ['<on>'] ifFalse: ['<off>']), res translated
					selector: #setWebCamResolution:
					argument: res].
			menu] value: (aMenu class new defaultTarget: aMenu defaultTarget));
		add: 'orientation...' translated subMenu: ([:menu |
			WebCamOrientation orientations do: [:ori |
				menu
					add: (orientation == ori ifTrue: ['<on>'] ifFalse: ['<off>']), ori translated
					selector: #setWebCamOrientation:
					argument: ori].
			menu] value: (aMenu class new defaultTarget: aMenu defaultTarget));
		addUpdating: #frameSizeToggleString action: #toggleUseFrameSize;
		addUpdating: #showFPSToggleString action: #toggleShowFPS;
		yourself

]

{ #category : #accessing }
WebCamMorph >> cameraIsOn [
	^camIsOn
]

{ #category : #accessing }
WebCamMorph >> cameraNumber [
	^camNum
]

{ #category : #accessing }
WebCamMorph >> cameraNumber: anInteger [
	camNum ~= anInteger ifTrue:
		[camNum := anInteger.
		 self initializeDisplayForm]
]

{ #category : #menu }
WebCamMorph >> cameraToggleString [

	^ camIsOn
		ifTrue: ['<on>', 'turn camera off' translated]
		ifFalse: ['<off>', 'turn camera on' translated].
	

	

]

{ #category : #accessing }
WebCamMorph >> decreaseCaptureDelay [

	captureDelayMs := (captureDelayMs - 1) min: 200.
]

{ #category : #'submorphs-add\/remove' }
WebCamMorph >> delete [
	self off.
	super delete
]

{ #category : #drawing }
WebCamMorph >> drawCameraImageOn: aCanvas [
	| scale offset |
	offset :=  0 @ 0.
	scale := 1 @ 1.
	bounds extent = displayForm extent
		ifFalse: [scale := bounds extent  / displayForm extent].
	orientation == #natural
		ifTrue: [
			scale := scale x negated @ scale y.
			offset := bounds width @ 0].
	1 @ 1 = scale
		ifTrue: [aCanvas drawImage: displayForm at: bounds origin + offset]
		ifFalse: [aCanvas
			warpImage: displayForm
			transform: (MatrixTransform2x3 withScale: scale)
			at: bounds origin + offset].

]

{ #category : #drawing }
WebCamMorph >> drawFPSOn: aCanvas [
	showFPS ifFalse: [^self].
	aCanvas
		drawString: 'FPS: ', fps asString
		at: bounds bottomLeft + (5 @ -20)
		font: Preferences windowTitleFont
		color: Color white
]

{ #category : #drawing }
WebCamMorph >> drawOn: aCanvas [ 
	camIsOn ifFalse:
		[self initializeDisplayForm.
		 self on].
	camIsOn ifTrue:
		[(CameraInterface frameExtent: camNum) ~= displayForm extent ifTrue:
			[self initializeDisplayForm]].
	displayForm ifNil:
		[self initializeDisplayForm].
	useFrameSize ifTrue: [self extent: frameExtent].
	self drawCameraImageOn: aCanvas.
	self drawFPSOn: aCanvas.
	self drawOverlayTextOn: aCanvas
]

{ #category : #drawing }
WebCamMorph >> drawOverlayTextOn: aCanvas [
	camIsOn ifTrue: [^self].
	aCanvas
		drawString: 'Camera is off' translated
		at: bounds origin + (5 @ 2)
		font: Preferences windowTitleFont
		color: Color white.
]

{ #category : #menu }
WebCamMorph >> frameSizeToggleString [

	^ (useFrameSize ifTrue: ['<on>'] ifFalse: ['<off>']), 'use frame size' translated

	

]

{ #category : #'e-toy - settings' }
WebCamMorph >> getLastFrame [

	
	^ SketchMorph withForm: displayForm deepCopy
]

{ #category : #'e-toy - settings' }
WebCamMorph >> getShowFPS [
	^ showFPS

]

{ #category : #'e-toy - settings' }
WebCamMorph >> getUseFrameSize [
	^ useFrameSize

]

{ #category : #'e-toy - settings' }
WebCamMorph >> getWebCamIsOn [

	^ camIsOn
]

{ #category : #'e-toy - settings' }
WebCamMorph >> getWebCamResolution [
	^ resolution
			

]

{ #category : #accessing }
WebCamMorph >> increaseCaptureDelay [

	captureDelayMs := (captureDelayMs + 1) max: 10.
]

{ #category : #initialization }
WebCamMorph >> initialize [
	super initialize.
	camNum := 1.
	camIsOn := false.
	showFPS := false.
	captureDelayMs := 16. "stepTime"	
	fps := 60. "guess."
	lastDisplayTime := 0.
	framesSinceLastDisplay := 0.
	useFrameSize := false.
	resolution := #medium.
	orientation := #natural.
	frameExtent := self class resolutionFor: resolution
]

{ #category : #initialization }
WebCamMorph >> initializeDisplayForm [
	| cameraExtent formExtent |

	cameraExtent := CameraInterface frameExtent: camNum.
	cameraExtent isZero 
		ifTrue: [formExtent := frameExtent]
		ifFalse: [ | camRatio frameRatio |
			formExtent := cameraExtent.
			camRatio := cameraExtent x / cameraExtent y.
			frameRatio := frameExtent x / frameExtent y.
			camRatio ~= frameRatio ifTrue: [frameExtent := frameExtent x @ (frameExtent x * camRatio reciprocal)]].
	displayForm := Form extent: formExtent depth: 32.
	self extent: frameExtent.

]

{ #category : #initialization }
WebCamMorph >> intoWorld: aWorld [

	super intoWorld: aWorld.
	camIsOn ifTrue: [self on]
					ifFalse:[self off].
	self removeActionsForEvent: #aboutToEnterWorld.
	aWorld
		when: #aboutToLeaveWorld
		send: #outOfWorld:
		to: self
		with: aWorld.
]

{ #category : #testing }
WebCamMorph >> knownName [

	^ CameraInterface cameraName: camNum	
]

{ #category : #'stepping and presenter' }
WebCamMorph >> nextFrame [
	
	| frameCount |
	frameCount := CameraInterface getFrameForCamera: camNum into: displayForm bits.
	frameCount = 0 ifTrue: [self increaseCaptureDelay].
	frameCount > 2 ifTrue: [self decreaseCaptureDelay].
	framesSinceLastDisplay := framesSinceLastDisplay + frameCount
]

{ #category : #accessing }
WebCamMorph >> off [
	self stopStepping.
	camIsOn := false.
	"Be careful not to close the camera if any other morphs are using the same camera."
	(self class allInstances anySatisfy: [:wcm| wcm cameraNumber = camNum and: [wcm cameraIsOn]]) ifFalse:
		[CameraInterface  closeCamera: camNum].
	self changed
	
	"self allInstances select: [:wcm| wcm cameraNumber = 1 and: [wcm cameraIsOn]]"
]

{ #category : #accessing }
WebCamMorph >> on [
	camIsOn ifTrue: [^true].
	(CameraInterface cameraIsOpen: camNum) ifFalse:
		[(CameraInterface openCamera: camNum width: frameExtent x height: frameExtent y) ifNil:
			[^false]].
	"The plugin/camera subsystem may end up choosing a different width and height.
	 So use the width and height it has selected; it may not be what was asked for."
	self initializeDisplayForm.
	CameraInterface waitForCameraStart: camNum.
	camIsOn := true.
	self startStepping
]

{ #category : #initialization }
WebCamMorph >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	camIsOn ifTrue: [self off. camIsOn := true].
	aWorld
		when: #aboutToEnterWorld
		send: #intoWorld:
		to: self
		with: aWorld.
]

{ #category : #'e-toy - settings' }
WebCamMorph >> setShowFPS: aBoolean [
	showFPS := aBoolean

]

{ #category : #'e-toy - settings' }
WebCamMorph >> setUseFrameSize: aBoolean [
	useFrameSize := aBoolean
]

{ #category : #'e-toy - settings' }
WebCamMorph >> setWebCamIsOn: aBoolean [
	aBoolean ifTrue: [self on] ifFalse: [self off]

]

{ #category : #'e-toy - settings' }
WebCamMorph >> setWebCamOrientation: aSymbol [

	((WebCamOrientation orientations) includes: aSymbol) ifFalse: [^ self].
	orientation := aSymbol.
			


]

{ #category : #'e-toy - settings' }
WebCamMorph >> setWebCamResolution: aSymbol [
	| wasOn |
	"Failing silently here is awful; but that's what the code did :-("
	(WebCamResolution resolutions includes: aSymbol) ifFalse: [^ self].
	resolution := aSymbol.

	(wasOn := camIsOn) ifTrue: [self off].
	frameExtent := self class resolutionFor: aSymbol.
	displayForm ifNotNil:
		[displayForm := displayForm scaledToSize: frameExtent].
	self updateDisplay.
     wasOn ifTrue: [self on]

]

{ #category : #menu }
WebCamMorph >> showFPSToggleString [

	^ (showFPS ifTrue: ['<on>'] ifFalse: ['<off>']), 'show fps' translated

	

]

{ #category : #'stepping and presenter' }
WebCamMorph >> step [
	camIsOn ifFalse:[self stopStepping].
	self updateDisplay.
	
									
]

{ #category : #'stepping and presenter' }
WebCamMorph >> stepTime [
	"Answer the desired time between steps in milliseconds"
	^ captureDelayMs

]

{ #category : #menu }
WebCamMorph >> toggleCameraOnOff [
	camIsOn
			ifTrue:[self off]
			ifFalse:[self on]
]

{ #category : #menu }
WebCamMorph >> toggleShowFPS [

	showFPS := showFPS not.

]

{ #category : #menu }
WebCamMorph >> toggleUseFrameSize [

	useFrameSize := useFrameSize not.

]

{ #category : #'stepping and presenter' }
WebCamMorph >> updateDisplay [
	camIsOn ifTrue:[self nextFrame].
	self updateFPS.
	self changed.
]

{ #category : #'stepping and presenter' }
WebCamMorph >> updateFPS [

	| now mSecs |
	now := Time millisecondClockValue.
	mSecs := now - lastDisplayTime.
	(mSecs > 500 or: [mSecs < 0 "clock wrap-around"])
		ifTrue: [
			fps := (framesSinceLastDisplay * 1000) // mSecs.
			lastDisplayTime := now.
			framesSinceLastDisplay := 0].
]
