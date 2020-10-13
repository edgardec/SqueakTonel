"
Adds to the record of ancestry, other identifying details.
"
Class {
	#name : #MCVersionInfo,
	#superclass : #MCAncestry,
	#instVars : [
		'id',
		'name',
		'message',
		'date',
		'time',
		'author'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #'instance creation' }
MCVersionInfo class >> name: vName id: id message: message date: date time: time author: author ancestors: ancestors [
	^ self 
		name: vName
		id: id
		message: message
		date: date
		time: time
		author: author
		ancestors: ancestors
		stepChildren: #()
]

{ #category : #'instance creation' }
MCVersionInfo class >> name: vName id: id message: message date: date time: time author: author ancestors: ancestors stepChildren: stepChildren [
	^ self new
		initializeWithName: vName
		id: id
		message: message
		date: date
		time: time
		author: author
		ancestors: ancestors
		stepChildren: stepChildren
]

{ #category : #comparing }
MCVersionInfo >> = other [
	^ other species = self species
		and: [other hasID: id]
]

{ #category : #converting }
MCVersionInfo >> asDictionary [
	^ Dictionary new
		at: #name put: name;
		at: #id put: id asString;
		at: #message put: message;
		at: #date put: date;
		at: #time put: time;
		at: #author put: author;
		at: #ancestors put: (self ancestors collect: [:a | a asDictionary]);
		yourself
]

{ #category : #pillaging }
MCVersionInfo >> author [
	^ author
]

{ #category : #'initialize-release' }
MCVersionInfo >> copyWithTrimmedAncestry [
	^ self copy postCopyWithTrimmedAncestry
]

{ #category : #pillaging }
MCVersionInfo >> date [
	^ date
]

{ #category : #accessing }
MCVersionInfo >> dateAndTime [
	^ DateAndTime
		date: date
		time: (time ifNil: [ Time midnight ])
]

{ #category : #private }
MCVersionInfo >> hasID: aUUID [
	^ id = aUUID
]

{ #category : #comparing }
MCVersionInfo >> hash [
	^ id hash
]

{ #category : #pillaging }
MCVersionInfo >> id [
	^ id 
]

{ #category : #'initialize-release' }
MCVersionInfo >> initializeWithName: vName id: aUUID message: aString date: aDate time: aTime author: initials ancestors: aCollection stepChildren: stepCollection [
	name := vName asString asMCVersionName.
	id := aUUID.
	message := aString.
	date := aDate.
	time := aTime.
	author := initials.
	ancestors :=  aCollection.
	stepChildren := stepCollection
]

{ #category : #accessing }
MCVersionInfo >> message [
	^ message ifNil: ['']
]

{ #category : #accessing }
MCVersionInfo >> name [
	^ name ifNil: ['<working copy>']
]

{ #category : #accessing }
MCVersionInfo >> nameWithout: packageName [
	| result |
	result := self name.
	(result beginsWith: packageName , '-') ifTrue: [
		result := result copyFrom: packageName size + 2 to: result size].
	^result
]

{ #category : #accessing }
MCVersionInfo >> packageAndBranchName [
	^ name
		ifNil: [ self name ]
		ifNotNil: [ name asMCVersionName packageAndBranchName ]
]

{ #category : #printing }
MCVersionInfo >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(; nextPutAll: self name; nextPut: $)
	
]

{ #category : #accessing }
MCVersionInfo >> summary [
	^ String streamContents:
		[:s |
		s
			nextPutAll: self summaryHeader; cr; cr;
			nextPutAll: self message.
		]
]

{ #category : #accessing }
MCVersionInfo >> summaryHeader [
	^ String streamContents:
		[:s |
		s
			nextPutAll: 'Name: '; nextPutAll: self name; cr.
		date ifNotNil:
			[s
				nextPutAll: 'Author: '; nextPutAll: author; cr;
				nextPutAll: 'Time: '; nextPutAll:  date asString, ', ', time asString; cr].
		id ifNotNil:
			[s nextPutAll: 'UUID: '; nextPutAll: id asString; cr].
		s
			nextPutAll: 'Ancestors: '; nextPutAll: self ancestorString.
		self stepChildren isEmpty ifFalse:
			[s cr; nextPutAll: 'Backported From: '; nextPutAll: self stepChildrenString].
		]
]

{ #category : #pillaging }
MCVersionInfo >> time [
	^ time
]

{ #category : #accessing }
MCVersionInfo >> timeStamp [
	^ TimeStamp date: date time: (time ifNil: [Time fromString: '00:00'])
]

{ #category : #accessing }
MCVersionInfo >> timeString [
	^ date asString, ', ', time asString
]

{ #category : #accessing }
MCVersionInfo >> versionName [
	^ name
		ifNil: [ self name ]
		ifNotNil: [ name asMCVersionName ]
]

{ #category : #accessing }
MCVersionInfo >> versionNumber [
	^ self versionName versionNumber
]
