Class {
	#name : #FileUrlTest,
	#superclass : #ClassTestCase,
	#category : #'NetworkTests-Url'
}

{ #category : #tests }
FileUrlTest >> testAsString [
	| target url |
	target := 'file://localhost/etc/rc.conf'.
	url := target asUrl.
	self assert: url asString = target.
		
]
