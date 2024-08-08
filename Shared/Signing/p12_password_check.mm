//
//  p12_password_check.cpp
//  feather
//
//  Created by HAHALOSAH on 8/6/24.
//

#include "p12_password_check.hpp"
#include "zsign/common/common.h"

#include <openssl/pem.h>
#include <openssl/cms.h>
#include <openssl/err.h>
#include <openssl/provider.h>
#include <openssl/pkcs12.h>
#include <openssl/conf.h>

#include <string>

using namespace std;

bool p12_password_check(NSString *file, NSString *pass)
{
    BIO *in = BIO_new(BIO_s_mem());
    d2i_CMS_bio(in, NULL);
    const string strSignerPKeyFile = [file cStringUsingEncoding:NSUTF8StringEncoding];
    const string strPassword = [pass cStringUsingEncoding:NSUTF8StringEncoding];
    X509 *x509Cert = NULL;
    EVP_PKEY *evpPKey = NULL;
    BIO *bioPKey = BIO_new_file(strSignerPKeyFile.c_str(), "r");
    OSSL_PROVIDER_load(NULL, "legacy");
    PKCS12 *p12 = d2i_PKCS12_bio(bioPKey, NULL);
    if (NULL != p12)
    {
        if (0 == PKCS12_parse(p12, strPassword.c_str(), &evpPKey, &x509Cert, NULL))
        {
            return false;
        }
        PKCS12_free(p12);
        BIO_free(bioPKey);
        return true;
    } else {
        BIO_free(bioPKey);
        return false;
    }
}

// This is fucking bullshit IMO.
//
// In total, I probably wasted a total of 1.5 hours on this
// Feel free to increment the counter until someone finds a proper fix
//
// hours_wasted = 1.5
//
// TODO: FIX
void password_check_fix_WHAT_THE_FUCK(NSString *path) {
    string strProvisionFile = [path cStringUsingEncoding:NSUTF8StringEncoding];
    string strProvisionData;
    ReadFile(strProvisionFile.c_str(), strProvisionData);
    
    BIO *in = BIO_new(BIO_s_mem());
    OPENSSL_assert((size_t)BIO_write(in, strProvisionData.data(), (int)strProvisionData.size()) == strProvisionData.size());
    d2i_CMS_bio(in, NULL);
}
