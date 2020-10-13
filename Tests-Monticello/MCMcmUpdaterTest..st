"
MCMcmUpdaterTest verifies registry of Monticello based updaters used for update streams, including the Squeak trunk update stream. The default update stream for the image is specified by preferences, and new updaters are created as needed. Existing updaters remain in a registry such that their individual update status is preserved.

"
Class {
	#name : #MCMcmUpdaterTest,
	#superclass : #TestCase,
	#classVars : [
		'SaveRegistry'
	],
	#category : #'Tests-Monticello'
}

{ #category : #running }
MCMcmUpdaterTest >> setUp [
	"Registry will be modified by tests. Safe it here and restore it in tearDown"
	SaveRegistry := MCMcmUpdater registry.
	MCMcmUpdater registry: nil
]

{ #category : #running }
MCMcmUpdaterTest >> tearDown [

	MCMcmUpdater registry: SaveRegistry

]

{ #category : #tests }
MCMcmUpdaterTest >> testDefault [

	| defaultMapFromPreference defaultURLFromPreference defaultUpdater |
	defaultMapFromPreference := MCMcmUpdater updateMapName.
	defaultURLFromPreference := MCMcmUpdater defaultUpdateURL.
	defaultUpdater := MCMcmUpdater default. "create and register"
	self assert: defaultMapFromPreference equals: defaultUpdater updateMapName.
	self assert: defaultURLFromPreference equals: defaultUpdater repository.
	self assert: MCMcmUpdater registry size = 1.
	self assert: (MCMcmUpdater registry at: defaultURLFromPreference) size = 1

]

{ #category : #tests }
MCMcmUpdaterTest >> testRegistryIsBeingSaved [
	"setUp and tearDown save and restore the current state"

	self assert: MCMcmUpdater registry isNil
]

{ #category : #tests }
MCMcmUpdaterTest >> testTwoUpdatersForOneRepository [

	| reg updater1 updater2 |
	reg := MCMcmUpdater registry.
	updater1 := MCMcmUpdater updateMapNamed: 'BAR' repository: 'FOO'.
	self assert: MCMcmUpdater registry size = 1.
	self assert: (MCMcmUpdater registry at: 'FOO') size = 1.
	updater2 := MCMcmUpdater updateMapNamed: 'BAZ' repository: 'FOO'.
	self assert: MCMcmUpdater registry size = 1.
	self assert: (MCMcmUpdater registry at: 'FOO') size = 2.
	updater1 unregister.
	self assert: MCMcmUpdater registry size = 1.
	self assert: (MCMcmUpdater registry at: 'FOO') size = 1.
	updater2 unregister.
	self assert: MCMcmUpdater registry isEmpty.
	self should: [MCMcmUpdater registry at: 'FOO'] raise: Error.

]

{ #category : #tests }
MCMcmUpdaterTest >> testTwoUpdatersInDifferentRepositories [

	| reg updater1 updater2 |
	reg := MCMcmUpdater registry.
	updater1 := MCMcmUpdater updateMapNamed: 'BAR' repository: 'FOO'.
	self assert: MCMcmUpdater registry size = 1.
	self assert: (MCMcmUpdater registry at: 'FOO') size = 1.
	updater2 := MCMcmUpdater updateMapNamed: 'BAZ' repository: 'FOO2'.
	self assert: MCMcmUpdater registry size = 2.
	self assert: (MCMcmUpdater registry at: 'FOO') size = 1.
	self assert: (MCMcmUpdater registry at: 'FOO2') size = 1.
	updater1 unregister.
	self assert: MCMcmUpdater registry size = 1.
	self assert: (MCMcmUpdater registry at: 'FOO2') size = 1.
	updater2 unregister.
	self assert: MCMcmUpdater registry isEmpty.
	self should: [MCMcmUpdater registry at: 'FOO'] raise: Error.
	self should: [MCMcmUpdater registry at: 'FOO2'] raise: Error.

]

{ #category : #tests }
MCMcmUpdaterTest >> testUpdatePreferences [

	| defaultMapFromPreference defaultURLFromPreference defaultUpdater |
	defaultMapFromPreference := MCMcmUpdater updateMapName.
	defaultURLFromPreference := MCMcmUpdater defaultUpdateURL.
	defaultUpdater := MCMcmUpdater default. "create and register"
	self assert: defaultMapFromPreference equals: defaultUpdater updateMapName.
	self assert: defaultURLFromPreference equals: defaultUpdater repository.
	self assert: MCMcmUpdater registry size = 1.
	self assert: (MCMcmUpdater registry at: defaultURLFromPreference) size = 1.
	[ | newDefault |
		MCMcmUpdater updateMapName: 'NEWMAP'.
		"new instance not yet registered"
		self assert: MCMcmUpdater registry size = 1.
		self assert: (MCMcmUpdater registry at: defaultURLFromPreference) size = 1.
		self shouldnt: [MCMcmUpdater registry at: defaultURLFromPreference] raise: Error.
		self should: [(MCMcmUpdater registry at: defaultURLFromPreference) at: 'NEWMAP'] raise: Error.
		newDefault := MCMcmUpdater default. "create and register new default updater"
		self shouldnt: [(MCMcmUpdater registry at: defaultURLFromPreference) at: 'NEWMAP'] raise: Error.
		self assert: 'NEWMAP' equals: newDefault updateMapName.

		MCMcmUpdater defaultUpdateURL: 'NEWURL'.
		self assert: MCMcmUpdater registry size = 1.
		newDefault := MCMcmUpdater default. "create and register new default updater"
		self assert: MCMcmUpdater registry size = 2.
		self shouldnt: [(MCMcmUpdater registry at: 'NEWURL') at: 'NEWMAP'] raise: Error.
		self assert: 'NEWURL' equals: newDefault repository.
		self assert: 'NEWMAP' equals: newDefault updateMapName.
	] ensure: [ "restore preferences"
		MCMcmUpdater updateMapName: defaultMapFromPreference.
		MCMcmUpdater defaultUpdateURL: defaultURLFromPreference
	]



]
