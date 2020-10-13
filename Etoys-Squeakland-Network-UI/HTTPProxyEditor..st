"
An editor for the http proxy settings.

To open it evaluate:

	HTTPProxyEditor open.

or use the World Menu (open... >> http proxy editor).

"
Class {
	#name : #HTTPProxyEditor,
	#superclass : #SystemWindow,
	#instVars : [
		'serverName',
		'port',
		'serverNameWidget',
		'portWidget',
		'serverNameLabelWidget',
		'portLabelWidget',
		'acceptWidget',
		'cancelWidget'
	],
	#category : #'Etoys-Squeakland-Network-UI'
}

{ #category : #'instance creation' }
HTTPProxyEditor class >> activateWindow: aWindow [ 
	"private - activate the window"
	| world |
	world := Project current world.
	aWindow
		right: (aWindow right min: world bounds right);
		bottom: (aWindow bottom min: world bounds bottom);
		left: (aWindow left max: world bounds left);
		top: (aWindow top max: world bounds top).
	aWindow comeToFront;	flash
]

{ #category : #'class initialization' }
HTTPProxyEditor class >> initialize [

	self registerInOpenMenu
]

{ #category : #'instance creation' }
HTTPProxyEditor class >> open [
	"open the receiver"
	Project current world submorphs
		do: [:each | (each isKindOf: self)
				ifTrue: [self activateWindow: each.
					^ self]].
	^ self new openInWorld
]

{ #category : #'class initialization' }
HTTPProxyEditor class >> registerInOpenMenu [
	"Register the receiver in the system's open menu"
	TheWorldMenu registerOpenCommand: {'http proxy editor' translated. {HTTPProxyEditor. #open}. 'An editor for the http proxy settings' translated}
]

{ #category : #'class initialization' }
HTTPProxyEditor class >> unload [
	"Called when the class is being removed"

	TheWorldMenu unregisterOpenCommandWithReceiver: self
]

{ #category : #'user interface' }
HTTPProxyEditor >> accept [
	"the user press the [accept] button"
	serverNameWidget hasUnacceptedEdits
		ifTrue: [serverNameWidget accept].
	portWidget hasUnacceptedEdits
		ifTrue: [portWidget accept].
	""
	self applyChanges.
	""
	self delete
]

{ #category : #'user interface' }
HTTPProxyEditor >> applyChanges [
	"apply the changes on HTTPSocket"
	| finalServerName finalPort |
	finalServerName := serverName asString withBlanksTrimmed.
	[finalPort := port asString withBlanksTrimmed asNumber]
		on: Error
		do: [:ex | finalPort := 0].
	""
	(finalServerName isNil
			or: [finalServerName isEmpty]
			or: [finalPort isZero])
		ifTrue: [""
Transcript
		show: ('Stop using Proxy Server.' translated );
		 cr.
""
			HTTPSocket stopUsingProxyServer.
			^ self].
	""
	Transcript
		show: ('Proxy Server Named: ''{1}'' port: {2}.' translated format: {finalServerName. finalPort});
		 cr.
	HTTPSocket useProxyServerNamed: finalServerName port: finalPort
]

{ #category : #'user interface' }
HTTPProxyEditor >> cancel [
	"the user press the [cancel] button"
	self delete
]

{ #category : #initialization }
HTTPProxyEditor >> createButtonLabel: aString action: actionSelector help: helpString [ 
	"private - create a button for the receiver"
	| button |
	button := SimpleButtonMorph new target: self;
				 label: aString;
				 actionSelector: actionSelector;
				 setBalloonText: helpString;
				 borderWidth: 2;
				 useSquareCorners.
	""
	^ button
]

{ #category : #initialization }
HTTPProxyEditor >> createLabel: aString [ 
	"private - create a label with aString"
	| labelWidget |
	labelWidget := PluggableButtonMorph
				on: self
				getState: nil
				action: nil.
	labelWidget hResizing: #spaceFill;
		 vResizing: #spaceFill;
		 label: aString translated.
	""
	labelWidget onColor: Color transparent offColor: Color transparent.

	""
	^ labelWidget
]

{ #category : #initialization }
HTTPProxyEditor >> createText: selector [ 
"private - create a text widget on selector"
	| widget |
	widget := PluggableTextMorph
				on: self
				text: selector
				accept: (selector , ':') asSymbol.
	widget acceptOnCR: true.
	^ widget
]

{ #category : #'open\/close' }
HTTPProxyEditor >> initialExtent [
"answer the receiver's initialExtent"
	^ 300 @ 180
]

{ #category : #initialization }
HTTPProxyEditor >> initialize [
	"initialize the receiver"
	super initialize.
	""
	serverName := HTTPSocket httpProxyServer
				ifNil: [''].
	port := HTTPSocket httpProxyPort asString.
	""
	self setLabel: 'HTTP Proxy Editor' translated.
	self
		setWindowColor: (Color
				r: 0.9
				g: 0.8
				b: 1.0).
	""
	self initializeWidgets.
	self updateWidgets.
""
self extent: 300@180
]

{ #category : #initialization }
HTTPProxyEditor >> initializeWidgets [
	"initialize the receiver's widgets"
	self
		addMorph: (serverNameLabelWidget := self createLabel: 'Server Name:' translated)
		frame: (0 @ 0 corner: 0.5 @ 0.33).
	self
		addMorph: (serverNameWidget := self createText: #serverName)
		frame: (0.5 @ 0 corner: 1 @ 0.33).
	""
	self
		addMorph: (portLabelWidget := self createLabel: 'Port:' translated)
		frame: (0 @ 0.33 corner: 0.5 @ 0.67).
	self
		addMorph: (portWidget := self createText: #port)
		frame: (0.5 @ 0.33 corner: 1 @ 0.67).
	""
	self
		addMorph: (acceptWidget := self
						createButtonLabel: 'Accept' translated
						action: #accept
						help: 'Accept the proxy settings' translated)
		frame: (0 @ 0.67 corner: 0.5 @ 1).
	self
		addMorph: (cancelWidget := self
						createButtonLabel: 'Cancel' translated
						action: #cancel
						help: 'Cancel the proxy settings' translated)
		frame: (0.5 @ 0.67 corner: 1 @ 1)
]

{ #category : #panes }
HTTPProxyEditor >> paneColor: aColor [ 
	"the pane color was changed"
	super paneColor: aColor.
	""
	self updateWidgets
]

{ #category : #accessing }
HTTPProxyEditor >> port [
	"answer the receiver's port"
	^ port
]

{ #category : #accessing }
HTTPProxyEditor >> port: anInteger [ 
"change the receiver's port"
	port := anInteger.
	self changed: #port
]

{ #category : #accessing }
HTTPProxyEditor >> serverName [
"answer the receiver's serverName"
	^ serverName
]

{ #category : #accessing }
HTTPProxyEditor >> serverName: aString [ 
"change the receiver's serverName"
	serverName := aString.
	self changed: #serverName
]

{ #category : #initialization }
HTTPProxyEditor >> updateWidgets [
"update the receiver's widgets"
	acceptWidget isNil
		ifFalse: [""
			acceptWidget color: Color lightGreen;
				 borderStyle: (BorderStyle raised width: 2)].
	cancelWidget isNil
		ifFalse: [""
			cancelWidget color: Color lightRed;
				 borderStyle: (BorderStyle raised width: 2)].
	""
	serverNameLabelWidget isNil
		ifFalse: [""
			serverNameLabelWidget color: self paneColor lighter;
				 borderStyle: (BorderStyle raised width: serverNameLabelWidget borderWidth)].
	portLabelWidget isNil
		ifFalse: [""
			portLabelWidget color: self paneColor lighter;
				 borderStyle: (BorderStyle raised width: portLabelWidget borderWidth)]
]
