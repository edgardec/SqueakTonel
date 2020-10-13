"
This is an incomplete test suite for storing and reading various word- and short-word subclasses of ArrayedCollection.

It demonstrates some problems with filing in of certain kinds of arrayed objects, including:

ShortPointArray
ShortIntegerArray
ShortRunArray
WordArray
MatrixTransform2x3

In 3.6b-5331, I get 8 passed/6 failed/6 errors (not counting the MatrixTransform2x3 tests, which were added later).

I ran into problems when trying to read back the SqueakLogo flash character morph, after I'd done a 'save morph to disk' from its debug menu.

The words within the ShortPointArrays and ShortRunArrays were reversed.

"
Class {
	#name : #BitmapStreamTests,
	#superclass : #TestCase,
	#instVars : [
		'random',
		'array',
		'stream'
	],
	#category : #'Tests-Bugs'
}

{ #category : #accessing }
BitmapStreamTests class >> testSelectors [
	"The ImageSegment-based Bitmap Test is known to not work on SPUR VMs
	with the prospect of crashing. #expectedFailure does not cut it here,
	don't even try to run them"
	^ super testSelectors copyWithout: #testMatrixTransform2x3WithImageSegment
]

{ #category : #'tests-ShortRunArray' }
BitmapStreamTests >> createSampleShortRunArray [
	^ShortRunArray newFrom: { 0. 1. 1. 2. 2. 2. 3. 3. 3. 3 }
]

{ #category : #private }
BitmapStreamTests >> randomFloat [
	"Answer a random 32-bit float"
	| w |
	random seed: (w := random nextValue).
	^w
]

{ #category : #private }
BitmapStreamTests >> randomShortInt [
	^((random next * 65536) - 32768) truncated
]

{ #category : #private }
BitmapStreamTests >> randomShortPoint [
	^(((random next * 65536) @ (random next * 65536)) - (32768 @ 32768)) truncated
]

{ #category : #private }
BitmapStreamTests >> randomWord [
	"Answer a random 32-bit integer"
	| w |
	random seed: (w := random nextValue).
	^w truncated
]

{ #category : #running }
BitmapStreamTests >> setUp [
	random := Random new.
]

{ #category : #'tests-MatrixTransform2x3' }
BitmapStreamTests >> testMatrixTransform2x3WithImageSegment [
	array := MatrixTransform2x3 new.
	1 to: 6 do: [ :i | array at: i put: self randomFloat ].
	self validateImageSegment
	
]

{ #category : #'tests-MatrixTransform2x3' }
BitmapStreamTests >> testMatrixTransform2x3WithRefStream [
	array := MatrixTransform2x3 new.
	1 to: 6 do: [ :i | array at: i put: self randomFloat ].
	self validateRefStream
	
]

{ #category : #'tests-MatrixTransform2x3' }
BitmapStreamTests >> testMatrixTransform2x3WithRefStreamOnDisk [
	array := MatrixTransform2x3 new.
	1 to: 6 do: [ :i | array at: i put: self randomFloat ].
	self validateRefStreamOnDisk	
]

{ #category : #'tests-MatrixTransform2x3' }
BitmapStreamTests >> testMatrixTransform2x3WithSmartRefStream [
	array := MatrixTransform2x3 new.
	1 to: 6 do: [ :i | array at: i put: self randomFloat ].
	self validateSmartRefStream
	
]

{ #category : #'tests-MatrixTransform2x3' }
BitmapStreamTests >> testMatrixTransform2x3WithSmartRefStreamOnDisk [
	array := MatrixTransform2x3 new.
	1 to: 6 do: [ :i | array at: i put: self randomFloat ].
	self validateSmartRefStreamOnDisk
	
]

{ #category : #'tests-misc' }
BitmapStreamTests >> testOtherClasses [

	#(WordArrayForSegment FloatArray PointArray IntegerArray SoundBuffer String ShortPointArray ShortIntegerArray WordArray Array ByteArray Bitmap ColorArray ) do: [:s | | a |
		a := (Smalltalk at: s) new: 3.
		self assert: a byteSize equals: a basicSize * a bytesPerBasicElement. ]

]

{ #category : #'tests-ShortIntegerArray' }
BitmapStreamTests >> testShortIntegerArrayReadRefStream2 [
	| refStrm |
	refStrm := ReferenceStream on: #[20 6 17 83 104 111 114 116 73 110 116 101 103 101 114 65 114 114 97 121 0 0 0 2 0 0 0 1 0 2 0 3 ] readStream.
	self assert: (ShortIntegerArray with: 0 with: 1 with: 2 with: 3)
		equals: refStrm next
]

{ #category : #'tests-ShortIntegerArray' }
BitmapStreamTests >> testShortIntegerArrayWithImageSegment [
	array := ShortIntegerArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomShortInt ].
	self validateImageSegment
	
]

{ #category : #'tests-ShortIntegerArray' }
BitmapStreamTests >> testShortIntegerArrayWithRefStream [

	array := ShortIntegerArray with: 0 with: 1 with: 2 with: 3.
	self validateRefStream
	
]

{ #category : #'tests-ShortIntegerArray' }
BitmapStreamTests >> testShortIntegerArrayWithRefStream2 [
	array := ShortIntegerArray with: 0 with: 1 with: 2 with: 3.
	self validateRefStream.
	self
		assert: #[20 6 17 83 104 111 114 116 73 110 116 101 103 101 114 65 114 114 97 121 0 0 0 2 0 0 0 1 0 2 0 3]
		equals: stream byteStream contents
	

]

{ #category : #'tests-ShortIntegerArray' }
BitmapStreamTests >> testShortIntegerArrayWithRefStreamOnDisk [
	array := ShortIntegerArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomShortInt ].
	self validateRefStreamOnDisk
	
]

{ #category : #'tests-ShortIntegerArray' }
BitmapStreamTests >> testShortIntegerArrayWithSmartRefStream [
	array := ShortIntegerArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomShortInt ].
	self validateSmartRefStream 
	
]

{ #category : #'tests-ShortIntegerArray' }
BitmapStreamTests >> testShortIntegerArrayWithSmartRefStream2 [
	array := ShortIntegerArray with: 0 with: 1 with: 2 with: 3.
	self validateSmartRefStream.
	self assert: #[0 0 0 2 0 0 0 1 0 2 0 3 33 13 13] equals: (stream contents asByteArray last: 15)
	

]

{ #category : #'tests-ShortIntegerArray' }
BitmapStreamTests >> testShortIntegerArrayWithSmartRefStreamOnDisk [
	array := ShortIntegerArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomShortInt ].
	self validateSmartRefStreamOnDisk
	
]

{ #category : #'tests-ShortPointArray' }
BitmapStreamTests >> testShortPointArrayWithImageSegment [
	array := ShortPointArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomShortPoint ].
	self validateImageSegment 
	
]

{ #category : #'tests-ShortPointArray' }
BitmapStreamTests >> testShortPointArrayWithRefStream [
	array := ShortPointArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomShortPoint ].
	self validateRefStream 
	
]

{ #category : #'tests-ShortPointArray' }
BitmapStreamTests >> testShortPointArrayWithRefStream2 [
	array := ShortPointArray with: 0@1 with: 2@3.
	self validateRefStream.
	self
		assert: #[20 6 15 83 104 111 114 116 80 111 105 110 116 65 114 114 97 121 0 0 0 2 0 0 0 1 0 2 0 3]
		equals: stream byteStream contents
	
]

{ #category : #'tests-ShortPointArray' }
BitmapStreamTests >> testShortPointArrayWithRefStreamOnDisk [
	array := ShortPointArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomShortPoint ].
	self validateRefStreamOnDisk
	
]

{ #category : #'tests-ShortPointArray' }
BitmapStreamTests >> testShortPointArrayWithSmartRefStream [
	array := ShortPointArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomShortPoint ].
	self validateSmartRefStream 
	
]

{ #category : #'tests-ShortPointArray' }
BitmapStreamTests >> testShortPointArrayWithSmartRefStream2 [
	array := ShortPointArray with: 0@1 with: 2@3.
	self validateSmartRefStream.
	self assert: #[0 0 0 2 0 0 0 1 0 2 0 3 33 13 13] equals: (stream contents asByteArray last: 15)
	
]

{ #category : #'tests-ShortPointArray' }
BitmapStreamTests >> testShortPointArrayWithSmartRefStreamOnDisk [
	array := ShortPointArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomShortPoint ].
	self validateSmartRefStreamOnDisk
	
]

{ #category : #'tests-ShortRunArray' }
BitmapStreamTests >> testShortRunArrayWithImageSegment [
	array := self createSampleShortRunArray.
	self validateImageSegment 
	
]

{ #category : #'tests-ShortRunArray' }
BitmapStreamTests >> testShortRunArrayWithRefStream [
	array := self createSampleShortRunArray.
	self validateRefStream 
	
]

{ #category : #'tests-ShortRunArray' }
BitmapStreamTests >> testShortRunArrayWithRefStreamOnDisk [
	array := self createSampleShortRunArray.
	self validateRefStreamOnDisk
	
]

{ #category : #'tests-ShortRunArray' }
BitmapStreamTests >> testShortRunArrayWithSmartRefStream [
	array := self createSampleShortRunArray.
	self validateSmartRefStream 
	
]

{ #category : #'tests-ShortRunArray' }
BitmapStreamTests >> testShortRunArrayWithSmartRefStream2 [
	array := self createSampleShortRunArray.
	self validateSmartRefStream.
	self assert: #[0 0 0 4 0 1 0 0 0 2 0 1 0 3 0 2 0 4 0 3 33 13 13] equals: (stream contents asByteArray last: 23)


]

{ #category : #'tests-ShortRunArray' }
BitmapStreamTests >> testShortRunArrayWithSmartRefStreamOnDisk [
	array := self createSampleShortRunArray.
	self validateSmartRefStreamOnDisk
	
]

{ #category : #'tests-WordArray' }
BitmapStreamTests >> testWordArrayWithImageSegment [
	array := WordArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomWord ].
	self validateImageSegment
	
]

{ #category : #'tests-WordArray' }
BitmapStreamTests >> testWordArrayWithRefStream [
	array := WordArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomWord ].
	self validateRefStream
	
]

{ #category : #'tests-WordArray' }
BitmapStreamTests >> testWordArrayWithRefStreamOnDisk [
	array := WordArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomWord ].
	self validateRefStreamOnDisk
	
]

{ #category : #'tests-WordArray' }
BitmapStreamTests >> testWordArrayWithSmartRefStream [
	array := WordArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomWord ].
	self validateSmartRefStream
	
]

{ #category : #'tests-WordArray' }
BitmapStreamTests >> testWordArrayWithSmartRefStreamOnDisk [
	array := WordArray new: 10.
	1 to: 10 do: [ :i | array at: i put: self randomWord ].
	self validateSmartRefStreamOnDisk
	
]

{ #category : #private }
BitmapStreamTests >> validateImageSegment [
	"array is set up with an array."
	| other filename |
	filename := 'bitmapStreamTest.extSeg'.

	FileDirectory default deleteFileNamed: filename ifAbsent: [ ].

	(ImageSegment copyFromRootsForExport: {array})
         writeForExport: filename.

	other := (FileDirectory default readOnlyFileNamed: filename)
		fileInObjectAndCode.

	self assert: other originalRoots first equals: array.
	
	"clean up disk"
	FileDirectory default deleteFileNamed: filename ifAbsent: [ ]
]

{ #category : #private }
BitmapStreamTests >> validateRefStream [
	"array is set up with an array."
	| other rwstream |
	rwstream := RWBinaryOrTextStream on: (ByteArray new: array basicSize * 6).

	stream := ReferenceStream on: rwstream.
	stream nextPut: array; close.

	rwstream position: 0.
	stream := ReferenceStream on: rwstream.
	other := stream next.
	stream close.

	self assert: other equals: array
]

{ #category : #private }
BitmapStreamTests >> validateRefStreamOnDisk [
	"array is set up with an array."
	| other filename |

	filename := 'bitmapStreamTest.ref'.
	FileDirectory default deleteFileNamed: filename ifAbsent: [ ].

	stream := ReferenceStream fileNamed: filename.
	stream nextPut: array; close.

	stream := ReferenceStream fileNamed: filename.
	other := stream next.
	stream close.

	self assert: other equals: array.
	
	"clean up disk"
	FileDirectory default deleteFileNamed: filename ifAbsent: [ ]
]

{ #category : #private }
BitmapStreamTests >> validateSmartRefStream [
	"array is set up with an array."
	| other |
	stream := RWBinaryOrTextStream on: (ByteArray new: array basicSize * 6).
	stream binary.
	stream fileOutClass: nil andObject: array.
	stream position: 0.
	stream binary.
	other := stream fileInObjectAndCode.
	self assert: other equals: array
]

{ #category : #private }
BitmapStreamTests >> validateSmartRefStreamOnDisk [
	"array is set up with an array."
	| other filename |

	filename := 'bitmapStreamTest.ref'.
	FileDirectory default deleteFileNamed: filename ifAbsent: [ ].

	stream := FileDirectory default fileNamed: filename.
	stream fileOutClass: nil andObject: array.
	stream close.

	stream := FileDirectory default fileNamed: filename.
	other := stream fileInObjectAndCode.
	stream close.

	self assert: other equals: array.
	
	"clean up disk"
	FileDirectory default deleteFileNamed: filename ifAbsent: [ ]
]
