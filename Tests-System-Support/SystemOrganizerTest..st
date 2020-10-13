Class {
	#name : #SystemOrganizerTest,
	#superclass : #TestCase,
	#category : #'Tests-System-Support'
}

{ #category : #tests }
SystemOrganizerTest >> testAccessGlobalDirectly [
	"
	SystemOrganizerTest run: #testAccessGlobalDirectly
	"
	
	self assert: (SystemOrganization isKindOf: SystemOrganizer).	
			
	"It really lives in Smalltalk (another global)"
	self assert: ((Smalltalk at: #SystemOrganization) == SystemOrganization).
]

{ #category : #tests }
SystemOrganizerTest >> testAccessGlobalThroughClass [
	"
	SystemOrganizerTest run: #testAccessGlobalThroughClass
	"
		
	"In case someone stumbles upon the SystemOrganizer class, and does not know
	about the SystemNavigation global, it can be accessed from there, too."
	self assert: (SystemOrganizer default == SystemOrganization).

]
