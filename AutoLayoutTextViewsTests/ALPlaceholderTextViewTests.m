//
//  ALPlaceholderTextViewTests.m
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
#import "Test_ALPlaceholderTextView.h"

// Collaborators

// Test Support
#import <XCTest/XCTestCase.h>

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>

#import <OCMock/OCMock.h>

@interface ALPlaceholderTextViewTests : XCTestCase
@end

@implementation ALPlaceholderTextViewTests
{
  Test_ALPlaceholderTextView *sut;
  
  id mockPlaceholder;
  id notificationCenter;
}

#pragma mark - Test Lifecycle

- (void)setUp
{
  [super setUp];
  
  notificationCenter = OCMPartialMock([NSNotificationCenter defaultCenter]);
  sut = [[Test_ALPlaceholderTextView alloc] initWithFrame:CGRectZero];
}

- (void)tearDown
{
  [notificationCenter stopMocking];
  [super tearDown];
}

#pragma mark - Utilities

- (void)givenMockPlaceholder
{
  mockPlaceholder = OCMClassMock([NSString class]);
  OCMStub([mockPlaceholder length]).andReturn(1);
  OCMStub([mockPlaceholder copy]).andReturn(mockPlaceholder);
  sut.placeholder = mockPlaceholder;
}

#pragma mark - Tests

- (void)test___init___calls___commonInit
{
  expect(sut.called_commonInit).to.beTruthy();
}

- (void)test___initWithCoder___calls___commonInit
{
  NSCoder *coder = nil;
  
  // when
  sut = [[Test_ALPlaceholderTextView alloc] initWithCoder:coder];
  
  // then
  expect(sut.called_commonInit).to.beTruthy();
}

- (void)test_placeholderIsNilByDefault
{
  expect(sut.placeholder).to.beNil();
}

- (void)test_placeholderColorIsLightGrayColorByDefault
{
  expect(sut.placeholderColor).to.equal([UIColor lightGrayColor]);
}

- (void)test_placeholderInsetsSetToCorrectDefaultValue
{
  // given
  UIEdgeInsets expected = UIEdgeInsetsMake(8.0f, 4.0f, 8.0f, 0.0f);
  
  // when
  UIEdgeInsets actual = sut.placeholderInsets;
  
  // then
  expect(UIEdgeInsetsEqualToEdgeInsets(actual, expected)).to.beTruthy();
}

- (void)test_observes_UITextViewTextDidChangeNotification
{
  OCMVerify([notificationCenter addObserver:sut
                                   selector:@selector(textDidChange:)
                                       name:UITextViewTextDidChangeNotification
                                     object:sut]);
}

- (void)test_observes_UIApplicationDidChangeStatusBarOrientationNotification
{
  OCMVerify([notificationCenter addObserver:sut
                                   selector:@selector(textDidChange:)
                                       name:UIApplicationDidChangeStatusBarOrientationNotification
                                     object:nil]);
}

- (void)test_observes_UIKeyboardWillShowNotification
{
  OCMVerify([notificationCenter addObserver:sut
                                   selector:@selector(keyboardWillShow:)
                                       name:UIKeyboardWillShowNotification
                                     object:nil]);
}

- (void)test_observes_UIKeyboardWillHideNotification
{
  OCMVerify([notificationCenter addObserver:sut
                                   selector:@selector(keyboardWillHide:)
                                       name:UIKeyboardWillHideNotification
                                     object:nil]);
}

- (void)test___textDidChange__calls___setNeedsDisplay
{
  // when
  NSNotification *notification = nil;
  [sut textDidChange:notification];
  
  // then
  expect(sut.called_setNeedsDisplay).to.beTruthy();
}

- (void)test___keyboardWillShow___calls___setNeedsDisplay
{
  // when
  NSNotification *notification = nil;
  [sut keyboardWillShow:notification];
  
  // then
  expect(sut.called_setNeedsDisplay).to.beTruthy();
}

- (void)test___keyboardWillHide___calls___setNeedsDisplay
{
  // when
  NSNotification *notification = nil;
  [sut keyboardWillHide:notification];
  
  // then
  expect(sut.called_setNeedsDisplay).to.beTruthy();
}

- (void)test___setText___calls___setsNeedsDisplay {
  
  // when
  [sut setNeedsDisplay];
  
  // then
  expect(sut.called_setNeedsDisplay).to.beTruthy();
}

- (void)test__sizeThatFits__givenLongerPlaceholderTextThanContentText_returnsSizeWithHeightFittingPlaceholder
{
  // given
  sut.placeholder = @"Long Placeholder Text Long Placeholder Text Long Placeholder Text Long Placeholder Text Long Placeholder Text Long Placeholder Text";
  
  // when
  CGSize actual = [sut sizeThatFits:CGSizeMake(50.0f, 50.0f)];
  
  // then
  expect(actual.height).to.beGreaterThan(30.0f);
}

- (void)test___drawRect___returnsNO_ifHasText
{
  // given
  sut.text = @"Some text";
  BOOL expected = NO;
  
  // when
  BOOL actual = [sut shouldDrawPlaceholder];
  
  // then
  expect(actual).to.equal(expected);
}

- (void)test___drawRect___returnsNO_ifPlaceholderLengthIsZero
{
  // given
  sut.placeholder = @"";
  BOOL expected = NO;
  
  // when
  BOOL actual = [sut shouldDrawPlaceholder];
  
  // then
  expect(actual).to.equal(expected);
}

- (void)test___drawRect___givenTextDoesNotDrawPlaceholder
{
  // given
  [self givenMockPlaceholder];
  sut.text = @"Some Text";
  CGRect rect = CGRectMake(0.0f, 0.0f, 320.0f, 50.0f);
  
  [[[mockPlaceholder reject] ignoringNonObjectArgs] drawInRect:rect withAttributes:[OCMArg any]];
  
  // when
  [sut drawRect:rect];
  
  // then
  OCMVerifyAll(mockPlaceholder);
}

- (void)test___drawRect___drawsPlaceholder
{
  // given
  [self givenMockPlaceholder];
  sut.text = nil;
  CGRect rect = CGRectMake(0.0f, 0.0f, 320.0f, 50.0f);
  
  // when
  [sut drawRect:rect];
  CGRect placeholderRect = [sut calculatePlaceholderRectInsetInRect:rect];
  
  // then
  OCMVerify([mockPlaceholder drawInRect:placeholderRect withAttributes:[OCMArg any]]);
}

@end
