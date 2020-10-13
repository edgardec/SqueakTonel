Class {
	#name : #PostscriptEncoderToDisk,
	#superclass : #PostscriptEncoder,
	#category : #'MorphicExtras-Postscript Canvases'
}

{ #category : #creation }
PostscriptEncoderToDisk class >> stream [

	^self new initWithTarget: PickAFileToWriteNotification signal

]
