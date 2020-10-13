Class {
	#name : #SqueakToolsDebuggerHelp,
	#superclass : #SqueakToolsHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakToolsDebuggerHelp class >> bookName [
	^'Debugger'
]

{ #category : #pages }
SqueakToolsDebuggerHelp class >> openingTheDebugger [
	"This method was automatically generated. Edit it using:"
	"SqueakToolsDebuggerHelp edit: #openingTheDebugger"
	^HelpTopic 
		title: 'Open a Debugger.'
		contents: 'A debugger window is opened in response to an unhandled exception condition. Evaluating the expression ''self halt'' in a workspace or as an expression in a method will cause a debugger window to be opened. The debugger provides direct interactive access to the interrupted process.

The debugger permits its interrupted process to be inspected and modified. Source code and variables may be modified interactively, and the process can be stepped through its execution in various ways.'
]

{ #category : #accessing }
SqueakToolsDebuggerHelp class >> pages [
	^# (whatIsADebugger openingTheDebugger usingTheDebugger)
]

{ #category : #pages }
SqueakToolsDebuggerHelp class >> priority [

	^ 30
]

{ #category : #pages }
SqueakToolsDebuggerHelp class >> showForm: aSymbol [
	| form contents |
	form := ScriptingSystem formAtKey: aSymbol.
	contents :=  (String with: Character cr) asText, 
					(Text string: ' '
					attribute: (TextFontReference toFont: 
						(FormSetFont new
							fromFormArray: (Array with: form)
							asciiStart: Character space asInteger
							ascent: form height))),
						(String with: Character cr) asText.
	^contents
]

{ #category : #pages }
SqueakToolsDebuggerHelp class >> usingTheDebugger [
	"This method was automatically generated. Edit it using:"
	"SqueakToolsDebuggerHelp edit: #usingTheDebugger"
	^HelpTopic 
		title: 'Debugging Loops.'
		contents: 'There are a few ways to get out of a loop.  The best way is to just let the loop run.

To do that select the space on your code (while in the Debugger) you want to jump to, right click and select: ''run to here.''

' asText, 
(self showForm: #Debugger1),
'

That will take you to the place you clicked on in your code.

There is another trick, loops usually have an index. This is Smalltalk after all.  In the case above we just selected this code and selected ''Debug it''

1 to: 100 do: [:i | Transcript show: i asString].
Transcript show: ''done''

While in the outer content evaluating the loop, select i change the value to 100 hit accept and ''bobs your uncle'' the loop is done. 

Ok so a bit of a hack but this can be used it to skip over some processing, and since you are debugging and know what you are doing it should be fine.

' asText,
(self showForm: #Debugger2),
'
Proceed is just continue and stop debugging.

Restart will stop debugging at the selected method and restart that method from the beginning.

Into goes into the execution of the next method and shows you what it does.

Over executes the next message and moves over it to the next message.

Through steps you through a block of code, so if you are about to execute a block, this steps you through that block

Full Stack increases the number of levels you see in the upper panel.  That normally shows you a subset of the execution stack.  Full stack will show you the rest of the stack that called this method.

Where is useful if you click around a method during debugging. It will highlight the code at its execution point.  You can also just select the stack method again to do the same thing.

Tally is supposed to tally selected code, but may not be reliable within the debugger. If you want to tally something do it outside a debugger.' asText
]

{ #category : #pages }
SqueakToolsDebuggerHelp class >> whatIsADebugger [
	"This method was automatically generated. Edit it using:"
	"SqueakToolsDebuggerHelp edit: #whatIsADebugger"
	^HelpTopic 
		title: 'What is a Debugger.'
		contents: 'A debugger represents the machine state at the time of an interrupted process. It also represent a query path into the state of the process.

The debugger is typically viewed through a window that views the stack of suspended contexts, the code for, and execution point in, the currently selected message, and inspectors on both the receiver of the currently selected message, and the variables in the current context.'
]
