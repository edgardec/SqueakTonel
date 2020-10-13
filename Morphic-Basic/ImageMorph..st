"
ImageMorph is a morph that displays a picture (Form). My extent is determined by the extent of my form.

Use #image: to set my picture.

Structure:
 instance var		Type 		Description
 image				Form		The Form to use when drawing

Code examples:
	ImageMorph new openInWorld; grabFromScreen

	(Form fromFileNamed: 'myGraphicsFileName') asMorph openInWorld

Relationship to SketchMorph: ImageMorph should be favored over SketchMorph, a parallel, legacy class -- see the Swiki FAQ for details ( http://minnow.cc.gatech.edu/squeak/1372 ). 

"
Class {
	#name : #ImageMorph,
	#superclass : #Morph,
	#instVars : [
		'image'
	],
	#classVars : [
		'DefaultForm'
	],
	#category : #'Morphic-Basic'
}

{ #category : #scripting }
ImageMorph class >> authoringPrototype [
	| aMorph aForm |
	aMorph := super authoringPrototype.
	aForm := ScriptingSystem formAtKey: 'Image'.
	aForm ifNil: [aForm := aMorph image rotateBy: 90].
	aMorph image: aForm.
	^ aMorph
]

{ #category : #accessing }
ImageMorph class >> defaultForm [
	^DefaultForm
]

{ #category : #'parts bin' }
ImageMorph class >> descriptionForPartsBin [
	^ self partName:	'Image' translatedNoop
		categories:		#('Graphics' 'Basic')
		documentation:	'A non-editable picture.  If you use the Paint palette to make a picture, you can edit it afterwards.' translatedNoop
]

{ #category : #'instance creation' }
ImageMorph class >> fromString: aString [ 
	"Create a new ImageMorph which displays the input string in the standard button font"

	^ self fromString: aString font: Preferences standardButtonFont
]

{ #category : #'instance creation' }
ImageMorph class >> fromString: aString font: aFont [
	"Create a new ImageMorph showing the given string in the given font"

	^ self new image: (StringMorph contents: aString font: aFont) imageForm
]

{ #category : #'class initialization' }
ImageMorph class >> initialize [
	"ImageMorph initialize"

	| h p d |
	DefaultForm := (Form extent: 80@40 depth: 16).
	h := DefaultForm height // 2.
	0 to: h - 1 do: [:i |
		p := (i * 2)@i.
		d := i asFloat / h asFloat.
		DefaultForm fill:
			(p corner: DefaultForm extent - p)
			fillColor: (Color r: d g: 0.5 b: 1.0 - d)].

	self registerInFlapsRegistry.
]

{ #category : #'class initialization' }
ImageMorph class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#ImageMorph. #authoringPrototype. 'Picture' translatedNoop. 'A non-editable picture of something' translatedNoop} 
						forFlapNamed: 'Supplies']
]

{ #category : #'class initialization' }
ImageMorph class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #menus }
ImageMorph >> addCustomMenuItems: aMenu hand: aHand [
	super addCustomMenuItems: aMenu hand: aHand.
	aMenu addUpdating: #opacityString action: #changeOpacity
]

{ #category : #accessing }
ImageMorph >> borderStyle: newStyle [
	| newExtent |
	newExtent := 2 * newStyle width + image extent.
	bounds extent = newExtent ifFalse:[super extent: newExtent].
	super borderStyle: newStyle.
]

{ #category : #accessing }
ImageMorph >> borderWidth: bw [
	| newExtent |
	newExtent := 2 * bw + image extent.
	bounds extent = newExtent ifFalse:[super extent: newExtent].
	super borderWidth: bw
]

{ #category : #menu }
ImageMorph >> changeOpacity [
	self isOpaque: self isOpaque not
]

{ #category : #accessing }
ImageMorph >> color: aColor [
        super color: aColor.
        (image depth = 1 and: [aColor isColor]) ifTrue: [
                image colors: {Color transparent. aColor}.
                self changed]
]

{ #category : #drawing }
ImageMorph >> drawOn: aCanvas [
	self borderStyle ifNotNil:[:style |
		style frameRectangle: bounds on: aCanvas.
	].
	self isOpaque
		ifTrue:[aCanvas drawImage: image at: self innerBounds origin]
		ifFalse:[aCanvas translucentImage: image at: self innerBounds origin]
]

{ #category : #geometry }
ImageMorph >> extent: aPoint [

	super extent: self preferredExtent.
]

{ #category : #accessing }
ImageMorph >> form [
	"For compatability with SketchMorph."

	^ image

]

{ #category : #'menu commands' }
ImageMorph >> grabFromScreen [

	self image: Form fromUser.

]

{ #category : #accessing }
ImageMorph >> image [

	^ image

]

{ #category : #accessing }
ImageMorph >> image: anImage [ 
	self changed.
	image := anImage depth = 1 
				ifTrue: [ColorForm mappingWhiteToTransparentFrom: anImage]
				ifFalse: [anImage]. 
	super extent: self preferredExtent
]

{ #category : #initialization }
ImageMorph >> initialize [

	super initialize.
	self image: DefaultForm.

]

{ #category : #'parts bin' }
ImageMorph >> initializeToStandAlone [

	super initializeToStandAlone.
	self image: DefaultForm.

]

{ #category : #testing }
ImageMorph >> isImageMorph [
	^true
]

{ #category : #accessing }
ImageMorph >> isOpaque [
	"Return true if the receiver is marked as being completely opaque"
	^ self
		valueOfProperty: #isOpaque
		ifAbsent: [false]
]

{ #category : #accessing }
ImageMorph >> isOpaque: aBool [
	"Mark the receiver as being completely opaque or not"
	aBool == false
		ifTrue:[self removeProperty: #isOpaque]
		ifFalse:[self setProperty: #isOpaque toValue: aBool].
	self changed
]

{ #category : #other }
ImageMorph >> newForm: aForm [
	self image: aForm
]

{ #category : #menu }
ImageMorph >> opacityString [
	^ (self isOpaque
		ifTrue: ['<on>']
		ifFalse: ['<off>']), 'opaque' translated
]

{ #category : #accessing }
ImageMorph >> preferredExtent [
	^ image ifNil: [0@0] ifNotNil: [image extent]
]

{ #category : #'menu commands' }
ImageMorph >> readFromFile [
	"This would benefit from a way to get a list of the plausible file extensions for image files"
	| fileName |
	fileName := UIManager default
		chooseFileMatchingSuffixes: Form allTypicalFileExtensions
		label: 'Please enter the image file name'.
	fileName isEmpty ifTrue: [^ self].
	self image: (Form fromFileNamed:  fileName).

]

{ #category : #caching }
ImageMorph >> releaseCachedState [

	super releaseCachedState.
	image hibernate.

]

{ #category : #accessing }
ImageMorph >> setNewImageFrom: formOrNil [
	"Change the receiver's image to be one derived from the supplied form.  If nil is supplied, clobber any existing image in the receiver, and in its place put a default graphic, either the one known to the receiver as its default value, else a squeaky mouse"

	|  defaultImage |
	formOrNil ifNotNil: [^ self image: formOrNil].
	defaultImage := self defaultValueOrNil ifNil: [ScriptingSystem squeakyMouseForm].
	self image: defaultImage

]

{ #category : #accessing }
ImageMorph >> wantsRecolorHandle [
	^ image notNil and: [image depth = 1]
]

{ #category : #accessing }
ImageMorph >> withSnapshotBorder [
	self borderStyle: ((ComplexBorder style: #complexFramed)
			color: (Color
					r: 0.613
					g: 1.0
					b: 0.516);
			 width: 1;
			
			 yourself)
]
