//
//  MTFont.m
//  iosMath
//
//  Created by Kostub Deshmukh on 5/18/16.
//
//  This software may be modified and distributed under the terms of the
//  MIT license. See the LICENSE file for details.
//

#import "MTFont.h"
#import "MTFont+Internal.h"

@interface MTFont ()

@property (nonatomic, assign) CGFontRef defaultCGFont;
@property (nonatomic, assign) CTFontRef ctFont;
@property (nonatomic, strong) MTFontMathTable* mathTable;
@property (nonatomic, strong) NSDictionary* rawMathTable;

@end

@implementation MTFont

- (instancetype)initFontWithName:(NSString *)name size:(CGFloat)size
{
    self = [super init];
    if (self != nil) {
        // CTFontCreateWithName does not load the complete math font, it only has about half the glyphs of the full math font.
        // In particular it does not have the math italic characters which breaks our variable rendering.
        // So we first load a CGFont from the file and then convert it to a CTFont.

        NSBundle* bundle = [MTFont fontBundle];
        NSString* fontPath = [bundle pathForResource:name ofType:@"otf"];
        if (fontPath.length == 0) {
            // 详细诊断：列出当前 fontBundle 路径与可用资源，帮助使用者排查 mathFonts 资源是否被正确打包。
            NSLog(@"[MTFont] Failed to locate %@.otf. fontBundle=%@ resourcePath=%@. "
                  @"Math rendering will be disabled until the resource is bundled.",
                  name, bundle, bundle.resourcePath);
            return nil;
        }
        NSString* mathTablePlistCheck = [bundle pathForResource:name ofType:@"plist"];
        if (mathTablePlistCheck.length == 0) {
            NSLog(@"[MTFont] Found %@.otf at %@ but %@.plist is missing in the same bundle. "
                  @"Math table will fail to load.", name, fontPath, name);
            return nil;
        }
        CGDataProviderRef fontDataProvider = CGDataProviderCreateWithFilename(fontPath.UTF8String);
        _defaultCGFont = CGFontCreateWithDataProvider(fontDataProvider);
        CFRelease(fontDataProvider);

        _ctFont = CTFontCreateWithGraphicsFont(self.defaultCGFont, size, nil, nil);

        NSString* mathTablePlist = [bundle pathForResource:name ofType:@"plist"];
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:mathTablePlist];
        self.rawMathTable = dict;
        self.mathTable = [[MTFontMathTable alloc] initWithFont:self mathTable:_rawMathTable];
    }
    return self;
}

- (void)setDefaultCGFont:(CGFontRef)defaultCGFont
{
    if (_defaultCGFont != nil) {
        CFRelease(_defaultCGFont);
    }
    if (defaultCGFont != nil) {
        CFRetain(defaultCGFont);
    }
    _defaultCGFont = defaultCGFont;
}

- (void)setCtFont:(CTFontRef)ctFont {
    if (_ctFont != nil) {
        CFRelease(_ctFont);
    }
    if (ctFont != nil) {
        CFRetain(ctFont);
    }
    _ctFont = ctFont;
}

+ (NSBundle*) fontBundle
{
    // 两种部署形态都要能找到 xits-math.otf / xits-math.plist：
    //   1）独立 mathFonts.bundle（iosMath 原生 / FluidMarkdown demo 直接集成源码场景）
    //   2）CocoaPods resource_bundles 平铺场景：资源被平铺进 AntMarkdown.bundle 根目录
    // 查找顺序依次为：class bundle → mainBundle，到以上两种位置其中之一定位资源。
    static NSBundle *cachedBundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *fw = [NSBundle bundleForClass:[self class]];
        NSBundle *main = [NSBundle mainBundle];

        // 1) 独立 mathFonts.bundle（class bundle 优先）
        NSURL *mathFontsURL = [fw URLForResource:@"mathFonts" withExtension:@"bundle"]
                            ?: [main URLForResource:@"mathFonts" withExtension:@"bundle"];
        if (mathFontsURL) {
            cachedBundle = [NSBundle bundleWithURL:mathFontsURL];
            return;
        }

        // 2) AntMarkdown.bundle 平铺场景：xits-math.otf 直接位于 AntMarkdown.bundle 根目录
        NSURL *companionURL = [fw URLForResource:@"AntMarkdown" withExtension:@"bundle"]
                            ?: [main URLForResource:@"AntMarkdown" withExtension:@"bundle"];
        if (companionURL) {
            NSBundle *companion = [NSBundle bundleWithURL:companionURL];
            if ([companion URLForResource:@"xits-math" withExtension:@"otf"]) {
                cachedBundle = companion;
                return;
            }
        }

        // 3) 最后回退：framework / static class bundle 自身
        cachedBundle = fw;
    });
    return cachedBundle;
}

- (MTFont *)copyFontWithSize:(CGFloat)size
{
    MTFont* copyFont = [[[self class] alloc] init];
    copyFont.defaultCGFont = self.defaultCGFont;
    CTFontRef newCtFont = CTFontCreateWithGraphicsFont(self.defaultCGFont, size, nil, nil);
    copyFont.ctFont = newCtFont;
    copyFont.rawMathTable = self.rawMathTable;
    copyFont.mathTable = [[MTFontMathTable alloc] initWithFont:copyFont mathTable:copyFont.rawMathTable];
    CFRelease(newCtFont);
    return copyFont;
}

-(NSString*) getGlyphName:(CGGlyph) glyph
{
    NSString* name = CFBridgingRelease(CGFontCopyGlyphNameForGlyph(self.defaultCGFont, glyph));
    return name;
}

- (CGGlyph)getGlyphWithName:(NSString *)glyphName
{
    return CGFontGetGlyphWithGlyphName(self.defaultCGFont, (__bridge CFStringRef) glyphName);
}

- (CGFloat)fontSize
{
    return CTFontGetSize(self.ctFont);
}

- (void)dealloc
{
    self.defaultCGFont=nil;
    self.ctFont=nil;
}
@end
