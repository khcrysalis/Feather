//
//  zsign.hpp
//  feather
//
//  Created by HAHALOSAH on 5/22/24.
//

#ifndef zsign_hpp
#define zsign_hpp

#include <stdio.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

int zsign(NSString *app, NSString *prov, NSString *key, NSString *pass);

#ifdef __cplusplus
}
#endif

#endif /* zsign_hpp */
