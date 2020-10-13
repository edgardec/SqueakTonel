"
An input field for <INPUT TYPE=""file"">
Support for uploading files using HTTP/multipart forms
Appearance/behavior as in NS/MS browsers
(i.e., separate filename entry box and browse files button)
"
Class {
	#name : #FileInput,
	#superclass : #TextInput,
	#category : #'Etoys-Squeakland-Network-HTML-Forms'
}

{ #category : #'instance creation' }
FileInput class >> name: aString textMorph: aTextMorph [
	^self name: aString defaultValue: '' textMorph: aTextMorph
]

{ #category : #accessing }
FileInput >> browse [
	| fileName |
	fileName := (FileChooserDialog openOn: self directory) ifNil: [^nil].

	textMorph setText: fileName;
		hasUnacceptedEdits: true;
		accept
]

{ #category : #accessing }
FileInput >> directory [
	^FileDirectory forFileName: self filename
]

{ #category : #accessing }
FileInput >> filename [
	textMorph hasUnacceptedEdits ifTrue: [ textMorph accept ].
	^textMorph getText asString withInternetLineEndings
]

{ #category : #accessing }
FileInput >> localFilename [
	^FileDirectory localNameFor: self filename
]

{ #category : #accessing }
FileInput >> url [
	^FileUrl pathParts: ((self directory pathParts) copyWith: self localFilename)
]

{ #category : #accessing }
FileInput >> value [
	^MIMEDocument contentType: (MIMEDocument guessTypeFromName: self filename)
		content: nil
		url: self url
]
