"
MethodChangeRecords are used to record method changes.  Here is a simple summary of the relationship between the changeType symbol and the recording of prior state

			|	prior == nil			|	prior not nil	
	---------	|----------------------------	|--------------------
	add		|	add					|	change
	---------	|----------------------------	|--------------------
	remove	|	addedThenRemoved	|	remove

Structure:
changeType			symbol -- as summarized above
currentMethod	method
				This is the current version of the method.
				It can be used to assert this change upon entry to a layer. 
infoFromRemoval -- an array of size 2.
				The first element is the source index of the last version of the method.
				The second element is the category in which it was defined, so it
				can be put back there if re-accepted from a version browser.

Note that the above states each have an associated revoke action:
	add --> remove
	change --> change back
	remove --> add back
	addedThenRemoved --> no change
However all of these are accomplished trivially by restoring the original method dictionary.
"
Class {
	#name : #MethodChangeRecord,
	#superclass : #Object,
	#instVars : [
		'changeType',
		'currentMethod',
		'infoFromRemoval'
	],
	#category : #'System-Changes'
}

{ #category : #accessing }
MethodChangeRecord >> changeType [

	^ changeType
]

{ #category : #accessing }
MethodChangeRecord >> currentMethod [

	^ currentMethod
]

{ #category : #'method changes' }
MethodChangeRecord >> methodInfoFromRemoval [
	"Return an array with the source index of the last version of the method,
	and the category in which it was defined (so it can be put back there if
	re-accepted from a version browser)."

	(changeType == #remove or: [changeType == #addedThenRemoved])
		ifTrue: [^ infoFromRemoval]
		ifFalse: [^ nil]
]

{ #category : #'all changes' }
MethodChangeRecord >> noteChangeType: newChangeType [

	(changeType == #addedThenRemoved and: [newChangeType == #change])
		ifTrue: [changeType := #add]
		ifFalse: [changeType := newChangeType]
]

{ #category : #'method changes' }
MethodChangeRecord >> noteMethodInfoFromRemoval: info [
	"Store an array with the source index of the last version of the method,
	and the category in which it was defined (so it can be put back there if
	re-accepted from a version browser)."

	infoFromRemoval := info
]

{ #category : #'method changes' }
MethodChangeRecord >> noteNewMethod: newMethod [
	"NEVER do this. It is evil."
	currentMethod := nil.
]

{ #category : #printing }
MethodChangeRecord >> printOn: strm [

	super printOn: strm.
	strm nextPutAll: ' ('; print: changeType; nextPutAll: ')'
]

{ #category : #'method changes' }
MethodChangeRecord >> priorMethod: ignored [

	"We do not save original versions of changed methods because we only
	revoke changes at the level of entire classes, and that is done by
	restoration of the entire methodDictionary."
]

{ #category : #'objects from disk' }
MethodChangeRecord >> storeDataOn: aDataStream [
	| oldMethod |
	oldMethod := currentMethod.
	currentMethod := nil.
	super storeDataOn: aDataStream.
	currentMethod := oldMethod.

]
