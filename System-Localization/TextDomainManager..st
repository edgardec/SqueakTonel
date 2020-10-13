"
I manage mapping from class category to textdomain.

Class variables:
 ClassCategories	IdentityDictionary -- classCategory -> domainName 
 Classes			IdentityDictionary -- class name (a Symbol) -> domainName   (a cache only!)
 DefaultDomain	String -- the default domain name
 DomainInfos		Dictionary -- domainName -> a TextDomainInfo
 LoneClasses		IdentityDictionary -- class name (a Symbol) -> domainName.  For classes whose entire category are not all in the same domain (BookMorph and QuickGuideMorph)

TextDomainManager registerCategoryPrefix: 'DrGeoII' domain: 'DrGeoII'.
TextDomainManager unregisterDomain: 'DrGeoII'.

TextDomainManager registerClass: #QuickGuideMorph domain: 'quickguides'.
TextDomainManager registerClass: #QuickGuideHolderMorph  domain: 'quickguides'.

"
Class {
	#name : #TextDomainManager,
	#superclass : #Object,
	#classVars : [
		'ClassCategories',
		'Classes',
		'DefaultDomain',
		'DomainInfos',
		'LoneClasses',
		'Packages'
	],
	#classInstVars : [
		'defaultDomain'
	],
	#category : #'System-Localization'
}

{ #category : #accessing }
TextDomainManager class >> allKnownDomains [
	"Every package has its own text domain now so it's not necessary to keep a registry of all domains, we can simply return all the packages in the image.
	PROBLEM: If a package doesn't contain translations, it won't have a mo file but the GetTextTranslator will try to load it anyway. This happens when we switch languages. So far I tested it briefly and it seems to work..."
	^PackageOrganizer default packageNames , {'Etoys-Tiles'}
]

{ #category : #private }
TextDomainManager class >> cleanUp: aggressive [
	aggressive ifTrue: [self clearAllDomains].
]

{ #category : #private }
TextDomainManager class >> clearAllDomains [
	"TextDomainManager clearAllDomains"
	self systemNavigation allBehaviorsDo:
		[:b|
		b selectorsAndMethodsDo:
			[:s :m |
			m removeProperty: self textDomainProperty ifAbsent: []]]
]

{ #category : #accessing }
TextDomainManager class >> defaultDomain [
	"I'm not sure we still need a default domain. AFAIK the default domain will only be used when no domain is found. In that case, wouldn't it be better to just look for a translation in all domains?"
	^defaultDomain
]

{ #category : #accessing }
TextDomainManager class >> defaultDomain: aDomainName [
	defaultDomain := aDomainName
]

{ #category : #accessing }
TextDomainManager class >> domainForClass: aClass [
	^'etoys'
]

{ #category : #accessing }
TextDomainManager class >> domainForPackage: aPackageInfo [
	"Package names and text domains are synonyms now"
	^aPackageInfo name
]

{ #category : #accessing }
TextDomainManager class >> domainOfMethod: aCompiledMethod [ 
	^ aCompiledMethod
		propertyValueAt: self textDomainProperty
		ifAbsent: [self updateDomainOfMethod: aCompiledMethod] 
]

{ #category : #'class initialization' }
TextDomainManager class >> initialize [
	"	TextDomainManager initialize	"
	self defaultDomain: 'Etoys'
]

{ #category : #private }
TextDomainManager class >> textDomainProperty [
	^#textDomain
]

{ #category : #private }
TextDomainManager class >> updateDomainOfAllMethodsWithTranslations [
	self allMethodsWithTranslations do: [:each |
		self updateDomainOfMethod: each]
]

{ #category : #private }
TextDomainManager class >> updateDomainOfMethod: aCompiledMethod [ 
	"First it looks for the package of the method reference (using
	the PackageOrganizer: deadly slow). If the method doesn't
	belong to any package it uses the default domain. Finally it
	stores the text domain of the method using a method
	property, this way we gain performance the next time we
	translate the same method because we avoid the use of
	PackageOrganizer. Have I mentioned it is really slow? :)"
	| package |
	package := PackageOrganizer default
				packageOfMethod: aCompiledMethod methodReference
				ifNone: [].
	^ aCompiledMethod
		propertyValueAt: self textDomainProperty
		put: (package isNil
				ifTrue: [TextDomainManager defaultDomain]
				ifFalse: [package name])
]
