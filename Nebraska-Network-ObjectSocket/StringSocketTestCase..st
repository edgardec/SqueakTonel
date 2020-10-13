Class {
	#name : #StringSocketTestCase,
	#superclass : #TestCase,
	#instVars : [
		'socket1',
		'socket2',
		'end1',
		'end2'
	],
	#category : #'Nebraska-Network-ObjectSocket'
}

{ #category : #running }
StringSocketTestCase >> setUp [
	"it would be nice to have an in-image loopback socket, so that the tests do not need the underlying platform's sockets to behave nicely"
	socket1 := Socket newTCP.
	socket2 := Socket newTCP.
	
	socket1 listenOn: 9999.
	socket2 connectTo: (NetNameResolver localHostAddress) port: socket1 port.

	socket1 waitForConnectionFor: 60.	
	socket2 waitForConnectionFor: 60.
	
	end1 := StringSocket on: socket1.
	end2 := StringSocket on: socket2.
	
]

{ #category : #running }
StringSocketTestCase >> tearDown [
	
	end1 ifNotNil: [ 
		end1 destroy.
		end1 := nil ].
	end2 ifNotNil: [
		end2 destroy.
		end2 := nil ].
	"StringSocket >> #destroy is expected to destroy the tcp socket. The code below will just ensure that." 
	socket1 ifNotNil: [
		socket1 destroy.
		socket1 := nil ].
	socket2 ifNotNil: [
		socket2 destroy.
		socket2 := nil ]
	
]

{ #category : #running }
StringSocketTestCase >> testBasics [
	end1 nextPut: #().
	end1 nextPut: #('').
	end1 nextPut: #('hello' 'world').
	end1 processIO.

	"The wait makes this test a bit more robust because network delivery 
	is asynchronous and may not have happened when we call end2 processIO. 
	This causes the test to fail occasionally for no apparent reason."
	(Delay forMilliseconds: 100) wait.

	end2 processIO.
	self should: [ end2 next = #() ].
	self should: [ end2 next = #('') ].
	self should: [ end2 next = #('hello' 'world') ].
	
]

{ #category : #running }
StringSocketTestCase >> testBogusInput1 [
	| negString |
	negString := String new: 4.
	negString putInteger32: -10 at: 1.
	socket1 sendData: negString.
	10 milliSeconds asDelay wait. "data sent, wait a few milliseconds"
	end2 processIO.
	
	self should: [ end2 isConnected not ].
	
]

{ #category : #running }
StringSocketTestCase >> testBogusInput2 [
	| bogoString |
	bogoString := String new: 8.
	bogoString putInteger32: 2 at: 1.
	bogoString putInteger32: -10 at: 5.
	socket1 sendData: bogoString.
	10 milliSeconds asDelay wait. "data sent, wait a few milliseconds"
	end2 processIO.
	
	self should: [ end2 isConnected not ].
	
]
