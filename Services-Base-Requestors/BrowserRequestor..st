"
I am a requestor specialized to fetch information in a Browser.
I can ask a browser its selected class and selected method for example.
If the RB is installed too, I can also fetch ast nodes in the browser's selected
method.

I am the default requestor for CodeHolder and it's subclasses.

To be integrated with services, alternative browsers, such as the OmniBrowser and Whisker should define a specialized requestor subclassing this one. A few core messages would need to be redefined, such as getClass, getMessage ... to be adapted to the browser's data structures. 
Only a few of them have to be overridden, the majority of the requests rely on a few base ones.
"
Class {
	#name : #BrowserRequestor,
	#superclass : #TextRequestor,
	#category : #'Services-Base-Requestors'
}

{ #category : #'initialize-release' }
BrowserRequestor >> browser: b [
	self model: b
]

{ #category : #requests }
BrowserRequestor >> getBrowser [
	^ self getModel
]

{ #category : #requests }
BrowserRequestor >> getClass [
	^ self getBrowser selectedClassOrMetaClass
]

{ #category : #requests }
BrowserRequestor >> getInitializingExpressionForTheNewParameter [
	^ UIManager default request: 'enter default parameter code'
				 initialAnswer: '42'
]

{ #category : #requests }
BrowserRequestor >> getNewSelectorName [
	^ UIManager default  request: 'enter the new selector name'
					initialAnswer: self getSelector
]

{ #category : #requests }
BrowserRequestor >> getNewVariableName [
	^ UIManager default request: 'Enter the new variable name' translated initialAnswer: 'foo'
]

{ #category : #requests }
BrowserRequestor >> getPackage [
	self getSelector ifNil: [
			^ PackageInfo named:(
					self getClass ifNil: [self getSystemCategory] 
									ifNotNil: [:c | c category copyUpTo:  $-])].
	^ PackageOrganizer default 
			packageOfMethod: 
					(MethodReference class: self getClass
										selector: self getSelector)
			ifNone: [PackageInfo named: (self getClass category copyUpTo:  $-)] 
]

{ #category : #requests }
BrowserRequestor >> getPackageForCategory [
	"answers a packageinfo for the current class category"
	^ PackageInfo named: self getClass category
]

{ #category : #requests }
BrowserRequestor >> getPackageForCategoryName [
	"answers a packageinfo for the current class category"
	^  self getPackageForCategory packageName
]

{ #category : #requests }
BrowserRequestor >> getPackageName [
	^ self getPackage packageName
]

{ #category : #requests }
BrowserRequestor >> getPackageProvider [
	| provs classes |
	provs := ServiceProvider registeredProviders.
	classes := self getPackage classes.
	^ classes detect: [:e | provs includes: e] ifNone: [ServiceProvider newProviderFor: self getPackageName]
]

{ #category : #requests }
BrowserRequestor >> getSelection [
	self getBrowser selectedInterval ifEmpty: [^super getSelection].
	^ self getBrowser selectedInterval
]

{ #category : #requests }
BrowserRequestor >> getSelector [
	| s |
	s := self getBrowser selectedMessageName.
	^ s ifNil: [super getSelector] ifNotNil: [s]
]

{ #category : #requests }
BrowserRequestor >> getSelectorCollection [
	self caption: 'enter selector list'.
	^ self getSymbolCollection 
]

{ #category : #requests }
BrowserRequestor >> getSelectorName [
	^ self getBrowser selectedMessageName
]

{ #category : #requests }
BrowserRequestor >> getSystemCategory [
	^ self getBrowser selectedSystemCategory
]
