//
//  CarbonWindow.m
//  CarbonMac
//
//  Created by Koushik Dutta on 1/27/13.
//  Copyright (c) 2013 ClockworkMod. All rights reserved.
//

#import "CarbonWindow.h"

@interface Device : NSObject {
    bool enabled;
    bool installed;
}
@property (assign) bool enabled;
@property (assign) bool installed;
@end

@implementation Device
@synthesize enabled;
@synthesize installed;

- (id)init
{
    self = [super init];
    if (self) {
        self.installed = true;
    }
    return self;
}
@end

@implementation CarbonWindow

//@synthesize destroyed;
//@synthesize connectedDevices;
//@synthesize logo;
//@synthesize status;

-(void)close {
    self.isVisible = false;
    
}

- (void) killAll {
    destroyed = true;
}

+ (NSString*) readProcess:(const char*) command {
    NSString* output = @"";
    FILE* proc = popen(command, "r");
    char buffer[2048];
    size_t read;
    while (0 != (read = fread(buffer, sizeof(char), sizeof(buffer) - 1, proc))) {
        buffer[read] = '\0';
        output = [output stringByAppendingFormat: @"%s", buffer];
    }
    pclose(proc);
    return output;
}

+ (NSString*) readAdbCommand: (const char*) adb withCommand: (const char*) command {
    NSString* cmd = [NSString stringWithFormat: @"%s %s", adb, command];
    return [CarbonWindow readProcess: [cmd UTF8String]];
}

+ (NSString*) readAdbCommand: (const char*) adb forDevice: (NSString*) device withCommand: (const char*) command {
    NSString* cmd = [NSString stringWithFormat: @"%s -s %@ %s", adb, device, command];
    return [CarbonWindow readProcess: [cmd UTF8String]];
}

+ (void) runAndDetachAdbCommand: (const char*) adb forDevice: (NSString*) device withCommand: (const char*) command {
    if (0 == fork()) {
        int ret = execl(adb, adb, "-s", [device UTF8String], "shell", command, NULL);
        printf("fail: %s %d\n", adb, ret);
        exit(1);
    }
}


- (void) refresh: (id) o {
    if ([connectedDevices count] == 0) {
        [logo setImage: unchecked];
        [status setStringValue: @"Please connect your Android to USB."];
        [NSApp setApplicationIconImage: logo.image];
        return;
    }
    bool installed = false;
    bool enabled = false;
    for (Device* device in [connectedDevices allValues]) {
        installed = device.installed;
        if (!installed) {
            break;
        }
        enabled = device.enabled;
        if (!enabled) {
            break;
        }
    }
    if (!installed) {
        [logo setImage: unchecked];
        [status setStringValue: @"Please install Carbon on your Android."];
    }
    else if (!enabled) {
        [logo setImage: unchecked];
        [status setStringValue: @"An error occured while trying to enable Carbon."];
    }
    else {
        [logo setImage: checked];
        [status setStringValue: @"Carbon has been enabled on your Android."];
    }
    [NSApp setApplicationIconImage: logo.image];
}

+ (void) run_node_thread:(id) param {
    char adb[PATH_MAX];
    sprintf(adb, "%s/Contents/Resources/darwin/adb", [[[NSBundle mainBundle] bundlePath] UTF8String]);

    [CarbonWindow readAdbCommand:adb withCommand: "kill-server"];
    [CarbonWindow readAdbCommand:adb withCommand: "start-server"];
    
    NSCharacterSet* trimChars = [NSCharacterSet characterSetWithCharactersInString: @"\n\r\t "];
    CarbonWindow* s = param;
    while (!s->destroyed) {
        NSString* output = [CarbonWindow readAdbCommand:adb withCommand:"devices"];
        
        NSMutableDictionary* newConnected = [[NSMutableDictionary alloc] init];
        NSArray* lines = [output componentsSeparatedByString: @"\n"];
        for (int i = 0 ; i < [lines count]; i++) {
            if (i == 0)
                continue;
            NSString* line = [lines objectAtIndex: i];
            NSString* deviceId = [[[line stringByTrimmingCharactersInSet: trimChars] componentsSeparatedByString: @"\t"] objectAtIndex: 0];
            if ([deviceId length] == 0)
                continue;
            Device* device = [s->connectedDevices objectForKey: deviceId];
            if (device == nil) {
                device = [[Device alloc] init];
            }
            [newConnected setObject:device forKey:deviceId];
            if (device.enabled) {
                continue;
            }
            output = [[CarbonWindow readAdbCommand:adb forDevice:deviceId withCommand:"shell pm path com.koushikdutta.backup"] stringByTrimmingCharactersInSet: trimChars];
            if (output.length == 0) {
                device.installed = false;
                [CarbonWindow runAndDetachAdbCommand:adb forDevice:deviceId withCommand: "am start -d market://details?id=com.koushikdutta.backup"];
                continue;
            }
            
            NSString* classPath = [output stringByReplacingOccurrencesOfString:@"package:" withString:@""];
            [CarbonWindow runAndDetachAdbCommand:adb forDevice:deviceId withCommand: [[NSString stringWithFormat: @"CLASSPATH=%@ app_process /system/bin com.koushikdutta.shellproxy.ShellRunner2 &", classPath] UTF8String]];
            device.enabled = true;
        }
        s->connectedDevices = newConnected;
        
        [s performSelectorOnMainThread:@selector(refresh:) withObject: nil waitUntilDone: false];
        sleep(3);
    }
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)windowStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation {
    id ret = [super initWithContentRect:contentRect styleMask:windowStyle backing:bufferingType defer:deferCreation];
    
    [NSThread detachNewThreadSelector:@selector(run_node_thread:) toTarget:[CarbonWindow class] withObject:ret];

    connectedDevices = [[NSMutableDictionary alloc] init];
    
    checked = [NSImage imageNamed: @"logochecked.icns"];
    unchecked = [NSImage imageNamed: @"logo.icns"];
    
    return ret;
}


@end
