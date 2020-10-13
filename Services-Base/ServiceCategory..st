"
I represent a category of services that can be added to a menu.
I can be displayed as a menu or button bar containing my services.
I am also a subclass of ServiceAction, so I can form a subcategory of another service category.

Like services, I am created in methods of a ServiceProvider, in the 'services' method protocol.
The template to create a service category is the following:

methodNameAndServiceCategoryId
	^ ServiceCategory 
		text: 'Menu text' 
		button: 'Button  text' 
		description: 'Longer descriptive text appearing in help balloons'
	
To put services in a service category, you have to use the Service Browser, located in the word menu, under the 'Preferences and Services' menu item.
In it, you can look up for the name of your category, and enter service identifiers as children
of the category in the associatedd text field, separating them with spaces.
"
Class {
	#name : #ServiceCategory,
	#superclass : #ServiceAction,
	#instVars : [
		'services'
	],
	#category : #'Services-Base'
}

{ #category : #'instance creation' }
ServiceCategory class >> text: aStringOrBlock button: buttonString description: aString [
	"use when id can be generated"
	^ self id: nil text: aStringOrBlock button: buttonString description: aString action: [] 
]

{ #category : #preferences }
ServiceCategory >> childrenPreferences [
		^ ('Items in ', self id, ':') asSymbol
]

{ #category : #accessing }
ServiceCategory >> enabledServices [
	^ services
		select: [:e | e isEnabled]
]

{ #category : #executing }
ServiceCategory >> execute [
	"displays the subservices as a submenu"
	ServiceGui openMenuFor: self
]

{ #category : #preferences }
ServiceCategory >> externalPreferences [
	| p |
	p := ServicePreferences valueOfPreference: self childrenPreferences ifAbsent: [''].
	^ (p findTokens: ' ') collect: [:e | e service]
]

{ #category : #'initialize-release' }
ServiceCategory >> initialize [

	services := OrderedCollection new.
	super initialize.
	

]

{ #category : #preferences }
ServiceCategory >> insertPreferences [
	super insertPreferences.
	ServicePreferences 
		addPreference: self childrenPreferences
		categories: { 
				(#'-- menu contents --').
				(self providerCategory)}
		default: ''
		balloonHelp: self description
		projectLocal: false
		changeInformee: self id -> #updateChildren
		changeSelector: #serviceUpdate
		type: #String
]

{ #category : #testing }
ServiceCategory >> isCategory [
	^ true
]

{ #category : #preferences }
ServiceCategory >> newChildren [
	| s |
	s := ServicePreferences valueOfPreference: self childrenPreferences.
	^ (s findTokens: ' ') collect: [:str | str serviceOrNil]
]

{ #category : #preferences }
ServiceCategory >> newChildrenValid [
	| s |
	s := ServicePreferences valueOfPreference: self childrenPreferences.
	^ (s findTokens: ' ') allSatisfy: [:str | 
		str serviceOrNil 
			ifNil: [ServiceRegistry ifInteractiveDo: 
						[self inform: str, ' is not a valid service name']. 
					false]
			ifNotNil: [true]]
]

{ #category : #preferences }
ServiceCategory >> prefServices [
	| s |
	s := ServicePreferences valueOfPreference: self childrenPreferences.
	^ (s findTokens: ' ') collect: [:str | str service]
]

{ #category : #preferences }
ServiceCategory >> replaceChildren [
	ServiceRegistry ifInteractiveDo: [services
		do: [:s | s provider
				ifNotNil: [:p | p class removeSelector: (self id , s id) asSymbol]]].
	services := self newChildren.
	services
		do: [:e | 
			(ServicePreferences preferenceAt: e shortcutPreference)
				ifNotNil: [:p | p categoryList: {'-- keyboard shortcuts --'. self id asString}].
			ServiceRegistry
				ifInteractiveDo: [self provider savePreferencesFor: self]]
]

{ #category : #accessing }
ServiceCategory >> requestor: aRequestor [
	super requestor: aRequestor.
	self services do: [:s | s requestor: aRequestor]
]

{ #category : #accessing }
ServiceCategory >> services [
	^services
]

{ #category : #preferences }
ServiceCategory >> updateChildren [

	self newChildrenValid
		ifTrue: [self replaceChildren].
	"PreferenceBrowserMorph updateBrowsers."
	ServiceGui updateBar: self
]
