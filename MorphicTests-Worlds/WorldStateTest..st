Class {
	#name : #WorldStateTest,
	#superclass : #ClassTestCase,
	#category : #'MorphicTests-Worlds'
}

{ #category : #tests }
WorldStateTest >> testActiveVariablesObsoletion [
	"Only the code for backwards compatibility may access the bindings for Active(World|Hand|Event)."
	
	#(ActiveWorld ActiveHand ActiveEvent) do: [:literal |
		self
			assert: 1 "Active(World|Hand|Event)Variable class >> #value:during:"
			equals: (self systemNavigation allCallsOnClass: (self environment bindingOf: literal)) size].
]

{ #category : #tests }
WorldStateTest >> testActiveVariablesRenamed [
	"Document the desire to rename Active(World|Hand|Event)Variable to Active(World|Hand|Event) after the Squeak 6.0 release."
	
	#(ActiveWorld ActiveHand ActiveEvent) do: [:className |
		(SystemVersion current majorVersionNumber >= 6
			and: [SystemVersion current minorVersionNumber >= 1])
				ifTrue: [self assert: ((Smalltalk classNamed: className) includesBehavior: DynamicVariable)]
				ifFalse: [self deny: (Smalltalk at: className) isBehavior] ].
]

{ #category : #tests }
WorldStateTest >> testDeferredUIQueueTimeout [
	"Ensure that the World's deferredUIMessage will take no more time than
	specified by WorldState's deferredExecutionTimeLimit"
	| firstWasRun secondWasRun thirdWasRun |
	firstWasRun := secondWasRun := thirdWasRun := false.
	WorldState addDeferredUIMessage:[
		firstWasRun := true.
		(Delay forMilliseconds: WorldState deferredExecutionTimeLimit + 50) wait.
	].
	WorldState addDeferredUIMessage:[
		secondWasRun := true.
	].
	WorldState addDeferredUIMessage:[
		thirdWasRun := true.
	].
	self deny: firstWasRun.
	self deny: secondWasRun.
	self deny: thirdWasRun.
	Project current world doOneCycleNow.
	self assert: firstWasRun.
	self deny: secondWasRun.
	self deny: thirdWasRun.
	Project current world doOneCycleNow.
	self assert: firstWasRun.
	self assert: secondWasRun.
	self assert: thirdWasRun.

]
