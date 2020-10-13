"
Transcripter is a dog-simple scrolling stream with display.  It is intended to operate with no support from MVC or color in a minimal, or headless version of Squeak.  No attention has been paid to appearance or performance.
"
Class {
	#name : #Transcripter,
	#superclass : #ReadWriteStream,
	#instVars : [
		'frame',
		'para'
	],
	#category : #'System-Recovery'
}

{ #category : #utilities }
Transcripter class >> emergencyEvaluator [
	(Transcripter newInFrame: (0@0 corner: 320@200))
		show: 'Type ''revert'' to revert your last method change.
Type ''exit'' to exit the emergency evaluator.';
		readEvalPrint
]

{ #category : #'instance creation' }
Transcripter class >> newInFrame: frame [
"
(Transcripter newInFrame: (0@0 extent: 100@200))
	nextPutAll: 'Hello there'; endEntry;
	cr; print: 355.0/113; endEntry;
	readEvalPrint.
"
	| transcript |
	transcript := self on: (String new: 100).
	transcript initInFrame: frame.
	^ transcript clear
]

{ #category : #'instance creation' }
Transcripter class >> startTranscriptProcess [   "Transcripter startTranscriptProcess"
	| activeProcess |
	Transcript := self newInFrame: Display boundingBox.
	activeProcess := [Transcript readEvalPrint.
					Smalltalk processShutDownList: true; quitPrimitive]
						newProcess
					priority: Processor userSchedulingPriority.
	activeProcess resume.
	Processor terminateActive

]

{ #category : #private }
Transcripter >> black [
	Display depth = 1 ifTrue: [^ Bitmap with: 16rFFFFFFFF "Works without color support"].
	^ Color black
]

{ #category : #accessing }
Transcripter >> clear [
	Display fill: (frame insetBy: -2) fillColor: self black;
			fill: frame fillColor: self white.
	self on: (String new: 100); endEntry
]

{ #category : #'command line' }
Transcripter >> confirm: queryString [ 

	| choice |
	[choice := self request: queryString , '
Please type yes or no followed by return'.
	choice first asUppercase = $Y ifTrue: [^ true].
		choice first asUppercase = $N ifTrue: [^ false]] repeat
]

{ #category : #accessing }
Transcripter >> endEntry [
	| c d cb |
	c := self contents.
	Display extent ~= DisplayScreen actualScreenSize ifTrue:
		["Handle case of user resizing physical window"
		DisplayScreen startUp.
		frame := frame intersect: Display boundingBox.
		^ self clear; show: c].
	Project current displayTranscripter: self.
	d := para compositionRectangle bottom - frame bottom.
	d > 0 ifTrue:
		["Scroll up to keep all contents visible"
		cb := para characterBlockAtPoint: para compositionRectangle topLeft
											+ (0@(d+para lineGrid)).
		self on: (c copyFrom: cb stringIndex to: c size).
		readLimit:= position:= collection size.
		^ self endEntry].

]

{ #category : #initialization }
Transcripter >> initInFrame: rect [
	frame := rect insetBy: 2.  "Leave room for border"
	Project current initializeParagraphForTranscripter: self

]

{ #category : #'command line' }
Transcripter >> readEvalPrint [
	| line okToRevert |
	okToRevert := true.
	[#('quit' 'exit' 'done' ) includes: (line := self request: '>')]
		whileFalse:
		[line = 'revert'
		ifTrue: [okToRevert
			ifTrue: [RecentMessages default revertMostRecent.
					self cr; show: 'reverted: ' , RecentMessages default mostRecent.
					okToRevert := false]
			ifFalse: [self cr; show: 'Only one level of revert currently supported']]
		ifFalse: [self cr; show: ([Compiler evaluate: line] ifError: [:err :ex | err])]]
]

{ #category : #'command line' }
Transcripter >> request: prompt [
	| startPos char contents | 
	self cr; show: prompt.
	startPos := position.
	[[Sensor keyboardPressed] whileFalse.
	(char := Sensor keyboard) = Character cr]
		whileFalse:
		[char = Character backspace
			ifTrue: [readLimit := position := (position - 1 max: startPos)]
			ifFalse: [self nextPut: char].
		self endEntry].
	contents := self contents.
	^ contents copyFrom: startPos + 1 to: contents size
]

{ #category : #accessing }
Transcripter >> show: anObject [
	self nextPutAll: anObject asString; endEntry
]

{ #category : #private }
Transcripter >> white [
	Display depth = 1 ifTrue: [^ Bitmap with: 0 "Works without color support"].
	^ Color white
]
