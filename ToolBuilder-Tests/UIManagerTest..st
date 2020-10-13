Class {
	#name : #UIManagerTest,
	#superclass : #TestCase,
	#category : #'ToolBuilder-Tests'
}

{ #category : #tests }
UIManagerTest >> testUiManagersAreResponsibleForProvideAnswerNotification [

	| classesUsingProvideAnswer otherValidReferences validReferences ignoredUsages |
	validReferences := {BlockClosure . UIManager . self class}.
	otherValidReferences := {ReleaseBuilder class}.
	ignoredUsages := {PopUpMenu}. "Not yet refactored"
	classesUsingProvideAnswer := ((SystemNavigation default allCallsOnClass: ProvideAnswerNotification) collect: [:m | 
		m actualClass]) asSet reject: #isDeprecated.
	self 
		assert: (validReferences , otherValidReferences , ignoredUsages) asSet
		equals: classesUsingProvideAnswer	
	
	
]
