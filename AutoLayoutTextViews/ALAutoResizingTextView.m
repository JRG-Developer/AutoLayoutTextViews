//
//  ALAutoResizingTextView.m
//  AutoLayoutTextViews
//
//  Created by Joshua Greene on 7/11/14.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "ALAutoResizingTextView.h"

@implementation ALAutoResizingTextView
@dynamic delegate;

#pragma mark - Object Lifecycle

- (void)commonInit
{
  [super commonInit];
  _minimumHeight = 0.0f;
  _maximumHeight = CGFLOAT_MAX;
}

#pragma mark - View Setup

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  if (!self.heightConstraint) {
    [self findHeightConstraint];
  }
}

- (void)findHeightConstraint
{
  for (NSLayoutConstraint *constraint in self.constraints) {
    if ([self isHeightConstraint:constraint]) {
      self.heightConstraint = constraint;
      if (self.minimumHeight == 0) {
        self.minimumHeight = constraint.constant;
      }
      break;
    }
  }
}

- (BOOL)isHeightConstraint:(NSLayoutConstraint *)constraint
{
  return constraint.firstItem == self && constraint.firstAttribute == NSLayoutAttributeHeight;
}

#pragma mark - Custom Accessors

- (void)setBounds:(CGRect)newBounds
{
  [super setBounds:newBounds];
  [self updateHeightConstraint];
}

- (void)setFrame:(CGRect)frame
{
  [super setFrame:frame];
  [self updateHeightConstraint];
}

- (void)setMaximumHeight:(CGFloat)maximumHeight
{
  _maximumHeight = maximumHeight > 0 ? maximumHeight : CGFLOAT_MAX;
  [self updateHeightConstraint];
}

- (void)setMinimumHeight:(CGFloat)minimumHeight
{
  _minimumHeight = fmaxf(0, minimumHeight);
  [self updateHeightConstraint];
}

#pragma mark - View

- (void)layoutSubviews
{
  [self invalidateIntrinsicContentSize];
  [self setNeedsDisplay];
  [super layoutSubviews];
}

- (void)updateConstraints
{
  [self updateHeightConstraint];
  [super updateConstraints];
}

- (void)updateHeightConstraint
{
  CGFloat oldHeight = self.heightConstraint.constant;
  CGFloat newHeight = [self calculateNewHeight];
  
  if (oldHeight == newHeight) { return; }
  
  self.oldHeight = oldHeight;
  self.newHeight = newHeight;
  
  if (self.newHeight >= self.maximumHeight) {
    [self setScrollEnabled:YES];
    
  } else {
    [self setScrollEnabled:NO];
  }
  
  [self performHeightWillUpdate];
  [self performHeightDidUpdate];
}

- (CGFloat)calculateNewHeight
{
  CGFloat height = [self sizeThatFits:self.frame.size].height;
  
  if (height > self.maximumHeight) {
    height = self.maximumHeight;
    
  } else if (height < self.minimumHeight) {
    height = self.minimumHeight;
  }
  return height;
}

- (void)performHeightWillUpdate
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(textView:willChangeFromHeight:toHeight:)]) {
    [self.delegate textView:self willChangeFromHeight:self.oldHeight toHeight:self.newHeight];
  }
  self.heightConstraint.constant = self.newHeight;
}

- (void)performHeightDidUpdate
{
  if (self.delegate && [self.delegate respondsToSelector:@selector(textView:didChangeFromHeight:toHeight:)]) {
    [self.delegate textView:self didChangeFromHeight:self.oldHeight toHeight:self.newHeight];
  }
}

@end
