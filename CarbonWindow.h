//
//  CarbonWindow.h
//  CarbonMac
//
//  Created by Koushik Dutta on 1/27/13.
//  Copyright (c) 2013 ClockworkMod. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CarbonWindow : NSWindow {
    bool destroyed;
    NSMutableDictionary* connectedDevices;
    NSImage* checked;
    NSImage* unchecked;
}


- (void) killAll;
- (void) refresh: (id) o;

@property (assign) bool destroyed;
@property (retain) NSMutableDictionary* connectedDevices;
@property (unsafe_unretained) IBOutlet NSImageView *logo;
@property (unsafe_unretained) IBOutlet NSTextField *status;

@end
