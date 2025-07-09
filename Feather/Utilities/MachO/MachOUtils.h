//
//  MachOUtils.h
//  Feather
//
//  Created by samara on 12.06.2025.
//

@import Darwin;
@import Foundation;
@import MachO;

NSString *LCPatchMachOFixupARM64eSlice(const char *path);
NSString *LCPatchMachOForSDK26(const char *path);
NSString *getApplicationIdentifier(void);

#if APPSTORE != 1
void* (SecTaskCopyValueForEntitlement)(void* task, CFStringRef entitlement, CFErrorRef *error);
void* (SecTaskCreateFromSelf)(CFAllocatorRef allocator);
#endif
