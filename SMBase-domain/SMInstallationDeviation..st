"
An installation deviation is when the user decides to install or upgrade to a release that is newer than one or more used configurations specify.
This means that the other installed releases which configurations will be broken may not work correctly.
Instvar selectedRelease refers to the release selected to install, brokenConfigurations is a collection of all configurations that need another release of this package.
"
Class {
	#name : #SMInstallationDeviation,
	#superclass : #Object,
	#instVars : [
		'brokenConfigurations',
		'selectedRelease'
	],
	#category : #'SMBase-domain'
}

{ #category : #'instance creation' }
SMInstallationDeviation class >> selectedRelease: release releases: releases [
	^self new selectedRelease: release releases: releases
]

{ #category : #accessing }
SMInstallationDeviation >> otherReleases [
	| package |
	package := selectedRelease package.
	^ brokenConfigurations collect: [:conf |
		conf releases detect: [:r | r package == package]]
]

{ #category : #accessing }
SMInstallationDeviation >> selectedRelease [
	^ selectedRelease
]

{ #category : #'initialize-release' }
SMInstallationDeviation >> selectedRelease: aRelease releases: releases [

	| p others |
	selectedRelease := aRelease.
	p := selectedRelease package.
	brokenConfigurations := OrderedCollection new.
	others := releases copyWithout: aRelease.
	others := others select: [:r | r package ~= p].
	others do: [:rel |
		rel workingConfigurations do: [:conf | | otherRequired |
			otherRequired := conf requiredReleases select: [:r | r package ~= p].
			((others includesAllOf: otherRequired) and:
				[(conf requiredReleases includes: selectedRelease) not])
					ifTrue: [brokenConfigurations add: conf]]]
]
