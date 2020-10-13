"
BufferedCanvas enabled: false.
BufferedCanvas enabled: true.

NebraskaDebug beginStats
NebraskaDebug showStats
NebraskaDebug stopAndShowAll
NebraskaDebug killStats
StringSocket showRatesSeen
StringSocket clearRatesSeen
NebraskaDebug showAndClearStats: #allStats
NebraskaDebug showAndClearStats: #queuedbufferSizes


CanvasEncoder beginStats
CanvasEncoder showStats
CanvasEncoder killStats
NebraskaDebug showStats: #peerBytesSent
NebraskaDebug showStats: #soundReductionTime
NebraskaDebug showStats: #FormEncodeTimes
NebraskaDebug showStats: #SendReceiveStats
NebraskaDebug showStats: #sendDeltas
NebraskaDebug showStats: #bigImage
NebraskaDebug showStats: #sketch
NebraskaDebug showStats: #addToOutBuf:
----
buffered off, painting 125kb/s, dragging 400kb/s
buffered on, painting 100kb/s, dragging 170kb/s
"
Class {
	#name : #NebraskaDebug,
	#superclass : #Object,
	#classVars : [
		'DEBUG',
		'Details'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'as yet unclassified' }
NebraskaDebug class >> at: queueName add: anArray [

	| now |

	DEBUG ifNil: [
		queueName == #sketchZZZ ifFalse: [^self].
		"Details := OrderedCollection new."
		self beginStats.
	].
	(Details notNil and: [Details size < 20]) ifTrue: [
		Details add: thisContext longStack
	].
	now := Time millisecondClockValue.
	DEBUG add: {now},anArray,{queueName}.

]

{ #category : #'as yet unclassified' }
NebraskaDebug class >> beginStats [

	DEBUG := OrderedCollection new
]

{ #category : #'as yet unclassified' }
NebraskaDebug class >> killStats [

	DEBUG := nil.

]

{ #category : #'as yet unclassified' }
NebraskaDebug class >> showAndClearStats: queueName [

	DEBUG ifNil: [^Beeper beep].
	self 
		showStats: queueName 
		from: DEBUG.
	DEBUG := nil.
]

{ #category : #'as yet unclassified' }
NebraskaDebug class >> showStats [

	DEBUG ifNil: [^Beeper beep].
	DEBUG explore.
]

{ #category : #'as yet unclassified' }
NebraskaDebug class >> showStats: queueName [

	DEBUG ifNil: [^Beeper beep].
	self 
		showStats: queueName 
		from: DEBUG.

]

{ #category : #'as yet unclassified' }
NebraskaDebug class >> showStats: queueName from: aCollection [

	| answer prevTime |

	prevTime := nil.
	answer := String streamContents: [ :s | 
		s nextPutAll: (aCollection last first - aCollection first first) asStringWithCommas,' ms';cr;cr.
		aCollection withIndexDo: [ :each :index | | xx currTime | 
			(queueName == #allStats or: [queueName == each last]) ifTrue: [
				currTime := each first.
				xx := currTime printString.
				prevTime ifNil: [prevTime := currTime].
				s nextPutAll: index printString,'.  ',
					(xx allButLast: 3),'.',(xx last: 3),' ',(currTime - prevTime) printString,' '.
				s nextPutAll: each allButFirst printString; cr.
				prevTime := currTime.
			].
		]
	].
	StringHolder new 
		contents: answer;
		openLabel: queueName
]

{ #category : #'as yet unclassified' }
NebraskaDebug class >> stopAndShowAll [

	| prev |

self halt.	"not updated to new format"

	prev := DEBUG.
	DEBUG := nil.
	prev ifNil: [^Beeper beep].
	prev keysAndValuesDo: [ :k :v |
		self showStats: k from: v
	].
]
