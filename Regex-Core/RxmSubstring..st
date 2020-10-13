"
-- Regular Expression Matcher v 1.1 (C) 1996, 1999 Vassili Bykov
--
Instance holds onto a string and matches exactly this string, and exactly once.

Instance variables:
	string 	<String>
"
Class {
	#name : #RxmSubstring,
	#superclass : #RxmLink,
	#instVars : [
		'sampleStream',
		'ignoreCase'
	],
	#category : #'Regex-Core'
}

{ #category : #initialization }
RxmSubstring >> initialize [

	super initialize.
	ignoreCase := false
]

{ #category : #matching }
RxmSubstring >> matchAgainst: aMatcher [
	"Match if my sample stream is exactly the current prefix
	of the matcher stream's contents."

	sampleStream reset.
	ignoreCase ifFalse: [ ^aMatcher matchCaseSensitiveAgainstStream: sampleStream nextLink: next ].
	^aMatcher matchCaseInsensitiveAgainstStream: sampleStream nextLink: next
]

{ #category : #copying }
RxmSubstring >> postCopy [

	super postCopy.
	sampleStream := sampleStream copy
]

{ #category : #copying }
RxmSubstring >> postCopyUsing: anIdentityDictionary [

	super postCopyUsing: anIdentityDictionary.
	sampleStream := sampleStream copy
]

{ #category : #'initialize-release' }
RxmSubstring >> substring: aString ignoreCase: aBoolean [
	"Match exactly this string."

	sampleStream := aString readStream.
	ignoreCase := aBoolean
]
