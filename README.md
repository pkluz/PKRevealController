
## Version 2.0

Version 2.0 is currently still **under development**. It is API compatible with the previous versions, although **some methods and properties have been deprecated**.

It is stable enough for daily use and fixes a lot of the issues the previous version had, nevertheless I recommend checking for updates as often as you possibly can.

A `master` release is scheduled for the **end of July**.

## Known Issues

- Missing documentation.
- CocoaPods is currently _NOT_ working.
- `revealResetTapGestureRecognizer`'s behaviour is now being affected by _two_ other properties. These are: `recognizesResetTapOnFrontView` and `recognizesResetTapOnFrontViewInPresentationMode`. Please disable BOTH if you wish to disable the behaviour entirely.
- Projects setting are not yet taken care of. I.e. building the framework for production might not work out the way it's supposed to.