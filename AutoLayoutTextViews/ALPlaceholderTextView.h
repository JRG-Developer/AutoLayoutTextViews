//
//  ALPlaceholderTextView.h
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

#import <UIKit/UIKit.h>

/**
 *  The `ALTextViewDelegate` protocol defines optional methods by which a delegate may be notified of `clear` or `done` pressed on the text view's `actionToolbar`.
 */

/**
 *  `ALPlaceholderTextView` adds a placeholder to `UITextView`
 */
@interface ALPlaceholderTextView : UITextView

/**
 *	The string that is displayed when there is no other text in the text field
 *
 *  @discussion The default value is `nil`.
 */
@property (strong, nonatomic) NSString *placeholder;

/**
 *	The color of the placeholder
 *
 *  @discussion The default value is `[UIColor lightGrayColor]`.
 */
@property (strong, nonatomic) UIColor *placeholderColor;

/**
 *  The placeholder insets
 *
 *  @discussion The default value is set to `UIEdgeInsetsMake(8.0f, 4.0f, 0.0f, 0.0f)`.
 */
@property (assign, nonatomic, readwrite) UIEdgeInsets placeholderInsets;

@end

@interface ALPlaceholderTextView (Protected)

/**
 *  This method is called by all `init` methods after self has been set.
 */
- (void)commonInit __attribute__((objc_requires_super));

/**
 *  This method is called within `commonInit` to setup notification observers.
 */
- (void)startObservingNotifications __attribute__((objc_requires_super));

/**
 *  This method is called whenever `UITextViewTextDidChangeNotification` is received.
 *
 *  @param notification The `UITextViewTextDidChangeNotification` notification object.
 */
- (void)textDidChange:(NSNotification *)notification __attribute__((objc_requires_super));

/**
 *  This method is called whenever `UIKeyboardWillShowNotification` is received.
 *
 *  @param notification The `UIKeyboardWillShowNotification` notification object.
 */
- (void)keyboardWillShow:(NSNotification *)notification __attribute__((objc_requires_super));

/**
 *  This method is called whenever `UIKeyboardWillHideNotification` is received.
 *
 *  @param notification The `UIKeyboardWillHideNotification` notification object.
 */
- (void)keyboardWillHide:(NSNotification *)notification __attribute__((objc_requires_super));

/**
 *  This method is called from `drawRect:` to determine if the placeholder should be drawn.
 *
 *  @return `YES` if the text view doesn't have any text and a `placeholder` is set (length > 0) or `NO` otherwise
 */
- (BOOL)shouldDrawPlaceholder;

/**
 *  The `NSNotficationCenter` object with which to register for notifications.
 *
 *  @discussion This method is exposed mainly for testing purposes, and you should *not* generally need to override it.
 *
 *
 *  @return Returns the `defaultCenter` by default.
 */
- (NSNotificationCenter *)notificationCenter;

/**
 *  This method is called to get the preferred rect to draw the placeholder within, taking into account the placeholder insets.
 *
 *  @param rect The rect that was passed to `drawRect:`
 *
 *  @return The preferred rect to draw the placeholder within
 */
- (CGRect)calculatePlaceholderRectInsetInRect:(CGRect)rect;

/**
 *  The view class
 *  @discussion This method is exposed to allow the `UIView` class to be mocked during unit testing. Otherwise, this method should not be called or overridden.
 *
 *  @return `[UIView class]`
 */
- (Class)viewClass;
@end