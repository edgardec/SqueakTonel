"
See PDA comment. 
"
Class {
	#name : #PDARecurringEvent,
	#superclass : #PDAEvent,
	#instVars : [
		'recurrence',
		'firstDate',
		'lastDate'
	],
	#category : #'Etoys-Squeakland-Morphic-PDA'
}

{ #category : #'as yet unclassified' }
PDARecurringEvent class >> chooseRecurrence [

	^ (CustomMenu selections: self basicNew validRecurrenceSymbols) startUp
		ifNil: [#dateOfYear]
]

{ #category : #'as yet unclassified' }
PDARecurringEvent >> firstDate: aDate [

	firstDate := aDate

]

{ #category : #'as yet unclassified' }
PDARecurringEvent >> lastDate: aDate [

	lastDate := aDate

]

{ #category : #date }
PDARecurringEvent >> matchesDate: aDate [ 
	(firstDate isNil or: [firstDate > aDate]) ifTrue: [^false].
	(lastDate notNil and: [lastDate < aDate]) ifTrue: [^false].
	recurrence == #eachDay ifTrue: [^true].
	recurrence == #dayOfWeek ifTrue: [^aDate weekday = firstDate weekday].
	recurrence == #dayOfMonth 
		ifTrue: [^aDate dayOfMonth = firstDate dayOfMonth].
	recurrence == #dateOfYear 
		ifTrue: 
			[^aDate monthIndex = firstDate monthIndex 
				and: [aDate dayOfMonth = firstDate dayOfMonth]].
	recurrence == #nthWeekdayOfMonth 
		ifTrue: 
			[^aDate weekday = firstDate weekday 
				and: [(aDate dayOfMonth - 1) // 7 = ((firstDate dayOfMonth - 1) // 7)]].
	recurrence == #nthWeekdayOfMonthEachYear 
		ifTrue: 
			[^aDate monthIndex = firstDate monthIndex and: 
					[aDate weekday = firstDate weekday 
						and: [(aDate dayOfMonth - 1) // 7 = ((firstDate dayOfMonth - 1) // 7)]]]
]

{ #category : #key }
PDARecurringEvent >> matchesKey: aString andMatchesDate: aDate [

	aString = 'recurring' ifTrue: [^ true].
	^ super matchesKey: aString andMatchesDate: aDate
]

{ #category : #'as text' }
PDARecurringEvent >> readField: fieldName fromString: aString fields: sharedFields base: instVarBase [
	"Overridden to check for valid recurrence symbol"

	fieldName = 'recurrence' ifTrue: [^ self recurrence: aString withBlanksTrimmed asSymbol].
	^ super readField: fieldName fromString: aString fields: sharedFields base: instVarBase

]

{ #category : #'as yet unclassified' }
PDARecurringEvent >> recurrence [
	"Return the value of recurrence"
	^ recurrence
]

{ #category : #'as yet unclassified' }
PDARecurringEvent >> recurrence: rSymbol [
	(self validRecurrenceSymbols includes: rSymbol)
		ifFalse: [^ self error: 'unrecognized recurrence symbol: , rSymbol'].
	recurrence := rSymbol
]

{ #category : #'as yet unclassified' }
PDARecurringEvent >> validRecurrenceSymbols [
	^ #(eachDay dayOfWeek dayOfMonth dateOfYear nthWeekdayOfMonth nthWeekdayOfMonthEachYear)
]
