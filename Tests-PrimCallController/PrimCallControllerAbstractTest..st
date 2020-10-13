"
PrimCallController tests.

Tests are here, but this class isAbstract and won't be tested.
Tests are done in the subclasses, which inherit the tests here.

If you want to perform some more very slow tests, change doNotMakeSlowTestsFlag in >>setUp.
"
Class {
	#name : #PrimCallControllerAbstractTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'pcc',
		'doNotMakeSlowTestsFlag'
	],
	#category : #'Tests-PrimCallController'
}

{ #category : #testing }
PrimCallControllerAbstractTest class >> isAbstract [
	^ true
]

{ #category : #helper }
PrimCallControllerAbstractTest >> avoidSlowTest [

	^ doNotMakeSlowTestsFlag and: [pcc class = PCCByCompilation]
]

{ #category : #constants }
PrimCallControllerAbstractTest >> compiledMethodsToExampleModule [
	^ self methodSelectorsToExampleModule
		collect: [:sel | self class >> sel]
]

{ #category : #helper }
PrimCallControllerAbstractTest >> disabledCallRefs [
	^ self disabledCallSelectors
		collect: [:sel | MethodReference class: self class selector: sel]
]

{ #category : #helper }
PrimCallControllerAbstractTest >> enabledCallRefs [
	^ self enabledCallSelectors
		collect: [:sel | MethodReference class: self class selector: sel]
]

{ #category : #constants }
PrimCallControllerAbstractTest >> failedCallRef [
	^ MethodReference class: self class selector: self failedCallSelector
]

{ #category : #constants }
PrimCallControllerAbstractTest >> methodRefsToExampleModule [
	^ self methodSelectorsToExampleModule
		collect: [:sym | MethodReference class: self class selector: sym]
]

{ #category : #constants }
PrimCallControllerAbstractTest >> noExternalCallRef [
	^ MethodReference class: self class selector: self noExternalCallSelector
]

{ #category : #constants }
PrimCallControllerAbstractTest >> numOfCallsExampleModule [
	^ self methodSelectorsToExampleModule size
]

{ #category : #running }
PrimCallControllerAbstractTest >> setUp [
	super setUp.
	pcc := self classToBeTested new.
	"set failed call"
	(self class >> self failedCallSelector) literals first at: 4 put: -1.
	"set it to false for some very slow tests..."
	doNotMakeSlowTestsFlag := true
]

{ #category : #constants }
PrimCallControllerAbstractTest >> singularCallRef [
	^ MethodReference class: self class selector: self singularCallSelector
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testChangeFailedCallFailing [
	pcc preserveStatusOfFailedCalls.
	self
		should: [pcc enableCallIn: self failedCallRef]
		raise: TestResult error.
	self
		should: [pcc disableCallIn: self failedCallRef]
		raise: TestResult error
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testChangeFailedCallSucceedingDisable [
	pcc changeStatusOfFailedCalls.
	pcc disableCallIn: self failedCallRef.
	self
		assert: (pcc existsDisabledCallIn: self failedCallRef).
	"necessary for PCCByCompilation (to make it visible for initialization again)"
	pcc enableCallIn: self failedCallRef
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testChangeFailedCallSucceedingEnable [
	pcc changeStatusOfFailedCalls.
	pcc enableCallIn: self failedCallRef.
	self
		assert: (pcc existsEnabledCallIn: self failedCallRef)
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testDisableCallsIntoModule [
	"wrong module"
	self
		should: [pcc disableCallsIntoModule: 'totallyRandom4711']
		raise: TestResult error.
	"precondition: all enabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"disabling"
	pcc disableCallsIntoModule: self exampleModuleName.
	"now all disabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = 0.
	"not enabled!"
	self
		should: [pcc disableCallsIntoModule: self exampleModuleName]
		raise: TestResult error.
	"enabling"
	self methodRefsToExampleModule
		do: [:ref | pcc enableCallIn: ref].
	"all enabled now"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"not enabled!"
	self
		should: [pcc disableCallsIntoModule: self failModuleName]
		raise: TestResult error.
	pcc changeStatusOfFailedCalls.
	pcc disableCallsIntoModule: self failModuleName.
	self assert: (pcc existsDisabledCallIn: self failedCallRef).
	"postcondition"
	pcc enableCallIn: self failedCallRef

]

{ #category : #tests }
PrimCallControllerAbstractTest >> testDisableCallsIntoModuleForClasses [
	"wrong module"
	self
		should: [pcc disableCallsIntoModule: 'totallyRandom4711' forClasses: {self class}]
		raise: TestResult error.
	"precondition: all enabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"disabling"
	pcc disableCallsIntoModule: self exampleModuleName forClasses: {self class}.
	"now all disabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = 0.
	"not enabled!"
	self
		should: [pcc disableCallsIntoModule: self exampleModuleName forClasses: {self class}]
		raise: TestResult error.
	"enabling"
	self methodRefsToExampleModule
		do: [:ref | pcc enableCallIn: ref].
	"all enabled now"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"not enabled!"
	self
		should: [pcc disableCallsIntoModule: self failModuleName forClasses: {self class}]
		raise: TestResult error.
	pcc changeStatusOfFailedCalls.
	pcc disableCallsIntoModule: self failModuleName forClasses: {self class}.
	self assert: (pcc existsDisabledCallIn: self failedCallRef).
	"postcondition"
	pcc enableCallIn: self failedCallRef

]

{ #category : #tests }
PrimCallControllerAbstractTest >> testEnableCallsIntoModule [
	self avoidSlowTest
		ifTrue: [^ self].
	"wrong module"
	self
		should: [pcc enableCallsIntoModule: 'totallyRandom4711']
		raise: TestResult error.
	"precondition: all enabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"not disabled!"
	self
		should: [pcc enableCallsIntoModule: self exampleModuleName]
		raise: TestResult error.
	"disabling"
	self methodRefsToExampleModule
		do: [:ref | pcc disableCallIn: ref].
	"now all disabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = 0.
	"enabling"
	"now this should work"
	pcc enableCallsIntoModule: self exampleModuleName.
	"all enabled now"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"not disabled!"
	self
		should: [pcc enableCallsIntoModule: self failModuleName]
		raise: TestResult error.
	pcc changeStatusOfFailedCalls.
	pcc enableCallsIntoModule: self failModuleName.
	self assert: (pcc existsEnabledCallIn: self failedCallRef)

]

{ #category : #tests }
PrimCallControllerAbstractTest >> testEnableCallsIntoModuleForClasses [
	"wrong module"
	self
		should: [pcc enableCallsIntoModule: 'totallyRandom4711' forClasses: {self class}]
		raise: TestResult error.
	"precondition: all enabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"not disabled!"
	self
		should: [pcc enableCallsIntoModule: self exampleModuleName forClasses: {self class}]
		raise: TestResult error.
	"disabling"
	self methodRefsToExampleModule
		do: [:ref | pcc disableCallIn: ref].
	"now all disabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = 0.
	"enabling"
	"now this should work"
	pcc enableCallsIntoModule: self exampleModuleName forClasses: {self class}.
	"all enabled now"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"not disabled!"
	self
		should: [pcc enableCallsIntoModule: self failModuleName forClasses: {self class}]
		raise: TestResult error.
	pcc changeStatusOfFailedCalls.
	pcc enableCallsIntoModule: self failModuleName forClasses: {self class}.
	self assert: (pcc existsEnabledCallIn: self failedCallRef)

]

{ #category : #tests }
PrimCallControllerAbstractTest >> testEnableDisableCallIn [
	| refs |
	refs := self methodRefsToExampleModule.
	"wrong call"
	self
		should: [pcc disableCallIn: self wrongCallRef]
		raise: TestResult error.
	"wrong class"
	self
		should: [pcc disableCallIn: self wrongClassRef]
		raise: TestResult error.
	"wrong call"
	self
		should: [pcc enableCallIn: self wrongCallRef]
		raise: TestResult error.
	"wrong class"
	self
		should: [pcc enableCallIn: self wrongClassRef]
		raise: TestResult error.
	"no external call"
	self
		should: [pcc enableCallIn: self noExternalCallRef]
		raise: TestResult error.
	"precondition: all enabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"not disabled!"
	self
		should: [refs
				do: [:ref1 | pcc enableCallIn: ref1]]
		raise: TestResult error.
	"disabling"
	refs
		do: [:ref2 | pcc disableCallIn: ref2].
	"now all disabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = 0.
	"not enabled!"
	self
		should: [refs
				do: [:ref3 | pcc disableCallIn: ref3]]
		raise: TestResult error.
	"enabling"
	"now this should work"
	refs
		do: [:ref4 | pcc enableCallIn: ref4].
	"all enabled now"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"try caches"
	pcc disableEnabled.
	"all disabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = 0.
	pcc enableDisabled.
	"all enabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testEnableDisableCallInCompiledMethod [
	"Note: >>compiledMethodsToExampleModule has to be called frequently,  
	since the CMs are changing with a successful compile!"
	"precondition: all enabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"not disabled!"
	self
		should: [self compiledMethodsToExampleModule
				do: [:cm1 | pcc enableCallInCompiledMethod: cm1]]
		raise: TestResult error.
	"disabling"
	self compiledMethodsToExampleModule
		do: [:cm2 | pcc disableCallInCompiledMethod: cm2].
	"now all disabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = 0.
	"not enabled!"
	self
		should: [self compiledMethodsToExampleModule
				do: [:cm3 | pcc disableCallInCompiledMethod: cm3]]
		raise: TestResult error.
	"enabling"
	"now this should work"
	self compiledMethodsToExampleModule
		do: [:cm4 | pcc enableCallInCompiledMethod: cm4].
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"try caches"
	pcc disableEnabled.
	"all disabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = 0.
	pcc enableDisabled.
	"all enabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testEnableDisableCallInMethodClass [
	| sels |
	sels := self methodSelectorsToExampleModule.
	"wrong call"
	self
		should: [pcc disableCallInMethod: #nonExistingCall class: self class]
		raise: TestResult error.
	"wrong class"
	self
		should: [pcc disableCallInMethod: sels first class: Integer]
		raise: TestResult error.
	"wrong call"
	self
		should: [pcc enableCallInMethod: #nonExistingCall class: self class]
		raise: TestResult error.
	"wrong class"
	self
		should: [pcc enableCallInMethod: sels first class: Integer]
		raise: TestResult error.
	self
		should: [pcc enableCallInMethod: self noExternalCallSelector class: self class]
		raise: TestResult error.
	"precondition: all enabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"not disabled!"
	self
		should: [sels
				do: [:sel1 | pcc enableCallInMethod: sel1 class: self class]]
		raise: TestResult error.
	"disabling"
	sels
		do: [:sel2 | pcc disableCallInMethod: sel2 class: self class].
	"now all disabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = 0.
	"not enabled!"
	self
		should: [sels
				do: [:sel3 | pcc disableCallInMethod: sel3 class: self class]]
		raise: TestResult error.
	"enabling"
	"now this should work"
	sels
		do: [:sel4 | pcc enableCallInMethod: sel4 class: self class].
	"all enabled now"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	"try caches"
	pcc disableEnabled.
	"all disabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = 0.
	pcc enableDisabled.
	"all enabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testExistsCallIn [
	self
		deny: (pcc existsCallIn: self noExternalCallRef).
	self enabledCallRefs , self disabledCallRefs , {self failedCallRef}
		do: [:callRef | self
				assert: (pcc existsCallIn: callRef)]
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testExistsDisabledCallIn [
	self
		deny: (pcc existsDisabledCallIn: self noExternalCallRef).
	self
		deny: (pcc existsDisabledCallIn: self failedCallRef).
	self enabledCallRefs
		do: [:callRef | self
				deny: (pcc existsDisabledCallIn: callRef)].
	self disabledCallRefs
		do: [:disabledRef | self
				assert: (pcc existsDisabledCallIn: disabledRef)]
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testExistsEnabledCallIn [
	self
		deny: (pcc existsEnabledCallIn: self noExternalCallRef).
	self
		deny: (pcc existsEnabledCallIn: self failedCallRef).
	self enabledCallRefs
		do: [:callRef | self
				assert: (pcc existsEnabledCallIn: callRef)].
	self disabledCallRefs
		do: [:disabledRef | self
				deny: (pcc existsEnabledCallIn: disabledRef)]
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testExistsFailedCallIn [
	self
		deny: (pcc existsFailedCallIn: self noExternalCallRef).
	self enabledCallRefs , self disabledCallRefs
		do: [:callRef | self
				deny: (pcc existsFailedCallIn: callRef)].
	self
		assert: (pcc existsFailedCallIn: self failedCallRef)
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithCallAndMethodsWithDisabledCall [
	| methodRefs disabledMethodRefs enabledMethodRefs failedMethodRefs |
	self avoidSlowTest
		ifTrue: [^ self].
	disabledMethodRefs := pcc methodsWithDisabledCall.
	self assert: disabledMethodRefs size > 0.
	enabledMethodRefs := pcc methodsWithEnabledCall.
	self assert: enabledMethodRefs size > 0.
	failedMethodRefs := pcc methodsWithFailedCall.
	self assert: failedMethodRefs size > 0.
	methodRefs := pcc methodsWithCall.
	self assert: methodRefs size = (disabledMethodRefs size + enabledMethodRefs size + failedMethodRefs size)
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithCallIntoModule [
	| methodRefs |
	self avoidSlowTest ifTrue: [^ self].
	"precondition: all enabled"
	pcc disableCallIn: self methodRefsToExampleModule first.
	methodRefs := pcc methodsWithCallIntoModule: self exampleModuleName.
	self assert: methodRefs size = self numOfCallsExampleModule.
	"postcondition"
	pcc enableCallIn: self methodRefsToExampleModule first
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithCallIntoModuleForClass [
	"precondition: all enabled"
	| methodRefs |
	pcc disableCallIn: self methodRefsToExampleModule first.
	methodRefs := pcc methodsWithCallIntoModule: self exampleModuleName forClass: self class.
	self assert: methodRefs size = self numOfCallsExampleModule.
	"postcondition"
	pcc enableCallIn: self methodRefsToExampleModule first.
	methodRefs := pcc methodsWithCallIntoModule: nil forClass: self class.
	self
		assert: (methodRefs size = 2
				and: [| methodCoreStrings | 
					methodCoreStrings := methodRefs
								collect: [:mRef | mRef methodSymbol allButFirst asString].
					(methodCoreStrings includes: 'ExternalCallWithoutModule')
						and: [methodCoreStrings includes: 'DisabledExternalCallWithoutModule']])
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithCallIntoModuleForClasses [
	"precondition: all enabled"
	| methodRefs |
	pcc disableCallIn: self methodRefsToExampleModule first.
	methodRefs := pcc methodsWithCallIntoModule: self exampleModuleName forClasses: {self class}.
	self assert: methodRefs size = self numOfCallsExampleModule.
	"postcondition"
	pcc enableCallIn: self methodRefsToExampleModule first.
	methodRefs := pcc methodsWithCallIntoModule: nil forClasses: {self class}.
	self
		assert: (methodRefs size = 2
				and: [| methodCoreStrings | 
					methodCoreStrings := methodRefs
								collect: [:mRef | mRef methodSymbol allButFirst asString].
					(methodCoreStrings includes: 'ExternalCallWithoutModule')
						and: [methodCoreStrings includes: 'DisabledExternalCallWithoutModule']])
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithCallX [
	| methodRefs |
	self avoidSlowTest
		ifTrue: [^ self].
	methodRefs := pcc methodsWithCall: self singularCallName.
	self assert: methodRefs size = 1
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithCallXIntoModule [
	| methodRefs |
	self avoidSlowTest
		ifTrue: [^ self].
	methodRefs := pcc methodsWithCall: self singularCallName intoModule: self moduleNameWithSingularCallName.
	self assert: methodRefs size = 1.
	methodRefs := pcc methodsWithCall: self singularCallName intoModule: self moduleNameNotWithSingularCallName.
	self assert: methodRefs isEmpty
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithDisabledCallIntoModule [
	| methodRefs |
	self avoidSlowTest ifTrue: [^ self].
	"precondition: all enabled"
	pcc disableCallIn: self methodRefsToExampleModule first.
	methodRefs := pcc methodsWithDisabledCallIntoModule: self exampleModuleName.
	self assert: methodRefs size = 1.
	"postcondition"
	pcc enableCallIn: self methodRefsToExampleModule first
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithDisabledCallIntoModuleForClass [
	"precondition: all enabled"
	| methodRefs |
	self methodRefsToExampleModule
		do: [:ref | pcc disableCallIn: ref].
	methodRefs := pcc methodsWithDisabledCallIntoModule: self exampleModuleName forClass: self class.
	self assert: methodRefs size = self numOfCallsExampleModule.
	"postcondition"
	self methodRefsToExampleModule
		do: [:ref | pcc enableCallIn: ref].
	methodRefs := pcc methodsWithDisabledCallIntoModule: nil forClass: self class.
	self assert: methodRefs size = 1 & (methodRefs first methodSymbol allButFirst = 'DisabledExternalCallWithoutModule')
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithDisabledCallIntoModuleForClasses [
	"precondition: all enabled"
	| methodRefs |
	self methodRefsToExampleModule
		do: [:ref | pcc disableCallIn: ref].
	methodRefs := pcc methodsWithDisabledCallIntoModule: self exampleModuleName forClasses: {self class}.
	self assert: methodRefs size = self numOfCallsExampleModule.
	"postcondition"
	self methodRefsToExampleModule
		do: [:ref | pcc enableCallIn: ref].
	methodRefs := pcc methodsWithDisabledCallIntoModule: nil forClasses: {self class}.
	self assert: methodRefs size = 1 & (methodRefs first methodSymbol allButFirst = 'DisabledExternalCallWithoutModule')
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithDisabledCallX [
	| methodRefs |
	self avoidSlowTest
		ifTrue: [^ self].
	"precondition: all enabled"
	pcc disableCallIn: self singularCallRef.
	methodRefs := pcc methodsWithDisabledCall: self singularCallName.
	self assert: methodRefs size = 1 & (methodRefs first methodSymbol = self singularCallName).
	"postcondition"
	pcc enableCallIn: self singularCallRef
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithDisabledCallXIntoModule [
	"precondition: all enabled"
	| methodRefs |
	self avoidSlowTest
		ifTrue: [^ self].
	"precondition: all enabled"
	pcc disableCallIn: self singularCallRef.
	methodRefs := pcc methodsWithDisabledCall: self singularCallName intoModule: self moduleNameWithSingularCallName.
	self assert: methodRefs size = 1.
	methodRefs := pcc methodsWithDisabledCall: self singularCallName intoModule: self moduleNameNotWithSingularCallName.
	self assert: methodRefs isEmpty.
	"postcondition"
	pcc enableCallIn: self singularCallRef
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithEnabledCall [
	| methodRefs |
	methodRefs := pcc methodsWithEnabledCall.
	self assert: methodRefs size > 0
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithEnabledCallIntoModule [
	| methodRefs |
	methodRefs := pcc methodsWithEnabledCallIntoModule: self exampleModuleName.
	self assert: methodRefs size = self numOfCallsExampleModule
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithEnabledCallIntoModuleForClass [
	"precondition: all enabled"
	| methodRefs |
	methodRefs := pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class.
	self assert: methodRefs size = self numOfCallsExampleModule.
	methodRefs := pcc methodsWithEnabledCallIntoModule: nil forClass: self class.
	self assert: methodRefs size = 1 & (methodRefs first methodSymbol allButFirst = 'ExternalCallWithoutModule')
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithEnabledCallIntoModuleForClasses [
	"precondition: all enabled"
	| methodRefs |
	methodRefs := pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClasses: {self class}.
	self assert: methodRefs size = self numOfCallsExampleModule.
	methodRefs := pcc methodsWithEnabledCallIntoModule: nil forClasses: {self class}.
	self assert: methodRefs size = 1 & (methodRefs first methodSymbol allButFirst = 'ExternalCallWithoutModule')
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithEnabledCallX [
	| methodRefs |
	methodRefs := pcc methodsWithEnabledCall: self singularCallName.
	self assert: methodRefs size = 1 & (methodRefs first methodSymbol = self singularCallName)
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithEnabledCallXIntoModule [
	"precondition: all enabled"
	| methodRefs |
	methodRefs := pcc methodsWithEnabledCall: self singularCallName intoModule: self moduleNameWithSingularCallName.
	self assert: methodRefs size = 1.
	methodRefs := pcc methodsWithEnabledCall: self singularCallName intoModule: self moduleNameNotWithSingularCallName.
	self assert: methodRefs isEmpty
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithFailedCall [
	| methodRefs |
	methodRefs := pcc methodsWithFailedCall.
	self assert: methodRefs size >= 1 & ((methodRefs
				select: [:mRef | mRef methodSymbol = self failedCallSelector]) size = 1)
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithFailedCallForClass [
	| methodRefs |
	methodRefs := pcc methodsWithFailedCallForClass: self class.
	self assert: methodRefs size = 1 & (methodRefs asArray first methodSymbol = self failedCallSelector)
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithFailedCallIntoModule [
	| methodRefs |
	methodRefs := pcc methodsWithFailedCallIntoModule: self failModuleName.
	self assert: methodRefs size = 1 & (methodRefs first methodSymbol = self failedCallSelector)
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testMethodsWithFailedCallIntoModuleForClass [
	| methodRefs |
	methodRefs := pcc methodsWithFailedCallIntoModule: self failModuleName forClass: self class.
	self assert: methodRefs size = 1 & (methodRefs first methodSymbol = self failedCallSelector)
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testSwitchPrimCallOffOn [
	| res |
	pcc disableCallInMethod: self realExternalCallOrPrimitiveFailedSelector class: self class.
	self
		should: [self perform: self realExternalCallOrPrimitiveFailedSelector]
		raise: TestResult error.
	pcc enableCallInMethod: self realExternalCallOrPrimitiveFailedSelector class: self class.
	res := self perform: self realExternalCallOrPrimitiveFailedSelector.
	self assert: res isString
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testSwitchStored [
	| refs |
	"all enabled, precondition"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	refs := self methodRefsToExampleModule.
	"fill cache"
	refs
		do: [:ref | pcc disableCallIn: ref].
	"enable one"
	pcc enableCallIn: refs first.
	self
		assert: (pcc existsEnabledCallIn: refs first).
	self
		assert: (pcc existsDisabledCallIn: refs second).
	"switching"
	pcc switchStored.
	"now the checks go vice versa"
	self
		assert: (pcc existsDisabledCallIn: refs first).
	self
		assert: (pcc existsEnabledCallIn: refs second).
	pcc enableCallIn: refs first.
	self
		assert: (pcc existsEnabledCallIn: refs first)
]

{ #category : #tests }
PrimCallControllerAbstractTest >> testTryCaches [
	| refs |
	"all enabled, precondition"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	refs := self methodRefsToExampleModule.
	"fill cache"
	refs
		do: [:ref | pcc disableCallIn: ref].
	"try caches"
	pcc enableDisabled.
	"all enabled"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule.
	pcc disableEnabled.
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = 0.
	pcc enableDisabled.
	"all enabled, postcondition"
	self assert: (pcc methodsWithEnabledCallIntoModule: self exampleModuleName forClass: self class) size = self numOfCallsExampleModule
]

{ #category : #constants }
PrimCallControllerAbstractTest >> wrongCallRef [
	^ MethodReference class: self class selector: #nonExistingCall
]

{ #category : #constants }
PrimCallControllerAbstractTest >> wrongClassRef [
	^ MethodReference class: Integer selector: self methodSelectorsToExampleModule first
]
