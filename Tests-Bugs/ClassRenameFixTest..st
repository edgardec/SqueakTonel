Class {
	#name : #ClassRenameFixTest,
	#superclass : #TestCase,
	#instVars : [
		'previousChangeSet',
		'testsChangeSet',
		'newClassName',
		'originalName'
	],
	#category : #'Tests-Bugs'
}

{ #category : #private }
ClassRenameFixTest >> newUniqueClassName [
	"Return a class name that is not used in the system."

	"self new newClassName"

	| baseName newName |
	baseName := 'AutoGeneratedClassForTestingSystemChanges'.
	1 to: 9999
		do: 
			[:number | 
			newName := baseName , number printString.
			(Smalltalk hasClassNamed: newName) ifFalse: [^newName asSymbol]].
	^self 
		error: 'Can no longer find a new and unique class name for the SystemChangeTest !'
]

{ #category : #private }
ClassRenameFixTest >> removeEverythingInSetFromSystem: aChangeSet [ 

	aChangeSet changedMessageList
		do: [:methodRef | methodRef actualClass removeSelector: methodRef methodSymbol].
	aChangeSet changedClasses
		do: [:each | each isMeta
				ifFalse: [each removeFromSystemUnlogged]]
]

{ #category : #tests }
ClassRenameFixTest >> renameClassUsing: aBlock [

	| createdClass foundClasses |
	originalName := self newUniqueClassName.
	createdClass := Object 
		subclass: originalName
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'ClassRenameFix-GeneradClass'.
	newClassName := self newUniqueClassName.
	aBlock value: createdClass value: newClassName.
	self assert: (Smalltalk classNamed: originalName) isNil.
	self assert: (Smalltalk classNamed: newClassName) notNil.
	foundClasses := Smalltalk organization listAtCategoryNamed: 'ClassRenameFix-GeneradClass'.
	self assert: (foundClasses notEmpty).
	self assert: (foundClasses includes: newClassName).
	self assert: (createdClass name = newClassName).
]

{ #category : #running }
ClassRenameFixTest >> setUp [

	previousChangeSet := ChangeSet current.
	testsChangeSet := ChangeSet new.
	ChangeSet newChanges: testsChangeSet.
	SystemChangeNotifier uniqueInstance
		notify: self
		ofSystemChangesOfItem: #class
		change: #Renamed
		using: #verifyRenameEvent:.
	super setUp
]

{ #category : #running }
ClassRenameFixTest >> tearDown [

	self removeEverythingInSetFromSystem: testsChangeSet.
	ChangeSet newChanges: previousChangeSet.
	ChangesOrganizer removeChangeSet: testsChangeSet.
	previousChangeSet := nil.
	testsChangeSet := nil.
	SystemChangeNotifier uniqueInstance noMoreNotificationsFor: self.
	super tearDown.
]

{ #category : #tests }
ClassRenameFixTest >> testRenameClassUsingClass [
	"self run: #testRenameClassUsingClass"

	self renameClassUsing: [:class :newName | class rename: newName].
]

{ #category : #private }
ClassRenameFixTest >> verifyRenameEvent: aRenamedEvent [

	| renamedClass |
	self assert: aRenamedEvent isRenamed.
	renamedClass :=  aRenamedEvent item.
	self assert: (Smalltalk classNamed: newClassName) name = newClassName.
	self assert: renamedClass name = newClassName
]
