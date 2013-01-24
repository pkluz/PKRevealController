<center>![PKRevealController](https://raw.github.com/pkluz/PKRevealController/master/hero.png)</center>

PKRevealController is a delightful view controller container for iOS, enabling you to present multiple controllers on top of one another. It is easy to set-up and highly flexible.

>The PKRevealController is the evolution of the ZUUIRevealController but **not API compatible** with any previous versions. The entire controller was rewritten from the ground up and major changes were inevitable. If you wish to access the older versions, please download one of the [tags](https://github.com/pkluz/PKRevealController/tags) or checkout the [deprecated](https://github.com/pkluz/PKRevealController/tree/deprecated) branch.

<br />

##Features
- Proper view controller containment usage
- Elegant block API
- Supports both left and right sided view presentation
- Works on both iPhones & iPads
- Supports landscape & portrait orientations

<br />

##How-To
You can either simply drag and drop the `PKRevealController/Controller` folder into your existing project or add the library as a submodule and reference `PKRevealController.xcodeproj` from within your own project.

###Setup
--
1. `#import "PKRevealController.h"` wherever you require access to it.

2. Instantiate an options dictionary if you wish to have more granular control over the controller's behaviour:

    ``` objective-c
    // PKRevealController.h contains a list of all the specifiable options
    NSDictionary *options = @{
        PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
        PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES]
    };
    ```
3. Instantiate the view controllers you wish to present within the reveal controller and pass them as parameters to the initializer of your choice along with the options dictionary (or `nil` for default behaviour):

    ``` objective-c
    // Convenience initializer for a one-sided reveal controller.
    PKRevealController *revealController = [PKRevealController revealControllerWithFrontViewController:frontVC leftViewController:leftVC options:options];
    ```
4. Assign the controller as your root view controller:
	``` objective-c
    self.window.rootViewController = revealController;
	```

###Usage
--
By importing the `PKRevealController.h` file you automatically import an Objective-C category which extends all UIViewControllers and its descendants with a `revealController` property. The result is a behaviour similar to the familiar `navigationController` property.

###Configuring the views
Each of the side controllers that are managed by your reveal controller can specify their own reveal-widths. 
For instance in their `viewDidLoad` method:	

```
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.revealController setMinimumWidth:220.0f maximumWidth:244.0f forViewController:self];
}
```

###Sending messages between controllers
It is really easy to send messages between controllers, as the `revealController` exposes each of those as properties. For instance, from you left view controller you can easily print a description of the front view controller like this:
``` objective-c
[self.revealController.frontViewController description];
```

###And more…
Please have a look at the [PKRevealController.h](https://github.com/pkluz/PKRevealController/blob/master/PKRevealController/Controller/PKRevealController.h) file to see a detailed documentation of the entire API the controller provides. For more detailed tutorials please take a look at the [wiki](https://github.com/pkluz/PKRevealController/wiki). Chances are, your issue is already covered.

<br />

##Requirements
- Requires iOS 5.0 or above
- Requires Automatic Reference Counting (ARC)

> If you require non-ARC compatibility, you will need to set the `-fobjc-arc` compiler flag on all of the PKRevealController source files.

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
