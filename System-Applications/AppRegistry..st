"
AppRegistry is a simple little class, not much more than a wrapper around a collection. It's intended to help break dependencies between packages. For example, if you'd like to be able to send e-mail, you could use the bare-bones MailComposition class, or you could use the full-blown Celeste e-mail client. Instead of choosing one or the other, you can call ""MailSender default"" (where MailSender is a subclass of AppRegistry), and thus avoid creating a hard-coded dependency on either of the two mail senders.

This will only really be useful, of course, for applications that have a very simple, general, well-defined interface. Most of the time, you're probably better off just marking your package as being dependent on a specific other package, and avoiding the hassle of this whole AppRegistry thing. But for simple things like e-mail senders or web browsers, it might be useful.

"
Class {
	#name : #AppRegistry,
	#superclass : #Object,
	#classInstVars : [
		'registeredClasses',
		'default'
	],
	#category : #'System-Applications'
}

{ #category : #defaults }
AppRegistry class >> appName [
	"Defaults to the class name, which is probably good enough, but you could override this in subclasses if you want to."
	^ self name
]

{ #category : #defaults }
AppRegistry class >> askForDefault [

	self registeredClasses isEmpty ifTrue:
		[self inform: 'There are no ', self appName, ' applications registered.'.
		^ default := nil].
	self registeredClasses size = 1 ifTrue:
		[^ default := self registeredClasses anyOne].
	default :=  UIManager default 
		chooseFrom: (self registeredClasses collect: [:ea | ea nameForViewer])
		values: self registeredClasses
		title: 'Which ', self appName, ' would you prefer?'.
	default ifNil: [default := self registeredClasses first].
	^default.
]

{ #category : #'class initialization' }
AppRegistry class >> cleanUp [
	"AppRegistry cleanUp"

	self removeObsolete.
]

{ #category : #accessing }
AppRegistry class >> default [
	^ default ifNil: [self askForDefault]
]

{ #category : #accessing }
AppRegistry class >> default: aClassOrNil [
	"Sets my default to aClassOrNil. 
	Answers the old default."
	| oldDefault |
	oldDefault := default.
	aClassOrNil ifNotNil: [ self register: aClassOrNil ].
	default := aClassOrNil.
	^ oldDefault
]

{ #category : #accessing }
AppRegistry class >> defaultOrNil [
	^ default
]

{ #category : #registration }
AppRegistry class >> register: aProviderClass [
	(self registeredClasses includes: aProviderClass) ifFalse:
		[default := nil.  "so it'll ask for a new default, since if you're registering a new app you probably want to use it"
		self registeredClasses add: aProviderClass].
]

{ #category : #registration }
AppRegistry class >> registeredClasses [
	^ registeredClasses ifNil: [registeredClasses := OrderedCollection new]
]

{ #category : #registration }
AppRegistry class >> removeObsolete [
	"AppRegistry removeObsoleteClasses"
	self registeredClasses copy do:[:cls| 
		(cls class isObsolete or:[cls isBehavior and:[cls isObsolete]]) 
			ifTrue:[self unregister: cls]].
	self subclasses do:[:cls| cls removeObsolete].
]

{ #category : #registration }
AppRegistry class >> unregister: aProviderClass [
	(default = aProviderClass) ifTrue: [default := nil].
	self registeredClasses remove: aProviderClass ifAbsent: [].
]
