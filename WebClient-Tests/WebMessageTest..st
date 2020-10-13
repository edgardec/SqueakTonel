Class {
	#name : #WebMessageTest,
	#superclass : #TestCase,
	#category : #'WebClient-Tests'
}

{ #category : #tests }
WebMessageTest >> testStreamDirectlyFromToSizeProgressWhenSizeIsNotSpecified [

	| message |
	message := WebMessage new.
	{
		ByteArray. #yourself.
		ByteString. #asString
	} groupsDo: [ :bufferClass :byteArrayToBufferClassConverterSelector |
		| maxSize source destination progressData totalRead |
		maxSize := 10000. "Should be greater than the buffer size used by #streamDirectlyFrom:to:size:progress:"
		source := ((ByteArray new: maxSize streamContents: [ :stream |
			1 to: maxSize do: [ :i | stream nextPut: (i bitAnd: 16rFF) ] ]) perform: byteArrayToBufferClassConverterSelector) readStream.
		destination := (bufferClass new: maxSize) writeStream.
		progressData := OrderedCollection new.
		0 to: maxSize do: [ :bytesToStream |
			totalRead := 0.
			source position: maxSize - bytesToStream.
			destination originalContents from: 1 to: destination position put: (bufferClass == ByteArray ifTrue: [ 0 ] ifFalse: [ Character value: 0 ]).
			destination resetToStart.
			progressData reset.
			message
				streamDirectlyFrom: source
				to: destination
				size: nil
				progress: [ :size :bytesRead |
					self assert: nil equals: size description: 'Progress block''s first argument should be the requested size - in this case nil'.
					progressData add: bytesRead ].
			bytesToStream > 0
				ifTrue: [
					self assert: progressData notEmpty description: 'Missing progress data.'.
					self assert: 0 equals: progressData first description: 'First progress data should report 0 size.'.
					self assert: bytesToStream equals: progressData last description: 'Last progress data should be the number of bytes streamed'.
					self assert: progressData isSorted description: 'Progress data should be monotonic' ]
				ifFalse: [
					self assert: (progressData isEmpty or: [ progressData size = 1 and: [ progressData first = 0 ] ]) description: 'Unexpected progress data' ].
			self assert: bytesToStream equals: destination position description: 'All bytes should be streamed'.
			1 to: bytesToStream do: [ :i |
				(destination originalContents at: i) = (source originalContents at: maxSize - bytesToStream + i) ifFalse: [ "This comparison is the same as the next assertion but it's significantly cheaper."
					self assert: (source originalContents at: maxSize - bytesToStream + i) equals: (destination originalContents at: i) description: 'Copied data doesn''t match source.' ] ] ] ]
]

{ #category : #tests }
WebMessageTest >> testStreamDirectlyFromToSizeProgressWhenSizeIsSpecified [
	<timeout: 20>

	| message |
	message := WebMessage new.
	{
		ByteArray. #yourself.
		ByteString. #asString
	} groupsDo: [ :bufferClass :byteArrayToBufferClassConverterSelector |
		| maxSize source destination progressData totalRead |
		maxSize := 10000. "Should be greater than the buffer size used by #streamDirectlyFrom:to:size:progress:"
		source := ((ByteArray new: maxSize streamContents: [ :stream |
			1 to: maxSize do: [ :i | stream nextPut: (i bitAnd: 16rFF) ] ]) perform: byteArrayToBufferClassConverterSelector) readStream.
		destination := (bufferClass new: maxSize) writeStream.
		progressData := OrderedCollection new.
		0 to: maxSize + 1 do: [ :bytesToStream |
			totalRead := 0.
			source reset.
			destination resetToStart.
			destination originalContents from: 1 to: destination position put: (bufferClass == ByteArray ifTrue: [ 0 ] ifFalse: [ Character value: 0 ]).
			progressData reset.
			message
				streamDirectlyFrom: source
				to: destination
				size: bytesToStream
				progress: [ :size :bytesRead |
					self assert: bytesToStream equals: size description: 'Progress block''s first argument should be the requested size'.
					progressData add: bytesRead ].
			bytesToStream > 0
				ifTrue: [
					self assert: 0 equals: progressData first description: 'First progress data should report 0 size.'.
					self assert: (bytesToStream min: maxSize) equals: progressData last description: 'Last progress data should be the minimum of the number of bytes available and the number of bytes requested'.
					self assert: progressData isSorted description: 'Progress data should be monotonic' ]
				ifFalse: [
					self assert: (progressData isEmpty or: [ progressData size = 1 and: [ progressData first = 0 ] ]) ].
			self assert: (bytesToStream min: maxSize) equals: destination position description: 'Last progress data should be the number of bytes read'.
			1 to: destination position do: [ :i |
				(destination originalContents at: i) = (source originalContents at: i) ifFalse: [ "This comparison is the same as the next assertion but it's significantly cheaper."
					self assert: (source originalContents at: maxSize - bytesToStream + i) equals: (destination originalContents at: i) description: 'Copied data doesn''t match source.' ] ] ] ]
]
