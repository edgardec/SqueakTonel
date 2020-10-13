"
URLs that instruct a browser to do something.
"
Class {
	#name : #BrowserUrl,
	#superclass : #GenericUrl,
	#category : #'Network-Url'
}

{ #category : #downloading }
BrowserUrl >> hasContents [
	^true
]

{ #category : #downloading }
BrowserUrl >> retrieveContentsForBrowser: aBrowser [
	^aBrowser browserUrlContents: locator
]
