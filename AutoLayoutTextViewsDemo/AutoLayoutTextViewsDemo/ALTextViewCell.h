//
//  ALTextViewCell.h
//  AutoLayoutTextViewsDemo
//
//  Created by Joshua Greene on 11/4/14.
//  Copyright (c) 2014 App-Order, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AutoLayoutTextViews/ALAutoResizingTextView.h>

@interface ALTextViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet ALAutoResizingTextView *textView;

@end
