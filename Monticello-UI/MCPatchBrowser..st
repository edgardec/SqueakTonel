Class {
	#name : #MCPatchBrowser,
	#superclass : #MCOperationsBrowser,
	#category : #'Monticello-UI'
}

{ #category : #'instance creation' }
MCPatchBrowser class >> forPatch: aPatch [
	^ self new patch: aPatch
]

{ #category : #styling }
MCPatchBrowser >> aboutToStyle: aStyler [ 
	
	selection ifNotNil: [
		selection isConflict ifTrue: [ ^false ].
		(selection isAddition or: [ selection isRemoval ]) ifTrue: [
			selection definition isOrganizationDefinition ifTrue: [ ^false ].
				aStyler classOrMetaClass: self selectedClassOrMetaClass.
				^true ] ].
	^false
]

{ #category : #ui }
MCPatchBrowser >> defaultLabel [
	^ 'Patch Browser'
]

{ #category : #'initialize-release' }
MCPatchBrowser >> patch: aPatch [
	items := aPatch operations sorted
]

{ #category : #ui }
MCPatchBrowser >> representsSameBrowseeAs: anotherModel [ 
	^ self class = anotherModel class
	and: [ items = anotherModel items ]
]
