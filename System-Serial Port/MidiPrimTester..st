"
This class simply demonstrates and tests the MIDI primitives. MIDI applications should use Stephen Pope's MIDIPort class, which will replace this one.

The Macintosh, and perhaps some other platforms, can send and receive MIDI data over a serial port by using an external clock signal supplied by an external MIDI adapter to generate the correct MIDI baud rate. Typical clock speeds of such adapters are 1, 2, or 0.5 MHz. This clock speed can be specified when a MIDI port is opened. On other platforms, this clock speed parameter is ignored.

"
Class {
	#name : #MidiPrimTester,
	#superclass : #Object,
	#instVars : [
		'port'
	],
	#classVars : [
		'CanSetClock',
		'CanUseSemaphore',
		'ClockTicksPerSec',
		'EchoOn',
		'EventsAvailable',
		'FlushDriver',
		'HasBuffer',
		'HasDurs',
		'HasInputClock',
		'Installed',
		'UseControllerCache',
		'Version'
	],
	#category : #'System-Serial Port'
}

{ #category : #'class initialization' }
MidiPrimTester class >> initialize [
	"Initialize the MIDI parameter constants."
	"MidiPrimTester initialize"

	Installed := 1.
		"Read-only. Return 1 if a MIDI driver is installed, 0 if not.
		 On OMS-based MIDI drivers, this returns 1 only if the OMS
		 system is properly installed and configured."

	Version := 2.
		"Read-only. Return the integer version number of this MIDI driver.
		 The version numbering sequence is relative to a particular driver.
		 That is, version 3 of the Macintosh MIDI driver is not necessarily
		 related to version 3 of the Win95 MIDI driver."

	HasBuffer := 3.
		"Read-only. Return 1 if this MIDI driver has a time-stamped output
		 buffer, 0 otherwise. Such a buffer allows the client to schedule
		 MIDI output packets to be sent later. This can allow more precise
		 timing, since the driver uses timer interrupts to send the data
		 at the right time even if the processor is in the midst of a
		 long-running Squeak primitive or is running some other application
		 or system task."

	HasDurs := 4.
		"Read-only. Return 1 if this MIDI driver supports an extended
		 primitive for note-playing that includes the note duration and
		 schedules both the note-on and the note-off messages in the
		 driver. Otherwise, return 0."

	CanSetClock := 5.
		"Read-only. Return 1 if this MIDI driver's clock can be set
		 via an extended primitive, 0 if not."

	CanUseSemaphore := 6.
		"Read-only. Return 1 if this MIDI driver can signal a semaphore
		 when MIDI input arrives. Otherwise, return 0. If this driver
		 supports controller caching and it is enabled, then incoming
		 controller messages will not signal the semaphore."

	EchoOn := 7.
		"Read-write. If this flag is set to a non-zero value, and if
		 the driver supports echoing, then incoming MIDI events will
		 be echoed immediately. If this driver does not support echoing,
		 then queries of this parameter will always return 0 and
		 attempts to change its value will do nothing."

	UseControllerCache := 8.
		"Read-write. If this flag is set to a non-zero value, and if
		 the driver supports a controller cache, then the driver will
		 maintain a cache of the latest value seen for each MIDI controller,
		 and control update messages will be filtered out of the incoming
		 MIDI stream. An extended MIDI primitive allows the client to
		 poll the driver for the current value of each controller. If
		 this driver does not support a controller cache, then queries
		 of this parameter will always return 0 and attempts to change
		 its value will do nothing."

	EventsAvailable := 9.
		"Read-only. Return the number of MIDI packets in the input queue."

	FlushDriver := 10.
		"Write-only. Setting this parameter to any value forces the driver
		 to flush its I/0 buffer, discarding all unprocessed data. Reading
		 this parameter returns 0. Setting this parameter will do nothing
		 if the driver does not support buffer flushing."

	ClockTicksPerSec := 11.
		"Read-only. Return the MIDI clock rate in ticks per second."

	HasInputClock := 12.
		"Read-only. Return 1 if this MIDI driver timestamps incoming
		 MIDI data with the current value of the MIDI clock, 0 otherwise.
		 If the driver does not support such timestamping, then the
		 client must read input data frequently and provide its own
		 timestamping."

]

{ #category : #private }
MidiPrimTester >> bufferTimeStampFrom: aByteArray [
	"Return the timestamp from the given MIDI input buffer. Assume the given buffer is at least 4 bytes long."

	^ ((aByteArray at: 1) bitShift: 24) +
	  ((aByteArray at: 2) bitShift: 16) +
	  ((aByteArray at: 3) bitShift: 8) +
	   (aByteArray at: 4)

]

{ #category : #private }
MidiPrimTester >> canTurnOnParameter: whichParameter [
	"Return true if the given MIDI parameter can be turned on. Leave the parameter in its orginal state."

	| old canSet |
	old := self primMIDIParameterGet: whichParameter.
	self primMIDIParameterSet: whichParameter to: 1.
	canSet := (self primMIDIParameterGet: whichParameter) = 1.
	self primMIDIParameterSet: whichParameter to: old.
	^ canSet

]

{ #category : #tests }
MidiPrimTester >> getDriverParameters [
	"Return a string that describes this platform's MIDI parameters."
	"MidiPrimTester new getDriverParameters"

	| s parameterNames v |
	parameterNames := #(Installed Version HasBuffer HasDurs CanSetClock CanUseSemaphore EchoOn UseControllerCache EventsAvailable FlushDriver ClockTicksPerSec HasInputClock).

	s := WriteStream on: String new.
	s cr.
	1 to: parameterNames size do: [:i |
		v := self primMIDIParameterGet: i.
		s nextPutAll: (parameterNames at: i).
		s nextPutAll: ' = '.
		s print: v; cr].

	s nextPutAll: 'MIDI Echoing is '.
	(self canTurnOnParameter: EchoOn)
		ifTrue: [s nextPutAll: 'supported.'; cr]
		ifFalse: [s nextPutAll: 'not supported.'; cr].

	s nextPutAll: 'Controller Caching is '.
	(self canTurnOnParameter: UseControllerCache)
		ifTrue: [s nextPutAll: 'supported.'; cr]
		ifFalse: [s nextPutAll: 'not supported.'; cr].

	^ s contents

]

{ #category : #tests }
MidiPrimTester >> getInputForSeconds: seconds onPort: portNum [
	"Collect MIDI input from the given port for the given number of seconds, and answer a string describing the data read."
	"MidiPrimTester new getInputForSeconds: 5 onPort: 0"

	| s bufList midiStartTime |
	"collect the data"
	self openPort: portNum andDo: [ | endTime buf n |
		buf := ByteArray new: 1000.
		bufList := OrderedCollection new.
		midiStartTime := self primMIDIGetClock.
		endTime := Time millisecondClockValue + (seconds * 1000).
		[Time millisecondClockValue < endTime] whileTrue: [
			n := self primMIDIReadPort: portNum into: buf.
			n > 0 ifTrue: [bufList add: (buf copyFrom: 1 to: n)].
			(Delay forMilliseconds: 5) wait]].

	"format the data into a string"
	s := WriteStream on: String new.
	s cr.
	bufList do: [:b | | t |
		t := (self bufferTimeStampFrom: b) - midiStartTime.
		s print: t.
		s nextPutAll: ': '.
		5 to: b size do: [:i | s print: (b at: i); space].
		s cr].
	^ s contents

]

{ #category : #tests }
MidiPrimTester >> getPortList [
	"Return a string that describes this platform's MIDI ports."
	"MidiPrimTester new getPortList"

	| s portCount dir directionString |
	s := WriteStream on: String new.
	s cr; nextPutAll: 'MIDI Ports:'; cr.
	portCount := self primMIDIGetPortCount.
	0 to: portCount - 1 do: [:i |
		s tab.
		s print: i; nextPutAll: ': '. 
		s nextPutAll: (self primMIDIGetPortName: i).
		dir := self primMIDIGetPortDirectionality: i.
		directionString := dir printString.  "default"
		dir = 1 ifTrue: [directionString := '(in)'].
		dir = 2 ifTrue: [directionString := '(out)'].
		dir = 3 ifTrue: [directionString := '(in/out)'].
		s space; nextPutAll: directionString; cr].
	^ s contents

]

{ #category : #private }
MidiPrimTester >> openPort: portNum andDo: aBlock [
	"Open the given MIDI port, evaluate the block, and close the port again. Answer the value of the block."

	| result |
	self primMIDIClosePort: portNum.
	self primMIDIOpenPort: portNum readSemaIndex: 0 interfaceClockRate: 1000000.
	result := aBlock value.
	self primMIDIClosePort: portNum.
	^ result

]

{ #category : #tests }
MidiPrimTester >> playDrumRoll: mSecsBetweenNotes count: tapCount onPort: portNum [
	"MidiPrimTester new playDrumRoll: 75 count: 64 onPort: 0"
	"Play middle-C tapCount times with the given space between notes. This example works best with a short percussive voice, like a drum."
	"Details: This test can be used to investigate the real-time performance of your system. On a 110 MHz PowerPC Mac, this method can genererate very fast and smooth drum rolls up to about 100 beats/sec (10 mSecs between notes). However, many factors can prevent one from seeing this level of performance including a slow CPU, lack of a level-2 cache, networking or other background processes stealing chunks of processor time from Squeak, or a sluggish MIDI synthesizer."
	"Details: By default, this method does an incremental GC on every note. While not really needed for this example, it illustrates a useful technique for real-time processing in Squeak: do an incremental GC when you know you have a few milliseconds of idle time to avoid triggering one during a time-critical task. In this case, we're also using the GC time to provide a small delay between the note-on and note-off events. If the GC time is too short, as it could be on a fast machine, the note may not sound at all unless you add a few milliseconds of additional delay!"
	"Note: This example works best if the VM's millisecond clock has 1 millisecond resolution."

	| gcDuringNote noteOn noteOff endTime waitTime |
	gcDuringNote := true.
	"these events use running status, so the command byte is omitted"
	noteOn := #[ 60 100 ].
	noteOff := #[ 60 0 ].
	self primMIDIOpenPort: portNum readSemaIndex: 0 interfaceClockRate: 1000000.

	"send an initial event with command byte to initiate running status"
	self primMIDIWritePort: portNum from: #[144 60 0] at: 0.

	1 to: tapCount do: [:i |
		endTime := Time millisecondClockValue + mSecsBetweenNotes.
		self primMIDIWritePort: portNum from: noteOn at: 0.
		gcDuringNote
			ifTrue: [
				"do quick GC; takes a few milliseconds and provides the note-down time"
				"Note: if GC is too fast on your machine, you need to add a few mSecs delay!"
				Smalltalk garbageCollectMost]
			ifFalse: [(Delay forMilliseconds: 3) wait].

		self primMIDIWritePort: portNum from: noteOff at: 0.
		waitTime := endTime - Time millisecondClockValue.
		waitTime > 0 ifTrue: [(Delay forMilliseconds: waitTime) wait]].

	self primMIDIClosePort: portNum.

]

{ #category : #tests }
MidiPrimTester >> playNoteOnPort: portNum [
	"MidiPrimTester new playNoteOnPort: 0"

	| noteOn noteOff bytesWritten |
	noteOn := #[144 60 100].
	noteOff := #[144 60 0].
	self openPort: portNum andDo: [
		bytesWritten := self primMIDIWritePort: portNum from: noteOn at: 0.
		(Delay forMilliseconds: 500) wait.
		bytesWritten := bytesWritten + (self primMIDIWritePort: portNum from: noteOff at: 0)].

	bytesWritten = 6 ifFalse: [self error: 'not all bytes were sent'].

]

{ #category : #tests }
MidiPrimTester >> playScale: mSecsPerNote onPort: portNum [
	"MidiPrimTester new playScale: 130 onPort: 0"

	| noteOn noteOff |
	noteOn := #[144 0 100].
	noteOff := #[144 0 0].
	self openPort: portNum andDo: [
		#(60 62 64 65 67 69 71 72 74 72 71 69 67 65 64 62 60) do: [:midiKey | 
			noteOn at: 2 put: midiKey.
			noteOff at: 2 put: midiKey.
			self primMIDIWritePort: portNum from: noteOn at: 0.
			(Delay forMilliseconds: mSecsPerNote - 10) wait.
			self primMIDIWritePort: portNum from: noteOff at: 0.
			(Delay forMilliseconds: 10) wait]].

]

{ #category : #primitives }
MidiPrimTester >> primMIDIClosePort: portNum [

	<primitive: 'primitiveMIDIClosePort' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : #primitives }
MidiPrimTester >> primMIDIGetClock [

	<primitive: 'primitiveMIDIGetClock' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : #primitives }
MidiPrimTester >> primMIDIGetPortCount [

	<primitive: 'primitiveMIDIGetPortCount' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : #primitives }
MidiPrimTester >> primMIDIGetPortDirectionality: portNum [

	<primitive: 'primitiveMIDIGetPortDirectionality' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : #primitives }
MidiPrimTester >> primMIDIGetPortName: portNum [

	<primitive: 'primitiveMIDIGetPortName' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : #primitives }
MidiPrimTester >> primMIDIOpenPort: portNum readSemaIndex: readSemaIndex interfaceClockRate: interfaceClockRate [
	"Open the given MIDI port. If non-zero, readSemaIndex specifies the index in the external objects array of a semaphore to be signalled when incoming MIDI data is available. Not all platforms support signalling the read semaphore. InterfaceClockRate specifies the clock rate of the external MIDI interface adaptor on Macintosh computers; it is ignored on other platforms."

	<primitive: 'primitiveMIDIOpenPort' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : #primitives }
MidiPrimTester >> primMIDIParameterGet: whichParameter [

	<primitive: 'primitiveMIDIParameterGetOrSet' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : #primitives }
MidiPrimTester >> primMIDIParameterSet: whichParameter to: newValue [

	<primitive: 'primitiveMIDIParameterGetOrSet' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : #primitives }
MidiPrimTester >> primMIDIReadPort: portNum into: byteArray [

	<primitive: 'primitiveMIDIRead' module: 'MIDIPlugin'>
	self primitiveFailed.

]

{ #category : #primitives }
MidiPrimTester >> primMIDIWritePort: portNum from: byteArray at: midiClockValue [

	<primitive: 'primitiveMIDIWrite' module: 'MIDIPlugin'>
	self primitiveFailed.

]
