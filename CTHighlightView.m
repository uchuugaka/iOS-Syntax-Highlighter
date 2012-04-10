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
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	NSString* newText = [text stringByReplacingOccurrencesOfString:@"\t" withString:@"    "];
	if (![newText isEqualToString:text]) {
		textView.text = [textView.text stringByReplacingCharactersInRange:range withString:newText];
		return NO;
	}
	return YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[scrollView setNeedsDisplay];
}
@end

static CGFloat MARGIN = 8;

@implementation CTHighlightView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.text = @"";
        // self.backgroundColor = [UIColor whiteColor];
        self.textColor = [UIColor clearColor]; 
        self.textColor = [UIColor redColor]; 
        internalDelegate = [[CTHighlightViewDelegate alloc] init];
        self.delegate = internalDelegate;
        self.text = [self.text stringByReplacingOccurrencesOfString:@"\t" withString:@"    "];
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
        CGRect workingFrame = CGRectMake(MARGIN + 0.0, (-self.contentOffset.y + 0), (size.width - 2*MARGIN ) , (size.height + self.contentOffset.y - MARGIN ));
        
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
        
         CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
        
        
        
        NSLog(@"MiLH:%f",minlineHeight);
        NSLog(@"MzLH:%f",maxlineHeight);
        
        CTParagraphStyleSetting setting[3] = {
            { kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(minlineHeight), &minlineHeight },
            { kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(maxlineHeight), &maxlineHeight },
            //{ kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(marginTop), &marginTop},
            //{ kCTParagraphStyleSpecifierParagraphSpacing, sizeof(marginBot), &marginBot},
            //{ kCTParagraphStyleSpecifierLineSpacing, sizeof(lineSpacing), &lineSpacing},
            {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode}
            
        };
        
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(setting, 3);
        
        
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
    
    //Digits
    NSRegularExpression *squeezeNewlines = [NSRegularExpression regularExpressionWithPattern:@"\\d" options:0 error:nil];
    NSArray* matches = [squeezeNewlines matchesInString:coloredStringPlain options:0 range:[coloredStringPlain rangeOfString:coloredStringPlain]];
    NSLog(@"Matches:%@",matches);
    
    for (NSTextCheckingResult *textMatch in matches) {
        
        NSRange textMatchRange = [textMatch rangeAtIndex:0];
        
        [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName 
                              value:(id)[[UIColor blueColor] CGColor]
                              range:textMatchRange];                            
    }
    
//Add keyword highlighting
//Add ClassName highlighting
    //Add ClassName highlighting
//Color Constants

    //#import    
    squeezeNewlines = [NSRegularExpression regularExpressionWithPattern:@"#import" options:0 error:nil];
    matches = [squeezeNewlines matchesInString:coloredStringPlain options:0 range:[coloredStringPlain rangeOfString:coloredStringPlain]];
    NSLog(@"Matches:%@",matches);
    
    for (NSTextCheckingResult *textMatch in matches) {
        
        NSRange textMatchRange = [textMatch rangeAtIndex:0];
        
        [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName 
                              value:(id)[[UIColor brownColor] CGColor]
                              range:textMatchRange];                            
    }
    
    //secondString    
         squeezeNewlines = [NSRegularExpression regularExpressionWithPattern:@"(')(.*?)(?<!\\\\)(\\1)|(')(.*?)(?<!\\\\)(\\r)|(')(.*?)(?<!\\\\)(\\n)|(')(.*?)(?<!\\\\)($)" options:0 error:nil];
         matches = [squeezeNewlines matchesInString:coloredStringPlain options:0 range:[coloredStringPlain rangeOfString:coloredStringPlain]];
        NSLog(@"Matches:%@",matches);
    
        for (NSTextCheckingResult *textMatch in matches) {

            NSRange textMatchRange = [textMatch rangeAtIndex:0];
            
                [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName 
                                      value:(id)[[UIColor blueColor] CGColor]
                                      range:textMatchRange];     
        }
        
        //first String
        squeezeNewlines = [NSRegularExpression regularExpressionWithPattern:@"(\")(.*?)(?<!\\\\)(\\1)|(\")(.*?)(?<!\\\\)(\\r)|(\")(.*?)(?<!\\\\)(\\n)|(\")(.*?)(?<!\\\\)($)/s" options:0 error:nil];
        matches = [squeezeNewlines matchesInString:coloredStringPlain options:0 range:[coloredStringPlain rangeOfString:coloredStringPlain]];
        NSLog(@"Matches:%@",matches);
        
        for (NSTextCheckingResult *textMatch in matches) {
            
            NSRange textMatchRange = [textMatch rangeAtIndex:0];
            
            [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName 
                                  value:(id)[[UIColor redColor] CGColor]
                                  range:textMatchRange];                            
        }

    //Single Line Comments
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
    
    
    //MultilineComment(begins with /* ends wit */)
    squeezeNewlines = [NSRegularExpression regularExpressionWithPattern:@"\\/\\*[\\s\\S]*?\\*\\/|\\/\\*[\\s\\S]*?$" options:0 error:nil];
    matches = [squeezeNewlines matchesInString:coloredStringPlain options:0 range:[coloredStringPlain rangeOfString:coloredStringPlain]];
    NSLog(@"Matches:%@",matches);
    
    for (NSTextCheckingResult *textMatch in matches) {
        
        NSRange textMatchRange = [textMatch rangeAtIndex:0];
        
        [coloredString addAttribute:(NSString*)kCTForegroundColorAttributeName 
                              value:(id)[[UIColor greenColor] CGColor]
                              range:textMatchRange];                            
    }
    
    
    NSAttributedString* coloredStringOut = coloredString.copy;
    return coloredStringOut;
}

+ (CGFloat)lineHeight:(CTFontRef)font {
    CGFloat ascent = CTFontGetAscent(font);
    CGFloat descent = CTFontGetDescent(font);
    CGFloat leading = CTFontGetLeading(font);
    return ceilf(ascent + descent + leading);
}
@end