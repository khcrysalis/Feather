//
//  p12_password_check.cpp
//  feather
//
//  Created by HAHALOSAH on 8/6/24.
//

#include "openssl_tools.hpp"
#include "zsign/Utils.hpp"
#include "zsign/common/common.h"

#include <openssl/pem.h>
#include <openssl/cms.h>
#include <openssl/err.h>
#include <openssl/provider.h>
#include <openssl/pkcs12.h>
#include <openssl/conf.h>
#include <openssl/evp.h>
#include <openssl/x509.h>

#include <string>

EVP_PKEY* generate_root_ca_key(const char* basename, const char* output_path);
X509* generate_root_ca_cert(EVP_PKEY* pkey, const char* basename, const char* output_path);

using namespace std;

bool p12_password_check(NSString *file, NSString *pass) {
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

void generate_root_ca_pair(const char* basename) {
    const char* documentsPath = getDocumentsDirectory();
        
    RSA *rsa = RSA_generate_key(2048, RSA_F4, NULL, NULL);
    EVP_PKEY *pkey = EVP_PKEY_new();
    EVP_PKEY_assign_RSA(pkey, rsa);
    
    X509* x509 = X509_new();
    X509_set_version(x509, 2);
    ASN1_INTEGER_set(X509_get_serialNumber(x509), 1);
        
    X509_gmtime_adj(X509_get_notBefore(x509), 0);
    X509_gmtime_adj(X509_get_notAfter(x509), 315360000L);
    
    X509_set_pubkey(x509, pkey);
    
    X509_NAME* name = X509_get_subject_name(x509);
    X509_NAME_add_entry_by_txt(name, "C", MBSTRING_ASC, (unsigned char*)"US", -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "O", MBSTRING_ASC, (unsigned char*)"Root CA", -1, -1, 0);
    X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC, (unsigned char*)"Root CA", -1, -1, 0);
    
    X509_set_issuer_name(x509, name);

    X509V3_CTX ctx;
    X509V3_set_ctx_nodb(&ctx);
    X509V3_set_ctx(&ctx, x509, x509, NULL, NULL, 0);
    
    X509_EXTENSION *ext = X509V3_EXT_conf_nid(NULL, &ctx, NID_basic_constraints, "critical,CA:TRUE,pathlen:0");
    X509_add_ext(x509, ext, -1);
    X509_EXTENSION_free(ext);
    
    ext = X509V3_EXT_conf_nid(NULL, &ctx, NID_key_usage, "critical,keyCertSign,cRLSign");
    X509_add_ext(x509, ext, -1);
    X509_EXTENSION_free(ext);
    
    ext = X509V3_EXT_conf_nid(NULL, &ctx, NID_subject_key_identifier, "hash");
    X509_add_ext(x509, ext, -1);
    X509_EXTENSION_free(ext);
    
    X509_sign(x509, pkey, EVP_sha256());
    
    string keyfile = std::string(documentsPath) + "/" + string(basename) + ".pem";
    string certfile = std::string(documentsPath) + "/" + string(basename) + ".crt";
    
    BIO *bio = BIO_new_file(keyfile.c_str(), "w");
    if (bio) {
        PEM_write_bio_PrivateKey(bio, pkey, NULL, NULL, 0, NULL, NULL);
        BIO_free(bio);
        printf("Private key written to: %s\n", keyfile.c_str());
    }
    
    FILE* f = fopen(certfile.c_str(), "wb");
    if (f) {
        PEM_write_X509(f, x509);
        fclose(f);
        printf("Certificate written to: %s\n", certfile.c_str());
    }
    
    EVP_PKEY_free(pkey);
    X509_free(x509);
}
