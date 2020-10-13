"
A package installation task is to install one or more given SMPackages (not specified releases) into the image.

First it tries to calculate the ideal releases of the given packages that it will try to install given the policy and preferences set by the user. Then it runs an analysis to find how to install those wanted releases. This typically results in zero, one or more possible scenarios.

"
Class {
	#name : #SMPackageInstallationTask,
	#superclass : #SMInstallationTask,
	#instVars : [
		'wantedPackages',
		'wantedReleases',
		'analysis'
	],
	#category : #'SMBase-domain'
}

{ #category : #'instance creation' }
SMPackageInstallationTask class >> engine: engine wantedPackages: wantedPackages [
	^self new engine: engine; wantedPackages: wantedPackages
]

{ #category : #queries }
SMPackageInstallationTask >> allInstallPaths [
	"Return all different ways to install - the ones requested plus all dependencies.
	This includes ways where different releases of the same package are combined."

	^analysis allInstallPaths
]

{ #category : #accessing }
SMPackageInstallationTask >> analysis [
	"Return the analysis of the task."

	^analysis
]

{ #category : #calculation }
SMPackageInstallationTask >> calculate [
	"First calculate the wanted releases. Then perform a dependency analysis.
	We return the most basic result of the analysis - does there exist at least one
	working installation scenario without tweaks?"

	self calculateWantedReleases.
	analysis := SMDependencyAnalysis task: self.
	analysis installPackageReleases: wantedReleases.
	^analysis success
]

{ #category : #private }
SMPackageInstallationTask >> calculateWantedReleases [
	"The user gave us wanted packages.
	We need to figure out which actual releases of those
	we should try to install."

	wantedReleases := Set new.
	wantedPackages do: [:p | | rel |
		rel := self idealReleaseFor: p.
		rel ifNotNil: [wantedReleases add: rel]]
]

{ #category : #private }
SMPackageInstallationTask >> idealReleaseFor: aPackage [
	"Return the most suitable release to install for <aPackage>."

	^ aPackage lastPublishedReleaseForCurrentSystemVersion
]

{ #category : #queries }
SMPackageInstallationTask >> proposals [
	"Return all different possible proposals to install
	sorted with the best proposal first."

	^analysis allNormalizedInstallPaths collect: [:path | SMInstallationProposal installList: path]
]

{ #category : #accessing }
SMPackageInstallationTask >> wantedPackages: packages [

	wantedPackages := packages
]
