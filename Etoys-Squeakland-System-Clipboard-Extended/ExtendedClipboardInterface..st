Class {
	#name : #ExtendedClipboardInterface,
	#superclass : #Object,
	#instVars : [
		'clipboard'
	],
	#classVars : [
		'Current',
		'WinClipboardTypes'
	],
	#classInstVars : [
		'mimeTypeMap',
		'clipboardFormatMap'
	],
	#category : #'Etoys-Squeakland-System-Clipboard-Extended'
}

{ #category : #private }
ExtendedClipboardInterface class >> clipboardFormatMap [
	^clipboardFormatMap
]

{ #category : #accessing }
ExtendedClipboardInterface class >> current [
	| platform |
	Current
		ifNil: [Current := (Smalltalk includesKey: #CPlatform)
						ifTrue: [(Smalltalk at: #CPlatform) current extendedClipboardInterfaceClass new]
						ifFalse: ["workaround"
							platform := SmalltalkImage current platformName.
							platform = 'unix'
								ifTrue: [ExtendedClipboardUnixInterface new]
								ifFalse: [platform = 'Win32'
										ifTrue: [ExtendedClipboardWinInterface new]
										ifFalse: [ExtendedClipboardMacInterface new]]]].
	^ Current
]

{ #category : #'class initialization' }
ExtendedClipboardInterface class >> initialize [
	"ExtendedClipboardInterface initialize"
	Current := nil.
	Smalltalk
		addToStartUpList: self;
		addToShutDownList: self.
]

{ #category : #private }
ExtendedClipboardInterface class >> mimeTypeMap [
	^mimeTypeMap
]

{ #category : #'system startup' }
ExtendedClipboardInterface class >> shutDown: quitting [

]

{ #category : #'system startup' }
ExtendedClipboardInterface class >> startUp: resuming [
	"The image is either being newly started (resuming is true), or it's just been snapshotted"

	Current := nil.
	self current.
]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> addClipboardData: data dataFormat: aFormat [
	clipboard = 0 ifTrue: 
		[Clipboard clipboardText: data asString.	
		^self].
	self primAddClipboardData: clipboard data: data dataFormat: aFormat.
]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> addClipboardDataConvertFormToJPEG: aForm [
	
	self useImageReadWriter: JPEGReadWriter2 
		onForm: aForm 
		addClipboardMethod: [:b | self addJPEGClipboardData: b].

]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> addClipboardDataConvertFormToPNG: aForm [
	
	self useImageReadWriter: PNGReadWriter 
		onForm: aForm 
		addClipboardMethod: [:b | self addPNGClipboardData: b].

]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> addClipboardDataResolveCorrectType: data [
	^data class addClipboardDataResolveCorrectType: data
]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> addJPEGClipboardData: data [
	^self subclassResponsibility
]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> addPNGClipboardData: data [
	"I'm not sure the proper way of default behavior, though, now I made it blank to avoid a temporary error. -- 6/28/2007 tak"
	"Do nothing"
]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> addRTFClipboardData: data [
	^self subclassResponsibility
]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> addStringClipboardData: data [
	^self subclassResponsibility
]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> addTextClipboardData: data [
	^self subclassResponsibility
]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> addWideStringClipboardData: data [
	^self subclassResponsibility
]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> cleanupToCopyMorphic [
	"For some very complicated issue, this method is called when you copy a morph.
	The morph is stored into PasteBuffer class variable. So text clipboard should not be
	referenced. That's why this is needed. I'll re-implement it more straightforward way."
	Clipboard clipboardText: ''.

]

{ #category : #'general-api-utility' }
ExtendedClipboardInterface >> clearClipboard [
	clipboard = 0 ifTrue: [^self].
	^ self primClearClipboard: clipboard.
]

{ #category : #testing }
ExtendedClipboardInterface >> clipboardMimeTypeExists: mimeType [
	| availableFormats |
	availableFormats := self readAvailableFormats.
	^availableFormats includes: mimeType
]

{ #category : #'general-api-utility' }
ExtendedClipboardInterface >> createClipboard [
	clipboard = 0 ifTrue: [^self].
	^ self primCreateClipboard.
]

{ #category : #'general-api-utility' }
ExtendedClipboardInterface >> getClipboardFormat: formatNumber [
	clipboard = 0 ifTrue: [^nil].
	^ self primGetClipboardFormat: clipboard formatNumber: formatNumber.
]

{ #category : #'initialize-release' }
ExtendedClipboardInterface >> initialize [
	clipboard := [self createClipboard] on: Error do: [:ex | clipboard := 0]
]

{ #category : #'system primitives' }
ExtendedClipboardInterface >> primAddClipboardData: clipboard data: data dataFormat: aFormat [

	<primitive:'ioAddClipboardData' module: 'ClipboardExtendedPlugin'>
	^ self primitiveFailed.
]

{ #category : #'system primitives' }
ExtendedClipboardInterface >> primClearClipboard: clipboard [

	<primitive:'ioClearClipboard' module: 'ClipboardExtendedPlugin'>
	^ self primitiveFailed.

]

{ #category : #'system primitives' }
ExtendedClipboardInterface >> primCreateClipboard [
	<primitive:'ioCreateClipboard' module: 'ClipboardExtendedPlugin'>
	^ self primitiveFailed.

]

{ #category : #'system primitives' }
ExtendedClipboardInterface >> primGetClipboardFormat: clipboard formatNumber: formatNumber [

	<primitive:'ioGetClipboardFormat' module: 'ClipboardExtendedPlugin'>
	^ self primitiveFailed.

]

{ #category : #'system primitives' }
ExtendedClipboardInterface >> primReadClipboardData: clipboard format: format [

	<primitive:'ioReadClipboardData' module: 'ClipboardExtendedPlugin'>.
	^ self primitiveFailed.

]

{ #category : #'general-api-read' }
ExtendedClipboardInterface >> readBMPClipboardData [
	^ self subclassResponsibility
]

{ #category : #'general-api-read' }
ExtendedClipboardInterface >> readByteStringClipboardData [
	^ self subclassResponsibility
]

{ #category : #'general-api-read' }
ExtendedClipboardInterface >> readClipboardData: format [
	^clipboard = 0 ifFalse: 
		[self primReadClipboardData: clipboard format: format].
]

{ #category : #'general-api-read' }
ExtendedClipboardInterface >> readFormClipboardData [
	^ nil
]

{ #category : #'general-api-read' }
ExtendedClipboardInterface >> readJPEGClipboardData [
	^ self subclassResponsibility
]

{ #category : #'general-api-read' }
ExtendedClipboardInterface >> readPNGClipboardData [
	^ self subclassResponsibility
]

{ #category : #'general-api-read' }
ExtendedClipboardInterface >> readRTFClipboardData [
	^ self subclassResponsibility
]

{ #category : #'general-api-read' }
ExtendedClipboardInterface >> readStringClipboardData [
	^ self subclassResponsibility
]

{ #category : #'general-api-read' }
ExtendedClipboardInterface >> readTIFFClipboardData [
	^ self subclassResponsibility
]

{ #category : #'general-api-read' }
ExtendedClipboardInterface >> readTextClipboardData [
	^ nil
]

{ #category : #'general-api-read' }
ExtendedClipboardInterface >> readWideStringClipboardData [
	^ self subclassResponsibility
]

{ #category : #'general-api-utility' }
ExtendedClipboardInterface >> setTextString: aString [
	Smalltalk at: #CClipboard ifPresent: [:c | c clipboardText: aString]
]

{ #category : #'general-api-add' }
ExtendedClipboardInterface >> useImageReadWriter: aImageReadWriterClass onForm: aForm addClipboardMethod: aAddClipBoardBlock [
	| estimate buffer stream pngConverter |
	(aForm isKindOf: Form) ifTrue: 
		[estimate := (aForm extent x)*(aForm extent y).
		estimate := 1024 max: (estimate * 4 * 3 // 4).
		buffer := ByteArray new: estimate.
		stream := (RWBinaryOrTextStream on: buffer) binary .
		pngConverter := aImageReadWriterClass on: stream.
		pngConverter nextPutImage: aForm.
		pngConverter close.	
		aAddClipBoardBlock value: stream contents].
		

]
