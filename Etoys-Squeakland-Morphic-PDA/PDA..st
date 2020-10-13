"
PDA help text...
A lot about the PDA should be obvious just by opening one up and playing with the sample data.  The PDA holds a complete database of people, events, to-do items and notes.  The date and keyword selected determine which records are visible at any given time.

All records
All records in the database have a number of pre-allocated fields, and these are displayed in the obvious manner in the current item pane at the bottom, when the record is selected.  Care must be taken to enter only valid data as the contents of any field.  This is usually simple but, for instance, matching string quotes can be a problem (embedded string quotes must be doubled).

Any item may be augmented by any number of fields, provided that the field names do not conflict with existing ones, and that the contents are valid Squeak objects.

The description field may often carry a long body of text so, for this reason, a special feature is provided for viewing only the description of the current item.  This makes it a lot easier to read long notes (like this one), and it saves the user from worrying about matching quotes and other punctuation.  Sorry it's a mode -- use the menu of the bottom pane to switch modes.

People
Since the name field is not split into first, middle, last as in some databases, you are encouraged to adopt the following format:
	Lastname, First I., Jr. (Nickname) (&Spousename)
which allows for useful processing for invitations and the like.

ToDoItems
ToDo items are designed not to be removed, but only to be marked done.  This allows the database to be browsed retroactively, with the to-do items appearing and disappearing on the dates the tasks were introduced and completed respectively.  Note that toDo items have a deadline field whose obvious associated semantics (see alarms) have not yet been implemented.

Schedule
Scedule items are relatively simple.  It is intended that if duration is specified, and that if time+duration overlaps ensuing events, that the ensuing events will be show in red or someting like that.  Alarms have not yet been implemented, but they will accept an integer field equal to the number of minutes prior to event time that the alarm should appear.  Presumably an alarm will apppear as a new object on the screen that announces the event, sounds a continuing audible sound, and allows easy dismissal by clicking or keystroke.

A number of short forms are allowed for the time field, such as '4p' asTime.
An event with time = nil will appear with dashes at the beginning of the day.

RecurringEvents
Recurring events are treated specially.  Each master event is consulted to generate derivative events in the schedule for any given day.  You can edit the derivative events, at which point they will become permanent events just like any other.  An unedited recurring event is a virtual object -- if you edit the master, its derivative copies may disappear from one time and reappear at another.  For this reason it is recommended that you never alter the date of a recurring event.  Instead, declare its last date, causing an end to that series, and create another recurring event for the new schedule if desired.  In this manner all the past schedule will continue to appear as it did when it was current.

To examine or alter recurring events, select the 'recurring' category (this will need further filtering for large databases).  The currently supported recurrence rules include
	#eachDay - for example, a 2-week vacation (give first and last dates).
	#dayOfWeek - for example, every Thursday
	#dayOfMonth - for example, on the first day of every month
	#dateOfYear - for example, birthdays and many holidays
	#nthWeekdayOfMonth - for example, the second Tuesday of every month
	#nthWeekdayOfMonthEachYear - for example, Thanksgiving
(The Squeak PDA does not support the recurrence rule for Easter Sunday ;-).

Notes
Notes are simple a place to capture thoughts and information relevant to the different areas of your life while you are in the simple planning mood inspired by using a PDA.  The ability to view the current item's description only is especially useful for notes.

Spawn Entire Month
While this feature (accessible from bottom pane menu) is very crude and does not offer interaction, its real purpose is for printing.  Expand the spawned window to full screen, use the morph menu to choose 'print PS to File...', and then send the resulting .eps file to your printer.  (At the time of this writing portrait and landscpe options were reversed ;-).
"
Class {
	#name : #PDA,
	#superclass : #Model,
	#instVars : [
		'userCategories',
		'allPeople',
		'allEvents',
		'recurringEvents',
		'allToDoItems',
		'allNotes',
		'date',
		'category',
		'currentItem',
		'currentItemText',
		'currentItemSelection',
		'categoryList',
		'categoryListIndex',
		'peopleList',
		'peopleListIndex',
		'scheduleList',
		'scheduleListIndex',
		'toDoList',
		'toDoListIndex',
		'notesList',
		'notesListIndex',
		'dateButtonPressed',
		'viewDescriptionOnly'
	],
	#category : #'Etoys-Squeakland-Morphic-PDA'
}

{ #category : #currentItem }
PDA >> acceptCurrentItemText: aText [
	"Accept into the current item from the text provided, and update lists accordingly"

	currentItem ifNil:
		[self inform: 'Can''t accept -- no item is selected'. ^ false].
	viewDescriptionOnly ifTrue:
		[currentItem description: aText string. ^ true].

	currentItem readFrom: aText.
	(currentItem isKindOf: PDAEvent) ifTrue: [self updateScheduleList].
	(currentItem isMemberOf: PDAToDoItem) ifTrue: [self updateToDoList].
	(currentItem isMemberOf: PDAPerson) ifTrue: [self updatePeopleList].
	(currentItem isMemberOf: PDARecord) ifTrue: [self updateNotesList].
	^ true
]

{ #category : #schedule }
PDA >> addEvent [
	| newEvent |
	newEvent := PDAEvent new key: self categorySelected; date: date;
						time: (Time readFromString: '7 am');
						description: 'new event'.
	allEvents := allEvents copyWith: newEvent.
	self currentItem: newEvent.
	self updateScheduleList
]

{ #category : #notes }
PDA >> addNote [
	| newNote |
	newNote := PDARecord new key: self categorySelected; description: 'new note'.
	allNotes := allNotes copyWith: newNote.
	self currentItem: newNote.
	self updateNotesList
]

{ #category : #people }
PDA >> addPerson [
	| newPerson |
	newPerson := PDAPerson new key: self categorySelected; name: 'Last, First'.
	allPeople := allPeople copyWith: newPerson.
	self currentItem: newPerson.
	self updatePeopleList
]

{ #category : #schedule }
PDA >> addRecurringEvent [
	| newEvent |
	newEvent := PDARecurringEvent new key: self categorySelected;
						firstDate: date; recurrence: PDARecurringEvent chooseRecurrence;
						description: 'recurring event'.
	newEvent key = 'recurring' ifTrue: [newEvent key: 'all'].
	newEvent recurrence == #eachDay ifTrue: [newEvent lastDate: (date addDays: 1)].
	recurringEvents := recurringEvents copyWith: newEvent.
	self currentItem: newEvent.
	self updateScheduleList
]

{ #category : #'to do' }
PDA >> addToDoItem [
	| newToDoItem |
	newToDoItem := PDAToDoItem new key: self categorySelected; description: 'new item to do';
					dayPosted: Date today; priority: 1.
	allToDoItems := allToDoItems copyWith: newToDoItem.
	self currentItem: newToDoItem.
	self updateToDoList
]

{ #category : #category }
PDA >> categoryChoices [
	"Return a list for the popup chooser"
	| special |
	special := {'all'. 'recurring'. nil}.
	(special includes: category) ifTrue:
		[^ special , userCategories , {nil. 'add new key'}].
	^ special , userCategories , {nil. 'remove ' , self categorySelected. 'rename ' , self categorySelected. nil. 'add new key'}
]

{ #category : #category }
PDA >> categorySelected [

	^ category ifNil: ['all']

]

{ #category : #category }
PDA >> chooseFrom: chooserMorph categoryItem: item [

	| newKey menu |
	newKey := item.
	self okToChange ifFalse: [^ self].
	(item = 'add new key') ifTrue:
		[newKey := FillInTheBlank request: 'New key to use'
						initialAnswer: self categorySelected.
		newKey isEmpty ifTrue: [^ self].
		(userCategories includes: newKey) ifTrue: [^ self].
		userCategories := (userCategories copyWith: newKey) sort].
	(item beginsWith: 'remove ') ifTrue:
		[(self confirm: 'Removal of this category will cause all items formerly
categorized as ''' , self categorySelected , ''' to be reclassified as ''all''.
Is this really what you want to do?
[unless there are very few, choose ''no'']')
			ifFalse: [^ self].
		self rekeyAllRecordsFrom: self categorySelected to: 'all'.
		userCategories := userCategories copyWithout: self categorySelected.
		newKey := 'all'].
	(item beginsWith: 'rename ') ifTrue:
		[menu := CustomMenu new.
		userCategories do: [:key | menu add: key action: key].
		newKey := menu startUpWithCaption: 'Please select the new key for
items now categorized as ''' , self categorySelected , '''.'.
		newKey ifNil: [^ self].
		(self confirm: 'Renaming this category will cause all items formerly
categorized as ''' , self categorySelected , ''' to be reclassified as ''' , newKey , '''.
Is this really what you want to do?')
			ifFalse: [^ self].
		self rekeyAllRecordsFrom: self categorySelected to: newKey.
		userCategories := userCategories copyWithout: self categorySelected].
	self selectCategory: newKey.
	chooserMorph contentsClipped: newKey
]

{ #category : #currentItem }
PDA >> clearUserEditFlag [
	"Clear the hasUnacceptedEdits flag in all my dependent views."

	self changed: #clearUserEdits
]

{ #category : #currentItem }
PDA >> currentItem [
	"Return the value of currentItem"
	currentItem ifNil: [^ 'No item is selected.'].
	^ currentItem
]

{ #category : #currentItem }
PDA >> currentItem: newValue [
	"Assign newValue to currentItem."

	currentItem class == newValue class ifFalse:
		["get rid of this hideous hack"
		(currentItem isMemberOf: PDAEvent) ifTrue: [self scheduleListIndex: 0].
		(currentItem isMemberOf: PDAToDoItem) ifTrue: [self toDoListIndex: 0].
		(currentItem isMemberOf: PDAPerson) ifTrue: [self peopleListIndex: 0].
		(currentItem isMemberOf: PDARecord) ifTrue: [self notesListIndex: 0]].
	currentItem := newValue.
	self changed: #currentItemText
]

{ #category : #currentItem }
PDA >> currentItemMenu: aMenu [
	| donorMenu labels |
	viewDescriptionOnly
		ifTrue: [aMenu add: 'view entire records' target: self selector: #toggleDescriptionMode]
		ifFalse: [aMenu add: 'view descriptions only' target: self selector: #toggleDescriptionMode].
	aMenu addLine.
	aMenu add: 'save database' target: self selector: #saveDatabase.
	aMenu add: 'load database from file...' target: self selector: #loadDatabase.
	aMenu add: 'spawn entire month' target: self selector: #openMonthView.
	aMenu addLine.
	aMenu add: 'accept (s)' target: self selector: #accept.
	aMenu add: 'cancel (l)' target: self selector: #cancel.
	aMenu addLine.
	donorMenu := ParagraphEditor yellowButtonMenu.
	labels := donorMenu labelString findTokens: String cr.
	aMenu labels: (labels allButLast: 4) lines: donorMenu lineArray selections: donorMenu selections.
	^ aMenu
]

{ #category : #currentItem }
PDA >> currentItemSelection [
	"Return the value of currentItemSelection"
	currentItemSelection ifNil: [^ 1 to: 0].
	^ currentItemSelection
]

{ #category : #currentItem }
PDA >> currentItemSelection: newValue [
	"Assign newValue to currentItemSelection."

	currentItemSelection := newValue.
]

{ #category : #currentItem }
PDA >> currentItemText [

	currentItem ifNil: [^ 'no item is selected'].
	viewDescriptionOnly
		ifTrue: [currentItem description ifNil:
					[^ 'No description has yet been entered for this item'].
				^ currentItem description asText]
		ifFalse: [^ currentItem asText]
]

{ #category : #'to do' }
PDA >> declareItemDone [
	| report |
	report := FillInTheBlank 
				request: 'This item will be declared done as of
' , date printString 
						, '.
Please give a short summary of status'
				initialAnswer: 'Completed.'.
	(report isNil or: [report isEmpty]) ifTrue: [^self].
	currentItem
		dayDone: date;
		result: report.
	self currentItem: currentItem
]

{ #category : #schedule }
PDA >> declareLastDate [
	(self confirm: 'Please confirm termination of this event as of
' , date printString , '.')
		ifFalse: [^ self].
	currentItem lastDate: date.
	self currentItem: currentItem

]

{ #category : #schedule }
PDA >> declarelastDate [
	(self confirm: 'Please confirm termination of this event as of
' , date printString , '.')
		ifFalse: [^ self].
	currentItem lastDate: date.
	self currentItem: currentItem

]

{ #category : #initialization }
PDA >> initialize [
	viewDescriptionOnly := false.
	self userCategories: self sampleCategoryList
		allPeople: self samplePeopleList
		allEvents: self sampleScheduleList
		recurringEvents: self sampleRecurringEventsList
		allToDoItems: self sampleToDoList
		allNotes: self sampleNotes
		dateSelected: Date today
	
]

{ #category : #initialization }
PDA >> labelString [

	| today |
	today := Date today.
	^ String streamContents:
		[:s | s nextPutAll: today weekday; space.
		Time now print24: false showSeconds: false on: s.
		s nextPutAll: '  --  '.
		s nextPutAll: today monthName; space; print: today dayOfMonth;
			nextPutAll: ', '; print: today year]
]

{ #category : #initialization }
PDA >> loadDatabase [
	| aName aFileStream list |
	aName := UIManager default chooseFileMatchingSuffixes: #('pda' 'pda.gz' ) label: 'Choose a file to load'.
	aName
		ifNil: [^ self].

	aFileStream := FileStream oldFileNamed: aName.
	list := aFileStream fileInObjectAndCode.
	userCategories := list first.
	allPeople := list second.
	allEvents := list third.
	recurringEvents := list fourth.
	allToDoItems := list fifth.
	allNotes := list sixth.
	date := Date today.
	self selectCategory: 'all'
]

{ #category : #initialization }
PDA >> mergeDatabase [
	| aName aFileStream list |
	aName :=  UIManager default chooseFileMatchingSuffixes: #('pda' 'pda.gz' ) label: 'Choose a file to load'.
	aName
		ifNil: [^ self].
	aFileStream := FileStream oldFileNamed: aName.
	list := aFileStream fileInObjectAndCode.
	userCategories := (list first , userCategories) asSet asArray sort.
	allPeople := (list second , allPeople) asSet asArray sort.
	allEvents := (list third , allEvents) asSet asArray sort.
	recurringEvents := (list fourth , recurringEvents) asSet asArray sort.
	allToDoItems := (list fifth , allToDoItems) asSet asArray sort.
	allNotes := ((list sixth)
				, allNotes) asSet asArray sort.
	date := Date today.
	self selectCategory: 'all'
]

{ #category : #notes }
PDA >> notesList [
	"Return the value of notesList"
	^ notesList
]

{ #category : #notes }
PDA >> notesListIndex [
	"Return the value of notesListIndex"
	^ notesListIndex
]

{ #category : #notes }
PDA >> notesListIndex: newValue [
	"Assign newValue to notesListIndex."

	notesListIndex = newValue ifTrue: [^ self].
	self okToChange ifFalse: [^ self].
	notesListIndex := newValue.
	self currentItem: (notesListIndex ~= 0
						ifTrue: [notesList at: notesListIndex]
						ifFalse: [nil]).
	self changed: #notesListIndex.
]

{ #category : #notes }
PDA >> notesListItems [

	^ notesList collect: [:p | p asListItem]
]

{ #category : #notes }
PDA >> notesMenu: aMenu [

	aMenu add: 'add new note' target: self selector: #addNote.
	notesListIndex > 0 ifTrue:
		[aMenu add: 'remove note' target: self selector: #removeNote].
	^ aMenu
]

{ #category : #updating }
PDA >> okToChange [

	self canDiscardEdits ifTrue: [^ true].
	self changed: #wantToChange.  "Solicit cancel from view"
	^ self canDiscardEdits

]

{ #category : #initialization }
PDA >> openAsMorphIn: window [  "PDA new openAsMorph openInWorld"
	"Create a pluggable version of all the morphs for a Browser in Morphic"
	| dragNDropFlag paneColor chooser |
	window color: Color black.
	paneColor := (Color r: 0.6 g: 1.0 b: 0.0).
	window model: self.
	dragNDropFlag := SystemBrowser browseWithDragNDrop.
	window addMorph: ((PluggableListMorph on: self list: #peopleListItems
			selected: #peopleListIndex changeSelected: #peopleListIndex:
			menu: #peopleMenu: keystroke: #peopleListKey:from:) enableDragNDrop: dragNDropFlag)
		frame: (0@0 corner: 0.3@0.25).
	window addMorph: ((chooser := PDAChoiceMorph new color: paneColor) contentsClipped: 'all';
			target: self; actionSelector: #chooseFrom:categoryItem:; arguments: {chooser};
			getItemsSelector: #categoryChoices)
		frame: (0@0.25 corner: 0.3@0.3).
	window addMorph: ((MonthMorph newWithModel: self) color: paneColor; extent: 148@109)
		frame: (0.3@0 corner: 0.7@0.3).
	window addMorph: (PDAClockMorph new color: paneColor;
						faceColor: (Color r: 0.4 g: 0.8 b: 0.6))  "To match monthMorph"
		frame: (0.7@0 corner: 1.0@0.3).

	window addMorph: ((PluggableListMorph on: self list: #toDoListItems
			selected: #toDoListIndex changeSelected: #toDoListIndex:
			menu: #toDoMenu: keystroke: #toDoListKey:from:) enableDragNDrop: dragNDropFlag)
		frame: (0@0.3 corner: 0.3@0.7).
	window addMorph: ((PluggableListMorph on: self list: #scheduleListItems
			selected: #scheduleListIndex changeSelected: #scheduleListIndex:
			menu: #scheduleMenu: keystroke: #scheduleListKey:from:) enableDragNDrop: dragNDropFlag)
		frame: (0.3@0.3 corner: 0.7@0.7).
	window addMorph: ((PluggableListMorph on: self list: #notesListItems
			selected: #notesListIndex changeSelected: #notesListIndex:
			menu: #notesMenu: keystroke: #notesListKey:from:) enableDragNDrop: dragNDropFlag)
		frame: (0.7@0.3 corner: 1@0.7).

	window addMorph: (PluggableTextMorph on: self
			text: #currentItemText accept: #acceptCurrentItemText:
			readSelection: #currentItemSelection menu: #currentItemMenu:)
		frame: (0@0.7 corner: 1@1).
	window firstSubmorph color: paneColor.
	window updatePaneColors.
	window step.
	^ window
]

{ #category : #initialization }
PDA >> openMonthView [
	| row month col paneExtent window paneColor nRows |
	month := date notNil
		ifTrue: [date month]
		ifFalse: ["But... it's here somewhere..."
				((self dependents detect: [:m | m isKindOf: PDAMorph])
					findA: MonthMorph) month].
	window := SystemWindow labelled: month printString.
	paneColor := Color transparent.
	window color: (Color r: 0.968 g: 1.0 b: 0.355).
	nRows := 0.  month weeksDo: [:w | nRows := nRows + 1].
	paneExtent := ((1.0/7) @ (1.0/nRows)).
	row := 0.
	month weeksDo:
		[:week | col := 0.
		week datesDo:
			[:day | day month = month ifTrue:
				[window addMorph: ((PluggableListMorph on: self list: nil
						selected: nil changeSelected: nil menu: nil keystroke: nil)
							list: {(day dayOfMonth printString , '  ' , day weekday) asText allBold}
								, (self scheduleListForDay: day))
					frame: (paneExtent * (col@row) extent: paneExtent)].
			col := col + 1].
		row := row + 1].

	window firstSubmorph color: paneColor.
	window updatePaneColors.
	window openInWorld
]

{ #category : #people }
PDA >> peopleList [
	"Return the value of peopleList"
	^ peopleList
]

{ #category : #people }
PDA >> peopleListIndex [
	"Return the value of peopleListIndex"
	^ peopleListIndex
]

{ #category : #people }
PDA >> peopleListIndex: newValue [
	"Assign newValue to peopleListIndex."

	peopleListIndex = newValue ifTrue: [^ self].
	self okToChange ifFalse: [^ self].
	peopleListIndex := newValue.
	self currentItem: (peopleListIndex ~= 0
						ifTrue: [peopleList at: peopleListIndex]
						ifFalse: [nil]).
	self changed: #peopleListIndex.
]

{ #category : #people }
PDA >> peopleListItems [

	^ peopleList collect: [:p | p asListItem]
]

{ #category : #people }
PDA >> peopleMenu: aMenu [

	aMenu add: 'add new person' target: self selector: #addPerson.
	peopleListIndex > 0 ifTrue:
		[aMenu add: 'remove person' target: self selector: #removePerson].
	^ aMenu
]

{ #category : #menus }
PDA >> perform: selector orSendTo: otherTarget [
	"This should be the default in Object"

	(self respondsTo: selector)
		ifTrue: [^ self perform: selector]
		ifFalse: [^ otherTarget perform: selector]
]

{ #category : #initialization }
PDA >> rekeyAllRecordsFrom: oldKey to: newKey [

	allPeople do: [:r | r rekey: oldKey to: newKey].
	allEvents do: [:r | r rekey: oldKey to: newKey].
	recurringEvents do: [:r | r rekey: oldKey to: newKey].
	allToDoItems do: [:r | r rekey: oldKey to: newKey].
	allNotes do: [:r | r rekey: oldKey to: newKey].

]

{ #category : #schedule }
PDA >> removeEvent [

	(currentItem isKindOf: PDARecurringEvent)
	ifTrue: [(self confirm:
'Rather than remove a recurring event, it is
better to declare its last day to keep the record.
Do you still wish to remove it?')
				ifFalse: [^ self].
			recurringEvents := recurringEvents copyWithout: currentItem]
	ifFalse: [allEvents := allEvents copyWithout: currentItem].
	self currentItem: nil.
	self updateScheduleList.

]

{ #category : #notes }
PDA >> removeNote [

	allNotes := allNotes copyWithout: currentItem.
	self currentItem: nil.
	self updateNotesList.

]

{ #category : #people }
PDA >> removePerson [

	allPeople := allPeople copyWithout: currentItem.
	self currentItem: nil.
	self updatePeopleList.

]

{ #category : #'to do' }
PDA >> removeToDoItem [

	(self confirm: 'Rather than remove an item, it is
better to declare it done with a reason such as
''gave up'', or ''not worth it'', to keep the record.
Do you still wish to remove it?')
		ifFalse: [^ self].
	allToDoItems := allToDoItems copyWithout: currentItem.
	self currentItem: nil.
	self updateToDoList.

]

{ #category : #example }
PDA >> sampleCategoryList [

	^ { 'home'. 'work'. 'services' }
]

{ #category : #example }
PDA >> sampleNotes [

	^ {
	PDARecord new key: 'home'; description: 'sprinkler schedule'.
	PDARecord new key: 'home'; description: 'directions to our house
Take the expressway, #93 south
Then south on Rte 24
East at the T with 195
Take exit 12 and go right to Faunce Corner
Cross rte 6, continue on Old Westport Rd
takes a bend left and becomes Chase Rd
Continue for 3.5-4 mi
Rt at T intersection on Russell Mills Rd
Pass DPW on left
Lg Yellow bldg Davall''s store
left on Rocko Dundee Rd
down a swail and up.  We''re #419 on the left'.
	PDARecord new key: 'work'; description: 'archaeology memo'.
	PDARecord new key: 'work'; description: 'worlds and envts memo'.
	PDARecord new key: 'work'; description: PDA comment asString.
	}
]

{ #category : #example }
PDA >> samplePeopleList [

	^ {
	PDAPerson new key: 'work'; name: 'Carson, Kit (&Lilly)'; phone: '888-555-1234'; email: 'Kit.Carson@Cosmo.com'.
	PDAPerson new key: 'work'; name: 'Kidd, William (Billy)'; phone: '888-555-1234'; email: 'William.Kidd@Cosmo.com'.
	PDAPerson new key: 'services'; name: 'Dewey, Cheatham & Howe'; phone: '888-555-1234'; email: 'AndHow@Cosmo.com'.
	PDAPerson new key: 'home'; name: 'Duck, Donald'; phone: '888-555-1234'; email: 'Donald.Duck@Cosmo.com'.
	PDAPerson new key: 'home'; name: 'Duck, Huey'; phone: '888-555-1234'; email: 'Huey.Duck@Cosmo.com'.
	PDAPerson new key: 'home'; name: 'Duck, Dewey'; phone: '888-555-1234'; email: 'Dewey.Duck@Cosmo.com'.
	PDAPerson new key: 'home'; name: 'Duck, Louie'; phone: '888-555-1234'; email: 'Louie.Duck@Cosmo.com'.
	}
]

{ #category : #example }
PDA >> sampleRecurringEventsList [

	^ {
	PDARecurringEvent new key: 'home'; description: 'take out trash'; recurrence: #dayOfWeek; firstDate: (Date readFromString: '7 September 1999').
	PDARecurringEvent new key: 'home'; description: 'pay bills'; recurrence: #dayOfMonth; firstDate: (Date readFromString: '1 September 1999').
	PDARecurringEvent new key: 'all'; description: 'Columbus Day'; recurrence: #dateOfYear; firstDate: (Date readFromString: '12 October 1999').
	PDARecurringEvent new key: 'all'; description: 'Christmas'; recurrence: #dateOfYear; firstDate: (Date readFromString: '25 December 1999').
	PDARecurringEvent new key: 'all'; description: 'New Years'; recurrence: #dateOfYear; firstDate: (Date readFromString: '1 January 1999').
	PDARecurringEvent new key: 'all'; description: 'April Fools Day'; recurrence: #dateOfYear; firstDate: (Date readFromString: '1 April 1999').
	PDARecurringEvent new key: 'all'; description: 'Independence Day'; recurrence: #dateOfYear; firstDate: (Date readFromString: '4 July 1999').
	PDARecurringEvent new key: 'all'; description: 'Thanksgiving Day'; recurrence: #nthWeekdayOfMonthEachYear; firstDate: (Date readFromString: '25 November 1999').
	}
]

{ #category : #example }
PDA >> sampleScheduleList [

	^ {
	PDAEvent new key: 'home'; date: Date today; description: 'wake up'; time: (Time hour: 6 minute: 0 second: 0).
	PDAEvent new key: 'home'; date: Date today; description: 'go for a run'; time: (Time hour: 7 minute: 0 second: 0).
	PDAEvent new key: 'home'; date: Date today; description: 'take a shower'; time: (Time hour: 8 minute: 0 second: 0).
	PDAEvent new key: 'home'; date: (Date today addDays: 2); description: 'dinner out'; time: (Time hour: 18 minute: 0 second: 0).
	PDAEvent new key: 'work'; date: (Date today addDays: 1); description: 'conf call'; time: (Time hour: 10 minute: 0 second: 0).
	PDAEvent new key: 'work'; date: (Date today addDays: 2); description: 'Leave for Conference'; time: (Time hour: 8 minute: 0 second: 0).
	PDAEvent new key: 'work'; date: Date today; description: 'call Boss'; time: (Time hour: 15 minute: 0 second: 0).
	PDAEvent new key: 'work'; date: Date today; description: 'Call about 401k'; time: (Time hour: 10 minute: 0 second: 0).
	}
]

{ #category : #example }
PDA >> sampleToDoList [

	^ {
	PDAToDoItem new key: 'work'; dayPosted: (Date today subtractDays: 3); description: 'release external updates'; priority: 2.
	PDAToDoItem new key: 'work'; dayPosted: (Date today subtractDays: 3); description: 'first pass of sMovie'; priority: 1.
	PDAToDoItem new key: 'work'; dayPosted: (Date today subtractDays: 2); description: 'first pass of PDA'; priority: 2.
	PDAToDoItem new key: 'work'; dayPosted: (Date today subtractDays: 2); description: 'changes for finite undo'; priority: 2.
	PDAToDoItem new key: 'work'; dayPosted: (Date today subtractDays: 1); description: 'Msg to Freeman Zork'; priority: 1.
	PDAToDoItem new key: 'home'; dayPosted: (Date today subtractDays: 1); description: 'Fix fridge'; priority: 1.
	PDAToDoItem new key: 'home'; dayPosted: (Date today subtractDays: 3); description: 'Fix roof'; priority: 3.
	PDAToDoItem new key: 'home'; dayPosted: (Date today subtractDays: 3); description: 'Call about driveway'; priority: 4.
	}
]

{ #category : #initialization }
PDA >> saveDatabase [

	(FileStream newFileNamed: (FileDirectory default nextNameFor: 'PDA' extension: 'pda'))
		fileOutClass: nil
		andObject: {userCategories. allPeople. allEvents. recurringEvents. allToDoItems. allNotes}.
]

{ #category : #schedule }
PDA >> scheduleList [
	"Return the value of scheduleList"
	^ scheduleList
]

{ #category : #schedule }
PDA >> scheduleListForDay: aDate [

	| dayList |
	dayList := ((allEvents select: [:c | c matchesKey: 'all' andMatchesDate: aDate])
			, ((recurringEvents select: [:c | c matchesKey: 'all' andMatchesDate: aDate])
					collect: [:re | (re as: PDAEvent) date: aDate])) sort.
	^ dayList collect: [:evt | evt asListItem]
]

{ #category : #schedule }
PDA >> scheduleListIndex [
	"Return the value of scheduleListIndex"
	^ scheduleListIndex
]

{ #category : #schedule }
PDA >> scheduleListIndex: newValue [
	"Assign newValue to scheduleListIndex."

	scheduleListIndex = newValue ifTrue: [^ self].
	self okToChange ifFalse: [^ self].
	scheduleListIndex := newValue.
	self currentItem: (scheduleListIndex ~= 0
						ifTrue: [scheduleList at: scheduleListIndex]
						ifFalse: [nil]).
	self changed: #scheduleListIndex.
]

{ #category : #schedule }
PDA >> scheduleListItems [

	^ scheduleList collect: [:p | p asListItem]
]

{ #category : #schedule }
PDA >> scheduleMenu: aMenu [

	date ifNil: [^ aMenu add: 'select a date' target: self selector: #yourself.].
	self categorySelected ~= 'recurring' ifTrue:
		[aMenu add: 'add new event' target: self selector: #addEvent].
	aMenu add: 'add recurring event' target: self selector: #addRecurringEvent.
	scheduleListIndex > 0 ifTrue:
		[(currentItem isKindOf: PDARecurringEvent) ifTrue:
			[aMenu add: 'declare last date' target: self selector: #declareLastDate].
		aMenu add: 'remove event' target: self selector: #removeEvent].
	^ aMenu
]

{ #category : #category }
PDA >> selectCategory: cat [

	category := cat.
	self updateScheduleList.
	self updateToDoList.
	self updatePeopleList.
	self updateNotesList.
	currentItem ifNil: [^ self].
	(scheduleListIndex + toDoListIndex + peopleListIndex + notesListIndex) = 0 ifTrue:
		["Old current item is no longer current (not in any list)"
		currentItem := nil.
		self changed: #currentItemText]
]

{ #category : #date }
PDA >> selectDate: aDate [

	date := aDate.
	self updateScheduleList.
	self updateToDoList.
	self updateCurrentItem.
]

{ #category : #date }
PDA >> setDate: aDate fromButton: aButton down: down [ 
	dateButtonPressed ifNotNil: [dateButtonPressed setSwitchState: false].
	dateButtonPressed := down 
				ifTrue:  
					[self selectDate: aDate.
					aButton]
				ifFalse: 
					[self selectDate: nil.
					nil].
	self currentItem: nil.
	aButton ifNotNil: 
			[aButton owner owner highlightToday	"ugly hack to restore highlight for today"]
]

{ #category : #'to do' }
PDA >> toDoList [
	"Return the value of toDoList"
	^ toDoList
]

{ #category : #'to do' }
PDA >> toDoListIndex [
	"Return the value of toDoListIndex"
	^ toDoListIndex
]

{ #category : #'to do' }
PDA >> toDoListIndex: newValue [
	"Assign newValue to toDoListIndex."

	toDoListIndex = newValue ifTrue: [^ self].
	self okToChange ifFalse: [^ self].
	toDoListIndex := newValue.
	self currentItem: (toDoListIndex ~= 0
						ifTrue: [toDoList at: toDoListIndex]
						ifFalse: [nil]).
	self changed: #toDoListIndex.
]

{ #category : #'to do' }
PDA >> toDoListItems [

	^ toDoList collect: [:p | p asListItem]
]

{ #category : #'to do' }
PDA >> toDoMenu: aMenu [

	date ifNil: [^ aMenu add: 'select a date' target: self selector: #yourself.].
	aMenu add: 'add new item' target: self selector: #addToDoItem.
	toDoListIndex > 0 ifTrue:
		[aMenu add: 'declare item done' target: self selector: #declareItemDone.
		aMenu add: 'remove item' target: self selector: #removeToDoItem].
	^ aMenu
]

{ #category : #currentItem }
PDA >> toggleDescriptionMode [

	self okToChange ifFalse: [^ self].
	viewDescriptionOnly := viewDescriptionOnly not.
	self changed: #currentItemText
]

{ #category : #currentItem }
PDA >> updateCurrentItem [

	(peopleList includes: currentItem) ifTrue: [^ self].
	(scheduleList includes: currentItem) ifTrue: [^ self].
	(toDoList includes: currentItem) ifTrue: [^ self].
	(notesList includes: currentItem) ifTrue: [^ self].
	self currentItem: nil
]

{ #category : #notes }
PDA >> updateNotesList [

	notesList := (allNotes select: [:c | c matchesKey: self categorySelected]) sort.
	self notesListIndex: (notesList indexOf: currentItem).
	self changed: #notesListItems
]

{ #category : #people }
PDA >> updatePeopleList [

	peopleList := (allPeople select: [:c | c matchesKey: category]) sort.
	peopleListIndex := peopleList indexOf: currentItem.
	self changed: #peopleListItems
]

{ #category : #schedule }
PDA >> updateScheduleList [
	(date isNil
			and: [category ~= 'recurring'])
		ifTrue: [scheduleList := Array new.
			scheduleListIndex := 0.
			^ self changed: #scheduleListItems].
	scheduleList := (category = 'recurring'
				ifTrue: ["When 'recurring' is selected, edit actual masters"
					(recurringEvents
						select: [:c | c matchesKey: category andMatchesDate: date]) ]
				ifFalse: ["Otherwise, recurring events just spawn copies."
					((allEvents
						select: [:c | c matchesKey: category andMatchesDate: date])
						, ((recurringEvents
								select: [:c | c matchesKey: category andMatchesDate: date])
								collect: [:re | (re as: PDAEvent)
										date: date])) ])sort.
	scheduleListIndex := scheduleList indexOf: currentItem.
	self changed: #scheduleListItems
]

{ #category : #'to do' }
PDA >> updateToDoList [

	date ifNil:
		[toDoList := Array new. toDoListIndex := 0.
		^ self changed: #toDoListItems].
	toDoList := (allToDoItems select: [:c | c matchesKey: category andMatchesDate: date]) sort.
	toDoListIndex := toDoList indexOf: currentItem.
	self changed: #toDoListItems
]

{ #category : #initialization }
PDA >> userCategories: cats allPeople: ppl allEvents: evts recurringEvents: recEvts allToDoItems: todo allNotes: notes dateSelected: aDate [

	userCategories := cats.
	allPeople := ppl.
	allEvents := evts.
	recurringEvents := recEvts.
	allToDoItems := todo.
	allNotes := notes.
	
	date := aDate.  "Because updates ahead will need *both* date and category"
	self selectCategory: 'all'.
	self selectDate: aDate.  "Superfluous, but might not be"
]
