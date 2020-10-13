"
Note: in an effort to remove the progress indicator if a walkback occurs, #withProgressDo: must be sent from the current uiProcess. Hopefully we can relax this restriction in the future. 
"
Class {
	#name : #ComplexProgressIndicator,
	#superclass : #Object,
	#instVars : [
		'formerWorld',
		'targetMorph',
		'estimate',
		'prevData',
		'formerProcess',
		'translucentMorph',
		'userSuppliedMorph',
		'specificHistory',
		'historyCategory',
		'cumulativeStageTime',
		'formerProject',
		'newRatio',
		'stageCompleted',
		'start'
	],
	#classVars : [
		'History'
	],
	#category : #'Morphic-Windows'
}

{ #category : #reports }
ComplexProgressIndicator class >> historyReport [
"
ComplexProgressIndicator historyReport
"
	| answer |
	History ifNil: [^Beeper beep].
	answer := String streamContents: [ :strm |
		(History keys asArray sort: [ :a :b | a asString <= b asString]) do: [ :k |
			| data |
			strm nextPutAll: k printString; cr.
			data := History at: k.
			(data keys asArray sort: [ :a :b | a asString <= b asString]) do: [ :dataKey |
				strm tab; nextPutAll: dataKey printString,'  ',
					(data at: dataKey) asArray printString; cr.
			].
			strm cr.
		].
	].
	StringHolder new
		contents: answer contents;
		openLabel: 'Progress History'
]

{ #category : #'as yet unclassified' }
ComplexProgressIndicator >> addProgressDecoration: extraParam [ 
	| f m |
	targetMorph ifNil: [^self].
	(extraParam isForm) 
		ifTrue: 
			[targetMorph 
				submorphsDo: [:mm | (mm isSketchMorph) ifTrue: [mm delete]].
			f := Form extent: extraParam extent depth: extraParam depth.
			extraParam displayOn: f.
			m := SketchMorph withForm: f.
			m align: m fullBounds leftCenter
				with: targetMorph fullBounds leftCenter + (2 @ 0).
			targetMorph addMorph: m.
			^self].
	(extraParam isString) 
		ifTrue: 
			[targetMorph 
				submorphsDo: [:mm | (mm isKindOf: StringMorph) ifTrue: [mm delete]].
			m := StringMorph contents: extraParam translated.
			m align: m fullBounds bottomCenter + (0 @ 8)
				with: targetMorph bounds bottomCenter.
			targetMorph addMorph: m.
			^self]
]

{ #category : #'as yet unclassified' }
ComplexProgressIndicator >> backgroundWorldDisplay [

	| world |
	self flag: #bob.		"really need a better way to do this"

			"World displayWorldSafely."

	"ugliness to try to track down a possible error"

	world := Project current world.
	[world displayWorld] ifError: [ :a :b |
		| f |
		stageCompleted := 999.
		f := FileDirectory default fileNamed: 'bob.errors'.
		f nextPutAll: a printString,'  ',b printString; cr; cr.
		f nextPutAll: 'worlds equal ',(formerWorld == world) printString; cr; cr.
		f nextPutAll: thisContext longStack; cr; cr.
		f nextPutAll: formerProcess suspendedContext longStack; cr; cr.
		f close. Beeper beep.
	].

]

{ #category : #'as yet unclassified' }
ComplexProgressIndicator >> forkProgressWatcher [

	[
	| currentWorld killTarget |
		currentWorld := Project current world.
		[stageCompleted < 999 and: 
				[formerProject == Project current and: 
				[formerWorld == currentWorld and: 
				[translucentMorph world notNil and:
				[formerProcess suspendedContext notNil and: 
				[Project uiProcess == formerProcess]]]]]] whileTrue: [

			translucentMorph setProperty: #revealTimes toValue: 
					{(Time millisecondClockValue - start max: 1). (estimate * newRatio max: 1)}.
			translucentMorph changed.
			translucentMorph owner addMorphInLayer: translucentMorph.
			(Time millisecondClockValue - WorldState lastCycleTime) abs > 500 ifTrue: [
				self backgroundWorldDisplay
			].
			(Delay forMilliseconds: 100) wait.
		].
		translucentMorph removeProperty: #revealTimes.
		self loadingHistoryAt: 'total' add: (Time millisecondClockValue - start max: 1).
		killTarget := targetMorph ifNotNil: [
			targetMorph valueOfProperty: #deleteOnProgressCompletion
		].
		formerWorld == currentWorld ifTrue: [
			translucentMorph delete.
			killTarget ifNotNil: [killTarget delete].
		] ifFalse: [
			translucentMorph privateDeleteWithAbsolutelyNoSideEffects.
			killTarget ifNotNil: [killTarget privateDeleteWithAbsolutelyNoSideEffects].
		].
	] forkAt: Processor lowIOPriority.
]

{ #category : #'as yet unclassified' }
ComplexProgressIndicator >> historyCategory: aKey [

	History ifNil: [History := Dictionary new].
	specificHistory := History
		at: aKey
		ifAbsentPut: [Dictionary new].
	^specificHistory

]

{ #category : #'as yet unclassified' }
ComplexProgressIndicator >> loadingHistoryAt: aKey add: aNumber [

	(self loadingHistoryDataForKey: aKey) add: aNumber.


]

{ #category : #'as yet unclassified' }
ComplexProgressIndicator >> loadingHistoryDataForKey: anObject [

	| answer |
	answer := specificHistory 
		at: anObject
		ifAbsentPut: [OrderedCollection new].
	answer size > 50 ifTrue: [
		answer := answer copyFrom: 25 to: answer size.
		specificHistory at: anObject put: answer.
	].
	^answer


]

{ #category : #'as yet unclassified' }
ComplexProgressIndicator >> targetMorph: aMorph [

	targetMorph := aMorph
]

{ #category : #'as yet unclassified' }
ComplexProgressIndicator >> withProgressDo: aBlock [

	| safetyFactor totals trialRect delta targetOwner |

	Smalltalk isMorphic ifFalse: [^aBlock value].
	formerProject := Project current.
	formerWorld := formerProject world.
	formerProcess := Processor activeProcess.
	targetMorph
		ifNil: [targetMorph := ProgressTargetRequestNotification signal].
	targetMorph ifNil: [
		trialRect := Rectangle center: Sensor cursorPoint extent: 80@80.
		delta := trialRect amountToTranslateWithin: formerWorld bounds.
		trialRect := trialRect translateBy: delta.
		translucentMorph := TranslucentProgessMorph new
			opaqueBackgroundColor: Color white;
			bounds: trialRect;
			openInWorld: formerWorld.
	] ifNotNil: [
		targetOwner := targetMorph owner.
		translucentMorph := TranslucentProgessMorph new
			setProperty: #morphicLayerNumber toValue: targetMorph morphicLayerNumber - 0.1;
			bounds: targetMorph boundsInWorld;
			openInWorld: targetMorph world.
	].
	stageCompleted := 0.
	safetyFactor := 1.1.	"better to guess high than low"
	translucentMorph setProperty: #progressStageNumber toValue: 1.
	translucentMorph hide.
	targetOwner ifNotNil: [targetOwner hide].
	totals := self loadingHistoryDataForKey: 'total'.
	newRatio := 1.0.
	estimate := totals size < 2 ifTrue: [
		15000		"be a pessimist"
	] ifFalse: [
		(totals sum - totals max) / (totals size - 1 max: 1) * safetyFactor.
	].
	start := Time millisecondClockValue.
	self forkProgressWatcher.

	[
		aBlock 
			on: ProgressInitiationException
			do: [ :ex | 
				ex sendNotificationsTo: [ :min :max :curr |
					"ignore this as it is inaccurate"
				].
			].
	] on: ProgressNotification do: [ :note | | stageCompletedString |
		translucentMorph show.
		targetOwner ifNotNil: [targetOwner show].
		note extraParam ifNotNil:[self addProgressDecoration: note extraParam].
		stageCompletedString := (note messageText findTokens: ' ') first.
		stageCompleted := (stageCompletedString copyUpTo: $:) asNumber.
		cumulativeStageTime := Time millisecondClockValue - start max: 1.
		prevData := self loadingHistoryDataForKey: stageCompletedString.
		prevData isEmpty ifFalse: [
			newRatio := (cumulativeStageTime / (prevData average max: 1)) asFloat.
		].
		self 
			loadingHistoryAt: stageCompletedString 
			add: cumulativeStageTime.
		translucentMorph 
			setProperty: #progressStageNumber 
			toValue: stageCompleted + 1.
		note resume.
	].

	stageCompleted := 999.	"we may or may not get here"


]
