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
#import <AOTestCase/AOTestCase.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

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

@interface ALAutoResizingTextViewTests : AOTestCase
@end

@implementation ALAutoResizingTextViewTests
{
  Test_ALAutoResizingTextView *sut;
  id <ALAutoResizingTextViewDelegate> delegate;
}

#pragma mark - Test Lifecycle

- (void)setUp
{
  [super setUp];

  sut = [[Test_ALAutoResizingTextView alloc] initWithFrame:CGRectZero];
  [self givenHeightConstraint];
}

#pragma mark - Given

- (void)givenMockDelegate
{
  delegate = mockProtocol(@protocol(ALAutoResizingTextViewDelegate));
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

#pragma mark - Object LifeCycle - Tests

- (void)test___commonInit___setsMinimumHeight
{
  assertThatFloat(sut.minimumHeight, equalToFloat(0.0f));
}

- (void)test___commonInit___setsMaximumHeight
{
  assertThatFloat(sut.maximumHeight, equalToFloat(CGFLOAT_MAX));
}

- (void)test___commonInit___setsAutoresizingAnimationDuration
{
  assertThatFloat(sut.autoresizingAnimationDuration, equalToFloat(0.2f));
}

#pragma mark - View - Tests

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
  assertThat(sut.heightConstraint, notNilValue());
}

- (void)test___layoutSubViews___updatesHeightConstraint
{
  // given
  [self givenAboutToChangeHeight];
  sut.test_viewClass = [UIView class];
  
  CGFloat expected = sut.test_sizeThatFits.height + sut.contentInset.top;
  
  // when
  [sut layoutSubviews];
  
  // then
  assertThatFloat(sut.heightConstraint.constant, equalToFloat(expected));
}

- (void)test___layoutSubViews___animatesHeightChange_ifAutoresizingAnimationDurationGreaterThanZero
{
  // given
  [self givenAboutToChangeHeight];
  sut.test_viewClass = mockClass([UIView class]);
  
  // when
  [sut layoutSubviews];
  
  // then
  [verify(sut.test_viewClass) animateWithDuration:sut.autoresizingAnimationDuration
                                            delay:0.0f
                                         options:UIViewAnimationOptionAllowUserInteraction |
                                                 UIViewAnimationOptionBeginFromCurrentState
                                      animations:anything()
                                      completion:anything()];
}

- (void)test___layoutSubViews___doesNotAnimateHeightChange_ifAutoresizingAnimationDurationEqualsZero
{
  [self givenAboutToChangeHeight];
  sut.test_viewClass = mockClass([UIView class]);
  sut.autoresizingAnimationDuration = 0;
  
  // when
  [sut layoutSubviews];
  
  // then
  [verifyCount(sut.test_viewClass, never()) animateWithDuration:sut.autoresizingAnimationDuration
                                                          delay:0.0f
                                                        options:UIViewAnimationOptionAllowUserInteraction |
                                                                UIViewAnimationOptionBeginFromCurrentState
                                                     animations:anything()
                                                     completion:anything()];
}

- (void)test_heightChangeAnimationBlock_notifiesDelegateWillChangeHeight
{
  // given
  [self givenMockDelegate];
  [self givenAboutToChangeHeight];

  sut.test_viewClass = mockClass([UIView class]);
  MKTArgumentCaptor *captor = [[MKTArgumentCaptor alloc] init];
  
  // when
  [sut layoutSubviews];
  
  // then
  [verify(sut.test_viewClass) animateWithDuration:sut.autoresizingAnimationDuration
                                            delay:0.0f
                                          options:UIViewAnimationOptionAllowUserInteraction |
   UIViewAnimationOptionBeginFromCurrentState
                                       animations:[captor capture]
                                       completion:anything()];

  void (^animationBlock)() = [captor value];
  animationBlock();
  
  [verify(sut.delegate) textView:sut willChangeFromHeight:sut.oldHeight toHeight:sut.newHeight];
  [verifyCount(sut.delegate, never()) textView:sut didChangeFromHeight:sut.oldHeight toHeight:sut.newHeight];
}

- (void)test_heightChangeCompletionBlock_notifiesDelegateDidChangeHeight
{
  // given
  [self givenMockDelegate];
  [self givenAboutToChangeHeight];
  
  sut.test_viewClass = mockClass([UIView class]);
  MKTArgumentCaptor *captor = [[MKTArgumentCaptor alloc] init];
  
  // when
  [sut layoutSubviews];
  
  // then
  [verify(sut.test_viewClass) animateWithDuration:sut.autoresizingAnimationDuration
                                            delay:0.0f
                                          options:UIViewAnimationOptionAllowUserInteraction |
   UIViewAnimationOptionBeginFromCurrentState
                                       animations:anything()
                                       completion:[captor capture]];
  
  void (^completionBlock)(BOOL) = [captor value];
  completionBlock(YES);
  
  [verify(sut.delegate) textView:sut didChangeFromHeight:sut.oldHeight toHeight:sut.newHeight];
  [verifyCount(sut.delegate, never()) textView:sut willChangeFromHeight:sut.oldHeight toHeight:sut.newHeight];
}

- (void)test_heightChangeWithoutAnimation_notifiesDelegateWillAndDidChangeHeight
{
  // given
  [self givenMockDelegate];
  [self givenAboutToChangeHeight];
  sut.autoresizingAnimationDuration = 0;
  
  // when
  [sut layoutSubviews];
  
  // then
  [verify(sut.delegate) textView:sut willChangeFromHeight:sut.oldHeight toHeight:sut.newHeight];
  [verify(sut.delegate) textView:sut didChangeFromHeight:sut.oldHeight toHeight:sut.newHeight];
}

@end