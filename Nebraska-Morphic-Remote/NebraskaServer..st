"
A Nebraska server has a private world and some collection of clients.  It associates a RemoteControlledHand for each client.  Redraw events in the world are broadcasted to all connected clients.  A Nebraska server can listen on a TCP/IP port and accept new clients. Current version has been modified so that the server serves the world in which it was launched. Other variations are certainly possible.

To start a server, execute the following code:
	NebraskaServerMorph serveWorld: World

To start a client, run the following in another image:
	NetworkTerminalMorph openAndConnectTo: 'servername'

Fill in your server's hostname for 'servername'. At this point, everything should be working!

Before starting a server, you can tweak these:
BufferedCanvas enabled: false.
BufferedCanvas enabled: true.

At any time you can do these:
NebraskaDebug beginStats
NebraskaDebug showStats
NebraskaDebug showStats: #delays
NebraskaDebug showStats: #bigImage
NebraskaDebug showStats: #FormEncodeTimes
NebraskaDebug killStats

NOTE: if you want to have a local view of the server, you shouldn't use the TCP connections. The problem is that the server will occasionally do a #flush, and it won't work due to single threading. The better solution is to use a LoopBackStringSocket instead of a regular StringSocket, but there is no handy method for that right now....



"
Class {
	#name : #NebraskaServer,
	#superclass : #Model,
	#instVars : [
		'worldDepth',
		'world',
		'clients',
		'listenQueue'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'as yet unclassified' }
NebraskaServer class >> defaultPort [

	^9091
]

{ #category : #'as yet unclassified' }
NebraskaServer class >> defaultPorts [
	^ 9091 to: 9099
]

{ #category : #'as yet unclassified' }
NebraskaServer class >> extremelyBigRectangle [

	^(0@0 extent: 5000@5000)
]

{ #category : #'instance creation' }
NebraskaServer class >> newForWorld: aWorld [

	^self basicNew initializeForWorld: aWorld
]

{ #category : #'instance creation' }
NebraskaServer class >> serveWorld: aWorld [

	^self serveWorld: aWorld onPort: self defaultPorts
]

{ #category : #'instance creation' }
NebraskaServer class >> serveWorld: aWorld onPort: aPortNumber [

	| server |

	Utilities authorName.	"since we will need it later"

	server := self newForWorld: aWorld.
	server startListeningOnPort: aPortNumber.
	^server
	"server acceptNullConnection"		"server acceptPhonyConnection."

]

{ #category : #networking }
NebraskaServer >> acceptNewConnections [
	| connection |
	listenQueue ifNil: [ ^self ].
	[ clients size > 20 ifTrue: [ "too many connections!" ^self ].
	  connection := listenQueue getConnectionOrNil.  
	  connection isNil ] 
	whileFalse: [
	  self addClientFromConnection: (StringSocket on: connection) ].
]

{ #category : #networking }
NebraskaServer >> acceptNullConnection [

	| twins |

	twins := LoopbackStringSocket newPair.
	self addClientFromConnection: twins first.
	(NullTerminalMorph new connection: twins second) openInWorld.

]

{ #category : #networking }
NebraskaServer >> acceptPhonyConnection [

	| twins |

	twins := LoopbackStringSocket newPair.
	self addClientFromConnection: twins first.
	(NetworkTerminalMorph new connection: twins second) inspect "openInWorld".

]

{ #category : #networking }
NebraskaServer >> addClientFromConnection: connection [
	| client |

	client := NebraskaClient onConnection: connection.
	clients add: client.
	client extent: world extent  depth: worldDepth.
	world addRemoteClient: client.
	self changed: #numClients.
]

{ #category : #networking }
NebraskaServer >> backlog [

	^clients inject: 0 into: [ :max :each | max max: each backlog]
]

{ #category : #accessing }
NebraskaServer >> clients [
	^clients ifNil:[#()].
]

{ #category : #initialization }
NebraskaServer >> destroy [
	self stopListening.
	clients do:[:each| each destroy].
	self breakDependents.
]

{ #category : #attributes }
NebraskaServer >> extent: newExtent  depth: newDepth [
	"modify the extent and/or depth of the shared world"
	clients do: [ :client |
		client extent: newExtent depth: newDepth ].
	world extent: newExtent.

	worldDepth := newDepth.
]

{ #category : #initialization }
NebraskaServer >> initialize [
	clients := IdentitySet new.
	self extent: 800@600 depth: 16.
]

{ #category : #initialization }
NebraskaServer >> initializeForWorld: aWorld [

	world := aWorld.
	clients := IdentitySet new.
	self extent: world extent depth: Display depth.
	aWorld remoteServer: self.
]

{ #category : #accessing }
NebraskaServer >> listeningPort [
	^listenQueue portNumberOrNil
]

{ #category : #attributes }
NebraskaServer >> numClients [
	"return the number of connected clients"
	^clients size
]

{ #category : #networking }
NebraskaServer >> processIO [
	self pruneDeadConnections.
	self acceptNewConnections.
]

{ #category : #networking }
NebraskaServer >> pruneDeadConnections [
	| deadConnections |
	deadConnections := clients select: [ :client | client isConnected not ].
	deadConnections do: [ :client |
		world removeRemoteClient: client].

	deadConnections isEmpty ifTrue:[ ^self ].

	clients removeAll: deadConnections.
	self changed: #numClients.
]

{ #category : #attributes }
NebraskaServer >> sharedWorld [
	^world
]

{ #category : #networking }
NebraskaServer >> startListeningOnPort: portNumber [
	Socket initializeNetwork.
	self stopListening.
	listenQueue := ConnectionQueue portNumber: portNumber  queueLength: 5.
]

{ #category : #menus }
NebraskaServer >> step [

	self processIO.

	"savedWorld := Processor activeProcess world.
	Processor activeProcess setWorld: world."

	self flag: #bob.		"in this version, world is THE WORLD, so it steps itself"
	"world doOneCycle."

	"Processor activeProcess setWorld: savedWorld."

	clients do: [ :each | each canvas apply: [ :ignore | ]].	"for modes that need a little push"

]

{ #category : #networking }
NebraskaServer >> stopListening [
	listenQueue ifNil: [ ^self ].
	listenQueue destroy.
	listenQueue := nil.
]
