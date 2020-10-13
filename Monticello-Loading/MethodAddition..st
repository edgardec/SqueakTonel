"
I represent the addition of a method to a class.  I can produce the CompiledMethod, install it, and then notify the system that the method has been added.  This allows Monticello to implement atomic addition.  A loader can compile all classes and methods first and then install all methods only after they have been all compiled, and in a way that executes little code.½
"
Class {
	#name : #MethodAddition,
	#superclass : #Object,
	#instVars : [
		'text',
		'category',
		'changeStamp',
		'requestor',
		'logSource',
		'myClass',
		'methodAndNode',
		'selector',
		'compiledMethod',
		'priorMethodOrNil'
	],
	#category : #'Monticello-Loading'
}

{ #category : #compiling }
MethodAddition >> compile [
    "This method is the how compiling a method used to work.  All these steps were done at once.
     This method should not normally be used, because the whole point of MethodAddition is to let
	you first create a compiled method and then install the method later."
	self createCompiledMethod.
	self installMethod.
	self notifyObservers.
	^selector
]

{ #category : #'initialize-release' }
MethodAddition >> compile: aString classified: aString1 withStamp: aString2 notifying: aRequestor logSource: aBoolean inClass: aClass [

	text := aString.
	category := aString1.
	changeStamp := aString2.
	requestor := aRequestor.
	logSource := aBoolean.
	myClass := aClass
]

{ #category : #compiling }
MethodAddition >> createCompiledMethod [
	| notification |
	[methodAndNode := myClass
		compile: text asString
		environment: Environment current
		notifying: requestor
		trailer: (myClass defaultMethodTrailerIfLogSource: logSource) 
		ifFail: [^nil]]
			on: SyntaxErrorNotification do: [:exc |
				notification := exc.
				exc pass].
	notification ifNotNil: [notification newSource ifNotNil: [:newSource | text := newSource]].
	selector := methodAndNode selector.
	compiledMethod := methodAndNode method.
	self writeSourceToLog.
	priorMethodOrNil := myClass compiledMethodAt: selector ifAbsent: [nil].

]

{ #category : #compiling }
MethodAddition >> installMethod [
	myClass addSelectorSilently: selector withMethod: compiledMethod.

]

{ #category : #compiling }
MethodAddition >> notifyObservers [
	SystemChangeNotifier uniqueInstance 
		doSilently: [myClass organization classify: selector under: category suppressIfDefault: false].
	priorMethodOrNil isNil
		ifTrue: [SystemChangeNotifier uniqueInstance methodAdded: compiledMethod selector: selector inProtocol: category class: myClass requestor: requestor]
		ifFalse: [SystemChangeNotifier uniqueInstance methodChangedFrom: priorMethodOrNil to: compiledMethod selector: selector inClass: myClass requestor: requestor].
	"The following code doesn't seem to do anything."
	myClass instanceSide noteCompilationOf: selector meta: myClass isClassSide.

]

{ #category : #compiling }
MethodAddition >> writeSourceToLog [
	logSource ifTrue: [
		myClass logMethodSource: text forMethodWithNode: methodAndNode 
			inCategory: category withStamp: changeStamp notifying: requestor.
	].

]
