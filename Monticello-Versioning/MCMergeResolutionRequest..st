Class {
	#name : #MCMergeResolutionRequest,
	#superclass : #Notification,
	#instVars : [
		'merger'
	],
	#category : #'Monticello-Versioning'
}

{ #category : #handling }
MCMergeResolutionRequest >> defaultAction [
	^ (MCMergeBrowser new
		merger: merger;
		label: messageText) showModally
]

{ #category : #accessing }
MCMergeResolutionRequest >> merger [
	^ merger
]

{ #category : #accessing }
MCMergeResolutionRequest >> merger: aMerger [
	merger := aMerger
]
