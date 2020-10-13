Class {
	#name : #PackageOrganizer,
	#superclass : #Object,
	#instVars : [
		'packages'
	],
	#classInstVars : [
		'default'
	],
	#category : #'PackageInfo-Base'
}

{ #category : #'initialize-release' }
PackageOrganizer class >> cleanUp: aggressive [

	aggressive ifTrue: [self default flushEmptyPackages].
]

{ #category : #accessing }
PackageOrganizer class >> default [
	^ default ifNil: [default := self new]
]

{ #category : #registering }
PackageOrganizer >> flushEmptyPackages [

	self flushObsoletePackages: [:package |
		package classes isEmpty and: [package methods isEmpty]].
]

{ #category : #registering }
PackageOrganizer >> flushObsoletePackages: aBlock [
	"Flush all packages considered obsolete by evaluating the argument block."

	packages keys do:[:key|
		(aBlock value: (packages at: key)) ifTrue:[packages removeKey: key].
	].
	self changed: #packages; changed: #packageNames.
]

{ #category : #initializing }
PackageOrganizer >> initialize [
	packages := Dictionary new
]

{ #category : #searching }
PackageOrganizer >> noPackageFound [
	self error: 'No package found'
]

{ #category : #searching }
PackageOrganizer >> packageNamed: aString ifAbsent: errorBlock [
	^ packages at: aString ifAbsent: errorBlock
]

{ #category : #searching }
PackageOrganizer >> packageNamed: aString ifPresent: aBlock [
	^ packages at: aString ifPresent: aBlock
]

{ #category : #searching }
PackageOrganizer >> packageNamed: aString ifPresent: aBlock ifAbsent: errorBlock [
	^ packages at: aString ifPresent: aBlock ifAbsent: errorBlock
]

{ #category : #accessing }
PackageOrganizer >> packageNames [
	^ packages keys
]

{ #category : #searching }
PackageOrganizer >> packageOfClass: aClass [
	^ self packageOfClass: aClass ifNone: [self noPackageFound]
]

{ #category : #searching }
PackageOrganizer >> packageOfClass: aClass ifNone: errorBlock [
	^ self packages detect: [:ea | ea includesClass: aClass] ifNone: errorBlock
]

{ #category : #searching }
PackageOrganizer >> packageOfMethod: aMethodReference [
	^ self packageOfMethod: aMethodReference ifNone: [self noPackageFound]
]

{ #category : #searching }
PackageOrganizer >> packageOfMethod: aMethodReference ifNone: errorBlock [
	^ self packages detect: [:ea | ea includesMethodReference: aMethodReference] ifNone: errorBlock
]

{ #category : #searching }
PackageOrganizer >> packageOfMethodCategory: categoryName ofClass: aClass [
	^self packageOfMethodCategory: categoryName ofClass: aClass ifNone: [ self noPackageFound ]

]

{ #category : #searching }
PackageOrganizer >> packageOfMethodCategory: categoryName ofClass: aClass ifNone: errorBlock [
	^ self packages detect: [:ea | ea includesMethodCategory: categoryName ofClassNamed: aClass name] ifNone: errorBlock
	
	

]

{ #category : #searching }
PackageOrganizer >> packageOfSystemCategory: aSystemCategory [
	^ self packageOfSystemCategory: aSystemCategory ifNone: [ self noPackageFound ]

]

{ #category : #searching }
PackageOrganizer >> packageOfSystemCategory: aSystemCategory ifNone: errorBlock [
	^ self packages detect: [:ea | ea includesSystemCategory: aSystemCategory] ifNone: errorBlock

]

{ #category : #accessing }
PackageOrganizer >> packages [
	^ packages values
]

{ #category : #registering }
PackageOrganizer >> registerPackage: aPackageInfo [
	packages at: aPackageInfo packageName put: aPackageInfo.
	self changed: #packages; changed: #packageNames.

]

{ #category : #registering }
PackageOrganizer >> registerPackageNamed: aString [
	^ self registerPackage: (PackageInfo named: aString)
]

{ #category : #registering }
PackageOrganizer >> unregisterPackage: aPackageInfo [
	packages removeKey: aPackageInfo packageName ifAbsent: [].	
	self changed: #packages; changed: #packageNames.

]

{ #category : #registering }
PackageOrganizer >> unregisterPackageNamed: aString [
	self unregisterPackage: (self packageNamed: aString ifAbsent: [^ self])
]
