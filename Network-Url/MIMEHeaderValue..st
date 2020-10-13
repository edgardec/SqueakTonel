"
I contain the value portion of a MIME-compatible header.

I must be only initialized with the value and not the field name.  E.g. in processing
	Subject: This is the subject
the MIMEHeaderValue should be given only 'This is the subject'

For traditional non-MIME headers, the complete value returned for mainValue and paramaters returns an empty collection.

For MIME headers, both mainValue and parameters are used.
"
Class {
	#name : #MIMEHeaderValue,
	#superclass : #Object,
	#instVars : [
		'mainValue',
		'parameters'
	],
	#category : #'Network-Url'
}

{ #category : #'instance creation' }
MIMEHeaderValue class >> forField: aFName fromString: aString [
	"Create a MIMEHeaderValue from aString.  How it is parsed depends on whether it is a MIME specific field or a generic header field."

	| decodedString |
	decodedString := [aString decodeMimeHeader]
		on: InvalidUTF8 , NoConverterFound do: [:e | aString].	
	(aFName beginsWith: 'content-') 
		ifTrue: [^self fromMIMEHeader: decodedString]
		ifFalse: [^self fromTraditionalHeader: decodedString]

]

{ #category : #'instance creation' }
MIMEHeaderValue class >> fromMIMEHeader: aString [
	"This is the value of a MIME header field and so is parsed to extract the various parts. 
	This assumes a string without any special encodings (e.g. q encoding)."

	| parts newValue parms |

	newValue := self new.

	parts := ReadStream on: (aString findTokens: ';').
	newValue mainValue: parts next.
	parms := Dictionary new.
	parts do: 
		[:e | | separatorPos parmName parmValue | 
		separatorPos := e findAnySubStr: '=' startingAt: 1. 
		separatorPos <= e size
			ifTrue: 
				[parmName := (e copyFrom: 1 to: separatorPos - 1) withBlanksTrimmed asLowercase.
				parmValue := (e copyFrom: separatorPos + 1 to: e size) withBlanksTrimmed withoutQuoting.
				parms at: parmName put: parmValue]].
	newValue parameters: parms.
	^ newValue

]

{ #category : #'instance creation' }
MIMEHeaderValue class >> fromTraditionalHeader: aString [
	"This is a traditional non-MIME header (like Subject:) and so should be stored whole. 
	This assumes a string without any special encodings (e.g. q encoding)."

	| newValue |

	newValue := self new.
	newValue mainValue: aString.
	newValue parameters: #().
	^newValue.

]

{ #category : #printing }
MIMEHeaderValue >> asHeaderValue [
	| strm result |
	strm := WriteStream on: (String new: 20).
	strm nextPutAll: mainValue.
	parameters associationsDo: [:e | 
		strm 
			nextPut: $; ; 
			nextPutAll: e key;
		 	nextPutAll: '=';
		 	nextPutAll: e value].
	^ (result := strm contents) isAsciiString
		ifFalse: [QEncodingMimeConverter mimeEncode: result]
		ifTrue: [result]

]

{ #category : #accessing }
MIMEHeaderValue >> mainValue [
	^ mainValue
]

{ #category : #accessing }
MIMEHeaderValue >> mainValue: anObject [
	mainValue := anObject
]

{ #category : #accessing }
MIMEHeaderValue >> parameterAt: aParameter ifAbsent: absentBlock [

	^ parameters at: aParameter ifAbsent: absentBlock
]

{ #category : #accessing }
MIMEHeaderValue >> parameterAt: aParameter put: value [
	parameters at: aParameter put: value
]

{ #category : #accessing }
MIMEHeaderValue >> parameters [
	^parameters
]

{ #category : #accessing }
MIMEHeaderValue >> parameters: anObject [
	parameters := anObject
]

{ #category : #printing }
MIMEHeaderValue >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ': '.
	aStream nextPutAll: self asHeaderValue
]
