"
An SMInstallationProposal is effectively a list of releases to install or upgrade to in a specific order to achieve an SMInstallationTask.
The task can be either an upgrade or a new installation - the proposal still involved an ordered list of installations or upgrades.

"
Class {
	#name : #SMInstallationTask,
	#superclass : #Object,
	#instVars : [
		'map',
		'engine'
	],
	#category : #'SMBase-domain'
}

{ #category : #calculation }
SMInstallationTask >> calculate [
	"Calculate how the task should be performed.
	After calculation the task can be inspected and presented
	to the user for confirmation. Actually performing the task
	is done by #execute."
	
	self subclassResponsibility 
]

{ #category : #accessing }
SMInstallationTask >> engine: anEngine [
	engine := anEngine.
	map := engine map
]

{ #category : #calculation }
SMInstallationTask >> execute [
	"Actually perform the task."

	self subclassResponsibility 
]

{ #category : #accessing }
SMInstallationTask >> map [
	^map
]
