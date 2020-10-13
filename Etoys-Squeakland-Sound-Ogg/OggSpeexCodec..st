Class {
	#name : #OggSpeexCodec,
	#superclass : #OggDriver,
	#instVars : [
		'driver'
	],
	#category : #'Etoys-Squeakland-Sound-Ogg'
}

{ #category : #'class initialization' }
OggSpeexCodec class >> fileReaderServicesForFile: fullName suffix: suffix [ 
	"self playFileNamed: 'majorChord.spx'"
	^ suffix = 'spx'
		ifTrue: [self services]
		ifFalse: [#()]
]

{ #category : #'user interface' }
OggSpeexCodec class >> visibleCodecName [
	"Answer a name by which this codec can be known externally."

	^ 'Speex'
]

{ #category : #'initialize-release' }
OggSpeexCodec >> startDecoder [
	^ self
		primitiveOpen: (SqSpeex bitOr: SqOggDecode)
]

{ #category : #'initialize-release' }
OggSpeexCodec >> startEncoder [
	| s |
	s := self
				primitiveOpen: (SqSpeex bitOr: SqOggEncode).
	"now only support 1 channel"
	channels := 1.
	rate := rate
				ifNil: [11025].
	quality := quality
				ifNil: [SpeexDefaultQuality].
	self primitiveSetChannels: s with: channels.
	self primitiveSetRate: s with: rate.
	self primitiveSetQuality: s with: quality.
	^ s
]
