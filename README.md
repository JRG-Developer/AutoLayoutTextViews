## AutoLayoutTextViews

`AutoLayoutTextViews` subclasses `UITextView` and adds placeholder text, auto resizing, and keyboard avoiding functionality.

`AutoLayoutTextViews` was inspired in part by Mouhcine El Amine's work on <a href="https://github.com/mouhcine/EAMTextView">EAMTextView</a> and by Matej Balantič's work on <a href="https://github.com/MatejBalantic/MBAutoGrowingTextView">MBAutoGrowingTextView</a>.

### Installation with CocoaPods

The easiest way to add `AutoLayoutTextViews` to your project is using <a href="http://cocoapods.org/">CocoaPods</a>. Simply add the following to your Podfile:

pod 'AutoLayoutTextViews', '~> 1.0'

Then run `pod install` as you normally would.

### Manual Installation

Alternatively, you can manually include `AutoLayoutTextViews` in your project by doing the following:

1) Clone this repo locally onto your computer, or press `Download ZIP` to simply download the latest `master` commit.

2) Drag the `AutoLayoutTextViews` folder into your project, making sure `Copy items into destination group's folder (if needed)` is checked.

### General Project Structure

`AutoLayoutTextViews` is architected as follows:

1) `ALPlaceholderTextView` subclasses `UITextView` and adds an optional `placeholder` property.

2) `ALAutoResizingTextView` subclasses `ALPlaceholderTextView`, which gives it a `placeholder` property, and adds "auto resizing" behavior- the text view will grow and shrink as the user types.

Note: when you create `layout constraints` (either in Interface Builder or in code), make sure that you set the `height` and/or `bottom` constraints to `greater than or equal`. See the `AutoLayoutTextViewsDemo` project for an example of how to do this using Interface Builder.

3) `ALKeyboardAvoidingTextView` also subclasses `ALPlaceholderTextView`, which gives it a `placeholder` property, and adds "keyboard avoiding behavior- the text view's frame will shrink/expand as the keyboard will show/hide.

### How to Use

Simply use `ALPlaceholderTextView`, `ALAutoResizingTextView`, or `ALKeyboardAvoidingTextView` as a replacement for a `UITextView` where you the added functionality provided by one of these.

For example usage of each of these, see the `AutoLayoutTextViewsDemo` project within this repository.

Note: `AutoLayoutTextViewsDemo` uses CocoaPods to add `AutoLayoutTextViews` as a dependency. So, you will need to first run `pod install` in the `AutoLayoutTextViewsDemo` directory to add the pods.

### Contributing

Patches and feature additions are welcome!

To contribute:

1) Open a new issue and propose your change- before writing code- to make sure the open source community agrees it's needed.

Make sure to include your rationale for why this change is needed (especially for new method/feature additions).

2) Fork this repo.

3) Make your changes.

4) Write unit tests for your changes (as needed). If possible, a TDD approach is best!

If you've never written unit tests before, that's okay!

You can learn by checking out Jon Reid's (<a href="https://twitter.com/qcoding">@qcoding</a>) excellent <a href="http://qualitycoding.org">website</a>, including a <a href="http://qualitycoding.org/unit-testing">section just about unit testing</a>.

4) Write in-line documentation comments for your property/method additions.

This project is part of the CocoaPods specs repo, which includes appledoc-parsed documentation hosted for each pod on CocoaDocs.

If you're not familar with appledoc, check out Mattt Thompson's (<a href="https://twitter.com/mattt">@matt</a>) introductory <a href="http://nshipster.com/documentation">post about it</a>.

5) Submit a pull request, referencing your original issue from (1) above.

6) Last but not least, sit back and enjoy your awesomeness in helping make your fellow developers' lives a bit easier!

### LICENSE

Like `EAMTextView` and `MBAutoGrowingTextView`, `AutoLayoutTextViews` is released under the MIT license. See the LICENSE file for more details.