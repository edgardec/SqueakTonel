Class {
	#name : #BitmapBugz,
	#superclass : #TestCase,
	#category : #'Tests-Bugs'
}

{ #category : #tests }
BitmapBugz >> testBitmapByteAt [
	| bm |
	bm := Bitmap new: 1.
	1 to: 4 do:[:i|
		self should:[bm byteAt: i put: 1000] raise: Error.
	].
]

{ #category : #tests }
BitmapBugz >> testWriteOn [

	| original binary copy |
	original := Bitmap new: 1.
	original byteAt: 1 put: 42.
	binary := ByteArray streamContents: [ :stream |
		original writeOn: stream ].
	copy := Bitmap newFromStream: binary readStream.
	self assert: original = copy
]
