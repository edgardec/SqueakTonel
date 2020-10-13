"
This is a wrapper for showing the SqueakMap package releases (SMPackageRelease) using the SimpleHierarchicalListMorph in the SMLoader, see SMPackageWrapper>>contents.
"
Class {
	#name : #SMPackageReleaseWrapper,
	#superclass : #ListItemWrapper,
	#category : #SMLoader
}

{ #category : #converting }
SMPackageReleaseWrapper >> asString [
	"Show installed releases with a trailing asterisk."
	| string |
	string := item smartVersion.
	"Older SMBase versions don't have isInstalled.'"
	(item respondsTo: #isInstalled) ifTrue:
		[item isInstalled ifTrue: [string := (string , ' *') asText allBold]].
	^ string
]

{ #category : #accessing }
SMPackageReleaseWrapper >> contents [
	^ #()
]

{ #category : #accessing }
SMPackageReleaseWrapper >> label [
	^ self asString
	
]
