Class {
	#name : #PropertyListEncoder,
	#superclass : #PrintableEncoder,
	#category : #'Etoys-Squeakland-MorphicExtras-Postscript Filters'
}

{ #category : #configuring }
PropertyListEncoder class >> filterSelector [
	^#propertyListOn:.

]

{ #category : #writing }
PropertyListEncoder >> writeArrayedCollection:aCollection [
	self print:'/* '; print:aCollection class name; print:'*/'; cr.
	self print:'( '; writeCollectionContents:aCollection separator:','; print:')'.
]

{ #category : #writing }
PropertyListEncoder >> writeDictionary:aCollection [
	self print:'{ '; writeDictionaryContents:aCollection separator:'; '; print:'}'.
]
