"
ProjectViewOpenNotification is signalled to determine if a ProjectViewMorph is needed for a newly created project. The default answer is yes.
"
Class {
	#name : #ProjectViewOpenNotification,
	#superclass : #Notification,
	#category : #'System-Exceptions'
}

{ #category : #handling }
ProjectViewOpenNotification >> defaultAction [

	self resume: true
]
