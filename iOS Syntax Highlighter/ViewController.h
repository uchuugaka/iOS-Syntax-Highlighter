//
//  ViewController.h
//  iOS Syntax Highlighter
//
//  Created by Andrew Boos on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTHighlightView.h"

@interface ViewController : UIViewController {
    CTHighlightView*    highlightView;
    
}
@property (nonatomic, retain) IBOutlet CTHighlightView* highlightView;

@end
