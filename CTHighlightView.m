//
//  CTHighlightView.m
//  iOS Syntax Highlighter
//
//  Created by Andrew Boos on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CTHighlightView.h"
#import "CTView.h"
@interface CTHighlightViewDelegate : NSObject <UITextViewDelegate>

@end

@implementation CTHighlightViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    NSLog(@"Text Changed");
    [textView setNeedsDisplay];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"Text Scrolled");
	[scrollView setNeedsDisplay];
}
@end

@implementation CTHighlightView
@synthesize ctView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code]
        
    editView = [[CTView alloc] initWithFrame:self.frame];
    editView.textViewText = @"";
        editView.backgroundColor = [UIColor clearColor];
       // self.textColor = [UIColor clearColor];
    [self addSubview:editView];
        
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
    internalDelegate = [[CTHighlightViewDelegate alloc] init];
	self.delegate = internalDelegate;

	editView.bounds = self.bounds;
	editView.center = self.center;    
}
- (void)setNeedsDisplay {
	[super setNeedsDisplay];
    
    NSLog(@"Set needs display in highlightingtextview:%@",self.text);
    if (self.text.length > 0) {
        editView.textViewText = [[NSString alloc] initWithString:self.text];
    } else {
        editView.textViewText = [[NSString alloc] initWithString:@""];
        
    }
    
	[editView setNeedsDisplay];
}

@end
