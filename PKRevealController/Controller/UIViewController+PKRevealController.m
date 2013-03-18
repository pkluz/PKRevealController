/*
 
 PKRevealController - Copyright (C) 2012 Philip Kluz (Philip.Kluz@zuui.org)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "UIViewController+PKRevealController.h"
#import "PKRevealController.h"
#import <objc/runtime.h>

@implementation UIViewController (PKRevealController)

static char revealControllerKey;

- (void)setRevealController:(PKRevealController *)revealController
{
    objc_setAssociatedObject(self, &revealControllerKey, revealController, OBJC_ASSOCIATION_ASSIGN);
}

- (PKRevealController *)revealController
{
    PKRevealController* aRevealController = (PKRevealController *)objc_getAssociatedObject(self, &revealControllerKey);
    
    if (aRevealController == nil) {
        aRevealController = [self.parentViewController revealController];
    }
    
    return aRevealController;
}

@end
