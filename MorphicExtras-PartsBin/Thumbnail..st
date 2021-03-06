"
A morph that serves as a thumbnail of a given form.
"
Class {
	#name : #Thumbnail,
	#superclass : #SketchMorph,
	#instVars : [
		'maximumWidth',
		'minimumHeight'
	],
	#category : #'MorphicExtras-PartsBin'
}

{ #category : #initialization }
Thumbnail >> initialize [
	"Initialize the receiver"

	super initialize.
	self setStandardDefaultMetrics
]

{ #category : #'thumnail creation' }
Thumbnail >> makeThumbnailFromForm: aForm [
	"Make a thumbnail from the form provided, obeying my min and max width and height preferences"

	|  scaleX scaleY margin opaque nominalWidth minimumWidth |
	minimumWidth := self minimumWidth.
	scaleY := minimumHeight / aForm height.  "keep height invariant"
	
	scaleX := ((nominalWidth := aForm width * scaleY) <= maximumWidth)
		ifTrue:
			[(nominalWidth < minimumWidth)
				ifFalse:
					[scaleY]  "the usual case; same scale factor, to preserve aspect ratio"
				ifTrue:
					[minimumWidth / aForm width]]
		ifFalse:
			[scaleY := maximumWidth / aForm width].

	"self form: (aForm magnify: aForm boundingBox by: (scaleX @ scaleY) smoothing: 2)."
	"Note: A problem with magnify:by: fails to reproduce borders properly.
		The following code does a better job..."
	margin := 1.0 / (scaleX@scaleY) // 2 max: 0@0.  "Extra margin around border"
	opaque := (Form extent: aForm extent + margin depth: 32) "fillWhite".
	aForm displayOn: opaque at: aForm offset negated rule: Form blendAlpha.  "Opaque form shrinks better"
	self form: ((opaque magnify: opaque boundingBox by: (scaleX @ scaleY) smoothing: 2) fixAlpha).

	self extent: originalForm extent
]

{ #category : #initialization }
Thumbnail >> maxWidth: maxWidth minHeight: minHeight [
	"Set the min and max heights and widths as indicated"

	maximumWidth := maxWidth.
	minimumHeight := minHeight
]

{ #category : #initialization }
Thumbnail >> setStandardDefaultMetrics [
	"Provide the current choices for min.max width/height for thumbnails"

	self maxWidth: 60 minHeight: 32.
	self setProperty: #minimumWidth toValue: 16
]
