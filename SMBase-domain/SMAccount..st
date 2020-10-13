"
SMAccount is the object representing a user account in SqueakMap - a Squeaker that owns information in SqueakMap.

It keeps track of the email address, developer initials and two passwords used to access the account. There is also an advogatoId (people.squeakfoundation.org username) and a signature field (not used yet). The flag isAdmin is a crude way of marking a user as a superuser, this will possibly be changed in the future and instead expressed using a category.

Passwords are stored as secure hashes. The extra password (newPassword) is used when the regular password is forgotten - it is then randomly set and an email is sent out containing it to the registered email. This enables the original password to still work. When logging in, the user gets a chance to enter a new regular password overwriting the old one and clearing the random new password in the process.

The instvar objects holds all SMPersonalObjects (instances of subclasses) that this account ""owns"" - these are typically instances of SMPackages and SMResources, but are not limited to be.

The instvar coObjects holds all SMPersonalObjects that this account is co-maintaining - these are typically instances of SMPackages and SMResources.

Finally the account also maintains a directory with uploaded files on the server. This directory has the UUID of the account as its name and it is located under sm/accounts
"
Class {
	#name : #SMAccount,
	#superclass : #SMRootedObject,
	#instVars : [
		'initials',
		'email',
		'signature',
		'password',
		'newPassword',
		'advogatoId',
		'objects',
		'coObjects',
		'isAdmin'
	],
	#category : #'SMBase-domain'
}

{ #category : #objects }
SMAccount >> addCoObject: anObject [
	"Add <anObject> to this account.
	Only called from #addMaintainer:."
	
	(coObjects includes: anObject)
		ifFalse:[coObjects add: anObject]
]

{ #category : #objects }
SMAccount >> addObject: anObject [
	"Add <anObject> to this account. Also makes sure the
	reverse reference is correct."
	
	(objects includes: anObject) ifFalse:[
		objects add: anObject.
		anObject owner: self.
		map addObject: anObject]
]

{ #category : #accessing }
SMAccount >> advogatoId [
	^advogatoId
]

{ #category : #accessing }
SMAccount >> advogatoId: aString [
	advogatoId := aString
]

{ #category : #objects }
SMAccount >> coPackageWithId: anIdString [
	"Return the correct package or nil."

	^self withId: anIdString in: self coPackages
]

{ #category : #objects }
SMAccount >> coPackages [
	"Return all co-maintained packages."

	^coObjects select: [:o | o isPackage]
]

{ #category : #passwords }
SMAccount >> correctPassword: aPassword [
	"We store the password as a SHA hash so that we can let the slave maps
	have them too. Also check the optional new random password."

	| try |
	aPassword isEmptyOrNil ifTrue:[^false].
	try := SecureHashAlgorithm new hashMessage: aPassword.
	^password = try or: [newPassword = try]
]

{ #category : #passwords }
SMAccount >> createRandomPassword [
	"Create a random password and set it
	in parallell to the regular one."

	| randomPass |
	randomPass := String streamContents: [:stream | 10 timesRepeat: [ stream nextPut: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' atRandom]].
	self setNewPassword: randomPass.
	^randomPass
]

{ #category : #files }
SMAccount >> delete [
	"Delete this account. First delete all SM objects we own
	and disconnect this account from those we co-maintain."

	objects do: [:o | o delete].
	coObjects do: [:co | co removeMaintainer: self].
	super delete

]

{ #category : #files }
SMAccount >> deleteFiles: fileNames [
	"Delete all fileNames from the uploads directory."

	| dir |
	dir := self uploadsDirectory.
	fileNames do: [:fn | dir deleteFileNamed: fn]

]

{ #category : #files }
SMAccount >> directory [
	"Get the directory for the account."

	| dir |
	dir := (map directory directoryNamed: 'accounts') assureExistence; yourself.
	^(dir directoryNamed: id asString) assureExistence; yourself

]

{ #category : #accessing }
SMAccount >> email [
	^email
]

{ #category : #accessing }
SMAccount >> email: address [
	email := address
]

{ #category : #files }
SMAccount >> entries [
	"Return all file entries in the upload directory."

	^self uploadsDirectory entries
]

{ #category : #files }
SMAccount >> files [
	"Return filenames for uploaded files."

	^self uploadsDirectory fileNames

]

{ #category : #view }
SMAccount >> getLink: aBuilder [
	"Return a link for using on the web.
	Always from the top."

	^aBuilder getLinkTop: 'accountbyid/', id asString text: self nameWithInitials
]

{ #category : #'initialize-release' }
SMAccount >> initialize [
	"Initialize account."

	super initialize.
	initials := signature := advogatoId := ''.
	isAdmin := false.
	objects := OrderedCollection new.
	coObjects := OrderedCollection new
]

{ #category : #accessing }
SMAccount >> initials [
	^initials
]

{ #category : #accessing }
SMAccount >> initials: aString [
	"If these are changed we need to update the dictionary in the map."

	initials ~= aString ifTrue: [
		initials := aString.
		map clearUsernames]
]

{ #category : #testing }
SMAccount >> isAccount [
	^true
]

{ #category : #accessing }
SMAccount >> isAdmin [
	^isAdmin ifNil: [false] ifNotNil: [isAdmin]
]

{ #category : #accessing }
SMAccount >> isAdmin: aBoolean [
	isAdmin := aBoolean
]

{ #category : #view }
SMAccount >> logout [
	"Automatically called upon logout. Do nothing."
]

{ #category : #objects }
SMAccount >> moveObject: aPersonalObject toAccount: anAccount [
	"Transfer the ownership of the given personal object to <anAccount>."

	self removeObject: aPersonalObject.
	anAccount addObject: aPersonalObject
]

{ #category : #accessing }
SMAccount >> nameAndEmail [
	"This is not really correct, the name needs to be
	mime encoded."

	^name , ' <', email, '>'
]

{ #category : #view }
SMAccount >> nameWithInitials [
	"Return name and developer initials within parentheses."

	^name, ' (', (initials isEmptyOrNil ifTrue: ['not entered'] ifFalse: [initials]) , ')'
]

{ #category : #files }
SMAccount >> newFile: fileName block: aBlock [
	"Create a new file. Let <aBlock> fill the file with content by calling it with a stream."

	| dir stream |
	dir := self uploadsDirectory.
	[(dir fileExists: fileName) ifTrue:[dir deleteFileNamed: fileName].
	stream := dir newFileNamed: fileName.
	stream binary.
	aBlock value: stream] ensure: [stream close]
]

{ #category : #accessing }
SMAccount >> newPassword [
	"Get the parallell password hash."

	^newPassword
]

{ #category : #accessing }
SMAccount >> newPassword: aHashNumber [
	"Set the parallell password hash."

	newPassword := aHashNumber
]

{ #category : #testing }
SMAccount >> owns: anObject [
	^objects includes: anObject
]

{ #category : #objects }
SMAccount >> packageWithId: anIdString [
	"Return the correct package or nil."

	^self withId: anIdString in: self packages
]

{ #category : #objects }
SMAccount >> packages [
	"Return all owned packages."

	^objects select: [:o | o isPackage]
]

{ #category : #accessing }
SMAccount >> password [
	"Get the password hash."

	^password
]

{ #category : #accessing }
SMAccount >> password: aHashNumber [
	"Set the password hash."

	password := aHashNumber
]

{ #category : #view }
SMAccount >> publicViewFor: uiObject [
	"This is a double dispatch mechanism for multiple views
	for multiple uis."

	^uiObject publicAccountViewOn: self
]

{ #category : #objects }
SMAccount >> removeCoObject: anObject [
	"Remove <anObject> from this account.
	Only called from #removeMaintainer:."

	(coObjects includes: anObject) ifTrue: [
		coObjects remove: anObject]
]

{ #category : #objects }
SMAccount >> removeObject: anObject [
	"Remove <anObject> from this account. Also makes sure the
	reverse reference is cleared."

	(objects includes: anObject) ifTrue: [
		anObject owner: nil.
		objects remove: anObject]
]

{ #category : #passwords }
SMAccount >> setNewPassword: aString [
	"Set a new parallell password the user can use to get in
	if the old password is forgotten. We don't delete the old
	password since the request for this new password is made
	anonymously. Note that the password is stored as a secured
	hash large integer."

	newPassword := SecureHashAlgorithm new hashMessage: aString
]

{ #category : #passwords }
SMAccount >> setPassword: aString [
	"We also clear the random extra password."

	password := SecureHashAlgorithm new hashMessage: aString.
	newPassword := nil
]

{ #category : #accessing }
SMAccount >> signature [
	"Get the signature."

	^signature
]

{ #category : #accessing }
SMAccount >> signature: aSignature [
	"Set the signature."

	signature := aSignature
]

{ #category : #files }
SMAccount >> streamForFile: fileName [
	"Return a readonly stream for file <fileName>.
	If the file does not exist return nil."

	^[StandardFileStream oldFileNamed: (self uploadsDirectory fullNameFor: fileName)]
		on: FileDoesNotExistException do: [nil]
]

{ #category : #printing }
SMAccount >> type [
	"Used in various views."

	^'Account'
]

{ #category : #files }
SMAccount >> uploadsDirectory [
	"Get the directory for uploaded files, create it if missing."

	^(self directory directoryNamed: 'uploads') assureExistence; yourself

]

{ #category : #view }
SMAccount >> viewFor: uiObject [
	"This is a double dispatch mechanism for multiple views
	for multiple uis."

	^uiObject accountViewOn: self
]
