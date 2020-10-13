Class {
	#name : #FormInspector,
	#superclass : #Inspector,
	#category : #'Tools-Inspector'
}

{ #category : #support }
FormInspector >> embedForm: aForm inText: stringOrText [

	^ stringOrText asText, String cr,
		(Text string: ' ' attribute:
			(TextFontReference toFont: 
				(FormSetFont new
					fromFormArray: (Array with: (aForm copy offset: 0@0))
					asciiStart: Character space asInteger
					ascent: aForm height)))
]

{ #category : #fields }
FormInspector >> fieldPixels [

	^ (self newFieldForType: #misc key: #pixels)
		name: 'pixels' translated; emphasizeName;
		printValueAsIs;
		valueGetter: [:form | self embedForm: form inText: form printString];
		yourself
]

{ #category : #'fields - streaming' }
FormInspector >> streamBaseFieldsOn: aStream [

	super streamBaseFieldsOn: aStream.
	aStream nextPut: self fieldPixels.
]
