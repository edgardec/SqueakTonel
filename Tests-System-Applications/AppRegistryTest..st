Class {
	#name : #AppRegistryTest,
	#superclass : #TestCase,
	#category : #'Tests-System-Applications'
}

{ #category : #tests }
AppRegistryTest >> test01AppsAreBehaviors [
	"This test ensures the integrity of the given image state with respect to AppRegistry. After the ReleaseBuilder scripts ran, this test must pass."
	
	AppRegistry withAllSubclasses do: [:app |
		self assert: (app registeredClasses reject: [:ea | ea isBehavior]) isEmpty].
]
