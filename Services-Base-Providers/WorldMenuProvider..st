"
I define services and categories:
- The world menu category (identifier:  world), where services and categories can be put to be displayed in the world menu.
- The preferencesMenu category, where services about services and preferences can be put
- th open menu
"
Class {
	#name : #WorldMenuProvider,
	#superclass : #ServiceProvider,
	#category : #'Services-Base-Providers'
}

{ #category : #'initialize-release' }
WorldMenuProvider class >> initialize [
	ServiceRegistry current buildProvider: self new
]

{ #category : #'saved preferences' }
WorldMenuProvider >> browserMethodMenucreateNewService [
	^ #(#'Items in browserMethodMenu:' #createNewService 1 )
]

{ #category : #services }
WorldMenuProvider >> closeTopWindow [
	^ ServiceAction
		text: 'Close top window'
		button: 'close window'
		description: 'Closes the focused window'
		action: [:r | SystemWindow topWindow delete]
]

{ #category : #'service registering' }
WorldMenuProvider >> convertOpenCommand: array [ 
	| description |
	description := array size > 2 
				ifTrue: [array third]
				ifFalse: ['none available'].
	^ServiceAction 
		id: array first asSymbol
		text: array first
		button: array first
		description: description
		action: [array second first perform: array second second]
]

{ #category : #services }
WorldMenuProvider >> createNewService [
	^ ServiceAction 
		text: 'Create new service' 
		button: 'new service' 
		description: 'Define a new service provided by this package' 
		action: [:r | | s p |
			s := r caption: 'enter service identifier'; getSymbol.
			p := r getPackageProvider.
			p compile: s, ' 
	^ ServiceAction 
		"Open the service browser to set the menu position and the keyboard shortcut"
		text: ''fill menu label''
		button: ''short button text''
		description: ''longer text for balloon help''
		action: [:r | "action block"]
		condition: [:r | "optional condition block"]' classified: 'services'.
			r getBrowser browseReference: (MethodReference class: p selector: s)]
]

{ #category : #services }
WorldMenuProvider >> helpOnServices [
	^ ServiceAction
		text: 'Help on Services'
		button: 'services help'
		description: 'Introductory text about services'
		action: [StringHolder new contents: self servicesHelpText; openLabel: 'Introduction to Services'].
]

{ #category : #services }
WorldMenuProvider >> nextWindow [
	^ ServiceAction text: 'Switch to next window' button: 'next window' description: 'Switches to the next window' action: [:r | SystemWindow sendTopWindowToBack]
]

{ #category : #services }
WorldMenuProvider >> openMenu [
	^ ServiceCategory text: 'Open' button: 'open' description: 'The open menu'
]

{ #category : #services }
WorldMenuProvider >> preferencesBrowser [
	^ ServiceAction text: 'Preference Browser' button: 'pref. browser' description: 'Open the preference browser to edit various Squeak settings' action: [PreferenceBrowser open].
]

{ #category : #services }
WorldMenuProvider >> preferencesMenu [
	^ ServiceCategory text: 'Preferences & Services' button: 'preferences' description: 'Menu related to editing preferences'
]

{ #category : #'saved preferences' }
WorldMenuProvider >> preferencesMenuhelpOnServices [
	^ #(#'Items in preferencesMenu:' #helpOnServices 3 )
]

{ #category : #'saved preferences' }
WorldMenuProvider >> preferencesMenupreferencesBrowser [
	^ #(#'Items in preferencesMenu:' #preferencesBrowser 1 )
]

{ #category : #'saved preferences' }
WorldMenuProvider >> preferencesMenurebuildRegistry [
	^ #(#'Items in preferencesMenu:' #rebuildRegistry 4 )
]

{ #category : #'saved preferences' }
WorldMenuProvider >> preferencesMenuservicesBrowser [
	^ #(#'Items in preferencesMenu:' #servicesBrowser 2 )
]

{ #category : #'saved preferences' }
WorldMenuProvider >> preferencesMenushortcut [
	^ #(#'Shortcut for preferencesMenu:' '' 1000 )
]

{ #category : #services }
WorldMenuProvider >> rebuildRegistry [
	^ ServiceAction text: 'Rebuild service registry' button: 'rebuild registry' description: 'Rebuilds the service registry to scan for newly defined services' action: [ServiceRegistry rebuild].
]

{ #category : #services }
WorldMenuProvider >> servicesBrowser [
	^ ServiceAction text: 'Services Browser' button: 'services' description: 'Open a preference browser to edit several Squeak menus' action: [PreferenceBrowser openForServices].
]

{ #category : #accessing }
WorldMenuProvider >> servicesHelpText [
	^ '
	This is an overview of the main concepts of the services framework. More details are available in class comments. The aim is to help you defining services step by step. The three main classes are: 

-ServiceAction
-ServiceCategory
-ServiceProvider

Alongside them, a tool to use is the Services Browser. It can be found in the world menu, under the ''Preferences & Services'' menu heading (in which you found this text).
	
	ServiceAction are executable objects in various contexts.
They can be displayed as buttons or menu items or bounded to keyboard shortcuts.

	ServiceCategory are categories of services. They are also services, so a ServiceCategory can be included in another, forming a tree of Services. ServiceCategories can be displayed with menus, or button bars.
	
	A ServiceProvider references services that are relevant to a given application.
Each application that wishes to use the Services framework must subclass a ServiceProvider.
This class must define a ''services'' method category.
Each method implemented in this category will be automatically called by the framework.
Each of these method should be a unary message (taking no argument), and return a fully initialised instance of ServiceAction or ServiceCategory. There are three possible patterns:

1)
serviceIdentifierAndMethodName
	^ ServiceAction
		text: ''Menu item text''
		button:''Button text''
		description: ''Longer text that appears in help balloons''
		action: [:r | "Code block fetching data from the requestor instance, r, that is passed to the block"]
		
2)
serviceIdentifierAndMethodName
	^ ServiceAction
		text: ''Menu item text''
		button: ''Button text''
		description: ''Longer text that appears in help balloons''
		action: [:r | "Code block fetching data from the requestor instance, r, that is passed to the block"]
		condition: [:r | "second block returning true if the service can be used at the time being, false otherwise. Data can still be fetched from the requestor instance"]
		
3)
methodNameAndServiceCategoryId
	^ ServiceCategory 
		text: ''Menu text''
		button: ''Button  text'' 
		description: ''Longer descriptive text appearing in help balloons''

The block given to the ServiceActions can take an instance of the Requestor class as parameter. You can fetch data from these. The generic format is to call methods starting with ''get'' on the requestor, like getClass, getMessageName for services related to the browser.	

The organisation of services into categories, and the services bound to keyboard shortcuts are
specified using the Services Browser, based on the Preference Browser by Hernan Tylim. When editing preferences, they are saved as methods on the ServiceProvider, all defined in the ''saved preferences'' method category. 

When opening the Services Browser you see a list of preference categories on the left, and the preferences inside this category on the right. The main preference categories for services are: 

-- keyboard shortcuts -- : several text preferences, one per keyboard shortcuts. To edit them,  enter a service identifier (equal to the method name under which it is defined in its ServiceProvider), and accept with alt-s or enter

-- menu contents -- : All the service categories in the image have a text preference under here. To edit it, enter the services identifiers you wish to put in this category, separating them with a single space character. The order is important: it defines the order of the items in menus.

-- settings -- : general boolean preferences.

Then there is a preference category for each provider in the image. Under each, you will find:
A boolean preference for each service in the image. If it is false, the service will not appear in menus. 
The text preference for each service category defined by the service provider. This is the same as the one appearing in the menu contents preference category.

Some identifiers of categories already appearing in the UI are:
- world : the world menu
- preferencesMenu
- browserClasssCategoryMenu
- browserClassMenu
- browserMethodCategoryMenu
- browserMethodMenu
- browserCodePaneMenu
- browserButtonBar

After editing these preferences to match the services and categories you defined for your application, you should be done.

	Romain Robbes'
]

{ #category : #services }
WorldMenuProvider >> world [
	^ ServiceCategory text: 'World' button: 'world' description: 'The world menu'
]

{ #category : #'saved preferences' }
WorldMenuProvider >> worldpreferencesMenu [
	^ #(#'Items in world:' #preferencesMenu 1 )
]

{ #category : #'saved preferences' }
WorldMenuProvider >> worldshortcut [
	^ #(#'Shortcut for world:' '' 1000 )
]
