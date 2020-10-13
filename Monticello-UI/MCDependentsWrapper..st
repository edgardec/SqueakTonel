Class {
	#name : #MCDependentsWrapper,
	#superclass : #ListItemWrapper,
	#category : #'Monticello-UI'
}

{ #category : #converting }
MCDependentsWrapper >> asString [
	^item description
]

{ #category : #accessing }
MCDependentsWrapper >> contents [
	| list workingCopies |
	workingCopies := model unsortedWorkingCopies.
	list := item requiredPackages collect: 
					[:each | 
					workingCopies detect: [:wc | wc package = each] ifNone: [nil]]
				thenSelect: [:x | x notNil].
	^list collect: [:each | self class with: each model: model]
]

{ #category : #testing }
MCDependentsWrapper >> hasContents [
	^item requiredPackages isEmpty not
]

{ #category : #accessing }
MCDependentsWrapper >> item [
	^item
]
