"
A dependency engine is used to perform one or more installation, upgrade or uninstallation tasks.
After creation it is typically configured according to different strategies, policies etc based on the preferences of the user.
Then it is used to calculate what installations, uninstallations or upgrades are needed and in which order to reach certain stated goals, like installing a set of wanted packages or upgrading the installed packages.

The engine instantiates different SMInstallationTask subclasses depending on what it should calculate.

Todo: both the installation information for the image and the engine should probably be kept outside of the SMSqueakMap instance.

"
Class {
	#name : #SMDependencyEngine,
	#superclass : #Object,
	#instVars : [
		'map'
	],
	#category : #'SMBase-domain'
}

{ #category : #'instance creation' }
SMDependencyEngine class >> map: aMap [

	^ self new map: aMap
]

{ #category : #tasks }
SMDependencyEngine >> installPackages: wantedPackages [
	"Given a Set of wanted SMPackages, create an installation task to compute
	possible installation scenarios.
	Returns an SMInstallationTask which can be further configured
	and then be sent #calculate after which it can be queried for results."
	
	^SMPackageInstallationTask engine: self wantedPackages: wantedPackages
]

{ #category : #accessing }
SMDependencyEngine >> map [
	^map
]

{ #category : #accessing }
SMDependencyEngine >> map: aMap [
	map := aMap
]
