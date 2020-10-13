"
Verify reference stream serialization for DateAndTime and Date. Tests are written in a Cronology-Classic image and should pass in a Chronology-UTC image.
"
Class {
	#name : #DateAndTimeReferenceStreamTest,
	#superclass : #TestCase,
	#category : #'Chronology-Tests'
}

{ #category : #testing }
DateAndTimeReferenceStreamTest >> testArrayOfDateAndTimeToBytes [

	| a bytes expectedBytes |
	a := Array
		with: '2018-12-08T09:35:10.913743-05:00' asDateAndTime
		with: '2018-12-08T14:16:16.931528-05:00' asDateAndTime
		with: #endMarker.
	expectedBytes :=  #[8 0 0 0 3 9 0 0 0 5 6 11 68 97 116 101 65 110 100 84 105 109 101 4 0 0 134 206 9 0 0 0 3 6 8 68 117 114 97 116 105 111 110 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 54 118 156 152 16 5 0 10 4 0 0 200 176 16 3 0 33 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 55 133 253 64 6 9 101 110 100 77 97 114 107 101 114].
	bytes := (ReferenceStream on: ByteArray new writeStream)
		nextPut: a;
		yourself;
		contents.
	self assert: expectedBytes equals: bytes
		description: 'serialized bytes should match expected bytes'.



]

{ #category : #testing }
DateAndTimeReferenceStreamTest >> testArrayWithDateToBytes [

	| date a bytes expectedBytes |
	date := Date
		starting: '2018-12-08T09:35:10.913743-05:00' asDateAndTime
		duration: 1 day + 13 seconds.
	a := Array
		with: '2018-12-08T09:35:10.913743-05:00' asDateAndTime
		with: date
		with: '2018-12-08T14:16:16.931528-05:00' asDateAndTime
		with: #endMarker.
	expectedBytes :=  #[8 0 0 0 4 9 0 0 0 5 6 11 68 97 116 101 65 110 100 84 105 109 101 4 0 0 134 206 9 0 0 0 3 6 8 68 117 114 97 116 105 111 110 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 54 118 156 152 9 0 0 0 3 6 4 68 97 116 101 16 5 0 10 4 0 0 134 206 16 3 0 33 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 54 118 156 152 16 3 0 33 4 0 0 0 0 4 0 1 81 141 16 5 0 10 4 0 0 200 176 16 3 0 33 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 55 133 253 64 6 9 101 110 100 77 97 114 107 101 114].
	bytes := (ReferenceStream on: ByteArray new writeStream)
		nextPut: a;
		yourself;
		contents.
	self assert: expectedBytes equals: bytes
		description: 'serialized bytes should match expected bytes'.



]

{ #category : #testing }
DateAndTimeReferenceStreamTest >> testBytesToArrayOfDateAndTime [

	| bytes expected materializedArray |
	expected := Array
		with: '2018-12-08T09:35:10.913743-05:00' asDateAndTime
		with: '2018-12-08T14:16:16.931528-05:00' asDateAndTime
		with: #endMarker.
.
	bytes :=   #[8 0 0 0 3 9 0 0 0 5 6 11 68 97 116 101 65 110 100 84 105 109 101 4 0 0 134 206 9 0 0 0 3 6 8 68 117 114 97 116 105 111 110 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 54 118 156 152 16 5 0 10 4 0 0 200 176 10 0 0 0 28 4 0 37 131 93 4 55 133 253 64 6 9 101 110 100 77 97 114 107 101 114].
	materializedArray  := (ReferenceStream on: bytes readStream) next.
	self assert: expected equals: materializedArray
		description: 'materialized from bytes should match expected array objects'.



]

{ #category : #testing }
DateAndTimeReferenceStreamTest >> testBytesToArrayWithfDate [

	| date bytes expected materializedArray |
	date := Date
		starting: '2018-12-08T09:35:10.913743-05:00' asDateAndTime
		duration: 1 day + 13 seconds.
	expected := Array
		with: '2018-12-08T09:35:10.913743-05:00' asDateAndTime
		with: date
		with: '2018-12-08T14:16:16.931528-05:00' asDateAndTime
		with: #endMarker.
	bytes :=   #[8 0 0 0 4 9 0 0 0 5 6 11 68 97 116 101 65 110 100 84 105 109 101 4 0 0 134 206 9 0 0 0 3 6 8 68 117 114 97 116 105 111 110 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 54 118 156 152 9 0 0 0 3 6 4 68 97 116 101 16 5 0 10 4 0 0 134 206 16 3 0 33 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 54 118 156 152 16 3 0 33 4 0 0 0 0 4 0 1 81 141 16 5 0 10 4 0 0 200 176 16 3 0 33 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 55 133 253 64 6 9 101 110 100 77 97 114 107 101 114].
	materializedArray  := (ReferenceStream on: bytes readStream) next.
	self assert: expected equals: materializedArray
		description: 'materialized from bytes should match expected array objects'.



]

{ #category : #testing }
DateAndTimeReferenceStreamTest >> testBytesToDate [

	| bytes expected materializedDate |
	expected := Date
		starting: '2018-12-08T09:35:10.913743-05:00' asDateAndTime
		duration: 1 day + 13 seconds.
	bytes :=  #[9 0 0 0 3 6 4 68 97 116 101 9 0 0 0 5 6 11 68 97 116 101 65 110 100 84 105 109 101 4 0 0 134 206 9 0 0 0 3 6 8 68 117 114 97 116 105 111 110 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 54 118 156 152 16 3 0 39 4 0 0 0 0 4 0 1 81 141].
	materializedDate  := (ReferenceStream on: bytes readStream) next.
	self assert: expected equals: materializedDate
		description: 'materialized from bytes should match expected DateAndTime'.



]

{ #category : #testing }
DateAndTimeReferenceStreamTest >> testBytesToDateAndTime [

	| bytes expected materializedDateAndTime |
	expected := '2018-12-08T09:35:10.913743-05:00' asDateAndTime.
	bytes :=  #[9 0 0 0 5 6 11 68 97 116 101 65 110 100 84 105 109 101 4 0 0 134 206 9 0 0 0 3 6 8 68 117 114 97 116 105 111 110 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 54 118 156 152].
	materializedDateAndTime  := (ReferenceStream on: bytes readStream) next.
	self assert: expected equals: materializedDateAndTime
		description: 'materialized from bytes should match expected DateAndTime'.



]

{ #category : #testing }
DateAndTimeReferenceStreamTest >> testDateAndTimeToBytes [

	| dt bytes expectedBytes |
	dt := '2018-12-08T09:35:10.913743-05:00' asDateAndTime.
	expectedBytes :=  #[9 0 0 0 5 6 11 68 97 116 101 65 110 100 84 105 109 101 4 0 0 134 206 9 0 0 0 3 6 8 68 117 114 97 116 105 111 110 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 54 118 156 152].
	bytes := (ReferenceStream on: ByteArray new writeStream)
		nextPut: dt;
		yourself;
		contents.
	self assert: expectedBytes equals: bytes
		description: 'serialized bytes should match expected bytes'.



]

{ #category : #testing }
DateAndTimeReferenceStreamTest >> testDateToBytes [

	| date bytes expectedBytes |
	date := Date
		starting: '2018-12-08T09:35:10.913743-05:00' asDateAndTime
		duration: 1 day + 13 seconds.
	expectedBytes :=  #[9 0 0 0 3 6 4 68 97 116 101 9 0 0 0 5 6 11 68 97 116 101 65 110 100 84 105 109 101 4 0 0 134 206 9 0 0 0 3 6 8 68 117 114 97 116 105 111 110 4 0 0 0 0 4 255 255 185 176 4 0 37 131 93 4 54 118 156 152 16 3 0 39 4 0 0 0 0 4 0 1 81 141].
	bytes := (ReferenceStream on: ByteArray new writeStream)
		nextPut: date;
		yourself;
		contents.
	self assert: expectedBytes equals: bytes
		description: 'serialized bytes should match expected bytes'.



]

{ #category : #testing }
DateAndTimeReferenceStreamTest >> testSeriailizeAndDeserializeArrayOfDateAndTime [

	| date a bytes newArray |
	date := Date
		starting: '2018-12-08T09:35:10.913743-05:00' asDateAndTime
		duration: 1 day + 13 seconds.
	a := Array
		with: '2018-12-08T09:35:10.913743-05:00' asDateAndTime
		with: date
		with: '2018-12-08T14:16:16.931528-05:00' asDateAndTime
		with: #endMarker.
	bytes := (ReferenceStream on: ByteArray new writeStream)
		nextPut: a;
		yourself;
		contents.
	newArray := (ReferenceStream on: bytes readStream) next.
	self assert: a equals: newArray.



]
