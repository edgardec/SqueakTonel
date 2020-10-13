Class {
	#name : #MCRemovalPostscriptDefinition,
	#superclass : #MCScriptDefinition,
	#category : #'Monticello-Modeling'
}

{ #category : #'private - instance creation' }
MCRemovalPostscriptDefinition class >> scriptSelector [
	^ #postscriptOfRemoval 
]

{ #category : #installing }
MCRemovalPostscriptDefinition >> unload [
	super unload.
	self evaluate
]
