Class {
	#name : #HtmlAttributes,
	#superclass : #Dictionary,
	#category : #'Etoys-Squeakland-Network-HTML-Parser'
}

{ #category : #printing }
HtmlAttributes >> printHtmlOn: aStream [
	self associationsDo: 
		[:element | 
		aStream 
			space;
			nextPutAll: element key asUppercase.
		element value ifNotNil: [  
				aStream nextPut: $=.
				aStream print: element value withoutQuoting]. ]
]
