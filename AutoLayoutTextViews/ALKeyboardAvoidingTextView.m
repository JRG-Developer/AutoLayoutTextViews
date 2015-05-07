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

@interface ALKeyboardAvoidingTextView()
@property (nonatomic, assign) CGFloat bottomConstraintToBottomLayoutGuideConstant;
@end

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

#pragma mark - Custom Accessors

- (void)setBottomConstraintToBottomLayoutGuide:(NSLayoutConstraint *)bottomConstraintToBottomLayoutGuide {
  
  if (_bottomConstraintToBottomLayoutGuide == bottomConstraintToBottomLayoutGuide) {
    return;
  }
  
  _bottomConstraintToBottomLayoutGuide = bottomConstraintToBottomLayoutGuide;
  _bottomConstraintToBottomLayoutGuideConstant = bottomConstraintToBottomLayoutGuide.constant;
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
  [self setBottomConstraintConstant:self.bottomConstraintToBottomLayoutGuideConstant
                      animationInfo:[notification userInfo]
                           animated:![self shouldDrawPlaceholder]];
}

#pragma mark - setBottomConstant: animationInfo: animated:

- (void)setBottomConstraintConstant:(CGFloat)constant animationInfo:(NSDictionary *)info animated:(BOOL)animated
{
  NSAssert(self.bottomConstraintToBottomLayoutGuide,
           @"ALKeyboardAvoidingTextView's `bottomConstraint` is not connected. ALKeyboardAvoidingTextView relies on "
           @"auto layout and will not work if it's disable or if its `bottomConstraint` outlet is not set.");
  
  self.bottomConstraintToBottomLayoutGuide.constant = constant;
  
  if (!animated) {
    [self updateConstraintsIfNeeded];
    return;
  }
  
  [self setNeedsLayout];
  
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [UIView setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [UIView setAnimationBeginsFromCurrentState:YES];
  
  // Warning-- this method is needed to animate scrolling to selection, but this call isn't in the unit tests
  // there's some issues around testing this that I haven't been able to get around... :/ -JRG
  if (!self.selectedTextRange.empty) {
    self.contentOffset = [self caretRectForPosition:self.selectedTextRange.start].origin;
  }
  
  [self layoutIfNeeded];
  
  [UIView commitAnimations];
}

@end
