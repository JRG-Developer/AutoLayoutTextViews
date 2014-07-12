//
//  ALAutoResizingTextView.h
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

#import "ALPlaceholderTextView.h"

@class ALAutoResizingTextView;

/**
 *	The `ALAutoResizingTextViewDelegate` defines optional methods by which a delegate may be notified of height changes on the `ALAutoResizingTextView`.
 */
@protocol ALAutoResizingTextViewDelegate <UITextViewDelegate>
@optional

/**
 *	Tells the delegate that the text view's height is about to change.
 *
 *	@param	textView	The text view whose height is about to change
 *	@param	oldHeight	The current height of the text view's frame
 *	@param	newHeight	The new height of the text view's frame
 *
 *  @discussion This method gets called in the animation block.
 */
- (void)textView:(ALAutoResizingTextView *)textView willChangeFromHeight:(CGFloat)oldHeight toHeight:(CGFloat)newHeight;

/**
 *	Tells the delegate that the text view's height did change.
 *
 *	@param	textView	The text view whose height did change
 *	@param	oldHeight	The previous height of the text view's frame
 *	@param	newHeight	The new height of the text view's frame
 *
 *  @discussion This method gets called in the animation completion block.
 */
- (void)textView:(ALAutoResizingTextView *)textView didChangeFromHeight:(CGFloat)oldHeight toHeight:(CGFloat)newHeight;
@end

/**
 *	`ALAutoResizingTextView` adds vertical autoresizing functionality to `ALPlaceholderTextView` as the user types.
 */
@interface ALAutoResizingTextView : ALPlaceholderTextView

/**
 *	The object that acts as the delegate of the text view. The delegate should conform to `ALAutoResizingTextViewDelegate`, which conforms to `ALTextViewDelegate` and `UITextViewDelegate`.
 */
@property (weak, nonatomic) id <ALAutoResizingTextViewDelegate> delegate;

/**
 *	The minimum height for the text view.
 *
 *  @discussion The default value is `0`. 
 *  If you attempt to set a negative value, `minimumHeight` will be set to `0`.
 */
@property (assign, nonatomic) CGFloat minimumHeight;

/**
 *	The maximum height for the text view.
 *
 *  @discussion The default value is `CGFloat_MAX`. 
 *  If you attempt to set a negative value, `maximumHeight` will be set to `CGFloat_Max`.
 */
@property (assign, nonatomic) CGFloat maximumHeight;

/**
 *	The autoresizing animation duration.
 *
 *  @discussion The default value is `0.2`.
 *  If you set this value to `0`, the height will be updated without animation.
 */
@property (nonatomic) NSTimeInterval autoresizingAnimationDuration;

/**
 *  The height constraint
 *
 *  @warning A runtime exception will be thrown if you don't set this outlet.
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

/**
 *  The height the text view is changing *to*
 */
@property (assign, nonatomic) CGFloat newHeight;

/**
 *  The height the text view is changing *from*
 */
@property (assign, nonatomic) CGFloat oldHeight;

@end
