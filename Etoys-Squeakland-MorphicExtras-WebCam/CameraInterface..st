"
CameraInterface: Simple cross-platform webcam access interface from MIT Scratch. Small changes made so that different cameras can be tested when more than one is connected. The ""CameraPlugin"" binary should soon be included in the VM. On Linux the plugin is designed to take advantage of libv4l2 (if found) to support a wide range of cameras.

Copyright (c) 2009 Massachusetts Institute of Technology

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the ""Software""), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

"
Class {
	#name : #CameraInterface,
	#superclass : #Object,
	#category : #'Etoys-Squeakland-MorphicExtras-WebCam'
}

{ #category : #utilities }
CameraInterface class >> camera: cameraNum framesDo: aBlock while: whileBlock [
	"Evaluate aBlock every time a frame becomes available.  Answer a tuple of frames per second and number of 16ms delays per second.
	 Be destructive; use only one bitmap, overwriting its contents with each successive frame.
	 It is the sender's responsibility to open and close the camera."
	| form bitmap delay start duration frameCount delayCount |
	form := Form
				extent: (self frameExtent: cameraNum)
				depth: 32.
	bitmap := form bits.
	delay := Delay forMilliseconds: (1000 / 60) asInteger. "60 fps is fast"
	start := Time utcMicrosecondClock.
	frameCount := delayCount := 0.
	[[(self camera: cameraNum getParam: 1) <= 0] whileTrue:
		[delay wait. delayCount := delayCount + 1].
	 self getFrameForCamera: cameraNum into: bitmap.
	 frameCount := frameCount + 1.
	 aBlock value: form.
	 whileBlock value] whileTrue.
	^{ frameCount * 1.0e6 / (duration := Time utcMicrosecondClock - start).
		delayCount * 1.0e6 / duration }

	"| cameraNum |
	 self openCamera: (cameraNum := 1) width: 640 height: 480.
	 self waitForCameraStart: cameraNum.
	 [self camera: cameraNum framesDo: [:bitmap| bitmap display] while: [Sensor noButtonPressed]] ensure:
		[self closeCamera: cameraNum]"
]

{ #category : #'camera ops' }
CameraInterface class >> camera: cameraNum getParam: paramNum [
	"Answer the given parameter for the given camera.
		param 1 is the frame count, the number of frames grabbed since the last send of getFrameForCamera:into:
		param 2 is the size of the bitmap in bytes required for an image"

	<primitive: 'primGetParam' module: 'CameraPlugin' error: ec>
	^nil

]

{ #category : #'camera ops' }
CameraInterface class >> camera: cameraNum setSemaphore: semaphoreIndex [
	"Set an external semaphore index through which to signal that a frame is available.
	 Fail if cameraNum does not reference an open camera, or if the platform does not
	 support interrupt-driven frame receipt."
	<primitive: 'primSetCameraSemaphore' module: 'CameraPlugin' error: ec>
	^self primitiveFailed
]

{ #category : #'camera ops' }
CameraInterface class >> cameraIsAvailable [
	"Answer true if at least one camera is available."

	^(self cameraName: 1) notNil

]

{ #category : #'camera ops' }
CameraInterface class >> cameraIsOpen: cameraNum [
	"Answer true if the camera is open."

	^ (self packedFrameExtent: cameraNum) > 0

]

{ #category : #'camera ops' }
CameraInterface class >> cameraName: cameraNum [
	"Answer the name of the given camera. Answer nil if there is no camera with the given number."

	<primitive: 'primCameraName' module: 'CameraPlugin'>
	^ nil

]

{ #category : #'camera ops' }
CameraInterface class >> closeCamera: cameraNum [
	"Close the camera. Do nothing if it was not open."

	<primitive: 'primCloseCamera' module: 'CameraPlugin'>

]

{ #category : #translation }
CameraInterface class >> declareCVarsIn: aCCodeGenerator [
	"self translate"

	super declareCVarsIn: aCCodeGenerator.
	aCCodeGenerator cExtras: '
#include "cameraOps.h"
#include <string.h>
'.
]

{ #category : #'camera ops' }
CameraInterface class >> frameExtent: cameraNum [
	"Answer the frame extent of the currently open camera, or zero if the camera isn't open."

	| packedExtent |
	packedExtent := self packedFrameExtent: cameraNum.
	^ (packedExtent bitShift: -16) @ (packedExtent bitAnd: 16rFFFF) 
]

{ #category : #'camera ops' }
CameraInterface class >> getFrameForCamera: cameraNum into: aBitmap [
	"Copy a camera frame into the given Bitmap. The Bitmap should be a Form of depth 32 that is the same width and height as the current camera frame. Fail if the camera is not open or if the bitmap is not the right size. If successful, answer the number of frames received from the camera since the last call. If this is zero, then there has been no change."

	<primitive: 'primGetFrame' module: 'CameraPlugin'>
	^ 0
]

{ #category : #test }
CameraInterface class >> interruptDrivenVideoTest: camNum [
	"A quick test of video input. Displays video on the screen until the mouse is pressed.
	 Answer nil if the interrupt-driven interface is unavailable."
	"self interruptDrivenVideoTest: 1"
	"self interruptDrivenVideoTest: 2"
	"[self interruptDrivenVideoTest: 2] fork.
	  self interruptDrivenVideoTest: 1"

	| semaphore height |
	height := 16.
	1 to: camNum - 1 do:
		[:camIndex| "N.B. the of an unopened camera is 0@0"
		height := height + (CameraInterface frameExtent: camIndex) y + 16].
	(CameraInterface cameraIsOpen: camNum) ifFalse:
		[(CameraInterface openCamera: camNum width: 352 height: 288) ifNil:
			[self inform: 'no camera'.
			 ^nil]].
	semaphore := Semaphore new.
	[CameraInterface camera: camNum setSemaphore: (Smalltalk registerExternalObject: semaphore)]
		on: Error
		do: [:err|
			Smalltalk unregisterExternalObject: semaphore.
			self inform: 'interrupt-driven camera interface unavailable: ', err messageText.
			^nil].
	[| f n startTime frameCount msecs fps |
	 [semaphore wait.
	 "N.B. the frame extent may not be known until the delivery of the first frame.
	  Si we have to delay initialization."
	  startTime ifNil:
		[(self frameExtent: camNum) x = 0 ifTrue: [self inform: 'no camera'. ^nil].
		 f := Form extent: (CameraInterface frameExtent: camNum) depth: 32.
		 frameCount := 0.
		 startTime := Time millisecondClockValue].
	  Sensor anyButtonPressed] whileFalse:
		[n := CameraInterface getFrameForCamera: camNum into: f bits.
		n > 0 ifTrue:
			[frameCount := frameCount + 1.
			 f displayAt: 16 @ height]].
	 msecs := Time millisecondClockValue - startTime.
	 fps := (frameCount * 1000) // msecs.
	 ^frameCount printString, ' frames at ', fps printString, ' frames/sec']
		ensure:
			[CameraInterface closeCamera: camNum.
			 Smalltalk unregisterExternalObject: semaphore.
			 Sensor waitNoButton]
]

{ #category : #'camera ops' }
CameraInterface class >> openCamera: cameraNum width: frameWidth height: frameHeight [
	"Open the given camera requesting the given frame dimensions. The camera number is usually 1 since you typically have only one camera plugged in. If the camera does not support the exact frame dimensions, an available frame size with width >= the requested width is selected."

	<primitive: 'primOpenCamera' module: 'CameraPlugin'>
	^ nil

]

{ #category : #'camera ops' }
CameraInterface class >> packedFrameExtent: cameraNum [
	"Answer the extent of the currently open camera packed in an integer. The top 16 bits are the width, the low 16 bits are the height. Answer zero if the camera isn't open."

	<primitive: 'primFrameExtent' module: 'CameraPlugin'>
	^ 0

]

{ #category : #test }
CameraInterface class >> videoTest: camNum [
	"A quick test of video input. Displays video on the screen until the mouse is pressed."
	"self videoTest: 1"
	"self videoTest: 2"

	| f n startTime frameCount msecs fps |
	(CameraInterface openCamera: camNum width: 320 height: 240) ifNil: [^ self inform: 'no camera'].
	self waitForCameraStart: camNum.
	(self frameExtent: camNum) x = 0 ifTrue: [^ self inform: 'no camera'].
	f := Form extent: (CameraInterface frameExtent: camNum) depth: 32.
	frameCount := 0.
	startTime := nil.
	[Sensor anyButtonPressed] whileFalse: [
		n := CameraInterface getFrameForCamera: camNum into: f bits.
		n > 0 ifTrue: [
			startTime ifNil: [startTime := Time millisecondClockValue].
			frameCount := frameCount + 1.
			f display]].
	Sensor waitNoButton.
	msecs := Time millisecondClockValue - startTime.
	CameraInterface closeCamera: camNum.
	fps := (frameCount * 1000) // msecs.
	^ frameCount printString, ' frames at ', fps printString, ' frames/sec'
]

{ #category : #'camera ops' }
CameraInterface class >> waitForCameraStart: camNum [
	"Wait for the camera to get it's first frame (indicated by a non-zero frame extent. Timeout after a few seconds."
	"self waitForCameraStart"

	| startTime |
	startTime := Time millisecondClockValue.
	[(Time millisecondClockValue - startTime) < 2000] whileTrue: [
		(self packedFrameExtent: camNum) > 0 ifTrue: [^ self].
		(Delay forMilliseconds: 50) wait].
]
