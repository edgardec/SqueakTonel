"
a URL type that can't be broken down in any systematic way.  For example, mailto: and telnet: URLs.  The part after the scheme name is stored available via the #locator message.
"
Class {
	#name : #GenericUrl,
	#superclass : #Url,
	#instVars : [
		'schemeName',
		'locator'
	],
	#category : #'Network-Url'
}

{ #category : #parsing }
GenericUrl class >> absoluteFromText: aString [
	| schemeName locator |
	schemeName := Url schemeNameForString: aString.
	schemeName ifNil: [ ^self schemeName: 'xnoscheme' locator: aString ].
	locator := aString copyFrom: (schemeName size + 2) to: aString size.
	^self schemeName: schemeName locator: locator
]

{ #category : #'instance creation' }
GenericUrl class >> schemeName: schemeName  locator: locator [
	^self new schemeName: schemeName  locator: locator
]

{ #category : #access }
GenericUrl >> locator [
	^locator
]

{ #category : #printing }
GenericUrl >> printOn: aStream [

	aStream nextPutAll: self schemeName.
	aStream nextPut: $:.
	aStream nextPutAll: self locator.

	self fragment ifNotNil:
		[aStream nextPut: $#.
		aStream nextPutAll: self fragment].
]

{ #category : #parsing }
GenericUrl >> privateInitializeFromText: aString [
	schemeName := Url schemeNameForString: aString.
	schemeName ifNil: [ self error: 'opaque URL with no scheme--shouldn''t happen!'. ].
	locator := aString copyFrom: (schemeName size+2) to: aString size.
]

{ #category : #parsing }
GenericUrl >> privateInitializeFromText: aString relativeTo: aUrl [
	schemeName := aUrl schemeName.
	locator := aString.
]

{ #category : #classification }
GenericUrl >> scheme [
	^ self schemeName.
]

{ #category : #access }
GenericUrl >> schemeName [
	^schemeName
]

{ #category : #private }
GenericUrl >> schemeName: schemeName0  locator: locator0 [
	schemeName := schemeName0.
	locator := locator0.
]
