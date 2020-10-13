Class {
	#name : #MCMockPackageInfo,
	#superclass : #PackageInfo,
	#category : #'Tests-Monticello-Utils'
}

{ #category : #'as yet unclassified' }
MCMockPackageInfo class >> cleanUp: aggressive [
	aggressive ifTrue: [self initialize].
]

{ #category : #'as yet unclassified' }
MCMockPackageInfo class >> initialize [
	[self new register] on: MessageNotUnderstood do: []
]

{ #category : #constants }
MCMockPackageInfo >> classNames [
	^ #(	MCMockClassA
		 	MCMockASubclass
			MCMockClassB
			MCMockClassD
			MCMockClassE
			MCMockClassF
			MCMockClassG
			MCMockClassH
			MCMockClassI
		)
]

{ #category : #listing }
MCMockPackageInfo >> classes [
	^ self classNames 
		select: [:name | Smalltalk hasClassNamed: name]
		thenCollect: [:name | Smalltalk at: name]
]

{ #category : #listing }
MCMockPackageInfo >> extensionMethods [
	^ Array with: (MethodReference 
					class: MCSnapshotTest 
					selector: #mockClassExtension)
]

{ #category : #testing }
MCMockPackageInfo >> includesClass: aClass [
	^self classes includes: aClass
]

{ #category : #testing }
MCMockPackageInfo >> includesSystemCategory: categoryName [
	^self systemCategories anySatisfy: [:cat | cat sameAs: categoryName]
]

{ #category : #naming }
MCMockPackageInfo >> packageName [
	^ 'MonticelloMocks'
]

{ #category : #listing }
MCMockPackageInfo >> systemCategories [
	^ Array with: 'Tests-MonticelloMocks'
]
