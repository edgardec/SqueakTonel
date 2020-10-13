Class {
	#name : #SqueakMessageCategoriesHelp,
	#superclass : #SqueakToolsHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #private }
SqueakMessageCategoriesHelp class >> addAllCategoriesTopicTo: newTopic [
	
	| mapping allCategoriesTopic |
	allCategoriesTopic := HelpTopic 
		title: 'All message categories'
		icon: (HelpIcons iconNamed: #bookIcon)
		contents: self allCategoriesExplanation.
	
	mapping := IdentityDictionary new.
	SystemNavigation allBehaviorsDo: [:behavior |
		((behavior organization categories 
			reject: [:category | category first = $*])
			collect: [:category | (category findTokens: '-') first withBlanksTrimmed])
			do: [:category |
				(mapping at: category asLowercase asSymbol ifAbsentPut: [Set new]) add: behavior]].
	
	mapping keys sorted do: [:categoryName |
		allCategoriesTopic addSubtopic: (HelpTopic
			title: categoryName
			icon: (HelpIcons iconNamed: #pageIcon)
			contents: (((mapping at: categoryName) collect: [:c | c printString]) sorted joinSeparatedBy: ',' , String crlf))]. 
		
	^ newTopic addSubtopic: allCategoriesTopic
]

{ #category : #private }
SqueakMessageCategoriesHelp class >> addCategoryTopicsTo: aTopic [

	self selectors sorted do: [:selector | | helpContents examples |
		examples := (self new perform: selector).
		examples := examples isCollection ifTrue: [examples] ifFalse: [#()].
		
		helpContents := (self commentsAt: selector) first asText,
			String crlf asText , String crlf asText ,
			('Examples:' asText allBold; yourself) , 
			String crlf asText , 
			((examples collect: [:m | m reference]) joinSeparatedBy: ', ' , String crlf) asText.
		
		aTopic addSubtopic: ((HelpTopic 
								title: (self organization categoryOfElement: selector)
								icon: (HelpIcons iconNamed: #pageIcon)
								contents: helpContents)
								priority: 999;
								yourself)]
]

{ #category : #contents }
SqueakMessageCategoriesHelp class >> allCategoriesExplanation [

	^ 'This chapter contains a list of all message categories used in the system and in which classes they are used.'
]

{ #category : #converting }
SqueakMessageCategoriesHelp class >> asHelpTopic [

	| newTopic |
	newTopic := HelpTopic 
		title: 'Message categories' 
		icon: (HelpIcons iconNamed: #bookIcon)
		contents: self mainTopicExplanation.
		
	self 
		addCategoryTopicsTo: newTopic;
		addAllCategoriesTopicTo: newTopic.	
		
	^ newTopic
		
]

{ #category : #contents }
SqueakMessageCategoriesHelp class >> mainTopicExplanation [

	^ 'Message categories are useful for readers of a class to distinguish between different aspects of the class. Depending on the category users might have a different perspective on the class they look at. Selecting the right message category can be difficult as there might be several categories the method would fit into. The following guidelines might help with judging where to put methods:
	
1. Look for matching method categories in common classes such as Collections, Magnitude, or Object. Depending on the domain of your method this might also include common, but specialized, classes such as Form, Morph, AbstractSound and so on.

2. If the category you would like to use is already very full or does not describe the concern of your method very well, consider using subcategories. You can specify one by putting a dash between the category name and the subcategory name, e.g. ''menu - layout menu''.

3. Method categories are often used to denote whether a method should only be called by an object on itself. Such methods are often sorted into the ''private'' category. This immediately indicates which methods should rather not be used by other objects. At the same time the ''private'' category is very generic and does not help readers very much. Thus, consider using a subcategory which describes the concern of the method.

This chapter further contains a more detailed description of some of the message categories and a separate subchapter listing all categories used in the system. The detailed descriptions all contain a list of example methods and, where appropriate, specify the meaning of the category in different contexts (e.g. packages or particular class hierarchies).'
]

{ #category : #accessing }
SqueakMessageCategoriesHelp class >> priority [

	^ 9999 "at the bottom"
]

{ #category : #arithmetic }
SqueakMessageCategoriesHelp >> arithmetic [
"This category contains methods implementing all kinds of arithmetic operations. Note that the content of the method and not the selector is relevant for whether a method belongs to that category. A method with the selector #+ that implements the composition of two things which is not the arithmetic addition does not belong here.  (For example TraitComposition>>#+)"

	^ {Fraction>>#+ . Point>>#//}
]

{ #category : #comparing }
SqueakMessageCategoriesHelp >> comparing [
"This category contains all methods for comparing objects. The main selectors are #= and #hash which should both be implemented consistently. Subclasses such as Magnitude add specialized selectors such as #<=."

	^ { Object>>#= . String>>#charactersExactlyMatching: }
]

{ #category : #converting }
SqueakMessageCategoriesHelp >> converting [
"This category contains methods for converting objects to other representations. 
Note: For converting to string representations for displaying or storing see the 'printing' category."

	^ {Object>>#asString . PositionableStream>>#asBinaryOrTextStream}
]

{ #category : #copying }
SqueakMessageCategoriesHelp >> copying [
"This category contains methods for different ways to copy an object. The standard method is #copy which is mapped to specialized methods."

	^ {Object>>#postCopy . String>>#copyReplaceTokens:with: }
]

{ #category : #debugging }
SqueakMessageCategoriesHelp >> debugging [
"The debugging category contains all kinds of methods related to debugging."

	^ {Object>>#inspectOnce . Object>>#haltIf:}
]

{ #category : #displaying }
SqueakMessageCategoriesHelp >> displaying [
"In the context of the ST80 package this category contains methods for displaying an object on screen. This is related to the drawing category in Morphic."

	^ {FormView>>#displayOn: . Circle>>#displayOn:at:clippingBox:rule:fillColor:}
]

{ #category : #drawing }
SqueakMessageCategoriesHelp >> drawing [
"In the context of the Morphic package, the drawing category contains the methods for displaying a Morph on the screen. The main entry points are the 'drawOn:' methods. This category is related to the displaying category in the ST80 package."

	^ {EllipseMorph>>#drawOn: . HandMorph>>#fullDrawOn:}
]

{ #category : #enumerating }
SqueakMessageCategoriesHelp >> enumerating [
"This category is mostly found with classes representing some form of collection. The methods in this category allow all sorts of iteration and enumeration on the receiver."

	^ {Collection>>#select: . HelpBrowser>>#do:}
]

{ #category : #'event handling' }
SqueakMessageCategoriesHelp >> eventHandling [
"In the context of the Morphic package, this category defines methods for processing events and methods Morph classes can override to handle particular events."

	^ {Morph>>#hasFocus . ScrollPane>>#handlesKeyboard:}
]

{ #category : #examples }
SqueakMessageCategoriesHelp >> examples [
"This category is mostly found on meta classes. The methods in this category can be called to create an example instance for the class."

	^ {SystemProgressMorph class>>#exampleLabelOnly . Form class>>#exampleShrink}
]

{ #category : #failures }
SqueakMessageCategoriesHelp >> failures [
"This category is most often used with TestCase classes. It contains any methods denoting failures for this TestCase"

	^ {"There is no stable example method for this"}
]

{ #category : #'initialize-release' }
SqueakMessageCategoriesHelp >> initializeRelease [
"This category contains methods related to initializing and, seldomly, releasing objects. The most common method in here is the #initialize method and any related methods. Further, this category also sometimes includes methods used by clients of the object to set an initial state after the object was initialized by #initialize."

	^ {WeakRegistry>>#initialize . RxMatcher>>#initialize:ignoreCase:}
]

{ #category : #'instance creation' }
SqueakMessageCategoriesHelp >> instanceCreation [
"This category contains methods for creating instances. Most often these are implemented for the class object."

	^ {TestCase class>>#selector: . Symbol class>>#empty}
]

{ #category : #layout }
SqueakMessageCategoriesHelp >> layout [
"In the context of the Morphic package, the layout category contain methods for setting layout policies or layout properties. In subcategories it futher contains methods for controling context menus for setting the layout parameters."

	^ {Morph>>#fullBounds . StringMorph>>#fitContents}
]

{ #category : #menu }
SqueakMessageCategoriesHelp >> menu [
"This category includes all methods related to menus, often context menus in particular. It contains methods defining the menu as well as often callbacks for the labels of menu items or the actions to be executed. Sometimes the menus are split up in different categories if there are multiple menus or submenus."

	^ {Inspector>>#mainFieldListMenu: . SystemWindow>>#makeClosable}
]

{ #category : #printing }
SqueakMessageCategoriesHelp >> printing [
"This category contains methods for creating a textual representation of an object, may it be for displaying (#printString) or storing (#storeOn:)."

	^ {Character>>#printOn: . Object>>#storeString}
]

{ #category : #private }
SqueakMessageCategoriesHelp >> private [
"This category contains methods which are only (and should only be) used by the containing class and its relatives up and down the class hierarchy. Often these methods expect a particular object state and are only useful in a particular control flow. One common reason for that is that the method is only a substep of a more elaborate process."

	^ {Monitor>>#privateCleanup . Collection>>#emptyCheck}
]

{ #category : #removing }
SqueakMessageCategoriesHelp >> removing [
"The 'removing' category is mostly used with objects representing collections of some kind and include methods for "

	^ {MethodDictionary>>#removeAll . ProcessorScheduler>>#remove:ifAbsent:}
]

{ #category : #running }
SqueakMessageCategoriesHelp >> running [
"In the context of a TestCase class, the 'running' category most often contains the #setUp and #tearDown methods."

	^ {ClipboardTest>>#setUp . LocaleTest>>#tearDown}
]

{ #category : #testing }
SqueakMessageCategoriesHelp >> testing [
"The testing category contains predicate methods which typically answer a Boolean value."

	^ {SMPackage>>#isAvailable . FontImporterFontDescription>>#hasChildren}
	
]

{ #category : #tests }
SqueakMessageCategoriesHelp >> tests [
"The tests category contains test methods in a TestCase class."

	^ {MCAncestryTest>>#testLinearPath . DurationTest>>#testNegated}
	
	
]
