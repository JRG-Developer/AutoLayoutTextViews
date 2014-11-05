//
//  ALAutoResizingTextViewTableViewController.m
//  AutoLayoutTextViewsDemo
//
//  Created by Anthony Miller on 11/4/14.
//  Copyright (c) 2014 App-Order, LLC. All rights reserved.
//

#import "ALAutoResizingTextViewTableViewController.h"

@implementation ALAutoResizingTextViewTableViewController

- (void)viewDidLoad
{
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 44.0;
}

#pragma mark - ALAutoResizingTextViewDelegate

- (void)textView:(ALAutoResizingTextView *)textView didChangeFromHeight:(CGFloat)oldHeight toHeight:(CGFloat)newHeight
{
  [self.tableView beginUpdates];
  [self.tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.tableView dequeueReusableCellWithIdentifier:@"ALAutoResizingCell" forIndexPath:indexPath];
}

@end
