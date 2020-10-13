Class {
	#name : #ArbitraryObjectSocketTestCase,
	#superclass : #TestCase,
	#instVars : [
		'socket1',
		'socket2',
		'end1',
		'end2'
	],
	#category : #'Nebraska-Network-ObjectSocket'
}

{ #category : #setup }
ArbitraryObjectSocketTestCase >> setUp [
	"it would be nice to have an in-image loopback socket, so that the tests do not need the underlying platform's sockets to behave nicely"
	socket1 := Socket newTCP.
	socket2 := Socket newTCP.
	
	socket1 listenOn: 9999.
	socket2 connectTo: (NetNameResolver localHostAddress) port: socket1 port.

	socket1 waitForConnectionFor: 60.	
	socket2 waitForConnectionFor: 60.
	
	end1 := ArbitraryObjectSocket on: socket1.
	end2 := ArbitraryObjectSocket on: socket2.
	
]

{ #category : #running }
ArbitraryObjectSocketTestCase >> tearDown [

	socket1 ifNotNil: [ socket1 destroy ].
	socket2 ifNotNil: [ socket2 destroy ]
]

{ #category : #testing }
ArbitraryObjectSocketTestCase >> testBasics [
	end1 nextPut: 'hello'.
	end1 nextPut: 42.
	end1 nextPut: 3@5.
	end1 processIO.  "hopefully one call is enough...."
	10 milliSeconds asDelay wait. "data sent, wait a few milliseconds"
	end2 processIO.  "hopefully one call is enough...."
	self should: [ end2 next = 'hello' ].
	self should: [ end2 next = 42 ].
	self should: [ end2 next = (3@5) ].
	
]
