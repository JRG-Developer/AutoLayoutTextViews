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
#import <XCTest/XCTestCase.h>

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>

#import <OCMock/OCMock.h>

@interface ALKeyboardAvoidingTextView()
@property (nonatomic, assign) CGFloat bottomConstraintToBottomLayoutGuideConstant;
@end

@interface ALKeyboardAvoidingTextViewTests : XCTestCase
@end

@implementation ALKeyboardAvoidingTextViewTests
{
  Test_ALKeyboardAvoidingTextView *sut;
  
  CGFloat constant;
  
  id partialMock;
  id mockBottomConstraint;
  id mockNotification;
  id viewClass;
  
  UIView *superview;
  NSMutableDictionary *userInfo;
}

#pragma mark - Test Lifecycle

- (void)setUp
{
  [super setUp];
  
  sut = [[Test_ALKeyboardAvoidingTextView alloc] init];
  [self givenMockBottomConstraintWithConstant:0];
}

- (void)tearDown
{
  [mockBottomConstraint stopMocking];
  [mockNotification stopMocking];
  [partialMock stopMocking];
  [viewClass stopMocking];
  
  [super tearDown];
}

#pragma mark - Given

- (void)givenAddedToSuperview
{
  superview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 480.0f)];
  [superview addSubview:sut];
}

- (void)givenMockNotification
{
  [self givenNotificationUserInfo];
  
  mockNotification = OCMClassMock([NSNotification class]);
  OCMStub([mockNotification userInfo]).andReturn(userInfo);
}

- (void)givenNotificationUserInfo
{
  userInfo = [NSMutableDictionary dictionary];
  userInfo[UIKeyboardAnimationDurationUserInfoKey] = @0.25f;
  userInfo[UIKeyboardAnimationCurveUserInfoKey] = @7;
  userInfo[UIKeyboardFrameEndUserInfoKey] = [NSValue valueWithCGRect:CGRectMake(0, 0, 320, 216)];
}

#pragma mark - Given - Mocks

- (void)givenMockBottomConstraintWithConstant:(CGFloat)expected {

  [mockBottomConstraint stopMocking];
  
  mockBottomConstraint = OCMClassMock([NSLayoutConstraint class]);
  OCMStub([(NSLayoutConstraint *)mockBottomConstraint constant]).andReturn(expected);
  
  sut.bottomConstraintToBottomLayoutGuide = mockBottomConstraint;
}

- (void)givenViewClass
{
  viewClass = OCMClassMock([UIView class]);
}

- (void)expectAnimatesChange:(NSDictionary *)info
{
  [self givenViewClass];
  OCMExpect([viewClass beginAnimations:nil context:NULL]);
  OCMExpect([viewClass setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]]);
  OCMExpect([viewClass setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]]);
  OCMExpect([viewClass setAnimationBeginsFromCurrentState:YES]);
  OCMExpect([viewClass commitAnimations]);
}

- (void)expectDoesNotAnimateChange:(NSDictionary *)info
{
  [self givenViewClass];
  [[viewClass reject] beginAnimations:nil context:NULL];
  [[viewClass reject] setAnimationDuration:[info[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
  [[viewClass reject] setAnimationCurve:[info[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
  [[viewClass reject] setAnimationBeginsFromCurrentState:YES];
  [[viewClass reject] commitAnimations];
}

- (void)givenPartialMock {
  partialMock = OCMPartialMock(sut);
}

#pragma mark - View - Tests

- (void)test___awakeFromNib___sets_bottomConstraint_fromSuperViewConstraints_whenBottomConstraintIsFoundBy_firstItem
{
  // given
  [self givenAddedToSuperview];
  sut.bottomConstraintToBottomLayoutGuide = nil;
  
  [superview addConstraint:[NSLayoutConstraint constraintWithItem:sut
                                                       attribute:NSLayoutAttributeBottom
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:superview
                                                       attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0f
                                                         constant:0.0f]];
  // when
  [sut awakeFromNib];
  
  // then
  expect(sut.bottomConstraintToBottomLayoutGuide).toNot.beNil();
}

- (void)test___awakeFromNib___sets_bottomConstraint_fromSuperViewConstraints_whenBottomConstraintIsFoundBy_secondItem
{
  // given
  [self givenAddedToSuperview];
  sut.bottomConstraintToBottomLayoutGuide = nil;
  
  [superview addConstraint:[NSLayoutConstraint constraintWithItem:superview
                                                        attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:sut
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0f
                                                         constant:0.0f]];
  // when
  [sut awakeFromNib];
  
  // then
  expect(sut.bottomConstraintToBottomLayoutGuide).toNot.beNil();
}

#pragma mark - Custom Accessors - Tests

- (void)test___setBottomConstraintToBottomLayoutGuide___setsbottomConstraintToBottomLayoutGuideConstant {
  
  // given
  CGFloat expected = 42;

  [self givenMockBottomConstraintWithConstant:expected];
  
  // then
  expect(sut.bottomConstraintToBottomLayoutGuideConstant).to.equal(expected);
}

#pragma mark - Keyboard Will Show - Tests

- (void)test___keyboardWillShow___setsBottomConstraintConstant_asNegative_ifTextViewIsFirstItemInConstraint
{
  // given
  OCMStub([mockBottomConstraint firstItem]).andReturn(sut);
  
  [self givenMockNotification];
  CGFloat expected = -1 * CGRectGetHeight([userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]);
  
  // when
  [sut keyboardWillShow:mockNotification];
  
  // then
  OCMVerify([mockBottomConstraint setConstant:expected]);
}

- (void)test___keyboardWillShow___setsBottomConstraintConstant_asPositive_ifTextViewIsSecondItemInConstraint
{
  // given
  OCMStub([mockBottomConstraint secondItem]).andReturn(sut);

  [self givenMockNotification];
  CGFloat expected = CGRectGetHeight([userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue]);
  
  // when
  [sut keyboardWillShow:mockNotification];
  
  // then
  OCMVerify([mockBottomConstraint setConstant:expected]);
}

- (void)test___keyboardWillShow___callsLayoutIfNeeded_givenText
{
  // given
  [self givenMockNotification];
  
  sut.text = @"Text";
  
  // when
  [sut keyboardWillShow:mockNotification];
  
  // then
  expect(sut.called_layoutIfNeeded).to.beTruthy();
}

- (void)test___keyboardWillShow___callsUpdateConstraintsIfNeeded_givenPlaceholderWithoutText
{
  // given
  [self givenMockNotification];
  
  sut.placeholder = @"Placeholder";
  sut.text = nil;
  
  // when
  [sut keyboardWillShow:mockNotification];
  
  // then
  expect(sut.called_updateConstraintsIfNeeded).to.beTruthy();
  expect(sut.called_layoutIfNeeded).to.beFalsy();
}

- (void)test___keyboardWillShow___animatesChange_GivenText
{
  // given
  [self givenMockNotification];
  [self expectAnimatesChange:userInfo];
  sut.text = @"Text";
  
  // when
  [sut keyboardWillShow:mockNotification];
  
  // then
  OCMVerifyAll(viewClass);
}

- (void)test___keyboardWillShow___doesNotAnimateChange_GivenPlaceholderWithoutText
{
  // given
  [self givenMockNotification];
  [self expectDoesNotAnimateChange:userInfo];
  
  sut.placeholder = @"Placeholder";
  sut.text = nil;
  
  // when
  [sut keyboardWillShow:mockNotification];
  
  // then
  OCMVerifyAll(viewClass);
}

- (void)test___keyboardWillShow___animatesChange_GivenNoPlaceholderAndNoText
{
  // given
  [self givenMockNotification];
  [self expectAnimatesChange:userInfo];
  
  // when
  [sut keyboardWillShow:mockNotification];
  
  // then
  OCMVerifyAll(viewClass);
}

#pragma mark - Keyboard Will Hide Tests

- (void)test___keyboardWillHide___setsBottomConstraintConstantToStoredValue
{
  // given
  CGFloat expected = 42;
  sut.bottomConstraintToBottomLayoutGuideConstant = expected;
  
  OCMStub([mockBottomConstraint secondItem]).andReturn(sut);

  [self givenMockNotification];
  
  // when
  [sut keyboardWillHide:mockNotification];
  
  // then
  OCMVerify([mockBottomConstraint setConstant:expected]);
}

- (void)test___keyboardWillHide___callsLayoutIfNeeded_givenText
{
  // given
  [self givenMockNotification];
  
  sut.text = @"Text";
  
  // when
  [sut keyboardWillHide:mockNotification];
  
  // then
  expect(sut.called_layoutIfNeeded).to.beTruthy();
}

- (void)test___keyboardWillHide___callsUpdateConstraintsIfNeeded_givenPlaceholderWithoutText
{
  // given
  [self givenMockNotification];
  
  sut.placeholder = @"Placeholder";
  sut.text = nil;
  
  // when
  [sut keyboardWillHide:mockNotification];
  
  // then
  expect(sut.called_updateConstraintsIfNeeded).to.beTruthy();
  expect(sut.called_layoutIfNeeded).to.beFalsy();
}

- (void)test___keyboardWillHide___animatesChange_GivenText
{
  // given
  [self givenMockNotification];
  [self expectAnimatesChange:userInfo];
  
  sut.text = @"Text";
  
  // when
  [sut keyboardWillHide:mockNotification];
  
  // then
  OCMVerifyAll(viewClass);
}

- (void)test___keyboardWillHide___doesNotAnimateChange_GivenPlaceholderWithoutText
{
  // given
  [self givenMockNotification];
  [self expectDoesNotAnimateChange:userInfo];
  
  sut.placeholder = @"Placeholder";
  sut.text = nil;
  
  // when
  [sut keyboardWillHide:mockNotification];
  
  // then
  OCMVerifyAll(viewClass);
}

@end
