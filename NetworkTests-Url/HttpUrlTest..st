Class {
	#name : #HttpUrlTest,
	#superclass : #ClassTestCase,
	#category : #'NetworkTests-Url'
}

{ #category : #tests }
HttpUrlTest >> testHttps [
	self assert: 'https://encrypted.google.com' asUrl class == HttpUrl
]
