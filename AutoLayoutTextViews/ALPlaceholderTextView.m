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
  [self requestRedraw];
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


- (void)setAttributedText:(NSAttributedString *)attributedText
{
  [super setAttributedText:attributedText];
  [self setNeedsDisplay];
}

- (void)setPlaceholder:(NSString *)placeholder
{
  if (_placeholder == placeholder) {
    return;
  }
  
  _placeholder = [placeholder copy];
  [self requestRedraw];
}

- (void)setFont:(UIFont *)font
{
  [super setFont:font];
  [self requestRedraw];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
  if (_placeholderColor == placeholderColor) {
    return;
  }
  
  _placeholderColor = placeholderColor;
  
  if ([self shouldDrawPlaceholder]) {
    [self requestRedraw];
  }
}

- (void)setText:(NSString *)text
{
  [super setText:text];
  [self requestRedraw];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
  [super setTextAlignment:textAlignment];
  [self requestRedraw];
}

- (void)requestRedraw
{
  [self invalidateIntrinsicContentSize];
  [self setNeedsDisplay];
  [self setNeedsLayout];
  [self setNeedsUpdateConstraints];
}

#pragma mark - Size That Fits

- (CGSize)intrinsicContentSize {
  return [self sizeThatFits:self.bounds.size];
}

- (CGSize)sizeThatFits:(CGSize)size
{  
  if (![self shouldDrawPlaceholder]) {
    CGSize sizeThatFits = [super sizeThatFits:size];
    sizeThatFits.width = self.bounds.size.width;
    return sizeThatFits;
  }
    
  CGRect placeholderInsetRect = [self calculatePlaceholderRectInsetInRect:self.frame];
  CGRect placeholderTextRect = [self.placeholder
                                boundingRectWithSize:CGSizeMake(placeholderInsetRect.size.width, CGFLOAT_MAX)
                                options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:[self placeholderAttributes]
                                context:nil];
  
  return CGSizeMake(self.bounds.size.width,
                    ceilf(placeholderTextRect.size.height) +
                    self.placeholderInsets.top + self.placeholderInsets.bottom);
}

- (NSDictionary *)placeholderAttributes
{
  NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
  paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
  paragraphStyle.alignment = self.textAlignment;
  
  NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
  attributes[NSParagraphStyleAttributeName] = paragraphStyle;

  if (self.font) {
    attributes[NSFontAttributeName] = self.font;
  }  
  attributes[NSForegroundColorAttributeName] = self.placeholderColor;
  
  return attributes;
}

#pragma mark - Draw Rect

- (void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  
  if (![self shouldDrawPlaceholder]) {
    return;
  }
  
  [self.placeholder drawInRect:[self calculatePlaceholderRectInsetInRect:rect]
                withAttributes:[self placeholderAttributes]];
}

- (BOOL)shouldDrawPlaceholder
{
  return (self.text.length == 0) && (self.placeholder.length > 0);
}

- (CGRect)calculatePlaceholderRectInsetInRect:(CGRect)rect
{
  CGRect placeholderRect = rect;
  placeholderRect.origin.x += (self.placeholderInsets.left + self.contentInset.left);
  placeholderRect.size.width -= placeholderRect.origin.x;
  placeholderRect.size.width -= (self.placeholderInsets.right + self.contentInset.right);
  
  placeholderRect.origin.y += (self.placeholderInsets.top + self.contentInset.top);
  placeholderRect.size.height -= placeholderRect.origin.y;
  placeholderRect.size.height -= (self.placeholderInsets.bottom + self.contentInset.bottom);
  
  return placeholderRect;
}

@end
