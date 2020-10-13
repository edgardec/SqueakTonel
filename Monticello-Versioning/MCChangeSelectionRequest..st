Class {
	#name : #MCChangeSelectionRequest,
	#superclass : #Notification,
	#instVars : [
		'patch',
		'label'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #handling }
MCChangeSelectionRequest >> defaultAction [
	^ (MCChangeSelector forPatch: patch)
		 label: label ;
		 showModally
]

{ #category : #accessing }
MCChangeSelectionRequest >> label [
	^ label
]

{ #category : #accessing }
MCChangeSelectionRequest >> label: aString [
	label := aString
]

{ #category : #accessing }
MCChangeSelectionRequest >> patch [
	^ patch
]

{ #category : #accessing }
MCChangeSelectionRequest >> patch: aPatch [
	patch := aPatch
]
