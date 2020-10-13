Class {
	#name : #MCRemovalPreambleDefinition,
	#superclass : #MCScriptDefinition,
	#category : #'Monticello-Modeling'
}

{ #category : #'private - instance creation' }
MCRemovalPreambleDefinition class >> scriptSelector [
	^ #preambleOfRemoval
]

{ #category : #accessing }
MCRemovalPreambleDefinition >> sortKey [
	^ 'zzz' "force to the end so it gets unloaded early"
]

{ #category : #installing }
MCRemovalPreambleDefinition >> unload [
	super unload.
	self evaluate
]

{ #category : #testing }
MCRemovalPreambleDefinition >> wantsToBeOutermost [

	^ true
]
