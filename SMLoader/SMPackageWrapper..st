"
This is a wrapper for showing the SqueakMap packages (SMPackage) using the SimpleHierarchicalListMorph in the SMLoader, see SMLoader>>packageWrapperList.
"
Class {
	#name : #SMPackageWrapper,
	#superclass : #ListItemWrapper,
	#category : #SMLoader
}

{ #category : #comparing }
SMPackageWrapper >> = anObject [
	^self withoutListWrapper = anObject withoutListWrapper
]

{ #category : #converting }
SMPackageWrapper >> asString [
	| string |
	string := item name, ' (', item versionLabel, ')'.
	item isInstalled ifTrue: [string := string asText allBold].
	"(string includesSubString: '->') ifTrue: [string := string asText color: Color green]."
	^ string
]

{ #category : #accessing }
SMPackageWrapper >> contents [
	^item releases reversed collect: [:e | SMPackageReleaseWrapper with: e]
]

{ #category : #testing }
SMPackageWrapper >> hash [
	^self withoutListWrapper hash
]

{ #category : #accessing }
SMPackageWrapper >> help [
	^ 'This shows all packages with their releases that should be displayed according the current filter.'
]

{ #category : #accessing }
SMPackageWrapper >> label [
	^ self asString
]

{ #category : #printing }
SMPackageWrapper >> printOn: aStream [
	aStream nextPutAll: 'wrapper for: ', item printString
]
