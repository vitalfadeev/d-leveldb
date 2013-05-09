/* Copyright (c) 2011 The LevelDB Authors. All rights reserved.
  Use of this source code is governed by a BSD-style license that can be
  found in the LICENSE file. See the AUTHORS file for names of contributors.

  C bindings for leveldb.  May be useful as a stable ABI that can be
  used by programs that keep leveldb in a shared library, or for
  a JNI api.

  Does not support:
  . getters for the option types
  . custom comparators that implement key shortening
  . capturing post-write-snapshot
  . custom iter, db, env, cache implementations using just the C bindings

  Some conventions:

  (1) We expose just opaque struct pointers and functions to clients.
  This allows us to change internal representations without having to
  recompile clients.

  (2) For simplicity, there is no equivalent to the Slice type.  Instead,
  the caller has to pass the pointer and length as separate
  arguments.

  (3) Errors are represented by a null-terminated c string.  NULL
  means no error.  All operations that can raise an error are passed
  a "char** errptr" as the last argument.  One of the following must
  be true on entry:
     *errptr == NULL
     *errptr points to a malloc()ed null-terminated error message
       (On Windows, *errptr must have been malloc()-ed by this library.)
  On success, a leveldb routine leaves *errptr unchanged.
  On failure, leveldb frees the old value of *errptr and
  set *errptr to a malloc()ed error message.

  (4) Bools have the type ubyte (0 == false; rest == true)

  (5) All of the pointer arguments must be non-NULL.
*/

module deimos.leveldb.leveldb;

private import std.stdint;

public:
extern(C):
nothrow:

/* Exported types */
alias void* leveldb_t;
alias void* leveldb_cache_t;
alias void* leveldb_comparator_t;
alias void* leveldb_env_t;
alias void* leveldb_filelock_t;
alias void* leveldb_filterpolicy_t;
alias void* leveldb_iterator_t;
alias void* leveldb_logger_t;
alias void* leveldb_options_t;
alias void* leveldb_randomfile_t;
alias void* leveldb_readoptions_t;
alias void* leveldb_seqfile_t;
alias void* leveldb_snapshot_t;
alias void* leveldb_writablefile_t;
alias void* leveldb_writebatch_t;
alias void* leveldb_writeoptions_t;

/* DB operations */

leveldb_t leveldb_open(
    const leveldb_options_t options,
    const char* name,
    char** errptr);

void leveldb_close(leveldb_t db);

void leveldb_put(
    leveldb_t db,
    const leveldb_writeoptions_t options,
    const char* key, size_t keylen,
    const char* val, size_t vallen,
    char** errptr);

void leveldb_delete(
    leveldb_t db,
    const leveldb_writeoptions_t options,
    const char* key, size_t keylen,
    char** errptr);

void leveldb_write(
    leveldb_t db,
    const leveldb_writeoptions_t options,
    leveldb_writebatch_t batch,
    char** errptr);

/* Returns NULL if not found.  A malloc()ed array otherwise.
   Stores the length of the array in *vallen. */
char* leveldb_get(
    leveldb_t db,
    const leveldb_readoptions_t options,
    const char* key, size_t keylen,
    size_t* vallen,
    char** errptr);

leveldb_iterator_t leveldb_create_iterator(
    leveldb_t db,
    const leveldb_readoptions_t options);

const(leveldb_snapshot_t) leveldb_create_snapshot(
    leveldb_t db);

void leveldb_release_snapshot(
    leveldb_t db,
    const leveldb_snapshot_t snapshot);

/* Returns NULL if property name is unknown.
   Else returns a pointer to a malloc()-ed null-terminated value. */
char* leveldb_property_value(
    leveldb_t db,
    const char* propname);

void leveldb_approximate_sizes(
    leveldb_t db,
    int num_ranges,
    const const(char)* range_start_key, const size_t* range_start_key_len,
    const const(char)* range_limit_key, const size_t* range_limit_key_len,
    uint64_t* sizes);

void leveldb_compact_range(
    leveldb_t db,
    const char* start_key, size_t start_key_len,
    const char* limit_key, size_t limit_key_len);

/* Management operations */

void leveldb_destroy_db(
    const leveldb_options_t options,
    const char* name,
    char** errptr);

void leveldb_repair_db(
    const leveldb_options_t options,
    const char* name,
    char** errptr);

/* Iterator */

void leveldb_iter_destroy(leveldb_iterator_t);
ubyte leveldb_iter_valid(const leveldb_iterator_t);
void leveldb_iter_seek_to_first(leveldb_iterator_t);
void leveldb_iter_seek_to_last(leveldb_iterator_t);
void leveldb_iter_seek(leveldb_iterator_t, const char* k, size_t klen);
void leveldb_iter_next(leveldb_iterator_t);
void leveldb_iter_prev(leveldb_iterator_t);
const(char*) leveldb_iter_key(const leveldb_iterator_t, size_t* klen);
const(char*) leveldb_iter_value(const leveldb_iterator_t, size_t* vlen);
void leveldb_iter_get_error(const leveldb_iterator_t, char** errptr);

/* Write batch */

leveldb_writebatch_t leveldb_writebatch_create();
void leveldb_writebatch_destroy(leveldb_writebatch_t);
void leveldb_writebatch_clear(leveldb_writebatch_t);
void leveldb_writebatch_put(
    leveldb_writebatch_t,
    const char* key, size_t klen,
    const char* val, size_t vlen);
void leveldb_writebatch_delete(
    leveldb_writebatch_t,
    const char* key, size_t klen);
void leveldb_writebatch_iterate(
    leveldb_writebatch_t,
    void* state,
    void function(void*, const char* k, size_t klen, const char* v, size_t vlen) put,
    void function(void*, const char* k, size_t klen) deleted);

/* Options */

leveldb_options_t leveldb_options_create();
void leveldb_options_destroy(leveldb_options_t);
void leveldb_options_set_comparator(
    leveldb_options_t,
    leveldb_comparator_t);
void leveldb_options_set_filter_policy(
    leveldb_options_t,
    leveldb_filterpolicy_t);
void leveldb_options_set_create_if_missing(
    leveldb_options_t, ubyte);
void leveldb_options_set_error_if_exists(
    leveldb_options_t, ubyte);
void leveldb_options_set_paranoid_checks(
    leveldb_options_t, ubyte);
void leveldb_options_set_env(leveldb_options_t, leveldb_env_t);
void leveldb_options_set_info_log(leveldb_options_t, leveldb_logger_t);
void leveldb_options_set_write_buffer_size(leveldb_options_t, size_t);
void leveldb_options_set_max_open_files(leveldb_options_t, int);
void leveldb_options_set_cache(leveldb_options_t, leveldb_cache_t);
void leveldb_options_set_block_size(leveldb_options_t, size_t);
void leveldb_options_set_block_restart_interval(leveldb_options_t, int);

enum {
  leveldb_no_compression = 0,
  leveldb_snappy_compression = 1
}
void leveldb_options_set_compression(leveldb_options_t, int);

/* Comparator */

leveldb_comparator_t leveldb_comparator_create(
    void* state,
    void function(void*) destructor,
    int function(
        void*,
        const char* a, size_t alen,
        const char* b, size_t blen) compare,
    const(char*) function(void*) name);
void leveldb_comparator_destroy(leveldb_comparator_t);

/* Filter policy */

leveldb_filterpolicy_t leveldb_filterpolicy_create(
    void* state,
    void function(void*) destructor,
    char* function(
        void*,
        const const(char)* key_array, const size_t* key_length_array,
        int num_keys,
        size_t* filter_length) create_filter,
    ubyte function(
        void*,
        const char* key, size_t length,
        const char* filter, size_t filter_length) key_may_match,
    const(char*) function(void*) name);
void leveldb_filterpolicy_destroy(leveldb_filterpolicy_t);

leveldb_filterpolicy_t leveldb_filterpolicy_create_bloom(
    int bits_per_key);

/* Read options */

leveldb_readoptions_t leveldb_readoptions_create();
void leveldb_readoptions_destroy(leveldb_readoptions_t);
void leveldb_readoptions_set_verify_checksums(
    leveldb_readoptions_t,
    ubyte);
void leveldb_readoptions_set_fill_cache(
    leveldb_readoptions_t, ubyte);
void leveldb_readoptions_set_snapshot(
    leveldb_readoptions_t,
    const leveldb_snapshot_t);

/* Write options */

leveldb_writeoptions_t leveldb_writeoptions_create();
void leveldb_writeoptions_destroy(leveldb_writeoptions_t);
void leveldb_writeoptions_set_sync(
    leveldb_writeoptions_t, ubyte);

/* Cache */

leveldb_cache_t leveldb_cache_create_lru(size_t capacity);
void leveldb_cache_destroy(leveldb_cache_t cache);

/* Env */

leveldb_env_t leveldb_create_default_env();
void leveldb_env_destroy(leveldb_env_t);

/* Utility */

/* Calls free(ptr).
   REQUIRES: ptr was malloc()-ed and returned by one of the routines
   in this file.  Note that in certain cases (typically on Windows), you
   may need to call this routine instead of free(ptr) to dispose of
   malloc()-ed memory returned by this library. */
void leveldb_free(void* ptr);

/* Return the major version number for this release. */
int leveldb_major_version();

/* Return the minor version number for this release. */
int leveldb_minor_version();

