Class {
	#name : #AmbientEvent,
	#superclass : #AbstractScoreEvent,
	#instVars : [
		'morph',
		'target',
		'selector',
		'arguments'
	],
	#category : #'Sound-Scores'
}

{ #category : #accessing }
AmbientEvent >> morph [ 
	^ morph
]

{ #category : #accessing }
AmbientEvent >> morph: m [
	morph := m
]

{ #category : #'sound generation' }
AmbientEvent >> occurAtTime: ticks inScorePlayer: player atIndex: index inEventTrack: track secsPerTick: secsPerTick [
	(target == nil or: [selector == nil]) ifTrue:
		[morph ifNil: [^ self].
		^ morph encounteredAtTime: ticks inScorePlayer: player atIndex: index
				inEventTrack: track secsPerTick: secsPerTick].
	target perform: selector withArguments: arguments
]

{ #category : #accessing }
AmbientEvent >> target: t selector: s arguments: a [
	target := t.
	selector := s.
	arguments := a.

]
