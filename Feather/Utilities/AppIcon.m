#import "AppIcon.h"
#import <dlfcn.h>

#define PrivClass(_cls_) ((Class)NSClassFromString(@#_cls_))

@interface NSObject (IconServicesPrivate)
- (instancetype)initWithBundleURL:(NSURL *)url;
+ (instancetype)imageDescriptorNamed:(NSString *)name;
@property (assign) BOOL drawBorder;
@property (assign) BOOL ignoreCache;
@property (assign) double scale;
@property (assign) NSUInteger variantOptions;
@property (assign) NSInteger appearance;
@property (assign) NSInteger appearanceVariant;
- (void)setIcon:(id)icon;
- (void)setImageDescriptor:(id)descriptor;
- (id)generateImageReturningRecordIdentifiers:(id *)identifiers;
- (CGImageRef)CGImage;
@end

@implementation FRIconServicesRenderer

+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dlopen("/System/Library/PrivateFrameworks/IconServices.framework/IconServices", RTLD_LAZY | RTLD_GLOBAL);
	});
}

+ (UIImage *)iconForBundle:(NSBundle *)bundle {
	NSURL *bundleURL = bundle.bundleURL;
	if (!bundleURL) return nil;

	id icon = [[PrivClass(ISBundleIcon) alloc] initWithBundleURL:bundleURL];
	if (!icon) return nil;

	NSObject *descriptor = [(id)PrivClass(ISImageDescriptor) imageDescriptorNamed:@"com.apple.IconServices.ImageDescriptor.HomeScreen"];
	if (!descriptor) return nil;

	descriptor.drawBorder = YES;
	descriptor.ignoreCache = YES;
	descriptor.scale = UIScreen.mainScreen.scale;
	descriptor.variantOptions = 0;
	descriptor.appearance = 1;

	if (@available(iOS 18.0, *)) {
		descriptor.appearanceVariant = 0;
	}

	id request = [[PrivClass(ISGenerationRequest) alloc] init];
	if (!request) return nil;

	[request setIcon:icon];
	[request setImageDescriptor:descriptor];

	id ifImage = [request generateImageReturningRecordIdentifiers:nil];
	if (!ifImage || ![ifImage respondsToSelector:@selector(CGImage)]) return nil;

	CGImageRef cgImage = [ifImage CGImage];
	if (!cgImage) return nil;

	return [UIImage imageWithCGImage:cgImage
							   scale:UIScreen.mainScreen.scale
						 orientation:UIImageOrientationUp];
}

@end
