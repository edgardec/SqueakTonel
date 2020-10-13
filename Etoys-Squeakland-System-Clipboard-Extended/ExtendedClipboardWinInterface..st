Class {
	#name : #ExtendedClipboardWinInterface,
	#superclass : #ExtendedClipboardInterface,
	#category : #'Etoys-Squeakland-System-Clipboard-Extended'
}

{ #category : #'class initialization' }
ExtendedClipboardWinInterface class >> initialize [
	"ExtendedClipboardWinInterface initialize"

	self
		initializeClipboardFormatMap;
		initializeMimeTypeMap
]

{ #category : #'class initialization' }
ExtendedClipboardWinInterface class >> initializeClipboardFormatMap [
	"ExtendedClipboardWinInterface initializeClipboardFormatMap"

	clipboardFormatMap := Dictionary new.
	"at: 6 put: 'image/tiff' asMIMEType; CF_TIFF"

	clipboardFormatMap
		at: 49510 put: 'text/rtf' asMIMEType; 
		at: 1 put: 'text/plain' asMIMEType; "CF_TEXT"
		at: 2 put: 'image/bmp' asMIMEType; "CF_BITMAP"
		at: 12 put: 'audio/wave'; "CF_WAVE"
		at: 13 put: 'text/unicode' asMIMEType; "CF_UNICODETEXT"
		at: 16 put: 'CF_LOCALE'; "CF_LOCALE"
		yourself.



]

{ #category : #'class initialization' }
ExtendedClipboardWinInterface class >> initializeMimeTypeMap [
	"ExtendedClipboardWinInterface initializeMimeTypeMap"

	mimeTypeMap := Dictionary new.
	mimeTypeMap
		at: 'text/rtf' asMIMEType put: 49510; 
		at: 'text/plain' asMIMEType put: 1; "CF_TEXT"
		at: 'image/*' asMIMEType put: 2; "CF_BITMAP"
		at: 'metafile' put: 3; "CF_METAFILEPICT"
		at: 'CF_SYLK' put: 4; "CF_SYLK"
		at: 'CF_DIF' put: 5; "CF_DIF"
		at: 'image/tiff' asMIMEType put: 6; "CF_TIFF"
		at: 'oemtext' put: 7; "CF_OEMTEXT"
		at: 'CF_DIB' put: 8; "CF_DIB"
		at: 'CF_PALETTE' put: 9; "CF_PALETTE"
		at: 'CF_PENDATA' put: 10; "CF_PENDATA"
		at: 'CF_RIFF' put: 11; "CF_RIFF"
		at: 'wave' put: 12; "CF_WAVE"
		at: 'text/unicode' asMIMEType put: 13; "CF_UNICODETEXT"
		at: 'CF_ENHMETAFILE' put: 14; "CF_ENHMETAFILE"
		at: 'CF_HDROP' put: 15; "CF_HDROP"
		at: 'CF_LOCALE' put: 16; "CF_LOCALE"
		at: 'CF_DIBV5' put: 17; "CF_DIBV5"
		yourself

]

{ #category : #'general-api-read' }
ExtendedClipboardWinInterface >> readAvailableFormats [
	| currentFormat availableFormats mimeType |
	availableFormats := OrderedCollection new: 10.
	currentFormat := 0.
	self openClipboard.
	[currentFormat := self format: currentFormat.
	currentFormat ~= 0]
		whileTrue: [
			mimeType := self class clipboardFormatMap at: currentFormat ifAbsent: [nil].
			mimeType ifNotNil: [
				availableFormats add: mimeType]].
	self closeClipboard.
	^availableFormats
]

{ #category : #'general-api-read' }
ExtendedClipboardWinInterface >> readBMPClipboardData [
	| string |
	self openClipboard.
	[string := (self getClipboardData: (self class mimeTypeMap at: 'image/*' asMIMEType)) fromCString]
		ensure: [self closeClipboard].
	^string
]

{ #category : #'general-api-read' }
ExtendedClipboardWinInterface >> readFormClipboardData [
	| bytes formats |
	formats := self readAvailableFormats.
	(formats includes: 'image/bmp' asMIMEType)
		ifTrue: [bytes := self readBMPClipboardData.
			^ (BMPReadWriter on: bytes readStream) nextImage].
	^ nil
]

{ #category : #'general-api-read' }
ExtendedClipboardWinInterface >> readRTFClipboardData [
	| string |
	self openClipboard.
	[string := (self getClipboardData: (self class mimeTypeMap at: 'text/rtf' asMIMEType)) fromCString]
		ensure: [self closeClipboard].
	^string
]

{ #category : #'general-api-read' }
ExtendedClipboardWinInterface >> readStringClipboardData [
	| string |
	self openClipboard.
	[string := (self getClipboardData: (self class mimeTypeMap at: 'text/plain' asMIMEType)) fromCString]
		ensure: [self closeClipboard].
	^string
]

{ #category : #'general-api-read' }
ExtendedClipboardWinInterface >> readTIFFClipboardData [
	| string |
	self openClipboard.
	[string := (self getClipboardData: (self class mimeTypeMap at: 'image/tiff' asMIMEType)) fromCString]
		ensure: [self closeClipboard].
	^string
]

{ #category : #'general-api-read' }
ExtendedClipboardWinInterface >> readWideStringClipboardData [
	| string |
	self openClipboard.
	[string := (self getClipboardData: (self class mimeTypeMap at: 'text/unicode' asMIMEType)) fromUTF16String]
		ensure: [self closeClipboard].
	^string
]
