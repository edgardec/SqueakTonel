"
I define the default categories of services dealing with browsing:
- the class category menu (service identifier: browserClassCategoryMenu)
- the class menu (browserClassMenu)
- the method category menu (browserMethodCategoryMenu)
- the browser method menu (browserMethodMenu)
- the browser button bar (browserButtonBar)
- the browser code pane/selection menu (browserCodePaneMenu)
"
Class {
	#name : #BrowserProvider,
	#superclass : #ServiceProvider,
	#category : #'Services-Base-Providers'
}

{ #category : #'initialize-release' }
BrowserProvider class >> initialize [
	ServiceRegistry current buildProvider: self new
]

{ #category : #services }
BrowserProvider >> browser [
	^ ServiceCategory  text: 'Browser' 
					button: 'browser' 
					description: 'The browser menus'
]

{ #category : #services }
BrowserProvider >> browserButtonBar [
	^ ServiceCategory 
		 text:'button bar'
		 button:'button'
		 description:'the browser button bar'
]

{ #category : #services }
BrowserProvider >> browserClassCategoryMenu [
	^ ServiceCategory 
		 text:'Class Category'
		 button:'class cat'
		 description:'The browser class category menu'
]

{ #category : #services }
BrowserProvider >> browserClassMenu [
	^ ServiceCategory 
		 text:'Class'
		 button:'class'
		 description:'The browser class menu'
]

{ #category : #'saved preferences' }
BrowserProvider >> browserClassMenushortcut [
	^ #(#'Shortcut for browserClassMenu:' '' 1000 )
]

{ #category : #services }
BrowserProvider >> browserCodePaneMenu [
	^ ServiceCategory text: 'Code Pane' 
						button: 'pane' 
						description: 'The browser code pane menu'
]

{ #category : #services }
BrowserProvider >> browserMethodCategoryMenu [
	^ ServiceCategory 
		 text:'Method Category'
		 button:'method cat'
		 description:'The browser method menu'
]

{ #category : #services }
BrowserProvider >> browserMethodMenu [
	^ ServiceCategory 
		 text:'Method'
		 button:'method'
		 description:'The browser method menu'
]

{ #category : #'saved preferences' }
BrowserProvider >> browserMethodMenushortcut [
	^ #(#'Shortcut for browserMethodMenu:' '' 1000 )
]
