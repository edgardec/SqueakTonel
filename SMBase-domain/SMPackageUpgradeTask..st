"
A package upgrade task is to upgrade one or more given SMPackages (not specified releases) in the image to newer releases.

First it tries to calculate the newest available releases of the given packages that it will try to upgrade given the policy and preferences set by the user. Then it runs an analysis to find how to upgrade to those wanted releases. This typically results in zero, one or more possible scenarios.

"
Class {
	#name : #SMPackageUpgradeTask,
	#superclass : #SMPackageInstallationTask,
	#category : #'SMBase-domain'
}
