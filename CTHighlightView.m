//
//  CTHighlightView.m
//  iOS Syntax Highlighter
//
//  Created by Andrew Boos on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CTHighlightView.h"

@interface CTHighlightViewDelegate : NSObject <UITextFieldDelegate>
@end

@implementation CTHighlightViewDelegate
//@synthesize scrollOffset;
- (void)textViewDidChange:(UITextView *)textView {
    [textView setNeedsDisplay];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[scrollView setNeedsDisplay];
}
@end

static CGFloat MARGIN = 8.5;

@implementation CTHighlightView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.text = @"";
        // self.backgroundColor = [UIColor whiteColor];
        self.textColor = [UIColor clearColor]; 
        //self.textColor = [UIColor redColor]; 
        internalDelegate = [[CTHighlightViewDelegate alloc] init];
        self.delegate = internalDelegate;
    }
    return self;
    
}

-(void)drawRect:(CGRect)rect
{
    if (self.text.length > 0) {
        
        //Prepare View for drawing
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        
        CGContextTranslateCTM(context, 0, ([self bounds]).size.height);
        
        CGContextScaleCTM(context, 1.0, -1.0);
        
        // Get the view frame size
        CGSize size = self.frame.size;
        NSLog(@"CO:%f",self.contentOffset.y);
        
        // Make a frame that has margins
        CGRect workingFrame = CGRectMake(MARGIN + 0.0, (-self.contentOffset.y + 0), (size.width - 2*MARGIN - 0) , (size.height + self.contentOffset.y - MARGIN + 1));
        
        //Set Font
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, 
                                              self.font.pointSize, 
                                              NULL);
        
        //Set color
        CGColorRef color = [UIColor blackColor].CGColor;
        
        //CGFloat lineSpacing = 0.0;
        //CGFloat marginTop = 0.0;    
        // CGFloat marginBot = 0.0;
        
        CGFloat minlineHeight = [self.text sizeWithFont:self.font].height;
        
        CGFloat maxlineHeight = [self.text sizeWithFont:self.font].height;
        
        // CTLineBreakMode lineBreakMode = kCTParagraphStyleSpecifierLineHeightMultiple;
        
        
        
        NSLog(@"MiLH:%f",minlineHeight);
        NSLog(@"MzLH:%f",maxlineHeight);
        
        CTParagraphStyleSetting setting[2] = {
            { kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(minlineHeight), &minlineHeight },
            { kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(maxlineHeight), &maxlineHeight },
            //{ kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(marginTop), &marginTop},
            //{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(marginBot), &marginBot},
            //{ kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing},
            //{kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode}
            
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(setting, 2);
        
        
        NSDictionary* attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                        (__bridge id)font,(NSString*)kCTFontAttributeName,
                                        (__bridge id)color, (NSString*)kCTForegroundColorAttributeName,
                                        (__bridge id)paragraphStyle, (NSString*)kCTParagraphStyleAttributeName,
                                        nil];
        
        
        //Create Attributed String
        NSAttributedString* stringToDraw = [[NSAttributedString alloc] 
                                            initWithString:self.text
                                            attributes:attributesDict];
        
        stringToDraw  = [self highlightText:stringToDraw];
        
        // Create path        
        CGMutablePathRef gpath = CGPathCreateMutable();
        CGPathAddRect(gpath, NULL, workingFrame);
        
        
        
        CFAttributedStringRef attrString = (__bridge CFAttributedStringRef) stringToDraw;
        
        CTFramesetterRef framesetter = 
        CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
        
        CTFrameRef theFrame = 
        CTFramesetterCreateFrame(framesetter, CFRangeMake(0,
                                                          CFAttributedStringGetLength(attrString)), gpath, NULL);
        
        CTFrameDraw(theFrame, context);
        
        
        
        
    } else {
        self.text = [[NSString alloc] initWithString:@""];
        
    }
    
}
- (NSRange)visibleRangeOfTextView:(UITextView *)textView {
    CGRect bounds = textView.bounds;
    UITextPosition *start = [textView characterRangeAtPoint:bounds.origin].start;
    UITextPosition *end = [textView characterRangeAtPoint:CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds))].end;
    return NSMakeRange([textView offsetFromPosition:textView.beginningOfDocument toPosition:start],
                       [textView offsetFromPosition:start toPosition:end]);
}

- (NSAttributedString*)highlightText:(NSAttributedString *)stringIn {
    NSMutableAttributedString* coloredString = [[NSMutableAttributedString alloc] initWithAttributedString:stringIn];
    NSString* coloredStringPlain = stringIn.string;
    
	//NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"objectivec" ofType:@"plist"];
    
	//NSDictionary* dwarves = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSScanner *theScanner = [NSScanner scannerWithString:coloredStringPlain];
    NSRange highlightRange = NSMakeRange (0,0);
    NSUInteger lastLocation = 0;

    while ([theScanner isAtEnd] == NO ) {
        lastLocation = theScanner.scanLocation;
        [theScanner scanUpToString:@"\"" intoString:nil];
        NSUInteger beginHighlight = [theScanner scanLocation];
        [theScanner scanString:@"\"" intoString:nil];
        
        [theScanner scanUpToString:@"\"" intoString:nil];
        [theScanner scanString:@"\"" intoString:nil];

        
        NSUInteger endHighlight = [theScanner scanLocation];
        
        highlightRange = NSMakeRange (beginHighlight, (endHighlight - beginHighlight));
        
        if (highlightRange.length > 0) {
            
            [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName 
                                  value:(id)[[UIColor redColor] CGColor]
                                  range:highlightRange];
        }
        if (theScanner.scanLocation == lastLocation) {
            break;
        }        }     
    [theScanner setScanLocation:0];
    while ([theScanner isAtEnd] == NO) {
        lastLocation = theScanner.scanLocation;
            [theScanner scanUpToString:@"'" intoString:nil];
            NSUInteger beginHighlight = [theScanner scanLocation];
        [theScanner scanString:@"'" intoString:nil];

            [theScanner scanUpToString:@"'" intoString:nil];
        [theScanner scanString:@"'" intoString:nil];

            NSUInteger endHighlight = [theScanner scanLocation];
            
            highlightRange = NSMakeRange (beginHighlight, (endHighlight - beginHighlight));
            
            if (highlightRange.length > 0) {
                
                [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName 
                                      value:(id)[[UIColor blueColor] CGColor]
                                      range:highlightRange];
            }
        if (theScanner.scanLocation == lastLocation) {
            break;
        }
    }
    [theScanner setScanLocation:0];

    while ([theScanner isAtEnd] == NO) {   
        lastLocation = theScanner.scanLocation;
        [theScanner scanUpToString:@"//" intoString:nil];
        NSUInteger beginHighlight = [theScanner scanLocation];
        [theScanner scanUpToString:@"\n" intoString:nil];
        NSUInteger endHighlight = [theScanner scanLocation];
        
        highlightRange = NSMakeRange (beginHighlight, (endHighlight - beginHighlight));
        
        if (highlightRange.length > 0) {
            
            [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName 
                                  value:(id)[[UIColor greenColor] CGColor]
                                  range:highlightRange];
        }
        if (theScanner.scanLocation == lastLocation) {
            break;
        }    }
    
    [theScanner setScanLocation:0];
    while ([theScanner isAtEnd] == NO ) {
        lastLocation = theScanner.scanLocation;
        [theScanner scanUpToString:@"/*" intoString:nil];
        NSUInteger beginHighlight = [theScanner scanLocation];
        [theScanner scanUpToString:@"*/" intoString:nil];
        
        NSUInteger endHighlight = [theScanner scanLocation];
        
        highlightRange = NSMakeRange (beginHighlight, (endHighlight - beginHighlight));
        
        if (highlightRange.length > 0) {
            
            [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName 
                                  value:(id)[[UIColor greenColor] CGColor]
                                  range:highlightRange];
        }
        if (theScanner.scanLocation == lastLocation) {
            break;
        }        }     

    
    NSAttributedString* coloredStringOut = coloredString.copy;
    return coloredStringOut;
    }
@end
