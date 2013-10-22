<center>![PKRevealController v2.0](http://imageshack.us/a/img401/4317/0mmv.png)</center>


PKRevealController is a delightful view controller container for iOS, enabling you to present multiple controllers on top of one another. It is easy to set-up and highly flexible.

<br />

## Features

- iPhone and iPad support.
- Landscape and portrait support.
- Left and right sides view presentation.

<br />

## Installation

### CocoaPods

Simply add `pod 'PKRevealController'` to your Podfile.

### Static Library

1. Add the repository as a submodule.
    ```
    git submodule add https://github.com/pkluz/PKRevealController.git
    ```

2. Drag and drop `Source/PKRevealController.xcodeproj` into your project or workspace.

3. In your project settings, link against `libPKRevealController.a`. ![Image](http://imageshack.us/a/img36/6909/1ii.png)

4. In your project build settings, add `-ObjC` to your `Other Linker Flags`. ![Image](http://imageshack.us/a/img849/7499/tw3u.png)

5. Add the contents of the `Headers/` directory into your project _(**Note**: Make sure to **uncheck** 'Copy items into destination…' and **check** your project's target)._ ![Image](http://img9.imageshack.us/img9/5581/7x41.png)

6. `#import "PKRevealController.h"` wherever you require it or just once in your project's .pch file.

<br />

## Usage 

The `PKRevealController.h` file is extensively documented. Make yourself familiar with it. There's also a Sample Project in the `Sample/` directory which I recommend you take a look at.

### Startup

1. Instantiate.
    ```objective-c
    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:front leftViewController:left];                
    ```
    
2. Configure.
    ```objective-c
    revealController.delegate = self;
    ```
    
3. Apply.
   ```objective-c
   self.window.rootViewController = revealController;
   ```

<br />

## Interaction

By importing the `PKRevealController.h` file you automatically import an Objective-C category which extends all UIViewControllers and its descendants with a `revealController` property. The result is a behaviour similar to the familiar `navigationController` property.

###Configuring the views
Each of the side controllers that are managed by your reveal controller can specify their own reveal-widths. 
For instance in their `viewDidLoad` method:	

```objective-c
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.revealController setMinimumWidth:220.0 maximumWidth:244.0 forViewController:self];
}
```

###Sending messages between controllers
It is really easy to send messages between controllers, as the `revealController` exposes each of those as properties. For instance, from your left view controller you can easily print a description of the front view controller like this:
```objective-c
[self.revealController.frontViewController description];
```

###And more…
Please have a look at the [PKRevealController.h](https://github.com/pkluz/PKRevealController/blob/master/PKRevealController/Controller/PKRevealController.h) file for detailed documentation of the entire API the controller provides. For more detailed tutorials please take a look at the [wiki](https://github.com/pkluz/PKRevealController/wiki). Chances are, your issue is already covered.

<br />

##Requirements
- Requires iOS 6.0 or later
- Requires Automatic Reference Counting (ARC)

<br />

##License
Starting with v1.0b the controller is released under the _MIT license_, though upgraders from the ZUUIRevealController are free to keep using the _BSD clause-3_.

> PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
>
> Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
> 
> The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
> 
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.