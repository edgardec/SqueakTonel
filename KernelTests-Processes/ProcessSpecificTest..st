"
A ProcessSpecificTest is a test case for process local and dynamic variables.

"
Class {
	#name : #ProcessSpecificTest,
	#superclass : #TestCase,
	#category : #'KernelTests-Processes'
}

{ #category : #private }
ProcessSpecificTest >> checkDynamic: value [

	self assert: value equals: TestDynamicVariable value.
]

{ #category : #private }
ProcessSpecificTest >> checkLocal: value [

	self assert: value equals: TestLocalVariable value.
]

{ #category : #running }
ProcessSpecificTest >> tearDown [
	"Make sure we don't pollute the running process' environment with the test variables"

	{ TestLocalVariable. TestDynamicVariable } do: [ :each |
		Processor activeProcess environmentRemoveKey: each ifAbsent: [] ].

	TestDynamicVariable default: nil.
]

{ #category : #tests }
ProcessSpecificTest >> testAssignmentToLocalVariableReturnsTheValue [

	self assert: 1 equals: (TestLocalVariable value: 1)
]

{ #category : #tests }
ProcessSpecificTest >> testDynamicVariable [

	| s1 s2 p1stopped p2stopped |
	s1 := Semaphore new.
	s2 := Semaphore new.
	p1stopped := p2stopped := false.
	[
		TestDynamicVariable value: 1 during:[
			self checkDynamic: 1.
			(Delay forMilliseconds: 30) wait.
			self checkDynamic: 1.
			TestDynamicVariable value: 3 during:[
				(Delay forMilliseconds: 30) wait.
				self checkDynamic: 3
			].
			self checkDynamic: 1.
		].
		self checkDynamic: nil.
		p1stopped := true.
		s1 signal.
	] fork.

	[
		TestDynamicVariable value: 2 during:[
			self checkDynamic: 2.
			(Delay forMilliseconds: 30) wait.
			self checkDynamic: 2.
		].
		self checkDynamic: nil.
		p2stopped := true.
		s2 signal.
	] fork.

	"Set a maximum wait timeout so that the test case will complete 
	 even if the processes fail to signal us."
	s1 waitTimeoutSeconds: 2.
	s2 waitTimeoutSeconds: 2.
	self assert: p1stopped.
	self assert: p2stopped.
]

{ #category : #tests }
ProcessSpecificTest >> testDynamicVariableDefault [

	"Just double-check our fixture."
	TestDynamicVariable default: #default.
	self assert: #default equals: TestDynamicVariable default.

	"Now check for default lookup out of any dynamic scope."
	self checkDynamic: #default..

	"Ignore default value by setting dynamic scope."
	TestDynamicVariable value: #dynamic during: [
		self checkDynamic: #dynamic].

	"Out of that scope, we should fall back to the default again."
	self checkDynamic: #default.

	"...even if that default value changes."
	TestDynamicVariable default: #anotherDefault.
	self checkDynamic: #anotherDefault.

]

{ #category : #tests }
ProcessSpecificTest >> testLocalVariable [

	| s1 s2 p1stopped p2stopped |
	s1 := Semaphore new.
	s2 := Semaphore new.
	p1stopped := p2stopped := false.
	[
		self checkLocal: 0.
		TestLocalVariable value: 1.
		self checkLocal: 1.
		(Delay forMilliseconds: 30) wait.
		self checkLocal: 1.
		TestLocalVariable value: 2.
		self checkLocal: 2.
		p1stopped := true.
		s1 signal.
	] fork.

	[
		(Delay forMilliseconds: 30) wait.
		self checkLocal: 0.
		TestLocalVariable value: 3.
		self checkLocal: 3.
		(Delay forMilliseconds: 30) wait.
		self checkLocal: 3.
		TestLocalVariable value: 4.
		self checkLocal: 4.
		p2stopped := true.
		s2 signal.
	] fork.

	"Set a maximum wait timeout so that the test case will complete 
	 even if the processes fail to signal us."
	s1 waitTimeoutMSecs: 5000.
	s2 waitTimeoutMSecs: 5000.
	self assert: p1stopped.
	self assert: p2stopped.

]
