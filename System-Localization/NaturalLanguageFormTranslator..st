Class {
	#name : #NaturalLanguageFormTranslator,
	#superclass : #Object,
	#instVars : [
		'id',
		'generics'
	],
	#classVars : [
		'CachedTranslations'
	],
	#category : #'System-Localization'
}

{ #category : #'japanese locale' }
NaturalLanguageFormTranslator class >> bitmapForJapanese [

	^ (Form
	extent: 54@17
	depth: 16
	fromArray: #( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 65536 0 1 65537 65537 65537 65537 0 0 0 0 1 0 0 0 0 65537 65537 1 65537 65537 65536 1 0 0 0 1 0 0 1 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 65536 0 0 65536 0 0 1 0 0 0 1 0 0 0 0 1 0 0 0 1 65537 65537 65536 1 0 0 0 1 0 0 65536 0 0 1 0 0 0 1 0 1 65537 65537 65537 65537 65537 65537 0 0 0 1 65537 65537 0 0 1 0 1 0 0 0 1 0 0 0 1 0 0 0 0 65537 65536 0 0 0 65537 65537 0 65536 1 0 0 0 65536 1 0 0 0 1 65537 65537 65537 65537 0 0 0 1 1 1 0 0 0 0 0 0 65536 1 0 0 0 65536 1 0 0 0 1 0 0 0 1 0 0 0 1 1 1 0 0 0 65537 65537 65537 65537 65537 65537 0 0 65536 1 0 0 0 1 0 0 0 1 0 0 0 65536 1 0 65536 0 0 0 0 0 0 0 0 0 0 65536 1 0 0 0 1 0 0 0 1 0 0 1 0 1 0 1 0 0 65537 65537 1 65537 65537 65536 0 0 65536 1 0 0 0 1 0 0 0 1 0 0 65536 65537 65537 65537 65536 65536 0 65536 1 1 0 0 65536 0 0 65536 0 65536 0 0 1 0 0 0 1 0 1 0 0 1 0 0 1 0 65536 1 1 0 0 65536 0 1 0 0 65536 0 0 1 65537 65537 65537 65537 0 0 0 0 1 0 0 0 0 65537 65537 1 65537 65537 65536 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 65536 0 0 0 65536 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0)
	offset: 0@0)
]

{ #category : #accessing }
NaturalLanguageFormTranslator class >> cachedTranslations [
	"CachedTranslations := nil" 
	^CachedTranslations ifNil: [CachedTranslations := Dictionary new]
]

{ #category : #'class initialization' }
NaturalLanguageFormTranslator class >> cleanUp [
	"Flush caches"

	CachedTranslations := nil
]

{ #category : #'japanese locale' }
NaturalLanguageFormTranslator class >> initializeJapaneseBitmap [

	(self localeID: (LocaleID isoString: 'ja')) name: 'LanguageNameInNativeLanguage' form: self bitmapForJapanese.

]

{ #category : #accessing }
NaturalLanguageFormTranslator class >> isoLanguage: isoLanguage [
	"Return the generic language translator as there is no information about the country code"

	^self isoLanguage: isoLanguage isoCountry: nil
]

{ #category : #accessing }
NaturalLanguageFormTranslator class >> isoLanguage: isoLanguage isoCountry: isoCountry [
	^self localeID: (LocaleID  isoLanguage: isoLanguage isoCountry: isoCountry)
]

{ #category : #'i\/o' }
NaturalLanguageFormTranslator class >> loadFormsFrom: aStream [

	| rr pair inst |
	rr := ReferenceStream on: aStream.
	pair := rr next.
	inst := self localeID: (LocaleID isoString: pair first).
	pair second associationsDo: [:assoc |
		inst name: assoc key form: assoc value.
	].
	^ inst.

]

{ #category : #accessing }
NaturalLanguageFormTranslator class >> localeID: localeID [ 
	^ self cachedTranslations
		at: localeID
		ifAbsentPut: [self new localeID: localeID]
]

{ #category : #accessing }
NaturalLanguageFormTranslator >> generics [
	^generics ifNil: [generics := Dictionary new]
]

{ #category : #accessing }
NaturalLanguageFormTranslator >> localeID [
	^id
]

{ #category : #accessing }
NaturalLanguageFormTranslator >> localeID: anID [
	id := anID
]

{ #category : #accessing }
NaturalLanguageFormTranslator >> name: formName form: translatedForm [ 
	self generics at: formName put: translatedForm.

]

{ #category : #'i\/o' }
NaturalLanguageFormTranslator >> saveFormsOn: aStream [

	| rr |
	rr := ReferenceStream on: aStream.
	rr nextPut: {id isoString. generics}.
	rr close.

]

{ #category : #utilities }
NaturalLanguageFormTranslator >> translate: aString [

	^ (self generics
		at: aString ifAbsent: [nil]) deepCopy.

	"Do you like to write 'form ifNotNil: [form deepCopy]'?"

]
