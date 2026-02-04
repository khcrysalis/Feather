//
//  iconPoc.m
//  nmsl
//
//  Created by s s on 2026/1/15.
//

#include "iconPoc.h"
#include <dlfcn.h>

#define PrivClass(name) ((Class)objc_lookUpClass(#name))

@interface IFColor : NSObject
- (instancetype)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (instancetype)initWithCGColor:(CGColorRef)color;
@end

@interface IFBundle : NSObject
- (instancetype)initWithURL:(NSURL*)url;
- (NSDictionary*)iconDictionary;
@end

@interface IFImage : NSObject
- (CGImageRef)CGImage;
@end

@interface ISImageDescriptor : NSObject
@property (nonatomic, assign, readwrite) NSInteger appearance;
@property (nonatomic, assign, readwrite) NSInteger appearanceVariant NS_AVAILABLE_IOS(18_0);
@property (nonatomic, assign, readwrite) NSUInteger specialIconOptions NS_AVAILABLE_IOS(18_0);
@property (nonatomic, assign, readwrite) BOOL drawBorder;
@property (atomic, assign, readwrite) BOOL ignoreCache;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, strong, readwrite) IFColor *tintColor;
@property (nonatomic, assign, readwrite) NSUInteger variantOptions;
+ (instancetype)imageDescriptorNamed:(NSString *)name;
@end

@interface ISIcon : NSObject
- (CGImageRef)CGImageForImageDescriptor:(ISImageDescriptor *)imageDescriptor;
@end

@interface ISConcreteIcon : ISIcon
@end

@interface ISBundleIcon : ISIcon

@property (readonly) NSString *tag;
@property (readonly) NSString *tagClass;
@property (readonly) NSString *type;
@property (readonly) NSURL *url;

+ (bool)supportsSecureCoding;

- (double)_aspectRatio;
- (id)_makeAppResourceProvider;
- (id)_makeDocumentResourceProvider;
- (id)description;
- (void)encodeWithCoder:(id)arg1;
- (id)initWithBundleURL:(id)arg1;
- (id)initWithBundleURL:(id)arg1 fileExtension:(id)arg2;
- (id)initWithBundleURL:(id)arg1 type:(id)arg2;
- (id)initWithBundleURL:(id)arg1 type:(id)arg2 tag:(id)arg3 tagClass:(id)arg4;
- (id)initWithCoder:(id)arg1;
- (id)makeResourceProvider;
- (id)tag;
- (id)tagClass;
- (id)type;
- (id)url;

@end

@interface ISGenerationRequest : NSObject
@property (retain) ISConcreteIcon *icon;
@property (retain) ISImageDescriptor *imageDescriptor;
@property unsigned long long lsDatabaseSequenceNumber;
@property (retain) NSUUID *lsDatabaseUUID;

+ (bool)supportsSecureCoding;

- (id)_decorationRecipeKeyFromType:(id)arg1;
- (void)encodeWithCoder:(id)arg1;
- (id)generateImage;
- (id)generateImageReturningRecordIdentifiers:(id*)arg1;
- (id)icon;
- (id)imageDescriptor;
- (id)init;
- (id)initWithCoder:(id)arg1;
- (unsigned long long)lsDatabaseSequenceNumber;
- (id)lsDatabaseUUID;
- (void)setIcon:(ISConcreteIcon*)arg1;
- (void)setImageDescriptor:(ISImageDescriptor*)arg1;
- (void)setLsDatabaseSequenceNumber:(unsigned long long)arg1;
- (void)setLsDatabaseUUID:(NSUUID*)arg1;

@end

@interface ISRecordResourceProvider : NSObject
-(id)initWithRecord:(id)arg1 options:(unsigned long long)arg2 ;
-(void)resolveResources;
-(id)suggestedRecipe;
-(void)setSuggestedRecipe:(id)suggestedRecipe;
-(void)setResourceType:(NSUInteger)type;
-(void)setIconShape:(NSUInteger)type;
@end

@interface ISiOSAppRecipe : NSObject
- (instancetype)init;
@end


@interface LSApplicationRecordFake : NSObject
@property NSBundle* bundle;
@end


@implementation LSApplicationRecordFake
- (instancetype)initWithBundle:(NSBundle *)bundle {
    self.bundle = bundle;
    return self;
}
- (BOOL)_is_canProvideIconResources {
    return YES;
}
- (NSDictionary *)iconDictionary {
    IFBundle* ifBundle = [[PrivClass(IFBundle) alloc] initWithURL:self.bundle.bundleURL];
    return [ifBundle iconDictionary];
}
- (NSURL *)iconResourceBundleURL {
    return self.bundle.bundleURL;
}
- (NSData *)persistentIdentifier {
    return [NSData data];
}
- (NSUInteger) _IS_platformToIFPlatform {
    return 4;
}
- (int)developerType {
	return 0;
}
- (id)appClipMetadata {
    return nil;
}

-(BOOL)isKindOfClass:(Class)aClass {
    const char* className = class_getName(aClass);
    if(strcmp(className, "LSBundleRecord") == 0) {
        return true;
    } else if (strcmp(className, "LSApplicationRecord") == 0) {
        return true;
    } else {
        return [super isKindOfClass:aClass];
    }
}
@end



@interface ISBundleIconFake : NSObject
@end

@implementation ISBundleIconFake

- (id)makeResourceProvider {
    NSURL* url = [(ISBundleIcon*)self url];
    NSBundle* bundle = [[NSBundle alloc] initWithURL:url];
    // to make IconServices generate an app icon, we need ISRecordResourceProvider instead of ISBundleResourceProvider, but it requires a LSApplicationRecord, so we create a fake LSApplicationRecordFake with necessary methods to make it initialize correctly
    LSApplicationRecordFake* record = [[LSApplicationRecordFake alloc] initWithBundle:bundle];
    ISRecordResourceProvider* provider = [[PrivClass(ISRecordResourceProvider) alloc] initWithRecord:record options:0];
    
    // set suggestedRecipe so -[ISRecipeFactory _recipe] skips all checks and directly use ISiOSAppRecipe
	if (@available(iOS 17.0, *)) {
		[provider setSuggestedRecipe:[[PrivClass(ISiOSAppRecipe) alloc] init]];
		[provider setResourceType:1];
	} else {
		[provider setIconShape:7];
	}
    return provider;
}

@end

@interface IFBundleFake : NSObject
@end

@implementation IFBundleFake
- (NSUInteger)platform {
    return 4;
}
@end


UIImage* iconTest(NSURL *bundleURL) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void* handle = dlopen("/System/Library/PrivateFrameworks/IconServices.framework/IconServices", RTLD_LAZY|RTLD_GLOBAL);
        assert(handle);

        method_exchangeImplementations(class_getInstanceMethod(PrivClass(ISBundleIcon), @selector(makeResourceProvider)), class_getInstanceMethod(ISBundleIconFake.class, @selector(makeResourceProvider)));
        // stop IFBundle from connecting to lsd database
        method_exchangeImplementations(class_getInstanceMethod(PrivClass(IFBundle), @selector(platform)), class_getInstanceMethod(IFBundleFake.class, @selector(platform)));
    });

//    NSBundle* bundle = [NSBundle bundleWithURL:[docPathUrl URLByAppendingPathComponent:@"me.oatmealdome.DolphiniOS-njb.app"]];
//    ISBundleIcon* icon = [[PrivClass(ISBundleIcon) alloc] initWithBundleURL:[docPathUrl URLByAppendingPathComponent:@"com.aigch.OpenParsec1.app"]];
    ISBundleIcon* icon = [[PrivClass(ISBundleIcon) alloc] initWithBundleURL:bundleURL];
//    ISBundleIcon* icon = [[PrivClass(ISBundleIcon) alloc] initWithBundleURL:[docPathUrl URLByAppendingPathComponent:@"org.mozilla.ios.Firefox.app"]];
    ISImageDescriptor *descriptor = [PrivClass(ISImageDescriptor) imageDescriptorNamed:@"com.apple.IconServices.ImageDescriptor.HomeScreen"];
    descriptor.drawBorder = YES;
    descriptor.ignoreCache = YES;
    descriptor.scale = UIScreen.mainScreen.scale;
	descriptor.tintColor =
		[[PrivClass(IFColor) alloc]
			initWithCGColor:FRCreateCGColorFromHex()];

    descriptor.variantOptions = 0;
    // 0 = light mode, 1 = dark mode
//    descriptor.appearance = 0;
	NSInteger style =
		[NSUserDefaults.standardUserDefaults integerForKey:@"Feather.userInterfaceStyle"];
	NSInteger variant =
		[NSUserDefaults.standardUserDefaults integerForKey:@"Feather.shouldTintIcons"];
	NSInteger lightDark =
		[NSUserDefaults.standardUserDefaults integerForKey:@"Feather.shouldChangeIconsBasedOffStyle"];

	// Resolve "system / unspecified" dynamically
	if (style == UIUserInterfaceStyleUnspecified) {
		style = UIScreen.mainScreen.traitCollection.userInterfaceStyle;
	}

	// IconServices: 0 = light, 1 = dark
	descriptor.appearance = 0;
	if (lightDark == 1) {
		descriptor.appearance =
		(style == UIUserInterfaceStyleDark) ? 1 : 0;
	}

    if (@available(iOS 18.0, *)) {
        // 0 = normal, 2 = tinted mode, 3 = liquid glass (gray scale)
		if (@available(iOS 18.2, *)) {
			descriptor.appearanceVariant = (variant == 0) ? 0 : 2;
		}
        descriptor.specialIconOptions = 2;
    }

    ISGenerationRequest* request = [[PrivClass(ISGenerationRequest) alloc] init];
    [request setIcon:(ISConcreteIcon*)icon];
    [request setImageDescriptor:descriptor];
    IFImage* ifImage = [request generateImageReturningRecordIdentifiers:nil];
    CGImageRef imageRef = [ifImage CGImage];
    return [UIImage imageWithCGImage:imageRef];

}

static CGColorRef FRCreateCGColorFromHex(void) {
	NSString *hex =
		[NSUserDefaults.standardUserDefaults
			stringForKey:@"Feather.userTintColor"];

	if (hex.length == 0) {
		return UIColor.systemGreenColor.CGColor;
	}

	NSString *sanitized =
		[[hex stringByTrimmingCharactersInSet:
			NSCharacterSet.whitespaceAndNewlineCharacterSet]
			stringByReplacingOccurrencesOfString:@"#" withString:@""];

	unsigned long long rgb = 0;
	[[NSScanner scannerWithString:sanitized] scanHexLongLong:&rgb];

	CGFloat r = 0, g = 0, b = 0, a = 1;

	if (sanitized.length == 6) {
		r = ((rgb & 0xFF0000) >> 16) / 255.0;
		g = ((rgb & 0x00FF00) >> 8)  / 255.0;
		b = (rgb & 0x0000FF) / 255.0;
	} else if (sanitized.length == 8) {
		r = ((rgb & 0xFF000000) >> 24) / 255.0;
		g = ((rgb & 0x00FF0000) >> 16) / 255.0;
		b = ((rgb & 0x0000FF00) >> 8)  / 255.0;
		a = (rgb & 0x000000FF) / 255.0;
	} else {
		return UIColor.systemGreenColor.CGColor;
	}

	return [UIColor colorWithRed:r green:g blue:b alpha:a].CGColor;
}
