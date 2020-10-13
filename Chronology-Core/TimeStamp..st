"
This represents a duration of 0 length that marks a particular point in time.
"
Class {
	#name : #TimeStamp,
	#superclass : #DateAndTime,
	#category : #'Chronology-Core'
}

{ #category : #'squeak protocol' }
TimeStamp class >> current [

	^self now
]

{ #category : #'squeak protocol' }
TimeStamp >> asDateAndTime [
	"Answer the receiver as an instance of DateAndTime."

	^ DateAndTime utcMicroseconds: utcMicroseconds offset: localOffsetSeconds
]

{ #category : #'squeak protocol' }
TimeStamp >> asTimeStamp [
	"Answer the receiver as an instance of TimeStamp."

	^ self
]

{ #category : #'squeak protocol' }
TimeStamp >> date [
	"Answer the date of the receiver."

	^ self asDate
]

{ #category : #'squeak protocol' }
TimeStamp >> dateAndTime [
	"Answer a two element Array containing the receiver's date and time."

	^ Array with: self date with: self time
]

{ #category : #'squeak protocol' }
TimeStamp >> minusDays: anInteger [
	"Answer a TimeStamp which is anInteger days before the receiver."

	^ self - (anInteger days)
]

{ #category : #'squeak protocol' }
TimeStamp >> minusSeconds: anInteger [
	"Answer a TimeStamp which is anInteger number of seconds before the receiver."

	^ self - (anInteger seconds)
]

{ #category : #'squeak protocol' }
TimeStamp >> plusDays: anInteger [
	"Answer a TimeStamp which is anInteger days after the receiver."

	^ self + (anInteger days)
]

{ #category : #'squeak protocol' }
TimeStamp >> plusSeconds: anInteger [
	"Answer a TimeStamp which is anInteger number of seconds after the receiver."

	^ self + (anInteger seconds)
]

{ #category : #'squeak protocol' }
TimeStamp >> printOn: aStream [ 
	"Print receiver's date and time on aStream."

	aStream 
		nextPutAll: self date printString;
		space;
		nextPutAll: self time printString.
]

{ #category : #'squeak protocol' }
TimeStamp >> storeOn: aStream [ 

	aStream 
		print: self printString;
		nextPutAll: ' asTimeStamp'
]

{ #category : #'squeak protocol' }
TimeStamp >> time [
	"Answer the time of the receiver."

	^ self asTime
]
