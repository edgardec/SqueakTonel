"
""Hold a password in memory during a run of the app.

After each save (after each startup), when an applicaiton asks for a password, one of two things will happen:
  1> the user will be prompted for the password
  2> If the user was previously prompted, return that password

Passwords are stored encoded.
At shutDown, passwords are cleared (will not be written to disc).

The intent for this class is to avoid storing passwords in code or on files on the system.  Instead, prompt the user during the running of the application.""
"
Class {
	#name : #Password,
	#superclass : #Object,
	#instVars : [
		'cache'
	],
	#category : #'Network-Kernel'
}

{ #category : #'system startup' }
Password class >> shutDown [
	"Forget all cached passwords, so they won't stay in the image"

	self allSubInstancesDo: [:each | each cache: nil].
]

{ #category : #accessing }
Password >> cache: anObject [
	"if anObject is nil, then clear out cache - don't store values to disc"
	anObject ifNil: [^cache := nil].
	"Otherwise, 'encode' (trivially) the password while it resides in memory - no plain text"
	cache := self decode: anObject
]

{ #category : #private }
Password >> decode: string [
	"Xor with secret number -- just so file won't have raw password in it"
	| kk rand |
	rand := Random new seed: 234237.
	kk := (ByteArray new: string size) collect: [:bb | (rand next * 255) asInteger].
	1 to: kk size do: [:ii |
		kk at: ii put: ((kk at: ii) bitXor: (string at: ii) asciiValue)].
	^ kk asString
]

{ #category : #accessing }
Password >> passwordForMessage: msg [
	cache ifNotNil: [^self decode: cache]. "Our stored value is encoded"
	^self decode: (cache := self decode: (UIManager default requestPassword: 'Password for ', msg, ':')).
]
