"
This class implements unit tests to verify that when the system changes, notification messages are sent around correctly.

Therefore the test messages make a system change, after registering to receive an event after the change occured. In this event (sent immediately after the change), the actual assertions take place.

Note that the system changes are *really* made to the system, but in a change set that is created in the setUp method, while the previous one is restored in the tearDown method.
"
Class {
	#name : #ChangeHooksTest,
	#superclass : #SystemChangeTestRoot,
	#instVars : [
		'previousChangeSet',
		'testsChangeSet',
		'capturedEvents',
		'generatedTestClass',
		'generatedTestClassX',
		'generatedTestClassC2',
		'createdMethodName',
		'createdMethod',
		'doItExpression'
	],
	#category : #'SystemChangeNotification-Tests'
}

{ #category : #Private }
ChangeHooksTest >> addSingleEvent: anEvent [

	capturedEvents isEmpty ifFalse: [self fail].
	capturedEvents add: anEvent
]

{ #category : #'Private-Generation' }
ChangeHooksTest >> categoryForTestName [

	^ self class name select: [:c | c isUppercase ]
]

{ #category : #'Private-Generation' }
ChangeHooksTest >> categoryForTestName1 [

	^ self categoryForTestName , 1
]

{ #category : #'Private-Generation' }
ChangeHooksTest >> categoryForTestName2 [

	^ self categoryForTestName , 2
]

{ #category : #Private }
ChangeHooksTest >> checkEvent: anEvent kind: changeKind item: item itemKind: itemKind [ 

	self assert: (anEvent perform: ('is' , changeKind) asSymbol).
	self assert: anEvent item = item.
	self assert: anEvent itemKind = itemKind
]

{ #category : #Private }
ChangeHooksTest >> checkForOnlySingleEvent [

	self assert: capturedEvents size = 1
]

{ #category : #'Events-Classes' }
ChangeHooksTest >> classCommentedEvent: event [ 

	self addSingleEvent: event.
	self assert: generatedTestClass comment = self commentStringForTesting.
	self 
		checkEvent: event
		kind: #Commented
		item: generatedTestClass
		itemKind: AbstractEvent classKind
]

{ #category : #'Events-Classes' }
ChangeHooksTest >> classCreationEvent: event [ 

	| classCreated |
	self addSingleEvent: event.
	classCreated := Smalltalk classNamed: self newlyCreatedClassName.
	self assert: classCreated notNil.
	self 
		assert: ((Smalltalk organization 
				listAtCategoryNamed: self categoryForTestName1) 
					includes: self newlyCreatedClassName).
	self 
		checkEvent: event
		kind: #Added
		item: classCreated
		itemKind: AbstractEvent classKind
]

{ #category : #'Events-Classes' }
ChangeHooksTest >> classRecategorizedEvent: event [ 

	self addSingleEvent: event.
	self 
		checkEvent: event
		kind: #Recategorized
		item: generatedTestClass
		itemKind: AbstractEvent classKind.
	self assert: event oldCategory = self categoryForTestName1
]

{ #category : #'Events-Classes' }
ChangeHooksTest >> classRedefinitionEvent: event [ 
	
	self addSingleEvent: event.
	self 
		checkEvent: event
		kind: #Modified
		item: generatedTestClass
		itemKind: AbstractEvent classKind.
]

{ #category : #'Events-Classes' }
ChangeHooksTest >> classRemovalEvent: event [ 
	"This event used to be sent efter the class was removed.
	This was changed, and therefore this test is useless currently."

	self addSingleEvent: event.
	self assert: (Smalltalk classNamed: self generatedTestClassName) isNil.
	self 
		checkEvent: event
		kind: #Removed
		item: self generatedTestClassName
		itemKind: AbstractEvent classKind
]

{ #category : #'Events-Classes' }
ChangeHooksTest >> classRenameEvent: event [ 

	| renamedClass |
	self addSingleEvent: event.
	renamedClass := Smalltalk classNamed: self renamedTestClassName.
	self assert: renamedClass notNil.
	self assert: (Smalltalk classNamed: self generatedTestClassName) isNil.
	self 
		checkEvent: event
		kind: #Renamed
		item: renamedClass
		itemKind: AbstractEvent classKind.
	self assert: event oldName = self generatedTestClassName
]

{ #category : #'Events-Classes' }
ChangeHooksTest >> classSuperChangedEvent: event [ 

	self addSingleEvent: event.
	self 
		checkEvent: event
		kind: #Modified
		item: generatedTestClass
		itemKind: AbstractEvent classKind.
	self assert: generatedTestClass superclass = Model
]

{ #category : #Private }
ChangeHooksTest >> commentStringForTesting [

	^'Added this comment as part of the unit test in SystemChangeTest>>testClassCommentedBasicEvents. You should never see this, unless you are debugging the system somewhere in between the tests.'
]

{ #category : #'Private-Generation' }
ChangeHooksTest >> generateTestClass [

	generatedTestClass := Object
				subclass: self generatedTestClassName
				instanceVariableNames: ''
				classVariableNames: ''
				poolDictionaries: ''
				category: self categoryForTestName1.
]

{ #category : #'Private-Generation' }
ChangeHooksTest >> generateTestClassCategory2 [

	generatedTestClassC2 := Object
				subclass: self generatedTestClassCategory2Name
				instanceVariableNames: ''
				classVariableNames: ''
				poolDictionaries: ''
				category: self categoryForTestName2.
]

{ #category : #'Private-Generation' }
ChangeHooksTest >> generateTestClassX [

	generatedTestClassX := Object
				subclass: self generatedTestClassNameX
				instanceVariableNames: 'x'
				classVariableNames: ''
				poolDictionaries: ''
				category: self categoryForTestName1.
]

{ #category : #'Private-Generation' }
ChangeHooksTest >> generatedTestClassCategory2Name [

	^#'AutoGeneratedClassC2ForTestingSystemChanges'
]

{ #category : #'Private-Generation' }
ChangeHooksTest >> generatedTestClassName [


	^#'AutoGeneratedClassForTestingSystemChanges'
]

{ #category : #'Private-Generation' }
ChangeHooksTest >> generatedTestClassNameX [

	^#'AutoGeneratedClassXForTestingSystemChanges'
]

{ #category : #'Events-Instance Variables' }
ChangeHooksTest >> instanceVariableCreationEvent: event [

	self addSingleEvent: event.	
	self assert: event isModified.
	self assert: event item = generatedTestClass.
	self assert: event itemKind = AbstractEvent classKind.
	self assert: event areInstVarsModified.
	self deny: event isSuperclassModified.
	self deny: event areClassVarsModified.
	self deny: event areSharedPoolsModified.
	

]

{ #category : #'Events-Instance Variables' }
ChangeHooksTest >> instanceVariableRemovedEvent: event [

	self addSingleEvent: event.	
	self assert: event isModified.
	self assert: event item = generatedTestClassX.
	self assert: event itemKind = AbstractEvent classKind.
	self assert: event areInstVarsModified.
	self deny: event isSuperclassModified.
	self deny: event areClassVarsModified.
	self deny: event areSharedPoolsModified.
	

]

{ #category : #'Events-Methods' }
ChangeHooksTest >> methodCreationEvent1: event [ 

	| methodCreated |
	self addSingleEvent: event.
	methodCreated := generatedTestClass >> createdMethodName.
	self 
		checkEvent: event
		kind: #Added
		item: methodCreated
		itemKind: AbstractEvent methodKind
]

{ #category : #'Events-Methods' }
ChangeHooksTest >> methodCreationEvent2: event [ 

	| methodCreated |
	self addSingleEvent: event.
	methodCreated := generatedTestClass >> createdMethodName.
	self 
		checkEvent: event
		kind: #Added
		item: methodCreated
		itemKind: AbstractEvent methodKind
]

{ #category : #'Events-Expression' }
ChangeHooksTest >> methodDoItEvent1: event [ 

	self addSingleEvent: event.
	self 
		checkEvent: event
		kind: #DoIt
		item: doItExpression
		itemKind: AbstractEvent expressionKind.
	self assert: event context isNil.
]

{ #category : #'Events-Methods' }
ChangeHooksTest >> methodRecategorizationEvent: event [

	| methodCreated |
	self addSingleEvent: event.
	methodCreated := generatedTestClass >> createdMethodName.
	self assert: ((generatedTestClass organization categoryOfElement: createdMethodName) = #newCategory).
	self assert: event oldCategory = #testing.
	self 
		checkEvent: event
		kind: #Recategorized
		item: methodCreated
		itemKind: AbstractEvent methodKind.
]

{ #category : #'Events-Methods' }
ChangeHooksTest >> methodRemovedEvent1: event [ 

	self addSingleEvent: event.
	self should: [generatedTestClass >> createdMethodName] raise: Error.
	self 
		checkEvent: event
		kind: #Removed
		item: createdMethod
		itemKind: AbstractEvent methodKind.
	event itemClass = generatedTestClass.
	event itemMethod = createdMethodName.
	self assert: ((generatedTestClass organization categoryOfElement: createdMethodName) isNil).
]

{ #category : #'Events-Methods' }
ChangeHooksTest >> methodRemovedEvent2: event [ 

	self methodRemovedEvent1: event
]

{ #category : #'Private-Generation' }
ChangeHooksTest >> newlyCreatedClassName [

	^#'AutoGeneratedClassWhileTestingSystemChanges'
]

{ #category : #private }
ChangeHooksTest >> performTest [

	Utilities
		useAuthorInitials: self className
		during: [ super performTest ]
]

{ #category : #'Events-General' }
ChangeHooksTest >> rememberEvent: event [

	capturedEvents add: event
]

{ #category : #Private }
ChangeHooksTest >> removeGeneratedTestClasses [
	"Remove all classes that were possibly generated during testing."
	
	| possiblyToRemove |
	possiblyToRemove := OrderedCollection
		with: self generatedTestClassName
		with: self generatedTestClassNameX
		with: self renamedTestClassName
		with: self newlyCreatedClassName.
	possiblyToRemove do: [:name | (Smalltalk hasClassNamed: name) ifTrue: [(Smalltalk at: name) removeFromSystemUnlogged]].
	generatedTestClass := nil.
	generatedTestClassX := nil
]

{ #category : #'Private-Generation' }
ChangeHooksTest >> renamedTestClassName [


	^#'AutoRenamedClassForTestingSystemChanges'
]

{ #category : #Running }
ChangeHooksTest >> setUp [

	previousChangeSet := ChangeSet current.
	testsChangeSet := ChangeSet new.
	ChangeSet newChanges: testsChangeSet.
	capturedEvents := OrderedCollection new.
	self generateTestClass.
	self generateTestClassX.
	self generateTestClassCategory2.
	super setUp
]

{ #category : #'Events-General' }
ChangeHooksTest >> shouldNotBeCalledEvent: anEvent [
	"This event should not be called, so fail the test."

	self assert: false
]

{ #category : #Running }
ChangeHooksTest >> tearDown [

	super tearDown.
	self removeGeneratedTestClasses.
	ChangeSet newChanges: previousChangeSet.
	ChangesOrganizer removeChangeSet: testsChangeSet.
	previousChangeSet := nil.
	testsChangeSet := nil.
	capturedEvents := nil.
	createdMethod := nil.
	SystemOrganization removeMissingClasses. "To make sure we do only try to unload recent classes."
	(PackageOrganizer default packages select: [:packageInfo | {self categoryForTestName1 . self categoryForTestName2} includes: packageInfo packageName ])
		do: [:packageInfo | packageInfo workingCopy unload].
]

{ #category : #'Testing-Classes' }
ChangeHooksTest >> testClassCommentedEvent [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #classCommentedEvent:.
	generatedTestClass comment: self commentStringForTesting.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Classes' }
ChangeHooksTest >> testClassCreationEvent [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #classCreationEvent:.
	Object 
		subclass: self newlyCreatedClassName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryForTestName1.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Classes' }
ChangeHooksTest >> testClassRecategorizedEvent1 [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #classRecategorizedEvent:.
	Object 
		subclass: generatedTestClass name
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryForTestName2.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Classes' }
ChangeHooksTest >> testClassRecategorizedEvent2 [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #classRecategorizedEvent:.
	generatedTestClass category: self categoryForTestName2.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Classes' }
ChangeHooksTest >> testClassRedefinition [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #classRedefinitionEvent:.
	self generateTestClass
]

{ #category : #'Testing-Classes' }
ChangeHooksTest >> testClassRemovalEvent [
	"This event used to be sent efter the class was removed.
	This was changed, and therefore this test is useless currently."
	
	"Keep it, since I really want to check with the responsible for the ChangeSet,
	and it is very likely this will be reintroduced afterwards!"

"	| createdClass |
	createdClass := self compileUniqueClass.
	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #classRemovalEvent:.
	createdClass removeFromSystem.
	self checkForOnlySingleEvent
	
	"
]

{ #category : #'Testing-Classes' }
ChangeHooksTest >> testClassRenamedEvent [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #classRenameEvent:.
	generatedTestClass rename: self renamedTestClassName.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Classes' }
ChangeHooksTest >> testClassSuperChangedEvent [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #classSuperChangedEvent:.
	Model 
		subclass: generatedTestClass name
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryForTestName1.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Expression' }
ChangeHooksTest >> testDoItEvent1 [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #methodDoItEvent1:.
	doItExpression := '1 + 2'.
	Compiler evaluate: doItExpression logged: true.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Expression' }
ChangeHooksTest >> testDoItEvent2 [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #shouldNotBeCalledEvent:.
	doItExpression := '1 + 2'.
	Compiler evaluate: doItExpression
]

{ #category : #'Testing-Instance Variables' }
ChangeHooksTest >> testInstanceVariableCreationEvent1 [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #instanceVariableCreationEvent:.
	Object 
		subclass: self generatedTestClassName
		instanceVariableNames: 'x'
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryForTestName1.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Instance Variables' }
ChangeHooksTest >> testInstanceVariableCreationEvent2 [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #instanceVariableCreationEvent:.
	generatedTestClass addInstVarName: 'x'.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Instance Variables' }
ChangeHooksTest >> testInstanceVariableRemovedEvent1 [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #instanceVariableRemovedEvent:.
	Object 
		subclass: generatedTestClassX name
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: self categoryForTestName1.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Instance Variables' }
ChangeHooksTest >> testInstanceVariableRemovedEvent2 [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #instanceVariableRemovedEvent:.
	generatedTestClassX removeInstVarName: 'x'.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Instance Variables' }
ChangeHooksTest >> testInstanceVariableRenamedSilently [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #shouldNotBeCalledEvent:.
	generatedTestClassX renameSilentlyInstVar: 'x' to: 'y'
]

{ #category : #'Testing-Methods' }
ChangeHooksTest >> testMethodCreationEvent1 [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #methodCreationEvent1:.
	createdMethodName := #testCreation.
	generatedTestClass compile: createdMethodName , '	^1'.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Methods' }
ChangeHooksTest >> testMethodCreationEvent2 [

	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #methodCreationEvent2:.
	createdMethodName := #testCreation.
	generatedTestClass compile: createdMethodName , '	^1' classified: #testing.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Methods' }
ChangeHooksTest >> testMethodRecategorizationEvent [

	createdMethodName := #testCreation.
	generatedTestClass compile: createdMethodName , '	^1' classified: #testing.
	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #methodRecategorizationEvent:.
	generatedTestClass organization 
		classify: createdMethodName
		under: #newCategory
		suppressIfDefault: false.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Methods' }
ChangeHooksTest >> testMethodRemovedEvent1 [

	createdMethodName := #testCreation.
	generatedTestClass compile: createdMethodName , '	^1'.
	createdMethod := generatedTestClass >> createdMethodName.
	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #methodRemovedEvent1:.
	generatedTestClass removeSelector: createdMethodName.
	self checkForOnlySingleEvent
]

{ #category : #'Testing-Methods' }
ChangeHooksTest >> testMethodRemovedEvent2 [

	createdMethodName := #testCreation.
	generatedTestClass compile: createdMethodName , '	^1'.
	createdMethod := generatedTestClass >> createdMethodName.
	self systemChangeNotifier notify: self
		ofAllSystemChangesUsing: #methodRemovedEvent2:.
	Smalltalk 
		removeSelector: (Array with: generatedTestClass name with: createdMethodName).
	self checkForOnlySingleEvent
]
