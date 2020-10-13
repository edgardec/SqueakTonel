Class {
	#name : #MailDateAndTimeTest,
	#superclass : #TestCase,
	#category : #'NetworkTests-RFC822'
}

{ #category : #tests }
MailDateAndTimeTest >> testBasicDate [

	| date |
	date := DateAndTime year: 2017 month: 2 day: 3 hour: 0 minute: 0 second: 0 offset: (Duration hours: 0).
	self assert: 'Fri, 03 Feb 2017 00:00:00 +0000' equals: date asMailMessageString
]

{ #category : #tests }
MailDateAndTimeTest >> testBasicDateAndTime [

	| date |
	date := DateAndTime year: 2000 month: 6 day: 22 hour: 14 minute: 17 second: 47 offset: (Duration days: 0 hours: -5 minutes: 0 seconds: 0 nanoSeconds:0).
	self assert: 'Thu, 22 Jun 2000 14:17:47 -0500' equals: date asMailMessageString
	
]
