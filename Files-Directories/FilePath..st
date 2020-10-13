"
This class absorb the difference of internal and external representation of the file path.  The idea is to keep the internal one as much as possible, and only when it goes to a primitive, the encoded file path, i.e. the native platform representation is passsed to the primitive.

	The converter used is obtained by ""LanguageEnvironment defaultFileNameConverter"".

"
Class {
	#name : #FilePath,
	#superclass : #Object,
	#instVars : [
		'squeakPathName',
		'vmPathName',
		'converter'
	],
	#category : #'Files-Directories'
}

{ #category : #accessing }
FilePath class >> classVersion [

	^ 1.

]

{ #category : #'instance creation' }
FilePath class >> pathName: pathName [

	^ self pathName: pathName isEncoded: false.

]

{ #category : #'instance creation' }
FilePath class >> pathName: pathName isEncoded: aBoolean [

	^ (self new) pathName: pathName isEncoded: aBoolean; yourself.

]

{ #category : #conversion }
FilePath >> asSqueakPathName [

	^ self pathName.

]

{ #category : #conversion }
FilePath >> asString [
	^self asSqueakPathName
]

{ #category : #conversion }
FilePath >> asVmPathName [

	^ vmPathName.

]

{ #category : #'file in\/out' }
FilePath >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	"If we're reading in an old version with a system path instance variable, convert it to a vm path."

	varDict at: 'systemPathName' ifPresent: [ :x | 
		vmPathName := x.
	].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.

]

{ #category : #conversion }
FilePath >> converter: aTextConverter [

	converter class ~= aTextConverter class ifTrue: [
		converter := aTextConverter.
		vmPathName := squeakPathName convertToWithConverter: converter
	].

]

{ #category : #'file in\/out' }
FilePath >> copySystemToVm [

	(self class instVarNames includes: 'systemPathName') ifTrue: [
		vmPathName := self instVarNamed: 'systemPathName'.
	].


]

{ #category : #testing }
FilePath >> isNullPath [
	"an empty path is used to represent the root path(s) when calling the primitive to list directory entries. Some users need to check for this and this is cleaner than grabbing the pathname and assuming it is a plain String"
	^self pathName isEmpty
]

{ #category : #conversion }
FilePath >> pathName [

	^ squeakPathName.

]

{ #category : #conversion }
FilePath >> pathName: p isEncoded: isEncoded [

	converter := LanguageEnvironment defaultFileNameConverter.
	isEncoded ifTrue: [
		squeakPathName := p convertFromWithConverter: converter.
		vmPathName := p.
	] ifFalse: [
		squeakPathName := p isOctetString ifTrue: [p asOctetString] ifFalse: [p].
		vmPathName := squeakPathName convertToWithConverter: converter.
	].

]

{ #category : #conversion }
FilePath >> printOn: aStream [

	aStream nextPutAll: 'FilePath('''.
	aStream nextPutAll: squeakPathName.
	aStream nextPutAll: ''')'.

]
