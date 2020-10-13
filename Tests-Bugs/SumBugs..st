Class {
	#name : #SumBugs,
	#superclass : #TestCase,
	#category : #'Tests-Bugs'
}

{ #category : #tests }
SumBugs >> testSummingColors [
	"self run: #testSummingColors"
	| cases |
	cases := { 
		Color black.
		Color red.
		Color green.
		Color blue.
		Color cyan.
		Color magenta.
		Color yellow.
		Color white.
	}.

	cases do: [ :each |
		self assert: ((Array with: each) sum = each) 
	].

]

{ #category : #tests }
SumBugs >> testSummingToTen [
	"self run: #testSummingToTen"

	| cases |
	cases :={ 
		{ 1 . 2 . 3 . 4 }.
		{ 2.0 . 2.0 . 2.0 . 2.0 . 2.0  }.
		{ 2/5 . 5/2 . 5/2 . 3/5 . 4 } 
	} .

	cases do: [ :each |
		self assert: (each  sum = 10 )
	] .
]

{ #category : #tests }
SumBugs >> testSummingToWhite [
	"self run: #testSummingToWhite"

	| cases |
	cases := { 
		{ Color black . Color white }.
		{ Color red . Color green. Color blue }.
		{ Color gray . Color gray }.
		{ Color cyan. Color magenta. Color yellow }.
		{ Color cyan. Color magenta.  }.
		{  Color magenta. Color yellow }.
		{ Color cyan.  Color yellow }.
		{ Color cyan. Color red }.
		{ Color green .Color magenta.  }.
		{ Color blue. Color yellow }.
	} .

	cases do: [ :each |
		self assert: (each  sum = Color white) 
	] .




]

{ #category : #tests }
SumBugs >> testSummingWithBlack [
	"self run: #testSummingWithBlack"

	| cases |
	cases := { 
		Color black.
		Color red.
		Color green.
		Color blue.
		Color cyan.
		Color magenta.
		Color yellow.
		Color white.
	}.

	cases do: [ :each |
		self assert: ((Array with: each with: Color black) sum = each) 
	] .




]

{ #category : #tests }
SumBugs >> testSummingWithWhite [
	"self run: #testSummingWithWhite"

	| cases |
	cases := { 
		Color black.
		Color red.
		Color green.
		Color blue.
		Color cyan.
		Color magenta.
		Color yellow.
		Color white.
	} .

	cases do: [ :each |
		self assert: ((Array with: Color white with: each ) sum = Color white) 
	] .




]
