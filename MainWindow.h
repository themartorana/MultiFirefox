//
//  MainWindow.h
//  MultiFirefox
//
//  Created by David Martorana on 4/7/08.
//  Copyright 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController {
    IBOutlet NSButton *mLaunchButton;
    IBOutlet NSButton *mShowProfileManagerButton;
    
    IBOutlet NSTableView *mProfilesTable;
    IBOutlet NSTableView *mVersionsTable;
    
    IBOutlet NSArrayController *mProfilesController;
    IBOutlet NSArrayController *mVersionsController;
}

- (IBAction) LaunchFirefox:(id)sender;
- (IBAction) ShowProfileManager:(id)sender;
- (IBAction) CreateApplication:(id)sender;

- (NSString *) GetSelectedVersion;

- (void) PopulateVersionValues;
- (void) PopulateProfileValues;

@end
