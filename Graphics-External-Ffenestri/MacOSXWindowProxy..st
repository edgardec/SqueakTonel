Class {
	#name : #MacOSXWindowProxy,
	#superclass : #HostWindowProxy,
	#instVars : [
		'windowClass',
		'windowAttributes'
	],
	#category : #'Graphics-External-Ffenestri'
}

{ #category : #constants }
MacOSXWindowProxy class >> activatesAttribute [ 
	^2 raisedTo: 17
]

{ #category : #constants }
MacOSXWindowProxy class >> alertWindowClass [
	^1
]

{ #category : #constants }
MacOSXWindowProxy class >> altPlainWindowClass [
	^16
]

{ #category : #constants }
MacOSXWindowProxy class >> asyncDragAttribute [ 
	^2 raisedTo: 23
]

{ #category : #constants }
MacOSXWindowProxy class >> closeBoxAttribute [
	^2 raisedTo: 0
]

{ #category : #constants }
MacOSXWindowProxy class >> collapseBoxAttribute [
	^2 raisedTo: 3
]

{ #category : #constants }
MacOSXWindowProxy class >> compositingAttribute [ 
	^2 raisedTo: 19
]

{ #category : #constants }
MacOSXWindowProxy class >> documentWindowClass [
	^6
]

{ #category : #constants }
MacOSXWindowProxy class >> doesNotCycleAttribute [
	^2 raisedTo: 15
]

{ #category : #constants }
MacOSXWindowProxy class >> drawerWindowClass [
	^20
]

{ #category : #constants }
MacOSXWindowProxy class >> floatingWindowClass [
	^5
]

{ #category : #constants }
MacOSXWindowProxy class >> fullZoomAttribute [
	^self verticalZoomAttribute bitOr: self horizontalZoomAttribute
]

{ #category : #constants }
MacOSXWindowProxy class >> helpWindowClass [
	^10
]

{ #category : #constants }
MacOSXWindowProxy class >> hideOnFullScreenAttribute [ 
	^2 raisedTo: 26
]

{ #category : #constants }
MacOSXWindowProxy class >> hideOnSuspendAttribute [ 
	^2 raisedTo: 24
]

{ #category : #constants }
MacOSXWindowProxy class >> horizontalZoomAttribute [
	^2 raisedTo: 1
]

{ #category : #constants }
MacOSXWindowProxy class >> ignoreClicksAttribute [ 
	^2 raisedTo: 29
]

{ #category : #constants }
MacOSXWindowProxy class >> inWindowMenuAttribute [ 
	^2 raisedTo: 27
]

{ #category : #'system startup' }
MacOSXWindowProxy class >> isActiveHostWindowProxyClass [
"Am I active?"
	^Smalltalk platformName  = 'Mac OS' and: [Smalltalk osVersion asInteger >= 1000]
]

{ #category : #constants }
MacOSXWindowProxy class >> liveResizeAttribute [ 
	^2 raisedTo: 28
]

{ #category : #constants }
MacOSXWindowProxy class >> metalAttribute [
	^2 raisedTo: 8
]

{ #category : #constants }
MacOSXWindowProxy class >> modalWindowClass [
	^3
]

{ #category : #constants }
MacOSXWindowProxy class >> movableAlertWindowClass [
	^2
]

{ #category : #constants }
MacOSXWindowProxy class >> movableModalWindowClass [
	^4
]

{ #category : #constants }
MacOSXWindowProxy class >> noAttributes [
	^0
]

{ #category : #constants }
MacOSXWindowProxy class >> noConstrainAttribute [ 
	^2 raisedTo: 31
]

{ #category : #constants }
MacOSXWindowProxy class >> noShadowAttribute [ 
	^2 raisedTo: 21
]

{ #category : #constants }
MacOSXWindowProxy class >> noUpdatesAttribute [ 
	^2 raisedTo: 16
]

{ #category : #constants }
MacOSXWindowProxy class >> opaqueForEventsAttribute [ 
	^2 raisedTo: 18
]

{ #category : #constants }
MacOSXWindowProxy class >> overlayWindowClass [
	^14
]

{ #category : #constants }
MacOSXWindowProxy class >> plainWindowClass [
	^13
]

{ #category : #constants }
MacOSXWindowProxy class >> resizableAttribute [
	^2 raisedTo: 4
]

{ #category : #constants }
MacOSXWindowProxy class >> sheetAlertWindowClass [
	^15
]

{ #category : #constants }
MacOSXWindowProxy class >> sheetWindowClass [
	^11
]

{ #category : #constants }
MacOSXWindowProxy class >> sideTitlebarAttribute [
	^2 raisedTo: 5
]

{ #category : #constants }
MacOSXWindowProxy class >> simpleWindowClass [
	^18
]

{ #category : #constants }
MacOSXWindowProxy class >> standardDocumentAttributes [ 
	^self noConstrainAttribute + self standardHandlerAttribute + self closeBoxAttribute + self fullZoomAttribute + self collapseBoxAttribute + self resizableAttribute


"16r8200001E printStringBase: 2 '2r 10000010 00000000 00000000 00011110'"
]

{ #category : #constants }
MacOSXWindowProxy class >> standardFloatingAttributes [
	^self closeBoxAttribute + self collapseBoxAttribute

]

{ #category : #constants }
MacOSXWindowProxy class >> standardHandlerAttribute [ 
	^2 raisedTo: 25
]

{ #category : #constants }
MacOSXWindowProxy class >> toolbarButtonAttribute [
	^2 raisedTo: 6
]

{ #category : #constants }
MacOSXWindowProxy class >> toolbarWindowClass [
	^12
]

{ #category : #constants }
MacOSXWindowProxy class >> utilityWindowClass [
	^8
]

{ #category : #constants }
MacOSXWindowProxy class >> verticalZoomAttribute [
	^2 raisedTo: 2
]

{ #category : #accessing }
MacOSXWindowProxy >> attributes [
	| val |
	val := ByteArray new: 8.
	val 
		unsignedLongAt: 1
		put: windowClass
		bigEndian: Smalltalk isBigEndian.
	val 
		unsignedLongAt: 5
		put: windowAttributes
		bigEndian: Smalltalk isBigEndian.
	^ val
]

{ #category : #metrics }
MacOSXWindowProxy >> defaultWindowType [
	self windowClass: self class documentWindowClass.
	self windowAttributes: self class standardDocumentAttributes.
]

{ #category : #accessing }
MacOSXWindowProxy >> windowAttributes [
	^windowAttributes

]

{ #category : #accessing }
MacOSXWindowProxy >> windowAttributes: aNumber [
	windowAttributes := aNumber
]

{ #category : #accessing }
MacOSXWindowProxy >> windowClass [
	^windowClass

]

{ #category : #accessing }
MacOSXWindowProxy >> windowClass: aNumber [
	windowClass := aNumber
]
