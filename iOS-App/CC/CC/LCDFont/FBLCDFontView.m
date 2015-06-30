#import "FBLCDFontView.h"
#import "FBFontSymbol.h"
#import "FBLCDFont.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 green:((float)(((rgbValue) & 0xFF00) >> 8))/255.0 blue:((float)((rgbValue) & 0xFF))/255.0 alpha:1.0]

@interface FBLCDFontView ()
@property (nonatomic, copy) NSArray *symbols;
@end

@implementation FBLCDFontView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.symbols           = @[];
    self.horizontalPadding = 5.0;
    self.drawOffLine       = NO;
    self.verticalPadding   = 5.0;
    self.edgeLength        = 20.0;
    self.lineWidth         = 4.0;
    self.margin            = 5.0;
    self.lineColor         = self.tintColor;
    self.glowColor         = self.tintColor;
    self.innerGlowColor    = self.tintColor;
    self.offColor          = UIColorFromRGB(0x222222);
    self.glowSize          = 3.0;
    self.innerGlowSize     = 1.0;
}

- (void)setText:(NSString *)text
{
    _text = text;
    self.symbols = [FBFontSymbol symbolsForString:text];
    [self setNeedsDisplay];
}

- (void)resetSize
{
    CGRect f = self.frame;
    f.size = [self sizeOfContents];
    self.frame = f;
}

- (CGSize)sizeOfContents
{
    CGFloat w = self.horizontalPadding * 2 + self.edgeLength * [self.symbols count] + self.margin * ([self.symbols count] - 1);
    CGFloat h = self.verticalPadding * 2 + self.edgeLength * 2;
    return CGSizeMake(w, h);
}

- (void)drawRect:(CGRect)rect
{
    NSInteger i = 0;

    CGSize s = [self sizeOfContents];
    CGRect r = (CGRect){CGPointZero, s};

    CGFloat x = self.horizontalPadding;
    CGFloat y = self.verticalPadding;
    CGFloat l = self.edgeLength + self.margin;

    CGContextRef ctx = UIGraphicsGetCurrentContext();

    if (self.drawOffLine) {
        CGContextSetFillColorWithColor(ctx, self.offColor.CGColor);

        for (i = 0; i < [self.symbols count]; i++) {
            [FBLCDFont drawSymbol:FBFontSymbol8
                       edgeLength:self.edgeLength
                        lineWidth:self.lineWidth
                       startPoint:CGPointMake(x + i * l, y)
                        inContext:ctx];
        }
    }

    UIGraphicsBeginImageContextWithOptions(s, NO, 0.0);
    ctx = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(ctx, self.lineColor.CGColor);

    for (i = 0; i < [self.symbols count]; i++) {
        [FBLCDFont drawSymbol:[[self.symbols objectAtIndex:i] intValue]
                   edgeLength:self.edgeLength
                    lineWidth:self.lineWidth
                   startPoint:CGPointMake(x + i * l, y)
                    inContext:ctx];
    }
    UIImage *numImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextClearRect(ctx, r);

    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillRect(ctx, r);
    CGContextTranslateCTM(ctx, 0.0, r.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextClipToMask(ctx, r, numImage.CGImage);
    CGContextClearRect(ctx, r);
    CGContextRestoreGState(ctx);
    
    UIImage *inverted = UIGraphicsGetImageFromCurrentImageContext();
    CGContextClearRect(ctx, r);

    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, self.innerGlowColor.CGColor);
    CGContextSetShadowWithColor(ctx, CGSizeZero, self.innerGlowSize, self.innerGlowColor.CGColor);
    [inverted drawAtPoint:CGPointZero];
    CGContextTranslateCTM(ctx, 0.0, r.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    CGContextClipToMask(ctx, r, inverted.CGImage);
    CGContextClearRect(ctx, r);
    CGContextRestoreGState(ctx);
    UIImage *innerShadow = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextSetShadowWithColor(ctx, CGSizeZero, self.glowSize, self.glowColor.CGColor);
    [numImage drawAtPoint:CGPointMake(0.0, 0.0)];
    CGContextRestoreGState(ctx);
    [innerShadow drawAtPoint:CGPointMake(0.0, 0.0)];
}

@end
