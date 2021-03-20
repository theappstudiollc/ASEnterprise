# ASEnterprise #

A collection of useful functions for iOS, macOS, tvOS, and watchOS apps

I am releasing the source code to ASEnterprise, an Objective C Apple framework I have been developing since 2013. It was used in several commercial apps, and while not very valuable now, I hope the code and project serves as a useful reference on Objective C code suitable for multi-platform frameworks, importation within Swift, as well as how to build and distribute via Swift Packages and via CocoaPods.

## The future ##

While the 1.x versions of this framework are essentially being sunset (as Objective C is not as important anymore), there is the potential for this code to be refactored into a v2.x for the purposes of creating shared code for a Swift Framework and Xamarin Binding Library.

## Installation ##

This project includes both a Swift Package and an Xcode project, which also has a build target that can properly build .framework files on all Apple platforms.

### For Swift Package Manager ###

So far, this distributes via normal SPM mechanisms, and does not require any custom setup to use. Though please ignore the 'frameworks' and 'libraries' folders, as those are for CocoaPods distribution.

### For CocoaPods ###

This is a public framework containing various useful functions for iOS and OSX apps. To use, you must first [install CocoaPods](http://guides.cocoapods.org/using/getting-started.html).

> $ sudo gem install cocoapods

Go into the directory with your Xcode Project and generate a Podfile

> $ pod init

Then add this to the top of your Podfile

> source 'https://bitbucket.org/theappstudiollc/podspecs.git'

An example use inside your Podfile:

> pod 'ASEnterpriseFramework', '1.0.0'

Unlikely, but if the podspec cannot be found, set up a private repository ([more information](http://guides.cocoapods.org/making/private-cocoapods.html))

> $ pod repo add bitbucket-theappstudiollc-podspecs https://bitbucket.org/theappstudiollc/podspecs
