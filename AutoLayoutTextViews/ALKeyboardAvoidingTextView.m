//
//  ALKeyboardAvoidingTextView.m
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

#import "ALKeyboardAvoidingTextView.h"

@implementation ALKeyboardAvoidingTextView

#pragma mark - View Setup

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  if (!self.bottomConstraintToBottomLayoutGuide) {
    [self findBottomConstraint];
  }
}

- (void)findBottomConstraint
{
  for (NSLayoutConstraint *constraint in self.superview.constraints) {
    if ([self isBottomConstraint:constraint]) {
      self.bottomConstraintToBottomLayoutGuide = constraint;
      break;
    }
  }
}

- (BOOL)isBottomConstraint:(NSLayoutConstraint *)constraint
{
  return  [self firstItemMatchesBottomConstraint:constraint] ||
  [self secondItemMatchesBottomConstraint:constraint];
}

- (BOOL)firstItemMatchesBottomConstraint:(NSLayoutConstraint *)constraint
{
  return constraint.firstItem == self && constraint.firstAttribute == NSLayoutAttributeBottom;
}

- (BOOL)secondItemMatchesBottomConstraint:(NSLayoutConstraint *)constraint
{
  return constraint.secondItem == self && constraint.secondAttribute == NSLayoutAttributeBottom;
}

#pragma mark - Notifications

#pragma mark - keyboardWillShow:

- (void)keyboardWillShow:(NSNotification *)notification
{
  [super keyboardWillShow:notification];
  
  CGFloat constant = [self bottomConstantFromNotification:notification];
  [self setBottomConstraintConstant:constant animationInfo:[notification userInfo] animated:![self shouldDrawPlaceholder]];
}

- (CGFloat)bottomConstantFromNotification:(NSNotification *)notification
{
  CGRect keyboardFrame = [self keyboardFrameFromNotification:notification];
  return CGRectGetHeight(keyboardFrame) * [self constraintConstantMultiplier];
}

- (CGRect)keyboardFrameFromNotification:(NSNotification *)notification
{
  NSDictionary *info = [notification userInfo];
  CGRect keyboardFrame = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  keyboardFrame = [self convertRect:keyboardFrame fromView:nil];
  return keyboardFrame;
}

- (CGFloat)constraintConstantMultiplier
{
  return self.bottomConstraintToBottomLayoutGuide.firstItem == self ? -1 : 1;
}

#pragma mark - keyboardWillHide:

- (void)keyboardWillHide:(NSNotification *)notification
{
  [super keyboardWillHide:notification];
  [self setBottomConstraintConstant:0 animationInfo:[notification userInfo] animated:![self shouldDrawPlaceholder]];
}

#pragma mark - setBottomConstant: animationInfo: animated:

- (void)setBottomConstraintConstant:(CGFloat)constant animationInfo:(NSDictionary *)info animated:(BOOL)animated
{
#ifdef DEBUG
  NSAssert(self.bottomConstraintToBottomLayoutGuide,
           @"ALKeyboardAvoidingTextView's `bottomConstraint` is not connected. ALKeyboardAvoidingTextView relies on "
           @"auto layout and will not work if it's disable or if its `bottomConstraint` outlet is not set.");
#endif
  
  self.bottomConstraintToBottomLayoutGuide.constant = constant;
  
  if (!animated) {
    [self layoutIfNeeded];
    return;
  }
  
  [[self viewClass] beginAnimations:nil context:NULL];
  [[self viewClass] setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [[self viewClass] setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [[self viewClass] setAnimationBeginsFromCurrentState:YES];
  [self layoutIfNeeded];
  [[self viewClass] commitAnimations];
}

@end
