"
An SMDocument refers typically to a piece of digital information accessible through a URL. :-)
This means it can be downloaded and cached.

The instvar description describes the document and instvar author references the name and/or email of the original author.

SMDocument has one subclasses - SMPackage. Since SqueakMap is primarily meant for
keeping track of installable source packages of Squeak software, a specific subclass handles those.
"
Class {
	#name : #SMDocument,
	#superclass : #SMMaintainableObject,
	#instVars : [
		'description',
		'author'
	],
	#category : #'SMBase-domain'
}

{ #category : #accessing }
SMDocument >> author [
	^author
]

{ #category : #accessing }
SMDocument >> author: aString [
	author := aString
]

{ #category : #accessing }
SMDocument >> description [
	^description
]

{ #category : #accessing }
SMDocument >> description: aString [
	description := aString
]

{ #category : #cache }
SMDocument >> ensureInCache [
	"Makes sure the file is in the cache."

	self subclassResponsibility 
]

{ #category : #'initialize-release' }
SMDocument >> initialize [

	super initialize.
	description := author := ''
]

{ #category : #cache }
SMDocument >> isCached [
	"Is the file corresponding to me in the local file cache?"

	self subclassResponsibility 
]

{ #category : #testing }
SMDocument >> isDownloadable [
	"Answer if I can be downloaded.
	Default is false."
	
	^ false
	
	

]
