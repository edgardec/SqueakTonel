Class {
	#name : #SMTPClientTest,
	#superclass : #TestCase,
	#instVars : [
		'smtp',
		'socket'
	],
	#category : #'NetworkTests-Protocols'
}

{ #category : #running }
SMTPClientTest >> setUp [
	socket := MockSocketStream on: ''.
	smtp := SMTPClient new.
	smtp stream: socket.
]

{ #category : #tests }
SMTPClientTest >> testMailFrom [
	smtp mailFrom: 'frank@angband.za.org'.
	self assert: socket outStream contents = ('MAIL FROM: <frank@angband.za.org>', String crlf).
	
	socket resetOutStream.
	smtp mailFrom: '<frank@angband.za.org>'.
	self assert: socket outStream contents = ('MAIL FROM: <frank@angband.za.org>', String crlf).
	
	socket resetOutStream.
	smtp mailFrom: 'Frank <frank@angband.za.org>'.
	self assert: socket outStream contents = ('MAIL FROM: <frank@angband.za.org>', String crlf).
]
