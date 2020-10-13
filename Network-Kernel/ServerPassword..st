"
""Hold a password.  There are three ways to get the password.

If there is no password (sequence == nil), ask the user for it.

If the user supplied one during this session, return that.  It is cleared at shutDown.

If sequence is a number, get the server passwords off the disk.  File 'sqk.info' must be in the same folder 'Squeak.sources' file.  Decode the file.  Return the password indexed by sequence.""
"
Class {
	#name : #ServerPassword,
	#superclass : #Password,
	#instVars : [
		'sequence'
	],
	#category : #'Network-Kernel'
}

{ #category : #accessing }
ServerPassword >> cache: anObject [
	cache := anObject
]

{ #category : #accessing }
ServerPassword >> passwordFor: serverDir [
	"Returned the password from one of many sources.  OK if send in a nil arg."

	| sp msg |
	cache ifNotNil: [^ cache].
	sequence ifNotNil: [
		(sp := self serverPasswords) ifNotNil: [
			sequence <= sp size ifTrue: [^ sp at: sequence]]].
	msg := serverDir isRemoteDirectory
		ifTrue: [serverDir moniker]
		ifFalse: ['this directory'].
	(serverDir user = 'anonymous') & (serverDir typeWithDefault == #ftp) ifTrue: [
			^ cache := UIManager default request: 'Please let this anonymous ftp\server know your email address.\This is the polite thing to do.' withCRs
			initialAnswer: 'yourName@company.com'].

	^ cache := UIManager default requestPassword: 'Password for ', serverDir user, ' at ', msg, ':'.
		"Diff between empty string and abort?"
]

{ #category : #accessing }
ServerPassword >> sequence [
	^sequence
]

{ #category : #accessing }
ServerPassword >> sequence: anNumber [
	sequence := anNumber
]

{ #category : #accessing }
ServerPassword >> serverPasswords [
	"Get the server passwords off the disk and decode them. The file 'sqk.info' must be in some folder that Squeak thinks is special (vm folder, or default directory).  (Note: This code works even if you are running with no system sources file.)"

	| sfile |
	(sfile := FileDirectory lookInUsualPlaces: 'sqk.info') ifNil: [^ nil].
		"If not there, Caller will ask user for password"
		"If you don't have this file, and you really do want to release an update, 
		 contact Ted Kaehler."
	^ (self decode: (sfile contentsOfEntireFile)) lines

]
