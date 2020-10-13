"
This class exists soley as a description of this package, and how it should be used.

When a package is removed from the trunk update process, you will need to increase the version number of the Squeak-Version package (this one) by the version number of the package removed + 1.  This ensures that the trunk build number keeps increasing.

An example: 
When you unload a package, let's say Universes-mt.48, you add 49 (48 + 1) to the version number of Squeak-Version and save it.
Additionally, add in the package postscript the code to actually unload the package from the image as well:
---------- package postscript ----------
(MCPackage named: 'Universes') unload.

Why is this important?

The Squeak Trunk update (build) number (or Squeak ""version"") is thesum of versions of all the base packages.
This works great as long as we update packages and occassionally add new packages to Trunk.
However, when we remove packages from the base system, we must bump Squeak-Version's version by the removed package's version number, so that the aggregate version number doesn't decrease.

In addition, folks have started to use the postscript of this package to actually remove the packages from the image that are removed from the Trunk updating process.  This is especially useful if the package is empty before it was removed - then it removes cruft from users images.

"
Class {
	#name : #SqueakVersion,
	#superclass : #Object,
	#category : #'Squeak-Version'
}
