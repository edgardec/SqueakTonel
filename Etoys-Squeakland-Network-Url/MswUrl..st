"
(out of date class....)
"
Class {
	#name : #MswUrl,
	#superclass : #HttpUrl,
	#category : #'Etoys-Squeakland-Network-Url'
}

{ #category : #misc }
MswUrl >> httpUrlOfServer [
	"return the HTTP address to make queries to"	
	#XXX.  "should come up with a better name for this when I'm less tired"
	^HttpUrl schemeName: 'http'  authority: authority  path: path  query: nil.
]

{ #category : #access }
MswUrl >> query [
	"return the query.  There is never a MuSwiki URL without a query; the query defaults to 'top' if none is explicitly specified"
	| q |
	q := super query.
	q isNil ifTrue: [ q := 'top' ].
	^q
]
