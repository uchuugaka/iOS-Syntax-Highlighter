//
//  CTView.m
//  iOS Syntax Highlighter
//
//  Created by Andrew Boos on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CTView.h"

static CGFloat MARGIN = 7;

@implementation CTView
@synthesize textViewText;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(void)drawRect:(CGRect)rect
{
    NSLog(@"drawRect called");
    
    // CGFloat y = 100.0;
    
    
    //Prepare View for drawing
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGContextTranslateCTM(context, 0, ([self bounds]).size.height);
    
    CGContextScaleCTM(context, 1.0, -1.0);
    
    
    // Get the view frame size
    CGSize size = self.frame.size;
    
    // Make a frame that has margins
	CGRect workingFrame = CGRectMake(MARGIN, MARGIN, size.width - 2*MARGIN, size.height - 2*MARGIN);
    
    
    //Set Font
    CTFontRef font = CTFontCreateWithName(CFSTR("System"), 12.0, NULL);
    
    
    //The unformatted String from out custom UITextView
    NSString* string = textViewText;
    
    
    //Set Range starting at zero and length of our string
	//NSRange range = NSMakeRange(0, unicodeString.length);
    
    
    
    //Set color
    CGColorRef color = [UIColor blueColor].CGColor;
    
    //Set Underline
    NSNumber* underline = [NSNumber numberWithInt:kCTUnderlineStyleSingle|kCTUnderlinePatternDot];
    
    //Set Attributes
    NSDictionary* attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    (__bridge id)font,(NSString*)kCTFontAttributeName,
                                    color, (NSString*)kCTForegroundColorAttributeName,
                                    underline,(NSString*)kCTUnderlineStyleAttributeName,
                                    nil];
    
    //Create Attributed String
    NSAttributedString* stringToDraw = [[NSAttributedString alloc] initWithString:string
                                                                       attributes:attributesDict];
    
    
       
    
    
    // Create path        
    CGMutablePathRef gpath = CGPathCreateMutable();
    CGPathAddRect(gpath, NULL, workingFrame);
    
    // Create an attributed string
    CGContextSetTextDrawingMode (context, kCGTextFillStroke); 
    CGContextSetGrayFillColor(context, 0.0, 1.0);
    
    CFAttributedStringRef attrString = (__bridge CFAttributedStringRef) stringToDraw;
    
    CTFramesetterRef framesetter = 
    CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    
    CTFrameRef theFrame = 
    CTFramesetterCreateFrame(framesetter, CFRangeMake(0,
                                                      CFAttributedStringGetLength(attrString)), gpath, NULL);
    
    CTFrameDraw(theFrame, context);

    NSLog(@"Out of Loop");

}

@end

