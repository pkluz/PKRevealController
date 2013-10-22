# Usage 

The `PKRevealController.h` file is extensively documented. Make yourself familiar with it. There's also a sample project in the `Sample/` directory which I recommend you take a look at.

## Setup

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

## Interaction

By importing the `PKRevealController.h` file you automatically import an Objective-C category, which extends all UIViewControllers and its descendants with a `revealController` property. The result is a behaviour similar to the familiar `navigationController` property.

### Configuring the views
Each of the side controllers that are managed by your reveal controller can specify their own reveal-widths. 
For instance in their `viewDidLoad` method:	

```objective-c
// This could be somewhere in the LeftRearViewController.h file...
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.revealController setMinimumWidth:220.0 maximumWidth:244.0 forViewController:self];
}
```

### Sending messages between controllers
It is really easy to send messages between controllers, as the `revealController` exposes each of those as properties. For instance, from your left view controller you can easily print a description of the front view controller like this:

```objective-c
[self.revealController.frontViewController description];
```

### And more…
You can do **a lot** more. Digg into the `PKRevealController.h` header file to find out what methods are at your disposal.

