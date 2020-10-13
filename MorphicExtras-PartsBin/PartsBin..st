Class {
	#name : #PartsBin,
	#superclass : #PasteUpMorph,
	#classVars : [
		'Thumbnails'
	],
	#category : #'MorphicExtras-PartsBin'
}

{ #category : #'thumbnail cache' }
PartsBin class >> cacheAllThumbnails [
	"In one monster operation, cache all the thumbnails of parts.  Intended to be called from do-its in update postscripts, for example, or manually."

	Cursor wait showWhile:
		[Morph withAllSubclasses do: [:aClass |
			(aClass class includesSelector: #descriptionForPartsBin) ifTrue:
				[self thumbnailForPartsDescription: aClass descriptionForPartsBin].
			(aClass class includesSelector: #supplementaryPartsDescriptions) ifTrue:
				[aClass supplementaryPartsDescriptions do:
					[:aDescription | self thumbnailForPartsDescription: aDescription]]]]

"Time millisecondsToRun: [PartsBin initialize. PartsBin cacheAllThumbnails]"

]

{ #category : #'thumbnail cache' }
PartsBin class >> cacheThumbnail: aThumbnail forSymbol: aSymbol [
	"Cache the thumbnail provided as the graphic representing a parts-bin denizen whose name is the given symbol"

	Thumbnails at: aSymbol put: aThumbnail
]

{ #category : #'class initialization' }
PartsBin class >> cleanUp [
	"Flush caches"

	self clearThumbnailCache
]

{ #category : #'thumbnail cache' }
PartsBin class >> clearThumbnailCache [
	"Clear the cache of thumbnails:
		PartsBin clearThumbnailCache
"

	Thumbnails := Dictionary new
]

{ #category : #'class initialization' }
PartsBin class >> initialize [
	"Initialize the PartsBin class, by starting it out with an empty Thumbnails dictionary"

	Thumbnails := Dictionary new
	"PartsBin initialize"
]

{ #category : #'class initialization' }
PartsBin class >> localeChanged [
	self initialize
]

{ #category : #'instance creation' }
PartsBin class >> newPartsBinWithOrientation: aListDirection andColor: aColor from: quadList [ 
	"Answer a new PartBin object, to run horizontally or vertically,  
	obtaining its elements from the list of tuples of the form:  
	(<receiver> <selector> <label> <balloonHelp>)"
	^ (self new)
		color: aColor;
		listDirection: aListDirection quadList: (self translatedQuads: quadList).
]

{ #category : #'instance creation' }
PartsBin class >> newPartsBinWithOrientation: aListDirection from: quadList [ 
	"Answer a new PartBin object, to run horizontally or vertically,  
	obtaining its elements from the list of tuples of the form:  
	(<receiver> <selector> <label> <balloonHelp>)"
	^ self new
		listDirection: aListDirection
		quadList: (self translatedQuads: quadList) 
]

{ #category : #'thumbnail cache' }
PartsBin class >> thumbnailForInstanceOf: aMorphClass [
	"Answer a thumbnail for a stand-alone instance of the given class, creating it if necessary.  If it is created afresh, it will also be cached at this time"

	^ Thumbnails at: aMorphClass name ifAbsent:
		[| aThumbnail |
		aThumbnail := Thumbnail new makeThumbnailFromForm: aMorphClass newStandAlone imageForm.
		self cacheThumbnail: aThumbnail forSymbol: aMorphClass name.
		^ aThumbnail]

"PartsBin initialize"
]

{ #category : #'thumbnail cache' }
PartsBin class >> thumbnailForPartsDescription: aPartsDescription [
	"Answer a thumbnail for the given parts description creating it if necessary.  If it is created afresh, it will also be cached at this time"

	| aSymbol |
	aSymbol := aPartsDescription formalName asSymbol.
	^ Thumbnails at: aSymbol ifAbsent:
		[| aThumbnail |
		aThumbnail := Thumbnail new makeThumbnailFromForm: aPartsDescription sampleImageForm.
		self cacheThumbnail: aThumbnail forSymbol: aSymbol.
		^ aThumbnail]

"PartsBin initialize"
]

{ #category : #'thumbnail cache' }
PartsBin class >> thumbnailForQuad: aQuint [
	"Answer a thumbnail for a morph obtaining as per the quintuplet provided, creating the thumbnail if necessary.  If it is created afresh, it will also be cached at this time"
	^self thumbnailForQuad: aQuint color: Color transparent.
]

{ #category : #'thumbnail cache' }
PartsBin class >> thumbnailForQuad: aQuint color: aColor [
	"Answer a thumbnail for a morph obtaining as per the quintuplet provided, creating the thumbnail if necessary.  If it is created afresh, it will also be cached at this time"

	| aThumbnail aSymbol formToThumbnail labeledItem |
	aSymbol := aQuint third.
	Thumbnails at: aSymbol ifPresent: [ :thumb | ^thumb ].
	formToThumbnail := aQuint at: 5 ifAbsent: [].
	formToThumbnail ifNil: [
		labeledItem := (Smalltalk at: aQuint first) perform: aQuint second.
		formToThumbnail := labeledItem imageForm: 32 backgroundColor: aColor forRectangle: labeledItem fullBounds.
		formToThumbnail replaceColor: aColor withColor: Color transparent.
		labeledItem delete.
	].

	aThumbnail := Thumbnail new makeThumbnailFromForm: formToThumbnail.
	self cacheThumbnail: aThumbnail forSymbol: aSymbol.
	^ aThumbnail

"PartsBin initialize"
]

{ #category : #private }
PartsBin class >> translatedQuads: quads [
	"private - convert the given quads to a translated one"
	
	| translatedQuads |

	translatedQuads := quads collect: [:each |
		| element |
		element := each copy. 
		element at: 3 put: each third translated.
		element at: 4 put: each fourth translated.
		element.
	].

	^ translatedQuads

]

{ #category : #properties }
PartsBin >> innocuousName [
	"Answer a harmless name for an unnamed instance"

	^ 'parts bin' translated
]

{ #category : #initialization }
PartsBin >> listDirection: aListDirection quadList: quadList [
	"Initialize the receiver to run horizontally or vertically, obtaining its elements from the list of tuples of the form:
		(<receiver> <selector> <label> <balloonHelp>)"

	^self listDirection: aListDirection quadList: quadList buttonClass: IconicButton
]

{ #category : #initialization }
PartsBin >> listDirection: aListDirection quadList: quadList buttonClass: buttonClass [
	"Initialize the receiver to run horizontally or vertically, obtaining its elements from the list of tuples of the form:
		(<receiver> <selector> <label> <balloonHelp>)
	Used by external package Connectors."

	self layoutPolicy: TableLayout new.
	self listDirection: aListDirection.
	self wrapCentering: #topLeft.
	self layoutInset: 2.
	self cellPositioning: #bottomCenter.

	aListDirection == #leftToRight
		ifTrue:
			[self vResizing: #rigid.
			self hResizing: #spaceFill.
			self wrapDirection: #topToBottom]
		ifFalse:
			[self hResizing: #rigid.
			self vResizing: #spaceFill.
			self wrapDirection: #leftToRight].
	quadList do:
		[:tuple |
			| aButton aClass |
			aClass := Smalltalk at: tuple first.
			aButton := buttonClass new 
				initializeWithThumbnail: (self class thumbnailForQuad: tuple color: self color) 				withLabel: tuple third 
				andColor: self color 
				andSend: tuple second 
				to: aClass.
			(tuple size > 3 and: [tuple fourth isEmptyOrNil not]) ifTrue:
				[aButton setBalloonText: tuple fourth].
 			self addMorphBack: aButton]
]

{ #category : #'dropping\/grabbing' }
PartsBin >> morphToDropFrom: aMorph [
	"Answer the morph to drop if the user attempts to drop aMorph"

	| aButton |
	((aMorph isKindOf: IconicButton) and: [aMorph actionSelector == #launchPartVia:label:])
		ifTrue: [^ aMorph].  
	"The above handles the unusual case of a button that's already set up in a manner suitable for living in PartsBin; the archetypal example is the attempt to reposition an object within a partsflap by dragging it via the black halo handle."

	aButton := IconicButton new.
	aButton color: self color;
		initializeToShow: aMorph withLabel: aMorph externalName andSend: #veryDeepCopy to: aMorph veryDeepCopy.
	^ aButton
]

{ #category : #'dropping\/grabbing' }
PartsBin >> wantsDroppedMorph: aMorph event: evt [
	"Answer whether the receiver would like to accept the given morph.  For a Parts bin, we accept just about anything except something that just originated from ourselves"

	(aMorph hasProperty: #beFullyVisibleAfterDrop) ifTrue:
		[^ true].

	^ super wantsDroppedMorph: aMorph event: evt
]

{ #category : #'event handling' }
PartsBin >> wantsEasySelection [
	"Answer if the receiver want easy selection mode"
	^ false
]
