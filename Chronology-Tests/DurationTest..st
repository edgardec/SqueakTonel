Class {
	#name : #DurationTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'aDuration'
	],
	#category : #'Chronology-Tests'
}

{ #category : #coverage }
DurationTest >> classToBeTested [

	^ Duration



]

{ #category : #coverage }
DurationTest >> selectorsToBeIgnored [

	| private | 
	private := #( #printOn: ).

	^ super selectorsToBeIgnored, private

]

{ #category : #running }
DurationTest >> setUp [
	aDuration := Duration days: 1 hours: 2 minutes: 3 seconds: 4 nanoSeconds: 5 
]

{ #category : #tests }
DurationTest >> testAbs [
	self assert: aDuration abs = aDuration. 
	self assert: (Duration nanoSeconds: -5)  abs =  (Duration nanoSeconds: 5). 

]

{ #category : #tests }
DurationTest >> testAgo [
	self assert: ((10 minutes ago) isMemberOf: DateAndTime).
	self assert: ((10 weeks ago) < DateAndTime now).
	self assert: ((-50 seconds ago) > DateAndTime now).
	self assert: ((10 hours ago) < DateAndTime now).
	self assert: (0 seconds ago - DateAndTime now < 1 second).
]

{ #category : #tests }
DurationTest >> testAsDelay [
	self deny: aDuration asDelay =   aDuration.
	"want to come up with a more meaningful test"

]

{ #category : #tests }
DurationTest >> testAsDuration [
	self assert: aDuration asDuration =  aDuration
	

]

{ #category : #tests }
DurationTest >> testAsMicroSeconds [
	self assert: (Duration nanoSeconds: 1000) asMicroSeconds = 1.
	self assert: (Duration seconds: 1) asMicroSeconds = 1e6.
	self assert: aDuration asMicroSeconds = 93784000000.
	self assert: (Duration microSeconds: 3775000) asSeconds = 3.
	self assert: (Duration microSeconds: 3775000) nanoSeconds = 775000000
]

{ #category : #tests }
DurationTest >> testAsMilliSeconds [
	self assert: (Duration nanoSeconds: 1000000) asMilliSeconds = 1.
	self assert: (Duration seconds: 1) asMilliSeconds = 1000.
	self assert: (Duration nanoSeconds: 1000000) asMilliSeconds = 1.
	self assert: (Duration nanoSeconds: 1000000) asMilliSeconds = 1.
	self assert: aDuration asMilliSeconds = 93784000.
	self assert: (Duration milliSeconds: 3775) asSeconds = 3.
	self assert: (Duration milliSeconds: 3775) nanoSeconds = 775000000
]

{ #category : #tests }
DurationTest >> testAsNanoSeconds [
	self assert: (Duration nanoSeconds: 1)  asNanoSeconds = 1.
	self assert: (Duration seconds: 1)  asNanoSeconds = 1000000000.	
	self assert: aDuration   asNanoSeconds = 93784000000005.
]

{ #category : #tests }
DurationTest >> testAsSeconds [
	self assert: (Duration nanoSeconds: 1000000000)  asSeconds = 1.
	self assert: (Duration seconds: 1)  asSeconds = 1.	
	self assert: aDuration   asSeconds = 93784.
]

{ #category : #tests }
DurationTest >> testComparing [

	| d1 d2 d3 |
	d1 := Duration seconds: 10 nanoSeconds: 1.
	d2 := Duration seconds: 10 nanoSeconds: 1.
	d3 := Duration seconds: 10 nanoSeconds: 2.
	
	self
		assert: (d1 = d1);
		assert: (d1 = d2);
		deny: (d1 = d3);
		assert: (d1 < d3)

]

{ #category : #tests }
DurationTest >> testDays [
	self assert: aDuration   days = 1.
	self assert: (Duration   days: 1) days= 1.	
]

{ #category : #tests }
DurationTest >> testDivide [
	self assert: aDuration / aDuration = 1. 
	self assert: aDuration / 2 = (Duration days: 0 hours: 13 minutes: 1 seconds: 32 nanoSeconds: 2). 
	self assert: aDuration / (1/2) = (Duration days: 2 hours: 4 minutes: 6 seconds: 8 nanoSeconds: 10).

]

{ #category : #tests }
DurationTest >> testFromNow [

	self assert: ((10 seconds fromNow) > DateAndTime now).
	self assert: ((0 days fromNow - DateAndTime now) < 1 second).
	self assert: ((-1 weeks fromNow) < DateAndTime now).
	self assert: ((1000 milliSeconds fromNow) isMemberOf: DateAndTime).
	self assert: ((250 hours fromNow) > DateAndTime now).
	self assert: ((-50 minutes fromNow) < DateAndTime now).
]

{ #category : #tests }
DurationTest >> testFromString [
	self assert: aDuration = (Duration fromString: '1:02:03:04.000000005').

]

{ #category : #tests }
DurationTest >> testHash [
	self assert: aDuration hash =    	(Duration days: 1 hours: 2 minutes: 3 seconds: 4 nanoSeconds: 5) hash.
	self assert: aDuration hash =     93789
	"must be a more meaningful test?"
]

{ #category : #tests }
DurationTest >> testHours [
	self assert: aDuration   hours = 2.
	self assert: (Duration   hours: 2) hours = 2.	
]

{ #category : #tests }
DurationTest >> testIntegerDivision [
	self assert: aDuration // aDuration = 1. 
	self assert: aDuration // 2 =  (aDuration / 2). 
	"is there ever a case where this is not true, since precision is always to the nano second?"
]

{ #category : #tests }
DurationTest >> testLessThan [
	self assert: aDuration  < (aDuration + 1 day ).
	self deny: aDuration < aDuration.
	
]

{ #category : #tests }
DurationTest >> testMilliSeconds [

	#(
		"argument (milliseconds)	seconds	nanoseconds"
		(5							0			5000000)
		(1005						1			5000000)
		(-5							0			-5000000)
		(-1005						-1			-5000000)
		(1234567					1234		567000000)
		(-1234567					-1234		-567000000)		
	) do: [ :each |
		| duration |
		duration := Duration milliSeconds: each first.
		self assert: duration asSeconds = each second.
		self assert: duration nanoSeconds = each third ]
]

{ #category : #tests }
DurationTest >> testMinus [
	self assert: aDuration - aDuration = (Duration seconds: 0).
	self assert: aDuration - (Duration days: -1 hours: -2 minutes: -3 seconds: -4 nanoSeconds: -5) = 
						    (Duration days: 2  hours: 4  minutes: 6  seconds: 8  nanoSeconds: 10). 
	self assert: aDuration - (Duration days: 0  hours: 1  minutes: 2  seconds: 3  nanoSeconds: 4) = 
						    (Duration days: 1  hours: 1  minutes: 1  seconds: 1  nanoSeconds: 1). 
	self assert: aDuration - (Duration days: 0  hours: 3   minutes: 0  seconds: 5  nanoSeconds: 0) = 
						    (Duration days: 0  hours: 23  minutes: 2  seconds: 59  nanoSeconds: 5). 
]

{ #category : #tests }
DurationTest >> testMinutes [
	self assert: aDuration   minutes = 3.
	self assert: (Duration minutes: 3) minutes = 3.	
]

{ #category : #tests }
DurationTest >> testModulo [

	| d1 d2 d3 |
	d1 := 11.5 seconds.
	d2 := d1 \\ 3.
	self assert: d2 = (Duration nanoSeconds: 1).

	d3 := d1 \\ (3 seconds).
	self assert: d3 =  (Duration seconds: 2 nanoSeconds: 500000000).

	self assert: aDuration \\ aDuration = 
		(Duration days: 0 hours: 0 minutes: 0 seconds: 0 nanoSeconds: 0). 
	self assert: aDuration \\ 2 = 
		(Duration days: 0 hours: 0 minutes: 0 seconds: 0 nanoSeconds: 1).
	


]

{ #category : #tests }
DurationTest >> testMonthDurations [

	| jan feb dec |
	jan := Duration month: #January.
	feb := Duration month: #February.
	dec := Duration month: #December.
	
	self 
		assert: jan = (Year current months first duration);
		assert: feb = (Year current months second duration);
		assert: dec = (Year current months last duration)

		

]

{ #category : #tests }
DurationTest >> testMultiply [
	self assert: aDuration * 2 = (Duration days: 2 hours: 4 minutes: 6 seconds: 8 nanoSeconds: 10). 
]

{ #category : #tests }
DurationTest >> testNanoSeconds [
	self assert: aDuration nanoSeconds = 5.
	self assert: (Duration nanoSeconds: 5) nanoSeconds = 5.	
]

{ #category : #tests }
DurationTest >> testNegated [
	self assert: aDuration + aDuration negated = (Duration seconds: 0). 

]

{ #category : #tests }
DurationTest >> testNegative [
	self deny: aDuration negative.
	self assert: aDuration negated negative

]

{ #category : #tests }
DurationTest >> testNew [

	self assert: Duration new =  (Duration seconds: 0)
]

{ #category : #tests }
DurationTest >> testNormalizeNanoSeconds [
	"Subtraction of two DateAndTime values may result in a request to
	create a Duration with negative nanoseconds and positive seconds.
	The resulting Duration should be normalized, otherwise its printString
	will be invalid."

	| d t1 t2 |
	t1 := '2004-01-07T11:55:01+00:00' asDateAndTime. 
	t2 := '2004-01-07T11:55:00.9+00:00' asDateAndTime.
	d := t1 - t2. "100 millisecond difference"
	self assert: d nanoSeconds > 0.
	self assert: d seconds = 0.
	self assert: d nanoSeconds = 100000000.
	self assert: d asString = '0:00:00:00.100'.
	"Verify that other combinations produces reasonable printString values"
	self assert: (Duration seconds: 1 nanoSeconds: 100000000) printString = '0:00:00:01.100'.
	self assert: (Duration seconds: -1 nanoSeconds: -100000000) printString = '-0:00:00:01.100'.
	self assert: (Duration seconds: 1 nanoSeconds: -100000000) printString = '0:00:00:00.900'.
	self assert: (Duration seconds: -1 nanoSeconds: 100000000) printString = '-0:00:00:00.900'

]

{ #category : #tests }
DurationTest >> testNumberConvenienceMethods [

	self
		assert: 1 week = (Duration days: 7);
		assert: -1 week = (Duration days: -7);
		assert: 1 day = (Duration days: 1);
		assert: -1 day = (Duration days: -1);
		assert: 1 hours = (Duration hours: 1);
		assert: -1 hour = (Duration hours: -1);
		assert: 1 minute = (Duration seconds: 60);
		assert: -1 minute = (Duration seconds: -60);
		assert: 1 second = (Duration seconds: 1);
		assert: -1 second = (Duration seconds: -1);
		assert: 1 milliSecond = (Duration milliSeconds: 1);
		assert: -1 milliSecond = (Duration milliSeconds: -1);
		assert: 1 nanoSecond = (Duration nanoSeconds: 1);
		assert: -1 nanoSecond = (Duration nanoSeconds: -1)
		
]

{ #category : #tests }
DurationTest >> testPlus [
	self assert: (aDuration + 0 hours) = aDuration.
	self assert: (aDuration + aDuration) = (Duration days: 2 hours: 4 minutes: 6 seconds: 8 nanoSeconds: 10). 
]

{ #category : #tests }
DurationTest >> testPositive [
	self assert: (Duration nanoSeconds: 0) positive.
	self assert: aDuration positive.
	self deny: aDuration negated positive

]

{ #category : #tests }
DurationTest >> testPrintOn [
	| ref ws |
	ref := '1:02:03:04.000000005'.
	ws := '' writeStream.
	aDuration printOn: ws.
	self assert: ws contents = ref
]

{ #category : #tests }
DurationTest >> testQuotient [

	| d1 d2 q |
	d1 := 11.5 seconds.
	d2 := d1 // 3.
	self assert: d2 = (Duration seconds: 3 nanoSeconds: 833333333).

	q := d1 // (3 seconds).
	self assert: q = 3.


]

{ #category : #tests }
DurationTest >> testReadFrom [
	self assert: aDuration =  (Duration readFrom: (ReadStream on: '1:02:03:04.000000005'))

]

{ #category : #tests }
DurationTest >> testReadFromTrailingDigits [
	"http://bugs.squeak.org/view.php?id=6764"
	self should:  (Duration readFrom: '0:00:00:00.001 ' readStream) nanoSeconds = 1000000.
]

{ #category : #tests }
DurationTest >> testRoundTo [

	self assert: ((5 minutes + 37 seconds) roundTo: (2 minutes)) = (6 minutes).
	
	self assert:  (aDuration roundTo: (Duration days: 1)) =
	               (Duration days: 1 hours: 0 minutes: 0 seconds: 0 nanoSeconds: 0).
	self assert:  (aDuration roundTo: (Duration hours: 1)) =
	               (Duration days: 1 hours: 2 minutes: 0 seconds: 0 nanoSeconds: 0).	
	self assert:  (aDuration roundTo: (Duration minutes: 1)) =
	               (Duration days: 1 hours: 2 minutes: 3 seconds: 0 nanoSeconds: 0).
]

{ #category : #tests }
DurationTest >> testSeconds [
	self assert: aDuration seconds =   4.
	self assert: (Duration  nanoSeconds: 2) seconds = 0.
	self assert: (Duration nanoSeconds: 999999999) seconds = 0.
	self assert: (Duration nanoSeconds: 1000000001) seconds = 1.
	self assert: (Duration  seconds: 2) seconds = 2.	
	self assert: (Duration  days: 1 hours: 2 minutes: 3 seconds:4) seconds = 4.
	self deny: (Duration  days: 1 hours: 2 minutes: 3 seconds:4) seconds = (1*24*60*60+(2*60*60)+(3*60)+4).	
]

{ #category : #tests }
DurationTest >> testSecondsNanoSeconds [ 
	self assert: (Duration   seconds: 0 nanoSeconds: 5)  = (Duration  nanoSeconds: 5).	
	"not sure I should include in sunit since its Private "
	self assert: (aDuration seconds: 0 nanoSeconds: 1) = (Duration nanoSeconds: 1). 

]

{ #category : #tests }
DurationTest >> testStoreOn [
     self assert: (aDuration storeOn: (WriteStream on:'')) asString ='1:02:03:04.000000005'. 
     "storeOn: returns a duration (self) not a stream"
]

{ #category : #tests }
DurationTest >> testTicks [
	self assert: aDuration ticks =  #(1 7384 5)
]

{ #category : #tests }
DurationTest >> testTruncateTo [

	self assert: ((5 minutes + 37 seconds) truncateTo: (2 minutes)) = (4 minutes).
	self assert:  (aDuration truncateTo: (Duration days: 1)) =
	               (Duration days: 1 hours: 0 minutes: 0 seconds: 0 nanoSeconds: 0).
	self assert:  (aDuration truncateTo: (Duration hours: 1)) =
	               (Duration days: 1 hours: 2 minutes: 0 seconds: 0 nanoSeconds: 0).	
	self assert:  (aDuration truncateTo: (Duration minutes: 1)) =
	               (Duration days: 1 hours: 2 minutes: 3 seconds: 0 nanoSeconds: 0).
]

{ #category : #tests }
DurationTest >> testWait [
	
	| start |
	start := DateAndTime new.
	(Duration milliSeconds: 500) wait.
	self assert: DateAndTime now - start > (Duration milliSeconds: 500).	
]

{ #category : #tests }
DurationTest >> testWeeks [
	self assert: (Duration  weeks: 1) days= 7.	
]

{ #category : #tests }
DurationTest >> testZero [
	self assert: (Duration zero) = (Duration seconds: 0).	
]
