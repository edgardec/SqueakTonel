Class {
	#name : #TTCFontDescription,
	#superclass : #TTFontDescription,
	#classVars : [
		'TTCDefault',
		'TTCDescriptions'
	],
	#category : #'TrueType-Fonts'
}

{ #category : #'instance creations' }
TTCFontDescription class >> addFromTTFile: fileName [
"
	Execute the following only if you know what you are doing.
	self addFromTTFile: 'C:\WINDOWS\Fonts\msgothic.TTC'
"

	| tt |
	(fileName asLowercase endsWith: 'ttf') ifTrue: [
		tt := TTCFontReader readTTFFrom: (FileStream readOnlyFileNamed: fileName).
	] ifFalse: [
		tt := TTCFontReader readFrom: (FileStream readOnlyFileNamed: fileName).
	].

	self addToDescription: tt.
	^ tt.

]

{ #category : #accessing }
TTCFontDescription class >> descriptionNamed: descriptionName at: index [

	| array |
	(array :=  self descriptionNamed: descriptionName) ifNil: [^ nil].
	^ array at: index.

]

{ #category : #accessing }
TTCFontDescription >> at: aCharOrInteger [

	| char |
	char := aCharOrInteger asCharacter.
	^ glyphs at: (char charCode) + 1.

]

{ #category : #copying }
TTCFontDescription >> deepCopy [

	^ self.

]

{ #category : #'objects from disk' }
TTCFontDescription >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a reference to a known Font in the other system instead.  "

	"A path to me"
	(TextConstants at: #forceFontWriting ifAbsent: [false]) ifTrue: [^ self].
		"special case for saving the default fonts on the disk.  See collectionFromFileNamed:"

	dp := DiskProxy global: #TTCFontDescription selector: #descriptionNamed:at:
			args: {self name. ((TTCFontDescription descriptionNamed: self name) indexOf: self)}.
	refStrm replace: self with: dp.
	^ dp.

]

{ #category : #accessing }
TTCFontDescription >> size [

	^ glyphs size.

]
