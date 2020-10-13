"
This is primarily an ordered list of package release installations or upgrades to achieve a given installation task.

"
Class {
	#name : #SMInstallationProposal,
	#superclass : #Object,
	#instVars : [
		'installList',
		'comment',
		'deviations',
		'task'
	],
	#category : #'SMBase-domain'
}

{ #category : #'instance creation' }
SMInstallationProposal class >> installList: anOrderedCollection [
	^ self new installList: anOrderedCollection
]

{ #category : #'initialize-release' }
SMInstallationProposal >> calculateComment [

	comment := ''
]

{ #category : #'initialize-release' }
SMInstallationProposal >> calculateDeviations [
	"Calculate deviations. Currently we just pick the newest release."

	| conflicts |
	deviations := OrderedCollection new.
	conflicts := self collectConflictsIn: installList.
	conflicts keysAndValuesDo: [:package :releases | | newest |
		newest := releases first.
		releases do: [:r | (r newerThan: newest) ifTrue: [newest := r]].
		deviations add: (SMInstallationDeviation selectedRelease: newest releases: installList)]
]

{ #category : #'initialize-release' }
SMInstallationProposal >> collectConflictsIn: collectionOfReleases [
	"Collect all conflicts where there are either
		- multiple releases of the same package and/or
		- another release of the same package already installed
	Return the conflicts as an IdentityDictionary with
	the package as key and the value being a Set of releases."

	| conflicts set |
	conflicts := IdentityDictionary new.
	collectionOfReleases do: [:r |
		set := conflicts at: r package ifAbsentPut: [OrderedCollection new].
		set add: r].
	"Add the installed releases too"
	conflicts keysAndValuesDo: [:key :value |
		key isInstalled ifTrue: [value add: key installedRelease]].
	"Prune release sets with only one member"
	^conflicts select: [:releaseSet | releaseSet size > 1]
]

{ #category : #'initialize-release' }
SMInstallationProposal >> hasDeviations [
	^ deviations notEmpty
]

{ #category : #'initialize-release' }
SMInstallationProposal >> installList: anOrderedCollection [

	installList := anOrderedCollection.
	self calculateDeviations.
	self calculateComment
]
