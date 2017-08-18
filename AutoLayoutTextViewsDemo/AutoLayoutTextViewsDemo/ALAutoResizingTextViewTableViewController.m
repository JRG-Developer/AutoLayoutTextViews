//
//  ALAutoResizingTextViewTableViewController.m
//  AutoLayoutTextViewsDemo
//
//  Created by Anthony Miller on 11/4/14.
//  Copyright (c) 2014 App-Order, LLC. All rights reserved.
//

#import "ALAutoResizingTextViewTableViewController.h"
#import "ALTextViewCell.h"

@implementation ALAutoResizingTextViewTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];  
  [self configureTableView];
}

- (void)configureTableView
{
  self.tableView.estimatedRowHeight = 44.0;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.tableFooterView = [[UIView alloc] init];
}

#pragma mark - ALAutoResizingTextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  
  return YES;
}

- (void)textView:(ALAutoResizingTextView *)textView didChangeFromHeight:(CGFloat)oldHeight toHeight:(CGFloat)newHeight {
  
  [UIView setAnimationsEnabled:NO];
  
  [self.tableView beginUpdates];
  [self.tableView endUpdates];

  // For some reason, on iOS 10.3.1 (or may be 10.0 and newer?), must call these TWICES...
  // if only called once, the constraint changes don't get applied for some reason... seems like an Apple bug. :/
  
  // This works fine on iOS 9.X versions, where or not there's 2 calls or just 1 to this method pair.
  [self.tableView beginUpdates];
  [self.tableView endUpdates];
  
  [UIView setAnimationsEnabled:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  ALTextViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ALTextViewCell" forIndexPath:indexPath];
  cell.textView.tag = indexPath.row;
  
  if (indexPath.row == 0) {
    cell.textView.placeholder = @"Please describe where the incident happened";
    
  } else if (indexPath.row == 1) {
    cell.textView.placeholder = @"This placeholder is just a little too long!";
  } else {
    cell.textView.placeholder = nil;
  }
  return cell;
}

@end
