"
TextAnchors support anchoring of images in text. A TextAnchor exists as an attribute of text emphasis. Depending on whether its anchoredMorph is a Morph or a Form, it repositions the morph, or displays the form respectively.  The coordination between composition, display, and selection can best be understood by browsing the various implementations of placeEmbeddedObjectFrom:.

In the morphic world, you can embed any form or morph in text by adding a startOfHeader character and adding the TextAnchor attribute to it.

	Workspace new
		contents: (Text withAll: 'foo') , (Text string: Character startOfHeader asString attribute: (TextAnchor new anchoredMorph: MenuIcons confirmIcon)) , (Text withAll: 'bar');
		openLabel: 'Text with Form'.

	Workspace new
		contents: (Text withAll: 'foo') , (Text string: Character startOfHeader asString attribute: (TextAnchor new anchoredMorph: EllipseMorph new)) , (Text withAll: 'bar');
		openLabel: 'Text with Morph'.
"
Class {
	#name : #TextAnchor,
	#superclass : #TextAttribute,
	#instVars : [
		'anchoredMorph'
	],
	#category : #'Morphic-Text Support'
}

{ #category : #examples }
TextAnchor class >> alignmentExamples [
	"self alignmentExamples"
	| anchoredMorph textMorph text demoMorph |
	demoMorph := Morph new
		changeTableLayout;
		color: Color white;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		yourself.
	#(top center bottom) do: [:morphAlignment |
		#(top center baseline bottom) do: [:textAlignment |
			anchoredMorph := Morph new.
			anchoredMorph textAnchorProperties verticalAlignment: {morphAlignment . textAlignment}.
			anchoredMorph textAnchorProperties padding: (anchoredMorph textAnchorProperties padding top: 10).
			text := Text streamContents: [ :stream | 
				stream
					nextPutAll: ('Here is an {1}, {2} example: ' format: {morphAlignment . textAlignment});
					nextPutAll: (Text
						string: Character startOfHeader asString
						attributes: {TextAnchor new anchoredMorph: anchoredMorph. 
							TextColor color: Color transparent});
					nextPutAll: ' with the morph in the text.'].
			textMorph := text asMorph.
			textMorph height: 100.
			demoMorph addMorph: textMorph]].
	demoMorph openInWorld
]

{ #category : #comparing }
TextAnchor >> = other [ 
	^ (other class == self class) 
		and: [other anchoredMorph == anchoredMorph]
]

{ #category : #accessing }
TextAnchor >> anchoredMorph [
	^ anchoredMorph
]

{ #category : #accessing }
TextAnchor >> anchoredMorph: aMorph [ 
	anchoredMorph := aMorph
]

{ #category : #accessing }
TextAnchor >> couldDeriveFromPrettyPrinting [
	^ false
]

{ #category : #visiting }
TextAnchor >> emphasizeScanner: scanner [
	"Do nothing for emphasizing the scanner - if the anchor is valid, a #embeddedObject will be encountered by the scanner and do the real thing"
]

{ #category : #comparing }
TextAnchor >> hash [
	"#hash is re-implemented because #= is re-implemented"
	^anchoredMorph identityHash
]

{ #category : #accessing }
TextAnchor >> mayBeExtended [
	"A textAnchor is designed to modify only a single character, and therefore must not be extended by the ParagraphEditor's emphasisHere facility"
	^ false
]

{ #category : #testing }
TextAnchor >> shoutShouldPreserve [

	^ true
]
