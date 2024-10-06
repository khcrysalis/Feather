#include "zsign.hpp"
#include "common/common.h"
#include "common/json.h"
#include "openssl.h"
#include "macho.h"
#include "bundle.h"
#include <libgen.h>
#include <dirent.h>
#include <getopt.h>
#include <stdlib.h>

NSString* getTmpDir() {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [[[paths objectAtIndex:0] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"tmp"];
}

extern "C" {

bool InjectDyLib(NSString *filePath, NSString *dylibPath, bool weakInject, bool bCreate) {
	ZTimer gtimer;
	@autoreleasepool {
		// Convert NSString to std::string
		std::string filePathStr = [filePath UTF8String];
		std::string dylibPathStr = [dylibPath UTF8String];

		ZMachO machO;
		bool initSuccess = machO.Init(filePathStr.c_str());
		if (!initSuccess) {
			gtimer.Print(">>> Failed to initialize ZMachO.");
			return false;
		}

		bool success = machO.InjectDyLib(weakInject, dylibPathStr.c_str(), bCreate);

		machO.Free();

		if (success) {
			gtimer.Print(">>> Dylib injected successfully!");
			return true;
		} else {
			gtimer.Print(">>> Failed to inject dylib.");
			return false;
		}
	}
}

bool ListDylibs(NSString *filePath, NSMutableArray *dylibPathsArray) {
	ZTimer gtimer;
	@autoreleasepool {
		// Convert NSString to std::string
		std::string filePathStr = [filePath UTF8String];

		ZMachO machO;
		bool initSuccess = machO.Init(filePathStr.c_str());
		if (!initSuccess) {
			gtimer.Print(">>> Failed to initialize ZMachO.");
			return false;
		}

		std::vector<std::string> dylibPaths = machO.ListDylibs();

		if (!dylibPaths.empty()) {
			gtimer.Print(">>> List of dylibs in the Mach-O file:");
			for (const std::string &dylibPath : dylibPaths) {
				NSString *dylibPathStr = [NSString stringWithUTF8String:dylibPath.c_str()];
				[dylibPathsArray addObject:dylibPathStr];
			}
		} else {
			gtimer.Print(">>> No dylibs found in the Mach-O file.");
		}

		machO.Free();

		return true;
	}
}

bool UninstallDylibs(NSString *filePath, NSArray<NSString *> *dylibPathsArray) {
	ZTimer gtimer;
	@autoreleasepool {
		std::string filePathStr = [filePath UTF8String];
		std::set<std::string> dylibsToRemove;

		for (NSString *dylibPath in dylibPathsArray) {
			dylibsToRemove.insert([dylibPath UTF8String]);
		}

		ZMachO machO;
		bool initSuccess = machO.Init(filePathStr.c_str());
		if (!initSuccess) {
			gtimer.Print(">>> Failed to initialize ZMachO.");
			return false;
		}

		machO.RemoveDylib(dylibsToRemove);

		machO.Free();

		gtimer.Print(">>> Dylibs uninstalled successfully!");
		return true;
	}
}



bool ChangeDylibPath(NSString *filePath, NSString *oldPath, NSString *newPath) {
	ZTimer gtimer;
	@autoreleasepool {
		// Convert NSString to std::string
		std::string filePathStr = [filePath UTF8String];
		std::string oldPathStr = [oldPath UTF8String];
		std::string newPathStr = [newPath UTF8String];

		ZMachO machO;
		bool initSuccess = machO.Init(filePathStr.c_str());
		if (!initSuccess) {
			gtimer.Print(">>> Failed to initialize ZMachO.");
			return false;
		}

		bool success = machO.ChangeDylibPath(oldPathStr.c_str(), newPathStr.c_str());

		machO.Free();

		if (success) {
			gtimer.Print(">>> Dylib path changed successfully!");
			return true;
		} else {
			gtimer.Print(">>> Failed to change dylib path.");
			return false;
		}
	}
}


int zsign(NSString *app,
		  NSString *prov,
		  NSString *key,
		  NSString *pass,
		  NSString *bundleid,
		  NSString *displayname,
		  NSString *bundleversion,
		  bool dontGenerateEmbeddedMobileProvision
		  )
{
	ZTimer gtimer;
	
	bool bForce = false;
	bool bWeakInject = false;
	bool bDontGenerateEmbeddedMobileProvision = dontGenerateEmbeddedMobileProvision;
	
	string strCertFile;
	string strPKeyFile;
	string strProvFile;
	string strPassword;
	string strBundleId;
	string strBundleVersion;
	string strDyLibFile;
	string strOutputFile;
	string strDisplayName;
	string strEntitlementsFile;
	
	bForce = true;
	strPKeyFile = [key cStringUsingEncoding:NSUTF8StringEncoding];
	strProvFile = [prov cStringUsingEncoding:NSUTF8StringEncoding];
	strPassword = [pass cStringUsingEncoding:NSUTF8StringEncoding];
	
	strBundleId = [bundleid cStringUsingEncoding:NSUTF8StringEncoding];
	strDisplayName = [displayname cStringUsingEncoding:NSUTF8StringEncoding];
	strBundleVersion = [bundleversion cStringUsingEncoding:NSUTF8StringEncoding];
	
	string strPath = [app cStringUsingEncoding:NSUTF8StringEncoding];
	if (!IsFileExists(strPath.c_str())) {
		ZLog::ErrorV(">>> Invalid Path! %s\n", strPath.c_str());
		return -1;
	}
	
	bool bZipFile = false;
	if (!IsFolder(strPath.c_str()))
	{
		bZipFile = IsZipFile(strPath.c_str());
		if (!bZipFile) { //macho file
			ZMachO macho;
			if (macho.Init(strPath.c_str())) {
				if (!strDyLibFile.empty()) { //inject dylib
					bool bCreate = false;
					macho.InjectDyLib(bWeakInject, strDyLibFile.c_str(), bCreate);
				} else {
					macho.PrintInfo();
				}
				macho.Free();
			}
			return 0;
		}
	}
	
	ZTimer timer;
	ZSignAsset zSignAsset;
	
	if (!zSignAsset.Init(strCertFile, strPKeyFile, strProvFile, strEntitlementsFile, strPassword)) {
		return -1;
	}
	
	bool bEnableCache = true;
	string strFolder = strPath;
	
	timer.Reset();
	ZAppBundle bundle;
	bool bRet = bundle.SignFolder(&zSignAsset, strFolder, strBundleId, strBundleVersion, strDisplayName, strDyLibFile, bForce, bWeakInject, bEnableCache, bDontGenerateEmbeddedMobileProvision);
	timer.PrintResult(bRet, ">>> Signed %s!", bRet ? "OK" : "Failed");
	
	gtimer.Print(">>> Done.");
	return bRet ? 0 : -1;
}

}
