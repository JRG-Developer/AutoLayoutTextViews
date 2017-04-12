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

- (void)textViewDidChange:(UITextView *)textView {
  CGPoint contentOffset = self.tableView.contentOffset;
  [UIView setAnimationsEnabled:NO];
  [self.tableView beginUpdates];
  [self.tableView endUpdates];
  [self.tableView setContentOffset:contentOffset animated:NO];
  
  CGRect rect = [self.tableView convertRect:textView.bounds fromView:textView];  
  [self.tableView scrollRectToVisible:rect animated:NO];
  
  [UIView setAnimationsEnabled:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return [self.tableView dequeueReusableCellWithIdentifier:@"ALTextViewCell" forIndexPath:indexPath];
}

@end
