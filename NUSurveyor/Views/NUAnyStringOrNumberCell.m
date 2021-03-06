//
//  NUAnyStringOrNumberCell.m
//  NUSurveyor
//
//  Created by Mark Yoon on 3/26/2012.
//  Copyright (c) 2011-2012 Northwestern University. All rights reserved.
//

#import "NUAnyStringOrNumberCell.h"
#import "UILabel+NUResize.h"

@interface NUAnyStringOrNumberCell()
- (void) resetContent;
@end
@implementation NUAnyStringOrNumberCell

@synthesize textField = _textField, label = _label, postLabel = _postLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
    self.textLabel.text = nil;
    
    CGFloat fontSize = [UIFont labelFontSize] - 2;
    UIColor *groupedBackgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.label = [[UILabel alloc] init];
    self.textField = [[UITextField alloc] init];
    self.postLabel = [[UILabel alloc] init];
    
    // (pre) text
    [self.label setUpCellLabelWithFontSize:fontSize];
    self.label.textAlignment = UITextAlignmentRight;
    //  self.label.backgroundColor = [UIColor redColor];
    self.label.backgroundColor = groupedBackgroundColor;
    self.label.autoresizingMask = UIViewAutoresizingNone;
    [self.contentView addSubview:self.label];
    
    // input
    self.textField.font = [UIFont systemFontOfSize:fontSize];
    self.textField.textAlignment = UITextAlignmentLeft;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    //	self.textField.backgroundColor = [UIColor yellowColor];
    self.textField.backgroundColor = groupedBackgroundColor;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.autoresizingMask = UIViewAutoresizingNone;
    self.textField.userInteractionEnabled = NO;
    [self.contentView addSubview:self.textField];
    
    // (post) text
    [self.postLabel setUpCellLabelWithFontSize:fontSize];
    //  self.postLabel.backgroundColor = [UIColor blueColor];
    self.postLabel.backgroundColor = groupedBackgroundColor;;
    self.postLabel.autoresizingMask = UIViewAutoresizingNone;
    [self.contentView addSubview:self.postLabel];
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

#pragma mark - NUCell
- (NSString *)accessibilityLabel{
	return [NSString stringWithFormat:@"NUAnyStringOrNumberCell %@ %@ %@", self.label.text, self.textField.text, self.postLabel.text];
}
- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
	[self resetContent];
	
  // look up existing response, fill in text
	self.sectionTVC = (NUSectionTVC *)tableView.delegate;
  NSManagedObject *existingResponse = [[self.sectionTVC responsesForIndexPath:indexPath] lastObject];
  if (existingResponse) {
    self.textField.text = [existingResponse valueForKey:@"value"];
    [self check];
  } else {
    [self uncheck];
  }

  // (pre) text
  if ([dataObject objectForKey:@"text"] == nil || [[dataObject objectForKey:@"text"] isEqualToString:@""]) {
    [self.label setHidden:YES];
  } else {
    self.label.text = [GRMustacheTemplate renderObject:self.sectionTVC.renderContext
                                            fromString:[dataObject objectForKey:@"text"]
                                                 error:NULL];
  }
  
  // input
	if ([[dataObject objectForKey:@"type"] isEqualToString:@"string"]) {
    // string
    self.textField.delegate = self.sectionTVC;
    self.textField.placeholder = [GRMustacheTemplate renderObject:self.sectionTVC.renderContext
                                                       fromString:[dataObject objectForKey:@"help_text"]
                                                            error:NULL];
  } else if([[dataObject objectForKey:@"type"] isEqualToString:@"integer"] ||
            [[dataObject objectForKey:@"type"] isEqualToString:@"float"]){
    // number
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.textField.delegate = self.sectionTVC;
    self.textField.placeholder = [GRMustacheTemplate renderObject:self.sectionTVC.renderContext
                                                       fromString:[dataObject objectForKey:@"help_text"]
                                                            error:NULL];
  } else {
    [self.textField setHidden:YES];
  }
  
  // (post) text
  if ([dataObject objectForKey:@"post_text"] == nil || [[dataObject objectForKey:@"post_text"] isEqualToString:@""]) {
    [self.postLabel setHidden:YES];
  } else {
    self.postLabel.text = [GRMustacheTemplate renderObject:self.sectionTVC.renderContext
                                                fromString:[dataObject objectForKey:@"post_text"]
                                                     error:NULL];
  }
  
  self.textField.accessibilityLabel = [NSString stringWithFormat:@"NUAnyStringOrNumberCell %@ %@ textField", self.label.text, self.postLabel.text];

}
- (void)selectedinTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
  if ([[self.sectionTVC responsesForIndexPath:indexPath] lastObject]) {
    [self.sectionTVC deleteResponseForIndexPath:indexPath];
    [(NUAnyCell *)[tableView cellForRowAtIndexPath:indexPath] uncheck];

    self.textField.text = nil;
    [self.textField resignFirstResponder]; // This will create a response, which needs to be deleted
    [self.sectionTVC deleteResponseForIndexPath:indexPath];
  } else {
    [(NUAnyCell *)[tableView cellForRowAtIndexPath:indexPath] check];
    if (self.textField.hidden == NO) {
      self.textField.userInteractionEnabled = YES;
      [self.textField becomeFirstResponder];
    }
    [self.sectionTVC newResponseForIndexPath:indexPath];
  }
//  [self.sectionTVC.tableView deselectRowAtIndexPath:indexPath animated:YES];  
}
- (void) resetContent {
  [self.label setHidden:NO];
  [self.textField setHidden:NO];
  [self.postLabel setHidden:NO];
	
  self.label.text = nil;
  self.textField.text = nil;
  self.textField.placeholder = nil;
  self.postLabel.text = nil;
  
  self.textField.keyboardType = UIKeyboardTypeDefault;
  self.textField.returnKeyType = UIReturnKeyDone;
  self.textField.delegate = nil;
}
- (void) layoutSubviews {
  [super layoutSubviews];
  [super layoutSubviews];
  
  CGFloat groupedCellWidth = self.sectionTVC.tableView.frame.size.width - 88.0;
  CGFloat widthPadding = 8;
  CGFloat heightPadding = 8;
	CGFloat height = self.contentView.frame.size.height - heightPadding * 2;
	CGFloat width = groupedCellWidth - 44.0 - widthPadding * 2;
  
  self.label.frame = CGRectMake(44.0 + widthPadding, heightPadding, .2 * width, height);
  self.textField.frame = CGRectMake(44.0 + widthPadding + (.2 * width) + widthPadding, heightPadding, .6 * width - widthPadding, height);
  self.postLabel.frame = CGRectMake(44.0 + widthPadding + (.8 * width), heightPadding, .2 * width, height);
  
  if ([self.label isHidden]) {
    self.textField.frame = CGRectMake(self.label.frame.origin.x, 
                                      self.label.frame.origin.y, 
                                      self.textField.frame.origin.x - self.label.frame.origin.x + self.textField.frame.size.width, 
                                      self.textField.frame.size.height);
  }
  if ([self.postLabel isHidden]) {
    self.textField.frame = CGRectMake(self.textField.frame.origin.x, 
                                      self.textField.frame.origin.y, 
                                      self.postLabel.frame.size.width + self.textField.frame.size.width, 
                                      self.textField.frame.size.height);
  }
  
}


@end
