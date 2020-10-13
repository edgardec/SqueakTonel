"
I am an ImageMorph that can hold more than one image. Each image has its own delay time.
"
Class {
	#name : #AnimatedImageMorph,
	#superclass : #ImageMorph,
	#instVars : [
		'images',
		'delays',
		'stepTime',
		'nextTime',
		'imageIndex'
	],
	#category : #'MorphicExtras-AdditionalMorphs'
}

{ #category : #'fileIn\/Out' }
AnimatedImageMorph class >> fileReaderServicesForFile: fullName suffix: suffix [

	^((AnimatedGIFReadWriter typicalFileExtensions asSet
		add: '*'; add: 'form'; yourself)
		includes: suffix)
		ifTrue: [ self services ]
		ifFalse: [#()]

]

{ #category : #'instance creation' }
AnimatedImageMorph class >> fromGIFFileNamed: fileName [
	| reader |
	reader := AnimatedGIFReadWriter formsFromFileNamed: fileName.
	^reader forms size = 1
		ifTrue: [ ImageMorph new image: reader forms first ]
		ifFalse: [ self new fromReader: reader ]
]

{ #category : #'instance creation' }
AnimatedImageMorph class >> fromStream: aStream [
	| reader |
	reader := AnimatedGIFReadWriter formsFromStream: aStream.
	^reader forms size = 1
		ifTrue: [ ImageMorph new image: reader forms first ]
		ifFalse: [ self new fromReader: reader ]
]

{ #category : #'class initialization' }
AnimatedImageMorph class >> initialize [
	"register the receiver in the global registries"
	self environment
		at: #FileServices
		ifPresent: [:cl | cl registerFileReader: self]
]

{ #category : #'instance creation' }
AnimatedImageMorph class >> openGIFInWindow: aStream [
	^(self fromStream: aStream binary) openInWorld
]

{ #category : #'fileIn\/Out' }
AnimatedImageMorph class >> serviceOpenGIFInWindow [
	"Answer a service for opening a gif graphic in a window"
	^ (SimpleServiceEntry
		provider: self
		label: 'open the graphic as a morph'
		selector: #openGIFInWindow:
		description: 'open a GIF graphic file as a morph'
		buttonLabel: 'open')
		argumentGetter: [:fileList | fileList readOnlyStream]
]

{ #category : #'fileIn\/Out' }
AnimatedImageMorph class >> services [
	^ Array
		with: self serviceOpenGIFInWindow
		"with: Form serviceImageImports"
		with: Form serviceImageAsBackground
]

{ #category : #'class initialization' }
AnimatedImageMorph class >> unload [
	"Unload the receiver from global registries"
	self environment
		at: #FileServices
		ifPresent: [:cl | cl unregisterFileReader: self]
]

{ #category : #private }
AnimatedImageMorph >> fromGIFFileNamed: fileName [
	self fromReader: (AnimatedGIFReadWriter formsFromFileNamed: fileName)
]

{ #category : #private }
AnimatedImageMorph >> fromImages: anArray [ 

	images := anArray.
	self setUniformDelay: 10.
	self isOpaque: true.
	self reset.
]

{ #category : #private }
AnimatedImageMorph >> fromImages: anArray delay: anInteger [

	images := anArray.
	self setUniformDelay: anInteger.
	self isOpaque: true.
	self reset.
]

{ #category : #private }
AnimatedImageMorph >> fromReader: reader [
	images := reader forms.
	delays := reader delays.
	(images anySatisfy:[:each|(each colors includes: Color transparent)])  ifTrue:[self isOpaque: true].
	self reset.
]

{ #category : #private }
AnimatedImageMorph >> fromStream: aStream [
	self fromReader: (AnimatedGIFReadWriter formsFromStream: aStream)
]

{ #category : #private }
AnimatedImageMorph >> images [
	^images
]

{ #category : #private }
AnimatedImageMorph >> initialize [
	nextTime := Time millisecondClockValue.
	imageIndex := 1.
	stepTime := 10.
	super initialize
]

{ #category : #private }
AnimatedImageMorph >> reset [

	imageIndex := 0.
	self image: (Form extent: images first extent depth: 32).
	self step.
]

{ #category : #private }
AnimatedImageMorph >> setUniformDelay: anInteger [
      "set delay to a uniform value for all images"
	delays := Array new: images size withAll: anInteger.
]

{ #category : #'stepping and presenter' }
AnimatedImageMorph >> step [
	| d form |
	images isEmpty ifTrue: [^ self].
		
	nextTime > Time millisecondClockValue
		ifTrue: [^self].
"	self changed."
	imageIndex > 0 ifTrue: [
		form := images at: imageIndex.
		form displayOn: self image at: 0@0 rule: (self isOpaque ifTrue: [Form paint] ifFalse: [Form erase])].
	form := images at: (imageIndex := imageIndex \\ images size + 1).
	form displayOn: self image at: 0@0 rule: Form paint.
	self changed. 
	d := (delays at: imageIndex) ifNil: [0].
	nextTime := Time millisecondClockValue + d

]

{ #category : #'stepping and presenter' }
AnimatedImageMorph >> stepTime [
	^stepTime ifNil: [super stepTime]
]

{ #category : #'stepping and presenter' }
AnimatedImageMorph >> stepTime: anInteger [
	stepTime := anInteger
]

{ #category : #'stepping and presenter' }
AnimatedImageMorph >> wantsSteps [
	^(images size > 1)

]
