"
This is the AppRegistry class for class browsing
"
Class {
	#name : #SystemBrowser,
	#superclass : #AppRegistry,
	#classVars : [
		'BrowseWithDragNDrop',
		'BrowseWithPrettyPrint'
	],
	#category : #'Tools-Base'
}

{ #category : #registration }
SystemBrowser class >> addRegistryMenuItemsTo: aMenu inAccountOf: aBrowser [ 
	"Add some useful options related Browser registry to the
	browsers windows menu"
	aMenu addLine;
		add: 'Register this Browser as default'
		target: [self default: aBrowser class]
		action: #value;
		add: 'Choose new default Browser'
		target: self
		action: #askForDefault
]

{ #category : #preferences }
SystemBrowser class >> browseWithDragNDrop [
	<preference: 'Browse with drag ''n'' drop' category: 'browsing' description: 'If true, new browsers will open with drag & drop functionality (only in Morphic)' type: #Boolean>
	^ BrowseWithDragNDrop ifNil: [false].
]

{ #category : #preferences }
SystemBrowser class >> browseWithDragNDrop: aBoolean [
	BrowseWithDragNDrop := aBoolean.
]

{ #category : #preferences }
SystemBrowser class >> browseWithPrettyPrint [
	<preference: 'Browse with pretty-print' category: 'browsing' description: 'If true, browsers will automatically format their contents' type: #Boolean>
	^ BrowseWithPrettyPrint ifNil: [false].
]

{ #category : #preferences }
SystemBrowser class >> browseWithPrettyPrint: aBoolean [
	BrowseWithPrettyPrint := aBoolean.
]

{ #category : #preferences }
SystemBrowser class >> browserShowsPackagePane [
	<preference: 'Browser shows package pane' category: 'browsing' description: 'If true, then the various ''browse full'' and ''browse it'' commands (usually invoked via cmd-b) will open a Package Browser rather than a System Browser.  The Package Browser includes a package pane which groups system categories into packages based on the initial portion of their category name.' type: #Boolean>
	^ SystemNavigation default browserClass == PackagePaneBrowser.
]

{ #category : #preferences }
SystemBrowser class >> browserShowsPackagePane: aBoolean [
	| theOtherOne |
	self registeredClasses size = 2
		ifTrue: [theOtherOne := (self registeredClasses copyWithout: PackagePaneBrowser) first]
		ifFalse: [theOtherOne := nil].
	aBoolean
		ifTrue: [self default: PackagePaneBrowser]
		ifFalse: [self default: theOtherOne].
	SystemNavigation default browserClass: self default.
]

{ #category : #'instance creation' }
SystemBrowser class >> defaultOpenBrowser [
	^self default openBrowser
]
