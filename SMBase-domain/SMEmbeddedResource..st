"
An embedded resource is a resource that is stored inside the map. No download is needed.
This means that embedded resources should be ""small"" and typically only be used for information that
is needed to be available at all times without downloading. A typical example is meta data for other SMObjects.


"
Class {
	#name : #SMEmbeddedResource,
	#superclass : #SMResource,
	#category : #'SMBase-domain'
}

{ #category : #services }
SMEmbeddedResource >> download [
	"A dummy method to respond as other resources would."

	^true
]

{ #category : #services }
SMEmbeddedResource >> ensureInCache [
	"Makes sure the file is in the cache.
	An embedded resource doesn't have a file."

	^true
]

{ #category : #testing }
SMEmbeddedResource >> isCached [
	"Is the file corresponding to me in the local file cache?
	Well consider it as true since I am embedded in the map."

	^true
]

{ #category : #testing }
SMEmbeddedResource >> isEmbedded [
	^ true
]
