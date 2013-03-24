//
//  IWAppDelegate.h
//  IWantPieChart
//
//  Created by Andreas Henriksson on 2013-03-16.
//  Copyright (c) 2013 Andreas Henriksson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IWViewController;

@interface IWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) IWViewController *viewController;

@end
