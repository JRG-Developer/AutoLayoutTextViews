//
//  ALKeyboardAvoidingTestViewTests.m
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

// Test Class
#import "Test_ALKeyboardAvoidingTextView.h"

// Collaborators

// Test Support
#import <AOTestCase/AOTestCase.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

@interface ALKeyboardAvoidingTextViewTests : AOTestCase
@end

@implementation ALKeyboardAvoidingTextViewTests
{
  Test_ALKeyboardAvoidingTextView *sut;
  NSLayoutConstraint *mockConstraint;
}

#pragma mark - Test Lifecycle

- (void)setUp
{
  [super setUp];
  
  mockConstraint = mock([NSLayoutConstraint class]);

  sut = [[Test_ALKeyboardAvoidingTextView alloc] init];
  sut.bottomConstraintToBottomLayoutGuide = mockConstraint;
}

#pragma mark - Given

- (NSNotification *)givenMockNotification
{
  NSNotification *notif = mock([NSNotification class]);
  [given([notif userInfo]) willReturn:[self notificationUserInfo]];
  return notif;
}

- (NSDictionary *)notificationUserInfo
{
  NSMutableDictionary *info = [NSMutableDictionary dictionary];
  info[UIKeyboardAnimationDurationUserInfoKey] = @0.25f;
  info[UIKeyboardAnimationCurveUserInfoKey] = @7;
  info[UIKeyboardFrameEndUserInfoKey] = [NSValue valueWithCGRect:CGRectMake(0, 0, 320, 216)];;  ;
  return [info copy];
}

#pragma mark - Verify

- (void)verifyAnimatesChange:(NSDictionary *)info
{
  [verify(sut.test_viewClass) beginAnimations:nil context:NULL];
  [verify(sut.test_viewClass) setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [verify(sut.test_viewClass) setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [verify(sut.test_viewClass) setAnimationBeginsFromCurrentState:YES];
  [verify(sut.test_viewClass) commitAnimations];
}

- (void)verifyDoesNotAnimateChange:(NSDictionary *)info
{
  [verifyCount(sut.test_viewClass, never()) beginAnimations:nil context:NULL];
  [verifyCount(sut.test_viewClass, never()) setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [verifyCount(sut.test_viewClass, never()) setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [verifyCount(sut.test_viewClass, never()) setAnimationBeginsFromCurrentState:YES];
  [verifyCount(sut.test_viewClass, never()) commitAnimations];
}

#pragma mark - Keyboard Will Show - Tests

- (void)test___keyboardWillShow___setsBottomConstraintConstant_asNegative_ifTextViewIsFirstItemInConstraint
{
  // given
  [given([mockConstraint firstItem]) willReturn:sut];
  NSNotification *notif = [self givenMockNotification];
  NSDictionary *info = [notif userInfo];
  
  CGFloat expected = -1 * CGRectGetHeight([info[UIKeyboardFrameEndUserInfoKey] CGRectValue]);
  
  // when
  [sut keyboardWillShow:notif];
  
  // then
  [verify(sut.bottomConstraintToBottomLayoutGuide) setConstant:expected];
}

- (void)test___keyboardWillShow___setsBottomConstraintConstant_asPositive_ifTextViewIsSecondItemInConstraint
{
  // given
  [given([mockConstraint secondItem]) willReturn:sut];
  NSNotification *notif = [self givenMockNotification];
  NSDictionary *info = [notif userInfo];
  
  CGFloat expected = CGRectGetHeight([info[UIKeyboardFrameEndUserInfoKey] CGRectValue]);
  
  // when
  [sut keyboardWillShow:notif];
  
  // then
  [verify(sut.bottomConstraintToBottomLayoutGuide) setConstant:expected];
}

- (void)test___keyboardWillShow___callsLayoutIfNeeded_givenText
{
  // given
  NSNotification *notif = [self givenMockNotification];
  
  sut.text = @"Text";
  
  // when
  [sut keyboardWillShow:notif];
  
  // then
  assertThatBool(sut.called_layoutIfNeeded, equalToBool(YES));
}

- (void)test___keyboardWillShow___callsLayoutIfNeeded_givenPlaceholderWithoutText
{
  // given
  NSNotification *notif = [self givenMockNotification];
  
  sut.placeholder = @"Placeholder";
  
  // when
  [sut keyboardWillShow:notif];
  
  // then
  assertThatBool(sut.called_layoutIfNeeded, equalToBool(YES));
}

- (void)test___keyboardWillShow___animatesChange_GivenText
{
  // given
  NSNotification *notif = [self givenMockNotification];
  NSDictionary *info = [notif userInfo];
  
  sut.test_viewClass = mockClass([UIView class]);
  sut.text = @"Text";
  
  // when
  [sut keyboardWillShow:notif];
  
  // then
  [self verifyAnimatesChange:info];
}

- (void)test___keyboardWillShow___doesNotAnimateChange_GivenPlaceholderWithoutText
{
  // given
  NSNotification *notif = [self givenMockNotification];
  NSDictionary *info = [notif userInfo];
  
  sut.test_viewClass = mockClass([UIView class]);
  sut.placeholder = @"Placeholder";
  sut.text = nil;
  
  // when
  [sut keyboardWillShow:notif];
  
  // then
  [self verifyDoesNotAnimateChange:info];
}

- (void)test___keyboardWillShow___animatesChange_GivenNoPlaceholderAndNoText
{
  // given
  NSNotification *notif = [self givenMockNotification];
  NSDictionary *info = [notif userInfo];

  sut.test_viewClass = mockClass([UIView class]);
  
  // when
  [sut keyboardWillShow:notif];
  
  // then
  [self verifyAnimatesChange:info];
}

#pragma mark - Keyboard Will Hide Tests

- (void)test___keyboardWillHide___setsBottomConstraintConstantToZero
{
  // given
  [given([mockConstraint secondItem]) willReturn:sut];
  NSNotification *notif = [self givenMockNotification];
  
  CGFloat expected = 0;
  
  // when
  [sut keyboardWillHide:notif];
  
  // then
  [verify(sut.bottomConstraintToBottomLayoutGuide) setConstant:expected];
}

- (void)test___keyboardWillHide___callsLayoutIfNeeded_givenText
{
  // given
  NSNotification *notif = [self givenMockNotification];
  
  sut.text = @"Text";
  
  // when
  [sut keyboardWillHide:notif];
  
  // then
  assertThatBool(sut.called_layoutIfNeeded, equalToBool(YES));
}

- (void)test___keyboardWillHide___callsLayoutIfNeeded_givenPlaceholderWithoutText
{
  // given
  NSNotification *notif = [self givenMockNotification];
  
  sut.placeholder = @"Placeholder";
  sut.text = nil;
  
  // when
  [sut keyboardWillHide:notif];
  
  // then
  assertThatBool(sut.called_layoutIfNeeded, equalToBool(YES));
}

- (void)test___keyboardWillHide___animatesChange_GivenText
{
  // given
  NSNotification *notif = [self givenMockNotification];
  NSDictionary *info = [notif userInfo];
  
  sut.test_viewClass = mockClass([UIView class]);
  sut.text = @"Text";
  
  // when
  [sut keyboardWillHide:notif];
  
  // then
  [self verifyAnimatesChange:info];
}

- (void)test___keyboardWillHide___doesNotAnimateChange_GivenPlaceholderWithoutText
{
  // given
  NSNotification *notif = [self givenMockNotification];
  NSDictionary *info = [notif userInfo];
  
  sut.test_viewClass = mockClass([UIView class]);
  sut.placeholder = @"Placeholder";
  sut.text = nil;
  
  // when
  [sut keyboardWillHide:notif];
  
  // then
  [self verifyDoesNotAnimateChange:info];
}

@end