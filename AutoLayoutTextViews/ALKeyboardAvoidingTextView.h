//
//  ALKeyboardAvoidingTextView.h
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

/**
 *  `ALKeyboardAvoidingTextView` adds keyboard avoiding functionality to `ALPlaceholderTextView`.
 */
@interface ALKeyboardAvoidingTextView : ALPlaceholderTextView

/**
 *  You should connect this outlet to the bottom constraint that's connected to the bottom layout guide.
 *
 *  @discussion If this outlet isn't connected, it will try to be determined by iterating through its `superview.constraints`.
 *  @warning If you do not explicitly set this outlet, and it's *not* able to be determined, this class will throw a runtime exception.
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraintToBottomLayoutGuide;
@end
