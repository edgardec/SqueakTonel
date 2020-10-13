"
A MCVersionName models the Monticello file / version name, in the format [Package]-[Author].[version-number]([ancestorAuthor.ancestorVersionNumber]).[mc?].

Any file-extension, if present, is ignored.
"
Class {
	#name : #MCVersionName,
	#superclass : #ByteString,
	#type : #bytes,
	#category : #'Monticello-Modeling'
}

{ #category : #'instance creation' }
MCVersionName class >> on: aString [ 
	"aString may be with or without a mc? extension."
	^ (self new: aString size)
		replaceFrom: 1
			to: aString size
			with: aString
			startingAt: 1 ;
		yourself
]

{ #category : #comparing }
MCVersionName >> = aByteString [ 
	"Ignore any file-extension for comparison of MCVersionNames."
	| myVersionName |
	aByteString isString ifFalse: [ ^ false ].
	myVersionName := self versionName.
	^ (myVersionName
		compare: myVersionName
		with: aByteString asMCVersionName versionName
		collated: AsciiOrder) = 2
]

{ #category : #converting }
MCVersionName >> asMCVersionName [
	^ self
]

{ #category : #accessing }
MCVersionName >> author [
	"The author initials embedded in the filename."
	
	^(self versionName copyAfterLast: $-) copyUpTo: $.
]

{ #category : #accessing }
MCVersionName >> baseVersionName [
	"The version name of our ancestor, if this is a Diffy filename."

	^(MCDiffyVersion baseNameFrom: (self copyUpThrough: $))) asMCVersionName
]

{ #category : #comparing }
MCVersionName >> hash [
	^ self versionName hash
]

{ #category : #testing }
MCVersionName >> isValid [
	^ [ (self endsWith: '.mcm') or:
		[ self packageName notEmpty and:
			[ self author notEmpty and: [ self versionNumber > 0 ] ] ] ]
		on: Error
		do:
			[ : err | false ]
]

{ #category : #accessing }
MCVersionName >> packageAndBranchName [
	"The MC package name, possibly with branch name, embedded into this filename."
	
	^self versionName copyUpToLast: $-
]

{ #category : #accessing }
MCVersionName >> packageName [
	"The MC Package name embedded into this filename."
	
	^self packageAndBranchName copyUpTo: $.
]

{ #category : #private }
MCVersionName >> species [
	^ ByteString
]

{ #category : #accessing }
MCVersionName >> versionName [
	"Answer my version name as a ByteString, without the file suffix or any ancestor-attributes."
	| end |
	self isEmpty ifTrue: [^ String empty]. 
	end := self indexOf: $( ifAbsent: [
		| size |
		size := self size.
		(size > 4 
			and: [ (self at: size - 3) == $.
			and: [ (self at: size - 2) == $m
			and: [ (self at: size - 1) == $c ] ] ])
				ifTrue: [size - 3]
				ifFalse: [size + 1]].
	^self first: end - 1
]

{ #category : #accessing }
MCVersionName >> versionNumber [
	"The Integer version number identified by this filename."
	| v |
	v := (self versionName copyAfterLast: $-) copyAfter: $..
	^(v notEmpty and: [v first isDigit])
		ifTrue: [ v asInteger ]
	 	ifFalse: [ 0 ]
]
