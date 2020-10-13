Class {
	#name : #ExtendedClipboardUnixInterface,
	#superclass : #ExtendedClipboardInterface,
	#category : #'Etoys-Squeakland-System-Clipboard-Extended'
}

{ #category : #'general-api-add' }
ExtendedClipboardUnixInterface >> addPNGClipboardData: data [
	self clearClipboard.
	self addClipboardData: data dataFormat: 'image/png'

]

{ #category : #'general-api-add' }
ExtendedClipboardUnixInterface >> cleanupToCopyMorphic [
	Clipboard default delete.

]

{ #category : #'general-api-read' }
ExtendedClipboardUnixInterface >> readAvailableFormats [
	| currentFormat availableFormats mimeType formatData |
	availableFormats := OrderedCollection new: 10.
	currentFormat := 1.
	[formatData := self getClipboardFormat: currentFormat.
	formatData notNil]
		whileTrue: [
			"mimeType := self class clipboardFormatMap at: formatData asString ifAbsent: [nil]".
			mimeType := formatData.
			mimeType ifNotNil: [
				availableFormats add: mimeType].
		currentFormat := currentFormat +1].
	^availableFormats
]

{ #category : #'general-api-read' }
ExtendedClipboardUnixInterface >> readFormClipboardData [
	| bytes formats |
	formats := self readAvailableFormats.
	(formats includes: 'image/png')
		ifTrue: [bytes := self readClipboardData: 'image/png'.
			^ (PNGReadWriter on: bytes readStream) nextImage].
	(formats includes: 'image/bmp')
		ifTrue: [bytes := self readClipboardData: 'image/bmp'.
			^ (BMPReadWriter on: bytes readStream) nextImage].
	^ nil
]

{ #category : #'general-api-read' }
ExtendedClipboardUnixInterface >> readHTMLClipboardData [
	| bytes source |
	"Answer a HTMLDocument object"
	bytes := self readClipboardData: 'text/html'.
	(bytes beginsWith: '<!DOCTYPE' asByteArray)
		ifTrue: ["BAD HACK for Abiword"
			source := bytes asString convertFromWithConverter: UTF8TextConverter new]
		ifFalse: ["BAD HACK for mozilla"
			source := bytes asString
						convertFromWithConverter: (UTF16TextConverter new useLittleEndian: SmalltalkImage current isLittleEndian)].
	^ HtmlParser parse: source readStream
]

{ #category : #'general-api-read' }
ExtendedClipboardUnixInterface >> readStringClipboardData [
	^self readWideStringClipboardData
]

{ #category : #'general-api-read' }
ExtendedClipboardUnixInterface >> readTextClipboardData [
	| formats |
	formats := self readAvailableFormats.
	(formats includes: 'text/html')
		ifTrue: [^ self readHTMLClipboardData formattedText].
	(formats includes: 'UTF8_STRING')
		ifTrue: [^self readWideStringClipboardData asText].
	(formats includes: 'STRING')
		ifTrue: ["handled by old clipboard code, fall through"].
	^ nil
]

{ #category : #'general-api-read' }
ExtendedClipboardUnixInterface >> readWideStringClipboardData [
	^(self readClipboardData: 'UTF8_STRING') asString utf8ToSqueak
]
