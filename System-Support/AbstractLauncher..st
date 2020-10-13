"
The class AutoStart in combination with the Launcher classes provides a mechanism for starting Squeak from the command line or a web page. Parameters on the command line or in the embed tag in the web page a parsed and stored in the launcher's parameter dictionary.
Subclasses can access these parameters to determine what to do.

CommandLineLauncherExample provides an example for a command line application. if you start squeak with a command line 'class Integer' it will launch a class browser on class Integer.
To enable this execute
CommandLineLauncherExample activate
before you save the image.
To disable execute
CommandLineLauncherExample deactivate

The PluginLauncher is an example how to use this framework to start Squeak as a browser plugin. It looks for a parameter 'src' which should point to a file containing a squeak script.
"
Class {
	#name : #AbstractLauncher,
	#superclass : #Object,
	#instVars : [
		'parameters'
	],
	#category : #'System-Support'
}

{ #category : #activation }
AbstractLauncher class >> activate [
	"Register this launcher with the auto start class"

	self autoStarter addLauncher: self
]

{ #category : #private }
AbstractLauncher class >> autoStarter [
	^AutoStart
]

{ #category : #activation }
AbstractLauncher class >> deactivate [
	"Unregister this launcher with the auto start class"
	self autoStarter removeLauncher: self
]

{ #category : #private }
AbstractLauncher >> commandLine: aString [
	"Start up this launcher from within Squeak as if it Squeak been launched the given command line."

	| dict tokens cmd arg |
	dict := Dictionary new.
	tokens := ReadStream on: (aString findTokens: ' ').
	[cmd := tokens next.
	 arg := tokens next.
	 ((cmd ~~ nil) and: [arg ~~ nil])]
		whileTrue: [dict at: cmd put: arg].
	self parameters: dict.
	self startUp.

]

{ #category : #private }
AbstractLauncher >> determineParameterNameFrom: alternateParameterNames [
	"Determine which of the given alternate parameter names is actually used."

	^alternateParameterNames detect: [:each | self includesParameter: each asUppercase] ifNone: [nil] 
]

{ #category : #private }
AbstractLauncher >> includesParameter: parName [
	"Return if the parameter named parName exists."
	^self parameters
		includesKey: parName asUppercase
]

{ #category : #private }
AbstractLauncher >> parameterAt: parName [
	"Return the parameter named parName or an empty string"
	^self
		parameterAt: parName
		ifAbsent: ['']
]

{ #category : #private }
AbstractLauncher >> parameterAt: parName ifAbsent: aBlock [
	"Return the parameter named parName.
	Evaluate the block if parameter does not exist."
	^self parameters
		at: parName asUppercase
		ifAbsent: aBlock
]

{ #category : #private }
AbstractLauncher >> parameters [
	parameters == nil
		ifTrue: [parameters := Smalltalk namedArguments].
	^parameters
]

{ #category : #private }
AbstractLauncher >> parameters: startupParameters [
	parameters := startupParameters
]

{ #category : #running }
AbstractLauncher >> startUp [
	"A backstop for subclasses.  Note that this is not a class message (most startUps are class messages)."


]
