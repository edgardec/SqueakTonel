"
A wrapper object for the WebSocket API.
"
Class {
	#name : #WebSocket00,
	#superclass : #WebSocket,
	#instVars : [
		'frameType',
		'frameData'
	],
	#category : #'WebClient-Core'
}

{ #category : #running }
WebSocket00 >> close [
	"Request graceful close"

	stream isConnected ifFalse: [ ^self ].
	stream 
		nextPut: (Character value: 255);
		nextPut: (Character value: 0);
		flush

]

{ #category : #'read\/write' }
WebSocket00 >> readMessage [
	"Reads one frame worth of data"

	| byte length |
	byte := stream next ifNil:[
		frameType := 255.
		^nil].
	frameType := byte asInteger.
	frameType < 128 ifTrue:[
		"Frame type < 128: UTF-8 encoded text with 0xFF frame delimiter"
		frameData := (stream upTo: 255 asCharacter) utf8ToSqueak.
	] ifFalse:[
		"Frame type >= 128: Binary data with length prefix"
		length := 0.
		[byte := stream next asInteger.
		length := (length * 128) + (byte bitClear: 128).
		byte >= 128] whileTrue.
		frameData := ByteArray new: length.
		stream nextInto: frameData.
	].

]

{ #category : #running }
WebSocket00 >> run [
	"Run the WebSocket's input process."

	[[[stream isConnected] whileTrue:[
		self readMessage.
		"XXXX: Should this be moved into handleMessage:type: ???"
		frameType = 255 ifTrue:[stream close. ^self].
		self handleMessage: frameData type: frameType.
	]] on: Error do:[:ex| self handleError: ex]] ensure:[
		[stream socket destroy] on: Error do:[:ex|].
		self handleClose.
	].

]

{ #category : #'read\/write' }
WebSocket00 >> send: aString [
	"Writes one frame worth of data"

	^self send: aString type: 0
]

{ #category : #'read\/write' }
WebSocket00 >> send: data type: type [
	"Writes one frame worth of data using the given frame type"

	"Frame type"
	stream nextPut: (Character value: type).
	type < 128 ifTrue:[
		"Frame type < 128: UTF-8 encoded text with 0xFF frame delimiter"
		stream nextPutAll: data squeakToUtf8.
		stream nextPutAll: (Character value: 255).
	] ifFalse:[ | prefix length |
		"Frame type >= 128: Binary data with length prefix"
		prefix := ByteArray new.
		length := data size.
		[length > 127]  whileTrue:[
			prefix := prefix copyWith: prefix \\ 128.
			length := length // 128.
		].
		prefix := prefix copyWith: length.
		stream nextPutAll: prefix reversed.
		stream nextPutAll: data.
		stream flush.
	].
	stream flush.

]
