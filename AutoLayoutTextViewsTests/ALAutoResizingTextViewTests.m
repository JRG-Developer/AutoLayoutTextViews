//
//  ALAutoResizingTextViewTests.m
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
#import "Test_ALAutoResizingTextView.h"

// Collaborators

// Test Support
#import <XCTest/XCTestCase.h>

#define EXP_SHORTHAND
#import <Expecta/Expecta.h>

#import <OCMock/OCMock.h>

@interface ALAutoResizingTextView (Test_Methods)

- (CGSize)test_intrinsicContentSize;
- (CGSize)test_sizeThatFits:(CGSize)size;

@end

@implementation ALAutoResizingTextView (Test_Methods)

- (CGSize)test_intrinsicContentSize
{
  return CGSizeMake(320.0f, 400.0f);
}

- (CGSize)test_sizeThatFits:(CGSize)size
{
  return CGSizeMake(300.0f, 50.0f);
}

@end

@interface ALAutoResizingTextViewTests : XCTestCase
@end

@implementation ALAutoResizingTextViewTests
{
  Test_ALAutoResizingTextView *sut;
  
  id delegate;
  id viewClass;
}

#pragma mark - Test Lifecycle

- (void)setUp
{
  [super setUp];

  sut = [[Test_ALAutoResizingTextView alloc] initWithFrame:CGRectZero];
  [self givenHeightConstraint];
}

- (void)tearDown
{
  [delegate stopMocking];
  [viewClass stopMocking];
  
  [super tearDown];
}

#pragma mark - Given

- (void)givenMockDelegate
{
  delegate = OCMProtocolMock(@protocol(ALAutoResizingTextViewDelegate));
  sut.delegate = delegate;
}

- (void)givenHeightConstraint
{
  NSLayoutConstraint *heightConstraint = [self heightConstraint];
  [sut addConstraint:heightConstraint];
  sut.heightConstraint = heightConstraint;
}

- (NSLayoutConstraint *)heightConstraint
{
  return [NSLayoutConstraint constraintWithItem:sut
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                         toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                     multiplier:1.0f
                                       constant:10.0f];

}

- (void)givenAboutToChangeHeight
{
  sut.contentInset = UIEdgeInsetsMake(10.0f, 0.0f, 0.0f, 0.0f);
  sut.test_sizeThatFits = CGSizeMake(300.0f, 50.0f);
}

- (void)givenMockViewClass
{
  viewClass = OCMClassMock([UIView class]);
}

#pragma mark - Object LifeCycle - Tests

- (void)test___commonInit___setsMinimumHeight
{
  expect(sut.minimumHeight).to.equal(0.0f);
}

- (void)test___commonInit___setsMaximumHeight
{
  expect(sut.maximumHeight).to.equal(CGFLOAT_MAX);
}

- (void)test___commonInit___setsAutoresizingAnimationDuration
{
  expect(sut.autoresizingAnimationDuration).to.equal(0.2f);
}

#pragma mark - awakwFromNib - Tests

- (void)test___awakeFromNib___setsHeightConstraint_whenHeightConstraintFoundBy_firstItem
{
  // given
  sut.heightConstraint = nil;
  [sut addConstraint:[NSLayoutConstraint constraintWithItem:sut
                                                 attribute:NSLayoutAttributeHeight
                                                 relatedBy:NSLayoutRelationEqual
                                                    toItem:nil
                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                 multiplier:1.0
                                                   constant:150.0f]];
  
  // when
  [sut awakeFromNib];
  
  // then
  expect(sut.heightConstraint).toNot.beNil();
}

#pragma mark - updateConstraints - Tests

- (void)test___updateConstraints___animatesHeightChange_ifAutoresizingAnimationDurationGreaterThanZero
{
  // given
  [self givenAboutToChangeHeight];
  [self givenMockViewClass];
  
  OCMExpect([viewClass animateWithDuration:sut.autoresizingAnimationDuration
                                     delay:0.0f
                                   options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                                animations:[OCMArg any]
                                completion:[OCMArg any]]);
  
  // when
  [sut updateConstraints];
  
  // then
  OCMVerifyAll(viewClass);
}

- (void)test___updateConstraints___doesNotAnimateHeightChange_ifAutoresizingAnimationDurationEqualsZero
{
  [self givenAboutToChangeHeight];
  [self givenMockViewClass];
  
  [[[viewClass reject] ignoringNonObjectArgs] animateWithDuration:sut.autoresizingAnimationDuration
                                                            delay:0.0f
                                                          options:UIViewAnimationOptionAllowUserInteraction |
                                                                  UIViewAnimationOptionBeginFromCurrentState
                                                       animations:[OCMArg any]
                                                       completion:[OCMArg any]];
  
  sut.autoresizingAnimationDuration = 0;
  
  // when
  [sut updateConstraints];
  
  // then
  OCMVerifyAllWithDelay(viewClass, 0.01);
}

- (void)test___updateConstraints___doesNotAnimateHieght_ifShouldDrawPlaceholderReturnsYES
{
  // given
  sut.placeholder = @"Placeholder";
  sut.text = @"";
  expect([sut shouldDrawPlaceholder]).to.beTruthy();
  
  [self givenAboutToChangeHeight];
  [self givenMockViewClass];
  
  [[[viewClass reject] ignoringNonObjectArgs] animateWithDuration:sut.autoresizingAnimationDuration
                                                            delay:0.0f
                                                          options:UIViewAnimationOptionAllowUserInteraction |
   UIViewAnimationOptionBeginFromCurrentState
                                                       animations:[OCMArg any]
                                                       completion:[OCMArg any]];
  
  // when
  [sut updateConstraints];
  
  // then
  OCMVerifyAllWithDelay(viewClass, 0.01);
}

- (void)test_heightChangeWithAnimation_notifies_delegate
{
  // given
  [self givenMockDelegate];
  [self givenAboutToChangeHeight];
  
  [[[delegate expect] ignoringNonObjectArgs] textView:sut willChangeFromHeight:0.0f toHeight:0.0f];
  [[[delegate expect] ignoringNonObjectArgs] textView:sut didChangeFromHeight:0.0f toHeight:0.0f];
  
  // when
  [sut updateConstraints];
  
  // then
  OCMVerifyAllWithDelay(delegate, 0.1);
}

- (void)test_heightChangeWithoutAnimation_notifies_delegate
{
  // given
  sut.autoresizingAnimationDuration = 0.0f;
  [self givenMockDelegate];
  [self givenAboutToChangeHeight];
  
  [[[delegate expect] ignoringNonObjectArgs] textView:sut willChangeFromHeight:0.0f toHeight:0.0f];
  [[[delegate expect] ignoringNonObjectArgs] textView:sut didChangeFromHeight:0.0f toHeight:0.0f];
  
  // when
  [sut updateConstraints];
  
  // then
  OCMVerifyAll(delegate);
}

@end
