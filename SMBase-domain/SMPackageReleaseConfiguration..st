"
A package release configuration describes the result of testing the specific release with a set of other releases that it depends on.
The status instvar holds a symbol which reflects the result. Currently there are two valid values:
	#working
	#failing
	
The intention is that users and maintainers post these configurations to the map as ""known working combinations of required releases"".
Each SMPackageRelease can then have multiple of these configurations.
"
Class {
	#name : #SMPackageReleaseConfiguration,
	#superclass : #SMEmbeddedResource,
	#instVars : [
		'requiredReleases',
		'status'
	],
	#category : #'SMBase-domain'
}

{ #category : #dependencies }
SMPackageReleaseConfiguration >> addRequiredRelease: aRelease [
	"Add <aRelease> as a required release. The release added
	can not indirectly refer back to this release."
	
	(self isCircular: aRelease) ifTrue: [self error: 'Circular dependencies not allowed.'].
	requiredReleases := requiredReleases copyWith: aRelease.
	^aRelease
]

{ #category : #'initialize-release' }
SMPackageReleaseConfiguration >> initialize [
	super initialize.
	requiredReleases := #().
	status := #working
]

{ #category : #private }
SMPackageReleaseConfiguration >> isCircular: aRelease [
	"Answer if there is a reference that goes back
	to the release of this configuration."

	"This is the base case"
	aRelease == object ifTrue: [^ true].
	
	aRelease configurations do: [:conf |
		conf requiredReleases do: [:rel |
			(self isCircular: rel) ifTrue: [^ true]]].
	^false
]

{ #category : #testing }
SMPackageReleaseConfiguration >> isConfiguration [
	^true
]

{ #category : #testing }
SMPackageReleaseConfiguration >> isFailing [
	^status == #failing
]

{ #category : #testing }
SMPackageReleaseConfiguration >> isFulfilled [
	"Are all my required releases already installed?"
	
	^requiredReleases allSatisfy: [:r | r isInstalled ]
]

{ #category : #testing }
SMPackageReleaseConfiguration >> isWorking [
	^status == #working
]

{ #category : #printing }
SMPackageReleaseConfiguration >> printOn: aStream [

	aStream nextPutAll: 'Cfg['.
	requiredReleases do: [:r |
		aStream nextPutAll: r printString; space].
	aStream nextPutAll: ']'
]

{ #category : #dependencies }
SMPackageReleaseConfiguration >> removeRequiredRelease: aRelease [
	"Remove <aRelease> as a required release."
	
	requiredReleases := requiredReleases copyWithout: aRelease.
	^ aRelease
]

{ #category : #accessing }
SMPackageReleaseConfiguration >> requiredReleases [
	^ requiredReleases
]

{ #category : #accessing }
SMPackageReleaseConfiguration >> status [
	^ status
]
