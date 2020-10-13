Class {
	#name : #SoundTest,
	#superclass : #TestCase,
	#category : #'Tests-Sound'
}

{ #category : #tests }
SoundTest >> testStoreSamples [

	| sound fileName arrayBytes fileBytes |
	sound := PluckedSound default.
	fileName := 'tempPluck.wav'.
	
	"Write to file"
	fileBytes := [
		sound storeWAVOnFileNamed: fileName.
		FileStream oldFileNamed: fileName do: [:stream |
			stream binary contents]] ensure: [
				FileDirectory deleteFilePath: fileName].
	
	"Write to array"
	arrayBytes := ByteArray streamContents: [:stream |
		sound storeWAVSamplesOn: stream].
	
	"Compare"
	self assert: fileBytes equals: arrayBytes.
]
