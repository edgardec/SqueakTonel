Class {
	#name : #AutoStart,
	#superclass : #Object,
	#instVars : [
		'parameters'
	],
	#classVars : [
		'Active',
		'InstalledLaunchers'
	],
	#category : #'System-Support'
}

{ #category : #private }
AutoStart class >> active [
	^ Active == true
]

{ #category : #private }
AutoStart class >> active: aBoolean [
	Active := aBoolean
]

{ #category : #accessing }
AutoStart class >> addLauncher: launcher [
	self installedLaunchers add: launcher
]

{ #category : #accessing }
AutoStart class >> addLauncherFirst: launcher [
	self installedLaunchers addFirst: launcher
]

{ #category : #'class initialization' }
AutoStart class >> deinstall [
	"AutoStart deinstall"

	Smalltalk removeFromStartUpList: AutoStart.
	Smalltalk removeFromShutDownList: AutoStart.
	InstalledLaunchers := nil
]

{ #category : #'class initialization' }
AutoStart class >> initialize [
	"AutoStart initialize"
	"Order: ExternalSettings, SecurityManager, AutoStart"
	Smalltalk addToStartUpList: AutoStart after: SecurityManager.
	Smalltalk addToShutDownList: AutoStart after: SecurityManager.
]

{ #category : #private }
AutoStart class >> installedLaunchers [
	InstalledLaunchers ifNil: [
		InstalledLaunchers := OrderedCollection new].
	^InstalledLaunchers
]

{ #category : #updating }
AutoStart class >> processUpdates [
	"Process update files from a well-known update server.  This method is called at system startup time,   Only if the preference #updateFromServerAtStartup is true is the actual update processing undertaken automatically"
	| choice |
	(MCMcmUpdater updateFromServerAtStartup) ifTrue:
		[choice := UIManager default chooseFrom: #('Yes, Update' 'No, Not now' 'Don''t ask again')
			title: 'Shall I look for new code\updates on the server?' withCRs.
		choice = 1 ifTrue: [
			MCMcmUpdater updateFromServer].
		choice = 3 ifTrue: [
			MCMcmUpdater updateFromServerAtStartup: false.
			self inform: 'Remember to save your image to make this setting permant']]
]

{ #category : #accessing }
AutoStart class >> removeLauncher: launcher [
	self installedLaunchers remove: launcher ifAbsent: []
]

{ #category : #'class initialization' }
AutoStart class >> shutDown: quitting [
	self active: false
]

{ #category : #initialization }
AutoStart class >> startUp: resuming [
	"The image is either being newly started (resuming is true), or it's just been snapshotted.
	If this has just been a snapshot, skip all the startup stuff."

	| startupParameters launchers |
	self active ifTrue: [^self].
	self active: true.
	resuming ifFalse: [^self].

	startupParameters := Smalltalk namedArguments.
			
	self processUpdates.

	launchers := self installedLaunchers collect: [:launcher |
		launcher new].
	launchers do: [:launcher |
		launcher parameters: startupParameters].
	launchers do: [:launcher |
		Project current addDeferredUIMessage: [launcher startUp]]
]
