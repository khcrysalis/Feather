// Jackson Coxson
// Bindings to idevice - https://github.com/jkcoxson/idevice

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/socket.h>
#include "plist/plist.h"

#define LOCKDOWN_PORT 62078

typedef enum AfcFopenMode {
  AfcRdOnly = 1,
  AfcRw = 2,
  AfcWrOnly = 3,
  AfcWr = 4,
  AfcAppend = 5,
  AfcRdAppend = 6,
} AfcFopenMode;

/**
 * Link type for creating hard or symbolic links
 */
typedef enum AfcLinkType {
  Hard = 1,
  Symbolic = 2,
} AfcLinkType;

typedef enum IdeviceErrorCode {
  IdeviceSuccess = 0,
  Socket = -1,
  Tls = -2,
  TlsBuilderFailed = -3,
  Plist = -4,
  Utf8 = -5,
  UnexpectedResponse = -6,
  GetProhibited = -7,
  SessionInactive = -8,
  InvalidHostID = -9,
  NoEstablishedConnection = -10,
  HeartbeatSleepyTime = -11,
  HeartbeatTimeout = -12,
  NotFound = -13,
  CdtunnelPacketTooShort = -14,
  CdtunnelPacketInvalidMagic = -15,
  PacketSizeMismatch = -16,
  Json = -17,
  DeviceNotFound = -18,
  DeviceLocked = -19,
  UsbConnectionRefused = -20,
  UsbBadCommand = -21,
  UsbBadDevice = -22,
  UsbBadVersion = -23,
  BadBuildManifest = -24,
  ImageNotMounted = -25,
  Reqwest = -26,
  InternalError = -27,
  Xpc = -28,
  NsKeyedArchiveError = -29,
  UnknownAuxValueType = -30,
  UnknownChannel = -31,
  AddrParseError = -32,
  DisableMemoryLimitFailed = -33,
  NotEnoughBytes = -34,
  Utf8Error = -35,
  InvalidArgument = -36,
  UnknownErrorType = -37,
  AdapterIOFailed = -996,
  ServiceNotFound = -997,
  BufferTooSmall = -998,
  InvalidString = -999,
  InvalidArg = -1000,
} IdeviceErrorCode;

typedef enum IdeviceLogLevel {
  Disabled = 0,
  ErrorLevel = 1,
  Warn = 2,
  Info = 3,
  Debug = 4,
  Trace = 5,
} IdeviceLogLevel;

typedef enum IdeviceLoggerError {
  Success = 0,
  FileError = -1,
  AlreadyInitialized = -2,
  InvalidPathString = -3,
} IdeviceLoggerError;

typedef struct AdapterHandle AdapterHandle;

typedef struct AfcClientHandle AfcClientHandle;

/**
 * Handle for an open file on the device
 */
typedef struct AfcFileHandle AfcFileHandle;

typedef struct AmfiClientHandle AmfiClientHandle;

typedef struct CoreDeviceProxyHandle CoreDeviceProxyHandle;

/**
 * Opaque handle to a DebugProxyClient
 */
typedef struct DebugProxyAdapterHandle DebugProxyAdapterHandle;

typedef struct HeartbeatClientHandle HeartbeatClientHandle;

/**
 * Opaque C-compatible handle to an Idevice connection
 */
typedef struct IdeviceHandle IdeviceHandle;

/**
 * Opaque C-compatible handle to a PairingFile
 */
typedef struct IdevicePairingFile IdevicePairingFile;

typedef struct IdeviceSocketHandle IdeviceSocketHandle;

typedef struct ImageMounterHandle ImageMounterHandle;

typedef struct InstallationProxyClientHandle InstallationProxyClientHandle;

/**
 * Opaque handle to a ProcessControlClient
 */
typedef struct LocationSimulationAdapterHandle LocationSimulationAdapterHandle;

typedef struct LockdowndClientHandle LockdowndClientHandle;

/**
 * Opaque handle to a ProcessControlClient
 */
typedef struct ProcessControlAdapterHandle ProcessControlAdapterHandle;

/**
 * Opaque handle to a RemoteServerClient
 */
typedef struct RemoteServerAdapterHandle RemoteServerAdapterHandle;

typedef struct SpringBoardServicesClientHandle SpringBoardServicesClientHandle;

typedef struct TcpProviderHandle TcpProviderHandle;

typedef struct UsbmuxdAddrHandle UsbmuxdAddrHandle;

typedef struct UsbmuxdConnectionHandle UsbmuxdConnectionHandle;

typedef struct UsbmuxdProviderHandle UsbmuxdProviderHandle;

/**
 * Opaque handle to an XPCDevice
 */
typedef struct XPCDeviceAdapterHandle XPCDeviceAdapterHandle;

typedef struct sockaddr sockaddr;

/**
 * File information structure for C bindings
 */
typedef struct AfcFileInfo {
  size_t size;
  size_t blocks;
  int64_t creation;
  int64_t modified;
  char *st_nlink;
  char *st_ifmt;
  char *st_link_target;
} AfcFileInfo;

/**
 * Device information structure for C bindings
 */
typedef struct AfcDeviceInfo {
  char *model;
  size_t total_bytes;
  size_t free_bytes;
  size_t block_size;
} AfcDeviceInfo;

/**
 * Represents a debugserver command
 */
typedef struct DebugserverCommandHandle {
  char *name;
  char **argv;
  uintptr_t argv_count;
} DebugserverCommandHandle;

/**
 * Opaque handle to an XPCService
 */
typedef struct XPCServiceHandle {
  char *entitlement;
  uint16_t port;
  bool uses_remote_xpc;
  char **features;
  uintptr_t features_count;
  int64_t service_version;
} XPCServiceHandle;

/**
 * Creates a new Idevice connection
 *
 * # Arguments
 * * [`socket`] - Socket for communication with the device
 * * [`label`] - Label for the connection
 * * [`idevice`] - On success, will be set to point to a newly allocated Idevice handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `label` must be a valid null-terminated C string
 * `idevice` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode idevice_new(struct IdeviceSocketHandle *socket,
                                  const char *label,
                                  struct IdeviceHandle **idevice);

/**
 * Creates a new Idevice connection
 *
 * # Arguments
 * * [`addr`] - The socket address to connect to
 * * [`addr_len`] - Length of the socket
 * * [`label`] - Label for the connection
 * * [`idevice`] - On success, will be set to point to a newly allocated Idevice handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `addr` must be a valid sockaddr
 * `label` must be a valid null-terminated C string
 * `idevice` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode idevice_new_tcp_socket(const struct sockaddr *addr,
                                             socklen_t addr_len,
                                             const char *label,
                                             struct IdeviceHandle **idevice);

/**
 * Gets the device type
 *
 * # Arguments
 * * [`idevice`] - The Idevice handle
 * * [`device_type`] - On success, will be set to point to a newly allocated string containing the device type
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `idevice` must be a valid, non-null pointer to an Idevice handle
 * `device_type` must be a valid, non-null pointer to a location where the string pointer will be stored
 */
enum IdeviceErrorCode idevice_get_type(struct IdeviceHandle *idevice,
                                       char **device_type);

/**
 * Performs RSD checkin
 *
 * # Arguments
 * * [`idevice`] - The Idevice handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `idevice` must be a valid, non-null pointer to an Idevice handle
 */
enum IdeviceErrorCode idevice_rsd_checkin(struct IdeviceHandle *idevice);

/**
 * Starts a TLS session
 *
 * # Arguments
 * * [`idevice`] - The Idevice handle
 * * [`pairing_file`] - The pairing file to use for TLS
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `idevice` must be a valid, non-null pointer to an Idevice handle
 * `pairing_file` must be a valid, non-null pointer to a pairing file handle
 */
enum IdeviceErrorCode idevice_start_session(struct IdeviceHandle *idevice,
                                            const struct IdevicePairingFile *pairing_file);

/**
 * Frees an Idevice handle
 *
 * # Arguments
 * * [`idevice`] - The Idevice handle to free
 *
 * # Safety
 * `idevice` must be a valid pointer to an Idevice handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void idevice_free(struct IdeviceHandle *idevice);

/**
 * Frees a string allocated by this library
 *
 * # Arguments
 * * [`string`] - The string to free
 *
 * # Safety
 * `string` must be a valid pointer to a string that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void idevice_string_free(char *string);

/**
 * Connects the adapter to a specific port
 *
 * # Arguments
 * * [`handle`] - The adapter handle
 * * [`port`] - The port to connect to
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode adapter_connect(struct AdapterHandle *handle, uint16_t port);

/**
 * Enables PCAP logging for the adapter
 *
 * # Arguments
 * * [`handle`] - The adapter handle
 * * [`path`] - The path to save the PCAP file (null-terminated string)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 * `path` must be a valid null-terminated string
 */
enum IdeviceErrorCode adapter_pcap(struct AdapterHandle *handle, const char *path);

/**
 * Closes the adapter connection
 *
 * # Arguments
 * * [`handle`] - The adapter handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode adapter_close(struct AdapterHandle *handle);

/**
 * Sends data through the adapter
 *
 * # Arguments
 * * [`handle`] - The adapter handle
 * * [`data`] - The data to send
 * * [`length`] - The length of the data
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 * `data` must be a valid pointer to at least `length` bytes
 */
enum IdeviceErrorCode adapter_send(struct AdapterHandle *handle,
                                   const uint8_t *data,
                                   uintptr_t length);

/**
 * Receives data from the adapter
 *
 * # Arguments
 * * [`handle`] - The adapter handle
 * * [`data`] - Pointer to a buffer where the received data will be stored
 * * [`length`] - Pointer to store the actual length of received data
 * * [`max_length`] - Maximum number of bytes that can be stored in `data`
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 * `data` must be a valid pointer to at least `max_length` bytes
 * `length` must be a valid pointer to a usize
 */
enum IdeviceErrorCode adapter_recv(struct AdapterHandle *handle,
                                   uint8_t *data,
                                   uintptr_t *length,
                                   uintptr_t max_length);

/**
 * Connects to the AFC service using a TCP provider
 *
 * # Arguments
 * * [`provider`] - A TcpProvider
 * * [`client`] - On success, will be set to point to a newly allocated AfcClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode afc_client_connect_tcp(struct TcpProviderHandle *provider,
                                             struct AfcClientHandle **client);

/**
 * Connects to the AFC service using a Usbmuxd provider
 *
 * # Arguments
 * * [`provider`] - A UsbmuxdProvider
 * * [`client`] - On success, will be set to point to a newly allocated AfcClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode afc_client_connect_usbmuxd(struct UsbmuxdProviderHandle *provider,
                                                 struct AfcClientHandle **client);

/**
 * Creates a new AfcClient from an existing Idevice connection
 *
 * # Arguments
 * * [`socket`] - An IdeviceSocket handle
 * * [`client`] - On success, will be set to point to a newly allocated AfcClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `socket` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode afc_client_new(struct IdeviceHandle *socket, struct AfcClientHandle **client);

/**
 * Frees an AfcClient handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to the handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void afc_client_free(struct AfcClientHandle *handle);

/**
 * Lists the contents of a directory on the device
 *
 * # Arguments
 * * [`client`] - A valid AfcClient handle
 * * [`path`] - Path to the directory to list (UTF-8 null-terminated)
 * * [`entries`] - Will be set to point to an array of directory entries
 * * [`count`] - Will be set to the number of entries
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid and non-null
 * `path` must be a valid null-terminated C string
 */
enum IdeviceErrorCode afc_list_directory(struct AfcClientHandle *client,
                                         const char *path,
                                         char ***entries,
                                         size_t *count);

/**
 * Creates a new directory on the device
 *
 * # Arguments
 * * [`client`] - A valid AfcClient handle
 * * [`path`] - Path of the directory to create (UTF-8 null-terminated)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `path` must be a valid null-terminated C string
 */
enum IdeviceErrorCode afc_make_directory(struct AfcClientHandle *client, const char *path);

/**
 * Retrieves information about a file or directory
 *
 * # Arguments
 * * [`client`] - A valid AfcClient handle
 * * [`path`] - Path to the file or directory (UTF-8 null-terminated)
 * * [`info`] - Will be populated with file information
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` and `path` must be valid pointers
 * `info` must be a valid pointer to an AfcFileInfo struct
 */
enum IdeviceErrorCode afc_get_file_info(struct AfcClientHandle *client,
                                        const char *path,
                                        struct AfcFileInfo *info);

/**
 * Frees memory allocated by afc_get_file_info
 *
 * # Arguments
 * * [`info`] - Pointer to AfcFileInfo struct to free
 *
 * # Safety
 * `info` must be a valid pointer to an AfcFileInfo struct previously returned by afc_get_file_info
 */
void afc_file_info_free(struct AfcFileInfo *info);

/**
 * Retrieves information about the device's filesystem
 *
 * # Arguments
 * * [`client`] - A valid AfcClient handle
 * * [`info`] - Will be populated with device information
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` and `info` must be valid pointers
 */
enum IdeviceErrorCode afc_get_device_info(struct AfcClientHandle *client,
                                          struct AfcDeviceInfo *info);

/**
 * Frees memory allocated by afc_get_device_info
 *
 * # Arguments
 * * [`info`] - Pointer to AfcDeviceInfo struct to free
 *
 * # Safety
 * `info` must be a valid pointer to an AfcDeviceInfo struct previously returned by afc_get_device_info
 */
void afc_device_info_free(struct AfcDeviceInfo *info);

/**
 * Removes a file or directory
 *
 * # Arguments
 * * [`client`] - A valid AfcClient handle
 * * [`path`] - Path to the file or directory to remove (UTF-8 null-terminated)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `path` must be a valid null-terminated C string
 */
enum IdeviceErrorCode afc_remove_path(struct AfcClientHandle *client, const char *path);

/**
 * Recursively removes a directory and all its contents
 *
 * # Arguments
 * * [`client`] - A valid AfcClient handle
 * * [`path`] - Path to the directory to remove (UTF-8 null-terminated)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `path` must be a valid null-terminated C string
 */
enum IdeviceErrorCode afc_remove_path_and_contents(struct AfcClientHandle *client,
                                                   const char *path);

/**
 * Opens a file on the device
 *
 * # Arguments
 * * [`client`] - A valid AfcClient handle
 * * [`path`] - Path to the file to open (UTF-8 null-terminated)
 * * [`mode`] - File open mode
 * * [`handle`] - Will be set to a new file handle on success
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid and non-null
 * `path` must be a valid null-terminated C string
 */
enum IdeviceErrorCode afc_file_open(struct AfcClientHandle *client,
                                    const char *path,
                                    enum AfcFopenMode mode,
                                    struct AfcFileHandle **handle);

/**
 * Closes a file handle
 *
 * # Arguments
 * * [`handle`] - File handle to close
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode afc_file_close(struct AfcFileHandle *handle);

/**
 * Reads data from an open file
 *
 * # Arguments
 * * [`handle`] - File handle to read from
 * * [`data`] - Will be set to point to the read data
 * * [`length`] - Will be set to the length of the read data
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid and non-null
 */
enum IdeviceErrorCode afc_file_read(struct AfcFileHandle *handle, uint8_t **data, size_t *length);

/**
 * Writes data to an open file
 *
 * # Arguments
 * * [`handle`] - File handle to write to
 * * [`data`] - Data to write
 * * [`length`] - Length of data to write
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid and non-null
 * `data` must point to at least `length` bytes
 */
enum IdeviceErrorCode afc_file_write(struct AfcFileHandle *handle,
                                     const uint8_t *data,
                                     size_t length);

/**
 * Creates a hard or symbolic link
 *
 * # Arguments
 * * [`client`] - A valid AfcClient handle
 * * [`target`] - Target path of the link (UTF-8 null-terminated)
 * * [`source`] - Path where the link should be created (UTF-8 null-terminated)
 * * [`link_type`] - Type of link to create
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid and non-null
 * `target` and `source` must be valid null-terminated C strings
 */
enum IdeviceErrorCode afc_make_link(struct AfcClientHandle *client,
                                    const char *target,
                                    const char *source,
                                    enum AfcLinkType link_type);

/**
 * Renames a file or directory
 *
 * # Arguments
 * * [`client`] - A valid AfcClient handle
 * * [`source`] - Current path of the file/directory (UTF-8 null-terminated)
 * * [`target`] - New path for the file/directory (UTF-8 null-terminated)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid and non-null
 * `source` and `target` must be valid null-terminated C strings
 */
enum IdeviceErrorCode afc_rename_path(struct AfcClientHandle *client,
                                      const char *source,
                                      const char *target);

/**
 * Automatically creates and connects to AMFI service, returning a client handle
 *
 * # Arguments
 * * [`provider`] - A TcpProvider
 * * [`client`] - On success, will be set to point to a newly allocated AmfiClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode amfi_connect_tcp(struct TcpProviderHandle *provider,
                                       struct AmfiClientHandle **client);

/**
 * Automatically creates and connects to AMFI service, returning a client handle
 *
 * # Arguments
 * * [`provider`] - A UsbmuxdProvider
 * * [`client`] - On success, will be set to point to a newly allocated AmfiClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode amfi_connect_usbmuxd(struct UsbmuxdProviderHandle *provider,
                                           struct AmfiClientHandle **client);

/**
 * Automatically creates and connects to AMFI service, returning a client handle
 *
 * # Arguments
 * * [`socket`] - An IdeviceSocket handle
 * * [`client`] - On success, will be set to point to a newly allocated AmfiClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `socket` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode amfi_new(struct IdeviceHandle *socket, struct AmfiClientHandle **client);

/**
 * Shows the option in the settings UI
 *
 * # Arguments
 * * `client` - A valid AmfiClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode amfi_reveal_developer_mode_option_in_ui(struct AmfiClientHandle *client);

/**
 * Enables developer mode on the device
 *
 * # Arguments
 * * `client` - A valid AmfiClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode amfi_enable_developer_mode(struct AmfiClientHandle *client);

/**
 * Accepts developer mode on the device
 *
 * # Arguments
 * * `client` - A valid AmfiClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode amfi_accept_developer_mode(struct AmfiClientHandle *client);

/**
 * Frees a handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to the handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void amfi_client_free(struct AmfiClientHandle *handle);

/**
 * Automatically creates and connects to Core Device Proxy, returning a client handle
 *
 * # Arguments
 * * [`provider`] - A TcpProvider
 * * [`client`] - On success, will be set to point to a newly allocated CoreDeviceProxy handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode core_device_proxy_connect_tcp(struct TcpProviderHandle *provider,
                                                    struct CoreDeviceProxyHandle **client);

/**
 * Automatically creates and connects to Core Device Proxy, returning a client handle
 *
 * # Arguments
 * * [`provider`] - A UsbmuxdProvider
 * * [`client`] - On success, will be set to point to a newly allocated CoreDeviceProxy handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode core_device_proxy_connect_usbmuxd(struct UsbmuxdProviderHandle *provider,
                                                        struct CoreDeviceProxyHandle **client);

/**
 * Automatically creates and connects to Core Device Proxy, returning a client handle
 *
 * # Arguments
 * * [`socket`] - An IdeviceSocket handle
 * * [`client`] - On success, will be set to point to a newly allocated CoreDeviceProxy handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `socket` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode core_device_proxy_new(struct IdeviceHandle *socket,
                                            struct CoreDeviceProxyHandle **client);

/**
 * Sends data through the CoreDeviceProxy tunnel
 *
 * # Arguments
 * * [`handle`] - The CoreDeviceProxy handle
 * * [`data`] - The data to send
 * * [`length`] - The length of the data
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 * `data` must be a valid pointer to at least `length` bytes
 */
enum IdeviceErrorCode core_device_proxy_send(struct CoreDeviceProxyHandle *handle,
                                             const uint8_t *data,
                                             uintptr_t length);

/**
 * Receives data from the CoreDeviceProxy tunnel
 *
 * # Arguments
 * * [`handle`] - The CoreDeviceProxy handle
 * * [`data`] - Pointer to a buffer where the received data will be stored
 * * [`length`] - Pointer to store the actual length of received data
 * * [`max_length`] - Maximum number of bytes that can be stored in `data`
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 * `data` must be a valid pointer to at least `max_length` bytes
 * `length` must be a valid pointer to a usize
 */
enum IdeviceErrorCode core_device_proxy_recv(struct CoreDeviceProxyHandle *handle,
                                             uint8_t *data,
                                             uintptr_t *length,
                                             uintptr_t max_length);

/**
 * Gets the client parameters from the handshake
 *
 * # Arguments
 * * [`handle`] - The CoreDeviceProxy handle
 * * [`mtu`] - Pointer to store the MTU value
 * * [`address`] - Pointer to store the IP address string (must be at least 16 bytes)
 * * [`netmask`] - Pointer to store the netmask string (must be at least 16 bytes)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 * `mtu` must be a valid pointer to a u16
 * `address` and `netmask` must be valid pointers to buffers of at least 16 bytes
 */
enum IdeviceErrorCode core_device_proxy_get_client_parameters(struct CoreDeviceProxyHandle *handle,
                                                              uint16_t *mtu,
                                                              char **address,
                                                              char **netmask);

/**
 * Gets the server address from the handshake
 *
 * # Arguments
 * * [`handle`] - The CoreDeviceProxy handle
 * * [`address`] - Pointer to store the server address string (must be at least 16 bytes)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 * `address` must be a valid pointer to a buffer of at least 16 bytes
 */
enum IdeviceErrorCode core_device_proxy_get_server_address(struct CoreDeviceProxyHandle *handle,
                                                           char **address);

/**
 * Gets the server RSD port from the handshake
 *
 * # Arguments
 * * [`handle`] - The CoreDeviceProxy handle
 * * [`port`] - Pointer to store the port number
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 * `port` must be a valid pointer to a u16
 */
enum IdeviceErrorCode core_device_proxy_get_server_rsd_port(struct CoreDeviceProxyHandle *handle,
                                                            uint16_t *port);

/**
 * Creates a software TCP tunnel adapter
 *
 * # Arguments
 * * [`handle`] - The CoreDeviceProxy handle
 * * [`adapter`] - Pointer to store the newly created adapter handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library, and never used again
 * `adapter` must be a valid pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode core_device_proxy_create_tcp_adapter(struct CoreDeviceProxyHandle *handle,
                                                           struct AdapterHandle **adapter);

/**
 * Frees a handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to the handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void core_device_proxy_free(struct CoreDeviceProxyHandle *handle);

/**
 * Frees a handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to the handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void adapter_free(struct AdapterHandle *handle);

/**
 * Creates a new DebugserverCommand
 *
 * # Safety
 * Caller must free with debugserver_command_free
 */
struct DebugserverCommandHandle *debugserver_command_new(const char *name,
                                                         const char *const *argv,
                                                         uintptr_t argv_count);

/**
 * Frees a DebugserverCommand
 *
 * # Safety
 * `command` must be a valid pointer or NULL
 */
void debugserver_command_free(struct DebugserverCommandHandle *command);

/**
 * Creates a new DebugProxyClient
 *
 * # Arguments
 * * [`socket`] - The socket to use for communication
 * * [`handle`] - Pointer to store the newly created DebugProxyClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `socket` must be a valid pointer to a handle allocated by this library
 * `handle` must be a valid pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode debug_proxy_adapter_new(struct AdapterHandle *socket,
                                              struct DebugProxyAdapterHandle **handle);

/**
 * Frees a DebugProxyClient handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library or NULL
 */
void debug_proxy_free(struct DebugProxyAdapterHandle *handle);

/**
 * Sends a command to the debug proxy
 *
 * # Arguments
 * * [`handle`] - The DebugProxyClient handle
 * * [`command`] - The command to send
 * * [`response`] - Pointer to store the response (caller must free)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` and `command` must be valid pointers
 * `response` must be a valid pointer to a location where the string will be stored
 */
enum IdeviceErrorCode debug_proxy_send_command(struct DebugProxyAdapterHandle *handle,
                                               struct DebugserverCommandHandle *command,
                                               char **response);

/**
 * Reads a response from the debug proxy
 *
 * # Arguments
 * * [`handle`] - The DebugProxyClient handle
 * * [`response`] - Pointer to store the response (caller must free)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer
 * `response` must be a valid pointer to a location where the string will be stored
 */
enum IdeviceErrorCode debug_proxy_read_response(struct DebugProxyAdapterHandle *handle,
                                                char **response);

/**
 * Sends raw data to the debug proxy
 *
 * # Arguments
 * * [`handle`] - The DebugProxyClient handle
 * * [`data`] - The data to send
 * * [`len`] - Length of the data
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer
 * `data` must be a valid pointer to `len` bytes
 */
enum IdeviceErrorCode debug_proxy_send_raw(struct DebugProxyAdapterHandle *handle,
                                           const uint8_t *data,
                                           uintptr_t len);

/**
 * Reads data from the debug proxy
 *
 * # Arguments
 * * [`handle`] - The DebugProxyClient handle
 * * [`len`] - Maximum number of bytes to read
 * * [`response`] - Pointer to store the response (caller must free)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer
 * `response` must be a valid pointer to a location where the string will be stored
 */
enum IdeviceErrorCode debug_proxy_read(struct DebugProxyAdapterHandle *handle,
                                       uintptr_t len,
                                       char **response);

/**
 * Sets the argv for the debug proxy
 *
 * # Arguments
 * * [`handle`] - The DebugProxyClient handle
 * * [`argv`] - NULL-terminated array of arguments
 * * [`argv_count`] - Number of arguments
 * * [`response`] - Pointer to store the response (caller must free)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer
 * `argv` must be a valid pointer to `argv_count` C strings or NULL
 * `response` must be a valid pointer to a location where the string will be stored
 */
enum IdeviceErrorCode debug_proxy_set_argv(struct DebugProxyAdapterHandle *handle,
                                           const char *const *argv,
                                           uintptr_t argv_count,
                                           char **response);

/**
 * Sends an ACK to the debug proxy
 *
 * # Arguments
 * * [`handle`] - The DebugProxyClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer
 */
enum IdeviceErrorCode debug_proxy_send_ack(struct DebugProxyAdapterHandle *handle);

/**
 * Sends a NACK to the debug proxy
 *
 * # Arguments
 * * [`handle`] - The DebugProxyClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer
 */
enum IdeviceErrorCode debug_proxy_send_nack(struct DebugProxyAdapterHandle *handle);

/**
 * Sets the ACK mode for the debug proxy
 *
 * # Arguments
 * * [`handle`] - The DebugProxyClient handle
 * * [`enabled`] - Whether ACK mode should be enabled
 *
 * # Safety
 * `handle` must be a valid pointer
 */
void debug_proxy_set_ack_mode(struct DebugProxyAdapterHandle *handle, int enabled);

/**
 * Returns the underlying socket from a DebugProxyClient
 *
 * # Arguments
 * * [`handle`] - The handle to get the socket from
 * * [`adapter`] - The newly allocated ConnectionHandle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library or NULL, and never used again
 */
enum IdeviceErrorCode debug_proxy_adapter_into_inner(struct DebugProxyAdapterHandle *handle,
                                                     struct AdapterHandle **adapter);

/**
 * Automatically creates and connects to Installation Proxy, returning a client handle
 *
 * # Arguments
 * * [`provider`] - A TcpProvider
 * * [`client`] - On success, will be set to point to a newly allocated InstallationProxyClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode heartbeat_connect_tcp(struct TcpProviderHandle *provider,
                                            struct HeartbeatClientHandle **client);

/**
 * Automatically creates and connects to Installation Proxy, returning a client handle
 *
 * # Arguments
 * * [`provider`] - A UsbmuxdProvider
 * * [`client`] - On success, will be set to point to a newly allocated InstallationProxyClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode heartbeat_connect_usbmuxd(struct UsbmuxdProviderHandle *provider,
                                                struct HeartbeatClientHandle **client);

/**
 * Automatically creates and connects to Installation Proxy, returning a client handle
 *
 * # Arguments
 * * [`socket`] - An IdeviceSocket handle
 * * [`client`] - On success, will be set to point to a newly allocated InstallationProxyClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `socket` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode heartbeat_new(struct IdeviceHandle *socket,
                                    struct HeartbeatClientHandle **client);

/**
 * Sends a polo to the device
 *
 * # Arguments
 * * `client` - A valid HeartbeatClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode heartbeat_send_polo(struct HeartbeatClientHandle *client);

/**
 * Sends a polo to the device
 *
 * # Arguments
 * * `client` - A valid HeartbeatClient handle
 * * `interval` - The time to wait for a marco
 * * `new_interval` - A pointer to set the requested marco
 *
 * # Returns
 * An error code indicating success or failure.
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode heartbeat_get_marco(struct HeartbeatClientHandle *client,
                                          uint64_t interval,
                                          uint64_t *new_interval);

/**
 * Frees a handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to the handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void heartbeat_client_free(struct HeartbeatClientHandle *handle);

/**
 * Automatically creates and connects to Installation Proxy, returning a client handle
 *
 * # Arguments
 * * [`provider`] - A TcpProvider
 * * [`client`] - On success, will be set to point to a newly allocated InstallationProxyClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode installation_proxy_connect_tcp(struct TcpProviderHandle *provider,
                                                     struct InstallationProxyClientHandle **client);

/**
 * Automatically creates and connects to Installation Proxy, returning a client handle
 *
 * # Arguments
 * * [`provider`] - A UsbmuxdProvider
 * * [`client`] - On success, will be set to point to a newly allocated InstallationProxyClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode installation_proxy_connect_usbmuxd(struct UsbmuxdProviderHandle *provider,
                                                         struct InstallationProxyClientHandle **client);

/**
 * Automatically creates and connects to Installation Proxy, returning a client handle
 *
 * # Arguments
 * * [`socket`] - An IdeviceSocket handle
 * * [`client`] - On success, will be set to point to a newly allocated InstallationProxyClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `socket` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode installation_proxy_new(struct IdeviceHandle *socket,
                                             struct InstallationProxyClientHandle **client);

/**
 * Gets installed apps on the device
 *
 * # Arguments
 * * [`client`] - A valid InstallationProxyClient handle
 * * [`application_type`] - The application type to filter by (optional, NULL for "Any")
 * * [`bundle_identifiers`] - The identifiers to filter by (optional, NULL for all apps)
 * * [`out_result`] - On success, will be set to point to a newly allocated array of PlistRef
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `out_result` must be a valid, non-null pointer to a location where the result will be stored
 */
enum IdeviceErrorCode installation_proxy_get_apps(struct InstallationProxyClientHandle *client,
                                                  const char *application_type,
                                                  const char *const *bundle_identifiers,
                                                  size_t bundle_identifiers_len,
                                                  void **out_result,
                                                  size_t *out_result_len);

/**
 * Frees a handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to the handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void installation_proxy_client_free(struct InstallationProxyClientHandle *handle);

/**
 * Installs an application package on the device
 *
 * # Arguments
 * * [`client`] - A valid InstallationProxyClient handle
 * * [`package_path`] - Path to the .ipa package in the AFC jail
 * * [`options`] - Optional installation options as a plist dictionary (can be NULL)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `package_path` must be a valid C string
 * `options` must be a valid plist dictionary or NULL
 */
enum IdeviceErrorCode installation_proxy_install(struct InstallationProxyClientHandle *client,
                                                 const char *package_path,
                                                 void *options);

/**
 * Installs an application package on the device
 *
 * # Arguments
 * * [`client`] - A valid InstallationProxyClient handle
 * * [`package_path`] - Path to the .ipa package in the AFC jail
 * * [`options`] - Optional installation options as a plist dictionary (can be NULL)
 * * [`callback`] - Progress callback function
 * * [`context`] - User context to pass to callback
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `package_path` must be a valid C string
 * `options` must be a valid plist dictionary or NULL
 */
enum IdeviceErrorCode installation_proxy_install_with_callback(struct InstallationProxyClientHandle *client,
                                                               const char *package_path,
                                                               void *options,
                                                               void (*callback)(uint64_t progress,
                                                                                void *context),
                                                               void *context);

/**
 * Upgrades an existing application on the device
 *
 * # Arguments
 * * [`client`] - A valid InstallationProxyClient handle
 * * [`package_path`] - Path to the .ipa package in the AFC jail
 * * [`options`] - Optional upgrade options as a plist dictionary (can be NULL)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `package_path` must be a valid C string
 * `options` must be a valid plist dictionary or NULL
 */
enum IdeviceErrorCode installation_proxy_upgrade(struct InstallationProxyClientHandle *client,
                                                 const char *package_path,
                                                 void *options);

/**
 * Upgrades an existing application on the device
 *
 * # Arguments
 * * [`client`] - A valid InstallationProxyClient handle
 * * [`package_path`] - Path to the .ipa package in the AFC jail
 * * [`options`] - Optional upgrade options as a plist dictionary (can be NULL)
 * * [`callback`] - Progress callback function
 * * [`context`] - User context to pass to callback
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `package_path` must be a valid C string
 * `options` must be a valid plist dictionary or NULL
 */
enum IdeviceErrorCode installation_proxy_upgrade_with_callback(struct InstallationProxyClientHandle *client,
                                                               const char *package_path,
                                                               void *options,
                                                               void (*callback)(uint64_t progress,
                                                                                void *context),
                                                               void *context);

/**
 * Uninstalls an application from the device
 *
 * # Arguments
 * * [`client`] - A valid InstallationProxyClient handle
 * * [`bundle_id`] - Bundle identifier of the application to uninstall
 * * [`options`] - Optional uninstall options as a plist dictionary (can be NULL)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `bundle_id` must be a valid C string
 * `options` must be a valid plist dictionary or NULL
 */
enum IdeviceErrorCode installation_proxy_uninstall(struct InstallationProxyClientHandle *client,
                                                   const char *bundle_id,
                                                   void *options);

/**
 * Uninstalls an application from the device
 *
 * # Arguments
 * * [`client`] - A valid InstallationProxyClient handle
 * * [`bundle_id`] - Bundle identifier of the application to uninstall
 * * [`options`] - Optional uninstall options as a plist dictionary (can be NULL)
 * * [`callback`] - Progress callback function
 * * [`context`] - User context to pass to callback
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `bundle_id` must be a valid C string
 * `options` must be a valid plist dictionary or NULL
 */
enum IdeviceErrorCode installation_proxy_uninstall_with_callback(struct InstallationProxyClientHandle *client,
                                                                 const char *bundle_id,
                                                                 void *options,
                                                                 void (*callback)(uint64_t progress,
                                                                                  void *context),
                                                                 void *context);

/**
 * Checks if the device capabilities match the required capabilities
 *
 * # Arguments
 * * [`client`] - A valid InstallationProxyClient handle
 * * [`capabilities`] - Array of plist values representing required capabilities
 * * [`capabilities_len`] - Length of the capabilities array
 * * [`options`] - Optional check options as a plist dictionary (can be NULL)
 * * [`out_result`] - Will be set to true if all capabilities are supported, false otherwise
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `capabilities` must be a valid array of plist values or NULL
 * `options` must be a valid plist dictionary or NULL
 * `out_result` must be a valid pointer to a bool
 */
enum IdeviceErrorCode installation_proxy_check_capabilities_match(struct InstallationProxyClientHandle *client,
                                                                  void *const *capabilities,
                                                                  size_t capabilities_len,
                                                                  void *options,
                                                                  bool *out_result);

/**
 * Browses installed applications on the device
 *
 * # Arguments
 * * [`client`] - A valid InstallationProxyClient handle
 * * [`options`] - Optional browse options as a plist dictionary (can be NULL)
 * * [`out_result`] - On success, will be set to point to a newly allocated array of PlistRef
 * * [`out_result_len`] - Will be set to the length of the result array
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `options` must be a valid plist dictionary or NULL
 * `out_result` must be a valid, non-null pointer to a location where the result will be stored
 * `out_result_len` must be a valid, non-null pointer to a location where the length will be stored
 */
enum IdeviceErrorCode installation_proxy_browse(struct InstallationProxyClientHandle *client,
                                                void *options,
                                                void **out_result,
                                                size_t *out_result_len);

/**
 * Creates a new ProcessControlClient from a RemoteServerClient
 *
 * # Arguments
 * * [`server`] - The RemoteServerClient to use
 * * [`handle`] - Pointer to store the newly created ProcessControlClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `server` must be a valid pointer to a handle allocated by this library
 * `handle` must be a valid pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode location_simulation_new(struct RemoteServerAdapterHandle *server,
                                              struct LocationSimulationAdapterHandle **handle);

/**
 * Frees a ProcessControlClient handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library or NULL
 */
void location_simulation_free(struct LocationSimulationAdapterHandle *handle);

/**
 * Clears the location set
 *
 * # Arguments
 * * [`handle`] - The LocationSimulation handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid or NULL where appropriate
 */
enum IdeviceErrorCode location_simulation_clear(struct LocationSimulationAdapterHandle *handle);

/**
 * Sets the location
 *
 * # Arguments
 * * [`handle`] - The LocationSimulation handle
 * * [`latitude`] - The latitude to set
 * * [`longitude`] - The longitude to set
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid or NULL where appropriate
 */
enum IdeviceErrorCode location_simulation_set(struct LocationSimulationAdapterHandle *handle,
                                              double latitude,
                                              double longitude);

/**
 * Connects to lockdownd service using TCP provider
 *
 * # Arguments
 * * [`provider`] - A TcpProvider
 * * [`client`] - On success, will be set to point to a newly allocated LockdowndClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode lockdownd_connect_tcp(struct TcpProviderHandle *provider,
                                            struct LockdowndClientHandle **client);

/**
 * Connects to lockdownd service using Usbmuxd provider
 *
 * # Arguments
 * * [`provider`] - A UsbmuxdProvider
 * * [`client`] - On success, will be set to point to a newly allocated LockdowndClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode lockdownd_connect_usbmuxd(struct UsbmuxdProviderHandle *provider,
                                                struct LockdowndClientHandle **client);

/**
 * Creates a new LockdowndClient from an existing Idevice connection
 *
 * # Arguments
 * * [`socket`] - An IdeviceSocket handle
 * * [`client`] - On success, will be set to point to a newly allocated LockdowndClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `socket` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode lockdownd_new(struct IdeviceHandle *socket,
                                    struct LockdowndClientHandle **client);

/**
 * Starts a session with lockdownd
 *
 * # Arguments
 * * `client` - A valid LockdowndClient handle
 * * `pairing_file` - An IdevicePairingFile alocated by this library
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `pairing_file` must be a valid plist_t containing a pairing file
 */
enum IdeviceErrorCode lockdownd_start_session(struct LockdowndClientHandle *client,
                                              struct IdevicePairingFile *pairing_file);

/**
 * Starts a service through lockdownd
 *
 * # Arguments
 * * `client` - A valid LockdowndClient handle
 * * `identifier` - The service identifier to start (null-terminated string)
 * * `port` - Pointer to store the returned port number
 * * `ssl` - Pointer to store whether SSL should be enabled
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `identifier` must be a valid null-terminated string
 * `port` and `ssl` must be valid pointers
 */
enum IdeviceErrorCode lockdownd_start_service(struct LockdowndClientHandle *client,
                                              const char *identifier,
                                              uint16_t *port,
                                              bool *ssl);

/**
 * Gets a value from lockdownd
 *
 * # Arguments
 * * `client` - A valid LockdowndClient handle
 * * `key` - The value to get (null-terminated string)
 * * `domain` - The value to get (null-terminated string)
 * * `out_plist` - Pointer to store the returned plist value
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `value` must be a valid null-terminated string
 * `out_plist` must be a valid pointer to store the plist
 */
enum IdeviceErrorCode lockdownd_get_value(struct LockdowndClientHandle *client,
                                          const char *key,
                                          const char *domain,
                                          void **out_plist);

/**
 * Gets all values from lockdownd
 *
 * # Arguments
 * * `client` - A valid LockdowndClient handle
 * * `out_plist` - Pointer to store the returned plist dictionary
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `out_plist` must be a valid pointer to store the plist
 */
enum IdeviceErrorCode lockdownd_get_all_values(struct LockdowndClientHandle *client,
                                               void **out_plist);

/**
 * Frees a LockdowndClient handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to the handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void lockdownd_client_free(struct LockdowndClientHandle *handle);

/**
 * Initializes the logger
 *
 * # Arguments
 * * [`console_level`] - The level to log to the file
 * * [`file_level`] - The level to log to the file
 * * [`file_path`] - If not null, the file to write logs to
 *
 * ## Log Level
 * 0. Disabled
 * 1. Error
 * 2. Warn
 * 3. Info
 * 4. Debug
 * 5. Trace
 *
 * # Returns
 * 0 for success, -1 if the file couldn't be created, -2 if a logger has been initialized, -3 for invalid path string
 *
 * # Safety
 * Pass a valid CString for file_path. Pass valid log levels according to the enum
 */
enum IdeviceLoggerError idevice_init_logger(enum IdeviceLogLevel console_level,
                                            enum IdeviceLogLevel file_level,
                                            char *file_path);

/**
 * Connects to the Image Mounter service using a TCP provider
 *
 * # Arguments
 * * [`provider`] - A TcpProvider
 * * [`client`] - On success, will be set to point to a newly allocated ImageMounter handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode image_mounter_connect_tcp(struct TcpProviderHandle *provider,
                                                struct ImageMounterHandle **client);

/**
 * Connects to the Image Mounter service using a Usbmuxd provider
 *
 * # Arguments
 * * [`provider`] - A UsbmuxdProvider
 * * [`client`] - On success, will be set to point to a newly allocated ImageMounter handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode image_mounter_connect_usbmuxd(struct UsbmuxdProviderHandle *provider,
                                                    struct ImageMounterHandle **client);

/**
 * Creates a new ImageMounter client from an existing Idevice connection
 *
 * # Arguments
 * * [`socket`] - An IdeviceSocket handle
 * * [`client`] - On success, will be set to point to a newly allocated ImageMounter handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `socket` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode image_mounter_new(struct IdeviceHandle *socket,
                                        struct ImageMounterHandle **client);

/**
 * Frees an ImageMounter handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to the handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void image_mounter_free(struct ImageMounterHandle *handle);

/**
 * Gets a list of mounted devices
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`devices`] - Will be set to point to a slice of device plists on success
 * * [`devices_len`] - Will be set to the number of devices copied
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `devices` must be a valid, non-null pointer to a location where the plist will be stored
 */
enum IdeviceErrorCode image_mounter_copy_devices(struct ImageMounterHandle *client,
                                                 void **devices,
                                                 size_t *devices_len);

/**
 * Looks up an image and returns its signature
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`image_type`] - The type of image to look up
 * * [`signature`] - Will be set to point to the signature data on success
 * * [`signature_len`] - Will be set to the length of the signature data
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `image_type` must be a valid null-terminated C string
 * `signature` and `signature_len` must be valid pointers
 */
enum IdeviceErrorCode image_mounter_lookup_image(struct ImageMounterHandle *client,
                                                 const char *image_type,
                                                 uint8_t **signature,
                                                 size_t *signature_len);

/**
 * Uploads an image to the device
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`image_type`] - The type of image being uploaded
 * * [`image`] - Pointer to the image data
 * * [`image_len`] - Length of the image data
 * * [`signature`] - Pointer to the signature data
 * * [`signature_len`] - Length of the signature data
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid and non-null
 * `image_type` must be a valid null-terminated C string
 */
enum IdeviceErrorCode image_mounter_upload_image(struct ImageMounterHandle *client,
                                                 const char *image_type,
                                                 const uint8_t *image,
                                                 size_t image_len,
                                                 const uint8_t *signature,
                                                 size_t signature_len);

/**
 * Mounts an image on the device
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`image_type`] - The type of image being mounted
 * * [`signature`] - Pointer to the signature data
 * * [`signature_len`] - Length of the signature data
 * * [`trust_cache`] - Pointer to trust cache data (optional)
 * * [`trust_cache_len`] - Length of trust cache data (0 if none)
 * * [`info_plist`] - Pointer to info plist (optional)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid (except optional ones which can be null)
 * `image_type` must be a valid null-terminated C string
 */
enum IdeviceErrorCode image_mounter_mount_image(struct ImageMounterHandle *client,
                                                const char *image_type,
                                                const uint8_t *signature,
                                                size_t signature_len,
                                                const uint8_t *trust_cache,
                                                size_t trust_cache_len,
                                                const void *info_plist);

/**
 * Unmounts an image from the device
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`mount_path`] - The path where the image is mounted
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `mount_path` must be a valid null-terminated C string
 */
enum IdeviceErrorCode image_mounter_unmount_image(struct ImageMounterHandle *client,
                                                  const char *mount_path);

/**
 * Queries the developer mode status
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`status`] - Will be set to the developer mode status (1 = enabled, 0 = disabled)
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `status` must be a valid pointer
 */
enum IdeviceErrorCode image_mounter_query_developer_mode_status(struct ImageMounterHandle *client,
                                                                int *status);

/**
 * Mounts a developer image
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`image`] - Pointer to the image data
 * * [`image_len`] - Length of the image data
 * * [`signature`] - Pointer to the signature data
 * * [`signature_len`] - Length of the signature data
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid and non-null
 */
enum IdeviceErrorCode image_mounter_mount_developer(struct ImageMounterHandle *client,
                                                    const uint8_t *image,
                                                    size_t image_len,
                                                    const uint8_t *signature,
                                                    size_t signature_len);

/**
 * Queries the personalization manifest from the device
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`image_type`] - The type of image to query
 * * [`signature`] - Pointer to the signature data
 * * [`signature_len`] - Length of the signature data
 * * [`manifest`] - Will be set to point to the manifest data on success
 * * [`manifest_len`] - Will be set to the length of the manifest data
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid and non-null
 * `image_type` must be a valid null-terminated C string
 */
enum IdeviceErrorCode image_mounter_query_personalization_manifest(struct ImageMounterHandle *client,
                                                                   const char *image_type,
                                                                   const uint8_t *signature,
                                                                   size_t signature_len,
                                                                   uint8_t **manifest,
                                                                   size_t *manifest_len);

/**
 * Queries the nonce from the device
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`personalized_image_type`] - The type of image to query (optional)
 * * [`nonce`] - Will be set to point to the nonce data on success
 * * [`nonce_len`] - Will be set to the length of the nonce data
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client`, `nonce`, and `nonce_len` must be valid pointers
 * `personalized_image_type` can be NULL
 */
enum IdeviceErrorCode image_mounter_query_nonce(struct ImageMounterHandle *client,
                                                const char *personalized_image_type,
                                                uint8_t **nonce,
                                                size_t *nonce_len);

/**
 * Queries personalization identifiers from the device
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`image_type`] - The type of image to query (optional)
 * * [`identifiers`] - Will be set to point to the identifiers plist on success
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` and `identifiers` must be valid pointers
 * `image_type` can be NULL
 */
enum IdeviceErrorCode image_mounter_query_personalization_identifiers(struct ImageMounterHandle *client,
                                                                      const char *image_type,
                                                                      void **identifiers);

/**
 * Rolls the personalization nonce
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode image_mounter_roll_personalization_nonce(struct ImageMounterHandle *client);

/**
 * Rolls the cryptex nonce
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode image_mounter_roll_cryptex_nonce(struct ImageMounterHandle *client);

/**
 * Mounts a personalized developer image
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`provider`] - A valid provider handle
 * * [`image`] - Pointer to the image data
 * * [`image_len`] - Length of the image data
 * * [`trust_cache`] - Pointer to the trust cache data
 * * [`trust_cache_len`] - Length of the trust cache data
 * * [`build_manifest`] - Pointer to the build manifest data
 * * [`build_manifest_len`] - Length of the build manifest data
 * * [`info_plist`] - Pointer to info plist (optional)
 * * [`unique_chip_id`] - The device's unique chip ID
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid (except optional ones which can be null)
 */
enum IdeviceErrorCode image_mounter_mount_personalized_usbmuxd(struct ImageMounterHandle *client,
                                                               struct UsbmuxdProviderHandle *provider,
                                                               const uint8_t *image,
                                                               size_t image_len,
                                                               const uint8_t *trust_cache,
                                                               size_t trust_cache_len,
                                                               const uint8_t *build_manifest,
                                                               size_t build_manifest_len,
                                                               const void *info_plist,
                                                               uint64_t unique_chip_id);

/**
 * Mounts a personalized developer image
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`provider`] - A valid provider handle
 * * [`image`] - Pointer to the image data
 * * [`image_len`] - Length of the image data
 * * [`trust_cache`] - Pointer to the trust cache data
 * * [`trust_cache_len`] - Length of the trust cache data
 * * [`build_manifest`] - Pointer to the build manifest data
 * * [`build_manifest_len`] - Length of the build manifest data
 * * [`info_plist`] - Pointer to info plist (optional)
 * * [`unique_chip_id`] - The device's unique chip ID
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid (except optional ones which can be null)
 */
enum IdeviceErrorCode image_mounter_mount_personalized_tcp(struct ImageMounterHandle *client,
                                                           struct TcpProviderHandle *provider,
                                                           const uint8_t *image,
                                                           size_t image_len,
                                                           const uint8_t *trust_cache,
                                                           size_t trust_cache_len,
                                                           const uint8_t *build_manifest,
                                                           size_t build_manifest_len,
                                                           const void *info_plist,
                                                           uint64_t unique_chip_id);

/**
 * Mounts a personalized developer image with progress callback
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`provider`] - A valid provider handle
 * * [`image`] - Pointer to the image data
 * * [`image_len`] - Length of the image data
 * * [`trust_cache`] - Pointer to the trust cache data
 * * [`trust_cache_len`] - Length of the trust cache data
 * * [`build_manifest`] - Pointer to the build manifest data
 * * [`build_manifest_len`] - Length of the build manifest data
 * * [`info_plist`] - Pointer to info plist (optional)
 * * [`unique_chip_id`] - The device's unique chip ID
 * * [`callback`] - Progress callback function
 * * [`context`] - User context to pass to callback
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid (except optional ones which can be null)
 */
enum IdeviceErrorCode image_mounter_mount_personalized_usbmuxd_with_callback(struct ImageMounterHandle *client,
                                                                             struct UsbmuxdProviderHandle *provider,
                                                                             const uint8_t *image,
                                                                             size_t image_len,
                                                                             const uint8_t *trust_cache,
                                                                             size_t trust_cache_len,
                                                                             const uint8_t *build_manifest,
                                                                             size_t build_manifest_len,
                                                                             const void *info_plist,
                                                                             uint64_t unique_chip_id,
                                                                             void (*callback)(size_t progress,
                                                                                              size_t total,
                                                                                              void *context),
                                                                             void *context);

/**
 * Mounts a personalized developer image with progress callback
 *
 * # Arguments
 * * [`client`] - A valid ImageMounter handle
 * * [`provider`] - A valid provider handle
 * * [`image`] - Pointer to the image data
 * * [`image_len`] - Length of the image data
 * * [`trust_cache`] - Pointer to the trust cache data
 * * [`trust_cache_len`] - Length of the trust cache data
 * * [`build_manifest`] - Pointer to the build manifest data
 * * [`build_manifest_len`] - Length of the build manifest data
 * * [`info_plist`] - Pointer to info plist (optional)
 * * [`unique_chip_id`] - The device's unique chip ID
 * * [`callback`] - Progress callback function
 * * [`context`] - User context to pass to callback
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid (except optional ones which can be null)
 */
enum IdeviceErrorCode image_mounter_mount_personalized_tcp_with_callback(struct ImageMounterHandle *client,
                                                                         struct TcpProviderHandle *provider,
                                                                         const uint8_t *image,
                                                                         size_t image_len,
                                                                         const uint8_t *trust_cache,
                                                                         size_t trust_cache_len,
                                                                         const uint8_t *build_manifest,
                                                                         size_t build_manifest_len,
                                                                         const void *info_plist,
                                                                         uint64_t unique_chip_id,
                                                                         void (*callback)(size_t progress,
                                                                                          size_t total,
                                                                                          void *context),
                                                                         void *context);

/**
 * Reads a pairing file from the specified path
 *
 * # Arguments
 * * [`path`] - Path to the pairing file
 * * [`pairing_file`] - On success, will be set to point to a newly allocated pairing file instance
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `path` must be a valid null-terminated C string
 * `pairing_file` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode idevice_pairing_file_read(const char *path,
                                                struct IdevicePairingFile **pairing_file);

/**
 * Parses a pairing file from a byte buffer
 *
 * # Arguments
 * * [`data`] - Pointer to the buffer containing pairing file data
 * * [`size`] - Size of the buffer in bytes
 * * [`pairing_file`] - On success, will be set to point to a newly allocated pairing file instance
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `data` must be a valid pointer to a buffer of at least `size` bytes
 * `pairing_file` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode idevice_pairing_file_from_bytes(const uint8_t *data,
                                                      uintptr_t size,
                                                      struct IdevicePairingFile **pairing_file);

/**
 * Serializes a pairing file to XML format
 *
 * # Arguments
 * * [`pairing_file`] - The pairing file to serialize
 * * [`data`] - On success, will be set to point to a newly allocated buffer containing the serialized data
 * * [`size`] - On success, will be set to the size of the allocated buffer
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `pairing_file` must be a valid, non-null pointer to a pairing file instance
 * `data` must be a valid, non-null pointer to a location where the buffer pointer will be stored
 * `size` must be a valid, non-null pointer to a location where the buffer size will be stored
 */
enum IdeviceErrorCode idevice_pairing_file_serialize(const struct IdevicePairingFile *pairing_file,
                                                     uint8_t **data,
                                                     uintptr_t *size);

/**
 * Frees a pairing file instance
 *
 * # Arguments
 * * [`pairing_file`] - The pairing file to free
 *
 * # Safety
 * `pairing_file` must be a valid pointer to a pairing file instance that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void idevice_pairing_file_free(struct IdevicePairingFile *pairing_file);

/**
 * Creates a new ProcessControlClient from a RemoteServerClient
 *
 * # Arguments
 * * [`server`] - The RemoteServerClient to use
 * * [`handle`] - Pointer to store the newly created ProcessControlClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `server` must be a valid pointer to a handle allocated by this library
 * `handle` must be a valid pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode process_control_new(struct RemoteServerAdapterHandle *server,
                                          struct ProcessControlAdapterHandle **handle);

/**
 * Frees a ProcessControlClient handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library or NULL
 */
void process_control_free(struct ProcessControlAdapterHandle *handle);

/**
 * Launches an application on the device
 *
 * # Arguments
 * * [`handle`] - The ProcessControlClient handle
 * * [`bundle_id`] - The bundle identifier of the app to launch
 * * [`env_vars`] - NULL-terminated array of environment variables (format "KEY=VALUE")
 * * [`arguments`] - NULL-terminated array of arguments
 * * [`start_suspended`] - Whether to start the app suspended
 * * [`kill_existing`] - Whether to kill existing instances of the app
 * * [`pid`] - Pointer to store the process ID of the launched app
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * All pointers must be valid or NULL where appropriate
 */
enum IdeviceErrorCode process_control_launch_app(struct ProcessControlAdapterHandle *handle,
                                                 const char *bundle_id,
                                                 const char *const *env_vars,
                                                 uintptr_t env_vars_count,
                                                 const char *const *arguments,
                                                 uintptr_t arguments_count,
                                                 bool start_suspended,
                                                 bool kill_existing,
                                                 uint64_t *pid);

/**
 * Kills a running process
 *
 * # Arguments
 * * [`handle`] - The ProcessControlClient handle
 * * [`pid`] - The process ID to kill
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode process_control_kill_app(struct ProcessControlAdapterHandle *handle,
                                               uint64_t pid);

/**
 * Disables memory limits for a process
 *
 * # Arguments
 * * [`handle`] - The ProcessControlClient handle
 * * [`pid`] - The process ID to modify
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 */
enum IdeviceErrorCode process_control_disable_memory_limit(struct ProcessControlAdapterHandle *handle,
                                                           uint64_t pid);

/**
 * Creates a TCP provider for idevice
 *
 * # Arguments
 * * [`ip`] - The sockaddr IP to connect to
 * * [`pairing_file`] - The pairing file handle to use
 * * [`label`] - The label to use with the connection
 * * [`provider`] - A pointer to a newly allocated provider
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `ip` must be a valid sockaddr
 * `pairing_file` must never be used again
 * `label` must be a valid Cstr
 * `provider` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode idevice_tcp_provider_new(const struct sockaddr *ip,
                                               struct IdevicePairingFile *pairing_file,
                                               const char *label,
                                               struct TcpProviderHandle **provider);

/**
 * Frees a TcpProvider handle
 *
 * # Arguments
 * * [`provider`] - The provider handle to free
 *
 * # Safety
 * `provider` must be a valid pointer to a TcpProvider handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void tcp_provider_free(struct TcpProviderHandle *provider);

/**
 * Creates a usbmuxd provider for idevice
 *
 * # Arguments
 * * [`addr`] - The UsbmuxdAddr handle to connect to
 * * [`tag`] - The tag returned in usbmuxd responses
 * * [`udid`] - The UDID of the device to connect to
 * * [`device_id`] - The muxer ID of the device to connect to
 * * [`pairing_file`] - The pairing file handle to use
 * * [`label`] - The label to use with the connection
 * * [`provider`] - A pointer to a newly allocated provider
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `addr` must be a valid pointer to UsbmuxdAddrHandle created by this library, and never used again
 * `udid` must be a valid CStr
 * `pairing_file` must never be used again
 * `label` must be a valid Cstr
 * `provider` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode usbmuxd_provider_new(struct UsbmuxdAddrHandle *addr,
                                           uint32_t tag,
                                           const char *udid,
                                           uint32_t device_id,
                                           const char *label,
                                           struct UsbmuxdProviderHandle **provider);

/**
 * Frees a UsbmuxdProvider handle
 *
 * # Arguments
 * * [`provider`] - The provider handle to free
 *
 * # Safety
 * `provider` must be a valid pointer to a UsbmuxdProvider handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void usbmuxd_provider_free(struct UsbmuxdProviderHandle *provider);

/**
 * Creates a new RemoteServerClient from a ReadWrite connection
 *
 * # Arguments
 * * [`connection`] - The connection to use for communication
 * * [`handle`] - Pointer to store the newly created RemoteServerClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `connection` must be a valid pointer to a handle allocated by this library
 * `handle` must be a valid pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode remote_server_adapter_new(struct AdapterHandle *adapter,
                                                struct RemoteServerAdapterHandle **handle);

/**
 * Frees a RemoteServerClient handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library or NULL
 */
void remote_server_free(struct RemoteServerAdapterHandle *handle);

/**
 * Returns the underlying connection from a RemoteServerClient
 *
 * # Arguments
 * * [`handle`] - The handle to get the connection from
 * * [`connection`] - The newly allocated ConnectionHandle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library or NULL, and never used again
 */
enum IdeviceErrorCode remote_server_adapter_into_inner(struct RemoteServerAdapterHandle *handle,
                                                       struct AdapterHandle **connection);

/**
 * Creates a new XPCDevice from an adapter
 *
 * # Arguments
 * * [`adapter`] - The adapter to use for communication
 * * [`device`] - Pointer to store the newly created XPCDevice handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `adapter` must be a valid pointer to a handle allocated by this library
 * `device` must be a valid pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode xpc_device_new(struct AdapterHandle *adapter,
                                     struct XPCDeviceAdapterHandle **device);

/**
 * Frees an XPCDevice handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library or NULL
 */
void xpc_device_free(struct XPCDeviceAdapterHandle *handle);

/**
 * Gets a service by name from the XPCDevice
 *
 * # Arguments
 * * [`handle`] - The XPCDevice handle
 * * [`service_name`] - The name of the service to get
 * * [`service`] - Pointer to store the newly created XPCService handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 * `service_name` must be a valid null-terminated C string
 * `service` must be a valid pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode xpc_device_get_service(struct XPCDeviceAdapterHandle *handle,
                                             const char *service_name,
                                             struct XPCServiceHandle **service);

/**
 * Returns the adapter in the RemoteXPC Device
 *
 * # Arguments
 * * [`handle`] - The handle to get the adapter from
 * * [`adapter`] - The newly allocated AdapterHandle
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library or NULL, and never used again
 */
enum IdeviceErrorCode xpc_device_adapter_into_inner(struct XPCDeviceAdapterHandle *handle,
                                                    struct AdapterHandle **adapter);

/**
 * Frees an XPCService handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library or NULL
 */
void xpc_service_free(struct XPCServiceHandle *handle);

/**
 * Gets the list of available service names
 *
 * # Arguments
 * * [`handle`] - The XPCDevice handle
 * * [`names`] - Pointer to store the array of service names
 * * [`count`] - Pointer to store the number of services
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `handle` must be a valid pointer to a handle allocated by this library
 * `names` must be a valid pointer to a location where the array will be stored
 * `count` must be a valid pointer to a location where the count will be stored
 */
enum IdeviceErrorCode xpc_device_get_service_names(struct XPCDeviceAdapterHandle *handle,
                                                   char ***names,
                                                   uintptr_t *count);

/**
 * Frees a list of service names
 *
 * # Arguments
 * * [`names`] - The array of service names to free
 * * [`count`] - The number of services in the array
 *
 * # Safety
 * `names` must be a valid pointer to an array of `count` C strings
 */
void xpc_device_free_service_names(char **names, uintptr_t count);

/**
 * Connects to the Springboard service using a TCP provider
 *
 * # Arguments
 * * [`provider`] - A TcpProvider
 * * [`client`] - On success, will be set to point to a newly allocated SpringBoardServicesClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode springboard_services_connect_tcp(struct TcpProviderHandle *provider,
                                                       struct SpringBoardServicesClientHandle **client);

/**
 * Connects to the Springboard service using a usbmuxd provider
 *
 * # Arguments
 * * [`provider`] - A UsbmuxdProvider
 * * [`client`] - On success, will be set to point to a newly allocated SpringBoardServicesClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `provider` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode springboard_services_connect_usbmuxd(struct UsbmuxdProviderHandle *provider,
                                                           struct SpringBoardServicesClientHandle **client);

/**
 * Creates a new SpringBoardServices client from an existing Idevice connection
 *
 * # Arguments
 * * [`socket`] - An IdeviceSocket handle
 * * [`client`] - On success, will be set to point to a newly allocated SpringBoardServicesClient handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `socket` must be a valid pointer to a handle allocated by this library
 * `client` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode springboard_services_new(struct IdeviceHandle *socket,
                                               struct SpringBoardServicesClientHandle **client);

/**
 * Gets the icon of the specified app by bundle identifier
 *
 * # Arguments
 * * `client` - A valid SpringBoardServicesClient handle
 * * `bundle_identifier` - The identifiers of the app to get icon
 * * `out_result` - On success, will be set to point to a newly allocated png data
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `client` must be a valid pointer to a handle allocated by this library
 * `out_result` must be a valid, non-null pointer to a location where the result will be stored
 */
enum IdeviceErrorCode springboard_services_get_icon(struct SpringBoardServicesClientHandle *client,
                                                    const char *bundle_identifier,
                                                    void **out_result,
                                                    size_t *out_result_len);

/**
 * Frees an SpringBoardServicesClient handle
 *
 * # Arguments
 * * [`handle`] - The handle to free
 *
 * # Safety
 * `handle` must be a valid pointer to the handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void springboard_services_free(struct SpringBoardServicesClientHandle *handle);

/**
 * Connects to a usbmuxd instance over TCP
 *
 * # Arguments
 * * [`addr`] - The socket address to connect to
 * * [`addr_len`] - Length of the socket
 * * [`tag`] - A tag that will be returned by usbmuxd responses
 * * [`usbmuxd_connection`] - On success, will be set to point to a newly allocated UsbmuxdConnection handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `addr` must be a valid sockaddr
 * `usbmuxd_connection` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode idevice_usbmuxd_new_tcp_connection(const struct sockaddr *addr,
                                                         socklen_t addr_len,
                                                         uint32_t tag,
                                                         struct UsbmuxdConnectionHandle **usbmuxd_connection);

/**
 * Connects to a usbmuxd instance over unix socket
 *
 * # Arguments
 * * [`addr`] - The socket path to connect to
 * * [`tag`] - A tag that will be returned by usbmuxd responses
 * * [`usbmuxd_connection`] - On success, will be set to point to a newly allocated UsbmuxdConnection handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `addr` must be a valid CStr
 * `usbmuxd_connection` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode idevice_usbmuxd_new_unix_socket_connection(const char *addr,
                                                                 uint32_t tag,
                                                                 struct UsbmuxdConnectionHandle **usbmuxd_connection);

/**
 * Frees a UsbmuxdConnection handle
 *
 * # Arguments
 * * [`usbmuxd_connection`] - The UsbmuxdConnection handle to free
 *
 * # Safety
 * `usbmuxd_connection` must be a valid pointer to a UsbmuxdConnection handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void idevice_usbmuxd_connection_free(struct UsbmuxdConnectionHandle *usbmuxd_connection);

/**
 * Creates a usbmuxd TCP address struct
 *
 * # Arguments
 * * [`addr`] - The socket address to connect to
 * * [`addr_len`] - Length of the socket
 * * [`usbmuxd_addr`] - On success, will be set to point to a newly allocated UsbmuxdAddr handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `addr` must be a valid sockaddr
 * `usbmuxd_Addr` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode idevice_usbmuxd_tcp_addr_new(const struct sockaddr *addr,
                                                   socklen_t addr_len,
                                                   struct UsbmuxdAddrHandle **usbmuxd_addr);

/**
 * Creates a new UsbmuxdAddr struct with a unix socket
 *
 * # Arguments
 * * [`addr`] - The socket path to connect to
 * * [`usbmuxd_addr`] - On success, will be set to point to a newly allocated UsbmuxdAddr handle
 *
 * # Returns
 * An error code indicating success or failure
 *
 * # Safety
 * `addr` must be a valid CStr
 * `usbmuxd_addr` must be a valid, non-null pointer to a location where the handle will be stored
 */
enum IdeviceErrorCode idevice_usbmuxd_unix_addr_new(const char *addr,
                                                    struct UsbmuxdAddrHandle **usbmuxd_addr);

/**
 * Frees a UsbmuxdAddr handle
 *
 * # Arguments
 * * [`usbmuxd_addr`] - The UsbmuxdAddr handle to free
 *
 * # Safety
 * `usbmuxd_addr` must be a valid pointer to a UsbmuxdAddr handle that was allocated by this library,
 * or NULL (in which case this function does nothing)
 */
void idevice_usbmuxd_addr_free(struct UsbmuxdAddrHandle *usbmuxd_addr);
