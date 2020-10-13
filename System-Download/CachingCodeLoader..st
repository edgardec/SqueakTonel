Class {
	#name : #CachingCodeLoader,
	#superclass : #CodeLoader,
	#instVars : [
		'cacheDir'
	],
	#category : #'System-Download'
}

{ #category : #accessing }
CachingCodeLoader >> cacheDir [
	^cacheDir
]

{ #category : #accessing }
CachingCodeLoader >> cacheDir: aString [
	cacheDir := aString.
]

{ #category : #private }
CachingCodeLoader >> createRequestFor: name in: aLoader [
	| request |
	request := super createRequestFor: name in: aLoader.
	request cachedName: cacheDir, name.
	^request
]

{ #category : #private }
CachingCodeLoader >> httpRequestClass [
	^CachedHTTPDownloadRequest

]

{ #category : #accessing }
CachingCodeLoader >> localCache: stringArray [
	| fd |
	fd := FileDirectory default.
	stringArray do:[:part|
		(fd directoryNames includes: part) 
			ifFalse:[fd createDirectory: part].
		fd := fd directoryNamed: part].
	self cacheDir: (fd pathName copyWith: fd pathNameDelimiter).
]

{ #category : #accessing }
CachingCodeLoader >> localCacheDir: aString [
	self cacheDir:
		(FileDirectory default pathName,
		FileDirectory slash,
		aString,
		FileDirectory slash)
]
