//
//  AppDelegate.h
//  Carbon
//
//  Created by Koushik Dutta on 1/26/13.
//  Copyright (c) 2013 ClockworkMod. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CarbonWindow.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    CarbonWindow* window;
}

@property (assign) IBOutlet CarbonWindow *window;

@end
