Class {
	#name : #InstallerInternetBased,
	#superclass : #Installer,
	#instVars : [
		'url',
		'pageDataStream',
		'markers'
	],
	#classVars : [
		'Entities'
	],
	#category : #'Installer-Core'
}

{ #category : #accessing }
InstallerInternetBased class >> entities [

	^ Entities ifNil: [ Entities := 
				"enough entities to be going on with"
  				Dictionary new.
				Entities at: 'lt' put: '<';
				at: 'gt' put: '>';
				at: 'amp' put: '&';
				at: 'star' put: '*';
				at: 'quot' put: '"';
				at: 'nbsp' put: ' ';
 			yourself
]

 
]

{ #category : #'class references' }
InstallerInternetBased >> classHTTPSocket [

	^Smalltalk at: #HTTPSocket ifAbsent: [ self error: 'Network package not present' ]
]

{ #category : #'as yet unclassified' }
InstallerInternetBased >> extractFromHtml: html option: allOrLast [

	|  start stop test in |

	start := self markersBegin.
	stop :=  self markersEnd.
	test := self markersTest.
			 
	in := WriteStream with: String new.
		
	[ html upToAll: start; atEnd ] 
		whileFalse: [
			| chunk |
			(allOrLast == #last) ifTrue: [ in resetToStart ]. 
			chunk := html upToAll: stop.
			self isSkipLoadingTestsSet ifTrue: [ chunk := chunk readStream upToAll: test ].
			in nextPutAll: chunk. 
		 ].

	^self removeHtmlMarkupFrom: in readStream
	 

]

{ #category : #url }
InstallerInternetBased >> hasPage [

	^ pageDataStream notNil and: [ pageDataStream size > 0 ]
			
]

{ #category : #utils }
InstallerInternetBased >> httpGet: aUrl [

	| page |
	page := self classHTTPSocket httpGet: aUrl accept: 'application/octet-stream'.  
 
	(page respondsTo: #reset)  ifFalse: [ self error: 'unable to contact web site' ].
	^ page
	
]

{ #category : #url }
InstallerInternetBased >> isHtmlStream: page [
	"matches  '<!DOCTYPE HTML', and <html>' "
	
	| first |	
	first := (page next: 14) asUppercase.
	^ (first = '<!DOCTYPE HTML') | (first beginsWith: '<HTML>')
	

]

{ #category : #'as yet unclassified' }
InstallerInternetBased >> markers [

	^ markers ifNil: [ '<code st>..."test ...</code st>' ]
]

{ #category : #'as yet unclassified' }
InstallerInternetBased >> markers: anObject [

	markers := anObject
]

{ #category : #'as yet unclassified' }
InstallerInternetBased >> markersBegin [
		 	 
	 ^ self markers copyUpTo: $.
]

{ #category : #'as yet unclassified' }
InstallerInternetBased >> markersEnd [
	"return the third marker or the second if there are only two"
	
	| str  a | 
	str := self markers readStream.
	a := str upToAll: '...'; upToAll: '...'.
	str atEnd  ifTrue: [ ^a ] ifFalse: [ ^str upToEnd ]
	
]

{ #category : #'as yet unclassified' }
InstallerInternetBased >> markersTest [
		 	 
	^ self markers readStream upToAll: '...'; upToAll: '...'
]

{ #category : #'as yet unclassified' }
InstallerInternetBased >> removeHtmlMarkupFrom: in [ 

	| out |
	out := WriteStream on: (String new: 100).
	[ in atEnd ] whileFalse: [ 
		out nextPutAll: (in upTo: $<).
		(((in upTo: $>) asLowercase beginsWith: 'br') and: [ (in peek = Character cr) ]) ifTrue: [ in next ].	
	].
	
	^self replaceEntitiesIn: out readStream.

]

{ #category : #url }
InstallerInternetBased >> replaceEntitiesIn: in [

	| out |
	out := WriteStream on: (String new: 100).
	[ in atEnd ] whileFalse: [ 
		out nextPutAll: ((in upTo: $&) replaceAll: Character lf with: Character cr).
		in atEnd ifFalse: [ out nextPutAll: (self class entities at: (in upTo: $;) ifAbsent: '?') ].	
	].

	^out readStream
]

{ #category : #accessing }
InstallerInternetBased >> url [

	^url
]

{ #category : #accessing }
InstallerInternetBased >> url: aUrl [
 
	url := aUrl
]

{ #category : #url }
InstallerInternetBased >> urlGet [

	^ self urlGet: self urlToDownload
]

{ #category : #url }
InstallerInternetBased >> urlGet: aUrl [

	| page |
	page := HTTPSocket httpGet: aUrl accept: 'application/octet-stream'.  
	(page respondsTo: #reset)  ifFalse: [ ^ nil ].
	(self isHtmlStream: page) ifTrue: [ page := self extractFromHtml: page option: nil ].
	^ page reset
	
]

{ #category : #url }
InstallerInternetBased >> wasPbwikiSpeedWarning [
		
		^ self hasPage and: [pageDataStream contents includesSubstring: 'Please slow down a bit' ] 
 

]
