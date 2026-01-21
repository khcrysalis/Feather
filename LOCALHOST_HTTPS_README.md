# Localhost HTTPS Implementation

## Overview

The Feather app generates **unique SSL certificates at runtime** for each user to serve HTTPS on `localhost` instead of relying on external services like `backloop.dev`.

## Key Features

✅ **Unique per user** - Each installation generates its own certificate  
✅ **Runtime generation** - Certificates created on first launch using iOS Security framework  
✅ **No shared secrets** - Each user has their own private key  
✅ **Completely offline** - No network required  
✅ **Automatic** - Transparent to the user  

## How It Works

### First Launch
1. Server starts and checks for existing certificates in documents directory
2. None found → Generates new certificate:
   - RSA 2048-bit key pair via `SecKeyCreateRandomKey()`
   - Self-signed X.509 certificate with random serial number
   - Valid for 1 year
   - CN=localhost with SANs for localhost and 127.0.0.1
3. Saves to documents directory: `server.crt`, `server.pem`, `commonName.txt`
4. Loads certificates into NIOSSL for TLS
5. Server starts on `https://localhost:PORT` (random port 4000-8000)

### Subsequent Launches
- Reuses existing unique certificate from documents directory
- Server starts immediately on `https://localhost:PORT`

## Implementation Details

### Modified Files

**Feather/Backend/Server/ServerInstaller+TLS.swift**
- Always uses HTTPS with localhost
- Calls `SSLCertificateGenerator.ensureLocalhostCertificate()` on startup

**Feather/Backend/Server/ServerInstaller+Compute.swift**
- All URLs use `https://localhost:PORT` format

**Feather/Utilities/SSLCertificateGenerator.swift** (New)
- Runtime certificate generation using Security framework
- ASN.1 DER encoding for X.509 structure
- PEM format output for NIOSSL compatibility

**Makefile**
- Removed certificate downloading/copying (no longer needed)

## Certificate Uniqueness

Each user's certificate is unique because:
- **Random serial number**: `Int.random(in: 100000...Int.max)`
- **Unique key pair**: Generated using device entropy via Security framework
- **Timestamp-based validity**: Generation time determines validity period
- **Sandboxed storage**: App-specific documents directory

## Security

⚠️ **Self-signed certificate** - Provides encryption but not authentication (CA not trusted by default). This is expected and acceptable for localhost connections.

For each user:
- Unique certificate with unique serial number
- Unique private key (never shared)
- Stored in sandboxed documents directory
- Not accessible to other apps or users

## Testing

```bash
# After first launch, verify unique certificate
openssl x509 -in ~/Documents/server.crt -noout -serial -dates
```

Each device will show different serial numbers, proving uniqueness.

## Troubleshooting

If certificate generation fails:
1. Check logs for: "Generating unique SSL certificate for localhost at runtime..."
2. Verify documents directory is writable
3. Ensure Security framework is available

To force regeneration:
```swift
SSLCertificateGenerator.removeCertificates()
// Next launch will generate new certificate
```

## Summary

- ✅ Certificates generated at **runtime** for each user
- ✅ **No bundled certificates** in the app
- ✅ **No shared secrets** between users
- ✅ Uses iOS **Security framework** for cryptography
- ✅ **Random serial numbers** ensure uniqueness
- ✅ Stored in **sandboxed** documents directory

Each user has their own unique cryptographic identity.
