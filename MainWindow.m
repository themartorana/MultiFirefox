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

// Set the value
BOOL alreadyChecked = NO;

#pragma mark Standard Methods

-(void) PopulateVersionValues{
    NSArray *versionsArray = [MFF versionsList];
    [mVersionsController addObjects:versionsArray];
    [mVersionsController setSelectionIndex:0];
}

-(void) PopulateProfileValues{
    NSArray *profilesArray = [MFF profilesList];
    [mProfilesController addObjects:profilesArray];
    [mProfilesController setSelectionIndex:0];
}

#pragma mark Event Handlers

- (void) awakeFromNib
{
    // Check to be sure there are multiple profiles
    if (![MFF multipleProfilesExist]){
        [self performSelector:@selector(showNotEnoughProfilesThingy) 
                   withObject:nil 
                   afterDelay:1.0];
    }
    
    [self PopulateProfileValues];
    [self PopulateVersionValues];
    
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
    [MFF openFirefoxProfilesWindow:[self GetSelectedVersion]];
}

#pragma mark Common Functions

- (NSString *)GetSelectedVersion
{
    NSString *versionName = (NSString *)[[mVersionsController selectedObjects] objectAtIndex:0];
    return versionName;
}

#pragma mark Window Delegates

- (BOOL)windowWillClose:(NSNotification *)notification {
    [NSApp terminate:self];
    return NO;
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
