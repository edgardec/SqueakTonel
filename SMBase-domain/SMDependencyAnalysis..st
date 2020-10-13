"
A dependency analysis is instantiated by an SMInstallationTask as a step in calculating how the task can be performed.

The analysis is done using a map and some input - for example a list of package releases that the task wants to get installed. It can then be queried for the results. The analysis is performed in a series of steps and middle results are collected in instvars. It also uses sub instances so the analysis actually forms a tree of several instances of SMDependencyAnalysis where each node describes one level of dependencies.

Instvars:

task - the task that instantiated this analysis.
map - the SMSqueakMap to use, we get it by asking the task.
wantedReleases - the releases that we want to install.
alreadyInstalled - the subset of wantedReleases that are already installed.
trivialToInstall - the subset of wantedReleases that do not have dependencies and can be installed directly.
alreadyInstallable - 	the subset of wantedReleases that do have dependencies but for which at least one configuration is fulfilled and thus the release can already be installed.
trickyReleases - the subset of wantedReleases that do have configurations but none of them are fulfilled, so some dependencies first needs to be installed before these releases can be installed.

workingConfigurations - an OrderedCollection of OrderedCollections holding all working configurations for the trickyReleases.
workingConfigurationsSize - size of workingConfigurations.
combinations - all possible (unordered) combinations of picking one working configuration for each tricky release.
suggestedInstallSetsSet - computed from combinations above. A Set of Sets of required releases. Each Set is a unique combination of the required releases to install in order to fulfill one configuration for each of the tricky releases.
conflictingInstallSetsSet - the subset of suggestedInstallSetsSet that are invalid since it includes multiple releases from the same package.
 
"
Class {
	#name : #SMDependencyAnalysis,
	#superclass : #Object,
	#instVars : [
		'task',
		'map',
		'wantedReleases',
		'alreadyInstalled',
		'trivialToInstall',
		'alreadyInstallable',
		'combinations',
		'suggestedInstallSetsSet',
		'workingConfigurations',
		'workingConfigurationsSize',
		'conflictingInstallSetsSet',
		'trickyReleases',
		'subAnalysises',
		'success'
	],
	#category : #'SMBase-domain'
}

{ #category : #'instance creation' }
SMDependencyAnalysis class >> task: ownerTask [

	^self new task: ownerTask
]

{ #category : #queries }
SMDependencyAnalysis >> allInstallPaths [
	"For all paths, collect in reverse all releases to install.
	At each level, first we add trivially installable releases
	(those that have no dependencies), then installable releases
	(those that have one configuration fulfilled) and finally
	the tricky releases (those left).
	Note that we also return paths with conflicting releases
	of the same package and paths with releases that conflict with
	already installed releases - those paths can be tweaked - and
	paths that are supersets of other paths."

	| installPaths |
	installPaths := OrderedCollection new.
	self allPathsDo: [:path |
		| releases |
		releases := OrderedCollection new.
		path reverseDo: [:ana |
			releases addAll: (ana trivialToInstall difference: releases).
			releases addAll: (ana alreadyInstallable difference: releases).
			releases addAll: (ana trickyReleases difference: releases)
			"Below for debugging
			r := OrderedCollection new.
			r add: ana trivialToInstall; add: ana alreadyInstallable; add: ana trickyReleases.
			releases add: r"].
		installPaths add: releases].
	^ installPaths
]

{ #category : #queries }
SMDependencyAnalysis >> allNormalizedInstallPaths [
	"Same as allInstallPaths, but with paths removed that
	are clear supersets of others."

	| installPaths |
	installPaths := self allInstallPaths.
	installPaths := installPaths reject: [:p1 |
					installPaths anySatisfy: [:p2 |
						(p1 ~~ p2) and: [p1 includesAllOf: p2]]].
	^installPaths
]

{ #category : #private }
SMDependencyAnalysis >> allPathsDo: aBlock [
	"For all paths down the tree, evaluate aBlock."

	^ self allPathsDo: aBlock trail: OrderedCollection new
]

{ #category : #private }
SMDependencyAnalysis >> allPathsDo: aBlock trail: trail [
	"For all paths down the tree, evaluate aBlock."

	trail add: self.
	subAnalysises
		ifNil: [
			aBlock value: trail.]
		ifNotNil: [
			subAnalysises do: [:sub |
				sub allPathsDo: aBlock trail: trail]].
	trail removeLast
]

{ #category : #private }
SMDependencyAnalysis >> allRoutesDo: aBlock currentRoute: currentRoute level: level [
	"Recursively iterate over all routes down the tree."

	| newLevel |
	workingConfigurationsSize = level ifTrue: ["we reached the leaves"
		workingConfigurations last do: [:conf | 
			currentRoute addLast: conf.
			aBlock value: currentRoute.
			currentRoute removeLast].
		^self].
	newLevel := level + 1.
	(workingConfigurations at: level) do: [:conf |
		currentRoute addLast: conf.
		self allRoutesDo: aBlock currentRoute: currentRoute level: newLevel.
		currentRoute removeLast]
]

{ #category : #accessing }
SMDependencyAnalysis >> alreadyInstallable [
	^alreadyInstallable
	
]

{ #category : #accessing }
SMDependencyAnalysis >> alreadyInstalled [
	^alreadyInstalled
	
]

{ #category : #queries }
SMDependencyAnalysis >> bestInstallPath [
	"Using some heuristics we suggest the best path:
		- No conflicts
		- Fewest releases
		- If same packages, the newest releases"

	| paths min points |
	paths := self installPathsWithoutConflicts.
	paths size = 1 ifTrue: [^paths first].
	min := paths inject: 999 into: [:mi :p | p size < mi ifTrue: [p size] ifFalse: [mi]].
	paths := paths select: [:p | p size = min].
	paths size = 1 ifTrue: [^paths first].
	"Try to pick the one with newest releases"
	points := Dictionary new.
	paths do: [:p | | point |
		point := 0.
		p do: [:r | | package |
			package := r package.
			paths do: [:p2 |
				p2 == p ifFalse: [
					(p2 anySatisfy: [:r2 |
						(r2 package == package) and: [r newerThan: r2]])
							ifTrue:[point := point + 1]]]].
		points at: p put: point].
	points isEmpty ifTrue: [^nil].
	^(points associations detectMax: [ :each | each value ]) key
]

{ #category : #private }
SMDependencyAnalysis >> collectCombinationsOfConfigurations [
	"Given the wanted releases, find and return all possible combinations
	of working configurations for all those. Perhaps not possible to do
	given lots of releases and configurations, then we need smarter algorithms."
	
	"Pick out all working configurations first."
	workingConfigurations := (trickyReleases collect: [:r | r workingConfigurations]) asOrderedCollection.
	workingConfigurationsSize := workingConfigurations size.
	
	"We iterate over all possible combinations of configurations
	and collect the unique set of unordered configurations."
	combinations := Set new.
	self allRoutesDo: [:route |
		combinations add: route asSet copy] currentRoute: OrderedCollection new level: 1
]

{ #category : #private }
SMDependencyAnalysis >> computeInstallSets [
	"Given all combinations of configurations, compute all valid combinations
	of depdendency releases - all possible different Sets of required releases
	to install before the trickyReleases can be installed."
	
	"For each unique combination of configurations, collect all required releases
	and produce a Set of unique required release combinations." 
	suggestedInstallSetsSet := (combinations collect: [:comb |
								comb inject: Set new into: [:set :conf |
									set addAll: conf requiredReleases.
									set ]]) asSet.

	"Filter out those Sets that have multiple releases of the same package, they are conflicting
	and thus not valid - we can't have two different releases of the same package
	installed at the same time."
	
	"conflictingInstallSetsSet := suggestedInstallSetsSet select:
								[:set | self detectConflictingReleasesIn: set].
	suggestedInstallSetsSet removeAll: conflictingInstallSetsSet"
]

{ #category : #private }
SMDependencyAnalysis >> detectConflictingReleasesIn: collectionOfReleases [
	"Detect if the Set has multiple releases of the same package."

	| detectedPackages |
	detectedPackages := Set new.
	collectionOfReleases do: [:r |
		(detectedPackages includes: r package)
			ifTrue: [^ true]
			ifFalse: [detectedPackages add: r package]].
	^false
]

{ #category : #printing }
SMDependencyAnalysis >> indent: level [
	^'                                                  '
		last: level * 6
]

{ #category : #calculation }
SMDependencyAnalysis >> installPackageReleases: packageReleases [
	"Given a Set of wanted SMPackageReleases, calculate all possible
	installation scenarios. If the analysis succeeds, return true, otherwise false."
	
	
	wantedReleases := packageReleases copy.
	"First classify the releases in different groups."
	self partitionReleases.
	
	"If there are no tricky releases, we are already done.
	No extra required releases needs to be installed or upgraded."
	trickyReleases isEmpty ifTrue: [^success := true].

	"Ok, that was the easy part. The releases left now needs to be processed
	so that we can find out the different scenarios of required releases that we need
	to install first. First we calculate all combinations of available working configurations
	for the tricky releases."
	self collectCombinationsOfConfigurations.
	
	"Based on all configuration combinations,
	compute possible combinations of dependency releases."
	self computeInstallSets.
	
	"Check if we have failed - meaning that there are no valid scenarios without conflicts."
	suggestedInstallSetsSet isEmpty ifTrue: [^success := false].
	
	"Ok, this means we have at least one solution *on this level*! But we need to do the
	analysis recursively for all these sets of required releases..."
	subAnalysises := OrderedCollection new.
	success := false.
	suggestedInstallSetsSet do: [:set | | result subAnalysis |
		subAnalysis := SMDependencyAnalysis task: task.
		result := subAnalysis installPackageReleases: set.
		result ifTrue: [success := true].
		subAnalysises add: subAnalysis].
	
	"Did at least one succeed? If so, then we have at least one possible scenario!
	If not, then we need to do tweaking."
	^success
]

{ #category : #queries }
SMDependencyAnalysis >> installPathsWithConflicts [
	"Same as allInstallPaths, but we only return paths
	with multiple releases of the same package."

	^ self allInstallPaths select: [:path | self detectConflictingReleasesIn: path] 
]

{ #category : #queries }
SMDependencyAnalysis >> installPathsWithoutConflicts [
	"Same as allInstallPaths, but we filter out paths
	with multiple releases of the same package."

	^ self allInstallPaths reject: [:path | self detectConflictingReleasesIn: path] 
]

{ #category : #private }
SMDependencyAnalysis >> partitionReleases [
	"Move releases from wantedReleases to suitable other collections
	if they are either installed, trivial to install, or installable as is."
	
	trickyReleases := wantedReleases copy.
	alreadyInstalled := wantedReleases select: [:r | r isInstalled ].
	trickyReleases removeAll: alreadyInstalled. 
	trivialToInstall := trickyReleases select: [:r | r hasNoConfigurations ].
	trickyReleases removeAll: trivialToInstall.		
	alreadyInstallable := trickyReleases select: [:r | r hasFulfilledConfiguration ].
	trickyReleases removeAll: alreadyInstallable
]

{ #category : #printing }
SMDependencyAnalysis >> printAllInstallPaths [
	"Follow all install paths in the tree."

	^String streamContents: [:s |
		self allInstallPaths do: [:path |
			path do: [:rel |
				s nextPutAll: rel packageNameWithVersion, ', '].
			s cr]] 
]

{ #category : #private }
SMDependencyAnalysis >> removeOlderReleasesIn: collectionOfReleases [
	"Remove older multiple releases of the same package.
	2 scans to retain order."

	| newestReleases rel |
	newestReleases := Dictionary new.
	collectionOfReleases do: [:r |
		rel := newestReleases at: r package ifAbsentPut: [r].
		(r newerThan: rel) ifTrue: [newestReleases at: r package put: r]].
	^collectionOfReleases select: [:r |
		(newestReleases at: r package) == r]
]

{ #category : #accessing }
SMDependencyAnalysis >> success [
	^success
	
]

{ #category : #accessing }
SMDependencyAnalysis >> task: ownerTask [
	task := ownerTask.
	map := task map
]

{ #category : #printing }
SMDependencyAnalysis >> treeString [
	"Return a indented String showing the tree
	structure of all possible scenarios."

	^String streamContents: [:s |
		self treeStringOn: s indent: 0]
]

{ #category : #printing }
SMDependencyAnalysis >> treeStringOn: stream indent: level [
	"Print the tree
	structure of all possible scenarios."

	| i |
	i := self indent: level.
	stream nextPutAll: i, 'Wanted:'; cr.
	wantedReleases do: [:r |
		stream nextPutAll: i ,'  ' , r packageNameWithVersion;cr].
	stream nextPutAll: i, 'Tricky:'; cr.
	trickyReleases do: [:r |
		stream nextPutAll: i ,'  ' , r packageNameWithVersion;cr].
	stream cr.
	subAnalysises ifNotNil: [
		subAnalysises do: [:sub | sub treeStringOn: stream indent: level + 1]]
]

{ #category : #accessing }
SMDependencyAnalysis >> trickyReleases [
	^trickyReleases
	
]

{ #category : #accessing }
SMDependencyAnalysis >> trivialToInstall [
	^trivialToInstall
	
]

{ #category : #queries }
SMDependencyAnalysis >> untestedInstallPaths [
	"We take the paths with conflicts and remove the older releases."

	^self installPathsWithConflicts collect: [:p |
		 self removeOlderReleasesIn: p] 
]

{ #category : #accessing }
SMDependencyAnalysis >> wantedReleases [
	^wantedReleases
	
]
