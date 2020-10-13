"
A resource is a document that is NOT a package. Thus, it is used for all the things interesting to register on SM that aren't packages. The are three major differences with resources:

- A resource keeps no track of version history like packages do with package releases. It only has a field for the current version.
- A resource can be embedded inside the map instead of being a document reached by a URL.
- A resource can be associated with another SMObject, the instvar object.

However, resources respond to some of the same actions as PackageReleases.
"
Class {
	#name : #SMResource,
	#superclass : #SMPersonalObject,
	#instVars : [
		'object',
		'version'
	],
	#category : #'SMBase-domain'
}

{ #category : #'instance creation' }
SMResource class >> forString: aString [
	^ SMEmbeddedResource new content: aString
]

{ #category : #'instance creation' }
SMResource class >> forUrl: anUrl [
	^ SMExternalResource new downloadUrl: anUrl; yourself
]

{ #category : #testing }
SMResource >> isConfiguration [
	^ false
]

{ #category : #testing }
SMResource >> isEmbedded [
	^false
]

{ #category : #testing }
SMResource >> isResource [
	^ true
]

{ #category : #accessing }
SMResource >> object [
	^object
]

{ #category : #accessing }
SMResource >> object: anSMCategorizableObject [
	object := anSMCategorizableObject
]

{ #category : #accessing }
SMResource >> version [
	^ version
]

{ #category : #accessing }
SMResource >> version: aVersion [
	version := aVersion
]
