//
//  LSApplicationWorkspace.h
//  feather
//
//  Created by Lakhan Lothiyi on 21/08/2024.
//

#ifndef LSApplicationWorkspace_h
#define LSApplicationWorkspace_h

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (bool)openApplicationWithBundleID:(NSString*)bundleID;
@end

#endif /* LSApplicationWorkspace_h */
