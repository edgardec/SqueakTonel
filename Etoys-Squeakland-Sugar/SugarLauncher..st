"
SugarLauncher handles communication with Sugar in the OLPC environment.

The DBus communication is used for, e.g., storing to the Journal (datastore), and networking (presence).

We also handle events from the window system.


"
Class {
	#name : #SugarLauncher,
	#superclass : #AbstractLauncher,
	#instVars : [
		'sharedActivity',
		'buddies',
		'buddiesLock',
		'tubes',
		'tubesLock'
	],
	#classVars : [
		'Current',
		'UISema'
	],
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #accessing }
SugarLauncher class >> current [
	^Current ifNil: [Current := self new]
]

{ #category : #utilities }
SugarLauncher class >> defaultDatastoreDirName [

	^ '[Journal]'

]

{ #category : #services }
SugarLauncher class >> fileReaderServicesForFile: fullName suffix: suffix [

	^({ 'pr'. 'st'. 'cs'. '*' } includes: suffix)
		ifTrue: [self services]
		ifFalse: [#()]
]

{ #category : #services }
SugarLauncher class >> initialize [
	Preferences
		addPreference: #sugarAutoSave
		category:  #morphic
		default: false
		balloonHelp: 'If enabled, quitting under Sugar will automatically save the current project.'.

]

{ #category : #testing }
SugarLauncher class >> isRunningInRainbow [
	^self current isRunningInRainbow
]

{ #category : #testing }
SugarLauncher class >> isRunningInSugar [
	^self current isRunningInSugar
]

{ #category : #services }
SugarLauncher class >> serviceWrapAsXOBundle [
	"Answer a service for wrapping a file as an .xo bundle"

	^ FileModifyingSimpleServiceEntry 
		provider: self 
		label: 'make XO bundle' translatedNoop
		selector: #wrapAsXOBundle:
		description: 'wrap as an OLPC XO bundle' translatedNoop
		buttonLabel: 'XO'
]

{ #category : #services }
SugarLauncher class >> services [
	^ {self serviceWrapAsXOBundle}
]

{ #category : #'class initialization' }
SugarLauncher class >> shutDown [
	Current ifNotNil: [Current shutDown. Current := nil]
]

{ #category : #accessing }
SugarLauncher class >> welcomeProjectName [
	"Deprecated"
	^Project home ifNotNil: [:p | p name]
]

{ #category : #services }
SugarLauncher class >> wrapAsXOBundle: aFileName [ 
	Utilities
		informUser: 'Making bundle' translated
		during: [Cursor wait showWhile:
			[self current bundle: aFileName]]
]

{ #category : #commands }
SugarLauncher >> active: aBoolean [
	"Etoys activity received or lost focus"

	Preferences setPreference: #soundsEnabled toValue: aBoolean.
	aBoolean
		ifTrue: [
			UISema ifNotNil: [:s | s signal].
		] 
		ifFalse: [
			SoundPlayer shutDown.
			SoundRecorder anyActive ifTrue: [SoundRecorder allSubInstancesDo: [:r | r stopRecording]].
			Smalltalk at: #VideoDevice ifPresent: [:vd | vd shutDown: true].

			UISema ifNil: [UISema := Semaphore new].
			UISema initSignals.
			WorldState addDeferredUIMessage: [UISema wait].
		].
]

{ #category : #accessing }
SugarLauncher >> activityId [
	^parameters at: 'ACTIVITY_ID'
]

{ #category : #bundling }
SugarLauncher >> bundle: aFileName [
	| localName nameAndVersion cleanName |
	localName := (FileDirectory localNameFor: aFileName) copyUpToLast: $..
	nameAndVersion := localName stemAndNumericSuffix.
	cleanName := nameAndVersion first select: [:c | c isAlphaNumeric].
	^self
		bundle: aFileName
		as: cleanName
		title: nameAndVersion first
		version: (nameAndVersion second max: 1)
		id: 'org.squeak.', cleanName
		icon: self bundleIcon

]

{ #category : #bundling }
SugarLauncher >> bundle: aFileName as: aBundleName title: aTitle version: aVersion id: aBundleID icon: anSVGIcon [
	"Create a ZIP file named aBundleName-aVersion.xo containing
		aBundleName.activity/
			aFileName
			bin/etoys-launch
			activity/activity.info
			activity/aBundleName-icon.svg
			locale/...
	"
	| dir archive fileAttr execAttr dirAttr localFileName scriptName |
	fileAttr := 16r81A4.
	execAttr := 16r81ED.
	dirAttr := 16r41ED.
	dir := aBundleName, '.activity/'.
	localFileName := FileDirectory localNameFor: aFileName.
	scriptName := aBundleName, '.sh'.
	archive := ZipArchive new.
	#('' 'bin' 'activity' 'locale') do: [:dirName | 
		(archive addDirectory: dir, dirName) unixFileAttributes: dirAttr].
	(archive addFile: aFileName as: dir, localFileName) unixFileAttributes: fileAttr.
	(archive addString: (self bundleScript: localFileName) as: dir, 'bin/', scriptName) unixFileAttributes: execAttr.
	(archive addString: (self bundleInfoTitle: aTitle version: aVersion bundle: aBundleID script: scriptName icon: aBundleName, '-icon') as: dir, 'activity/activity.info') unixFileAttributes: fileAttr.
	(archive addString: self bundleIcon as: dir, 'activity/', aBundleName, '-icon.svg') unixFileAttributes: fileAttr.
	archive members do: [:m | m setLastModFileDateTimeFrom: Time totalSeconds].
	archive writeToFileNamed: aBundleName, '-', aVersion asString, '.xo'.
	archive close.
]

{ #category : #bundling }
SugarLauncher >> bundleIcon [
	^self bundleIconTemplate  replaceAll: Character cr with: Character lf
]

{ #category : #bundling }
SugarLauncher >> bundleIconTemplate [
	"template for activity/icon.svg"

	^'<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd" [
        <!ENTITY fill_color "#AAAAAA">
        <!ENTITY stroke_color "#000000">
]>
<svg xmlns="http://www.w3.org/2000/svg" width="55" height="55">
  <g>
    <rect width="45" height="45" x="5" y="5" ry="7.5"
       style="fill:&fill_color;;stroke:&stroke_color;;stroke-width:3" />
  </g>
</svg>
'
]

{ #category : #accessing }
SugarLauncher >> bundleId [
	^parameters at: 'BUNDLE_ID' ifAbsent: ['org.squeak']
]

{ #category : #bundling }
SugarLauncher >> bundleInfoTemplate [
	"template for activity/activity.info"

	^'[Activity]
name = {TITLE}
activity_version = {VERSION}
host_version = 1
bundle_id = {BUNDLE}
icon = {ICON}
exec = {SCRIPT}
show_launcher = yes
'
]

{ #category : #bundling }
SugarLauncher >> bundleInfoTitle: aTitle version: aVersion bundle: aBundle script: aScriptName icon: anIconName [ 
	| s |
	s := self bundleInfoTemplate.
	{	'{TITLE}'. aTitle.
		'{VERSION}'. aVersion asString.
		'{BUNDLE}'. aBundle.
		'{ICON}'. anIconName.
		'{SCRIPT}'. aScriptName.
		String cr. String lf.
	} pairsDo: [:key :val |
		s := s copyReplaceAll:  key with: val].
	^s squeakToUtf8
]

{ #category : #accessing }
SugarLauncher >> bundlePath [
	^parameters at: 'BUNDLE_PATH' ifAbsent: [FileDirectory default pathName]
]

{ #category : #'as yet unclassified' }
SugarLauncher >> bundleScript: aFileName [
	| s |
	s := self bundleScriptTemplate.
	{	'{FILE}'. aFileName.
		String cr. String lf.
	} pairsDo: [:key :val |
		s := s copyReplaceAll:  key with: val].
	^s squeakToUtf8 
]

{ #category : #bundling }
SugarLauncher >> bundleScriptTemplate [
	"template for MyActivity.activity/bin/MyActivity.sh"

	^'#!/bin/sh
# Author: Bert Freudenberg
# Purpose: Run {FILE} in Etoys

# arguments are unordered, have to loop
args=""
while [ -n "$2" ] ; do
    case "$1" in
      	-b | --bundle-id)   bundle_id="$2"   ; args="$args BUNDLE_ID $2" ;;
      	-a | --activity-id) activity_id="$2" ; args="$args ACTIVITY_ID $2";;
      	-o | --object-id)   object_id="$2"   ; args="$args OBJECT_ID $2";;
	-u | --uri)         uri="$2"         ; args="$args URI $2";;
	*) echo unknown argument $1 $2 ;;
    esac
    shift;shift
done

# really need bundle id and activity id
if [ -z "$bundle_id" -o -z "$activity_id" ] ; then
  echo ERROR: bundle-id and activity-id arguments required
  echo Aborting
  exit 1
fi

# some debug output
echo launching $bundle_id instance $activity_id
[ -n "$object_id"   ] && echo with journal obj $object_id
[ -n "$uri"         ] && echo loading uri $uri
echo

# sanitize
[ -z "$SUGAR_PROFILE" ] && SUGAR_PROFILE=default
[ -z "$SUGAR_ACTIVITY_ROOT" ] && SUGAR_ACTIVITY_ROOT="$HOME/.sugar/$SUGAR_PROFILE/etoys"

# rainbow-enforced locations
export SQUEAK_SECUREDIR="$SUGAR_ACTIVITY_ROOT/data/private"
export SQUEAK_USERDIR="$SUGAR_ACTIVITY_ROOT/data/MyEtoys"

# make group-writable for rainbow
umask 0002
[ ! -d "$SQUEAK_SECUREDIR" ] && mkdir -p "$SQUEAK_SECUREDIR" && chmod o-rwx "$SQUEAK_SECUREDIR"
[ ! -d "$SQUEAK_USERDIR" ] && mkdir -p "$SQUEAK_USERDIR"

# do not crash on dbus errors
export DBUS_FATAL_WARNINGS=0

# now run Squeak VM with Etoys image
exec etoys \
    -sugarBundleId $bundle_id \
    -sugarActivityId $activity_id \
    --document "{FILE}" \
    BUNDLE_PATH "$SUGAR_BUNDLE_PATH" \
    MO_PATH "$SUGAR_BUNDLE_PATH/locale" \
    $args
'
]

{ #category : #chooser }
SugarLauncher >> chooseObject [
	| chooserId |
	chooserId := self journal chooseObject: 0.
	self journal
		onObjectChooserResponse: chooserId send: #chooser:response: to: self;
		onObjectChooserCancelled: chooserId send: #chooserDone: to: self
]

{ #category : #chooser }
SugarLauncher >> chooser: chooserId response: objectIdOrPath [
	self chooserDone: chooserId.
	WorldState addDeferredUIMessage: [
		(objectIdOrPath beginsWith: '/')
			ifTrue: [
				| path file title |
				path := objectIdOrPath utf8ToSqueak.
				file := FileStream readOnlyFileNamed: path.
				title := FileDirectory localNameFor: path.
				self handleStream: file mimetype: nil titled: title]
			ifFalse: [
				| props title mimetype |
				props := self getProperties: objectIdOrPath.
				title := props at: 'title' ifAbsent: ['untitled' translated].
				mimetype := props at: 'mime_type' ifAbsent: [''].
				[self open: objectIdOrPath title: title mimetype: mimetype]
					on: SugarPropertiesNotification do: [:ex | ex resume: props]]].
]

{ #category : #chooser }
SugarLauncher >> chooserDone: chooserId [
	self journal
		onObjectChooserResponse: chooserId send: nil to: self;
		onObjectChooserCancelled: chooserId send: nil to: self
]

{ #category : #gconf }
SugarLauncher >> gconfPropertiesAt: aString [
	| dir |
	"search up tree to guess home dir"
	dir := Project squeakletDirectory.
	[dir pathName = '/'] whileFalse: [
		dir := dir containingDirectory.		
		[FileStream
			readOnlyFileNamed: dir pathName, '/.gconf', aString, '/%gconf.xml'
			do: [:f |
				| props |
				props := Dictionary new.
				(XMLDOMParser parseDocumentFrom: f)
					tagsNamed: #entry do: [:entry |
						props at: (entry attributeAt: 'name')
							put: (entry attributeAt: 'value'
								ifAbsent: [entry elements first contentString])].
				^props].
		] on: FileDoesNotExistException do: [:ignore | ].
	].
	^self error: 'cannot find gconf path ', aString
]

{ #category : #commands }
SugarLauncher >> invite: aBuddyKey [
	"aBuddy was invited to our activity."

	| buddy |
	Utilities informUser: 'Inviting buddy ...' translated
		during: [
			self isShared ifFalse: [
				self sharePublicly: false.
				SugarNavigatorBar current joinSharedActivity].
			buddy := self presence getBuddyByPublicKey: aBuddyKey asByteArray.
			sharedActivity invite: buddy with: ''].

]

{ #category : #testing }
SugarLauncher >> isRunningInRainbow [
	"Need better test, but works for now. We cannot use dbus here"
	^Smalltalk osVersion = 'linux-gnu'
		and: [#('/home/olpc/isolation/' '/activities/' ) anySatisfy: [:dir |
			SecurityManager default secureUserDirectory beginsWith: dir]]
]

{ #category : #testing }
SugarLauncher >> isRunningInSugar [
	^self parameters includesKey: 'ACTIVITY_ID'
]

{ #category : #testing }
SugarLauncher >> isShared [
	^sharedActivity notNil
]

{ #category : #accessing }
SugarLauncher >> journal [
	^ (Smalltalk classNamed: 'SugarJournal') ifNotNil: [:journal | journal new]
]

{ #category : #chooser }
SugarLauncher >> open: id title: titleString mimetype: mimeString [
	| file |
	Utilities informUser: 'Opening journal entry' translated, String cr, 
			(titleString copyReplaceAll: String lf with: String cr)
		during: [file := self getFile: id].
	self handleStream: file mimetype: mimeString titled: titleString.
]

{ #category : #running }
SugarLauncher >> parameters: aDictionary [
	super parameters: aDictionary.

	"prevent reading bundled project at startup on resuming a journal object. This is for Etoys-based Sugar activities (e.g. made using #bundle:)."

	((parameters includesKey: 'OBJECT_ID') 
		and: [(Smalltalk getSystemAttribute: 2) isEmptyOrNil not])
			ifTrue: [Preferences disable: #readDocumentAtStartup]
]

{ #category : #commands }
SugarLauncher >> quit [
	| autoSave |
	autoSave := self shouldSaveOnQuit.

	Preferences sugarAutoSave ifFalse: [
		autoSave := false.
		(self 
			confirm: 'Are you sure you want to quit Etoys?
(the project will NOT be saved)' translated)
				ifFalse: [^self]].

	autoSave
		ifFalse: [^Smalltalk quitPrimitive].

	Project current
		projectParameterAt: #sugarAutoSave put: true;
		storeOnServerWithNoInteractionThenQuit.
]

{ #category : #commands }
SugarLauncher >> save [
	Project current 
		projectParameterAt: #sugarAutoSave put: false;
		storeOnServerWithNoInteraction
]

{ #category : #testing }
SugarLauncher >> shouldEnterHomeProject [
	"only if no other content is about to be loaded"
	^Preferences eToyFriendly
		and: [(Smalltalk getSystemAttribute: 2) isEmptyOrNil
			and: [(self includesParameter: 'SRC') not
				and: [Sensor hasDandDEvents not]]]

]

{ #category : #testing }
SugarLauncher >> shouldSaveOnQuit [
	"Don't save the home project to avoid confusion. Also, don't save if something was loaded from the XO bundle - this is for Etoys-based Sugar activities (e.g. made using #bundle:)."

	^Project current ~~ Project home
		and: [(Smalltalk getSystemAttribute: 2) isEmptyOrNil]
]

{ #category : #running }
SugarLauncher >> shutDown [
	sharedActivity ifNotNil: [
		self leaveSharedActivity.
		sharedActivity := nil].
	Project allSubInstancesDo: [:prj | prj removeParameter: #sugarId].
	ServerDirectory inImageServers keysAndValuesDo: [:srvrName :srvr |
		(srvr isKindOf: SugarDatastoreDirectory) ifTrue: [
			ServerDirectory removeServerNamed: srvrName ifAbsent: []]].
	Current := nil.
	Project current world windowEventHandler: nil.

]

{ #category : #running }
SugarLauncher >> startUp [
	self class allInstances do: [:ea | ea shutDown].

	Current := self.

	SugarNavigatorBar current
		ifNotNil: [:bar | bar startUp].

	parameters at: 'ACTIVITY_ID' ifPresent: [ :activityId |
		OLPCVirtualScreen setupIfNeeded.
		Project current world windowEventHandler: self.
		(Smalltalk classNamed: 'DBus') ifNotNil: [:dbus |
			dbus sessionBus 
				export: (Smalltalk classNamed: 'SugarEtoysActivity') new
				on: 'org.laptop.Activity', activityId
				at: '/org/laptop/Activity/', activityId].
		Utilities authorName: self ownerBuddy nick.
		ServerDirectory
			addServer: (SugarDatastoreDirectory mimetype: 'application/x-squeak-project' extension: '.pr')
			named: SugarLauncher defaultDatastoreDirName.
		self joinSharedActivity.
		self isShared ifFalse: [
			parameters at: 'OBJECT_ID' ifPresent: [:id |
				^self resumeJournalEntry: id]].
		self isShared ifTrue: [^self].
		^self welcome: (parameters at: 'URI' ifAbsent: [''])].

	self welcome: ''


]

{ #category : #commands }
SugarLauncher >> takeScreenshot [
	"ignored - we can take a screenshot any time"
]

{ #category : #commands }
SugarLauncher >> viewSource [

	Project current world addDeferredUIMessage: [
		Project current world showSourceKeyHit].
]

{ #category : #commands }
SugarLauncher >> welcome: aUrl [
	"Sent either when running from Sugar, or at regular startUp otherwise"

	aUrl isEmpty ifFalse: [
		| url |
		url := (aUrl includes: $/)
			ifTrue: [aUrl]
			ifFalse: ['file:', (parameters at: 'BUNDLE_PATH'), '/', aUrl].
		^(url endsWith: '.pr')
			ifTrue: [Project fromUrl: url]
			ifFalse: [WorldState addDeferredUIMessage: [FileStream fileIn: (url copyAfter: $:)]]].

	self shouldEnterHomeProject ifTrue: [Project home ifNotNil: [:p | p enter]].
]

{ #category : #testing }
SugarLauncher >> willSaveOnQuit [

	^Preferences sugarAutoSave
		and: [self shouldSaveOnQuit]
]

{ #category : #events }
SugarLauncher >> windowEvent: anEvent [
	anEvent type == #windowClose
		ifTrue: [^self quit].

]
