Class {
	#name : #MCPreambleDefinition,
	#superclass : #MCScriptDefinition,
	#category : #'Monticello-Modeling'
}

{ #category : #'private - instance creation' }
MCPreambleDefinition class >> scriptSelector [
	^ #preamble
]

{ #category : #installing }
MCPreambleDefinition >> load [
	super load.
	self evaluate
]
