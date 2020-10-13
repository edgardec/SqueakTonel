"
ExternalSettings manages settings kept externally, e.g. files.
Objects can register themselves as clients to be notified at startup time to read their settings.

Eventually all the preferences should be managed through this mechanism.

"
Class {
	#name : #ExternalSettings,
	#superclass : #Object,
	#classVars : [
		'RegisteredClients'
	],
	#category : #'System-Support'
}

{ #category : #accessing }
ExternalSettings class >> assuredPreferenceDirectory [
	"Answer the preference directory, creating it if necessary"

	|  prefDir topDir |
	prefDir := self preferenceDirectory.
	prefDir
		ifNil:
			[topDir := Preferences startInUntrustedDirectory
				ifTrue: [FileDirectory on: SecurityManager default secureUserDirectory]
				ifFalse: [FileDirectory default].
			prefDir := topDir directoryNamed: self preferenceDirectoryName.
			prefDir assureExistence].
	^ prefDir
]

{ #category : #'class initialization' }
ExternalSettings class >> initialize [
	"ExternalSettings initialize"
	"Order: ExternalSettings, SecurityManager, AutoStart"
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self
]

{ #category : #accessing }
ExternalSettings class >> parseServerEntryArgsFrom: stream [
	"Args are in the form <argName>: <argValueString> delimited by end of line.
	It's not a very robust format and should be replaced by something like XML later.
	But it avoids evaluating the entries for security reasons."

	| entries lineStream entryName entryValue |
	entries := Dictionary new.
	stream skipSeparators.
	[stream atEnd]
		whileFalse: [
			lineStream := ReadStream on: stream nextLine.
			entryName := lineStream upTo: $:.
			lineStream skipSeparators.
			entryValue := lineStream upToEnd.
			(entryName isEmptyOrNil 
				or: [entryValue isEmptyOrNil])
				ifFalse: [entries at: entryName put: entryValue withoutTrailingBlanks].
			stream skipSeparators].
	^entries
]

{ #category : #accessing }
ExternalSettings class >> preferenceDirectory [
	| prefDirName path |
	prefDirName := self preferenceDirectoryName.
	path := Smalltalk vmPath.
	^(FileDirectory default directoryExists: prefDirName)
		ifTrue: [FileDirectory default directoryNamed: prefDirName]
		ifFalse: [
			((FileDirectory on: path) directoryExists: prefDirName)
				ifTrue: [(FileDirectory on: path) directoryNamed: prefDirName]
				ifFalse: [nil]]

]

{ #category : #accessing }
ExternalSettings class >> preferenceDirectoryName [
	^'prefs'
]

{ #category : #accessing }
ExternalSettings class >> registerClient: anObject [
	"Register anObject as a settings client to be notified on startup."

	self registeredClients add: anObject
]

{ #category : #private }
ExternalSettings class >> registeredClients [
	RegisteredClients ifNil: [RegisteredClients := Set new].
	^RegisteredClients
]

{ #category : #'class initialization' }
ExternalSettings class >> shutDown [
	"Look for external defs and load them."
	"ExternalSettings shutDown"

	self registeredClients do: [:client | 
		client releaseExternalSettings]
]

{ #category : #'class initialization' }
ExternalSettings class >> startUp [
	"Look for external defs and load them."
	"ExternalSettings startUp"

	| prefDir |
	prefDir := self preferenceDirectory.
	prefDir
		ifNil: [^self].
	self registeredClients do: [:client | 
		client fetchExternalSettingsIn: prefDir]
]
