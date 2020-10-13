"
The beginnings of a telnet terminal, for telnetting to other hosts. 


NOTE - it should separate out the VT100 code to a separate class some time....

"
Class {
	#name : #TelnetMachine,
	#superclass : #Model,
	#instVars : [
		'hostname',
		'port',
		'socket',
		'outputBuffer',
		'processingCommand',
		'commandChar',
		'lastInputChar',
		'displayLines',
		'cursorX',
		'cursorY',
		'foregroundColor',
		'displayMode',
		'commandParams',
		'requestedRemoteEcho',
		'remoteEchoAgreed'
	],
	#classVars : [
		'CSSpecialChars',
		'DOChar',
		'DONTChar',
		'IAC',
		'OPTEcho',
		'WILLChar',
		'WONTChar'
	],
	#category : #'Etoys-Squeakland-Network-TelNet WordNet'
}

{ #category : #initialization }
TelnetMachine class >> initialize [
	"TelnetMachine initialize"
	WILLChar := 251 asCharacter.
	WONTChar := 252 asCharacter.
	DOChar := 253 asCharacter.
	DONTChar := 254 asCharacter.
	IAC := 255 asCharacter.

	OPTEcho := 1 asCharacter.


	"set of characters that need special processing"
	CSSpecialChars := CharacterSet 
		with: Character escape 
		with: Character cr
		with: Character lf
		with: Character tab.
	
]

{ #category : #'user interface' }
TelnetMachine class >> open [
	"TelnetMachine open"
	| machine win displayMorph inputMorph |
	Smalltalk isMorphic ifFalse: [ ^self notYetImplemented ].
	
	machine := self new.

	win := SystemWindow labelled: 'telnet'.
	win model: machine.

	displayMorph := PluggableTextMorph on: machine text: #displayBuffer accept: nil readSelection: #displayBufferSelection menu: #menu:shifted:.	
	displayMorph color: Color black.

	inputMorph := PluggableTextMorph on: machine text: nil accept: #sendLine:.
	inputMorph acceptOnCR: true.

	win addMorph: displayMorph frame: (0@0 extent: 1@0.9).
	win addMorph: inputMorph frame: (0@0.9 extent: 1@0.1).

	displayMorph color: Color black.

	win openInWorld.

]

{ #category : #'screen management' }
TelnetMachine >> addBoringStringInNormalMode: aString [
	"add a string with no special characters, and assuming we are already in #normal mode"
	|line inPos space amt |

aString do: [ :c | self displayChar: c ].
true ifTrue: [ ^self ].
	line := displayLines at: cursorY.
	inPos := 1.

	[ inPos <= aString size ] whileTrue: [
		"copy a line's worth"
		space := 80 - cursorX + 1.
		amt := space min: (aString size - inPos + 1).
		line replaceFrom: cursorX to: cursorX+amt-1 with: aString startingAt: inPos.
		line addAttribute: (TextColor color: foregroundColor) from: cursorX to: cursorX+amt-1.
		inPos := inPos + amt.

		"update cursor"
		cursorX := cursorX + amt.
		self possiblyWrapCursor.

	].

]

{ #category : #IO }
TelnetMachine >> connect [
	"connect to the name host"
	| addr |
	self isConnected ifTrue: [ self disconnect ].

	Socket initializeNetwork.

	addr := NetNameResolver addressForName: hostname.
	addr ifNil: [ self error: 'could not find address for ', hostname ].

	socket := Socket new.
	
	[socket connectTo: addr port: port]
		on: ConnectionTimedOut
		do: [:ex | self error: 'connection failed' ].

	
	requestedRemoteEcho := true.
	self do: OPTEcho.
]

{ #category : #IO }
TelnetMachine >> disconnect [
	self isConnected ifTrue: [
		Transcript show: 'disconnecting from ', hostname.
		socket disconnect ].
]

{ #category : #access }
TelnetMachine >> displayBuffer [
	"the 'screen' of the terminal"
	^Text streamContents: [ :s |
		displayLines do: [ :line |
			s nextPutAll: line.
			s cr. ] ]
]

{ #category : #access }
TelnetMachine >> displayBufferSelection [
	"where the selection should be in the display buffer.  It should be where the cursor is"
	| pos |
	pos := cursorY * 81 + cursorX - 82.
	^pos+1 to: pos
]

{ #category : #'screen management' }
TelnetMachine >> displayChar: c [
	| line |

	displayMode = #sawEscape ifTrue: [ 
		^self displayCharSawEscape: c ].

	displayMode = #gatheringParameters ifTrue: [
		^self displayCharGatheringParameters: c ].

	c = Character escape ifTrue: [
		displayMode := #sawEscape.
		^self ].

	c = Character cr ifTrue: [
		"go back to the beginning of the line"
		cursorX := 1.
		^self ].

	c = Character lf ifTrue: [
		"go to the next line"
		cursorY := cursorY + 1.
		cursorY > 25 ifTrue: [
			self scrollScreenBack: 1.
			cursorY := 25 ].
		^self ].

	c = Character tab ifTrue: [
		"move to the next tab stop"
		cursorX := cursorX + 8 // 8 * 8.
		self possiblyWrapCursor.
		^self ].

	"default: display the character"
	line := displayLines at: cursorY.
	line at: cursorX put: c.
	line addAttribute: (TextColor color: foregroundColor) from: cursorX to: cursorX.
		
	cursorX := cursorX + 1.
	self possiblyWrapCursor.
]

{ #category : #'screen management' }
TelnetMachine >> displayCharGatheringParameters: c [
	"display a character from the mode #gatheringParameters"

	| colorName |
	c isDigit  ifTrue: [
		"add a digit to the last parameter"
		commandParams at: commandParams size put:
			(commandParams last * 10 + c digitValue).
		^self ].

	c = $; ifTrue: [
		"end of a parameter; begin another one"
		commandParams add: 0.
		^self ].

	c = $m ifTrue: [
		"change display modes"
		displayMode := #normal.

		commandParams do: [ :p |
			p = 0 ifTrue: [
				"reset"
				foregroundColor := Color white ].
			(p >= 30 and: [ p <= 37 ]) ifTrue: [
				"change color"
				colorName := #(gray red green yellow blue blue cyan white) at: (p - 29).
				foregroundColor := Color perform: colorName. ] ].

		^self ].


	"unrecognized character"
	displayMode := #normal.
	^self displayChar: c
]

{ #category : #'screen management' }
TelnetMachine >> displayCharSawEscape: c [
	"display a character from the mode #sawEscape"

	c = $[ ifTrue: [
		commandParams := OrderedCollection with: 0.
		displayMode := #gatheringParameters.
		^self ].
	
	displayMode := #normal.
	^self displayChar: c
]

{ #category : #'screen management' }
TelnetMachine >> displayString: aString [
	"add aString to the display"
	|pos specialIdx |

	pos := 1. 	"pos steps through aString"

	[ pos <= aString size ] whileTrue: [
		displayMode = #normal ifTrue: [
			"try to display a whole hunk of text at once"
			specialIdx := aString indexOfAnyOf: CSSpecialChars startingAt: pos ifAbsent: [ aString size + 1 ].
			specialIdx > pos ifTrue: [
				self addBoringStringInNormalMode: (aString copyFrom: pos to: specialIdx-1).
				pos := specialIdx. ] ].

			pos <= aString size ifTrue: [
				"either a special has been seen, or we're in a special mode"
				self displayChar: (aString at: pos).
				pos := pos + 1. ].
	].


]

{ #category : #private }
TelnetMachine >> do: optionNo [
	"request that the remote side does optionNo"
	self sendChar: IAC.
	self sendChar: DOChar.
	self sendChar: optionNo asCharacter
]

{ #category : #private }
TelnetMachine >> dont: optionNo [
	"demand that the remote side doesn't do optionNo"
	self sendChar: IAC.
	self sendChar: DONTChar.
	self sendChar: optionNo asCharacter
]

{ #category : #private }
TelnetMachine >> initialize [
	outputBuffer := WriteStream on: String new.
	port := 23.
	processingCommand := false.
	displayLines := (1 to: 25) asOrderedCollection collect: [ :i |
		Text new: 80 withAll: Character space ].
	cursorX := 1.
	cursorY := 1.
	foregroundColor := Color white.
	displayMode := #normal.
	requestedRemoteEcho := false.
	remoteEchoAgreed := false.
	hostname := ''.
]

{ #category : #access }
TelnetMachine >> isConnected [
	"answer whether we are connected to a remote host"
	^socket ~~ nil and: [ socket isValid and: [ socket isConnected ] ]
]

{ #category : #menu }
TelnetMachine >> menu: aMenu shifted: shiftState [

	aMenu labels: 
'set host name
set port
connect
disconnect' lines: #() selections: #(setHostName setPort connect disconnect).
	^aMenu
]

{ #category : #menu }
TelnetMachine >> perform: aSelector orSendTo: anObject [
	^self perform: aSelector
]

{ #category : #access }
TelnetMachine >> port: anInteger [
	"set which port to connect to"
	port := anInteger
]

{ #category : #'screen management' }
TelnetMachine >> possiblyWrapCursor [
	"if the cursor has gone past the right margin, then wrap"

	cursorX > 80 ifTrue: [
		cursorX := 1.
		cursorY := cursorY + 1.
		cursorY > 25 ifTrue: [
			cursorY := 25.
			self scrollScreenBack: 1 ].
	].

]

{ #category : #private }
TelnetMachine >> processDo: optionChar [
	"we don't do anything"
	self wont: optionChar
]

{ #category : #private }
TelnetMachine >> processDont: char [
	"okay, fine by us, we won't do it..."
]

{ #category : #IO }
TelnetMachine >> processIO [
	"should be called periodically--this actually sends and recieves some bytes over the network"
	| amountSent |


	self isConnected ifFalse: [ ^ self ].

	outputBuffer := outputBuffer contents.	"convert to String for convenience in the loop.  still not as optimal as it could be...."
	[outputBuffer size > 0 and: [ socket sendDone ]] whileTrue: [ 
		"do some output"
		amountSent := socket sendSomeData: outputBuffer.
		outputBuffer := outputBuffer copyFrom: amountSent+1 to: outputBuffer size. ].
	outputBuffer := WriteStream on: outputBuffer.

	"do some input"
	self processInput: socket receiveAvailableData.
]

{ #category : #private }
TelnetMachine >> processInput: aString [
	"process input from the network"
	| newDisplayText |

	(processingCommand not and: [(aString indexOf: IAC) = 0]) ifTrue: [
		"no commands here--display the whole string"
		self displayString: aString.
		self changed: #displayBuffer.
		^self ].

	Transcript show: 'slow.'; cr.

	newDisplayText := WriteStream on: String new.

	aString do: [ :c |
		processingCommand ifTrue: [
			"an IAC has been seen"
			commandChar
				ifNil: [ 
					"c is the command character.  act immediately if c=IAC, otherwise save it and wait fro the next character"
					commandChar := c.  
					(commandChar = IAC) ifTrue: [ self displayChar: IAC. processingCommand := false ] ]
				ifNotNil: [
					commandChar == DOChar ifTrue: [ self processDo: c. ].
					commandChar == DONTChar ifTrue: [ self processDont: c ].
					commandChar == WILLChar ifTrue: [ self processWill: c ].
					commandChar == WONTChar ifTrue: [ self processWont: c ].
					processingCommand := false.  ] ]
		ifFalse: [
			"normal mode"
			c = IAC ifTrue: [ processingCommand := true.  commandChar := nil ] ifFalse: [
			  newDisplayText nextPut: c ] ] ].


	self displayString: newDisplayText contents.

	self changed: #displayBuffer

]

{ #category : #'sending data' }
TelnetMachine >> processTyping: aString [
	"process aString as if it were typed"
	outputBuffer nextPutAll: aString asString.
	remoteEchoAgreed ifFalse: [ self displayString: aString asString ].
	^true
]

{ #category : #private }
TelnetMachine >> processWill: optionChar [
	optionChar == OPTEcho ifTrue: [
		requestedRemoteEcho ifTrue: [
			remoteEchoAgreed := true ]
		ifFalse: [
			"they are offering remote echo, though we haven't asked.  Answer: oh yes."
			self do: OPTEcho.
			requestedRemoteEcho := true.
			remoteEchoAgreed := true. ].
	^self  ].
	

	"they've requested an unknown option.  reject it"
	self dont: optionChar.
]

{ #category : #private }
TelnetMachine >> processWont: optionChar [
	optionChar == OPTEcho ifTrue: [
		remoteEchoAgreed := false.
		requestedRemoteEcho := false.
	^self  ].
	

]

{ #category : #IO }
TelnetMachine >> release [
	self isConnected ifTrue:[ self disconnect ]
]

{ #category : #access }
TelnetMachine >> remoteHost: aString [
	"set which host to connect to"
	hostname := aString
]

{ #category : #'screen management' }
TelnetMachine >> scrollScreenBack: numLines [
	"scrolls the screen up by the number of lines.  The cursor isn't moved"
	numLines timesRepeat: [ displayLines removeFirst ].
	numLines timesRepeat: [
		displayLines addLast: (Text new: 80 withAll: Character space) ].
]

{ #category : #private }
TelnetMachine >> sendChar: char [
	"queue a character for sending over the network"
	outputBuffer nextPut: char
]

{ #category : #'sending data' }
TelnetMachine >> sendLine: aString [
	"send a line, along with a newline"
	self processTyping: aString, String crlf.
	^true
]

{ #category : #menu }
TelnetMachine >> setHostName [
	| newHostname |
	newHostname := FillInTheBlank request: 'host to connect to' initialAnswer: hostname.
	newHostname size > 0 ifTrue: [ hostname := newHostname ].
]

{ #category : #menu }
TelnetMachine >> setPort [
	| portString |
	portString := port printString.
	portString := FillInTheBlank request: 'port to connect on' initialAnswer: portString.
	portString := portString withBlanksTrimmed.
	portString isEmpty ifFalse: [ port := portString asNumber asInteger ].
]

{ #category : #IO }
TelnetMachine >> step [
	self processIO
]

{ #category : #IO }
TelnetMachine >> wantsSteps [
	^true
]

{ #category : #private }
TelnetMachine >> will: optionNo [
	"request that we do optionNo"
	self sendChar: IAC.
	self sendChar: WILLChar.
	self sendChar: optionNo asCharacter
]

{ #category : #private }
TelnetMachine >> wont: optionNo [
	"demand that we won't do optionNo"
	self sendChar: IAC.
	self sendChar: WONTChar.
	self sendChar: optionNo asCharacter
]
