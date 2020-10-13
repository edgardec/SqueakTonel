"
A PrimCallController (PCC) serves for switching external prim calls (primitiveExternalCall) on and off: this is an abstract class, instantiate one of the subclasses PCCByLiterals and PCCByCompilation.

External prim calls are used to access internal and external modules (plugins) as shown by
	Smalltalk listLoadedModules.
	Smalltalk listBuiltinModules.
Note: not loaded external modules (since they have not been called so far) are not shown by these methods.

Highlight: dis/en-abling prims by a PCC works for both internal and external modules!


To help you choosing the right subclass, some properties are listed in the following table:

Functionality/Property							|	PCCByLiterals	PCCByCompilation
------------------------------------------------------------------------------------------------------
testing plugins									|		suited			not suited
permanent disabling of external prim calls		|		no				yes
------------------------------------------------------------------------------------------------------
method changes visible in changeset				|		no				yes
enabling survives snapshot/compilation			|		yes				yes
disabling survives snapshot/compilation			|		no				yes
speed disabling									|		fast				medium
speed enabling									|		fast				slow
CompiledMethod pointer valid after en/dis-abling	|		yes				no
									
Important: Be careful with mixing the use of different PCCs! PCCByLiterals does not see prims disabled by PCCByCompilation and vice versa. For playing around you should start with PCCByLiterals; use PCCByCompilation only, if you know what you are doing!

In protocols 'ui controlling', 'ui logging' and 'ui querying' (please look into this class) are the most important user interface methods. Thereafter the methods in 'ui testing' could be of interest.


Useful expressions:

Controlling:
	""Factorial example""
	| pcc tDisabled tEnabled tEnabled2 |
	pcc := PCCByLiterals new logStream: Transcript. ""logStream set here for more info""
	pcc disableCallsIntoModule: 'LargeIntegers'.
	tDisabled := [1000 factorial] timeToRun.
	pcc enableDisabled.
	tEnabled := [1000 factorial] timeToRun.
	tEnabled2 := [1000 factorial] timeToRun.
	{tDisabled. tEnabled. tEnabled2}
Note: You shouldn't switch off module 'LargeIntegers' for a longer time, since this slows down your system.

Querying:
	PCCByLiterals new methodsWithCall.								""all calls""
	PCCByLiterals new methodsWithCall: 'prim1'.						""call in all modules or without module""
	PCCByLiterals new methodsWithCallIntoModule: nil.				""all calls without module""
	PCCByLiterals new methodsWithCallIntoModule: 'LargeIntegers'.	""all calls into module 'LargeIntegers'""
	PCCByLiterals new
		methodsWithCallIntoModule: 'LargeIntegers'
		forClass: Integer.							""all calls into module 'LargeIntegers' in class Integer""
	PCCByLiterals new
		methodsWithCallIntoModule: 'LargeIntegers'
		forClasses: Integer withAllSubclasses.		""all calls into module 'LargeIntegers' in class Integer withAllSubclasses""

	| pcc | (pcc := PCCByLiterals new) methodsWithCall
			collect: [:mRef | {mRef. pcc extractCallModuleNames: mRef}].


Structure:
 treatedMethods				Dictionary of MethodReferences->#disabled/#enabled
								-- contains changed methods and how they are changed last
 logStream					WriteStream -- shows info about changed methods ifNotNil
 changeStatusOfFailedCalls	Boolean -- if status of failed calls should be changed, default is false
"
Class {
	#name : #PrimCallControllerAbstract,
	#superclass : #Object,
	#instVars : [
		'treatedMethods',
		'logStream',
		'changeStatusOfFailedCallsFlag'
	],
	#category : #'Tests-PrimCallController'
}

{ #category : #'private user interface' }
PrimCallControllerAbstract >> blockSelectCallName: callName [

	^ [:mRef | (self extractCallModuleNames: mRef) key = callName]
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> blockSelectFailedCall [
	"Precondition: mRef references compiledCall."
	^ [:mRef | (mRef compiledMethod literals first at: 4)
		= -1]
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> blockSelectModuleName: moduleNameOrNil [

	^ [:mRef | (self extractCallModuleNames: mRef) value = moduleNameOrNil]
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> changeCallCompiledMethod: aCompiledMethod enable: enableFlag [ 
	"Enables disabled or disables enabled external prim call by recompiling 
	method with prim call taken from comment."
	|  methodRef |
	methodRef := aCompiledMethod methodReference.
	enableFlag
		ifTrue: [self enableCallIn: methodRef]
		ifFalse: [self disableCallIn: methodRef]
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> changeCallMethod: selector class: classOrSymbol enable: enableFlag [ 
	"Enables disabled or disables enabled external prim call by recompiling  
	method with prim call taken from comment."
	| methodRef |
	methodRef := MethodReference
				class: (classOrSymbol isSymbol
						ifTrue: [Smalltalk at: classOrSymbol]
						ifFalse: [classOrSymbol])
				selector: selector.
	enableFlag
		ifTrue: [self enableCallIn: methodRef]
		ifFalse: [self disableCallIn: methodRef]
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> changeStatusOfFailedCalls [
	"En/dis-able not only dis/en-abled calls, but also failed ones. Using this 
	feature can hide serious problems."
	changeStatusOfFailedCallsFlag := true
]

{ #category : #accessing }
PrimCallControllerAbstract >> changeStatusOfFailedCallsFlag [
	^changeStatusOfFailedCallsFlag
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> disableCallIn: aMethodRef [ 
	"Disables enabled external prim call."
	(self existsEnabledCallIn: aMethodRef)
		ifFalse: [self changeStatusOfFailedCallsFlag
				ifTrue: [(self existsFailedCallIn: aMethodRef)
						ifFalse: [^ self error: 'no enabled or failed prim call found']]
				ifFalse: [^ self error: 'no enabled prim call found']].
	self privateDisableCallIn: aMethodRef.
	self treatedMethods at: aMethodRef put: #disabled.
	self logStream
		ifNotNil: [self log: 'Call ' , (self extractCallModuleNames: aMethodRef) printString , ' in ' , aMethodRef actualClass name , '>>' , aMethodRef methodSymbol , ' disabled.']
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> disableCallInCompiledMethod: aCompiledMethod [ 
	"Disables external prim call."
	self changeCallCompiledMethod: aCompiledMethod enable: false
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> disableCallInMethod: selector class: classOrSymbol [ 
	"Disables external prim call."
	self
		changeCallMethod: selector
		class: classOrSymbol
		enable: false
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> disableCallsIntoModule: aModule [ 
	"Disables enabled external prim calls in aModule."
	| methods |
	methods := self methodsWithEnabledCallIntoModule: aModule.
	self changeStatusOfFailedCallsFlag
		ifTrue: [methods
				addAll: (self methodsWithFailedCallIntoModule: aModule)].
	methods isEmpty
		ifTrue: [^ self error: 'no enabled '
					, (self changeStatusOfFailedCallsFlag	ifTrue: ['or failed ']	ifFalse: [''])
					, 'prim calls for module ' , aModule , ' found'].
	methods
		do: [:mRef | self disableCallIn: mRef]
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> disableCallsIntoModule: aModule forClasses: classes [ 
	"Disables enabled external prim calls in aModule for classes."
	| methods |
	methods := self methodsWithEnabledCallIntoModule: aModule forClasses: classes.
	self changeStatusOfFailedCallsFlag
		ifTrue: [methods
				addAll: (self methodsWithFailedCallIntoModule: aModule forClasses: classes)].
	methods isEmpty
		ifTrue: [^ self error: 'no enabled '
					, (self changeStatusOfFailedCallsFlag	ifTrue: ['or failed ']	ifFalse: [''])
					, 'prim calls for module ' , aModule , ' in given classes found'].
	methods
		do: [:mRef | self disableCallIn: mRef]
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> disableEnabled [
	"Disables these external prim calls, which are formerly enabled by self."
	self treatedMethods
		keysAndValuesDo: [:mRef :status | status == #enabled
				ifTrue: [self disableCallIn: mRef]]
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> enableCallIn: aMethodRef [ 
	"Enables disabled external prim call."
	(self existsDisabledCallIn: aMethodRef)
		ifTrue: [self privateEnableCallIn: aMethodRef]
		ifFalse: [self changeStatusOfFailedCallsFlag
				ifTrue: [(self existsFailedCallIn: aMethodRef)
						ifTrue: [self privateEnableViaLiteralIn: aMethodRef]
						ifFalse: [^ self error: 'no disabled or failed prim call found']]
				ifFalse: [^ self error: 'no disabled prim call found']].
	self treatedMethods at: aMethodRef put: #enabled.
	self logStream
		ifNotNil: [self log: 'Call ' , (self extractCallModuleNames: aMethodRef) printString , ' in ' , aMethodRef actualClass name , '>>' , aMethodRef methodSymbol , ' enabled.']
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> enableCallInCompiledMethod: aCompiledMethod [ 
	"Enables disabled external prim call."
	self changeCallCompiledMethod: aCompiledMethod enable: true
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> enableCallInMethod: selector class: classOrSymbol [ 
	"Enables disabled external prim call."
	self
		changeCallMethod: selector
		class: classOrSymbol
		enable: true
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> enableCallsIntoModule: aModule [ 
	"Enables disabled external prim calls in aModule."
	| methods |
	methods := self methodsWithDisabledCallIntoModule: aModule.
	self changeStatusOfFailedCallsFlag
		ifTrue: [methods
				addAll: (self methodsWithFailedCallIntoModule: aModule)].
	methods isEmpty
		ifTrue: [^ self error: 'no disabled '
					, (self changeStatusOfFailedCallsFlag	ifTrue: ['or failed ']	ifFalse: [''])
					, 'prim calls for module ' , aModule , ' found'].
	methods
		do: [:mRef | self enableCallIn: mRef]
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> enableCallsIntoModule: aModule forClasses: classes [ 
	"Enables disabled external prim calls in aModule for classes."
	| methods |
	methods := self methodsWithDisabledCallIntoModule: aModule forClasses: classes.
	self changeStatusOfFailedCallsFlag
		ifTrue: [methods
				addAll: (self methodsWithFailedCallIntoModule: aModule forClasses: classes)].
	methods isEmpty
		ifTrue: [^ self error: 'no disabled '
					, (self changeStatusOfFailedCallsFlag	ifTrue: ['or failed ']	ifFalse: [''])
					, 'prim calls for module ' , aModule , ' in given classes found'].
	methods
		do: [:mRef | self enableCallIn: mRef]
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> enableDisabled [
	"Enables these external prim calls, which are formerly disabled by self."
	self treatedMethods
		keysAndValuesDo: [:mRef :status | status == #disabled
				ifTrue: [self enableCallIn: mRef]]
]

{ #category : #'ui testing' }
PrimCallControllerAbstract >> existsCallIn: aMethodRef [

	self subclassResponsibility
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> existsCompiledCallIn: aMethodRef [ 
	"This just means that there is a compiled in external prim call: from the 
	by compiler subclass point of view disabled prim calls not visible by 
	this method are also prim calls."
	^ aMethodRef compiledMethod primitive = 117
]

{ #category : #'ui testing' }
PrimCallControllerAbstract >> existsDisabledCallIn: aMethodRef [ 
	self subclassResponsibility
]

{ #category : #'ui testing' }
PrimCallControllerAbstract >> existsEnabledCallIn: aMethodRef [ 
	^ (self existsCompiledCallIn: aMethodRef)
		and: [(aMethodRef compiledMethod literals first at: 4)
				>= 0]
]

{ #category : #'ui testing' }
PrimCallControllerAbstract >> existsFailedCallIn: aMethodRef [ 
	^ (self existsCompiledCallIn: aMethodRef)
		and: [self blockSelectFailedCall value: aMethodRef]
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> extractCallModuleNames: aMethodRef [
	"Returns prim call and module name as call->module Association."
	self subclassResponsibility
]

{ #category : #private }
PrimCallControllerAbstract >> extractCallModuleNamesFromLiterals: aMethodRef [ 
	| firstLiteral |
	firstLiteral := aMethodRef compiledMethod literals first.
	^ (firstLiteral at: 2)
		-> (firstLiteral at: 1)
]

{ #category : #'initialize-release' }
PrimCallControllerAbstract >> initialize [
	treatedMethods := Dictionary new.
"	logStream := Transcript."
	changeStatusOfFailedCallsFlag := false
]

{ #category : #logging }
PrimCallControllerAbstract >> log: aString [ 
	self logStream
		ifNotNil: [self logStream cr; show: '[' , self className , '] ' , aString]
]

{ #category : #accessing }
PrimCallControllerAbstract >> logStream [
	^logStream
]

{ #category : #'ui logging' }
PrimCallControllerAbstract >> logStream: aStreamOrNil [ 
	"If aStreamOrNil is notNil, there will be shown dis/en-abling prim call 
	info; nil means no logging."
	logStream := aStreamOrNil
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithCall [
	"Returns all methods containing external prim calls."
	self subclassResponsibility
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithCall: primName [
	^ self methodsWithCall: primName enabled: nil
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> methodsWithCall: callName enabled: enabledFlag [ 
	^ (self methodsWithCallEnabled: enabledFlag)
		select: (self blockSelectCallName: callName)
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithCall: primName intoModule: moduleNameOrNil [
	^ self methodsWithCall: primName intoModule: moduleNameOrNil enabled: nil
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> methodsWithCall: callName intoModule: moduleNameOrNil enabled: enabledFlag [ 
	^ ((self methodsWithCallEnabled: enabledFlag)
		select: (self blockSelectCallName: callName))
		select: (self blockSelectModuleName: moduleNameOrNil)
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> methodsWithCallEnabled: enabledFlag [ 
	^ enabledFlag
		ifNil: [self methodsWithCall]
		ifNotNil: [enabledFlag
				ifTrue: [self methodsWithEnabledCall]
				ifFalse: [self methodsWithDisabledCall]]
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> methodsWithCallForClass: class enabled: enabledFlag [ 
	^ class selectors
		collect: [:sel | MethodReference class: class selector: sel]
		thenSelect: (enabledFlag
				ifNil: [[:mRef | self existsCallIn: mRef]]
				ifNotNil: [enabledFlag
						ifTrue: [[:mRef | self existsEnabledCallIn: mRef]]
						ifFalse: [[:mRef | self existsDisabledCallIn: mRef]]])
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> methodsWithCallForClasses: classes enabled: enabledFlag [ 
	| result |
	result := OrderedCollection new.
	classes
		do: [:class | result
				addAll: (self methodsWithCallForClass: class enabled: enabledFlag)].
	^ result
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithCallIntoModule: moduleNameOrNil [
	^ self methodsWithCallIntoModule: moduleNameOrNil enabled: nil
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> methodsWithCallIntoModule: moduleNameOrNil enabled: enabledFlag [ 
	^ (self methodsWithCallEnabled: enabledFlag)
		select: (self blockSelectModuleName: moduleNameOrNil)
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithCallIntoModule: moduleNameOrNil forClass: class [ 
	^ self methodsWithCallIntoModule: moduleNameOrNil forClasses: {class}
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithCallIntoModule: moduleNameOrNil forClasses: classes [ 
	^ self
		methodsWithCallIntoModule: moduleNameOrNil
		forClasses: classes
		enabled: nil
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> methodsWithCallIntoModule: moduleNameOrNil forClasses: classes enabled: enabledFlag [ 
	^ (self methodsWithCallForClasses: classes enabled: enabledFlag)
		select: (self blockSelectModuleName: moduleNameOrNil)
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithCompiledCall [
	"Returns all methods containing compiled in external prim calls.  
	If the by compilation subclass has disabled some, this method does *not*  
	return all methods containing prim calls (use >>methodsWithCall in this 
	case). "
	^ (SystemNavigation new
		allMethodsSelect: [:method | method primitive = 117])
		reject: [:method | method actualClass == ProtoObject]
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithDisabledCall [
	"Returns all methods containing disabled external prim calls."
	self subclassResponsibility
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithDisabledCall: primName [
	^ self methodsWithCall: primName enabled: false
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithDisabledCall: primName intoModule: moduleNameOrNil [
	^ self methodsWithCall: primName intoModule: moduleNameOrNil enabled: false
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithDisabledCallIntoModule: moduleNameOrNil [
	^ self methodsWithCallIntoModule: moduleNameOrNil enabled: false
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithDisabledCallIntoModule: moduleNameOrNil forClass: class [ 
	^ self methodsWithDisabledCallIntoModule: moduleNameOrNil forClasses: {class}
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithDisabledCallIntoModule: moduleNameOrNil forClasses: classes [ 
	^ self
		methodsWithCallIntoModule: moduleNameOrNil
		forClasses: classes
		enabled: false
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithEnabledCall [
	"Returns all methods containing enabled external prim calls."
	^ self methodsWithCompiledCall
		select: [:mRef | (mRef compiledMethod literals first at: 4)
				>= 0]
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithEnabledCall: primName [
	^ self methodsWithCall: primName enabled: true
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithEnabledCall: primName intoModule: moduleNameOrNil [
	^ self methodsWithCall: primName intoModule: moduleNameOrNil enabled: true
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithEnabledCallIntoModule: moduleNameOrNil [
	^ self methodsWithCallIntoModule: moduleNameOrNil enabled: true
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithEnabledCallIntoModule: moduleNameOrNil forClass: class [ 
	^ self methodsWithEnabledCallIntoModule: moduleNameOrNil forClasses: {class}
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithEnabledCallIntoModule: moduleNameOrNil forClasses: classes [ 
	^ self
		methodsWithCallIntoModule: moduleNameOrNil
		forClasses: classes
		enabled: true
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithFailedCall [
	"Returns all methods containing failed external prim calls."
	^ self methodsWithCompiledCall select: self blockSelectFailedCall
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithFailedCallForClass: class [ 
	^ class selectors
		collect: [:sel | MethodReference class: class selector: sel]
		thenSelect: [:mRef | self existsFailedCallIn: mRef]
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithFailedCallForClasses: classes [
	| result |
	result := OrderedCollection new.
	classes
		do: [:class | result
				addAll: (self methodsWithFailedCallForClass: class)].
	^ result
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithFailedCallIntoModule: moduleNameOrNil [ 
	^ self methodsWithFailedCall
		select: (self blockSelectModuleName: moduleNameOrNil)
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithFailedCallIntoModule: moduleNameOrNil forClass: class [ 
	^ self methodsWithFailedCallIntoModule: moduleNameOrNil forClasses: {class}
]

{ #category : #'ui querying' }
PrimCallControllerAbstract >> methodsWithFailedCallIntoModule: moduleNameOrNil forClasses: classes [
	^ (self methodsWithFailedCallForClasses: classes)
		select: (self blockSelectModuleName: moduleNameOrNil)
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> preserveStatusOfFailedCalls [
	"Do not en/dis-able failed calls (default)."
	changeStatusOfFailedCallsFlag := false
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> privateDisableCallIn: aMethodRefWithExternalCall [
	"Disables enabled or failed external prim call."
	self subclassResponsibility
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> privateEnableCallIn: aMethodRefWithExternalCall [
	"Enables disabled external prim call."
	self subclassResponsibility
]

{ #category : #'private user interface' }
PrimCallControllerAbstract >> privateEnableViaLiteralIn: aMethodRef [ 
	"Enables external prim call by filling function ref literal with zero for 
	'non called'."
	aMethodRef compiledMethod literals first at: 4 put: 0.
	Object flushCache
]

{ #category : #'ui controlling' }
PrimCallControllerAbstract >> switchStored [
	"Disables enabled and enables disabled (see corresponding method 
	comments). "
	self treatedMethods
		keysAndValuesDo: [:mRef :status | status == #enabled
				ifTrue: [self disableCallIn: mRef]
				ifFalse: [self enableCallIn: mRef]]
]

{ #category : #accessing }
PrimCallControllerAbstract >> treatedMethods [
	^treatedMethods
]
