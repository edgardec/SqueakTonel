"
This is the unit test for the class Base64MimeConverter. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #Base64MimeConverterTest,
	#superclass : #TestCase,
	#instVars : [
		'message'
	],
	#category : #'CollectionsTests-Streams'
}

{ #category : #running }
Base64MimeConverterTest >> setUp [
	message := 'Hi There!' readStream.

]

{ #category : #tests }
Base64MimeConverterTest >> testBase64Encoded [
	| encoded |
	encoded := (Base64MimeConverter mimeEncode: message) contents.
	self assert: encoded = 'Hi There!' base64Encoded.
	
]

{ #category : #tests }
Base64MimeConverterTest >> testMimeEncodeDecode [

	| encoded |
	encoded := Base64MimeConverter mimeEncode: message.
	self assert: (encoded contents = 'SGkgVGhlcmUh').
     self assert: ((Base64MimeConverter mimeDecodeToChars: encoded) contents = message contents).

	"Encoding should start from the beginning of the stream."
	message reset.
	message skip: 2.
	encoded := Base64MimeConverter mimeEncode: message.
	self assert: (encoded contents = 'SGkgVGhlcmUh').
	
	"Encoding should start from the current position of the stream."
	message reset.
	message skip: 2.
	encoded := Base64MimeConverter mimeEncodeContinue: message.
	self assert: (encoded contents = 'IFRoZXJlIQ==').
]

{ #category : #tests }
Base64MimeConverterTest >> testMimeEncodeDecodeMultiLine [

	| encoded |
	encoded := (Base64MimeConverter mimeEncode: (String new: 100 withAll: $a) readStream) contents.
	self assert: encoded = 
'YWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFh
YWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYQ=='.

	encoded := (Base64MimeConverter mimeEncode: (String new: 100 withAll: $a) readStream multiLine: false) contents.
	self assert: encoded = 
'YWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYWFhYQ=='.

]

{ #category : #tests }
Base64MimeConverterTest >> testOnByteArray [
	self assert: ('Hi There!' base64Encoded = 'Hi There!' asByteArray base64Encoded)
]
