//
//  NUAppDelegate.h
//  NUSurveyoriOS
//
//  Created by Mark Yoon on 1/23/2012.
//  Copyright (c) 2012 Northwestern University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NUSpyVC.h"

@interface NUAppDelegate : UIResponder <UIApplicationDelegate, NUSpyVCDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)inspect;
- (void) loadSurvey:(NSString *)pathforResource;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) UISplitViewController *splitViewController;
@property (strong, nonatomic) NUSpyVC *spyVC;

@end
