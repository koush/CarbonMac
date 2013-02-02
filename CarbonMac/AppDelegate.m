//
//  AppDelegate.m
//  Carbon
//
//  Created by Koushik Dutta on 1/26/13.
//  Copyright (c) 2013 ClockworkMod. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [self.window killAll];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application 
    [self.window setBackgroundColor:[NSColor colorWithPatternImage:[NSImage imageNamed:@"carbon_fiber.jpg"]]];
}

- (void) handleOpenApplicationEvent:(NSAppleEventDescriptor *)event
                     withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    self.window.isVisible = true;
}

-(void)applicationWillFinishLaunching:(NSNotification *)notification
{
    NSAppleEventManager *appleEventManager = [NSAppleEventManager
                                              sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector
     (handleOpenApplicationEvent:withReplyEvent:)
                         forEventClass:kCoreEventClass
                            andEventID:kAEOpenApplication];
    
    [appleEventManager setEventHandler:self
                           andSelector:@selector
     (handleOpenApplicationEvent:withReplyEvent:)
                         forEventClass:kCoreEventClass
                            andEventID:kAEReopenApplication];
    
    [appleEventManager setEventHandler:self
                           andSelector:@selector
     (handleOpenApplicationEvent:withReplyEvent:)
                         forEventClass:kCoreEventClass
                            andEventID:kAEOpenDocuments];
}

@end
