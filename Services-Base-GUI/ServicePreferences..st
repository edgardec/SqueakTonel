"
I store the preferences related to the services framework. The preferences are editable via the Services Browser, based on Hernan Tylim's Preference Browser.

The main preference categories for services are: 

-- keyboard shortcuts -- : several text preferences, one per keyboard shortcuts. To edit them,  enter a service identifier (equal to the method name under which it is defined in its ServiceProvider), and accept with alt-s or enter

-- menu contents -- : All the service categories in the image have a text preference under here. To edit it, enter the services identifiers you wish to put in this category, separating them with a single space character. The order is important: it defines the order of the items in menus.

-- settings -- : general boolean preferences.

Then there is a preference category for each provider in the image. Under each, you will find:
A boolean preference for each service in the image. If it is false, the service will not appear in menus. 
The text preference for each service category defined by the service provider. This is the same as the one appearing in the menu contents preference category.
"
Class {
	#name : #ServicePreferences,
	#superclass : #Preferences,
	#category : #'Services-Base-GUI'
}

{ #category : #accessing }
ServicePreferences class >> compileAccessorForPreference: aPreference [
	"do nothing"
]

{ #category : #replaying }
ServicePreferences class >> replayPreferences: preferences [ 

	(preferences sorted: [ :a :b | a last < b last ])
		do: [:e | | v | 
			v := self valueOfPreference: e first ifAbsent: ''.
			self setPreference: e first toValue: (v
					ifEmpty: ['']
					ifNotEmpty: [v , ' '])
					, e second]
]

{ #category : #accessing }
ServicePreferences class >> wipe [
	preferencesDictionary := nil
]
