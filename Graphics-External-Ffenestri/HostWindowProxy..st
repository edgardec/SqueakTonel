"
This is a proxy for a Host OS window and as such is considered a disposable item. When an image is restarted the client must recreate suitable instances from the information they hold. Platform specific subclasses are available to translate abstract requirements into possible platform concrete data.
There is a registry of instances so that when users let go they can be guaranteed to close down properly. Because the instances point to the source Form in use this can on occasion result in a cycle that defeats the Weak mechanism - hence the implementation of #executor & #asExecutor.
The only requirements placed on the sourceForm instvar are those of being like a DisplayScreen - can return a bits array, the width, depth etc PLUS implement processEvent: AND able to respond to #resetProxy to remove and rebuild the window proxy
"
Class {
	#name : #HostWindowProxy,
	#superclass : #Object,
	#instVars : [
		'windowHandle',
		'sourceForm'
	],
	#classVars : [
		'ActiveProxyClass',
		'Registry'
	],
	#category : #'Graphics-External-Ffenestri'
}

{ #category : #'system startup' }
HostWindowProxy class >> activeWindowProxyClass [
	"Return the concrete HostWindowProxy subclass for the platform on which we are
currently running."

	HostWindowProxy allSubclasses do: [:class |
		class isActiveHostWindowProxyClass ifTrue: [^ class]].

	"no responding subclass; use HostWindowProxy"
	^ HostWindowProxy

]

{ #category : #'class initialization' }
HostWindowProxy class >> initialize [
"Add me to the system startup list and make sure to do a file-in init for first time loading"
"HostWindowProxy initialize"
	self setDefaultWindowProxyClass.
	Smalltalk addToStartUpList: self.
]

{ #category : #'system startup' }
HostWindowProxy class >> isActiveHostWindowProxyClass [
"subclasses must override this"
	self subclassResponsibility
]

{ #category : #'initialize-release' }
HostWindowProxy class >> on: aSourceForm [
"Build a new window proxy by finding the appropriate platform specific subclass
and setting it up for this Form-like argument"
	^ActiveProxyClass new on: aSourceForm
]

{ #category : #events }
HostWindowProxy class >> processEvent: evt [
	"evt is a raw event buffer from VM. Pass it on to the appropiate proxy."
	self registry keys do: [:proxy |
		(proxy wantsEvent: evt) ifTrue: [proxy processEvent: evt]].

]

{ #category : #registry }
HostWindowProxy class >> register: anObject [
"boilerplate WeakRegistry usage"
	^self registry add: anObject
]

{ #category : #registry }
HostWindowProxy class >> registry [
"boilerplate WeakRegistry usage"
	^Registry ifNil: [Registry := WeakRegistry new]
]

{ #category : #'system startup' }
HostWindowProxy class >> setDefaultWindowProxyClass [
	"connect to the proper platform subclass of proxy"
	ActiveProxyClass := self activeWindowProxyClass
]

{ #category : #'system startup' }
HostWindowProxy class >> startUp: resuming [
	resuming ifFalse: [^self].
	"system startup - find the appropriate proxy class for this platform"
	self setDefaultWindowProxyClass.
	"any currently extant instances must tell their sourceForm to resetProxy in order to kill potentially wrong-platform versions and reset to correct-platform"
	self registry keys do: [:i | i resetProxy]
]

{ #category : #registry }
HostWindowProxy class >> unregister: anObject [
"boilerplate WeakRegistry usage"
	^self registry remove: anObject ifAbsent:[]
]

{ #category : #finalization }
HostWindowProxy >> asExecutor [
	sourceForm := nil
]

{ #category : #'window decorations' }
HostWindowProxy >> attributes [
"return the ByteArray representing the desired window attributes. This is utterly platform dependent and my default is an empty ByteArray to signify a default window"
	^ByteArray new
]

{ #category : #metrics }
HostWindowProxy >> bits [
"return the bits - normally of the sourceForm"
	^sourceForm bits
]

{ #category : #'initialize-release' }
HostWindowProxy >> close [
	"close this window"
	windowHandle ifNil: [^self].
	self unregister.
	self primitiveWindowClose: windowHandle.
	windowHandle := nil.

]

{ #category : #'window decorations' }
HostWindowProxy >> defaultWindowType [
"set up my attributes to be a default window - a titlebar, usual decorations etc"
	^self subclassResponsibility
]

{ #category : #metrics }
HostWindowProxy >> depth [
"return the depth - normally of the sourceForm"
	^sourceForm depth
]

{ #category : #finalization }
HostWindowProxy >> executor [
	^self shallowCopy asExecutor
]

{ #category : #finalization }
HostWindowProxy >> finalize [
	"close this window"
	self close
]

{ #category : #'window manipulation' }
HostWindowProxy >> forceToScreen: damageRectangle [ 
	"update the area of the sourceForm defined by damageRectangle"
	self
		primitiveUpdateHostWindow: windowHandle
		bitmap: self bits
		width: self width
		height: self height
		depth: self depth
		left: damageRectangle left
		right: damageRectangle right
		top: damageRectangle top
		bottom: damageRectangle bottom
]

{ #category : #metrics }
HostWindowProxy >> height [
"return the height - normally of the sourceForm"
	^sourceForm height
]

{ #category : #accessing }
HostWindowProxy >> isOpen [
"am I already opened?"
	^windowHandle notNil
]

{ #category : #metrics }
HostWindowProxy >> offset [
"return the offset - normally of the sourceForm"
	^sourceForm offset
]

{ #category : #'initialize-release' }
HostWindowProxy >> on: aSourceForm [ 
	"set my sourceForm; usually an actual Form but so long as methods like bits, height etc work, it can be anything"
	sourceForm := aSourceForm
]

{ #category : #'initialize-release' }
HostWindowProxy >> open [
	"open a host window built around my position, size and bitmap"
	windowHandle
		ifNil: [sourceForm
				ifNotNil:[windowHandle := self
						primitiveCreateHostWindowWidth: self width
						height: self height
						originX: self offset x
						y: self offset y
						attributes: self attributes.
						windowHandle ifNotNil:[self register].
						^windowHandle]]
]

{ #category : #'system primitives' }
HostWindowProxy >> primitiveCreateHostWindowWidth: w height: h originX: x y: y attributes: list [
"create and open a host window. list is a ByteArray list of window attributes in some platform manner. See subclasses for information"
	<primitive: 'primitiveCreateHostWindow' module: 'HostWindowPlugin'>
	^self error: 'Unable to create Host Window'
]

{ #category : #'system primitives' }
HostWindowProxy >> primitiveUpdateHostWindow: id bitmap: bitmap width: w height: h depth: d left: l
right: r top: t bottom: b [ 
	"Force the pixels to the screen. The bitmap details and affected area are given
explicitly to avoid dependence upon any object structure"
	<primitive: 'primitiveShowHostWindowRect' module:'HostWindowPlugin'>
	^self windowProxyError: 'update'
]

{ #category : #'system primitives' }
HostWindowProxy >> primitiveWindowClose: id [
"Close the window"
	<primitive: 'primitiveCloseHostWindow' module: 'HostWindowPlugin'>
	^self windowProxyError: 'close'
]

{ #category : #'system primitives' }
HostWindowProxy >> primitiveWindowPosition: id [
"Find the topleft corner of the window"
	<primitive: 'primitiveHostWindowPosition' module: 'HostWindowPlugin'>
	^self windowProxyError: 'get position'
]

{ #category : #'system primitives' }
HostWindowProxy >> primitiveWindowPosition: id x: x y: y [
"Set the topleft corner of the window - return what is actually set"
	<primitive: 'primitiveHostWindowPositionSet' module: 'HostWindowPlugin'>
	^self windowProxyError: 'set position'
]

{ #category : #'system primitives' }
HostWindowProxy >> primitiveWindowSize: id [
"Find the size of the window, just like primitiveScreenSize"
	<primitive: 'primitiveHostWindowSize' module: 'HostWindowPlugin'>
	^self windowProxyError: 'get size'
]

{ #category : #'system primitives' }
HostWindowProxy >> primitiveWindowSize: id x: x y: y [
"Set the size of the window, just like primitiveScreenSize. Return the actually
achieved size"
	<primitive: 'primitiveHostWindowSizeSet' module: 'HostWindowPlugin'>
	^self windowProxyError: 'set size'
]

{ #category : #'system primitives' }
HostWindowProxy >> primitiveWindowTitle: id string: titleString [
"Set the label of the title bar of the window"
	<primitive: 'primitiveHostWindowTitle' module: 'HostWindowPlugin'>
	^self error: 'Unable to set title of Host Window'
]

{ #category : #printing }
HostWindowProxy >> printOn: aStream [
	super printOn:aStream.
	aStream nextPutAll: ' (windowIndex '.
	windowHandle printOn: aStream.
	aStream nextPut: $)
]

{ #category : #events }
HostWindowProxy >> processEvent: evt [
	"evt is a raw event buffer from VM. delegate to client window"
	sourceForm processEvent: evt
]

{ #category : #'window manipulation' }
HostWindowProxy >> recreate [
"something has changed that require deleting the host window before opening it
with new attributes"
	self close; open
]

{ #category : #finalization }
HostWindowProxy >> register [
	^self class register: self
]

{ #category : #finalization }
HostWindowProxy >> resetProxy [
"tell my sourceForm to kill me (gulp) and resurrect me in the correct clothing"
	sourceForm ifNotNil:[ sourceForm resetProxy]
]

{ #category : #finalization }
HostWindowProxy >> unregister [
	^self class unregister: self
]

{ #category : #events }
HostWindowProxy >> wantsEvent: evt [
	"evt is a raw event buffer from VM. check if its window field matches ours"
	^ windowHandle = (evt at: 8)
]

{ #category : #metrics }
HostWindowProxy >> width [
"return the width - normally of the sourceForm"
	^sourceForm width
]

{ #category : #'window manipulation' }
HostWindowProxy >> windowPosition [
	"return the current position of the window"
		^self primitiveWindowPosition: windowHandle
]

{ #category : #'window manipulation' }
HostWindowProxy >> windowPosition: aPoint [
	"set the position of the window and then return the new position"
		^self primitiveWindowPosition: windowHandle x: aPoint x y: aPoint y
]

{ #category : #accessing }
HostWindowProxy >> windowProxyError: problemString [
	"Could be useful to raise an exception but not yet"
]

{ #category : #'window manipulation' }
HostWindowProxy >> windowSize [
	"return the current size of the window "
		^self primitiveWindowSize: windowHandle
]

{ #category : #'window manipulation' }
HostWindowProxy >> windowSize: aPoint [
	"Set the size of the window and then return the actually set size of the window - not neccessarily the same "
		^self primitiveWindowSize: windowHandle x: aPoint x y: aPoint y
]

{ #category : #'window manipulation' }
HostWindowProxy >> windowTitle: titleString [
"set the label in the window titlebar to titleString"
	^self primitiveWindowTitle: windowHandle string: titleString squeakToUtf8
]
