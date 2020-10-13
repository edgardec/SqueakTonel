"
I am a canvas for generating Encapsulates PostScript (EPS) files from single morphs, for example for screen-dumps.

I make sure that the bounding box of the EPS surrounds exactly the morph, and am not capable of generating multiple pages.  I do not generate an on-screen Preview for the EPS file, though that should be possible.

"
Class {
	#name : #EPSCanvas,
	#superclass : #PostscriptCanvas,
	#category : #'MorphicExtras-Postscript Canvases'
}

{ #category : #configuring }
EPSCanvas class >> baseOffset [
	^0@0.
]

{ #category : #configuring }
EPSCanvas class >> defaultExtension [
	^'.eps'
]

{ #category : #'drawing-general' }
EPSCanvas >> fullDraw: aMorph [
	super fullDraw: aMorph.
	morphLevel = 0 ifTrue: [
		self writeTrailer: 1.
	]
]

{ #category : #'page geometry' }
EPSCanvas >> pageBBox [
	^psBounds
]

{ #category : #'page geometry' }
EPSCanvas >> pageOffset [
	^0@0
]

{ #category : #private }
EPSCanvas >> writeEPSPreviewImageFor: aMorph [
	| form stream string newExtent |
	newExtent := (aMorph width roundUpTo: 8) @ aMorph height.
	form := aMorph imageForm: 1 forRectangle: (aMorph bounds origin extent: newExtent).
	stream := WriteStream on: (String new: (form bits byteSize * 2.04) asInteger).
	form storePostscriptHexOn: stream.
	string := stream contents.

	"%%BeginPreview: 80 24 1 24"
	"width height depth "
	target print: '%%BeginPreview: '; write:  newExtent; space; write: form depth; space; write: string lineCount; cr.

	string linesDo: [:e | target nextPut: $%; nextPutAll: e; cr.].

	target print: '%%EndPreview'; cr.


]

{ #category : #private }
EPSCanvas >> writePSIdentifierRotated: rotateFlag [ 
	target
		print: '%!PS-Adobe-2.0 EPSF-2.0';
		cr.
	rotateFlag 
		ifTrue: 
			[target
				print: '%%BoundingBox: ';
				write: (0 @ 0 corner: psBounds corner transposed) rounded;
				cr]
		ifFalse: 
			[target
				print: '%%BoundingBox: ';
				write: psBounds rounded;
				cr].
	target
		print: '%%Title: ';
		print: self topLevelMorph externalName;
		cr.
	target
		print: '%%Creator: ';
		print: Utilities authorName;
		cr.
	target
		print: '%%CreationDate: ';
		print: Date today asString;
		space;
		print: Time now asString;
		cr.
		
	"is this relevant?"
	target print: '%%Orientation: ';
		 print: (rotateFlag ifTrue: [ 'Landscape' ] ifFalse: [ 'Portrait' ]);
		cr.
	target print: '%%DocumentFonts: (atend)'; cr.
	target
		print: '%%EndComments';
		cr

	"	self writeEPSPreviewImageFor: topLevelMorph."

	"	target print: '%%EndProlog'; cr."
]
