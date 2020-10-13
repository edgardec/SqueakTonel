Class {
	#name : #WeakSetInspectorTest,
	#superclass : #SetInspectorTest,
	#category : #'ToolsTests-Inspector'
}

{ #category : #running }
WeakSetInspectorTest >> createObject [

	| weakSet |
	weakSet := WeakSet withAll: super createObject.
	Smalltalk garbageCollect.
	^ weakSet
]

{ #category : #tests }
WeakSetInspectorTest >> testDebugConstruction [
	"Ignore."
]

{ #category : #tests }
WeakSetInspectorTest >> testSymbolTableM6812 [
	"This test is related to http://bugs.squeak.org/view.php?id=6812. Check whether field selection and garbage collection are somehow interfering."
	
	| getRandomSymbol symbols priorContents currentContents currentIndex |
	self object removeAll.
	
	getRandomSymbol := [ 
		| token |
		token := (1 to: 10) collect: [:ea | ($a to: $z) atRandom] as: String.
		(Symbol lookup: token) ifNil: [token asSymbol] ifNotNil: [nil]].

	symbols := OrderedCollection new.
	10 timesRepeat: [
		getRandomSymbol value ifNotNil: [:symbol | symbols add: symbol]].	

	self object addAll: symbols.
	Smalltalk garbageCollect.
	self assert: symbols size equals: self object size.
	self assert: symbols notEmpty.
	
	1 to: symbols size do: [:round |
		currentIndex := 1.
		symbols removeLast.

		[(currentIndex := currentIndex + 1) <= self inspector fieldList size]
			whileTrue: [
				self inspector selectionIndex: currentIndex.
				self assert: priorContents ~= (currentContents := self inspector contents).
				priorContents := currentContents.

				Smalltalk garbageCollect. "Removes symbol from weak set"
				self simulateStepping. "Removes field from weak-set inspector"]].
	
	self assert: symbols isEmpty.
	self assert: self object isEmpty.
]
