Class {
	#name : #DSCPostscriptCanvasToDisk,
	#superclass : #DSCPostscriptCanvas,
	#category : #'MorphicExtras-Postscript Canvases'
}

{ #category : #configuring }
DSCPostscriptCanvasToDisk class >> defaultTarget [

	^PostscriptEncoderToDisk stream.

]

{ #category : #drawing }
DSCPostscriptCanvasToDisk class >> morphAsPostscript: aMorph rotated: rotateFlag offsetBy: offset [

	^self morphAsPostscript: aMorph rotated: rotateFlag offsetBy: offset specs: nil

]

{ #category : #drawing }
DSCPostscriptCanvasToDisk class >> morphAsPostscript: aMorph rotated: rotateFlag offsetBy: offset specs: specsOrNil [


	^[
		(self new morphAsPostscript: aMorph rotated: rotateFlag offsetBy: offset) close
	]
		on: PickAFileToWriteNotification
		do: [ :ex |
			| newFileName stream |
			newFileName := UIManager default
				saveFilenameRequest: 'Name of file to write:' translated
				initialAnswer: 'xxx',Time millisecondClockValue printString, self defaultExtension. 
			newFileName isEmptyOrNil ifFalse: [
				stream := FileStream fileNamed: newFileName.
				stream ifNotNil: [ex resume: stream].
			].
		].


]

{ #category : #drawing }
DSCPostscriptCanvasToDisk class >> morphAsPostscript: aMorph rotated: rotateFlag specs: specsOrNil [

	^ self morphAsPostscript: aMorph rotated: rotateFlag offsetBy: self baseOffset specs: specsOrNil

]

{ #category : #drawing }
DSCPostscriptCanvasToDisk >> morphAsPostscript: aMorph rotated: rotateFlag offsetBy: offset [

	^self morphAsPostscript: aMorph rotated: rotateFlag offsetBy: offset specs: nil

]

{ #category : #drawing }
DSCPostscriptCanvasToDisk >> morphAsPostscript: aMorph rotated: rotateFlag offsetBy: offset specs: specsOrNil [ 
	self reset.
	psBounds := offset extent: aMorph bounds extent.
	topLevelMorph := aMorph.
	self writeHeaderRotated: rotateFlag.
	self fullDrawMorph: aMorph.
	^ self close
]
