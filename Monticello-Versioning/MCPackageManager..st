Class {
	#name : #MCPackageManager,
	#superclass : #Object,
	#instVars : [
		'package',
		'modified'
	],
	#classInstVars : [
		'registry'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #private }
MCPackageManager class >> allManagers [
	^ self registry values
]

{ #category : #'system changes' }
MCPackageManager class >> classModified: anEvent [
	self managersForClass: anEvent item do:[:mgr| mgr modified: true].
]

{ #category : #'system changes' }
MCPackageManager class >> classMoved: anEvent [
	self classModified: anEvent.
	self managersForCategory: anEvent oldCategory do:[:mgr| mgr modified: true].
]

{ #category : #'system changes' }
MCPackageManager class >> classRemoved: anEvent [
	self classModified: anEvent
]

{ #category : #'instance creation' }
MCPackageManager class >> forPackage: aPackage [
	^ self registry at: aPackage ifAbsent:
		[|mgr|
		mgr := self new initializeWithPackage: aPackage.
		self registry at: aPackage put: mgr.
		self changed: #allManagers.
		mgr]
]

{ #category : #'instance creation' }
MCPackageManager class >> forPackageNamed: aString [ 
	^ self registry detect:
		[ : each | each packageName = aString ]
]

{ #category : #'class initialization' }
MCPackageManager class >> initialize [
	"Remove this later"
	Smalltalk at: #SystemChangeNotifier ifPresent:[:cls|
		(cls uniqueInstance) noMoreNotificationsFor: self.
	].
]

{ #category : #'system changes' }
MCPackageManager class >> managersForCategory: aSystemCategory do: aBlock [
	"Got to be careful here - we might get method categories where capitalization is problematic."
	| cat foundOne index |
	foundOne := false.
	cat := aSystemCategory ifNil:[^nil]. "yes this happens; for example in eToy projects"
	"first ask PackageInfos, their package name might not match the category"
	self registry do: [:mgr | 
		(mgr packageInfo includesSystemCategory: aSystemCategory)	ifTrue: [
			aBlock value: mgr.
			foundOne := true.
		]
	].
	foundOne ifTrue: [^self].
	["Loop over categories until we found a matching one"
	self registry at: (MCPackage named: cat) ifPresent:[:mgr|
		aBlock value: mgr.
		foundOne := true.
	].
	index := cat lastIndexOf: $-.
	index > 0]whileTrue:[
		"Step up to next level package"
		cat := cat copyFrom: 1 to: index-1.
	].
	foundOne ifFalse:[
		"Create a new (but only top-level)"
		aBlock value: (MCWorkingCopy forPackage: (MCPackage named: (aSystemCategory copyUpTo: $-) capitalized)).
	].
]

{ #category : #'system changes' }
MCPackageManager class >> managersForClass: aClass category: methodCategory do: aBlock [
	(methodCategory isEmptyOrNil or:[methodCategory first ~= $*]) ifTrue:[
		"Not an extension method"
		^self managersForClass: aClass do: aBlock.
	].
	self managersForCategory: methodCategory allButFirst do: aBlock.
]

{ #category : #'system changes' }
MCPackageManager class >> managersForClass: aClass do: aBlock [

	self registry do: [:mgr |
		(mgr packageInfo includesClass: aClass)
			ifTrue: [aBlock value: mgr]]
]

{ #category : #'system changes' }
MCPackageManager class >> managersForClass: aClass selector: aSelector do: aBlock [
	^self managersForClass: aClass category: (aClass organization categoryOfElement: aSelector) do: aBlock
]

{ #category : #'system changes' }
MCPackageManager class >> methodModified: anEvent [
	^self managersForClass: anEvent itemClass selector: anEvent itemSelector do:[:mgr| mgr modified: true].
]

{ #category : #'system changes' }
MCPackageManager class >> methodMoved: anEvent [
	self managersForClass: anEvent itemClass category: anEvent oldCategory do:[:mgr| mgr modified: true].
	self methodModified: anEvent.
]

{ #category : #'system changes' }
MCPackageManager class >> methodRemoved: anEvent [
	self managersForClass: anEvent itemClass category: anEvent itemProtocol do:[:mgr| mgr modified: true].

]

{ #category : #'system changes' }
MCPackageManager class >> registerForNotifications [
	Smalltalk
		at: #SystemChangeNotifier
		ifPresent:
			[:cls|
			cls uniqueInstance noMoreNotificationsFor: self.
			self reregisterForNotificationsWith: cls uniqueInstance]
]

{ #category : #private }
MCPackageManager class >> registry [
	^ registry ifNil: [registry := Dictionary new]
]

{ #category : #'system changes' }
MCPackageManager class >> reregisterForNotificationsWith: aSystemChangeNotifier [
	aSystemChangeNotifier
		notify: self ofSystemChangesOfItem: #class change: #Added using: #classModified:;
		notify: self ofSystemChangesOfItem: #class change: #Modified using: #classModified:;
		notify: self ofSystemChangesOfItem: #class change: #Renamed using: #classModified:;
		notify: self ofSystemChangesOfItem: #class change: #Commented using: #classModified:;
		notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #classMoved:;
		notify: self ofSystemChangesOfItem: #class change: #Removed using: #classRemoved:;
		notify: self ofSystemChangesOfItem: #method change: #Added using: #methodModified:;
		notify: self ofSystemChangesOfItem: #method change: #Modified using: #methodModified:;
		notify: self ofSystemChangesOfItem: #method change: #Recategorized using: #methodMoved:;
		notify: self ofSystemChangesOfItem: #method change: #Removed using: #methodRemoved:
]

{ #category : #'system changes' }
MCPackageManager >> classModified: anEvent [
	"obsolete - remove this later"
]

{ #category : #'system changes' }
MCPackageManager >> classMoved: anEvent [
	"obsolete - remove this later"
]

{ #category : #'system changes' }
MCPackageManager >> classRemoved: anEvent [
	"obsolete - remove this later"
]

{ #category : #'initialize-release' }
MCPackageManager >> initialize [
	modified := false.
	self registerForNotifications.
]

{ #category : #'initialize-release' }
MCPackageManager >> initializeWithPackage: aPackage [
	package := aPackage inEnvironment: Environment current.
	self initialize.
]

{ #category : #'system changes' }
MCPackageManager >> methodModified: anEvent [
	"obsolete - remove this later"
]

{ #category : #'system changes' }
MCPackageManager >> methodMoved: anEvent [ 
	"obsolete - remove this later"
]

{ #category : #'system changes' }
MCPackageManager >> methodRemoved: anEvent [
	"obsolete - remove this later"
]

{ #category : #accessing }
MCPackageManager >> modified [
	^ modified
]

{ #category : #accessing }
MCPackageManager >> modified: aBoolean [
     modified = aBoolean ifTrue: [^ self].
	modified := aBoolean.
	self changed: #modified.
	
	modified ifFalse:
		[(((Smalltalk classNamed: 'SmalltalkImage') ifNotNil: [:si | si current]) ifNil: [Smalltalk])
			logChange: '"', self packageName, '"'].
]

{ #category : #accessing }
MCPackageManager >> package [
	^ package
]

{ #category : #accessing }
MCPackageManager >> packageInfo [
	^ package packageInfo
]

{ #category : #accessing }
MCPackageManager >> packageName [
	^ package name
]

{ #category : #accessing }
MCPackageManager >> packageNameWithStar [
	^ modified
		ifTrue: ['* ', self packageName]
		ifFalse: [self packageName]
]

{ #category : #'system changes' }
MCPackageManager >> registerForNotifications [
	"obsolete - remove this later"
]

{ #category : #'system changes' }
MCPackageManager >> registerForNotificationsFrom: aNotifier [
	"obsolete - remove this later"
]

{ #category : #'system changes' }
MCPackageManager >> systemChange: anEvent [
	"obsolete - remove this later"
]

{ #category : #operations }
MCPackageManager >> unregister [
	self class registry
		removeKey: package
		ifAbsent: [ "Should not complain when trying to clean up." ].
	self class changed: #allManagers
]

{ #category : #operations }
MCPackageManager >> unregisterSubpackages [
	(self class registry keys
		select: [:p | self packageName , '-*' match: p name])
		do: [:k | self class registry removeKey: k]
]

{ #category : #'system changes' }
MCPackageManager >> update: aSymbol [
	InMidstOfFileinNotification signal ifFalse: [
	[((aSymbol = #recentMethodSubmissions)
		and: [self packageInfo
				includesMethodReference: RecentMessages default mostRecent])
					ifTrue: [self modified: true]]
		on: Error do: []]
]
