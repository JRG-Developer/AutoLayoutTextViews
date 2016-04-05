//
//  ALPlaceholderTextView.m
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

@implementation ALPlaceholderTextView

#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self commonInit];
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonInit
{
  _placeholderColor = [UIColor lightGrayColor];
  _placeholderInsets = UIEdgeInsetsMake(8.0f, 4.0f, 8.0f, 0.0f);
  self.font = self.font ?: [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
  
  [self startObservingNotifications];
}

#pragma mark - Custom Accessors

- (Class)viewClass
{
  return [UIView class];
}

#pragma mark - Notifications

- (void)startObservingNotifications
{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                selector:@selector(textDidChange:)
                                    name:UITextViewTextDidChangeNotification
                                  object:self];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                selector:@selector(textDidChange:)
                                    name:UIApplicationDidChangeStatusBarOrientationNotification
                                  object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                selector:@selector(keyboardWillShow:)
                                    name:UIKeyboardWillShowNotification
                                  object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                selector:@selector(keyboardWillHide:)
                                    name:UIKeyboardWillHideNotification
                                  object:nil];
}

- (void)textDidChange:(NSNotification *)notification
{
  [self setNeedsDisplay];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
  [self setNeedsDisplay];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
  [self setNeedsDisplay];
}


#pragma mark - Custom Accessors

- (void)setPlaceholder:(NSString *)placeholder
{
  if (_placeholder == placeholder) {
    return;
  }
  
  _placeholder = [placeholder copy];
  [self setNeedsDisplay];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
  if (_placeholderColor == placeholderColor) {
    return;
  }
  
  _placeholderColor = placeholderColor;
  
  if ([self shouldDrawPlaceholder]) {
    [self setNeedsDisplay];
  }
}

- (void)setText:(NSString *)text
{
  [super setText:text];
  [self setNeedsDisplay];
}

#pragma mark - Size That Fits

- (CGSize)sizeThatFits:(CGSize)size
{
  CGSize contentSize = [super sizeThatFits:size];
  CGSize placeholderTextSize = [_placeholder boundingRectWithSize:CGSizeMake(size.width, CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:[self placeholderAttributes]
                                                          context:nil].size;
  
  CGSize placeholderSize = CGSizeMake(placeholderTextSize.width, placeholderTextSize.height +
                                      _placeholderInsets.top +
                                      _placeholderInsets.bottom);
  
  return contentSize.height >= placeholderSize.height ? contentSize : placeholderSize;
}

- (NSDictionary *)placeholderAttributes
{
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
  paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
  paragraphStyle.alignment = self.textAlignment;
  
  return @{NSFontAttributeName: self.font,
           NSParagraphStyleAttributeName: paragraphStyle,
           NSForegroundColorAttributeName: self.placeholderColor};
}

#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  
  if (![self shouldDrawPlaceholder]) {
    return;
  }
  
  [self.placeholder drawInRect:[self calculatePlaceholderRectInsetInRect:rect] withAttributes:[self placeholderAttributes]];
}

- (BOOL)shouldDrawPlaceholder
{
  return (self.text.length == 0) && (self.placeholder.length > 0);
}

- (CGRect)calculatePlaceholderRectInsetInRect:(CGRect)rect
{
  CGRect placeholderRect = CGRectInset(rect, _placeholderInsets.left, _placeholderInsets.top);
  placeholderRect.origin.y += self.contentInset.top;
  return placeholderRect;
}

@end