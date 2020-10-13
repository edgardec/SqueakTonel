"
A ServiceProvider references services that are relevant to a given application.

Each application that wishes to use the Services framework must subclass a ServiceProvider.
This class must define a 'services' method category.
Each method implemented in this category will be automatically called by the framework.
Each of these method should be a unary message (taking no argument), and return a fully initialised instance of ServiceAction or ServiceCategory. There are three possible patterns:

1)

serviceIdentifierAndMethodName
	^ ServiceAction
		text: 'Menu item text'
		button: 'Button text'
		description: 'Longer text that appears in help balloons'
		action: [:r | ""Code block fetching data from the requestor instance, r, that is passed to the block""]
		

2)

serviceIdentifierAndMethodName
	^ ServiceAction
		text: 'Menu item text'
		button: 'Button text'
		description: 'Longer text that appears in help balloons'
		action: [:r | ""Code block fetching data from the requestor instance, r, that is passed to the block""]
		condition: [:r | ""second block returning true if the service can be used at the time being, false otherwise. Data can still be fetched from the requestor instance""]
		
3)

methodNameAndServiceCategoryId
	^ ServiceCategory 
		text: 'Menu text' 
		button: 'Button  text' 
		description: 'Longer descriptive text appearing in help balloons'
	

The organisation of services into categories, and the services bound to keyboard shortcuts are
specified using the Services Browser (see the comment on the class ServicePreferences for more details). When editing preferences, they are saved as methods on the ServiceProvider, all defined
in the 'saved preferences' method category. Each of thesse methods stores preferences that the provider can replay.

"
Class {
	#name : #ServiceProvider,
	#superclass : #Object,
	#category : #'Services-Base'
}

{ #category : #'provider creation' }
ServiceProvider class >> newProviderFor: packageName [
	| cls clsName |
	clsName := ((packageName copyWithout: $-) , 'ServiceProvider') asSymbol.
	cls := self subclass: clsName
		instanceVariableNames: '' 
		classVariableNames: '' 
		poolDictionaries: ''
		category: packageName.
	cls class compile: 'initialize 
	ServiceRegistry current buildProvider: self new' classified: 'initialization'.
	^ cls
]

{ #category : #accessing }
ServiceProvider class >> registeredProviders [
	^ self allSubclasses collect: [:each | each new]
]

{ #category : #accessing }
ServiceProvider >> performAndSetId: aSymbol [ 
	| service |
	service := self perform: aSymbol.
	service id: aSymbol.
	^service
]

{ #category : #accessing }
ServiceProvider >> registeredServices [
	
	^ self services collect: [:each | self performAndSetId: each]
]

{ #category : #persistence }
ServiceProvider >> replayPreferences [
	ServicePreferences replayPreferences: self savedPreferences
]

{ #category : #persistence }
ServiceProvider >> savePreferencesFor: aService [ 
	
	"pref := ServicePreferences preferenceAt: aService shortcutPreference.
	strm := WriteStream with: ''.
	strm nextPutAll: aService id;
		 nextPutAll: 'shortcut';
		 cr;
		 tab;
		 nextPutAll: '^ ';
		 nextPutAll: {pref name. pref preferenceValue. 1000} storeString.
	self class compileSilently: strm contents classified: 'saved preferences'."
	aService isCategory
		ifTrue: [aService externalPreferences
				doWithIndex: [:e :i | | strm | 
					strm := WriteStream with: aService id asString.
					strm nextPutAll: e id asString;
						 cr;
						 tab;
						 nextPutAll: '^ ';
						 nextPutAll: {aService childrenPreferences. e id. i} storeString.
					e provider class compileSilently: strm contents classified: 'saved preferences']]
]

{ #category : #persistence }
ServiceProvider >> savedPreferences [
	 ^ (self class organization listAtCategoryNamed: #'saved preferences')
			collect: [:e | self perform: e]
]

{ #category : #accessing }
ServiceProvider >> services [
	^ self class organization listAtCategoryNamed: #services
]
