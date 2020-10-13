Class {
	#name : #MIMEDocumentTest,
	#superclass : #ClassTestCase,
	#category : #'NetworkTests-Url'
}

{ #category : #tests }
MIMEDocumentTest >> testCharset [
	
	| document |
	document := MIMEDocument contentType: 'text/plain;charset=utf-8' content: self utf8String.
	self assert: 'utf-8' equals: document charset. 
]

{ #category : #tests }
MIMEDocumentTest >> testContentType [
	
	| document |
	document := MIMEDocument contentType: 'text/plain;charset=utf-8' content: self utf8String.
	self assert: 'text/plain' equals: document contentType. 
]

{ #category : #tests }
MIMEDocumentTest >> testMainAndSubType [
	
	| document |
	document := MIMEDocument contentType: 'text/plain' content: self utf8String.
	self assert: 'text' equals: document mainType. 
	self assert: 'plain' equals: document subType.
]

{ #category : #tests }
MIMEDocumentTest >> testMultipartDocument [
	
	| document |
	document := MIMEDocument newMultipart.
	self assert: 'multipart/mixed' equals: document contentType. 
]

{ #category : #tests }
MIMEDocumentTest >> testParameterizedContentType [
	
	| document |
	document := MIMEDocument contentType: 'text/plain;charset=utf-8' content: self utf8String.
	self assert: 'text/plain;charset=utf-8' equals: document parameterizedContentType. 
]

{ #category : #tests }
MIMEDocumentTest >> testUtf8Text [
	
	| document |
	document := MIMEDocument contentType: 'text/plain; charset="utf8"' content: self utf8String.
	self assert: self utf8String utf8ToSqueak equals: document content 
]

{ #category : #fixtures }
MIMEDocumentTest >> utf8String [

	^ #[199 161 84 83 67 72] asString
]
