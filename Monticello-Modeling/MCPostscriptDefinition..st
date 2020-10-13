Class {
	#name : #MCPostscriptDefinition,
	#superclass : #MCScriptDefinition,
	#category : #'Monticello-Modeling'
}

{ #category : #'private - instance creation' }
MCPostscriptDefinition class >> scriptSelector [
	^ #postscript
]

{ #category : #installing }
MCPostscriptDefinition >> postload [
	self evaluate
]

{ #category : #accessing }
MCPostscriptDefinition >> sortKey [
	^ 'zzz' "force to the end so it gets loaded late"
]

{ #category : #nil }
MCPostscriptDefinition >> wantsToBeOutermost [

	^ true
]
