"
I am an SUnit Test of PopUpMenu and FillInTheBlank.  The original motivation for my creation was the regression of functionality associated with allowing the non-interactive testing of these menus.  

My fixtures are: None

NOTES ABOUT AUTOMATING USER INPUTS (See MethodContextTest also for a discussion of this functionality.)

When executing non-interactive programs you will inevitably run into programs  that require user input during their execution and these sort of problems shoot the whole non-interactiveness of your enclosing program. This is particularly true in doing Sunit tests.

PopUpMenu and FillInTheBlankMorph were modified to first signal a ProvideAnswerNotification and if someone handles that (e.g. the enclosing block) then the user interaction will be avoided and a answer provided by an array will be used instead. PopUpMenu and FillInTheBlankMorph take advantage of BlockClosure helper methods have been made available and tests of these helpers are provided in this class to demonstrate that it can intercept  requests for user interaction.  Of course,

 The basic syntax looks like:

	[self confirm: 'Install spyware?'] valueSupplyingAnswer: #('Install spyware?' false)

There a few variants on this theme making it easy to provide a literal list of answers for the block so that you can handle a bunch of questions in a block with appropriate answers.

Additionally, it is possible to suppress Object>>inform: modal dialog boxes as these get in the way of automating anything.  After applying this changeset you should be able to tryout the following code snippets to see the variants on this theme that are available.

Examples:

So you don't need any introduction here -- this one works like usual.
[self inform: 'hello'. #done] value.

Now let's suppress all inform: messages.
[self inform: 'hello'; inform: 'there'. #done] valueSuppressingAllMessages.

Here we can just suppress a single inform: message.
[self inform: 'hi'; inform: 'there'. #done] valueSuppressingMessages: #('there')

Here you see how you can suppress a list of messages.
[self inform: 'hi'; inform: 'there'; inform: 'bill'. #done] valueSuppressingMessages: #('hi' 'there')

Enough about inform:, let's look at confirm:. As you see this one works as expected.
[self confirm: 'You like Squeak?'] value

Let's supply answers to one of the questions -- check out the return value.
[{self confirm: 'You like Smalltalk?'. self confirm: 'You like Squeak?'}]
	valueSupplyingAnswer: #('You like Smalltalk?' true)

Here we supply answers using only substrings of the questions (for simplicity).
[{self confirm: 'You like Squeak?'. self confirm: 'You like MVC?'}]
	valueSupplyingAnswers: #( ('Squeak' true) ('MVC' false) )

This time let's answer all questions exactly the same way.
[{self confirm: 'You like Squeak?'. self confirm: 'You like Morphic?'}]
	valueSupplyingAnswer: true
	
And, of course, we can answer FillInTheBlank questions in the same manner.
[FillInTheBlank request: 'What day is it?']
	valueSupplyingAnswer: 'the first day of the rest of your life'
	
We can also return whatever the initialAnswer of the FillInTheBlank was by using the #default answer.
[FillInTheBlank request: 'What day is it?' initialAnswer: DateAndTime now dayOfWeekName]
	valueSupplyingAnswer: #default
	
Finally, you can also do regex matches on any of the question text (or inform text) (should you have VB-Regex enhancements in your image).
[FillInTheBlank request: 'What day is it?']
	valueSupplyingAnswers: { {'What day.*\?'. DateAndTime now dayOfWeekName} }
"
Class {
	#name : #ST80MenusTest,
	#superclass : #TestCase,
	#category : #'ST80-Menus-Tests'
}

{ #category : #tests }
ST80MenusTest >> testSupplyAnswerOfFillInTheBlank [

	self should: ['blue' = ([UIManager default request: 'Should not see this message or this test failed?'] 
		valueSupplyingAnswer: #('Should not see this message or this test failed?' 'blue'))]
]

{ #category : #tests }
ST80MenusTest >> testSupplySpecificAnswerToQuestion [

	self should: [false = ([self confirm: 'Should not see this message or this test failed?'] 
		valueSupplyingAnswer: #('Should not see this message or this test failed?' false))]
]

{ #category : #tests }
ST80MenusTest >> testSuppressInform [

	self should: [[nil inform: 'Should not see this message or this test failed!'] valueSuppressingAllMessages isNil]
]
