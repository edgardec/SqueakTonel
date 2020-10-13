"
This class provides the Simplified Chinese support (Used mainly in Mainland China).  Unfortunately, we haven't tested this yet, but as soon as we find somebody who understand the language, probably we can make it work in two days or so, as we have done for Czech support.
"
Class {
	#name : #SimplifiedChineseEnvironment,
	#superclass : #LanguageEnvironment,
	#category : #'Multilingual-Languages'
}

{ #category : #'subclass responsibilities' }
SimplifiedChineseEnvironment class >> clipboardInterpreterClass [
	| platformName osVersion |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk osVersion.
	platformName = 'Win32' ifTrue: [^WinGB2312ClipboardInterpreter].
	platformName = 'Mac OS' 
		ifTrue: 
			[('10*' match: osVersion) 
				ifTrue: [^NoConversionClipboardInterpreter]
				ifFalse: [^WinGB2312ClipboardInterpreter]].
	platformName = 'unix' 
		ifTrue: 
			[(ShiftJISTextConverter encodingNames includes: X11Encoding getEncoding) 
				ifTrue: [^MacShiftJISClipboardInterpreter]
				ifFalse: [^NoConversionClipboardInterpreter]].
	^NoConversionClipboardInterpreter
]

{ #category : #'public query' }
SimplifiedChineseEnvironment class >> defaultEncodingName [
	| platformName osVersion |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk osVersion.
	(#('Win32' 'Mac OS' 'ZaurusOS') includes: platformName) 
		ifTrue: [^'gb2312'].
	(#('unix') includes: platformName) ifTrue: [^'euc-cn'].
	^'mac-roman'
]

{ #category : #'subclass responsibilities' }
SimplifiedChineseEnvironment class >> inputInterpreterClass [
	| platformName osVersion encoding |
	platformName := Smalltalk platformName.
	osVersion := Smalltalk osVersion.
	platformName = 'Win32' ifTrue: [^WinGB2312InputInterpreter].
	platformName = 'Mac OS' 
		ifTrue: 
			[('10*' match: osVersion) 
				ifTrue: [^MacUnicodeInputInterpreter]
				ifFalse: [^WinGB2312InputInterpreter]].
	platformName = 'unix' 
		ifTrue: 
			[encoding := X11Encoding encoding.
			(EUCJPTextConverter encodingNames includes: encoding) 
				ifTrue: [^MacRomanInputInterpreter].
			(UTF8TextConverter encodingNames includes: encoding) 
				ifTrue: [^MacRomanInputInterpreter].
			(ShiftJISTextConverter encodingNames includes: encoding) 
				ifTrue: [^MacRomanInputInterpreter]].
	^MacRomanInputInterpreter
]

{ #category : #'subclass responsibilities' }
SimplifiedChineseEnvironment class >> supportedLanguages [
	"Return the languages that this class supports. 
	Any translations for those languages will use this class as their environment."
	
	^#('zh' )
]

{ #category : #'language methods' }
SimplifiedChineseEnvironment class >> traditionalCharsetClass [

	^ GB2312

]
