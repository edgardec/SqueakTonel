Class {
	#name : #ExtendedClipboardMacInterface,
	#superclass : #ExtendedClipboardInterface,
	#category : #'Etoys-Squeakland-System-Clipboard-Extended'
}

{ #category : #'class initialization' }
ExtendedClipboardMacInterface class >> initialize [
	"ExtendedClipboardMacInterface initialize"
 
	self
		initializeClipboardFormatMap; 
		initializeMimeTypeMap
]

{ #category : #'class initialization' }
ExtendedClipboardMacInterface class >> initializeClipboardFormatMap [
	"ExtendedClipboardMacInterface initializeClipboardFormatMap"

	clipboardFormatMap := Dictionary new.
	clipboardFormatMap
		at: 'public.rtf' put: 'text/rtf' asMIMEType; 
		at: 'com.apple.traditional-mac-plain-text' put: 'text/plain' asMIMEType;
		at: 'public.png' put: 'image/png' asMIMEType;
		at: 'public.jpeg' put: 'image/jpeg' asMIMEType; 
		at: 'public.tiff' put: 'image/tiff' asMIMEType; 
		at: 'public.utf16-plain-text' put: 'text/unicode' asMIMEType;
		at: 'public.utf8-plain-text' put: 'text/utf8-unicode' asMIMEType;
		yourself

]

{ #category : #'class initialization' }
ExtendedClipboardMacInterface class >> initializeMimeTypeMap [
	"ExtendedClipboardWinInterface initializeMimeTypeMap"

	mimeTypeMap := Dictionary new.
	mimeTypeMap
		at: 'text/rtf' asMIMEType put: 'public.rtf'; 
		at: 'text/*' asMIMEType put: 'com.apple.traditional-mac-plain-text';
		at: 'image/jpeg' asMIMEType put: 'public.jpeg';
		at: 'image/png' asMIMEType put: 'public.png';
		at: 'text/unicode' asMIMEType put: 'public.utf8-plain-text';
		yourself

]

{ #category : #'general-api-add' }
ExtendedClipboardMacInterface >> addJPEGClipboardData: data [
	self clearClipboard.
	self addClipboardData: data dataFormat: 'public.jpeg'

]

{ #category : #'general-api-add' }
ExtendedClipboardMacInterface >> addPNGClipboardData: data [
	self clearClipboard.
	self addClipboardData: data dataFormat: 'public.png'

]

{ #category : #'general-api-add' }
ExtendedClipboardMacInterface >> addRTFClipboardData: data [
	self clearClipboard.
	self addClipboardData: data dataFormat: 'public.rtf'

]

{ #category : #'general-api-add' }
ExtendedClipboardMacInterface >> addStringClipboardData: data [
	self clearClipboard.
	self addClipboardData: data dataFormat: 'public.text'

]

{ #category : #'general-api-add' }
ExtendedClipboardMacInterface >> addTextClipboardData: data [
	| buffer stream |
	self clearClipboard.
	self addClipboardData: data asString dataFormat: 'public.text'.
	self halt.
	buffer := ByteArray new: 2048.
	stream := (RWBinaryOrTextStream on: buffer) binary .
	data serializeOn:  stream.
	self addClipboardData: (buffer copyFrom: 1 to: stream size) dataFormat: 'org.squeak.text'.
 


]

{ #category : #'general-api-add' }
ExtendedClipboardMacInterface >> addUF8StringClipboardData: aString [
	| ba  |

	self clearClipboard.
	ba := aString convertToWithConverter: (UTF8TextConverter new).
	self addClipboardData: ba dataFormat: 'public.utf8-plain-text'

]

{ #category : #'general-api-add' }
ExtendedClipboardMacInterface >> addWideStringClipboardData: aString [
	| ba  |

	self clearClipboard.
	ba := aString convertToWithConverter: (UTF16TextConverter new useByteOrderMark: true).
	self addClipboardData: ba dataFormat: 'public.utf16-plain-text'

]

{ #category : #'general-api-read' }
ExtendedClipboardMacInterface >> readAvailableFormats [
	| currentFormat availableFormats mimeType formatData |
	availableFormats := OrderedCollection new: 10.
	currentFormat := 1.
	[formatData := self getClipboardFormat: currentFormat.
	formatData notNil]
		whileTrue: [
			mimeType := self class clipboardFormatMap at: formatData asString ifAbsent: [nil].
			mimeType ifNotNil: [
				availableFormats add: mimeType].
		currentFormat := currentFormat +1].
	^availableFormats
]

{ #category : #'general-api-read' }
ExtendedClipboardMacInterface >> readByteStringClipboardData [
	^(self readClipboardData: 'com.apple.traditional-mac-plain-text')
		ifNotNil: [: bytes | bytes asString macToSqueak]

]

{ #category : #'general-api-read' }
ExtendedClipboardMacInterface >> readFormClipboardData [
	| bytes formats |
	formats := self readAvailableFormats.
	(formats includes: 'image/png' asMIMEType)
		ifTrue: [bytes := self readPNGClipboardData.
			^ (PNGReadWriter on: bytes readStream) nextImage].
	(formats includes: 'image/jpeg' asMIMEType)
		ifTrue: [bytes := self readJPEGClipboardData.
			^ (JPEGReadWriter2 on: bytes readStream) nextImage].
	^ nil
]

{ #category : #'general-api-read' }
ExtendedClipboardMacInterface >> readJPEGClipboardData [
	| bytes |
	bytes := self readClipboardData: 'public.jpeg'.
	^bytes

]

{ #category : #'general-api-read' }
ExtendedClipboardMacInterface >> readPNGClipboardData [
	| bytes |
	bytes := self readClipboardData: 'public.png'.
	^bytes

]

{ #category : #'general-api-read' }
ExtendedClipboardMacInterface >> readRTFClipboardData [
	| bytes |
	bytes := self readClipboardData: 'public.rtf'.
	^bytes ifNil: [bytes] ifNotNil: [bytes asString]

]

{ #category : #'general-api-read' }
ExtendedClipboardMacInterface >> readStringClipboardData [
	| string |
	string := self readUTF8StringClipboardData.
	string ifNil: [string := self readWideStringClipboardData].
	string ifNil: [string := self readByteStringClipboardData].
	^string

]

{ #category : #'general-api-read' }
ExtendedClipboardMacInterface >> readTIFFClipboardData [
	| bytes |
	bytes := self readClipboardData: 'public.tiff'.
	^bytes

]

{ #category : #'general-api-read' }
ExtendedClipboardMacInterface >> readTextClipboardData [
	^self readStringClipboardData
		ifNotNil: [:string | (string replaceAll: Character lf with: Character cr) asText]

]

{ #category : #'general-api-read' }
ExtendedClipboardMacInterface >> readUTF8StringClipboardData [
	^(self readClipboardData: 'public.utf8-plain-text')
		ifNotNil: [:bytes |
			[bytes asString utf8ToSqueak] ifError: [bytes asString] ]

]

{ #category : #'general-api-read' }
ExtendedClipboardMacInterface >> readWideStringClipboardData [
	| bytes |
	"utf16 plain text has no bom"

	bytes := self readClipboardData: 'public.utf16-plain-text'.
	^bytes ifNil: [bytes] ifNotNil: 
		[bytes asString convertFromWithConverter: (UTF16TextConverter new useLittleEndian: (SmalltalkImage current endianness = #little)
)]

]

{ #category : #'general-api-utility' }
ExtendedClipboardMacInterface >> setTextString: aString [
	super setTextString: aString.
	aString isWideString
		ifTrue: [self addUF8StringClipboardData: aString].
	Smalltalk at: #MacServicesInterface ifPresent: [:c | c current setTextString: aString].
]
