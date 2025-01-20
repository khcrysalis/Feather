//
//  p12_password_check.hpp
//  feather
//
//  Created by HAHALOSAH on 8/6/24.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
bool p12_password_check(NSString *file, NSString *pass);
void password_check_fix_WHAT_THE_FUCK(NSString *path);
void generate_root_ca_pair(const char* basename);
#ifdef __cplusplus
}
#endif
