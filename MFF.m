//
//  MFF.m
//  MultiFirefox
//
//  Created by David Martorana on 4/7/08.
//  Copyright 2008. All rights reserved.
//

#import "MFF.h"
#import <unistd.h>

// Some path constants, for now
static const NSString* __FIREFOX_PROFILE_PATH__ = @"~/Library/Application Support/Firefox/Profiles";
static const NSString* __APPLICATIONS_PATH__ = @"/Applications";

@implementation MFF

// Open the profiles window
+ (void)openFirefoxProfilesWindow:(NSString *)version
{
    NSLog(@"version: %@", version);
        
    NSString *toBeCalled = [[self getFirefoxCmd:version] stringByAppendingString: @" --profilemanager &"];
    
    NSLog(@"%@", [@"Profile Launch call: " stringByAppendingString:toBeCalled]);
    
    system([toBeCalled UTF8String]);
    
}

+ (NSString *) getFirefoxPath:(NSString *)version
{
    NSString *firefoxPath = [[__APPLICATIONS_PATH__ stringByAppendingPathComponent:[version stringByAppendingString:@".app"]] stringByAppendingPathComponent:@"Contents/MacOS/firefox-bin"];
    return firefoxPath;
}

+ (NSString *) getFirefoxCmd:(NSString *)version
{
    SInt32 MacVersion;
    NSString *prefix = @"";

    //try to get version info
    if (Gestalt(gestaltSystemVersion, &MacVersion) == noErr) 
    {
        NSLog(@"MacVersion: %x", MacVersion);

        //only add prefix for anything less than 10.6
        if (MacVersion < 0x1060) 
        {
            prefix = @"/usr/bin/arch -$(/usr/bin/arch) ";
        }

    }

    NSString *firefoxCmd = [[[prefix stringByAppendingString:@"'"] stringByAppendingString:[self getFirefoxPath:version]] stringByAppendingString:@"'"];
    return firefoxCmd;
}

// Check to be sure there aren't multiple profiles
+ (BOOL) multipleProfilesExist
{
    // Create the appropriate folder name
    NSString *folderName = [__FIREFOX_PROFILE_PATH__ stringByExpandingTildeInPath];
    NSArray *folderContents = [[NSFileManager defaultManager] directoryContentsAtPath:folderName];
    
    // Get the number of directories
    int count = [folderContents count];
    if ([folderContents containsObject:@".DS_Store"])
        count--;
    if ([folderContents containsObject:@".Trashes"])
        count--;
    
    NSLog(@"final count is: %i\n", count);
    
    if (count <= 1)
        return NO;
    else
        return YES;
}

// Get the list of possible profiles
+ (NSArray *) profilesList
{
    NSString *profilesFile = [[[__FIREFOX_PROFILE_PATH__ stringByExpandingTildeInPath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"profiles.ini"];
    NSLog(@"Attempted path is %@", profilesFile);

    if ([[NSFileManager defaultManager] fileExistsAtPath:profilesFile])
    {
        // Get the contents of the file by line
        //NSArray *values = [[[[NSString alloc] initWithContentsOfFile:profilesFile] componentsSeparatedByString:@"\n"] autorelease];
        NSString* fileContents = [[[NSString alloc] initWithContentsOfFile:profilesFile] autorelease];
        NSArray *values = [fileContents componentsSeparatedByString:@"\n"];
        NSEnumerator *valuesEnum = [values objectEnumerator];
        
        // Find the profile names
        NSString *entry;
        NSMutableArray *profileNames = [NSMutableArray arrayWithCapacity:1];
        
        while (entry = [valuesEnum nextObject])
        {
            NSRange range = [entry rangeOfString:@"Name="];
            if (range.location != NSNotFound)
            {
                NSString *profileName = [entry substringFromIndex:(range.location + range.length)];
                if ([profileName isEqualToString:@"default"])
                    [profileNames insertObject:profileName atIndex:0];
                else
                    [profileNames addObject:profileName];
            }
        }
        
        // Populate our return array
        return [NSArray arrayWithArray:profileNames];
    }

    // Return our array
    return nil;
}

// Get the list of Firefox versions
+ (NSArray *) versionsList
{
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:(NSString*)__APPLICATIONS_PATH__];
    NSMutableArray *versionsTemp = [NSMutableArray arrayWithCapacity:0];
    NSString *curFileFolderName;
    
    while (curFileFolderName = [dirEnum nextObject])
    {
        [dirEnum skipDescendents];
        
        if ([[curFileFolderName lowercaseString] rangeOfString:@"firefox"].location == 0 &&
            [[curFileFolderName lowercaseString] rangeOfString:@".app"].location != NSNotFound)
        {                                  
            [versionsTemp addObject:[curFileFolderName substringToIndex:[[curFileFolderName lowercaseString] rangeOfString:@".app"].location]];
        }
    }

    // Put the mutable values into a non-mutable form
    return [NSArray arrayWithArray:versionsTemp];
}

// Launch Firefox with the selected profile
+ (void) launchFirefox:(NSString *)version withProfile:(NSString *)profile
{
    // Construct the exe path

    NSString *firefoxPath = [self getFirefoxCmd:version];
    NSString *cmd = [[[[firefoxPath stringByAppendingString:@" -no-remote -P "] stringByAppendingString:@"'"] stringByAppendingString:profile] stringByAppendingString:@"' &"];
    NSLog(@"Launching: %@", cmd);

    // Construct and send the shell command
    system([cmd UTF8String]);

    // Exit this application
    exit(0);
}

@end
