Class {
	#name : #URIAuthority,
	#superclass : #Object,
	#instVars : [
		'host',
		'port',
		'userInfo'
	],
	#category : #'Network-URI'
}

{ #category : #'instance creation' }
URIAuthority class >> fromString: authorityString [
	^self new fromString: authorityString
]

{ #category : #private }
URIAuthority >> fromString: authorityString [
	| userInfoEnd remainder hostEnd |
	userInfoEnd := authorityString indexOf: $@.
	remainder := userInfoEnd > 0
		ifTrue: [
			userInfo := authorityString copyFrom: 1 to: userInfoEnd-1.
			authorityString copyFrom: userInfoEnd+1 to: authorityString size]
		ifFalse: [authorityString].
	hostEnd := remainder indexOf: $: .
	hostEnd > 0
		ifTrue: [
			host := remainder copyFrom: 1 to: hostEnd-1.
			port := (remainder copyFrom: hostEnd+1 to: remainder size) asNumber]
		ifFalse: [host := remainder]
]

{ #category : #accessing }
URIAuthority >> host [
	^host
]

{ #category : #accessing }
URIAuthority >> port [
	^port
]

{ #category : #printing }
URIAuthority >> printOn: stream [
	userInfo
		ifNotNil: [
			stream nextPut: $@ .
			stream nextPutAll: userInfo].
	stream nextPutAll: host.
	port
		ifNotNil: [
			stream nextPut: $: .
			port printOn: stream] 
]

{ #category : #accessing }
URIAuthority >> userInfo [
	^userInfo
]
