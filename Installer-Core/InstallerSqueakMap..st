Class {
	#name : #InstallerSqueakMap,
	#superclass : #Installer,
	#instVars : [
		'sm'
	],
	#category : #'Installer-Core'
}

{ #category : #'basic interface' }
InstallerSqueakMap >> basicAvailablePackages [
	
	^self classSMSqueakMap default packagesByName
]

{ #category : #'basic interface' }
InstallerSqueakMap >> basicBrowse [

	self smThing explore
]

{ #category : #'basic interface' }
InstallerSqueakMap >> basicInstall [ 

	self log: ' installing '. 
	self withAnswersDo: [ self smThing install ].
	self log: ' done'.

]

{ #category : #'basic interface' }
InstallerSqueakMap >> basicVersions [
 
	^ (self smReleasesForPackage: self package) 
			collect: [ :v | self copy package: (v package name,'(',v version,')'); yourself. ] 

 
]

{ #category : #'basic interface' }
InstallerSqueakMap >> basicView [

	self smThing explore
]

{ #category : #'class references' }
InstallerSqueakMap >> classSMLoader [

	^Smalltalk at: #SMLoader  ifAbsent: [ self error: 'SqueakMap Loader not present' ]
]

{ #category : #'class references' }
InstallerSqueakMap >> classSMSqueakMap [

	^Smalltalk at: #SMSqueakMap  ifAbsent: [ self error: 'SqueakMap not present' ]
]

{ #category : #'public interface' }
InstallerSqueakMap >> open [
	self classSMLoader open
]

{ #category : #searching }
InstallerSqueakMap >> packagesMatching: aMatch [
	^ (self availablePackages
		select: [ :p | aMatch match: p name ]) 
		collect: [ :p | self copy package: p name; yourself ]
]

{ #category : #searching }
InstallerSqueakMap >> search: aMatch [  

	| results |
	results := Set new.
	self availablePackages do: [ :pkg |
		({ 'name:',pkg name.
		   'summary:', pkg summary.
		   'description:', pkg description.
		   'author:', pkg author. } anySatisfy: [ :field | aMatch match: field ])
		 ifTrue: [ results add: (self copy package: pkg name) ]. 
	].
	^results


]

{ #category : #accessing }
InstallerSqueakMap >> sm [

	^ sm ifNil: [ false ]
]

{ #category : #accessing }
InstallerSqueakMap >> sm: anObject [

	sm := anObject
]

{ #category : #squeakmap }
InstallerSqueakMap >> smPackageAndVersion [
	^ self packageAndVersionFrom: self package.
]

{ #category : #squeakmap }
InstallerSqueakMap >> smReleasesForPackage: name [ 

	^(self classSMSqueakMap default packageWithName: name) releases
]

{ #category : #squeakmap }
InstallerSqueakMap >> smThing [ 

	| pkgAndVersion releases release |
	pkgAndVersion := self packageAndVersionFrom: self package.
	self logCR: 'retrieving ', self package, ' from SqueakMap...'.
	releases := self smReleasesForPackage: pkgAndVersion first.
	release := pkgAndVersion last isEmpty 
				ifTrue: [ releases last ]
				ifFalse:[ releases detect: [ :rel | rel version = pkgAndVersion last ] ]. 
	^ release
		
	

]

{ #category : #squeakmap }
InstallerSqueakMap >> update [
"Updates the local map for SqueakMap, upgrading SqueakMap to the latest version if necessary.

When SqueakMap is old and needs to be upgraded, it does four things that mostly make sense in the interactive world SM was built for, but are totally evil here in the world of automatic scripting:
1. It asks the user if she wants to upgrade, in the form of a pop-up (see SMSqueakMap >> #checkVersion:).
2. It terminates its own process.
3. It creates a new UI process.
(see the last line of the SqueakMap upgrade file-in: ''Project spawnNewProcessAndTerminateOld: true'', from 
http://map.squeak.org/accountbyid/9bdedc18-1525-44a6-9b79-db5d4a87f6f8/files/SqueakMap8.st
4. It opens a SqueakMap window

We work around these three problems seperately:
1. We use #answer:with: and #withAnswersDo: to automatically answer ''Yes'' when asked if we want to upgrade
2. We don't want this process to be terminated, so we run the update in a forked process and wait for it to finish, using #fork, #ensure:, and a Semaphore
3. We keep track of the UI process before updating, and if it changes, we terminate the new UI process and reinstall the old one using Project >> #resumeProcess:
4. We don't bother with the newly opened window. The other three problems are much worse.

We do all this in a new process, since it is not unlikely that this method is executing in the UI process"

	| oldUIProcess doneSema |
	self answer: 'You need to upgrade the SqueakMap package' with: true.
	oldUIProcess := Project uiProcess.
	doneSema := Semaphore new.
	[[self withAnswersDo: [self classSMSqueakMap default loadUpdates]] 
		ensure: [
			| newUIProcess |
			newUIProcess := Project uiProcess.
			(oldUIProcess ~~ newUIProcess
				and: [oldUIProcess notNil
					and: [oldUIProcess isTerminated not]])
					 ifTrue: [
							newUIProcess ifNotNil: [newUIProcess terminate].
							oldUIProcess suspend.
							Project resumeProcess: oldUIProcess.].
			doneSema signal]] fork.
	doneSema wait
]
