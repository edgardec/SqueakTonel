"
I provide a way to alter the behavior of the old-style progress notifier in String. See examples in:

ProgressInitiationException testWithout.
ProgressInitiationException testWith.

"
Class {
	#name : #ProgressInitiationException,
	#superclass : #Notification,
	#instVars : [
		'workBlock',
		'maxVal',
		'minVal',
		'aPoint',
		'progressTitle'
	],
	#classVars : [
		'PreferredProgressBarPosition'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #signalling }
ProgressInitiationException class >> display: aString at: aPoint from: minVal to: maxVal during: workBlock [ 
	^ self new
		display: aString
		at: (aPoint ifNil: [ self preferredProgressBarPoint ])
		from: minVal
		to: maxVal
		during: workBlock
]

{ #category : #signalling }
ProgressInitiationException class >> display: aString from: minVal to: maxVal during: workBlock [ 
	^ self
		display: aString
		at: nil
		from: minVal
		to: maxVal
		during: workBlock
]

{ #category : #accessing }
ProgressInitiationException class >> preferredProgressBarPoint [
	^ self preferredProgressBarPosition = #cursorPoint
		ifTrue: [ Sensor cursorPoint ]
		ifFalse: [ UIManager default screenBounds perform: self preferredProgressBarPosition ]
]

{ #category : #accessing }
ProgressInitiationException class >> preferredProgressBarPosition [
	^ PreferredProgressBarPosition ifNil: [ #center ]
]

{ #category : #accessing }
ProgressInitiationException class >> preferredProgressBarPosition: aSymbol [ 
	"Specify any of:  #center, #topCenter, #bottomCenter, #leftCenter, #rightCenter, #topLeft, #topRight, #bottomLeft or #bottomRight or #cursorPoint."
	^ PreferredProgressBarPosition
]

{ #category : #'examples and tests' }
ProgressInitiationException class >> testInnermost [

	"test the progress code WITHOUT special handling"

	^'Now here''s some Real Progress'
		displayProgressFrom: 0 
		to: 10
		during: [ :bar |
			1 to: 10 do: [ :x | 
				bar value: x. (Delay forMilliseconds: 500) wait.
				x = 5 ifTrue: [1/0].	"just to make life interesting"
			].
			'done'
		].


]

{ #category : #'examples and tests' }
ProgressInitiationException class >> testWith [

	"test progress code WITH special handling of progress notifications"

	^[ self testWithAdditionalInfo ] 
		on: ProgressInitiationException
		do: [ :ex | 
			ex sendNotificationsTo: [ :min :max :curr |
				Transcript show: min printString,'  ',max printString,'  ',curr printString; cr
			].
		].

]

{ #category : #'examples and tests' }
ProgressInitiationException class >> testWithAdditionalInfo [

	^{'starting'. self testWithout. 'really!'}
]

{ #category : #'examples and tests' }
ProgressInitiationException class >> testWithout [

	"test the progress code WITHOUT special handling"

	^[self testInnermost]
		on: ZeroDivide
		do: [ :ex | ex resume]


]

{ #category : #handling }
ProgressInitiationException >> defaultAction [
	self resume
]

{ #category : #handling }
ProgressInitiationException >> defaultResumeValue [
	^ UIManager default
		displayProgress: progressTitle
		at: aPoint
		from: minVal
		to: maxVal
		during: workBlock
]

{ #category : #'initialize-release' }
ProgressInitiationException >> display: argString at: argPoint from: argMinVal to: argMaxVal during: argWorkBlock [

	progressTitle := argString.
	aPoint := argPoint.
	minVal := argMinVal.
	maxVal := argMaxVal.
	workBlock := argWorkBlock.
	^self signal
]

{ #category : #'initialize-release' }
ProgressInitiationException >> sendNotificationsTo: aNewBlock [

	self resume: (
		workBlock value: [ :barVal |
			aNewBlock value: minVal value: maxVal value: barVal
		]
	)

]
