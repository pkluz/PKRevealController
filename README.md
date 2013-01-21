# PKRevealController <span style="font-weight:normal">(ZUUIRevealController)</span>
PKRevealController is a delightful view controller container for iOS, enabling you to present multiple controllers on top of one another. It is easy to set-up and highly flexible.

>The PKRevealController is the evolution of the ZUUIRevealController but **not API compatible** with any previous versions. The entire controller was rewritten from the ground up and major changes were inevitable. If you wish to access the older versions, please download one of the [tags](https://github.com/pkluz/ZUUIRevealController/tags) or checkout the [deprecated](https://github.com/pkluz/ZUUIRevealController/tree/deprecated) branch.

##Features
- Proper view controller containment usage
- Elegant block API
- Supports both left and right sided view presentation
- Works on both iPhones & iPads
- Supports landscape & portrait orientations

##How-To
You can either simply drag and drop the `PKRevealControllerClasses` folder into your existing project or you can add the library as a submodule and reference the project from within your own.

1. `#import "PKRevealController.h"` wherever you require access to it.
2. Setup an options dictionary if you wish to have more granular control over the controller's behaviour:

    ``` objective-c
    NSDictionary *options = @{
        PKRevealControllerAllowsOverdrawKey : [NSNumber numberWithBool:YES],
        PKRevealControllerDisablesFrontViewInteractionKey : [NSNumber numberWithBool:YES]
    };
    ```
            
3. Instantiate the view controllers you wish to present within the reveal controller and pass them as parameters to the initializer of your choice:

    `ds`

##License
PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
