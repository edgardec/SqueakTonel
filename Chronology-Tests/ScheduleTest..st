Class {
	#name : #ScheduleTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'firstEvent',
		'aSchedule',
		'restoredTimeZone',
		'localTimeZonePreferenceToRestore'
	],
	#category : #'Chronology-Tests'
}

{ #category : #Coverage }
ScheduleTest >> classToBeTested [

	^ Schedule


]

{ #category : #Coverage }
ScheduleTest >> selectorsToBeIgnored [

	| private | 
	private := #( #printOn: ).

	^ super selectorsToBeIgnored, private

]

{ #category : #running }
ScheduleTest >> setUp [
 	 "Schedule is a type of Timespan representing repeated occurences of the same event. 
	The beginning of the schedule is the first occurrence of the event.
	A schedule maintains an array of Durations. 
	Each durations specify the offset to the next scheduled each. 
	The duration of each occurence of the event is not specified. 
	Nor are any other attributes such as name"

	restoredTimeZone := DateAndTime localTimeZone.
	localTimeZonePreferenceToRestore := DateAndTime automaticTimezone.
	DateAndTime localTimeZone: (TimeZone timeZones detect: [:tz | tz abbreviation = 'GMT']).

	"Create aSchedule with an event scheduled for 8:30pm every Saturday 
	and Sunday for the year 2003. "
	"Create the first event occurring on the first Saturday at 8:30 pm: 1/4/03"
	firstEvent :=  DateAndTime year: 2003 month: 1 day: 4 hour: 20 minute: 30. 
	
	"Create a schedule for one year starting with the first event" 
	aSchedule := Schedule starting: firstEvent duration: 52 weeks.

	"Schedule the recurring events by scheduling the time in between each one.  
	One day for Sat-Sun. 6 days for Sun-Sat" 
	aSchedule schedule: { Duration days: 1. Duration days: 6 }.

]

{ #category : #running }
ScheduleTest >> tearDown [

	DateAndTime localTimeZone: restoredTimeZone.
	DateAndTime automaticTimezone: localTimeZonePreferenceToRestore.
 
]

{ #category : #testing }
ScheduleTest >> testBetweenAndDoDisjointWithSchedule [
	| count |
	count := 0.
	aSchedule
		between: (DateAndTime
				year: 2004
				month: 4
				day: 1)
		and: (DateAndTime
				year: 2004
				month: 4
				day: 30)
		do: [:each | count := count + 1].
	self assert: count = 0
]

{ #category : #testing }
ScheduleTest >> testBetweenAndDoIncludedInSchedule [
	| count |
	count := 0.
	aSchedule
		between: (DateAndTime
				year: 2003
				month: 4
				day: 1)
		and: (DateAndTime
				year: 2003
				month: 4
				day: 30)
		do: [:each | count := count + 1].
	self assert: count = 8
]

{ #category : #testing }
ScheduleTest >> testBetweenAndDoOverlappingSchedule [
	| count |
	count := 0.
	aSchedule
		between: (DateAndTime
				year: 2002
				month: 12
				day: 1)
		and: (DateAndTime
				year: 2003
				month: 1
				day: 31)
		do: [:each | count := count + 1].
	self assert: count = 8
]

{ #category : #testing }
ScheduleTest >> testDateAndTimes [
	| answer |
	self assert: aSchedule dateAndTimes size  = 104.
	self assert: aSchedule dateAndTimes first = firstEvent.
	answer := true.
	aSchedule dateAndTimes do: [:each | (each dayOfWeekName = 'Saturday'
		or: [each dayOfWeekName = 'Sunday']) ifFalse: [^false]].
	self assert: answer

]

{ #category : #testing }
ScheduleTest >> testExampleFromSwikiPage [
	"It is often neccessary to schedule repeated events, like airline flight schedules, TV programmes, and file backups.
	 Schedule is a Timespan which maintains an array of Durations.
	 The durations specify the offset to the next scheduled DateAndTime. "
	"Consider a TV programme scheduled for 8:30pm every Saturday and Sunday for the current year. "
	"Find the first Saturday and set its time to 20h30"
	| sat shows |
	sat := Year current asMonth dates detect: [ :d | d dayOfWeekName = #Saturday ].
	sat := sat start + (Duration hours: 20.5).
	"Create a schedule" 
	shows := Schedule starting: sat ending: Year current end.
	shows schedule: { Duration days: 1. Duration days: 6 }.
	"To inspect:"
	shows dateAndTimes.
	shows dateAndTimes collect: [ :dt | dt dayOfWeekName ].


]

{ #category : #Tests }
ScheduleTest >> testFromDateAndTime [

	| oc1 oc2 |
	oc1 := OrderedCollection new.
	DateAndTime today to: DateAndTime tomorrow by: 10 hours do: [ :dt | oc1 add: dt ].

	oc2 := { DateAndTime today. 
			(DateAndTime today + 10 hours). 
				(DateAndTime today + 20 hours) }.

	self assert: (oc1 asArray = oc2)
]

{ #category : #testing }
ScheduleTest >> testIncludes [
	self assert: (aSchedule includes: (DateAndTime year: 2003 month: 6 day: 15 hour: 20 minute: 30 second: 0 offset: 0 hours))
	

]

{ #category : #Tests }
ScheduleTest >> testMonotonicity [

	| t1 t2 t3 t4 |
	t1 := DateAndTime now.
	t2 := DateAndTime now.
	t3 := DateAndTime now.
	t4 := DateAndTime now.

	self 
		assert: (	t1 <= t2);
		assert: (	t2 <= t3);
		assert: (	t3 <= t4).

]

{ #category : #testing }
ScheduleTest >> testSchedule [
	self assert: aSchedule schedule size = 2.
	self assert: aSchedule schedule first = 1 days.	
	self assert: aSchedule schedule second = 6 days.

]