//
//  QuestionResponse.m
//  surveyor_ios
//
//  Created by Mark Yoon on 7/26/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuestionResponse.h"
#import "UUID.h"

@interface QuestionResponse ()
// http://swish-movement.blogspot.com/2009/05/private-properties-for-iphone-objective.html
@property (nonatomic,retain) UITableViewCell* selectedCell;
@end

@implementation QuestionResponse

// public properties
@synthesize json, UUID, responseSet, answers, pick;
// private properties
@synthesize selectedCell;

- (QuestionResponse *) initWithJson:(NSDictionary *)dict responseSet:(NSManagedObject *)nsmo {
  self = [super init];
  if (self) {
    self.json = dict;
    self.responseSet = nsmo;
//    DLog(@"initWithJson responseSetId: %@", self.responseSetId);
    self.answers = [json valueForKey:@"answers"];
//    DLog(@"%@", self.answers);
    self.pick  = [json valueForKey:@"pick"];
    self.UUID = [json valueForKey:@"uuid"];
//    DLog(@"%@", self.pick);
  }
  return self;
}

#pragma mark -
#pragma mark Core Data

- (NSManagedObject *) responseForAnswer:(NSString *)aid{
//  DLog(@"responseForQuestion %@ answer %@", qid, aid);
  // setup fetch request
	NSError *error = nil;
  NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Response" inManagedObjectContext:[UIAppDelegate managedObjectContext]];
  [request setEntity:entity];
  
  // Set predicate
  NSPredicate *predicate = [NSPredicate predicateWithFormat:
                            @"(responseSet == %@) AND (Question == %@) AND (Answer == %@)", self.responseSet, self.UUID, aid];
  [request setPredicate:predicate];

  NSArray *results = [[UIAppDelegate managedObjectContext] executeFetchRequest:request error:&error];
  if (results == nil)
  {
    /*
     Replace this implementation with code to handle the error appropriately.
     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
     */
    NSLog(@"Unresolved responseForAnswer fetch error %@, %@", error, [error userInfo]);
    abort();
  }
//  DLog(@"responseForAnswer: %@ result: %@", aid, [results lastObject]);
//  DLog(@"responseForAnswer #:%d", [results count]);
  return [results lastObject];
}

- (void) newResponseForAnswer:(NSString *)aid{
  NSManagedObject *newResponse = [NSEntityDescription insertNewObjectForEntityForName:@"Response" inManagedObjectContext:[UIAppDelegate managedObjectContext]];
  [newResponse setValue:self.responseSet forKey:@"responseSet"];
  [newResponse setValue:self.UUID forKey:@"Question"];
  [newResponse setValue:aid forKey:@"Answer"];

  [newResponse setValue:[NSDate date] forKey:@"CreatedAt"];
  [newResponse setValue:[UUID generateUuidString] forKey:@"UUID"];
  
  // Save the context.
  [UIAppDelegate saveContext:@"QuestionResponse newResponseForQuestion"];
  
//  DLog(@"newResponseForQuestion answer: %@", newResponse);
}

#pragma mark -
#pragma mark Picker view data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
  return 1;
}

#pragma mark -
#pragma mark Picker view delegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
  return [answers count];
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
  UILabel *pickerRow = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
  pickerRow.backgroundColor = [UIColor clearColor];
  pickerRow.font = [UIFont systemFontOfSize:16.0];
  pickerRow.text = [[answers objectAtIndex:row] objectForKey:@"text"];
  return pickerRow;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return [answers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  static NSString *CellIdentifier = @"CheckboxCellIdentifier";
  
  // Dequeue or create a cell of the appropriate type.
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:[pick isEqual:@"one"] ? @"undotted" : @"unchecked.png"];
  }
  
  NSManagedObject *existingResponse = [self responseForAnswer:[[answers objectAtIndex:[indexPath row]] valueForKey:@"uuid"]];
  if (existingResponse) {
    DLog(@"tableViewcellForRowAtIndexPath: %@", existingResponse);
    cell.imageView.image = [UIImage imageNamed:[pick isEqual:@"one"] ? @"dotted" : @"checked.png"];
    selectedCell = cell;
  }
  
  // Configure the cell.
  //  cell.textLabel.text = [NSString stringWithFormat:@"Row %d", indexPath.row];
  
  cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
  cell.textLabel.text = [[answers objectAtIndex:indexPath.row] objectForKey:@"text"];
  //	cell.textLabel.text = @"foo";
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [aTableView cellForRowAtIndexPath:indexPath];
  if ([@"one" isEqual:pick]) {
    if (selectedCell) {
      selectedCell.imageView.image = [UIImage imageNamed:@"undotted.png"];
      NSManagedObject *existingResponse = [self responseForAnswer:[[answers objectAtIndex:[[aTableView indexPathForCell:selectedCell] row]] valueForKey:@"uuid"]];
      if (existingResponse) {
        DLog(@"tableViewdidSelectRowAtIndexPath removing: %@", existingResponse);
        [UIAppDelegate.managedObjectContext deleteObject:existingResponse];
        // Save the context.
        [UIAppDelegate saveContext:@"tableViewdidSelectRowAtIndexPath removing"];
      }
    }
    cell.imageView.image = [UIImage imageNamed:@"dotted.png"];
    selectedCell = cell;
    
    [self newResponseForAnswer:[[answers objectAtIndex:[indexPath row]] valueForKey:@"uuid"]];
    
  } else {
    Boolean checked = cell.imageView.image == [UIImage imageNamed:@"checked.png"];  
    cell.imageView.image = checked ? [UIImage imageNamed:@"unchecked.png"] : [UIImage imageNamed:@"checked.png"];
  }
}

@end
