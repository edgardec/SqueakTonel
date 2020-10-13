Class {
	#name : #MCFileRepositoryInspector,
	#superclass : #MCRepositoryInspector,
	#instVars : [
		'allVersionNames'
	],
	#category : #'Monticello-UI'
}

{ #category : #private }
MCFileRepositoryInspector >> allVersionNames [
	^ allVersionNames ifNil:
		[ self initializeVersionNames.
		allVersionNames ]
]

{ #category : #private }
MCFileRepositoryInspector >> initializeVersionNames [
	repository cacheAllFileNamesDuring:
		[ super initializeVersionNames.
		allVersionNames := repository readableFileNames ]
]

{ #category : #'morphic ui' }
MCFileRepositoryInspector >> refresh [
	allVersionNames := nil.
	super refresh
]

{ #category : #private }
MCFileRepositoryInspector >> versionInfo [
	^ versionInfo ifNil: [versionInfo := repository versionInfoFromFileNamed: selectedVersion]
]

{ #category : #private }
MCFileRepositoryInspector >> versionNamesForNoPackageSelection [
	^ self allVersionNames
]

{ #category : #private }
MCFileRepositoryInspector >> versionNamesForSelectedPackage [
	^ self allVersionNames select:
		(self class browseBranchedVersionsSeparately
			ifTrue: [[:each| each packageAndBranchName = selectedPackage]]
			ifFalse: [[:each| each packageName = selectedPackage]])
]

{ #category : #private }
MCFileRepositoryInspector >> versionSelection: aNumber [ 
	versionInfo := nil.
	super versionSelection: aNumber
]

{ #category : #'morphic ui' }
MCFileRepositoryInspector >> versionSummary [
	^ version
		ifNotNil: [version summary]
		ifNil: [self versionInfo summary]
]
