"
An event representing the playing of a media object such as a sound or a movie.
"
Class {
	#name : #MediaPlayEvent,
	#superclass : #MorphicUnknownEvent,
	#category : #'Etoys-Squeakland-Morphic-Mentoring'
}

{ #category : #accessing }
MediaPlayEvent >> duration [
	"Answer the duration of the event, in seconds."

	^ argument ifNil: [0] ifNotNil: [argument duration]
]

{ #category : #accessing }
MediaPlayEvent >> durationInMilliseconds [
	"Answer the duration of the event in milliseconds."

	^ argument ifNil: [0] ifNotNil: [argument durationInMilliseconds]
]

{ #category : #accessing }
MediaPlayEvent >> endTime [
	"Answer the end time of the receiver."

	^ argument ifNil: [timeStamp] ifNotNil: [timeStamp + argument duration]
]

{ #category : #accessing }
MediaPlayEvent >> play [
	"In  isolation, play the media event if possible."

	argument play


]
