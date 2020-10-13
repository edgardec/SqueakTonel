"
I can be used to save packages to the SqueakMap server.  Here are the fields to save a release:

	1-1 = ""Select release:"" = 3
	1-3 = ""Version"" = 100
	1-4 = License drop-down index = 7
	1-5 = Compatibility = 5
	1-6 = Squeak versions = 11
	1-7 = Maturity = 4
	1-8 = Download url = http%3A%2F%2Fminnow.cc.gatech.edu%2Fsqueak%2Fuploads%2F2978%2FMa%2520client%2520server-cmm.mcz.sar
	1-9 = (file-selection drop-down) = 1 ""None""
	1-10 = Name (a cool one if you want) = [empty string]
	1-11 = Summary = [empty string]
	(1-12)* = Additional categories
	1-13 = Release note = This+version+much+faster+than+the+prior+SqueakMap+version.%0D%0A%0D%0AThis+single+release+installs+correctly+on+3.6%2C+3.7%2C+3.8%2C+3.9alpha+and+Jasmin+0.3++%28Croquet%29+images.%0D%0A%0D%0A
	1-17 = Button clicked = Save+changes
	1-18 = Button clicked = 'Save as new release' encodeForHTTP
	1-19 = parent release = 3
"
Class {
	#name : #SMClient,
	#superclass : #Object,
	#instVars : [
		'client'
	],
	#category : #SMLoader
}

{ #category : #private }
SMClient class >> assureWebClient [
	^ (Smalltalk classNamed: #WebClient) ifNil:
		[ self installWebClient.
		Smalltalk classNamed: #WebClient ]
]

{ #category : #private }
SMClient class >> installWebClient [ 
	Installer ss
		project: 'WebClient';
		install: 'WebClient-Core-ar.92.mcz'
]

{ #category : #private }
SMClient >> client [
	^ client ifNil:
		[ client := self class assureWebClient new
			 allowRedirect: false ;
			 yourself ]
]

{ #category : #api }
SMClient >> close [
	self logout.
	client ifNotNil: [ client close ].
	client := nil
]

{ #category : #private }
SMClient >> ensurePassword [
	self password isEmptyOrNil ifTrue: [ self password: (UIManager default requestPassword: 'Please enter your SqueakMap password.') ].
	self password isEmptyOrNil ifTrue: [ self error: 'authentication failure' ]
]

{ #category : #'initialize-release' }
SMClient >> initialize [
	super initialize.
	self username: Utilities authorInitialsPerSe 
]

{ #category : #api }
SMClient >> login [
	| response |
	self ensurePassword.
	response := self client
		httpPost: self smUrl, '/login'
		content: 'uusername=' , self username , '&ppassword=', self password, '&requestedUrl=%2Faccount&1-4=Log+in'
		type: 'application/x-www-form-urlencoded'
		do: [ : req | req headerAt: 'Connection' put: 'Keep-Alive' ].
	(#(200 302 ) includes: response code) ifFalse: [ self error: 'login error' ].
	"Eat up content."
	response content.
	^ response
]

{ #category : #private }
SMClient >> logout [
	^ (client notNil and: [ client isConnected ]) ifTrue:
		[ (self client httpGet: self smUrl , '/account/logout')
			 content ;
			 yourself ]
]

{ #category : #api }
SMClient >> password [
	"The SqueakMap user password."
	^ client ifNotNil: [ client password ]
]

{ #category : #api }
SMClient >> password: aString [
	"The SqueakMap user password."
	self client password: aString
]

{ #category : #api }
SMClient >> save: aSMPackageRelease [ 
	"Save aSMPackageRelease to the SqueakMap server."
	| response |
	response := self client
		httpPost: self smUrl , '/account/package/' , aSMPackageRelease package id asString , '/editreleases'
		content: aSMPackageRelease httpPostContent
		type: 'application/x-www-form-urlencoded'
		do:
			[ : req | req
				headerAt: 'Connection'
				put: 'Keep-Alive' ].
	^ response
		 content ;
		 yourself
]

{ #category : #private }
SMClient >> smUrl [
	^ 'http://', SMSqueakMap findServer
]

{ #category : #api }
SMClient >> uploadFile: aDirectoryEntryFile [ 
	"Upload aDirectoryEntryFile to the uploads area of SqueakMap for my userId."
	| boundary fieldMap fileStream doc |
	fileStream := aDirectoryEntryFile readStream binary.
	[ doc := MIMEDocument
		contentType: (MIMEDocument guessTypeFromName: aDirectoryEntryFile name)
		content: fileStream contents
		url: fileStream asUrl ] ensure:
		[ fileStream ifNotNil: [ fileStream close ] ].
	boundary := (Smalltalk at: #WebUtils) multipartBoundary.
	fieldMap := {'upload' -> doc}.
	^ (self client
		httpPost: self smUrl , '/account/upload'
		content:
			((Smalltalk at: #WebUtils)
				encodeMultipartForm: fieldMap
				boundary: boundary)
		type: MIMEDocument contentTypeMultipart , '; boundary=' , boundary
		do: [ : req | req headerAt: 'Connection' put: 'keep-alive' ])
		 content ;
		 yourself
]

{ #category : #api }
SMClient >> uploadFileNamed: filename [
	"Upload filename to the uploads area of SqueakMap for my userId."
	^ self uploadFile: (FileDirectory default entryAt: filename)
]

{ #category : #api }
SMClient >> username [
	"The SqueakMap username."
	^ client ifNotNil: [ client username ]
]

{ #category : #api }
SMClient >> username: aString [
	"The SqueakMap username."
	self client username: aString
]
