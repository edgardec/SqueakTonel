"
The Root test class for the System Change Notification tests.
"
Class {
	#name : #SystemChangeTestRoot,
	#superclass : #TestCase,
	#category : #'SystemChangeNotification-Tests'
}

{ #category : #Private }
SystemChangeTestRoot >> systemChangeNotifier [
	"The notifier to use. Use the one for the system."

	^SystemChangeNotifier uniqueInstance
]

{ #category : #Running }
SystemChangeTestRoot >> tearDown [

	self unhook.
	super tearDown
]

{ #category : #Running }
SystemChangeTestRoot >> unhook [

	self systemChangeNotifier noMoreNotificationsFor: self
]
