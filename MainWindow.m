//
//  MainWindow.m
//  MultiFirefox
//
//  Created by David Martorana on 4/7/08.
//  Copyright 2008. All rights reserved.
//

#import "MainWindow.h"
#import "MFF.h"

@implementation MainWindowController

// Determines if profile list should refresh on window focus
BOOL shouldReloadProfiles = NO;

#pragma mark Standard Methods

-(void) PopulateVersionValues {
    NSArray *versionsArray = [[MFF versionsList] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    [mVersionsController removeObjects:[mVersionsController arrangedObjects]];
    [mVersionsController addObjects:versionsArray];
    [mVersionsController setSelectionIndex:0];
}

-(void) PopulateProfileValues {
    NSArray *profilesArray = [[MFF profilesList] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    [mProfilesController removeObjects:[mProfilesController arrangedObjects]];
    [mProfilesController addObjects:profilesArray];
    [mProfilesController setSelectionIndex:0];
}

#pragma mark Event Handlers

- (void) awakeFromNib
{
    [[self window] setDelegate:self];
    
    // Check to be sure there are multiple profiles
    if (![MFF multipleProfilesExist]){
        [self performSelector:@selector(showNotEnoughProfilesThingy) 
                   withObject:nil 
                   afterDelay:1.0];
    }
    
    [self PopulateProfileValues];
    [self PopulateVersionValues];
    [mVersionsTable setDelegate:self];
    [mVersionsTable setDoubleAction:@selector(LaunchFirefox:)];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* lastVersion = [defaults objectForKey:@"lastVersion"];
    NSString* lastProfile = [defaults objectForKey:@"lastProfile"];
    
    if (lastVersion) {
        [mVersionsController setSelectedObjects:[NSArray arrayWithObject:lastVersion]];    
    }
    if (lastProfile) {
        [mProfilesController setSelectedObjects:[NSArray arrayWithObject:lastProfile]];    
    }
  
}

- (void) showNotEnoughProfilesThingy
{
    NSString *msg = @"You only have one profile set up for Firefox.  In order to run multiple versions of Firefox side by side, you must have multiple profiles defined.\n\nClick OK to open the profile manager.  Once you've set up a seperate multiple profiles, please relaunch MultiFirefox.";
    NSBeginAlertSheet(@"You need to create a profile!", 
                      @"OK", 
                      nil, 
                      nil, 
                      [self window], 
                      self, 
                      @selector(noProfilesOKClick:returnCode:contextInfo:),
                      NULL, 
                      NULL, 
                      msg);    
}

-(IBAction)LaunchFirefox:(id)sender {
    NSString *profileName = (NSString *)[[mProfilesController selectedObjects] objectAtIndex:0];
    //NSString *versionName = (NSString *)[[mVersionsController selectedObject] self];
    NSString *versionName = [self GetSelectedVersion];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:profileName forKey:@"lastProfile"];
    [defaults setObject:versionName forKey:@"lastVersion"];
    [defaults synchronize];
    
    NSLog(@"%@", [profileName stringByAppendingString:versionName]);
    
    [MFF launchFirefox:versionName withProfile:profileName];
}

-(IBAction)ShowProfileManager:(id)sender {
    shouldReloadProfiles = YES;
    [MFF openFirefoxProfilesWindow:[self GetSelectedVersion]];
}

-(IBAction)CreateApplication:(id)sender {
    NSString *profileName = (NSString *)[[mProfilesController selectedObjects] objectAtIndex:0];
    NSString *versionName = [self GetSelectedVersion];

    [MFF createApplicationWithVersion:versionName andProfile:profileName];
}

#pragma mark Common Functions

- (NSString *)GetSelectedVersion
{
    NSString *versionName = (NSString *)[[mVersionsController selectedObjects] objectAtIndex:0];
    return versionName;
}

- (void) SelectProfileForVersion:(NSString *)version {
    // Strip any directory paths
    version = [version lastPathComponent];
    BOOL versionIsPlain = [[version lowercaseString] isEqualToString:@"firefox"];

    // Find the first profile whose name starts with the version name
    NSArray *profiles = [mProfilesController arrangedObjects];
    for (NSString *profile in profiles) {
        if (
            (versionIsPlain && [profile isEqualToString:@"default"]) ||
            [profile hasPrefix:version]
        ) {
            [mProfilesController setSelectedObjects:[NSArray arrayWithObject:profile]];
            break;
        }
    }
}

#pragma mark NSTableView Delegates

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self SelectProfileForVersion:[self GetSelectedVersion]];
}

#pragma mark Window Delegates

- (void)windowWillClose:(NSNotification *)notification {
    [NSApp terminate:self];
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    if (shouldReloadProfiles) {
        NSArray *oldValues = [mProfilesController selectedObjects];
        [self PopulateProfileValues];
        [mProfilesController setSelectedObjects:oldValues];
        shouldReloadProfiles = NO;
    }
}

-(void)noProfilesOKClick:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo{
    [MFF openFirefoxProfilesWindow:[self GetSelectedVersion]];
    [NSApp terminate:self];
}

#pragma mark Application Delegates

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  [[self window] center];
  [[self window] makeKeyAndOrderFront:self];
}

@end
