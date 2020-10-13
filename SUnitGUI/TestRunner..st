"
<lint: #ignore rule: #classNotReferenced rational: 'this view is only accessed from menus'>


"
Class {
	#name : #TestRunner,
	#superclass : #Model,
	#instVars : [
		'categories',
		'categoryIndex',
		'categoriesSelected',
		'classes',
		'classIndex',
		'classesSelected',
		'failedList',
		'failedSelected',
		'errorList',
		'errorSelected',
		'lastUpdate',
		'result',
		'previousRun',
		'categoryPattern',
		'classPattern',
		'environment'
	],
	#category : #SUnitGUI
}

{ #category : #'instance-creation' }
TestRunner class >> build [
	^ ToolBuilder build: self new.
]

{ #category : #'instance-creation' }
TestRunner class >> buildForSuite: aTestSuite [
	^ ToolBuilder build: (self newForSuite: aTestSuite).
]

{ #category : #initialization }
TestRunner class >> initialize [
	self registerInWorldMenu; registerInToolsFlap.
]

{ #category : #'instance-creation' }
TestRunner class >> newForSuite: aSuite [

	| runner classes categories |
	runner := TestRunner new.
	classes := aSuite tests asSet collect: #class.
	categories := classes collect: #category.
	^ runner
		filterCategoriesBy: ((categories collect: #asString) asArray joinSeparatedBy: $;);
		filterClassesBy: ((classes collect: #asString) asArray joinSeparatedBy: $;);
		yourself
]

{ #category : #'instance-creation' }
TestRunner class >> open [
	^ ToolBuilder open: self new.
]

{ #category : #'instance-creation' }
TestRunner class >> openForSuite: aTestSuite [
	^ ToolBuilder open: (self newForSuite: aTestSuite).
]

{ #category : #initialization }
TestRunner class >> registerInToolsFlap [
	self environment at: #Flaps ifPresent: [ :class |
		class
			registerQuad: #( TestRunner build 'SUnit Runner' 'A production scale test-runner.' ) forFlapNamed: 'Tools';
			replaceToolsFlap ].
]

{ #category : #initialization }
TestRunner class >> registerInWorldMenu [
	self environment at: #TheWorldMenu ifPresent: [ :class |
		class registerOpenCommand: (Array 
			with: 'Test Runner' 
			with: (Array
				with: self
				with: #open)) ].
]

{ #category : #preferences }
TestRunner class >> themeProperties [

	^ super themeProperties, {
		{ #failureColor. 'Colors'. 'Color to indicate failed tests.'}.
		{ #errorColor. 'Colors'. 'Color to indicate errored tests.'}.
		{ #passColor. 'Colors'. 'Color to indicate passed tests.'}.

		{ #failureTextColor. 'Colors'. 'Color to indicate failed tests.'}.
		{ #errorTextColor. 'Colors'. 'Color to indicate errored tests.'}.
		{ #passTextColor. 'Colors'. 'Color to indicate passed tests.'}.

	}
]

{ #category : #actions }
TestRunner >> addDeclaredPackagesUnderTestTo: packages [ 
	classesSelected do: 
		[ :class | 
		(class class includesSelector: #packageNamesUnderTest) ifTrue: 
			[ class packageNamesUnderTest do: [ :name | packages add: (PackageInfo named: name) ] ] ]
]

{ #category : #actions }
TestRunner >> addMethodsUnderTestIn: packages to: methods [ 
	packages
		do: [:package | package isNil
				ifFalse: [package methods
						do: [:method | ((#(#packageNamesUnderTest #classNamesNotUnderTest ) includes: method methodSymbol)
									or: [method compiledMethod isAbstract
											or: [method compiledMethod hasLiteral: #ignoreForCoverage]])
								ifFalse: [methods add: method]]]]
]

{ #category : #updating }
TestRunner >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	
	self changed: #statusColor.
	self changed: #statusTextColor.
]

{ #category : #accessing }
TestRunner >> baseClass [
	^ TestCase
]

{ #category : #processing }
TestRunner >> basicRunSuite: aTestSuite do: aBlock [ 
	self basicSetUpSuite: aTestSuite.
	[ | prefix |
	prefix := aTestSuite name isEmptyOrNil
		ifTrue: [ '' ]
		ifFalse: [ aTestSuite name , ' - ' ].
	aTestSuite tests size = 1
		ifTrue: [ aTestSuite tests do: aBlock ]
		ifFalse:
			[ aTestSuite tests
				do: aBlock
				displayingProgress: [ : test | prefix , test printString ]
				every: 0 ] ] ensure: [ self basicTearDownSuite: aTestSuite ]
]

{ #category : #processing }
TestRunner >> basicSetUpSuite: aTestSuite [
	aTestSuite resources do: [ :each |
		each isAvailable
			ifFalse: [ each signalInitializationError ] ].
]

{ #category : #processing }
TestRunner >> basicTearDownSuite: aTestSuite [
	aTestSuite resources do: [ :each | each reset ].
]

{ #category : #'accessing-classes' }
TestRunner >> browseClass [
	(classes at: classIndex ifAbsent: [ ^ self ]) browse
]

{ #category : #private }
TestRunner >> browserEnvironment [
	^ Smalltalk classNamed: #BrowserEnvironment.
]

{ #category : #building }
TestRunner >> buildButtonsWith: aBuilder [
	^ aBuilder pluggablePanelSpec new
		model: self;
		layout: #horizontal;
		children: (self buttons collect: [ :each |
			aBuilder pluggableButtonSpec new
				model: self; 
				label: each first;
				action: each second;
				enabled: each third;
				yourself ]);
		yourself.
]

{ #category : #building }
TestRunner >> buildCategoriesWith: aBuilder [
	^ aBuilder pluggableMultiSelectionListSpec new
		model: self;
		list: #categoryList;
		menu: #categoryMenu:;
		getIndex: #categorySelected;
		setIndex: #categorySelected:;
		getSelectionList: #categoryAt:;
		setSelectionList: #categoryAt:put:;
		yourself.
]

{ #category : #building }
TestRunner >> buildClassesWith: aBuilder [
	^ aBuilder pluggableMultiSelectionListSpec new
		model: self;
		list: #classList;
		menu: #classMenu:;
		getIndex: #classSelected;
		setIndex: #classSelected:;
		getSelectionList: #classAt:;
		setSelectionList: #classAt:put:;
		yourself.
]

{ #category : #building }
TestRunner >> buildErrorListWith: aBuilder [
	^ aBuilder pluggableListSpec new
		model: self;
		name: 'Error List';
		list: #errorList; 
		menu: #errorMenu:;
		getIndex: #errorSelected; 
		setIndex: #errorSelected:;
		yourself.
]

{ #category : #building }
TestRunner >> buildFailureListWith: aBuilder [
	^ aBuilder pluggableListSpec new
		model: self;
		name: 'Failure List';
		list: #failedList; 
		menu: #failureMenu:;
		getIndex: #failedSelected; 
		setIndex: #failedSelected:;
		yourself.
]

{ #category : #building }
TestRunner >> buildStatusWith: aBuilder [
	^ aBuilder pluggableTextSpec new
		model: self;
		menu: #statusMenu:;
		color: #statusColor;
		textColor: #statusTextColor;
		getText: #statusText;
		yourself.
]

{ #category : #building }
TestRunner >> buildWith: aBuilder [
	| window |
	window := aBuilder pluggableWindowSpec new
		model: self; label: self label; extent: self extent;
		children: (OrderedCollection new 
			add: ((self buildCategoriesWith: aBuilder)
				frame: self categoriesFrame;
				yourself);
			add: ((self buildClassesWith: aBuilder)
				frame: self classesFrame;
				yourself);
			add: ((self buildStatusWith: aBuilder)
				frame: self statusFrame;
				yourself);
			add: ((self buildFailureListWith: aBuilder)
				frame: self failureListFrame;
				yourself);
			add: ((self buildErrorListWith: aBuilder)
				frame: self errorListFrame;
				yourself);
			add: ((self buildButtonsWith: aBuilder)
				frame: self buttonsFrame;
				yourself);
			yourself);
		yourself.
	^ aBuilder build: window.
]

{ #category : #building }
TestRunner >> buttonHeight [
	^ Preferences standardButtonFont height * 3
]

{ #category : #'accessing-ui' }
TestRunner >> buttons [
	^ #(( 'Run Selected' #runAll #hasRunnable )
		( 'Run Profiled' #runProfiled #hasRunnable )
		( 'Run Coverage' #runCoverage #hasRunnable )
		( 'Run Failures' #runFailures #hasFailures )
		( 'Run Errors' #runErrors #hasErrors ))
]

{ #category : #building }
TestRunner >> buttonsFrame [
	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 1 offset: self buttonHeight negated;
		rightFraction: 1 offset: 0;
		bottomFraction: 1 offset: 0
]

{ #category : #building }
TestRunner >> categoriesFrame [
	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 0 offset: 0;
		rightFraction: 0.25 offset: 0;
		bottomFraction: 1 offset: self buttonHeight negated
]

{ #category : #'accessing-categories' }
TestRunner >> categoryAt: anIndex [
	^ categoriesSelected includes: (categories at: anIndex ifAbsent: [ ^ false ]).
]

{ #category : #'accessing-categories' }
TestRunner >> categoryAt: anInteger put: aBoolean [
	categoriesSelected := categoriesSelected
		perform: (aBoolean ifTrue: [ #copyWith: ] ifFalse: [ #copyWithout: ])
		with: (categories at: anInteger ifAbsent: [ ^ self ]).
	self
		changed: #categoryAt:;
		changed: #categorySelected;
		updateClasses.
]

{ #category : #'accessing-categories' }
TestRunner >> categoryList [
	^ categories
]

{ #category : #'accessing-categories' }
TestRunner >> categoryMenu: aMenu [
	^ aMenu
		title: 'Categories';
		add: 'Select all' action: #selectAllCategories;
		add: 'Select inversion' action: #selectInverseCategories;
		add: 'Select none' action: #selectNoCategories;
		addLine;
		add: 'Filter...' action: #filterCategories;
		addLine;
		add: 'Refresh' action: #updateCategories;
		yourself.
]

{ #category : #'accessing-categories' }
TestRunner >> categorySelected [
	^ categoryIndex ifNil: [0]
]

{ #category : #'accessing-categories' }
TestRunner >> categorySelected: anInteger [
	categoryIndex := anInteger.
	self changed: #categorySelected.
]

{ #category : #'accessing-classes' }
TestRunner >> classAt: anInteger [
	^ classesSelected includes: (classes at: anInteger ifAbsent: [ ^ false ]).
]

{ #category : #'accessing-classes' }
TestRunner >> classAt: anInteger put: aBoolean [
	classesSelected := classesSelected
		perform: (aBoolean ifTrue: [ #copyWith: ] ifFalse: [ #copyWithout: ])
		with: (classes at: anInteger ifAbsent: [ ^ self ]).
	self
		changed: #classAt:;
		changed: #classSelected;
		changed: #hasRunnable.
]

{ #category : #'accessing-classes' }
TestRunner >> classList [
	
	| helper |
	classes isEmpty ifTrue: [ ^ classes ].
	
	helper := Browser new.
	^ helper
		flattenHierarchyTree: (helper createHierarchyTreeOf: classes)
		on: OrderedCollection new
		indent: ''
		by: '  '
		format: [:class | class isAbstract
							ifTrue: [class name asText addAttribute: TextEmphasis italic; yourself]
							ifFalse: [
								(class history notNil and: [class history includesKey: #duration])
									ifFalse: ['{1} ({2} tests)' format: {
										class name.
										(class shouldInheritSelectors
											ifTrue: [class allTestSelectors]
											ifFalse: [class testSelectors]) size}]
									ifTrue: [
										| duration |
										duration := (class history at: #duration).
										'{1} ({2} tests, {3})' format: {
											class name.
											(class shouldInheritSelectors
												ifTrue: [class allTestSelectors]
												ifFalse: [class testSelectors]) size.
											duration = 0 ifTrue: ['< 1 ms'] ifFalse: [
												duration < 1000 ifTrue: [duration asString, ' ms'] ifFalse: [
													(duration / 1000) rounded asString, ' secs']]}]]] 
]

{ #category : #'accessing-classes' }
TestRunner >> classMenu: aMenu [
	^ aMenu
		title: 'Classes';
		add: 'Browse' action: #browseClass;
		addLine;
		add: 'Select all' action: #selectAllClasses;
		add: 'Select subclasses' action: #selectSubclasses;
		add: 'Select inversion' action: #selectInverseClasses;
		add: 'Select none' action: #selectNoClasses;
		addLine;
		add: 'Filter...' action: #filterClasses;
		addLine;
		add: 'Refresh' action: #updateClasses;
		yourself.
]

{ #category : #'accessing-classes' }
TestRunner >> classSelected [
	^ classIndex
]

{ #category : #'accessing-classes' }
TestRunner >> classSelected: anInteger [
	classIndex := anInteger.
	self changed: #classSelected
]

{ #category : #building }
TestRunner >> classesFrame [
	^LayoutFrame new
		leftFraction: 0.25 offset: 0;
		topFraction: 0 offset: 0;
		rightFraction: 0.5 offset: 0;
		bottomFraction: 1 offset: self buttonHeight negated
]

{ #category : #accessing }
TestRunner >> classesSelected [
	^ classesSelected
]

{ #category : #actions }
TestRunner >> collectCoverageFor: methods [
	| wrappers suite |
	wrappers := methods collect: [ :each | TestCoverage on: each ].
	suite := self
		reset;
		suiteAll.
	
	[ wrappers do: [ :each | each install ].
	[ self runSuite: suite ] ensure: [ wrappers do: [ :each | each uninstall ] ] ] valueUnpreemptively.
	wrappers := wrappers reject: [ :each | each hasRun ].
	wrappers isEmpty 
		ifTrue: 
			[ UIManager default inform: 'Congratulations. Your tests cover all code under analysis.' ]
		ifFalse: 
			[ ToolSet 
				browseMessageSet: (wrappers collect: [ :each | each reference ])
				name: 'Not Covered Code (' , (100 - (100 * wrappers size // methods size)) printString , '% Code Coverage)'
				autoSelect: nil ].
	self saveResultInHistory
]

{ #category : #actions }
TestRunner >> debug: aTestCase [
	self debugSuite: (TestSuite new
		addTest: aTestCase; 
		yourself).
]

{ #category : #actions }
TestRunner >> debugSuite: aTestSuite [
	self basicRunSuite: aTestSuite do: [ :each | each debug ].
]

{ #category : #'user interface' }
TestRunner >> defaultWindowColor [
	^ (Color r: 0.9 g: 0.576 b: 0.09)
]

{ #category : #accessing }
TestRunner >> environment [
	^ environment ifNil: [Smalltalk globals]
]

{ #category : #accessing }
TestRunner >> environment: anEnvironment [
	 environment := anEnvironment.
	self update; reset
]

{ #category : #'accessing-testing' }
TestRunner >> errorList [
	^ errorList collect: [ :each | each printString ].
]

{ #category : #building }
TestRunner >> errorListFrame [
	^LayoutFrame new
		leftFraction: 0.5 offset: 0;
		topFraction: 0.5 offset: 0;
		rightFraction: 1 offset: 0;
		bottomFraction: 1 offset: self buttonHeight negated
]

{ #category : #'accessing-menu' }
TestRunner >> errorMenu: aMenu [
	^ self statusMenu: aMenu
]

{ #category : #'accessing-testing' }
TestRunner >> errorSelected [
	^ errorList indexOf: errorSelected.
]

{ #category : #'accessing-testing' }
TestRunner >> errorSelected: anInteger [
	errorSelected := errorList at: anInteger ifAbsent: nil.
	self changed: #errorSelected.
	errorSelected ifNotNil: [ self debug: errorSelected ].
]

{ #category : #actions }
TestRunner >> excludeClassesNotUnderTestFrom: methods [ 
	
	classesSelected do: 
		[ :class | 
		(class class includesSelector: #classNamesNotUnderTest) ifTrue: 
			[ class classNamesNotUnderTest do: 
				[ :className | | theClass | 
				theClass := Smalltalk classNamed: className.
				theClass ifNotNil:[
				theClass methods do: 
					[ :each | 
					methods 
						remove: each methodReference
						ifAbsent: [  ] ].
				theClass class methods do: 
					[ :each | 
					methods 
						remove: each methodReference
						ifAbsent: [  ] ]] ] ] ]
]

{ #category : #'accessing-ui' }
TestRunner >> extent [
	^ 640 @ 480
]

{ #category : #'accessing-testing' }
TestRunner >> failedList [
	^ failedList collect: [ :each | each printString ].
]

{ #category : #'accessing-testing' }
TestRunner >> failedSelected [
	^ failedList indexOf: failedSelected.
]

{ #category : #'accessing-testing' }
TestRunner >> failedSelected: anInteger [
	failedSelected := failedList at: anInteger ifAbsent: nil.
	self changed: #failedSelected.
	failedSelected ifNotNil: [ self debug: failedSelected ].
]

{ #category : #building }
TestRunner >> failureListFrame [
	^LayoutFrame new
		leftFraction: 0.5 offset: 0;
		topFraction: 0 offset: self statusHeight;
		rightFraction: 1 offset: 0;
		bottomFraction: 0.5 offset: 0
]

{ #category : #'accessing-menu' }
TestRunner >> failureMenu: aMenu [
	^ aMenu
		add: 'Profile this test' action: #runProfileOnFailure;
		yourself
]

{ #category : #'accessing-categories' }
TestRunner >> filterCategories [
	| pattern |
	pattern := UIManager default 
					request: 'Pattern(s) to select categories:\    (separate patterns with '';'')' withCRs
					initialAnswer: (categoryPattern ifNil: ['*']).
	(pattern isNil or: [pattern isEmpty]) ifTrue:
		[^self].
	self filterCategoriesBy: pattern
]

{ #category : #'accessing-categories' }
TestRunner >> filterCategoriesBy: aPattern [
	categoriesSelected := ((categoryPattern := aPattern) subStrings: ';')
								inject: Set new
								into: [:matches :subPattern|
									matches
										addAll: (categories select: [ :each | subPattern match: each]);
										yourself].
	self changed: #allSelections; changed: #categorySelected; updateClasses
]

{ #category : #'accessing-classes' }
TestRunner >> filterClasses [
	| pattern |
	pattern := UIManager default 
					request: 'Pattern(s) to select tests:\  (separate patterns with '';'')' withCRs
					initialAnswer: (classPattern ifNil: '*').
	(pattern isNil or: [pattern isEmpty]) ifTrue:
		[^self].
	self filterClassesBy: pattern
]

{ #category : #'accessing-classes' }
TestRunner >> filterClassesBy: aPattern [
	classesSelected := ((classPattern := aPattern) subStrings: ';')
							inject: Set new
							into: [:matches :subPattern|
								matches
									addAll: (classes select: [ :each | subPattern match: each name]);
									yourself].
	self
		changed: #allSelections;
		changed: #classSelected;
		changed: #hasRunnable
]

{ #category : #utilities }
TestRunner >> findCategories [
	| visible |
	visible := Set new.
	self baseClass withAllSubclassesDo: [ :each |
		each category ifNotNil: [ :category |
			visible add: category ] ].
	^ Array streamContents: [ :stream |
		self environment organization categories do: [ :each |
			(visible includes: each)
				ifTrue: [ stream nextPut: each ] ] ].
]

{ #category : #utilities }
TestRunner >> findClassesForCategories: aCollection [

	| environment items |
	aCollection isEmpty 
		ifTrue: [ ^ self baseClass withAllSubclasses asSet ].
	environment := self environment.
	items := aCollection gather: [ :category |
		((environment organization listAtCategoryNamed: category)
			collect: [ :each | environment valueOf: each ])
			select: [ :each | each includesBehavior: self baseClass ] ].
	^ items asSet.
]

{ #category : #testing }
TestRunner >> hasErrors [
	^ result hasErrors.
]

{ #category : #testing }
TestRunner >> hasFailures [
	^ result hasFailures.
]

{ #category : #'history saving' }
TestRunner >> hasHistory [

	self flag: #Useless. "No Senders?"
	^ true
]

{ #category : #'history saving' }
TestRunner >> hasProgress [

	result classesTested do: [:cls |
		(cls class methodDictionary includesKey: #lastStoredRun)
			ifTrue: [^ true]].
	^ false
]

{ #category : #'history saving' }
TestRunner >> hasResults [

	^ result notNil
]

{ #category : #testing }
TestRunner >> hasRunnable [
	^ classesSelected notEmpty.
]

{ #category : #'history saving' }
TestRunner >> historyMenuList [
	^ {'** save current result **'}, (self previousRun collect: [:ts | ts printString])
]

{ #category : #initialization }
TestRunner >> initialize [
	super initialize.
	failedList := errorList := Array new.
	SystemChangeNotifier uniqueInstance 
		notify: self ofSystemChangesOfItem: #class change: #Added using: #update;
		notify: self ofSystemChangesOfItem: #category change: #Added using: #update;
		notify: self ofSystemChangesOfItem: #class change: #Removed using: #update;
		notify: self ofSystemChangesOfItem: #category change: #Removed using: #update;
		notify: self ofSystemChangesOfItem: #class change: #Renamed using: #update;
		notify: self ofSystemChangesOfItem: #category change: #Renamed using: #update;
		notify: self ofSystemChangesOfItem: #class change: #Recategorized using: #update;
		notify: self ofSystemChangesOfItem: #category change: #Recategorized using: #update.
	environment := Environment current.
	self update; reset
]

{ #category : #'accessing-ui' }
TestRunner >> label [
	^ 'Test Runner in environment ', environment name
]

{ #category : #private }
TestRunner >> label: aString forSuite: aTestSuite [
	^ String streamContents: [ :stream |
		stream nextPutAll: 'Running '; print: aTestSuite tests size; space; nextPutAll: aString.
		aTestSuite tests size > 1 ifTrue: [ stream nextPut: $s ] ]. 
]

{ #category : #private }
TestRunner >> perform: selector orSendTo: otherTarget [
	"<lint: #expect rule: #badMessage rational: 'this is a common morphic pattern'>"
	
	^ (self respondsTo: selector)
		ifTrue: [ self perform: selector ]
		ifFalse: [ super perform: selector orSendTo: otherTarget ].
]

{ #category : #'accessing-ui' }
TestRunner >> postAcceptBrowseFor: aModel [
	"Nothing to do."
]

{ #category : #'history saving' }
TestRunner >> previousRun [

	^ previousRun ifNil: [ previousRun := OrderedCollection new ]
]

{ #category : #actions }
TestRunner >> promptForPackages [
	| packages |
	packages := (PackageOrganizer default packages
				reject: [:package | (package packageName beginsWith: 'Kernel')
						or: [(package packageName beginsWith: 'Collections')
								or: [(package packageName beginsWith: 'Exceptions')
										or: [(package packageName beginsWith: 'SUnit')
												or: [(package packageName beginsWith: 'System')
														or: [package packageName includesSubstring: 'Test' caseSensitive: false]]]]]])
				sort: [:a :b | a packageName < b packageName].
	packages := Array
				with: (UIManager default
						chooseFrom: (packages
								collect: [:package | package packageName])
						values: packages
						title: 'Select Package').
	^ packages
]

{ #category : #'accessing-ui' }
TestRunner >> representsSameBrowseeAs: anotherModel [ 
	^ true
]

{ #category : #actions }
TestRunner >> reset [
	self result: TestResult new; updateResults.
]

{ #category : #'accessing-testing' }
TestRunner >> result [
	^ result
]

{ #category : #'accessing-testing' }
TestRunner >> result: aResult [
	result := aResult
]

{ #category : #actions }
TestRunner >> runAll [
	self reset; runSuite: self suiteAll.
	self saveResultInHistory
]

{ #category : #actions }
TestRunner >> runCoverage [
	| packages methods |
	packages := Set new.
	self addDeclaredPackagesUnderTestTo: packages.
	packages isEmpty ifTrue: 
		[ packages := self promptForPackages ].
	methods := OrderedCollection new.
	self 
		addMethodsUnderTestIn: packages
		to: methods.
	self excludeClassesNotUnderTestFrom: methods.
	methods isEmpty ifTrue: 
		[ ^ UIManager default inform: 'No methods found for coverage analysis.' ].
	self collectCoverageFor: methods

]

{ #category : #actions }
TestRunner >> runErrors [
	self result resetErrors.
	self runSuite: self suiteErrors.
]

{ #category : #actions }
TestRunner >> runFailures [
	self result resetFailures.
	self runSuite: self suiteFailures.
]

{ #category : #actions }
TestRunner >> runProfileOnFailure [
	"if we have selected a failure case, run it within a MessageTAlly and see what is taking time"
	
	failedSelected ifNotNil: [self
				basicRunSuite: (TestSuite new addTest: failedSelected;
						 yourself)
				do: [:each | MessageTally
						spyOn: [self runTest: each]]]
]

{ #category : #actions }
TestRunner >> runProfiled [
	MessageTally spyOn: [ self runAll ].
]

{ #category : #actions }
TestRunner >> runSuite: aTestSuite [
	self basicRunSuite: aTestSuite do: [ :each | self runTest: each ].
	self updateResults


]

{ #category : #actions }
TestRunner >> runTest: aTestCase [
	aTestCase run: result.
	self updateStatus: true.
]

{ #category : #'history saving' }
TestRunner >> saveResultInHistory [
	result dispatchResultsIntoHistory.
	self changed: #classList.
]

{ #category : #'accessing-categories' }
TestRunner >> selectAllCategories [
	categoriesSelected := categories asSet.
	self changed: #allSelections; changed: #categorySelected; updateClasses
]

{ #category : #'accessing-classes' }
TestRunner >> selectAllClasses [
	"Fixed to update all selections now that the
	selection invalidation has been optimised."
	
	classesSelected := classes asSet.
	self
		changed: #allSelections;
		changed: #classSelected;
		changed: #hasRunnable
]

{ #category : #'accessing-categories' }
TestRunner >> selectInverseCategories [
	categoriesSelected := categories asSet 
		removeAll: categoriesSelected;
		yourself.
	self changed: #allSelections; changed: #categorySelected; updateClasses
]

{ #category : #'accessing-classes' }
TestRunner >> selectInverseClasses [
	"Fixed to update all selections now that the
	selection invalidation has been optimised."
	
	classesSelected := classes asSet 
		removeAll: classesSelected;
		yourself.
	self
		changed: #allSelections;
		changed: #classSelected;
		changed: #hasRunnable
]

{ #category : #'accessing-categories' }
TestRunner >> selectNoCategories [
	categoriesSelected := Set new.
	self changed: #allSelections; changed: #categorySelected; updateClasses
]

{ #category : #'accessing-classes' }
TestRunner >> selectNoClasses [
	"Fixed to update all selections now that the
	selection invalidation has been optimised."
	
	classesSelected := Set new.
	self
		changed: #allSelections;
		changed: #classSelected;
		changed: #hasRunnable
]

{ #category : #'accessing-classes' }
TestRunner >> selectSubclasses [
	"Fixed to update all selections now that the
	selection invalidation has been optimised."
	
	| classesForPackages |
	classesForPackages := self findClassesForCategories: categoriesSelected.	
	classesSelected := (classesSelected gather: [ :class |
		class withAllSubclasses select: [ :each |
			classesForPackages includes: each ] ])
		asSet.
	self
		changed: #allSelections;
		changed: #classSelected;
		changed: #hasRunnable
]

{ #category : #'history saving' }
TestRunner >> showDiffWith: aTestResult [
	| string diff |

	diff := result diff: aTestResult.
	string := String streamContents: [:str|
		str nextPutAll: '----------------'; cr.
		str nextPutAll: 'Diff between current result with: ', aTestResult asString; cr.
		str nextPutAll: 'New passed: '.
		diff first do: [:s| str nextPutAll: s printString, ' '].
		str cr.
		str nextPutAll: 'New failures: '.
		diff second do: [:s| str nextPutAll: s printString, ' '].
		str cr.
		
		str nextPutAll: 'New errors: '.
		diff third do: [:s| str nextPutAll: s printString, ' '].
		str cr].
	
	Workspace new contents: string; openLabel: 'SUnit Progress'
	
]

{ #category : #'history saving' }
TestRunner >> showHistoryMenu [
	| selectionIndex selectedPreviousResult actionIndex |
	selectionIndex := UIManager default chooseFrom: self historyMenuList title: 'History:'.

	"We pressed outside the menu"
	selectionIndex isZero ifTrue: [ ^ self ]. 				

	"save current result is selected"
	selectionIndex = 1 ifTrue: [ self previousRun addFirst: result. ^ self ]. 			

	selectedPreviousResult := self previousRun at: (selectionIndex - 1).
 	actionIndex := (UIManager default chooseFrom: #('delete' 'show diff')  title:  'Action:').
	actionIndex = 1 ifTrue: [ self previousRun remove: selectedPreviousResult. ^ self ].
	actionIndex = 2 ifTrue: [ self showDiffWith: selectedPreviousResult].	
]

{ #category : #'history saving' }
TestRunner >> showProgress [
	| testCaseClasses d string |
	testCaseClasses := (self suiteAll tests collect: [:testCase | testCase class]) asSet.
	
	"At the end of the algorithm, d will contains all the diff between what was saved and the current result"
	d := Dictionary new.
	d at: #passed put: OrderedCollection new.
	d at: #failures put: OrderedCollection new.
	d at: #errors put: OrderedCollection new.

	testCaseClasses do: [ :cls | | t |
		(cls class methodDict includesKey: #lastStoredRun)
			ifTrue: [t := cls lastStoredRun.
					(t at: #passed) do: [:s | 	
											(result isErrorFor: cls selector: s)
												ifTrue: [(d at: #errors) add: {cls . s}].
											(result isFailureFor: cls selector: s)
												ifTrue: [(d at: #failures) add: {cls . s}]  ].
											
					(t at: #failures) do: [:s | (result isPassedFor: cls selector: s)
												ifTrue: [(d at: #passed) add: {cls . s}].
											(result isErrorFor: cls selector: s)
												ifTrue: [(d at: #errors) add: {cls . s}]].
											
					(t at: #errors) do: [:s | 	(result isPassedFor: cls selector: s)
												ifTrue: [(d at: #passed) add: {cls . s}].
											(result isFailureFor: cls selector: s)
												ifTrue: [(d at: #failures) add: {cls . s}]]]].
		
			
	string := String streamContents: [:str|
		str nextPutAll: '----------------'; cr.
		str nextPutAll: 'Diff between current result and saved result'; cr.
		str nextPutAll: 'New passed: '.
		(d at: #passed) do: [:s| str nextPutAll: s printString, ' '].
		str cr.
		str nextPutAll: 'New failures: '.
		(d at: #failures) do: [:s| str nextPutAll: s printString, ' '].
		str cr.
		
		str nextPutAll: 'New errors: '.
		(d at: #errors) do: [:s| str nextPutAll: s printString, ' '].
		str cr].
	
	Workspace new contents: string; openLabel: 'SUnit Progress' string.

	
]

{ #category : #utilities }
TestRunner >> sortClass: firstHierarchyList before: secondHierarchyList [

	1 to: (firstHierarchyList size min: secondHierarchyList size) do: [ :index | 
		(firstHierarchyList at: index) == (secondHierarchyList at: index)
			ifFalse: [ ^(firstHierarchyList at: index) name <= (secondHierarchyList at: index) name ] ].
	^secondHierarchyList includes: firstHierarchyList last.
]

{ #category : #'accessing-testing' }
TestRunner >> statusColor [
	result hasErrors ifTrue: [^ self userInterfaceTheme errorColor ifNil: [Color red]].
	result hasFailures ifTrue: [^ self userInterfaceTheme failureColor ifNil: [Color yellow]].
	^ self userInterfaceTheme passColor ifNil: [Color green]
]

{ #category : #building }
TestRunner >> statusFrame [
	^LayoutFrame new
		leftFraction: 0.5 offset: 0;
		topFraction: 0 offset: 0;
		rightFraction: 1 offset: 0;
		bottomFraction: 0 offset: self statusHeight
]

{ #category : #building }
TestRunner >> statusHeight [
	^Preferences standardCodeFont height * 2 + 12
]

{ #category : #'accessing-menu' }
TestRunner >> statusMenu: aMenu [
	^ aMenu
		add: 'History' action: #showHistoryMenu;
		add: 'Store result as progress reference' action: #storeResultIntoTestCases;
		add: 'Show progress' action: #showProgress; 
		yourself
]

{ #category : #'accessing-testing' }
TestRunner >> statusText [
	^ result printString.
]

{ #category : #'accessing-testing' }
TestRunner >> statusTextColor [
	result hasErrors ifTrue: [^ self userInterfaceTheme errorTextColor ifNil: [Color black]].
	result hasFailures ifTrue: [^ self userInterfaceTheme failureTextColor ifNil: [Color black]].
	^ self userInterfaceTheme passTextColor ifNil: [Color black]
]

{ #category : #'history saving' }
TestRunner >> storeResultIntoTestCases [

	result classesTested do: [:testCaseCls | testCaseCls generateLastStoredRunMethod ]

]

{ #category : #accessing }
TestRunner >> suiteAll [
	^ TestSuite new in: [ :suite |
		classesSelected do: [ :each | 
			each isAbstract 
				ifFalse: [ each addToSuiteFromSelectors: suite ] ].
		suite name: (self label: 'Test' forSuite: suite) ].
]

{ #category : #accessing }
TestRunner >> suiteErrors [
	^ TestSuite new in: [ :suite |
		suite 
			addTests: errorList; 
			name: (self label: 'Error' forSuite: suite) ].
]

{ #category : #accessing }
TestRunner >> suiteFailures [
	^ TestSuite new in: [ :suite |
		suite 
			addTests: failedList; 
			name: (self label: 'Failure' forSuite: suite) ].
]

{ #category : #updating }
TestRunner >> update [
	self updateCategories; updateClasses
]

{ #category : #updating }
TestRunner >> updateCategories [
	categories := self findCategories.
	categoriesSelected := categoriesSelected isNil
		ifTrue: [ Set new ]
		ifFalse: [
			categoriesSelected
				select: [ :each | categories includes: each ] ].
	self changed: #categoryList; changed: #categorySelected.
]

{ #category : #updating }
TestRunner >> updateClasses [

	| classesForCategories |
	classesForCategories := self findClassesForCategories: categoriesSelected.
	classes := classesForCategories asArray
		replace: [ :class | class withAllSuperclasses reverseInPlace ];
		sort: [ :a :b | self sortClass: a before: b ];
		replace: [ :hierarchyList | hierarchyList last ].
	classesSelected := classesSelected
		ifNil: [ classesForCategories ]
		ifNotNil: [ 
			classesSelected
				select: [ :each | classesForCategories includes: each ] ].
	classIndex
		ifNil: [ classIndex := 0 ]
		ifNotNil: [
			(classesSelected includes: (classes at: classIndex ifAbsent: [])) ifFalse: [
				classIndex := 0 ] ].
	self 
		changed: #classList;
		changed: #classSelected;
		changed: #hasRunnable
]

{ #category : #updating }
TestRunner >> updateResults [
	"<lint: #expect rule: #guardingClause>"
	"<lint: #expect rule: #longMethods>"

	self updateStatus: false.
	failedList size = result failures size ifFalse: [
		failedList := result failures asArray
			sort: [ :a :b | a printString <= b printString ].
		failedSelected := nil.
		self 
			changed: #failedList; 
			changed: #failedSelected;
			changed: #hasFailures;
			changed: #hasProgress  ].
	errorList size = result errors size ifFalse: [
		errorList := result errors asArray
			sort: [ :a :b | a printString <= b printString ].
		errorSelected := nil.
		self 
			changed: #errorList; 
			changed: #errorSelected;
			changed: #hasErrors;
			changed: #hasProgress;
			changed: #classList ].
]

{ #category : #updating }
TestRunner >> updateStatus: aBoolean [
	"Update the status display, at most once a second if aBoolean is true."

	(aBoolean and: [ lastUpdate = Time totalSeconds ])
		ifTrue: [ ^ self ].
	self changed: #statusText; changed: #statusColor; changed: #statusTextColor.
	lastUpdate := Time totalSeconds.
]

{ #category : #private }
TestRunner >> windowIsClosing [
	SystemChangeNotifier uniqueInstance noMoreNotificationsFor: self
]
