//
//  CTHighlightView.h
//  iOS Syntax Highlighter
//
//  Created by Andrew Boos on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CTView;
@class CTHighlightViewDelegate;

@interface CTHighlightView : UITextView {
    
    id internalDelegate;
    CTView* editView;
    CTHighlightViewDelegate* ctHighlightViewDelegate;

}
@property (nonatomic, retain) CTView* ctView;

@end
