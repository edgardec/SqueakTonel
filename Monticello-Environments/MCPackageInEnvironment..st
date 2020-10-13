"
I am a decorator for an MCPackage, activating an Environment for relevant operations.

Instance Variables
	environment:		<Environment> should be the current one for some of my operations
	package:		<MCPackage> my substance
"
Class {
	#name : #MCPackageInEnvironment,
	#superclass : #ProtoObject,
	#instVars : [
		'package',
		'environment'
	],
	#category : #'Monticello-Environments'
}

{ #category : #'instance creation' }
MCPackageInEnvironment class >> decorating: aPackage in: anEnvironment [
	| instance |
	instance := self new.
	instance initializeWithPackage: aPackage in: anEnvironment.
	^ instance
]

{ #category : #'object behavior' }
MCPackageInEnvironment >> basicInspect [
	"Create and schedule an Inspector in which the user can examine the 
	receiver's variables. This method should not be overriden."
	^ToolSet basicInspect: self
]

{ #category : #delegating }
MCPackageInEnvironment >> doesNotUnderstand: aMessage [
	^ aMessage sendTo: package
]

{ #category : #accessing }
MCPackageInEnvironment >> environment [

	^ environment
]

{ #category : #accessing }
MCPackageInEnvironment >> environment: anObject [

	environment := anObject
]

{ #category : #'initialize-release' }
MCPackageInEnvironment >> inEnvironment: anEnvironment [
	environment == anEnvironment ifTrue: [^ self].
	^ MCPackageInEnvironment decorating: package in: anEnvironment
]

{ #category : #'initialize-release' }
MCPackageInEnvironment >> initializeWithPackage: aPackage in: anEnvironment [
	package := aPackage.
	environment := anEnvironment.
]

{ #category : #delegating }
MCPackageInEnvironment >> respondsTo: aSymbol [
	^ (MCPackageInEnvironment canUnderstand: aSymbol)
		or: [package respondsTo: aSymbol]
]

{ #category : #'input\/output' }
MCPackageInEnvironment >> snapshot [
	^ environment beCurrentDuring: [package snapshot]
]
