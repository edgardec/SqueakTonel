"
I am an inspector for HTML entities.
"
Class {
	#name : #HtmlEntityInspector,
	#superclass : #Inspector,
	#category : #'Etoys-Squeakland-Network-HTML-Parser'
}

{ #category : #fields }
HtmlEntityInspector >> fieldHtml [

	^ (self newFieldForType: #custom key: #html)
		name: 'asHtml'; emphasizeName;
		valueGetter: [:object | object asHtml];
		yourself
]

{ #category : #toolbuilder }
HtmlEntityInspector >> initialExtent [
	"Answer the desired extent for the receiver when it is first opened on the screen.  "

	^ 300 @ 300
]

{ #category : #fields }
HtmlEntityInspector >> streamFieldsOn: aStream [

	super streamFieldsOn: aStream.
	aStream nextPut: self fieldHtml.
]
