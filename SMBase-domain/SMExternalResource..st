"
An external resource is a downloadable resource.
The instance variable downloadUrl holds the URL to the resource and the resource is cacheable in the FileCache for the SqueakMap.
An external resource can be used for any kind of document that is to be attached to another SMObject.
"
Class {
	#name : #SMExternalResource,
	#superclass : #SMResource,
	#instVars : [
		'downloadUrl'
	],
	#category : #'SMBase-domain'
}

{ #category : #accessing }
SMExternalResource >> cacheDirectory [
	^ map cache directoryForResource: self
]

{ #category : #accessing }
SMExternalResource >> contents [
	"Return the contents of a stream from the downloaded resource.
	Not yet tested, this resource returns the stream and not its contents."

	map cache add: self.
	^(self cacheDirectory readOnlyFileNamed: self downloadFileName) binary; yourself
]

{ #category : #services }
SMExternalResource >> download [
	"Force a download into the cache regardless if it is already there."

	^map cache download: self
]

{ #category : #accessing }
SMExternalResource >> downloadFileName [
	"Cut out the filename from the url."

	downloadUrl isEmpty ifTrue: [^nil].
	^downloadUrl asUrl path last
]

{ #category : #accessing }
SMExternalResource >> downloadUrl [
	^ downloadUrl
]

{ #category : #accessing }
SMExternalResource >> downloadUrl: anUrl [
	downloadUrl := anUrl
]

{ #category : #services }
SMExternalResource >> ensureInCache [
	"Makes sure the file is in the cache."

	^map cache add: self
]

{ #category : #testing }
SMExternalResource >> isCached [
	"Is the file corresponding to me in the local file cache?"

	^map cache includes: self
]

{ #category : #accessing }
SMExternalResource >> isDownloadable [
	"Answer if I can be downloaded.
	We simply verify that the download url
	ends with a filename."

	^self downloadFileName isEmptyOrNil not
]
