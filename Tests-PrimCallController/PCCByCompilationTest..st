"
PCCByCompilation tests.

Tests are in the superclass and inherited from there.
"
Class {
	#name : #PCCByCompilationTest,
	#superclass : #PrimCallControllerAbstractTest,
	#category : #'Tests-PrimCallController'
}

{ #category : #testing }
PCCByCompilationTest class >> isAbstract [
	^ false
]

{ #category : #'test methods' }
PCCByCompilationTest >> cDisabledExternalCallWithoutModule [
	"{prim disabled by PCCByCompilation} <primitive: 'primGetModuleName'>"
	^ 'Hello World!'
]

{ #category : #'test methods' }
PCCByCompilationTest >> cDisabledRealExternalCall [
	"{prim disabled by PCCByCompilation} <primitive: 'primGetModuleName' module:'LargeIntegers'>"
	^ 'Hello World!'
]

{ #category : #'test methods' }
PCCByCompilationTest >> cDisabledRealExternalCallNaked [
	"{prim disabled by PCCByCompilation} <primitive: 'primGetModuleName' module:'LargeIntegers'>"
]

{ #category : #'test methods' }
PCCByCompilationTest >> cDisabledRealExternalCallOrPrimitiveFailed [
	"{prim disabled by PCCByCompilation} <primitive: 'primGetModuleName' module:'LargeIntegers'>"
	self primitiveFailed
]

{ #category : #'example module' }
PCCByCompilationTest >> cExternalCall1 [
	<primitive: 'prim1' module: 'CPCCT'>

]

{ #category : #'example module' }
PCCByCompilationTest >> cExternalCall2 [
		<primitive:'prim2'module:'CPCCT'>
		self primitiveFailed
]

{ #category : #'test methods' }
PCCByCompilationTest >> cExternalCallWithoutModule [
	<primitive: 'primGetModuleName'>
	^ 'Hello World!'
]

{ #category : #'test methods' }
PCCByCompilationTest >> cFailedCall [
	<primitive: 'primGetModuleName' module:'CFailModule'>
	^ 'failed call'
]

{ #category : #'test methods' }
PCCByCompilationTest >> cNoExternalCall [
	^ 'Hello World!'
]

{ #category : #'test methods' }
PCCByCompilationTest >> cRealExternalCall [
	<primitive: 'primGetModuleName' module:'LargeIntegers'>
	^ 'Hello World!'
]

{ #category : #'test methods' }
PCCByCompilationTest >> cRealExternalCallNaked [
	<primitive: 'primGetModuleName' module:'LargeIntegers'>
]

{ #category : #'test methods' }
PCCByCompilationTest >> cRealExternalCallOrPrimitiveFailed [
	<primitive: 'primGetModuleName' module:'LargeIntegers'>
	self primitiveFailed
]

{ #category : #'test methods' }
PCCByCompilationTest >> cSingularExternalCall [
	<primitive: 'cSingularExternalCall' module:'COne'>
	^ 'Hello World!'
]

{ #category : #constants }
PCCByCompilationTest >> classToBeTested [
	^ PCCByCompilation
]

{ #category : #constants }
PCCByCompilationTest >> disabledCallSelectors [
	^ #(#cDisabledRealExternalCall #cDisabledRealExternalCallNaked #cDisabledRealExternalCallOrPrimitiveFailed #cDisabledExternalCallWithoutModule )
]

{ #category : #constants }
PCCByCompilationTest >> enabledCallSelectors [
	^ #(#cRealExternalCall #cRealExternalCallNaked #cRealExternalCallOrPrimitiveFailed #cExternalCallWithoutModule )
]

{ #category : #constants }
PCCByCompilationTest >> exampleModuleName [
	^ 'CPCCT'
]

{ #category : #constants }
PCCByCompilationTest >> failModuleName [
	^ 'CFailModule'
]

{ #category : #constants }
PCCByCompilationTest >> failedCallSelector [
	^ #cFailedCall
]

{ #category : #constants }
PCCByCompilationTest >> methodSelectorsToExampleModule [
	^ #(#cExternalCall1 #cExternalCall2 )
]

{ #category : #constants }
PCCByCompilationTest >> moduleNameNotWithSingularCallName [
	^ 'CNotOne'
]

{ #category : #constants }
PCCByCompilationTest >> moduleNameWithSingularCallName [
	^ 'COne'
]

{ #category : #constants }
PCCByCompilationTest >> noExternalCallSelector [
	^ #cNoExternalCall
]

{ #category : #constants }
PCCByCompilationTest >> realExternalCallOrPrimitiveFailedSelector [
	^ #cRealExternalCallOrPrimitiveFailed
]

{ #category : #constants }
PCCByCompilationTest >> singularCallName [
	"occurrs exactly once as prim call name in >>cSingularExternalCall"
	^ 'cSingularExternalCall'
]

{ #category : #constants }
PCCByCompilationTest >> singularCallSelector [
	^ #cSingularExternalCall
]
