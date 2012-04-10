//
//  CTHighlightView.h
//  iOS Syntax Highlighter
//
//  Created by Andrew Boos on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface CTHighlightView : UITextView <UITextViewDelegate> {
    
    id internalDelegate;

}

- (NSRange)visibleRangeOfTextView:(UITextView *)textView;

- (NSAttributedString*)highlightText:(NSAttributedString *)stringIn;
@end
