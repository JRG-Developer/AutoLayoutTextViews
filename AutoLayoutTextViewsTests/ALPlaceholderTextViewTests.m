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
#import <AOTestCase/AOTestCase.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

@interface ALPlaceholderTextViewTests : AOTestCase
@end

@implementation ALPlaceholderTextViewTests
{
  Test_ALPlaceholderTextView *sut;
}

#pragma mark - Test Lifecycle

- (void)setUp
{
  [super setUp];
  sut = [[Test_ALPlaceholderTextView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Utilities

- (void)givenMockPlaceholder
{
  NSString *mockPlaceholder = mock([NSString class]);
  [given([mockPlaceholder length]) willReturnInt:1];
  [given([mockPlaceholder copy]) willReturn:mockPlaceholder];
  
  sut.placeholder = mockPlaceholder;
}

#pragma mark - Tests

- (void)test___init___calls___commonInit
{
  assertThatBool(sut.called_commonInit, equalToBool(YES));
}

- (void)test___initWithCoder___calls___commonInit
{
  // when
  sut = [[Test_ALPlaceholderTextView alloc] initWithCoder:nil];
  
  // then
  assertThatBool(sut.called_commonInit, equalToBool(YES));
}

- (void)test_placeholderIsNilByDefault
{
  assertThat(sut.placeholder, nilValue());
}

- (void)test_placeholderColorIsLightGrayColorByDefault
{
  assertThat(sut.placeholderColor, equalTo([UIColor lightGrayColor]));
}

- (void)test_placeholderInsetsSetToCorrectDefaultValue
{
  // given
  UIEdgeInsets expected = UIEdgeInsetsMake(8.0f, 4.0f, 0.0f, 0.0f);
  
  // when
  UIEdgeInsets actual = sut.placeholderInsets;
  
  // then
  assertThatBool(UIEdgeInsetsEqualToEdgeInsets(actual, expected), equalToBool(YES));;
}

- (void)test_observes_UITextViewTextDidChangeNotification
{
  [verify(sut.mockNotificationCenter) addObserver:sut
                                         selector:@selector(textDidChange:)
                                             name:UITextViewTextDidChangeNotification
                                           object:sut];
}

- (void)test_observes_UIApplicationDidChangeStatusBarOrientationNotification
{
  [verify(sut.mockNotificationCenter) addObserver:sut
                                         selector:@selector(textDidChange:)
                                             name:UIApplicationDidChangeStatusBarOrientationNotification
                                           object:nil];
}

- (void)test_observes_UIKeyboardWillShowNotification
{
  [verify(sut.mockNotificationCenter) addObserver:sut
                                         selector:@selector(keyboardWillShow:)
                                             name:UIKeyboardWillShowNotification
                                           object:nil];
}

- (void)test_observes_UIKeyboardWillHideNotification
{
  [verify(sut.mockNotificationCenter) addObserver:sut
                                         selector:@selector(keyboardWillHide:)
                                             name:UIKeyboardWillHideNotification
                                           object:nil];
}

- (void)test___textDidChange__calls___setNeedsDisplay
{
  // when
  [sut textDidChange:nil];
  
  // then
  assertThatBool(sut.called_setNeedsDisplay, equalToBool(YES));
}

- (void)test___keyboardWillShow___calls___setNeedsDisplay
{
  // when
  [sut keyboardWillShow:nil];
  
  // then
  assertThatBool(sut.called_setNeedsDisplay, equalToBool(YES));
}

- (void)test___keyboardWillHide___calls___setNeedsDisplay
{
  // when
  [sut keyboardWillHide:nil];
  
  // then
  assertThatBool(sut.called_setNeedsDisplay, equalToBool(YES));
}

- (void)test___drawRect___returnsNO_ifHasText
{
  // given
  sut.text = @"Some text";
  BOOL expected = NO;
  
  // when
  BOOL actual = [sut shouldDrawPlaceholder];
  
  // then
  assertThatBool(actual, equalToBool(expected));
}

- (void)test___drawRect___returnsNO_ifPlaceholderLengthIsZero
{
  // given
  sut.placeholder = @"";
  BOOL expected = NO;
  
  // when
  BOOL actual = [sut shouldDrawPlaceholder];
  
  // then
  assertThatBool(actual, equalToBool(expected));
}

- (void)test___drawRect___givenTextDoesNotDrawPlaceholder
{
  // given
  [self givenMockPlaceholder];
  sut.text = @"Some Text";
  CGRect rect = CGRectMake(0.0f, 0.0f, 320.0f, 50.0f);
  
  // when
  [sut drawRect:rect];
  
  // then
  [verifyCount(sut.placeholder, never()) drawInRect:rect withAttributes:anything()];
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
  [verify(sut.placeholder) drawInRect:placeholderRect withAttributes:anything()];
}

@end