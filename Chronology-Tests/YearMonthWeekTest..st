"
I am one of several Sunit test Cases intentended to provide complete coverage for the Chronology set of classes as part of the external testing. See DateAndEpochTestCase for a complete list.  tlk.
I have no fixtures but do make sure to restore anything I change.
"
Class {
	#name : #YearMonthWeekTest,
	#superclass : #TestCase,
	#instVars : [
		'restoredStartDay',
		'restoredTimeZone',
		'localTimeZonePreferenceToRestore'
	],
	#category : #'Chronology-Tests'
}

{ #category : #running }
YearMonthWeekTest >> setUp [
	restoredStartDay := Week startDay.
	restoredTimeZone := DateAndTime localTimeZone.
	localTimeZonePreferenceToRestore := DateAndTime automaticTimezone.
	Week startDay: #Sunday.
	DateAndTime localTimeZone: (TimeZone timeZones detect: [:tz | tz abbreviation = 'GMT']).

]

{ #category : #running }
YearMonthWeekTest >> tearDown [
	Week startDay: restoredStartDay.
	DateAndTime localTimeZone: restoredTimeZone.
	DateAndTime automaticTimezone: localTimeZonePreferenceToRestore.
]

{ #category : #testing }
YearMonthWeekTest >> testDaysInMonth [
	self assert: (Month daysInMonth: 2 forYear: 2000) = 29.
	self assert: (Month daysInMonth: 2 forYear: 2001) = 28.
	self assert: (Month  daysInMonth: 2 forYear: 2004) = 29.
	self assert: (Month  daysInMonth: 2 forYear: 2100) = 28.
	
	self assert: (Month  daysInMonth: 'January' forYear: 2003) = 31.
	self assert: (Month  daysInMonth: 'February' forYear: 2003) = 28.
	self assert: (Month  daysInMonth: 'March' forYear: 2003) = 31.
	self assert: (Month  daysInMonth: 'April' forYear: 2003) = 30.
	self assert: (Month  daysInMonth: 'May' forYear: 2003) = 31.
	self assert: (Month  daysInMonth: 'June' forYear: 2003) = 30.
	self assert: (Month  daysInMonth: 'July' forYear: 2003) = 31.
	self assert: (Month  daysInMonth: 'August' forYear: 2003) = 31.
	self assert: (Month  daysInMonth: 'September' forYear: 2003) = 30.
	self assert: (Month  daysInMonth: 'October' forYear: 2003) = 31.
	self assert: (Month  daysInMonth: 'November' forYear: 2003) = 30.
	self assert: (Month  daysInMonth: 'December' forYear: 2003) = 31.
]

{ #category : #testing }
YearMonthWeekTest >> testDaysInYear [
	self assert: (Year daysInYear: 2000) = 366.
	self assert: (Year daysInYear: 2001) = 365.
	self assert: (Year daysInYear: 2004) = 366.
	self assert: (Year daysInYear: 2100) = 365.
	self assert: (Year daysInYear: 2003) = 365.
]

{ #category : #testing }
YearMonthWeekTest >> testIndexOfDay [
	self assert: (Week indexOfDay: 'Friday') = 6.


]

{ #category : #testing }
YearMonthWeekTest >> testIsLeapYear [
	self assert: (Year isLeapYear: 2000).
	self deny: (Year isLeapYear: 2001).
	self assert: (Year isLeapYear: 2004).
	self deny: (Year isLeapYear: 2100).
	self deny: (Year isLeapYear: 2002).
]

{ #category : #testing }
YearMonthWeekTest >> testMonthPrintOn [
	| aMonth ws |
	aMonth := Month starting: DateAndTime new duration: 31 days.
	ws := '' writeStream.
	aMonth printOn: ws.
	self assert: ws contents = 'January 1901'.
]

{ #category : #testing }
YearMonthWeekTest >> testStartDay [
	Week startDay: 'Wednesday'.
	self assert: Week startDay = 'Wednesday'.
	Week startDay: 'Thursday'.
	self assert: Week startDay = 'Thursday'.


]

{ #category : #testing }
YearMonthWeekTest >> testWeekPrintOn [
	| aWeek cs rw |
	aWeek := Week starting: (DateAndTime year: 1900 month: 12 day: 31).
	cs := 'a Week starting: 1900-12-30T00:00:00+00:00'.
	rw := WriteStream on: ''.
	aWeek printOn: rw.
	self assert: rw contents = cs
]

{ #category : #testing }
YearMonthWeekTest >> testYearPrintOn [
	| aYear ws |
	aYear := Year starting: DateAndTime new duration: 365 days.
	ws := '' writeStream.
	aYear printOn: ws.
	self assert: ws contents = 'a Year (1901)'.
]
