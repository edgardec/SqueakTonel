"
The ServiceRegistry is the repository in which services are stored. They are stored in
a dictionary, and keyed by their identifier (which is the name of the method they were defined in).

The registry handles the intialization, building and referencing processes as well.
"
Class {
	#name : #ServiceRegistry,
	#superclass : #Object,
	#instVars : [
		'services',
		'interactive'
	],
	#classVars : [
		'Current'
	],
	#category : #'Services-Base'
}

{ #category : #'as yet unclassified' }
ServiceRegistry class >> current [
	^ Current ifNil: [Current := self new]
]

{ #category : #'as yet unclassified' }
ServiceRegistry class >> ifInteractiveDo: aBlock [
	self current isInteractive ifTrue: [aBlock value]
]

{ #category : #'as yet unclassified' }
ServiceRegistry class >> initialize [

	self rebuild.
	SystemChangeNotifier uniqueInstance
		notify: self
		ofSystemChangesOfItem: #method 
		using: #methodChanged:
		
]

{ #category : #'as yet unclassified' }
ServiceRegistry class >> methodChanged: event [
	self ifInteractiveDo: [
	| cls | 
	cls := event itemClass. 
	((event changeKind = #removed) not & (cls inheritsFrom: ServiceProvider) and: [cls new services includes: event itemSelector])
		ifTrue: [[self current addService: (cls new performAndSetId: event itemSelector)
					provider: cls]
			on: Error do: [self inform: 'Service format seems to be incorrect']]]
]

{ #category : #'as yet unclassified' }
ServiceRegistry class >> rebuild [
	| old |
	old := Current.
	[Current := self new.
	Current build]
		on: Error
		do: [:err | (self confirm: 'An error occured during build. 
								Debug it?')
				ifTrue: [err signal].
				Current := old]
]

{ #category : #building }
ServiceRegistry >> addService: aService provider: p [
	services  at:aService id  put:aService.
	aService provider: p.
	aService insertPreferences

]

{ #category : #building }
ServiceRegistry >> beNotInteractiveDuring: aBlock [
	interactive := false.
	aBlock value.
	interactive := true
]

{ #category : #building }
ServiceRegistry >> build [
	"ServicePreferences wipe."
	self
		beNotInteractiveDuring: [
			| pr |
			ServiceProvider registeredProviders
				do: [:p | p registeredServices
						do: [:each | self addService: each provider: p class]].
			pr := ServiceProvider registeredProviders
						gather: [:p | p savedPreferences].
			ServicePreferences replayPreferences: pr.
			].
	ServiceGui updateBars.
	ServiceShortcuts setPreferences
]

{ #category : #building }
ServiceRegistry >> buildProvider: p [
	self beNotInteractiveDuring: [
		p registeredServices do: [:each | self addService: each provider: p class].
		p replayPreferences]
	
]

{ #category : #accessing }
ServiceRegistry >> categories [
	^ self serviceCollection select: [:s | s isCategory]
]

{ #category : #'initialize-release' }
ServiceRegistry >> initialize [
	services := Dictionary new.
	interactive := true
]

{ #category : #accessing }
ServiceRegistry >> isInteractive [
	^ interactive
]

{ #category : #recompilation }
ServiceRegistry >> postRecompileAction [
	"Each ServiceAction in the Current registry holds onto a method.  Rebuild to reference the freshly compiled ones."
	Current ifNotNil: [self rebuild]
]

{ #category : #accessing }
ServiceRegistry >> serviceCollection [
	^ services asArray
]

{ #category : #accessing }
ServiceRegistry >> serviceWithId: aSymbol [
	^ services at: aSymbol 
				ifAbsent: [nil]
]

{ #category : #accessing }
ServiceRegistry >> services [
	^ self serviceCollection reject: [:s | s isCategory]
]
