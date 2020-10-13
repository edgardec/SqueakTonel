"
A subclass of DisplayScreen that uses a (platform appropriate) HostWindowProxy
to do its displaying in a separate host OS window. This is just one example of a
client for HostWindowProxy.
See #test #test2 and HostWindowTests for example usage.
"
Class {
	#name : #DisplayHostWindow,
	#superclass : #DisplayScreen,
	#instVars : [
		'windowProxy',
		'title',
		'windowType',
		'eventQueue'
	],
	#pools : [
		'EventSensorConstants'
	],
	#category : #'Graphics-External-Ffenestri'
}

{ #category : #examples }
DisplayHostWindow class >> examplePaint [
	"DisplayHostWindow examplePaint inspect"
	"Should
		a) open a window
		b) fork a process to allow painting with mouse
		c) survive saving and re-opening the image
		d) close and terminate the process when clicking close box or pressing ESC or garbage collect
	This relies on the Morphic main loop repeatedly fetching events from Sensor.
	"
	| win evt pen |
	win := DisplayHostWindow extent: 400@400 depth: 32.
	win offset: 50@50; open; windowTitle: 'Paint Test'.
	pen := nil.
	[
		[win isOpen] whileTrue: [
			evt := win nextEvent.
			"check for ESC event"
			((evt at: 1) = EventTypeKeyboard and: [(evt at: 4) = EventKeyChar and: [(evt at: 3) = 27]])
				ifTrue: [win close].
			"process for mouse events"
			(evt at: 1) = EventTypeMouse ifTrue: [
				(evt at: 5) > 0	"button pressed"
					ifTrue: [
						pen ifNil: [
							pen := Pen newOnForm: win.
							pen roundNib: 5; color: Color random.
							pen place: (evt at: 3)@(evt at: 4)].
						pen goto: (evt at: 3)@(evt at: 4)]
					ifFalse: [pen := nil]].
			win forceToScreen.
		].
	] forkNamed: thisContext asString.
	^win
]

{ #category : #snapshots }
DisplayHostWindow >> actualScreenSize [
"return the host window size as if it were 'the' screen"
	^self windowSize
]

{ #category : #'initialize-release' }
DisplayHostWindow >> close [
	"close this window"
	windowProxy ifNil: [ ^ self error: 'cannot close never opened window' ].
	"We don't use 'self windowProxy close' here because if we've never setup the window why do it now only to close it immediately?"
	windowProxy close.
	windowProxy := nil
]

{ #category : #accessing }
DisplayHostWindow >> eventQueue [
	^eventQueue ifNil: [eventQueue := SharedQueue new]

]

{ #category : #'basic api' }
DisplayHostWindow >> forceToScreen [
	"update the area defined by my bounds"
	self forceToScreen: self boundingBox
]

{ #category : #'basic api' }
DisplayHostWindow >> forceToScreen: damageRectangle [ 
	"update the area defined by damageRectangle"
	windowProxy ifNotNil:[ windowProxy forceToScreen: damageRectangle]
]

{ #category : #'private-events' }
DisplayHostWindow >> handleActivated [
	"window made active - some platforms only - do not rely upon this"
]

{ #category : #'private-events' }
DisplayHostWindow >> handleClose [
	"window close icon pressed"

	self close.

]

{ #category : #'private-events' }
DisplayHostWindow >> handleIconise [
	"window iconised or hidden etc"
]

{ #category : #'private-events' }
DisplayHostWindow >> handleMetricChange: aRectangle [
	"size or position of window changed"

	offset := aRectangle origin.

	(width = aRectangle width and: [height = aRectangle height])
		ifFalse: [self setExtent: aRectangle extent depth: depth].

]

{ #category : #'private-events' }
DisplayHostWindow >> handlePaint: aRectangle [
	"window area needs updating. Some platforms do not need to send this, do not rely on it in image"

	self forceToScreen: aRectangle.

]

{ #category : #accessing }
DisplayHostWindow >> isOpen [
	^windowProxy notNil
]

{ #category : #accessing }
DisplayHostWindow >> nextEvent [
	^self eventQueue next
]

{ #category : #accessing }
DisplayHostWindow >> nextEventOrNil [
	^self eventQueue nextOrNil
]

{ #category : #'initialize-release' }
DisplayHostWindow >> open [
	"open the host window"
	windowProxy ifNil: [ windowProxy := HostWindowProxy on: self ].
	windowType ifNil: [ windowType := #defaultWindowType ].
	windowProxy perform: windowType.
	windowProxy open.
	title ifNotNil: [ windowProxy windowTitle: title ].

]

{ #category : #'private-events' }
DisplayHostWindow >> processEvent: evt [
	"evt is a raw event buffer from VM. Check for window events (close etc.). Queue events if queue exists"
	(evt at: 1) = EventTypeWindow
		ifTrue: [self processWindowEvent: evt].
	self queueEvent: evt.

]

{ #category : #'private-events' }
DisplayHostWindow >> processWindowEvent: evt [
	(evt at: 3) caseOf: {
		[WindowEventMetricChange] -> [self handleMetricChange: ((evt at: 4)@(evt at: 5) corner: (evt at: 6)@(evt at: 7)) ].
		[WindowEventClose] ->	 [self handleClose].
		[WindowEventIconise] -> [self handleIconise]. 
		[WindowEventActivated] -> [self handleActivated]. 
		[WindowEventPaint] -> [self handlePaint: ((evt at: 4)@(evt at: 5) corner: (evt at: 6)@(evt at: 7))].
	} otherwise: ["unknown"]

]

{ #category : #'private-events' }
DisplayHostWindow >> queueEvent: evt [
	"Queue the given event in the event queue (if any).
	Note that the event buffer must be copied since it
	will be reused later on."
	eventQueue ifNil: [^self].	"queue gets created by client"
	eventQueue nextPut: evt shallowCopy.

]

{ #category : #snapshots }
DisplayHostWindow >> resetProxy [
	"private - for use when resuming a snapshot file only. If the windowProxy had previously been created, nil it and reopen cleanly. IF you try to use this in a 'live' system it will NOT close the windows since startup conditions assume that proxies are invalid so we don't attempt to close them - since that could cause other problems"
	windowProxy ifNotNil: 
		[ windowProxy := nil.
		self open ]
]

{ #category : #testing }
DisplayHostWindow >> test [
	"((DisplayHostWindow extent: 400@400 depth: 16 ) translateBy: 210@450) test"
	"Should
		a) open a window with the upper left portion of the current Display
		b) find the window size
		f) close the window"
	| size |
	self open.
	Display displayOn: self.
	self forceToScreen: self boundingBox.
	size := self windowSize.
	self close.
	^ size
]

{ #category : #testing }
DisplayHostWindow >> test2 [
	"((DisplayHostWindow extent: 400 @ 400 depth: 16 ) translateBy: 210 @ 450) test2"
	"Should
		a) open a window with the upper left portion of the current Display
		b) update the middle area with part of Display
		c) move the window from 210 @ 450 to 300 @ 300
		d) change the window title
		e) change the window size from 400 @ 400 to 600 @ 400
		f) wait 4 seconds so you can see the result
		g) close the window via the garbage collecttor finalizing it"
	self open.
	Display displayOn: self.
	self forceToScreen.
	Display displayOn: self at: -100 @ -200.
	self forceToScreen: (100 @ 100 extent: 200 @ 200).
	self windowPosition: 300 @ 300.
	self windowTitle: 'YooHoo! New title'.
	self windowSize: 600 @ 400.
	(Delay forSeconds: 4) wait.
]

{ #category : #'basic api' }
DisplayHostWindow >> windowPosition [
	"return the current position of the window"
		
	^windowProxy ifNotNil:[ windowProxy windowPosition]
]

{ #category : #'basic api' }
DisplayHostWindow >> windowPosition: aPoint [
	"set the position of the window and then return the new position"
	^windowProxy ifNotNil:[ windowProxy windowPosition: aPoint]
]

{ #category : #'basic api' }
DisplayHostWindow >> windowSize [
	"return the current size of the window - not neccessarily the same as my bitmap"

	^windowProxy ifNotNil:[ windowProxy windowSize]
]

{ #category : #'basic api' }
DisplayHostWindow >> windowSize: aPoint [
	"Set the size of the window and then return the current size of the window -
not neccessarily the same "
		
	^windowProxy ifNotNil:[ windowProxy windowSize: aPoint]
]

{ #category : #'basic api' }
DisplayHostWindow >> windowTitle: titleString [ 
	"set the label in the window titlebar to titleString"
	title := titleString.
	windowProxy ifNotNil: [ windowProxy windowTitle: title ]
]
