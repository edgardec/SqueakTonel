"
I provide fast JPEG compression and decompression. I require the VM pluginJPEGReadWriter2Plugin, which is typically stored in same directory as the Squeak virtual machine.

JPEGReadWriter2Plugin is based on LIBJPEG library. This sentence applies to the plugin:
   ""This software is based in part on the work of the Independent JPEG Group"".

The LIBJPEG license allows it to be used free for any purpose so long as its origin and copyright are acknowledged. You can read more about LIBJPEG and get the complete source code at www.ijg.org.

"
Class {
	#name : #JPEGReadWriter2,
	#superclass : #ImageReadWriter,
	#category : #'Graphics-Files'
}

{ #category : #'image reading\/writing' }
JPEGReadWriter2 class >> primJPEGPluginIsPresent [
	<primitive: 'primJPEGPluginIsPresent' module: 'JPEGReadWriter2Plugin'>
	^false
]

{ #category : #'image reading\/writing' }
JPEGReadWriter2 class >> putForm: aForm quality: quality progressiveJPEG: progressiveFlag onFileNamed: fileName [
	"Store the given Form as a JPEG file of the given name, overwriting any existing file of that name. Quality goes from 0 (low) to 100 (high), where -1 means default. If progressiveFlag is true, encode as a progressive JPEG."

	| writer theFile |
	FileDirectory deleteFilePath: fileName.
	theFile := FileStream newFileNamed: fileName.
	writer := self on: theFile binary.
	Cursor write showWhile: [
		writer nextPutImage: aForm quality: quality progressiveJPEG: progressiveFlag].
	writer close.
	theFile directory setMacFileNamed: theFile localName type: '    ' creator: '    '.
]

{ #category : #'image reading\/writing' }
JPEGReadWriter2 class >> typicalFileExtensions [
	"Answer a collection of file extensions (lowercase) which files that I can read might commonly have"
	^#('jpg' 'jpeg')
]

{ #category : #'public access' }
JPEGReadWriter2 >> compress: aForm quality: quality [
	"Encode the given Form and answer the compressed ByteArray. Quality goes from 0 (low) to 100 (high), where -1 means default.
	We can only compress:
		* 32-bit deep Forms 
		* -32-bit deep Forms
		* 16-bit deep Forms
		* -16-bit deep Forms
		* GrayScale ColorForms (see #isGrayScale)"
	| sourceForm jpegCompressStruct jpegErrorMgr2Struct buffer byteCount |
	
	aForm unhibernate.
	
	sourceForm := self supports8BitGrayscaleJPEGs 
		ifTrue: [ 
			(aForm depth = 32) | (aForm depth = 16) | (aForm isGrayScale)
				ifTrue: [aForm]
				ifFalse: [aForm asFormOfDepth: 32 ]]
		ifFalse: [
			(aForm nativeDepth > 0) & ((aForm depth = 32) | ((aForm depth = 16) & (aForm width even)))
				ifTrue: [aForm]
				ifFalse: [aForm asFormOfDepth: 32 ]].
	
	jpegCompressStruct := ByteArray new: self primJPEGCompressStructSize.
	jpegErrorMgr2Struct := ByteArray new: self primJPEGErrorMgr2StructSize.
	buffer := ByteArray new: sourceForm width * sourceForm height + 1024.
	byteCount := self primJPEGWriteImage: jpegCompressStruct 
		onByteArray: buffer
		form: sourceForm
		quality: quality
		progressiveJPEG: false
		errorMgr: jpegErrorMgr2Struct.
	byteCount = 0 ifTrue: [self error: 'buffer too small for compressed data'].
	^ buffer copyFrom: 1 to: byteCount

]

{ #category : #'public access' }
JPEGReadWriter2 >> imageExtent: aByteArray [ 
	"Answer the extent of the compressed image encoded in the given ByteArray."

	| jpegDecompressStruct jpegErrorMgr2Struct w h |
	jpegDecompressStruct := ByteArray new: self primJPEGDecompressStructSize.
	jpegErrorMgr2Struct := ByteArray new: self primJPEGErrorMgr2StructSize.
	self
		primJPEGReadHeader: jpegDecompressStruct 
		fromByteArray: aByteArray
		errorMgr: jpegErrorMgr2Struct.
	w := self primImageWidth: jpegDecompressStruct.
	h := self primImageHeight: jpegDecompressStruct.
	^ w @ h

]

{ #category : #testing }
JPEGReadWriter2 >> isPluginPresent [
	^self primJPEGPluginIsPresent
]

{ #category : #'public access' }
JPEGReadWriter2 >> nextImage [
	"Decode and answer a Form from my stream."

	^ self nextImageSuggestedDepth: Display depth

]

{ #category : #'public access' }
JPEGReadWriter2 >> nextImageSuggestedDepth: suggestedDepth [
	"Decode and answer a Form of the given depth from my stream. Close the stream if it is a file stream.
	We can read RGB JPEGs into:
		* 32-bit Forms
		* -32-bit Forms
		* 16-bit Forms (with or without dithering!)
		* -16-bit Forms (with or without dithering!)
	We can read grayscale JPEGs into:
		* 32-bit Forms
		* -32-bit Forms
		* 16-bit Forms (with or without dithering!)
		* -16-bit Forms (with or without dithering!)
		* 8-bit grayScale ColorForms (see #isGrayScale)
		* -8-bit grayScale ColorForms (see #isGrayScale)"

	| bytes width height components form jpegDecompressStruct jpegErrorMgr2Struct |
	bytes := stream upToEnd.
	stream close.
	jpegDecompressStruct := ByteArray new: self primJPEGDecompressStructSize.
	jpegErrorMgr2Struct := ByteArray new: self primJPEGErrorMgr2StructSize.
	self 
		primJPEGReadHeader: jpegDecompressStruct 
		fromByteArray: bytes
		errorMgr: jpegErrorMgr2Struct.
	width := self primImageWidth: jpegDecompressStruct.
	height := self primImageHeight: jpegDecompressStruct.
	components := self primImageNumComponents: jpegDecompressStruct.
	form :=
		self supports8BitGrayscaleJPEGs
			ifTrue: [
				components = 3
					ifTrue: [ Form extent: width@height depth: suggestedDepth ]
					ifFalse: [ (Form extent: width@height depth: suggestedDepth) asGrayScale ]]
			ifFalse: [
				Form
					extent: width@height
					depth: 
						(suggestedDepth = 32 
							ifTrue: [ 32 ]
							ifFalse: [
								((suggestedDepth = 16) & (width even))
									ifTrue: [ 16 ]
									ifFalse: [ 32 ]])].
					
	self
		primJPEGReadImage: jpegDecompressStruct
		fromByteArray: bytes
		onForm: form
		doDithering: true
		errorMgr: jpegErrorMgr2Struct.
	^ form
]

{ #category : #'public access' }
JPEGReadWriter2 >> nextPutImage: aForm [
	"Encode the given Form on my stream with default quality."

	^ self nextPutImage: aForm quality: -1 progressiveJPEG: false

]

{ #category : #'public access' }
JPEGReadWriter2 >> nextPutImage: aForm quality: quality progressiveJPEG: progressiveFlag [
	"Encode the given Form on my stream with the given settings. Quality goes from 0 (low) to 100 (high), where -1 means default. If progressiveFlag is true, encode as a progressive JPEG.
	We can compress:
		* 32-bit deep Forms 
		* -32-bit deep Forms
		* 16-bit deep
		* -16-bit deep
		* GrayScale ColorForms (see #isGrayScale)"

	| sourceForm jpegCompressStruct jpegErrorMgr2Struct buffer byteCount |
	
	aForm unhibernate.
	
	sourceForm := self supports8BitGrayscaleJPEGs 
		ifTrue: [ 
			(aForm depth = 32) | (aForm depth = 16) | (aForm isGrayScale)
				ifTrue: [aForm]
				ifFalse: [aForm asFormOfDepth: 32 ]]
		ifFalse: [
			(aForm nativeDepth > 0) & ((aForm depth = 32) | ((aForm depth = 16) & (aForm width even)))
				ifTrue: [aForm]
				ifFalse: [aForm asFormOfDepth: 32 ]].
	
	jpegCompressStruct := ByteArray new: self primJPEGCompressStructSize.
	jpegErrorMgr2Struct := ByteArray new: self primJPEGErrorMgr2StructSize.
	buffer := ByteArray new: sourceForm width * sourceForm height + 1024.
	"Try to write the image. Retry with a larger buffer if needed."
	[
		byteCount := self primJPEGWriteImage: jpegCompressStruct 
			onByteArray: buffer
			form: sourceForm
			quality: quality
			progressiveJPEG: progressiveFlag
			errorMgr: jpegErrorMgr2Struct.
		byteCount = 0 and: [ buffer size < (sourceForm width * sourceForm height * 3 + 1024) ] ]
			whileTrue: [ buffer := ByteArray new: buffer size * 2 ].
	byteCount = 0 ifTrue: [ self error: 'buffer too small for compressed data' ].
	stream next: byteCount putAll: buffer startingAt: 1.
	self close.

]

{ #category : #primitives }
JPEGReadWriter2 >> primImageHeight: aJPEGCompressStruct [

	<primitive: 'primImageHeight' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
JPEGReadWriter2 >> primImageNumComponents: aJPEGDecompressStruct [

	<primitive: 'primImageNumComponents' module: 'JPEGReadWriter2Plugin'>
	^ 3
]

{ #category : #primitives }
JPEGReadWriter2 >> primImageWidth: aJPEGCompressStruct [

	<primitive: 'primImageWidth' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
JPEGReadWriter2 >> primJPEGCompressStructSize [

	<primitive: 'primJPEGCompressStructSize' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
JPEGReadWriter2 >> primJPEGDecompressStructSize [

	<primitive: 'primJPEGDecompressStructSize' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
JPEGReadWriter2 >> primJPEGErrorMgr2StructSize [

	<primitive: 'primJPEGErrorMgr2StructSize' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
JPEGReadWriter2 >> primJPEGPluginIsPresent [
	<primitive: 'primJPEGPluginIsPresent' module: 'JPEGReadWriter2Plugin'>
	^false
]

{ #category : #primitives }
JPEGReadWriter2 >> primJPEGReadHeader: aJPEGDecompressStruct fromByteArray: source errorMgr: aJPEGErrorMgr2Struct [

	<primitive: 'primJPEGReadHeaderfromByteArrayerrorMgr' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
JPEGReadWriter2 >> primJPEGReadImage: aJPEGDecompressStruct fromByteArray: source onForm: form doDithering: ditherFlag errorMgr: aJPEGErrorMgr2Struct [

	<primitive: 'primJPEGReadImagefromByteArrayonFormdoDitheringerrorMgr' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
JPEGReadWriter2 >> primJPEGWriteImage: aJPEGCompressStruct onByteArray: destination form: form quality: quality progressiveJPEG: progressiveFlag errorMgr: aJPEGErrorMgr2Struct [

	<primitive: 'primJPEGWriteImageonByteArrayformqualityprogressiveJPEGerrorMgr' module: 'JPEGReadWriter2Plugin'>
	self primitiveFailed

]

{ #category : #primitives }
JPEGReadWriter2 >> primSupports8BitGrayscaleJPEGs [
	<primitive: 'primSupports8BitGrayscaleJPEGs' module: 'JPEGReadWriter2Plugin'>
	^ false
]

{ #category : #testing }
JPEGReadWriter2 >> supports8BitGrayscaleJPEGs [
	^ self primSupports8BitGrayscaleJPEGs
]

{ #category : #'public access' }
JPEGReadWriter2 >> uncompress: aByteArray into: aForm [
	^ self uncompress: aByteArray into: aForm doDithering: true

]

{ #category : #'public access' }
JPEGReadWriter2 >> uncompress: aByteArray into: aForm doDithering: ditherFlag [
	"Uncompress an image from the given ByteArray into the given Form. 
	Fails if the given Form has the wrong dimensions or depth.
	We can read RGB JPEGs into:
		* 32-bit Forms
		* -32-bit Forms
		* 16-bit Forms (with or without dithering!)
		* -16-bit Forms (with or without dithering!)
	We can read grayscale JPEGs into:
		* 32-bit Forms
		* -32-bit Forms
		* 16-bit Forms (with or without dithering!)
		* -16-bit Forms (with or without dithering!)
		* 8-bit grayScale ColorForms (see #isGrayScale)
		* -8-bit grayScale ColorForms (see #isGrayScale)"

	| jpegDecompressStruct jpegErrorMgr2Struct width height components |
	
	aForm unhibernate.
	
	jpegDecompressStruct := ByteArray new: self primJPEGDecompressStructSize.
	jpegErrorMgr2Struct := ByteArray new: self primJPEGErrorMgr2StructSize.
	self 
		primJPEGReadHeader: jpegDecompressStruct 
		fromByteArray: aByteArray
		errorMgr: jpegErrorMgr2Struct.
	width := self primImageWidth: jpegDecompressStruct.
	height := self primImageHeight: jpegDecompressStruct.
	components := self primImageNumComponents: jpegDecompressStruct.
	
	((aForm width = width) & (aForm height = height)) ifFalse: [
		^ self error: 'form dimensions do not match' ].
	self supports8BitGrayscaleJPEGs
		ifTrue: [
			components = 3
				ifTrue: [
					aForm depth = 8
						ifTrue: [ ^ self error: 'Cannot uncompress multi-channel JPEGs into 8-bit deep forms' ]].
			components = 1
				ifTrue: [
					aForm depth = 8
						ifTrue: [
							aForm isGrayScale 
								ifFalse: [ ^ self error: 'Cannot uncompress single-channel JPEGs into 8-bit deep forms that are not grayscale' ]]]]
						
		ifFalse: [
			aForm nativeDepth < 0
				ifTrue: [ ^ self error: 'Current plugin version doesn''t support uncompressing JPEGs into little-endian forms' ]
				ifFalse: [
					aForm depth = 16
						ifTrue: [
							width odd
								ifTrue: [ ^ self error: 'Current plugin version doesn''t support uncompressing JPEGs with an odd width into 16-bit deep forms' ]].
					aForm depth = 8
						ifTrue: [ ^ self error: 'Current plugin version doesn''t support uncompressing JPEGs into 8-bit deep forms' ]]].

	self primJPEGReadImage: jpegDecompressStruct
		fromByteArray: aByteArray
		onForm: aForm
		doDithering: ditherFlag
		errorMgr: jpegErrorMgr2Struct.

]

{ #category : #testing }
JPEGReadWriter2 >> understandsImageFormat [
	"Answer true if the image stream format is understood by this decoder."
	self isPluginPresent ifFalse:[^false]. "cannot read it otherwise"
	self next = 16rFF ifFalse: [^ false].
	self next = 16rD8 ifFalse: [^ false].
	^ true

]
