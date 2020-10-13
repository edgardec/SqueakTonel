Class {
	#name : #TopologicalSorter,
	#superclass : #Object,
	#instVars : [
		'collection',
		'orders',
		'edges',
		'result',
		'currentTime',
		'firstGroup',
		'secondGroup',
		'intrinsics',
		'nonIntrinsics'
	],
	#category : #'Etoys-Squeakland-Tweak-Kedama-ParseTreeTransformer'
}

{ #category : #'as yet unclassified' }
TopologicalSorter class >> test1 [
"
	MessageTally spyOn: [10000 timesRepeat: [TopologicalSorter test1]]
"

	| t edges ret first second collection edgeCandidates |
	t := TopologicalSorter new.
	collection := #(1 2 3 4 5).
	edgeCandidates := {
		{#(2 4). #(2 5). #(1 2)}.
		{#(1 2)}.
		{#(1 2). #(2 3). #(2 4)}.
		{#(1 2). #(2 5). #(1 5)}.
		{#(1 2). #(2 5). #(1 5). #(3 5)}.
		{#(1 2). #(2 5). #(1 5). #(3 4)}.
	}.

	t collection: collection shuffled.
	edges := edgeCandidates atRandom.
	t edges: edges.
	ret := t sort.
	edges do: [:edge |
		first := ret indexOf: edge first.	
		second := ret indexOf: edge second.
		self assert: first < second
	].
	ret := ret reverse.
	edges do: [:edge |
		first := ret indexOf: edge first.	
		second := ret indexOf: edge second.
		self assert: first > second
	].
	^ ret reverse.



]

{ #category : #'as yet unclassified' }
TopologicalSorter class >> test2 [
"
	MessageTally spyOn: [10000 timesRepeat: [TopologicalSorter test2]]
"

	| t edges ret first second collection edgeCandidates d |
	t := TopologicalSorter new.
	collection := #(1 2 3 4 5).
	edgeCandidates := {
		{1. #(2). 2. #(4 5)}.
		{1. #(2)}.
		{1. #(2). 2. #(3 4)}.
		{1. #(2 5). 2. #(5)}.
		{1. #(2 5). 2. #(5). 3. #(5)}.
		{1. #(2 5). 2. #(5). 3. #(4)}.
	}.
	edgeCandidates := edgeCandidates collect: [:list |
		d := IdentityDictionary new.
		1 to: list size by: 2 do: [:i | d at: (list at: i) put: (list at: i+1)].
		d.
	].

	MessageTally spyOn: [10000 timesRepeat: [t collection: collection shuffled.
	edges := edgeCandidates atRandom.
	t edges: edges.
	ret := t sort.]].
	edges associationsDo: [:edge |
		first := ret indexOf: edge key.
		edge value do: [:value |
			second := ret indexOf: value.
			self assert: first < second
		].
	].
	ret := ret reverse.
	edges associationsDo: [:edge |
		first := ret indexOf: edge key.	
		edge value do: [:value |
			second := ret indexOf: value.
			self assert: first > second
		].
	].
	^ ret reverse.



]

{ #category : #all }
TopologicalSorter >> collection: aCollection [

	collection := aCollection.
	firstGroup := OrderedCollection new: aCollection size.
	secondGroup := OrderedCollection new: aCollection size.

]

{ #category : #all }
TopologicalSorter >> currentTimeStamp [

	currentTime := currentTime + 1.
	^ currentTime.

]

{ #category : #all }
TopologicalSorter >> edges: collectionOfDictionaries [

	edges := collectionOfDictionaries.
	currentTime := 0.

]

{ #category : #all }
TopologicalSorter >> sort [

	| s |
	collection do: [:e |
		e outTime = 0 ifTrue: [firstGroup add: e] ifFalse: [secondGroup add: e].
		e inTime < 0 ifTrue: [self visit: e]
	].
	s := secondGroup sorted: [:a :b | a outTime > b outTime].
	^ firstGroup asArray, s.


]

{ #category : #all }
TopologicalSorter >> visit: element [

	element inTime: self currentTimeStamp.
	edges at: element ifPresent: [:edgesFromElement |
	edgesFromElement do: [:nextElement |
		(nextElement outTime  < nextElement inTime)
			ifTrue: [self error: 'loop found']
			ifFalse: [(nextElement inTime < 0) ifTrue: [
				self visit: nextElement]]]].
	element outTime: self currentTimeStamp.

]
