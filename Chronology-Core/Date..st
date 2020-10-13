"
Instances of Date are Timespans with duration of 1 day.  As with all Chronology Timespan sub-instances, Dates can be instantiated as position values which compare equally to any other instance of the same Date, irregardless of the timezone in which either is created.

However, like the other Timespan subInstances, there are rare cases where it may be desirable to use instances of Date to represent a particular 1-day span of time at a particular locality on the globe.  All Timespans, including Dates, may specify a particular timezone offset for this purpose.
"
Class {
	#name : #Date,
	#superclass : #Timespan,
	#pools : [
		'ChronologyConstants'
	],
	#category : #'Chronology-Core'
}

{ #category : #'smalltalk-80' }
Date class >> dateAndTimeNow [
	"Answer an Array whose with Date today and Time now."

	^ Time dateAndTimeNow

]

{ #category : #'smalltalk-80' }
Date class >> dayOfWeek: dayName [ 

	^ Week indexOfDay: dayName
]

{ #category : #'smalltalk-80' }
Date class >> daysInMonth: monthName forYear: yearInteger [ 

	^ Month daysInMonth: monthName forYear: yearInteger.

]

{ #category : #'smalltalk-80' }
Date class >> daysInYear: yearInteger [ 

	^ Year daysInYear: yearInteger.
]

{ #category : #'general inquiries' }
Date class >> easterDateFor: year [

 "  compute the easter date.
    source: Physikalisch-Technische Bundesanstalt Braunschweig.
    Lichtenberg, H.: Zur Interpretation der Gaussschen Osterformel
                     und ihrer Ausnahmeregeln,
                     Historia Mathematica 24 (1997), pp. 441-444
  
    http://www.ptb.de/de/org/4/44/441/oste.htm
  "

  | k m s a d r og sz oe day |

  k := year // 100.
  m := 15 + (3*k + 3//4) - (8*k + 13//25).
   s := 2 - (3*k + 3// 4).
  a := year \\ 19.
  d := 19*a + m \\ 30.
  r := d//29 + ((d//28) - (d//29)* (a// 11)).

  og := 21 + d - r.
  sz := 7 - (year//4 + year + s\\7).
  oe := 7 - (og - sz\\7).
  day := og + oe.
  ^day <= 31
    ifTrue: [Date newDay: day month: 3 year: year ]
    ifFalse: [Date newDay: day - 31 month: 4 year: year].
]

{ #category : #'smalltalk-80' }
Date class >> firstWeekdayOfMonth: month year: year [
	"Answer the weekday index of the first day in <month> in the <year>."

	^ (self newDay: 1 month: month year: year) weekdayIndex

]

{ #category : #'smalltalk-80' }
Date class >> fromDays: dayCount [ 
	"Days since 1 January 1901"

	^ self julianDayNumber: dayCount + SqueakEpoch
]

{ #category : #'smalltalk-80' }
Date class >> fromSeconds: seconds [
	"Answer an instance of me which is 'seconds' seconds after January 1, 1901."

	^ self fromDays: ((Duration seconds: seconds) days)

]

{ #category : #'squeak protocol' }
Date class >> fromString: aString [
	"Answer an instance of created from a string with format mm.dd.yyyy."

	^ self readFrom: aString readStream.
]

{ #category : #'smalltalk-80' }
Date class >> indexOfMonth: aMonthName [ 

	^ Month indexOfMonth: aMonthName.

]

{ #category : #'squeak protocol' }
Date class >> julianDayNumber: aJulianDayNumber [ 
	^ self starting:
		(DateAndTime
			julianDayNumber: aJulianDayNumber
			offset: self defaultOffset)
]

{ #category : #'smalltalk-80' }
Date class >> leapYear: yearInteger [ 

	^ Year leapYear: yearInteger
]

{ #category : #'smalltalk-80' }
Date class >> nameOfDay: dayIndex [ 

	^ Week nameOfDay: dayIndex 
]

{ #category : #'smalltalk-80' }
Date class >> nameOfMonth: anIndex [ 

	^ Month nameOfMonth: anIndex.

]

{ #category : #'smalltalk-80' }
Date class >> newDay: day month: month year: year [ 

	^ self year: year month: month day: day

]

{ #category : #'smalltalk-80' }
Date class >> newDay: dayCount year: yearInteger [

	^ self year: yearInteger day: dayCount
]

{ #category : #'general inquiries' }
Date class >> orthodoxEasterDateFor: year [

 "  compute the easter date according to the rules of the orthodox calendar.
    source: 
    http://www.smart.net/~mmontes/ortheast.html 
  "
     | r1 r2 r3 r4 ra rb r5 rc date |

    r1 := year \\ 19.
    r2 := year \\ 4.
    r3 := year \\ 7.
    ra := 19*r1 + 16.
    r4 := ra \\ 30.
    rb := r2 + r2 + (4*r3) + (6*r4).
    r5 := rb \\ 7.
    rc := r4 + r5.
    date := Date newDay: 3 month: 4 year: year.
    ^date addDays: rc.
]

{ #category : #'squeak protocol' }
Date class >> readFrom: aStream [ 
	"Read a Date from the stream in any of the forms:  
		<day> <month> <year>		(15 April 1982; 15-APR-82; 15.4.82; 15APR82)  
		<month> <day> <year>		(April 15, 1982; 4/15/82)
		<year>-<month>-<day>			(1982-04-15) (ISO8601)"
	| ymd |
	ymd := self readYearMonthDayFrom: aStream.
	^ self
		year: ymd first
		month: ymd second
		day: ymd third

]

{ #category : #'squeak protocol' }
Date class >> readFrom: inputStream pattern: pattern [
	"Read a Date from the stream based on the pattern which can include the tokens:
	
		y = A year with 1-n digits
		yy = A year with 2 digits
		yyyy = A year with 4 digits
		m = A month with 1-n digits
		mm = A month with 2 digits
		d = A day with 1-n digits
		dd = A day with 2 digits
		
	...and any other Strings inbetween. Representing $y, $m and $d is done using
	\y, \m and \d and slash itself with \\. Simple example patterns:

		'yyyy-mm-dd'
		'yyyymmdd'
		'yy.mm.dd'
		'y-m-d'

	A year given using only two decimals is considered to be >2000."

	| day month year patternStream char |
	patternStream := pattern readStream.
	[patternStream atEnd] whileFalse: [
		inputStream atEnd ifTrue: [^nil].
		char := patternStream next.
		char = $\
			ifTrue: [inputStream next = patternStream next ifFalse: [^nil]]
			ifFalse: [
				char = $y
					ifTrue: [
						(patternStream nextMatchAll: 'yyy')
							ifTrue: [year := (inputStream next: 4) asInteger]
							ifFalse: [
								(patternStream peekFor: $y)
									ifTrue: [
										year := (inputStream next: 2) asInteger]
									ifFalse: [
										year := Integer readFrom: inputStream]]]
					ifFalse: [
						char = $m
							ifTrue: [
								(patternStream peekFor: $m)
									ifTrue: [
										month := (inputStream next: 2) asInteger]
									ifFalse: [
										month := Integer readFrom: inputStream]]
							ifFalse: [
								char = $d
									ifTrue: [
										(patternStream peekFor: $d)
											ifTrue: [
												day := (inputStream next: 2) asInteger]
											ifFalse: [
												day := Integer readFrom: inputStream]]
									ifFalse: [
										inputStream next = char ifFalse: [^nil]]]]]].
	(year isNil | month isNil | day isNil) ifTrue: [^nil].
	^self year: year month: month day: day
]

{ #category : #'squeak protocol' }
Date class >> readYearMonthDayFrom: aStream [ 
	"Read Date information from the stream in any of the forms:  
		<day> <month> <year>		(15 April 1982; 15-APR-82; 15.4.82; 15APR82)  
		<month> <day> <year>		(April 15, 1982; 4/15/82)
		<year>-<month>-<day>			(1982-04-15) (ISO8601)"
	| day month year parsedNumber prefix monthIndex |
	aStream peek = $-
		ifTrue: [prefix := -1]
		ifFalse: [prefix := 1].
	[aStream peek isAlphaNumeric]
		whileFalse: [aStream skip: 1].
	aStream peek isDigit
		ifTrue: [
			parsedNumber := (Integer readFrom: aStream) * prefix.
			(parsedNumber < 0 or: [parsedNumber > 31])
				ifTrue: [year := parsedNumber]].
	[aStream peek isAlphaNumeric]
		whileFalse: [aStream skip: 1].
	aStream peek isLetter
		ifTrue: ["MM-DD-YY or DD-MM-YY or YY-MM-DD"
			month := WriteStream on: (String new: 10).
			[aStream peek isLetter]
				whileTrue: [month nextPut: aStream next].
			month := month contents.
			[aStream peek isAlphaNumeric]
				whileFalse: [aStream skip: 1].
			parsedNumber isNil
				ifTrue: ["MM DD YY"
					day := Integer readFrom: aStream]
				ifFalse: [
					year isNil
						ifTrue: ["DD MM YY"
							day := parsedNumber]]]
		ifFalse: ["MM-DD-YY or DD-MM-YY or YY-MM-DD"
			year isNil 
				ifTrue: ["MM-DD-YY or DD-MM-YY"
					parsedNumber > 12
						ifTrue: ["DD-MM-YY"
							day := parsedNumber.
							monthIndex := Integer readFrom: aStream.
							"month := Month nameOfMonth: (Integer readFrom: aStream)"]
						ifFalse: ["MM-DD-YY"
							monthIndex := parsedNumber.
							"month := Month nameOfMonth: parsedNumber."
							day := Integer readFrom: aStream]]
				ifFalse: ["YY-MM-DD"
					monthIndex := Integer readFrom: aStream.
					"month := Month nameOfMonth: (Integer readFrom: aStream)"]].
	[aStream peek isAlphaNumeric]
		whileFalse: [aStream skip: 1].
	year isNil
		ifTrue: [year := Integer readFrom: aStream]
		ifFalse: [day := Integer readFrom: aStream].
	(year < 100 and: [year >= 0]) 
		ifTrue: [
			year < 69 
				ifTrue: [	year := 2000 + year]
				ifFalse: [year := 1900 + year]].

	monthIndex ifNil: [monthIndex := Month indexOfMonth: month].
	^ { year . monthIndex . day }

]

{ #category : #'squeak protocol' }
Date class >> starting: aDateAndTime [ 
	^ self
		starting: aDateAndTime midnight
		duration: Duration oneDay
]

{ #category : #'smalltalk-80' }
Date class >> today [

	^ self current

]

{ #category : #'squeak protocol' }
Date class >> tomorrow [

	^ self today next
]

{ #category : #'squeak protocol' }
Date class >> year: year day: dayOfYear [ 
	^ self starting:
		(DateAndTime
			year: year
			day: dayOfYear
			hour: 0
			minute: 0
			second: 0
			offset: self defaultOffset)
]

{ #category : #'squeak protocol' }
Date class >> year: year month: month day: day [ 
	^ self starting:
		(DateAndTime
			year: year
			month: month
			day: day
			hour: 0
			minute: 0
			second: 0
			offset: self defaultOffset)
]

{ #category : #'squeak protocol' }
Date class >> yesterday [

	^ self today previous
]

{ #category : #'squeak protocol' }
Date >> @ aTime [ 
	^ DateAndTime
		date: self
		time: aTime
]

{ #category : #'smalltalk-80' }
Date >> addDays: dayCount [ 

	^ (self asDateAndTime + (dayCount days)) asDate
]

{ #category : #utils }
Date >> addMonths: monthCount [ 
	|year month maxDaysInMonth day |
	year := self year + (monthCount + self monthIndex - 1 // 12).
	month := self monthIndex + monthCount - 1 \\ 12 + 1.
	maxDaysInMonth := Month daysInMonth: month forYear: year.
	day := self dayOfMonth > maxDaysInMonth
				ifTrue: [maxDaysInMonth]
				ifFalse: [self dayOfMonth].
	^ Date
		newDay: day
		month: month
		year: year
]

{ #category : #'squeak protocol' }
Date >> asDate [

	^ self

]

{ #category : #'smalltalk-80' }
Date >> asSeconds [
	"Answer the seconds since the Squeak epoch: 1 January 1901"

	^ start asSeconds

]

{ #category : #'squeak protocol' }
Date >> dayMonthYearDo: aBlock [ 
	"Supply integers for day, month and year to aBlock and return the result"

	^ start dayMonthYearDo: aBlock
]

{ #category : #'smalltalk-80' }
Date >> leap [
	"Answer whether the receiver's year is a leap year."

	^ start isLeapYear ifTrue: [1] ifFalse: [0].
]

{ #category : #printing }
Date >> mmddyyyy [
	"Answer the receiver rendered in standard U.S.A format mm/dd/yyyy.
	Note that the name here is slightly misleading -- the month and day numbers don't show leading zeros, 
	so that for example February 1 1996 is 2/1/96"


	^ self printFormat: #(2 1 3 $/ 1 1)

]

{ #category : #'squeak protocol' }
Date >> month [
	^ self asMonth
]

{ #category : #'squeak protocol' }
Date >> monthIndex [
	^ super month
]

{ #category : #utils }
Date >> onNextMonth [

	^ self addMonths: 1

]

{ #category : #utils }
Date >> onPreviousMonth [

	^ self addMonths: -1

]

{ #category : #'smalltalk-80' }
Date >> previous: dayName [ 
	"Answer the previous date whose weekday name is dayName."

	| days |
	days := 7 + self weekdayIndex - (self class dayOfWeek: dayName) \\ 7.
	days = 0 ifTrue: [ days := 7 ].
	^ self subtractDays: days
]

{ #category : #printing }
Date >> printFormat: formatArray [ 
	"Answer a String describing the receiver using the argument formatArray."

	^String new: 17 streamContents: [ :stream |
		self printOn: stream format: formatArray ]
]

{ #category : #printing }
Date >> printOn: aStream [

	self printOn: aStream format: #(1 2 3 $  3 1 )

]

{ #category : #printing }
Date >> printOn: aStream format: formatArray [ 
	"Print a description of the receiver on aStream using the format 
	denoted the argument, formatArray: 
	
		#(item item item sep monthfmt yearfmt twoDigits) 
	
		items: 1=day 2=month 3=year will appear in the order given, 
	
		separated by sep which is eaither an ascii code or character. 
	
		monthFmt: 1=09 2=Sep 3=September 
	
		yearFmt: 1=1996 2=96 
	
		digits: (missing or)1=9 2=09. 
	
	See the examples in printOn: and mmddyy"
	| gregorian twoDigits element monthFormat |
	gregorian := self dayMonthYearDo: [ :d :m :y | {d. m. y} ].
	twoDigits := formatArray size > 6 and: [(formatArray at: 7) > 1].
	1 to: 3 do: 
		[ :i | 
			element := formatArray at: i.
			element = 1
				ifTrue: [twoDigits
						ifTrue: [aStream
								nextPutAll: (gregorian first asString
										padded: #left
										to: 2
										with: $0)]
						ifFalse: [gregorian first printOn: aStream]].
			element = 2
				ifTrue: [monthFormat := formatArray at: 5.
					monthFormat = 1
						ifTrue: [twoDigits
								ifTrue: [aStream
										nextPutAll: (gregorian middle asString
												padded: #left
												to: 2
												with: $0)]
								ifFalse: [gregorian middle printOn: aStream]].
					monthFormat = 2
						ifTrue: [aStream
								nextPutAll: ((Month nameOfMonth: gregorian middle)
										copyFrom: 1
										to: 3)].
					monthFormat = 3
						ifTrue: [aStream
								nextPutAll: (Month nameOfMonth: gregorian middle)]].
			element = 3
				ifTrue: [(formatArray at: 6)
							= 1
						ifTrue: [gregorian last printOn: aStream]
						ifFalse: [aStream
								nextPutAll: ((gregorian last \\ 100) asString
										padded: #left
										to: 2
										with: $0)]].
			i < 3
				ifTrue: [(formatArray at: 4)
							~= 0
						ifTrue: [aStream nextPut: (formatArray at: 4) asCharacter]]]
]

{ #category : #printing }
Date >> storeOn: aStream [

	aStream print: self printString; nextPutAll: ' asDate'

]

{ #category : #'smalltalk-80' }
Date >> subtractDate: aDate [ 
	"Answer the number of days between self and aDate"

	^ (self start - aDate asDateAndTime) days
]

{ #category : #'smalltalk-80' }
Date >> subtractDays: dayCount [ 

	^ (self asDateAndTime - (dayCount days)) asDate
]

{ #category : #'smalltalk-80' }
Date >> weekday [
	"Answer the name of the day of the week on which the receiver falls."

	^ self dayOfWeekName
]

{ #category : #'smalltalk-80' }
Date >> weekdayIndex [
	"Sunday=1, ... , Saturday=7"

	^ self dayOfWeek
]

{ #category : #printing }
Date >> yyyymmdd [
	"Format the date in ISO 8601 standard like '2002-10-22'."

	^ self printFormat: #(3 2 1 $- 1 1 2)

]
