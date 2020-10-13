"
I provide the test suite for Browser.

"
Class {
	#name : #BrowserTest,
	#superclass : #TestCase,
	#instVars : [
		'browser'
	],
	#category : #'ToolsTests-Browser'
}

{ #category : #running }
BrowserTest >> setUp [
	browser := Browser new.
]

{ #category : #tests }
BrowserTest >> testAlphabetizeMessageCategories [
	| categories |
	browser selectSystemCategory: browser class category.
	self deny: browser alphabetizeMessageCategories.
	
	browser selectClass: browser class.
	browser metaClassIndicated: false.
	self assert: browser alphabetizeMessageCategories.
	categories := browser classOrMetaClassOrganizer categories.
	self assert: (categories select: [:c| c first == $*]) isSorted.
	self assert: (categories select: [:c| c beginsWith: 'private']) isSorted.
	self assert: (categories reject: [:c| c first == $* or: [c beginsWith: 'private']]) isSorted.
	
	browser metaClassIndicated: true.
	self assert: browser alphabetizeMessageCategories.
	self assert: browser classOrMetaClassOrganizer categories isSorted.
]

{ #category : #tests }
BrowserTest >> testAlphabetizeMessageCategoriesLeavesClassSelected [
	browser selectSystemCategory: browser class category.
	browser selectClassNamed: browser class name.
	
	"This is a no-op."
	browser alphabetizeMessageCategories.
	self assert: browser selectedClassName = browser class name.
]

{ #category : #'tests - message list' }
BrowserTest >> testAlphabetizingMethodsPreservesPlace [
	| oldCategory oldMethod |
	oldCategory := 'breakpoints'.
	oldMethod := #toggleBreakOnEntry.
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser selectMessageCategoryNamed: oldCategory.
	browser selectMessageNamed: oldMethod.
	browser alphabetizeMessageCategories.

	self assert: browser selectedMessageCategoryName = oldCategory.
	self assert: browser selectedMessageName = oldMethod.
]

{ #category : #'tests - message list' }
BrowserTest >> testAlphabetizingMethodsPreservesPlaceWhenNoMessageCategorySelected [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser selectMessageCategoryNamed: nil.
	browser selectMessageNamed: nil.
	browser alphabetizeMessageCategories.

	self assert: browser selectedMessageCategoryName = nil.
	self assert: browser selectedMessageName = nil.
]

{ #category : #'tests - message list' }
BrowserTest >> testAlphabetizingMethodsPreservesPlaceWhenNoMethodSelected [
	| oldCategory |
	oldCategory := 'breakpoints'.
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser selectMessageCategoryNamed: oldCategory.
	browser selectMessageNamed: nil.
	browser alphabetizeMessageCategories.

	self assert: browser selectedMessageCategoryName = oldCategory.
	self assert: browser selectedMessageName = nil.
]

{ #category : #tests }
BrowserTest >> testBuildMessageCategoryBrowserEditString [
	| spawn |
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser messageCategoryListIndex: 1.
	browser messageListIndex: 1.
	
	spawn := browser buildMessageCategoryBrowserEditString: 'We don''t yet test that we do the right thing with this string!'.
	[self assert: spawn selectedSystemCategory = browser selectedSystemCategory.
	self assert: spawn selectedClass = browser selectedClass.
	self assert: spawn messageCategoryListIndex = browser messageCategoryListIndex.
	self assert: spawn messageListIndex = browser messageListIndex]
		ensure: [ [ToolBuilder default close: spawn topView] valueSupplyingAnswer: true].
]

{ #category : #tests }
BrowserTest >> testBuildMessageCategoryBrowserEditStringNoCategorySelected [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser messageCategoryListIndex: 0.
	
	self assert: (browser buildMessageCategoryBrowserEditString: 'foo') isNil.
]

{ #category : #tests }
BrowserTest >> testChangeMessageCategoriesLeavesClassSelected [
	browser selectSystemCategory: browser class category.
	browser selectClassNamed: browser class name.
	
	"This is a no-op."
	browser changeMessageCategories: browser classOrMetaClassOrganizer printString.
	self assert: browser selectedClassName = browser class name.
]

{ #category : #tests }
BrowserTest >> testClassCommentAnnotation [
	| annotation |
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	annotation := browser annotationForClassCommentFor: browser class.
	self assert: (annotation includesSubstring: browser class organization commentStamp).
	self assert: (annotation includesSubstring: 'class comment for').
	self assert: (annotation includesSubstring: browser className).
]

{ #category : #tests }
BrowserTest >> testClassCommentAnnotationIgnoresParameter [
	| annotation |
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	"And the method ignores the parameter:"
	annotation := browser annotationForClassCommentFor: browser class superclass.
	self assert: (annotation includesSubstring: browser className).
]

{ #category : #tests }
BrowserTest >> testClassCommentViewingPersists [
	browser selectSystemCategory: browser class category.
	self assert: browser classList size > 1 description: 'We use the first TWO classes in the category!'.
	browser classListIndex: 1.
	browser metaClassIndicated: false.
	browser editComment.
	
	browser classListIndex: 2.
	self assert: browser editSelection = #editComment.
]

{ #category : #tests }
BrowserTest >> testClassDefinitionAnnotation [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	self assert: browser class comment equals: (browser annotationForClassDefinitionFor: browser class).
	"And the method ignores the parameter:"
	self assert: browser class comment equals: (browser annotationForClassDefinitionFor: browser class superclass).
]

{ #category : #tests }
BrowserTest >> testContentsNewClass [
	browser selectSystemCategory: browser class category.

	self assert: (Class template: browser selectedSystemCategory) equals: browser contents.
	
	self flag: #todo. "I don't know how to test the other half of this: see Browser >> #newClassContents".
]

{ #category : #tests }
BrowserTest >> testContentsSelection [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.

	"No category or message selected."
	self assert: browser contentsSelection isEmpty.

	"Category selected, but no message selected."
	browser messageCategoryListIndex: 1.
	browser selectMessageNamed: browser messageList first.
	self assert: browser contentsSelection isEmpty.
	
	"Category and message selected."
	browser selectMessageNamed: nil.
	self deny: browser contentsSelection isEmpty.
]

{ #category : #tests }
BrowserTest >> testCreateHierarchyTreeOf [
	"Empty."
	self assert: (browser createHierarchyTreeOf: #()) isEmpty.
	"Single class."
	self assert: { Browser -> #() } = (browser createHierarchyTreeOf: { Browser }).
	"Single class + 1 subclass"
	self assert: { Browser->{HierarchyBrowser->#()} } = (browser createHierarchyTreeOf: { Browser. HierarchyBrowser. }).
	"Single class + 2 subclasses"
	self assert: { Browser->{HierarchyBrowser->#() . FileContentsBrowser->#()} } = (browser createHierarchyTreeOf: { Browser. HierarchyBrowser. FileContentsBrowser. }).
	"Superclass, class, subclass"
	self assert: { CodeHolder->{Browser->{HierarchyBrowser->#()}} } = (browser createHierarchyTreeOf: { CodeHolder. Browser. HierarchyBrowser. }).
	"Two 'unrelated' classes"
	self assert: {Browser->#() . SmallInteger->#()} = (browser createHierarchyTreeOf: { Browser. SmallInteger }).
	"Two 'unrelated' classes and a common ancestor"
	self assert: {Browser->#() . SmallInteger->#() . ProtoObject->#()} = (browser createHierarchyTreeOf: { Browser. SmallInteger. ProtoObject }).
]

{ #category : #tests }
BrowserTest >> testDefaultClassList [
	browser selectSystemCategory: nil.
	self assert: browser defaultClassList isEmpty.
	
	browser selectSystemCategory: Browser category.
	self assert: browser defaultClassList = (SystemOrganization listAtCategoryNamed: Browser category)
]

{ #category : #tests }
BrowserTest >> testFileOutMessageCategories [
	| fileName |	
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser messageCategoryListIndex: 1.
	
	"Handcrafted from ClassDescription>>fileOutCategory:asHtml:"
	fileName := browser selectedClass name, '-', browser selectedMessageCategoryName, FileDirectory dot, 'st'.
	self deny: (FileDirectory default fileExists: fileName).
	
	[browser fileOutMessageCategories.
	self assert: (FileDirectory default fileExists: fileName).
	] ensure: [FileDirectory default deleteFileNamed: fileName].
]

{ #category : #tests }
BrowserTest >> testFlattenHierarchyTreeOnIndent [
	| flatten |
	flatten := [:coll | (browser
		flattenHierarchyTree: (browser createHierarchyTreeOf: coll)
		on: OrderedCollection new
		indent: '') asArray ].
	"Empty collection."
	self assert: (flatten value: #()) isEmpty.
	"Single class."
	self assert: #('Browser') equals: (flatten value: {Browser}).
	"Single class + subclass."
	self assert: #('Browser' '  HierarchyBrowser') equals: (flatten value: {Browser. HierarchyBrowser}).
	"Single class + 2 subclasses"
	self assert: #('Browser' '  HierarchyBrowser' '  FileContentsBrowser') equals: (flatten value: { Browser. HierarchyBrowser. FileContentsBrowser. }).
	"Superclass, class, subclass"
	self assert: #('CodeHolder' '  Browser' '    HierarchyBrowser') equals: (flatten value: { CodeHolder. Browser. HierarchyBrowser. }).
	"Two 'unrelated' classes"
	self assert: #('Browser' 'SmallInteger') equals: (flatten value: { Browser. SmallInteger }).
	"Two 'unrelated' classes and a common ancestor"
	self assert: #('Browser' 'SmallInteger' 'ProtoObject') equals: (flatten value: { Browser. SmallInteger. ProtoObject }).
]

{ #category : #tests }
BrowserTest >> testFlattenHierarchyTreeOnIndentBy [
	| flatten |
	flatten := [:coll | (browser
		flattenHierarchyTree: (browser createHierarchyTreeOf: coll)
		on: OrderedCollection new
		indent: ''
		by: 'x') asArray ].
	"Empty collection."
	self assert: (flatten value: #()) isEmpty.
	"Single class."
	self assert: #('Browser') equals: (flatten value: {Browser}).
	"Single class + subclass."
	self assert: #('Browser' 'xHierarchyBrowser') equals: (flatten value: {Browser. HierarchyBrowser}).
	"Single class + 2 subclasses"
	self assert: #('Browser' 'xHierarchyBrowser' 'xFileContentsBrowser') equals: (flatten value: { Browser. HierarchyBrowser. FileContentsBrowser. }).
	"Superclass, class, subclass"
	self assert: #('CodeHolder' 'xBrowser' 'xxHierarchyBrowser') equals: (flatten value: { CodeHolder. Browser. HierarchyBrowser. }).
	"Two 'unrelated' classes"
	self assert: #('Browser' 'SmallInteger') equals: (flatten value: { Browser. SmallInteger }).
	"Two 'unrelated' classes and a common ancestor"
	self assert: #('Browser' 'SmallInteger' 'ProtoObject') equals: (flatten value: { Browser. SmallInteger. ProtoObject }).
]

{ #category : #tests }
BrowserTest >> testGetSystemCategoryListIndex [
	| cat |
	cat := browser systemCategoryList first.
	browser selectSystemCategory: cat.
	self assert: browser systemCategoryListIndex = (browser systemCategoryList indexOf: browser selectedSystemCategory).
]

{ #category : #tests }
BrowserTest >> testHasClassSelected [
	browser selectSystemCategory: browser class category.
	self deny: browser hasClassSelected.

	browser selectClass: browser class.
	self assert: browser hasClassSelected.

	browser selectClass: nil.
	self deny: browser hasClassSelected.

	browser selectClassNamed: browser class name asString.
	self assert: browser hasClassSelected.
]

{ #category : #tests }
BrowserTest >> testHasMessageCategorySelected [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser messageCategoryListIndex: 0.
	self deny: browser hasMessageCategorySelected.
	
	browser messageCategoryListIndex: 1.
	self assert: browser hasMessageCategorySelected.
	
	browser messageCategoryListIndex: 0.
	self deny: browser hasMessageCategorySelected.
]

{ #category : #tests }
BrowserTest >> testHasMessageSelected [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser messageCategoryListIndex: 1.
	
	self deny: browser hasMessageSelected.
	
	browser messageListIndex: 0.
	self deny: browser hasMessageSelected.
	
	browser messageListIndex: 1.
	self assert: browser hasMessageSelected.
	
	browser messageListIndex: 0.
	self deny: browser hasMessageSelected.
]

{ #category : #tests }
BrowserTest >> testHomeCategory [
	"This also 'just happens' to test #selectOriginalCategoryForCurrentMethod. It's not appropriate to directly test a private method. (It's a private method because its comment says so, not its category.)"
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser messageCategoryListIndex: 0. "Select -- all --"
	browser selectMessageNamed: browser messageList first.
	browser showHomeCategory.
	
	self assert: browser selectedMessageCategoryName = (browser class organization categoryOfElement: browser selectedMessageName).
]

{ #category : #'tests - message list' }
BrowserTest >> testKeepMethodSelectedWhenChangingClass [
	browser selectSystemCategory: SequenceableCollection category.
	browser selectClass: SequenceableCollection.
	browser selectMessageNamed: #add:.
	self assert: browser selectedMessageName = #add:.
	
	"Even though we have no message category selected, stay looking at the #add: method."
	browser selectClass: Collection.
	self assert: browser selectedMessageName = #add:.
]

{ #category : #tests }
BrowserTest >> testLabelStringAlwaysShowsBrowserType [
	browser selectSystemCategory: browser class category.
	self assert: (browser labelString includesSubstring: 'System Browser').
	browser selectClass: browser class.
	self assert: (browser labelString includesSubstring: 'System Browser').
	browser selectSystemCategory: DependencyBrowser category.
	browser selectClass: DependencyBrowser.
	self assert: (browser labelString includesSubstring: 'System Browser').
]

{ #category : #tests }
BrowserTest >> testLabelStringOfNewBrowserShowsBrowserType [
	self assert: 'System Browser' equals: browser labelString.
]

{ #category : #tests }
BrowserTest >> testLabelStringShowsBrowsedClassName [
	browser selectSystemCategory: DependencyBrowser category.
	browser selectClass: DependencyBrowser.
	self assert: (browser labelString includesSubstring: DependencyBrowser name).
]

{ #category : #tests }
BrowserTest >> testMessageCatListSingleton [
	| catName |
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	
	self assert: browser messageCatListSingleton = #().
	
	catName := browser messageCategoryList second.
	browser selectMessageCategoryNamed: catName.
	
	self assert: browser messageCatListSingleton = {catName}.
]

{ #category : #tests }
BrowserTest >> testMessageCategoryList [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	
	self assert: ({ClassOrganizer allCategory}, browser class organization categories) sorted equals: browser messageCategoryList sorted.
	
	browser selectClass: nil.
	self assert: #() equals: browser messageCategoryList.
	
	browser selectClass: browser class.
	browser metaClassIndicated: true.
	self assert: ({ClassOrganizer allCategory}, browser class classSide organization categories) equals: browser messageCategoryList.
]

{ #category : #tests }
BrowserTest >> testMessageCategoryListIndex [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	
	self assert: browser messageCategoryList size > 1 description: 'Sanity check: test refers to first two categories.'.
	
	browser messageCategoryListIndex: 0.
	self assert: browser selectedMessageCategoryName isNil.
	
	browser messageCategoryListIndex: 1.
	self assert: browser selectedMessageCategoryName = browser messageCategoryList first.
	
	browser messageListIndex: 1.
	browser messageCategoryListIndex: 2.
	self assert: browser selectedMessageName isNil description: 'Changing category deselects method'.
]

{ #category : #tests }
BrowserTest >> testMessageList [
	browser selectSystemCategory: browser class category.
	browser selectClass: nil.
	self assert: browser messageList isEmpty.
	
	browser selectClass: browser class.
	browser messageCategoryListIndex: 0.
	self assert: browser messageList = browser classOrMetaClassOrganizer allMethodSelectors.
	browser messageCategoryListIndex: 1. "-- all --"
	self assert: browser messageList = browser classOrMetaClassOrganizer allMethodSelectors.
	
	browser messageCategoryListIndex: 2.
	self assert: browser messageList = (browser classOrMetaClassOrganizer listAtCategoryNumber: 1).
	
	browser metaClassIndicated: true.
	browser messageCategoryListIndex: 0.
	self assert: browser messageList = browser classOrMetaClassOrganizer allMethodSelectors.
	
	browser messageCategoryListIndex: 1. "-- all --"
	self assert: browser messageList = browser classOrMetaClassOrganizer allMethodSelectors.
	
	browser messageCategoryListIndex: 2.
	self assert: browser messageList = (browser classOrMetaClassOrganizer listAtCategoryNumber: 1).
]

{ #category : #tests }
BrowserTest >> testMetaClassIndicatedFalseOnExistingClass [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser metaClassIndicated: false.
	
	self assert: browser messageListIndex = 0.
	self assert: browser messageCategoryListIndex = 0.
	self deny: browser contents isEmpty. "It shows the class definition."
	
	self deny: browser messageCategoryList isEmpty.
	
	self assert: browser messageList = (browser class organization allMethodSelectors).
	self assert: browser editSelection = #editClass.
]

{ #category : #tests }
BrowserTest >> testMetaClassIndicatedIsResetByChangedSystemCategory [
	browser selectSystemCategory: browser class category.
	browser metaClassIndicated: true.
	browser selectSystemCategory: self class category.
	
	self deny: browser metaClassIndicated.
]

{ #category : #tests }
BrowserTest >> testMetaClassIndicatedNotOnNoClass [
	browser selectSystemCategory: browser class category.
	browser selectClass: nil.
	browser metaClassIndicated: false.
	
	self assert: browser messageListIndex = 0.
	self assert: browser messageCategoryListIndex = 0.
	self deny: browser contents isEmpty. "It shows the class definition."
	
	self assert: browser messageCategoryList isEmpty.
	
	self assert: browser messageList isEmpty.
	self assert: browser editSelection = #newClass.
]

{ #category : #tests }
BrowserTest >> testMetaClassIndicatedNotWithNoSystemCategorySelected [
	browser selectSystemCategory: nil.
	browser metaClassIndicated: false.
	
	self assert: browser messageListIndex = 0.
	self assert: browser messageCategoryListIndex = 0.
	self assert: browser contents isEmpty. "It shows the Class definition."
	self assert: browser messageCategoryList isEmpty.
	self assert: browser editSelection = #none.
]

{ #category : #tests }
BrowserTest >> testMetaClassIndicatedOnNoClass [
	browser selectSystemCategory: browser class category.
	browser selectClass: nil.
	browser metaClassIndicated: true.
	
	self assert: browser messageListIndex = 0.
	self assert: browser messageCategoryListIndex = 0.
	self assert: browser contents isEmpty.
	
	self assert: browser messageCategoryList isEmpty.
	
	self assert: browser messageList isEmpty.
	self assert: browser editSelection = #none.
]

{ #category : #tests }
BrowserTest >> testMetaClassIndicatedTrueOnExistingClass [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser metaClassIndicated: true.
	
	self assert: browser messageListIndex = 0.
	self assert: browser messageCategoryListIndex = 0.
	self deny: browser contents isEmpty. "It shows the Class definition."
	self deny: browser messageCategoryList isEmpty.
	
	self assert: browser messageList = (browser class classSide organization allMethodSelectors).
]

{ #category : #tests }
BrowserTest >> testMetaClassIndicatedWithNoSystemCategorySelected [
	browser selectSystemCategory: nil.
	browser metaClassIndicated: true.
	
	self assert: browser messageListIndex = 0.
	self assert: browser messageCategoryListIndex = 0.
	self assert: browser contents isEmpty. "It shows the Class definition."
	self assert: browser messageCategoryList isEmpty.
	self assert: browser editSelection = #none.
]

{ #category : #tests }
BrowserTest >> testRawMessageCategoryList [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	
	self assert: browser rawMessageCategoryList = browser class organization categories.
	
	browser selectClass: nil.
	self assert: browser rawMessageCategoryList = #().
	
	browser selectClass: browser class.
	browser metaClassIndicated: true.
	self assert: browser rawMessageCategoryList = browser class classSide organization categories.
]

{ #category : #tests }
BrowserTest >> testSelectCategoryForClass [
	browser selectCategoryForClass: Browser.
	self assert: browser selectedSystemCategory = Browser category.
	
	browser selectCategoryForClass: TestCase.
	self assert: browser selectedSystemCategory = TestCase category.
]

{ #category : #tests }
BrowserTest >> testSelectClass [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	self assert: browser hasClassSelected.
	
	browser selectClass: nil.
	self deny: browser hasClassSelected.
]

{ #category : #tests }
BrowserTest >> testSelectClassEditSelectionNoClass [
	browser selectSystemCategory: browser class category.
	
	browser selectClass: nil.
	self assert: browser editSelection = #newClass.
]

{ #category : #tests }
BrowserTest >> testSelectClassEditSelectionWhenCommentSelected [
	| editSelection |
	browser selectSystemCategory: Heap category.
	browser selectClass: Heap.
	browser editComment.
	browser messageListIndex: 0.
	browser messageListIndex: 0.

	editSelection := browser editSelection.
	browser selectClass: Interval.
	self assert: browser editSelection = editSelection.
]

{ #category : #tests }
BrowserTest >> testSelectClassEditSelectionWhenEditingClass [
	browser selectSystemCategory: Heap category.
	browser selectClass: Heap.
	browser metaClassIndicated: false.
	browser messageListIndex: 0.
	browser messageListIndex: 0.
	
	browser selectClass: Interval.
	self assert: browser editSelection = #editClass.
]

{ #category : #tests }
BrowserTest >> testSelectClassEditSelectionWhenEditingMetaclass [
	browser selectSystemCategory: Heap category.
	browser selectClass: Heap.
	browser metaClassIndicated: true.
	browser messageListIndex: 0.
	browser messageListIndex: 0.
	
	browser selectClass: Interval.
	self assert: browser editSelection = #editClass.
]

{ #category : #tests }
BrowserTest >> testSelectClassEditSelectionWhenMsgSelected [
	browser selectSystemCategory: Heap category.
	browser selectClass: Heap.
	browser selectMessageCategoryNamed: 'adding'.
	browser messageListIndex: (browser messageList indexOf: #add:).
	
	browser selectClass: Interval.
	self assert: browser editSelection = #editMessage.
]

{ #category : #tests }
BrowserTest >> testSelectClassEditSelectionWhenNoMsgButCatSelected [
	browser selectSystemCategory: Heap category.
	browser selectClass: Heap.
	browser selectMessageCategoryNamed: 'adding'.
	browser messageListIndex: 0.
	
	browser selectClass: Interval.
	self assert: browser editSelection = #newMessage.
]

{ #category : #tests }
BrowserTest >> testSelectClassNamed [
	browser selectSystemCategory: browser class category.
	browser selectClassNamed: browser class name.
	self assert: browser selectedClassName = browser class name.
	
	browser selectClassNamed: nil.
	self assert: browser selectedClassName isNil.
	
	browser selectClassNamed: browser class name asString.
	self assert: browser selectedClassName = browser class name.
]

{ #category : #tests }
BrowserTest >> testSelectClassNamedPreservesPlace [
	| commonCategory commonSelector otherClass |
	browser selectSystemCategory: browser class category.
	otherClass := HierarchyBrowser. "Unlikely to move out of Browser's package!"
	browser selectClassNamed: browser class name.
	
	commonCategory := (browser class organization categories intersection: otherClass organization categories) detect: [ :each | each == #'class list' ].
	commonSelector := #classList.
	browser selectMessageCategoryNamed: commonCategory.
	browser selectMessageNamed: commonSelector.

	browser selectClass: otherClass.
	
	self assert: browser selectedClassName = otherClass name.
	self assert: browser selectedMessageCategoryName = commonCategory.
	self assert: browser selectedMessageName = commonSelector.
]

{ #category : #tests }
BrowserTest >> testSelectClassReselectsMessage [
	"Colections-Sequences contains a number of classes with similar protocols. In particular, several classes have a method called #add: in a category 'adding'."
	| selectedMsgCat selectedMethod |
	selectedMsgCat := 'adding'.
	selectedMethod := #add:.
	browser selectSystemCategory: Heap category.
	browser selectClass: Heap.
	browser selectMessageCategoryNamed: selectedMsgCat.
	browser messageListIndex: (browser messageList indexOf: selectedMethod).
	
	browser selectClass: Interval.
	
	self assert: browser selectedMessageCategoryName = selectedMsgCat.
	self assert: browser selectedMessageName = selectedMethod.
]

{ #category : #tests }
BrowserTest >> testSelectClassSelectsClass [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	self assert: browser classListIndex ~= 0.
	self assert: browser selectedClass = browser class.
	self assert: browser selectedClassName = browser class name.
]

{ #category : #tests }
BrowserTest >> testSelectClassWhenNothingSelected [
	self assert: browser editSelection = #none.
]

{ #category : #tests }
BrowserTest >> testSelectMessageCategoryEditSelection [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser selectMessageCategoryNamed: browser messageCategoryList first.
	
	self assert: browser editSelection = #newMessage.
]

{ #category : #tests }
BrowserTest >> testSelectMessageCategoryEditSelectionNoMsgCat [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
.
	browser messageCategoryListIndex: 0.
	
	self assert: browser editSelection = #editClass.
]

{ #category : #tests }
BrowserTest >> testSelectMessageCategoryEditSelectionNoMsgCatNoClass [
	browser selectSystemCategory: browser class category.
	browser selectClass: nil.
.
	browser messageCategoryListIndex: 0.
	
	self assert: browser editSelection = #newClass.
]

{ #category : #tests }
BrowserTest >> testSelectMessageCategoryNamed [
	| catName |
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	
	catName := browser messageCategoryList anyOne.
	browser selectMessageCategoryNamed: catName.
	self assert: browser selectedMessageCategoryName = catName.
]

{ #category : #tests }
BrowserTest >> testSelectMessageNamed [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser messageCategoryListIndex: 1.

	browser selectMessageNamed: browser messageList first.
	self assert: browser selectedMessageName = browser messageList first.
	self assert: browser messageListIndex = 1.
		
	browser selectMessageNamed: nil.
	self assert: browser selectedMessageName isNil.
	self assert: browser messageListIndex = 0.
	
	browser selectMessageNamed: browser messageList second.
	self assert: browser selectedMessageName = browser messageList second.
	self assert: browser messageListIndex = 2.
	
	browser selectMessageNamed: browser messageList first asString.
	self assert: browser selectedMessageName = browser messageList first.
	self assert: browser messageListIndex = 1.
]

{ #category : #tests }
BrowserTest >> testSelectedClass [
	browser selectSystemCategory: browser class category.
	browser classListIndex: 0.
	self assert: browser classListIndex = 0.
	self assert: browser selectedClass isNil.
	
	browser classListIndex: 1.
	self assert: browser classListIndex = 1.
	self assert: browser selectedClass notNil.
]

{ #category : #tests }
BrowserTest >> testSelectedEnvironment [
	browser selectSystemCategory: browser class category.
	self assert: browser selectedEnvironment = Smalltalk globals.
	
	"browser selectSystemCategory: nil.
	self assert: browser selectedEnvironment isNil."
	"selectedClass would not work in a hierarchy browser that has to display classes from different environments (because the correct categories might be missing)"
]

{ #category : #tests }
BrowserTest >> testSelectedSystemCategory [
	| cat newCat |
	cat := browser systemCategoryList first.
	newCat := browser systemCategoryList second.
	browser selectSystemCategory: cat.
	self assert:	browser selectedSystemCategory = cat.
		
	browser systemCategoryListIndex: 2.
	self assert:	browser selectedSystemCategory = newCat.
]

{ #category : #tests }
BrowserTest >> testShowHomeCategory [
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	"Select '--all--'."
	browser selectMessageCategoryNamed: browser messageCategoryList first.
	browser selectMessageNamed: browser messageList first.
	
	browser showHomeCategory.
	self assert: browser messageCategoryListIndex > 1.
]

{ #category : #tests }
BrowserTest >> testSpawnHierarchy [
	| spawn |
	browser selectSystemCategory: browser class category.
	browser selectClass: browser class.
	browser selectMessageCategoryNamed: browser messageCategoryList last.
	browser messageListIndex: (browser messageList size).

	spawn := browser spawnHierarchy.
	[self assert: spawn selectedSystemCategory = browser selectedSystemCategory.
	self assert: spawn selectedClassName = browser selectedClassName.
	self assert: spawn selectedMessageCategoryName = browser selectedMessageCategoryName.
	self assert: spawn messageListIndex = browser messageListIndex.]
		ensure: [ ToolBuilder default close: spawn topView ].
]

{ #category : #tests }
BrowserTest >> testSystemCategoryListIndex [
	| oldCat |
	
	browser systemCategoryListIndex: 1.
	oldCat := browser selectedSystemCategory.
	self assert:	browser selectedSystemCategory = browser systemCategoryList first.
		
	browser systemCategoryListIndex: 2.
	self deny: browser selectedSystemCategory = oldCat.
	self assert:	browser selectedSystemCategory = browser systemCategoryList second.
]
