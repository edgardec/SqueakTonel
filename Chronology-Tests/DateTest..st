"
This is the unit test for the class Date. 
"
Class {
	#name : #DateTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'date',
		'aDate',
		'aTime'
	],
	#category : #'Chronology-Tests'
}

{ #category : #Coverage }
DateTest >> classToBeTested [

	^ self dateClass
]

{ #category : #Private }
DateTest >> dateClass [

	^ Date
]

{ #category : #Coverage }
DateTest >> selectorsToBeIgnored [

	 | deprecated private special |
	deprecated := #().
	private := #().
	special := #( #< #= #new #next #previous #printOn: #printOn:format: #storeOn: #fromString: ).

	^ super selectorsToBeIgnored, deprecated, private, special
]

{ #category : #Running }
DateTest >> setUp [

	date := self dateClass newDay: 153 year: 1973.	"2 June 1973"

	aDate := Date readFrom: '01-23-2004' readStream.
	aTime := Time readFrom: '12:34:56 pm' readStream
]

{ #category : #Tests }
DateTest >> testAccessing [

	self	
		assert: date day = 153;
		assert: date julianDayNumber = 2441836;
		assert: date leap = 0;
		assert: date monthIndex = 6;
		assert: date monthName = #June;
		assert: date weekday = #Saturday;
		assert: date weekdayIndex = 7;
		assert: date year = 1973.

]

{ #category : #testing }
DateTest >> testAddDays [
	self assert: (aDate addDays: 00) yyyymmdd =  '2004-01-23'.	
	self assert: (aDate addDays: 30) yyyymmdd =  '2004-02-22'.
	self assert: (aDate addDays: 60) yyyymmdd =  '2004-03-23'.
	self assert: (aDate addDays: 90) yyyymmdd =  '2004-04-22'.
	self assert: (aDate addDays:120) yyyymmdd =  '2004-05-22'
]

{ #category : #testing }
DateTest >> testAddMonths [
	self assert: (aDate addMonths: 0) yyyymmdd =  '2004-01-23'.	
	self assert: (aDate addMonths: 1) yyyymmdd =  '2004-02-23'.
	self assert: (aDate addMonths: 2) yyyymmdd =  '2004-03-23'.
	self assert: (aDate addMonths: 3) yyyymmdd =  '2004-04-23'.
	self assert: (aDate addMonths: 12) yyyymmdd =  '2005-01-23'.
	
	self assert: ((Date readFrom: '05-31-2017' readStream) addMonths: 1) yyyymmdd =  '2017-06-30'.
	self assert: ((Date readFrom: '02-29-2000' readStream) addMonths: 12) yyyymmdd =  '2001-02-28'
]

{ #category : #Tests }
DateTest >> testArithmetic [
	| d |
	d := date addDays: 32.		"4 July 1973"

	self 
		assert: d year = 1973;
		assert: d monthIndex = 7;
		assert: d dayOfMonth = 4.
	self 
		assert: (d subtractDate: date) = 32;
		assert: (date subtractDate: d) = -32.
	self	 
		assert: (d subtractDays: 32) = date.

]

{ #category : #testing }
DateTest >> testAsDate [
	self assert: (aDate asDate) = aDate

]

{ #category : #testing }
DateTest >> testAsSeconds [
	self assert: (aDate asSeconds) =   3252268800.
	self assert: (aDate asSeconds) =  ((103*365*24*60*60) + (22+25"leap days"*24*60*60)) .
	self assert: aDate  =  (Date fromSeconds: 3252268800).
]

{ #category : #Tests }
DateTest >> testComparing [
	| d1 d2 d3 |
	d1 := self dateClass newDay: 2 month: #June year: 1973.
	d2 := self dateClass newDay: 97 year: 2003. 		"7 April 2003"
	d3 := self dateClass newDay: 250 year: 1865. 		"7 September 1865"

	self
		assert: date = d1;
		assert: date = date copy;
		assert: date hash = d1 hash.
	self 
		assert: date < d2;
		deny: date < d3.

]

{ #category : #Tests }
DateTest >> testConverting [

	self 
		assert: date asDate = date;
		assert: '2 June 1973' asDate = date;
		assert: date asSeconds = 2285280000.

	date dayMonthYearDo: [ :d :m :y | self assert: d = 2; assert: m = 6; assert: y = 1973 ].
]

{ #category : #Tests }
DateTest >> testConvertingFromIso8601 [

	self 
		assert: '1973-06-02' asDate = date;
		assert: '1973-JUN-02' asDate = date;
		assert: '1973-June-02' asDate = date
]

{ #category : #testing }
DateTest >> testDateAndTimeNow [
	"Not a great test: could falsely fail if midnight come in between the two executions and doesnt catch time errors"
	self assert: Date dateAndTimeNow first  = Date today 

]

{ #category : #testing }
DateTest >> testDayMonthYearDo [
	self assert: (aDate dayMonthYearDo: [:day :month :year | day asString , month asString, year asString]) = '2312004'

]

{ #category : #testing }
DateTest >> testDaysInMonthForYear [
	self assert: (Date daysInMonth: 'February' forYear: 2008)  = 29.	
	self assert: (Date daysInMonth: 'February' forYear: 2000)  = 29.	
	self assert: (Date daysInMonth: 'February' forYear: 2100)  = 28.	
	self assert: (Date daysInMonth: 'July' forYear: 2100)  = 31.	
]

{ #category : #testing }
DateTest >> testDaysInYear [
	self assert: (Date daysInYear: 2008)  = 366.	
	self assert: (Date daysInYear: 2000)  = 366.	
	self assert: (Date daysInYear: 2100)  = 365	

]

{ #category : #testing }
DateTest >> testDuration [
	self assert: aDate duration = 24 hours
]

{ #category : #testing }
DateTest >> testEqual [
	self assert: aDate = (Date readFrom: (ReadStream on: 'January 23, 2004')).
]

{ #category : #testing }
DateTest >> testFirstWeekdayOfMonthYear [
	self assert: (Date firstWeekdayOfMonth: 'January' year: 2004)  = 5.	

]

{ #category : #Tests }
DateTest >> testFromDateAndTime [

	| aDateAndTime |
	aDateAndTime := '2018-10-22T22:51:38.322706-04:00' asDateAndTime.
	aDate := aDateAndTime asDate.
	self
		assert: aDate start offset
		equals: aDateAndTime offset
		description: 'Start time for a Date created from a DateAndTime should preserve local time offset'
]

{ #category : #Tests }
DateTest >> testFromDays [
	| epoch d0 d1 d2 |
	epoch := self dateClass newDay: 1 year: 1901.
	d0 := self dateClass fromDays: 0. 			"1 January 1901"
	self assert: d0 = epoch.

	d1 := self dateClass fromDays:  26450. 	"2 June 1973"
	self assert: d1 = date.

	d2 := self dateClass fromDays: -100000.	"18 March 1627"
	self assert: d2 julianDayNumber = 2315386.

	self assert: aDate  =  (Date fromDays:  37642).
	self assert: aDate  =  (Date fromDays: 103*365 + 22 + 25 "leap days") .
	
]

{ #category : #Tests }
DateTest >> testFromSeconds [
	| d |
	d := self dateClass fromSeconds: 2285280000. 
	self
		assert: d = date.

]

{ #category : #Tests }
DateTest >> testGeneralInquiries [

	| shuffled indices names now | 

	shuffled := #(#January #February #March #April #May #June #July 
					#August #September #October #November #December) shuffled.
	indices := shuffled collect: [ :m | self dateClass indexOfMonth: m ].
	names := indices collect: [ :i | self dateClass nameOfMonth: i ].
	self assert: names = shuffled.

	shuffled := #(#Monday #Tuesday #Wednesday #Thursday #Friday #Saturday #Sunday) shuffled.
	indices := shuffled collect: [ :m | self dateClass dayOfWeek: m ].
	names := indices collect: [ :i | self dateClass nameOfDay: i ].
	self assert: names = shuffled.
	
	now  := self dateClass dateAndTimeNow.
	self 
		assert: now size = 2;
		assert: now first = self dateClass today.

	self assert: (self dateClass firstWeekdayOfMonth: #June year: 1973) = 6.

	self
		assert: (self dateClass leapYear: 1973) = 0;
		assert: (self dateClass leapYear: 1972) = 1;
		assert: (self dateClass daysInYear: 1973) = 365;
		assert: (self dateClass daysInYear: 1972) = 366;
		assert: (self dateClass daysInMonth: #February forYear: 1973) = 28;
		assert: (self dateClass daysInMonth: #February forYear: 1972) = 29.

]

{ #category : #testing }
DateTest >> testIndexOfMonth [
	self assert: (Date indexOfMonth: 'January')  = 1.	
	self assert: (Date indexOfMonth: 'December')  = 12.	
]

{ #category : #Tests }
DateTest >> testInitialization [

	self should: [ self dateClass initialize. true ].

]

{ #category : #Tests }
DateTest >> testInquiries [

	self	
		assert: date dayOfMonth = 2;
		assert: date dayOfYear = 153;
		assert: date daysInMonth = 30;
		assert: date daysInYear = 365;
		assert: date daysLeftInYear = (365 - 153);
		assert: date firstDayOfMonth = 152.

]

{ #category : #testing }
DateTest >> testJulianDayNumber [
	self assert: aDate = (Date julianDayNumber: ((4713+2004)*365 +1323) ).  
]

{ #category : #testing }
DateTest >> testLeap [
	self assert: aDate leap = 1.	


]

{ #category : #testing }
DateTest >> testLeapNot [
	self assert: (aDate addDays: 365) leap = 0

]

{ #category : #testing }
DateTest >> testLessThan [
	self assert: aDate < (Date readFrom: (ReadStream on: '01-24-2004')).
]

{ #category : #testing }
DateTest >> testMakeUTC [
	"Equal dates should compare equal regardless of which TimeZone they are created in."

	| priorTz priorPreference march31stLocal march31stOcean | 
	priorTz := DateAndTime localTimeZone.
	priorPreference := DateAndTime automaticTimezone.

	[DateAndTime 
		localTimeZone: (TimeZone
		offset: 9 hours
		name: 'Early Test Countries'
		abbreviation: 'Test Ocean Early'). 
 
	march31stLocal := Date year: 2016 month: 3 day: 31.
	march31stLocal start: (march31stLocal start offset: DateAndTime localTimeZone offset).
 
	DateAndTime
		localTimeZone: (TimeZone
		offset: -9 hours
		name: 'Late Test Countries'
		abbreviation: 'Test Ocean Late').
 
	march31stOcean := Date year: 2016 month: 3 day: 31.
	march31stOcean start: (march31stOcean start offset: DateAndTime localTimeZone offset).] 
		ensure: [DateAndTime localTimeZone: priorTz.
				DateAndTime automaticTimezone: priorPreference].
 
	self 
		deny: march31stLocal = march31stOcean;
		assert: march31stOcean > march31stLocal.

 	self 
		assert: march31stLocal makeUTC = march31stOcean makeUTC;
		deny: march31stOcean makeUTC > march31stLocal makeUTC;
		deny: march31stOcean makeUTC < march31stLocal makeUTC.
]

{ #category : #testing }
DateTest >> testMmddyyyy [
	self assert: aDate mmddyyyy =  '1/23/2004'
]

{ #category : #testing }
DateTest >> testNameOfMonth [
	self assert: (Date nameOfMonth: 5) = 'May'.	
	self assert: (Date nameOfMonth: 8) = 'August' 
]

{ #category : #Tests }
DateTest >> testNew [
	| epoch |
	epoch := self dateClass newDay: 1 year: 1901.
	self assert: (self dateClass new = epoch).
]

{ #category : #testing }
DateTest >> testNewDayMonthYear [
	self assert: aDate = (Date newDay: 23 month: 1 year: 2004)	

]

{ #category : #testing }
DateTest >> testNewDayYear [
	self assert: aDate = (Date newDay: 23 year: 2004)	

]

{ #category : #testing }
DateTest >> testPreviousFriday [
	self assert: (aDate previous: 'Friday') yyyymmdd = '2004-01-16'


]

{ #category : #Tests }
DateTest >> testPreviousNext [
	| n p pt ps |
	n := date next.
	p := date previous.

	self
		assert: n year = 1973;
		assert: n dayOfYear = 154;
		assert: p year = 1973;
		assert: p dayOfYear = 152.

	pt := date previous: #Thursday.		"31 May 1973"
	self	
		assert: pt year = 1973;
		assert: pt dayOfYear = 151.

	ps := date previous: #Saturday.		" 26 May 1973"
	self	
		assert: ps year = 1973;
		assert: ps dayOfYear = (153-7).

]

{ #category : #testing }
DateTest >> testPreviousThursday [
	self assert: (aDate previous: 'Thursday') yyyymmdd = '2004-01-22'


]

{ #category : #testing }
DateTest >> testPrintFormat [
	self assert: (aDate printFormat: #(1 2 3 $? 2 2)) =  '23?Jan?04'
]

{ #category : #testing }
DateTest >> testPrintOn [
	| ref ws |
	ref := '23 January 2004'.
	ws := '' writeStream.
	aDate printOn: ws.
	self assert: ws contents = ref
]

{ #category : #testing }
DateTest >> testPrintOnFormat [
	| ref ws |
	ref :='04*Jan*23'.
	ws := '' writeStream.
	aDate printOn: ws format: #(3 2 1 $* 2 2).
	self assert: ws contents = ref
]

{ #category : #Tests }
DateTest >> testPrinting [

	self	
		assert: date mmddyyyy = '6/2/1973';
		assert: date yyyymmdd = '1973-06-02';
		assert: (date printFormat: #(3 1 2 $! 2 1 1)) = '1973!2!Jun'.

]

{ #category : #Tests }
DateTest >> testReadFrom [
	| s1 s2 s3 s4 s5 | 
	s1 := '2 June 1973'.
	s2 := '2-JUN-73'.
	s3 := 'June 2, 1973'.
	s4 := '6/2/73'.
	s5 := '2JUN73'.

	self	
		assert: date = (self dateClass readFrom: s1 readStream);
		assert: date = (self dateClass readFrom: s2 readStream);
		assert: date = (self dateClass readFrom: s3 readStream);
		assert: date = (self dateClass readFrom: s4 readStream);
		assert: date = (self dateClass readFrom: s5 readStream).
]

{ #category : #testing }
DateTest >> testStarting [
	self assert: aDate = (Date starting: ((DateAndTime fromString: '2004-01-23T12:12') offset: Date defaultOffset))
]

{ #category : #testing }
DateTest >> testStoreOn [
	| ref ws |
	ref := '''23 January 2004'' asDate'.
	ws := '' writeStream.
	aDate storeOn: ws.
	self assert: ws contents = ref
]

{ #category : #Tests }
DateTest >> testStoring [

	self	
		assert: date storeString = '''2 June 1973'' asDate';
		assert: date = ('2 June 1973' asDate).

]

{ #category : #testing }
DateTest >> testSubtractDate [
	self assert: (aDate subtractDate:(aDate addDays: 30)) = -30.	
	self assert: (aDate subtractDate:(aDate subtractDays: 00)) = 0.	
	self assert: (aDate subtractDate:(aDate subtractDays: 30)) = 30.


]

{ #category : #testing }
DateTest >> testSubtractDays [
	self assert: (aDate subtractDays: 00) yyyymmdd =  '2004-01-23'.	
	self assert: (aDate subtractDays: 30) yyyymmdd =  '2003-12-24'.
	self assert: (aDate subtractDays: 60) yyyymmdd =  '2003-11-24'

]

{ #category : #testing }
DateTest >> testTomorrow [
	"Not a great test: could falsely fail if midnight come in between the two executions and doesnt catch many errors"
	self assert: Date tomorrow  > Date today 

]

{ #category : #testing }
DateTest >> testWeekday [
	self assert: aDate weekday = 'Friday'.	
	self assert: aDate weekdayIndex = 6. 
	self assert: (Date dayOfWeek: aDate weekday ) =6.
	self assert: (Date nameOfDay: 6 ) = 'Friday'	
]

{ #category : #testing }
DateTest >> testYesterday [
	"Not a great test:  doesnt catch many errors"
	self assert: Date yesterday  < Date today 

]

{ #category : #testing }
DateTest >> testYyyymmdd [
	self assert: aDate yyyymmdd =  '2004-01-23'
]
