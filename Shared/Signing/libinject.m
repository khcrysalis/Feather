//
//  libinject.m
//  libinject
//
//  Created by Mineek on 19/08/2024.
//

// based on inject_dylib.

#import "include/libinject/libinject.h"
#import <mach-o/loader.h>
#import <mach-o/fat.h>

#define IS_64_BIT(x) ((x) == MH_MAGIC_64 || (x) == MH_CIGAM_64)
#define IS_LITTLE_ENDIAN(x) ((x) == FAT_CIGAM || (x) == MH_CIGAM_64 || (x) == MH_CIGAM)
#define SWAP32(x, magic) (IS_LITTLE_ENDIAN(magic)? OSSwapInt32(x): (x))
#define SWAP64(x, magic) (IS_LITTLE_ENDIAN(magic)? OSSwapInt64(x): (x))

int inject_dylib(const char *exec_path, const char *dylib_path) {
    printf("[libinject] Injecting %s into %s\n", dylib_path, exec_path);
    FILE *macho = fopen(exec_path, "r+");
    if (macho == NULL) {
        printf("[libinject] Unable to open %s\n", exec_path);
        return -1;
    }
    struct mach_header header;
    fread(&header, sizeof(struct mach_header), 1, macho);
    if (header.magic != MH_MAGIC && header.magic != MH_MAGIC_64 && header.magic != MH_CIGAM && header.magic != MH_CIGAM_64) {
        printf("[libinject] %s is not a valid (recognized?) Mach-O file\n", exec_path); // or its fat! oops, will fix later.
        fclose(macho);
        return -1;
    }

	size_t commands_offset = (IS_64_BIT(header.magic)? sizeof(struct mach_header_64): sizeof(struct mach_header));

    size_t path_padding = 8;
	size_t dylib_path_len = strlen(dylib_path);
	size_t dylib_path_size = (dylib_path_len & ~(path_padding - 1)) + path_padding;
	uint32_t cmdsize = (uint32_t)(sizeof(struct dylib_command) + dylib_path_size);

    // write the new LC_LOAD_DYLIB command
    struct dylib_command dylib_command = {
		.cmd = SWAP32(LC_LOAD_DYLIB, header.magic),
		.cmdsize = SWAP32(cmdsize, header.magic),
		.dylib = {
			.name = SWAP32(sizeof(struct dylib_command), header.magic),
			.timestamp = 0,
			.current_version = 0,
			.compatibility_version = 0
		}
	};

    uint32_t sizeofcmds = SWAP32(header.sizeofcmds, header.magic);

    fseeko(macho, commands_offset + sizeofcmds, SEEK_SET);
    char space[cmdsize];
    fread(space, cmdsize, 1, macho);
    fseeko(macho, -((off_t)cmdsize), SEEK_CUR);

    char *dylib_path_buffer = calloc(dylib_path_size, 1);
    memcpy(dylib_path_buffer, dylib_path, dylib_path_len);
    fwrite(&dylib_command, sizeof(struct dylib_command), 1, macho);
    fwrite(dylib_path_buffer, dylib_path_size, 1, macho);
    free(dylib_path_buffer);
    
    // update the number of load commands
    header.ncmds = SWAP32(SWAP32(header.ncmds, header.magic) + 1, header.magic);
    sizeofcmds += cmdsize;
    header.sizeofcmds = SWAP32(sizeofcmds, header.magic);

    fseeko(macho, 0, SEEK_SET);
    fwrite(&header, sizeof(header), 1, macho);
    fclose(macho);
    printf("[libinject] %s injected into %s\n", dylib_path, exec_path);
    return 0;
}
