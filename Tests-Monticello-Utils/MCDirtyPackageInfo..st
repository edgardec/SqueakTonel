Class {
	#name : #MCDirtyPackageInfo,
	#superclass : #PackageInfo,
	#category : #'Tests-Monticello-Utils'
}

{ #category : #'as yet unclassified' }
MCDirtyPackageInfo class >> initialize [
	[self new register] on: MessageNotUnderstood do: []
]

{ #category : #'as yet unclassified' }
MCDirtyPackageInfo class >> wantsChangeSetLogging [
	^ false
]

{ #category : #listing }
MCDirtyPackageInfo >> classes [
	^ Array new: 0.
]

{ #category : #listing }
MCDirtyPackageInfo >> methods [
	^ MCMockClassA selectors
		select: [:ea | ea beginsWith: 'ordinal']
		thenCollect:
			[:ea | 
				MethodReference 
					class: MCMockClassA 
					selector: ea].
]

{ #category : #naming }
MCDirtyPackageInfo >> packageName [
	^ 'MCDirtyPackage'
]
