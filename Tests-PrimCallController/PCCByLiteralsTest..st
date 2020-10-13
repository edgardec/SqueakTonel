"
PCCByLiterals tests.

Tests are in the superclass and inherited from there.
"
Class {
	#name : #PCCByLiteralsTest,
	#superclass : #PrimCallControllerAbstractTest,
	#category : #'Tests-PrimCallController'
}

{ #category : #testing }
PCCByLiteralsTest class >> isAbstract [
	^ false
]

{ #category : #constants }
PCCByLiteralsTest >> classToBeTested [
	^ PCCByLiterals
]

{ #category : #constants }
PCCByLiteralsTest >> disabledCallSelectors [
	^ #(#lDisabledRealExternalCall #lDisabledRealExternalCallNaked #lDisabledRealExternalCallOrPrimitiveFailed #lDisabledExternalCallWithoutModule )
]

{ #category : #constants }
PCCByLiteralsTest >> enabledCallSelectors [
	^ #(#lRealExternalCall #lRealExternalCallNaked #lRealExternalCallOrPrimitiveFailed #lExternalCallWithoutModule )
]

{ #category : #constants }
PCCByLiteralsTest >> exampleModuleName [
	^ 'LPCCT'
]

{ #category : #constants }
PCCByLiteralsTest >> failModuleName [
	^ 'LFailModule'
]

{ #category : #constants }
PCCByLiteralsTest >> failedCallSelector [
	^ #lFailedCall
]

{ #category : #'test methods' }
PCCByLiteralsTest >> lDisabledExternalCallWithoutModule [
	<primitive: 'primGetModuleName'>
	^ 'Hello World!'
]

{ #category : #'test methods' }
PCCByLiteralsTest >> lDisabledRealExternalCall [
	<primitive: 'primGetModuleName' module:'LargeIntegers'>
	^ 'Hello World!'
]

{ #category : #'test methods' }
PCCByLiteralsTest >> lDisabledRealExternalCallNaked [
	<primitive: 'primGetModuleName' module:'LargeIntegers'>
]

{ #category : #'test methods' }
PCCByLiteralsTest >> lDisabledRealExternalCallOrPrimitiveFailed [
	<primitive: 'primGetModuleName' module:'LargeIntegers'> "primitiveExternalCall" 
	self primitiveFailed
]

{ #category : #'example module' }
PCCByLiteralsTest >> lExternalCall1 [
	<primitive: 'prim1' module: 'LPCCT'>

]

{ #category : #'example module' }
PCCByLiteralsTest >> lExternalCall2 [
		<primitive:'prim2'module:'LPCCT'>
		self primitiveFailed
]

{ #category : #'test methods' }
PCCByLiteralsTest >> lExternalCallWithoutModule [
	<primitive: 'primGetModuleName'> "primitiveExternalCall" 
	^ 'Hello World!'
]

{ #category : #'test methods' }
PCCByLiteralsTest >> lFailedCall [
	<primitive: 'primGetModuleName' module:'LFailModule'>
	^ 'failed call'
]

{ #category : #'test methods' }
PCCByLiteralsTest >> lNoExternalCall [
	^ 'Hello World!'
]

{ #category : #'test methods' }
PCCByLiteralsTest >> lRealExternalCall [
	<primitive: 'primGetModuleName' module:'LargeIntegers'>
	^ 'Hello World!'
]

{ #category : #'test methods' }
PCCByLiteralsTest >> lRealExternalCallNaked [
	<primitive: 'primGetModuleName' module:'LargeIntegers'>
]

{ #category : #'test methods' }
PCCByLiteralsTest >> lRealExternalCallOrPrimitiveFailed [
	<primitive: 'primGetModuleName' module:'LargeIntegers'>
	self primitiveFailed
]

{ #category : #'test methods' }
PCCByLiteralsTest >> lSingularExternalCall [
	<primitive: 'lSingularExternalCall' module:'LOne'>
	^ 'Hello World!'
]

{ #category : #constants }
PCCByLiteralsTest >> methodSelectorsToExampleModule [
	^ #(#lExternalCall1 #lExternalCall2 )
]

{ #category : #constants }
PCCByLiteralsTest >> moduleNameNotWithSingularCallName [
	^ 'LNotOne'
]

{ #category : #constants }
PCCByLiteralsTest >> moduleNameWithSingularCallName [
	^ 'LOne'
]

{ #category : #constants }
PCCByLiteralsTest >> noExternalCallSelector [
	^ #lNoExternalCall
]

{ #category : #constants }
PCCByLiteralsTest >> realExternalCallOrPrimitiveFailedSelector [
	^ #lRealExternalCallOrPrimitiveFailed
]

{ #category : #running }
PCCByLiteralsTest >> setUp [
	super setUp.
	"disable external calls"
	(self class selectors
		select: [:sel | sel beginsWith: 'lDisabled'])
		do: [:sel | (self class >> sel) literals first at: 4 put: -2]
]

{ #category : #constants }
PCCByLiteralsTest >> singularCallName [
	"occurrs exactly once as prim call name in >>lSingularExternalCall"
	^ 'lSingularExternalCall'
]

{ #category : #constants }
PCCByLiteralsTest >> singularCallSelector [
	^ #lSingularExternalCall
]
