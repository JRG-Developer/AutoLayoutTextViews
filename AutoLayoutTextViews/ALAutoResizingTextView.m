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

#pragma mark - Object Lifecycle

- (void)commonInit
{
  [super commonInit];
  
  _minimumHeight = 0.0f;
  _maximumHeight = CGFLOAT_MAX;
  _autoresizingAnimationDuration = 0.2f;
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
      break;
    }
  }
}

- (BOOL)isHeightConstraint:(NSLayoutConstraint *)constraint
{
  return constraint.firstItem == self && constraint.firstAttribute == NSLayoutAttributeHeight;
}

#pragma mark - Custom Accessors

- (void)setMaximumHeight:(CGFloat)maximumHeight
{
  _maximumHeight = maximumHeight > 0 ? maximumHeight : CGFLOAT_MAX;
  [self setNeedsDisplay];
}

-(void)setMinimumHeight:(CGFloat)minimumHeight
{
  _minimumHeight = minimumHeight > 0 ? minimumHeight : 0;
  [self setNeedsDisplay];
}

#pragma mark - View

- (void)layoutSubviews
{
#ifdef DEBUG
  NSAssert(self.heightConstraint, @"ALAutoResizingTextView is missing a height constraint. ALAutoResizingTextView "
           @"relies on auto layout and will not work if its `heightConstraint` is not set.");
#endif
  
  [super layoutSubviews];
  [self needsUpdateConstraints];
}

- (void)updateConstraints
{
  [super updateConstraints];
  [self updateHeightConstraint];
}


- (void)updateHeightConstraint
{
  self.oldHeight = self.heightConstraint.constant;
  self.newHeight = [self calculateNewHeight];
  
  if (![self didHeightChange]) {
    return;
  }
  
  if ([self shouldAnimateHeightChange]) {
    [self animateHeightChange];
    
  } else {
    [self setNewHeightWithoutAnimation];
  }
}

- (CGFloat)calculateNewHeight
{
  CGSize size = [self sizeThatFits:self.frame.size];
  CGFloat height = size.height + self.contentInset.top;
  
  height = fminf(height, self.maximumHeight);
  height = fmaxf(height, self.minimumHeight);
  
  return height;
}

- (BOOL)didHeightChange
{
  return self.newHeight != self.oldHeight;
}

- (BOOL)shouldAnimateHeightChange
{
  return self.autoresizingAnimationDuration > 0;
}

- (void)animateHeightChange
{
  [[self viewClass] animateWithDuration:self.autoresizingAnimationDuration
                                  delay:0.0f
                                options:UIViewAnimationOptionAllowUserInteraction |
   UIViewAnimationOptionBeginFromCurrentState
                             animations:[self animationBlock]
                             completion:[self completionBlock]];
}

- (void)setNewHeightWithoutAnimation
{
  [self animationBlock]();
  [self completionBlock](YES);
}

- (void (^)())animationBlock
{
  return  ^{
    if ([self.delegate respondsToSelector:@selector(textView:willChangeFromHeight:toHeight:)]) {
      [self.delegate textView:self willChangeFromHeight:self.oldHeight toHeight:self.newHeight];
    }
    self.heightConstraint.constant = self.newHeight;
  };
}

- (void(^)(BOOL))completionBlock
{
  return ^(BOOL finished) {
    if ([self.delegate respondsToSelector:@selector(textView:didChangeFromHeight:toHeight:)]) {
      [self.delegate textView:self didChangeFromHeight:self.oldHeight toHeight:self.newHeight];
    }
  };
}

@end
