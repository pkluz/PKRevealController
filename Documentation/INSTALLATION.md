# Installation

You can install **PKRevealController** either using **[CocoaPods](http://cocoapods.org)** or the **static library**. Please note, that the CocoaPods version will always be the most stable, whilst the static library will include the most recent changes, bug fixes and features.

## CocoaPods

Simply add `pod 'PKRevealController'` to your Podfile, execute a `pod update` and `#import <PKRevealController/PKRevealController.h>`.

## Static Library

1. Add the repository as a **submodule**.
    ```
    git submodule add https://github.com/pkluz/PKRevealController.git
    ```

2. **Drag and drop** `Source/PKRevealController.xcodeproj` into your project or workspace.
![Image](http://img4.imageshack.us/img4/6169/qhid.png)

3. In your project settings, link against `libPKRevealController.a`.
![Image](http://imageshack.us/a/img36/6909/1ii.png)

4. In your project build settings, add `-ObjC` to your `Other Linker Flags`.
![Image](http://imageshack.us/a/img849/7499/tw3u.png)

5. Add the contents of the `Headers/` directory into your project _(**Note**: Make sure to **uncheck** 'Copy items into destination…' and **check** your project's target)._
![Image](http://img9.imageshack.us/img9/5581/7x41.png)</center>

6. `#import "PKRevealController.h"` wherever you require it or just once in your project's **.pch** file.
