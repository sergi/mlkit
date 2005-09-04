#ifndef LOCKS_H

#define LOCKS_H
#include "../config.h"

#ifdef THREADS
#ifdef APACHE

#define str(s)      # s
#define xstr(s)     str(s)
#include xstr(APACHEDIR/include/apr_pools.h)
#include xstr(APACHEDIR/include/apr_thread_mutex.h)

extern apr_thread_mutex_t *apache_locks[];

#define LOCK_LOCK(name) apr_thread_mutex_lock(apache_locks[name])
#define LOCK_UNLOCK(name) apr_thread_mutex_unlock(apache_locks[name])

#define CODECACHEMUTEX     0
#define FREELISTMUTEX      1
#define STACKPOOLMUTEX     2
#define FUNCTIONTABLEMUTEX 3

#elif AOLSERVER // APACHE

#define CODECACHEMUTEX     codeCacheMutex
#define FREELISTMUTEX      freelistMutex
#define STACKPOOLMUTEX     stackPoolMutex
#define FUNCTIONTABLEMUTEX functionTableMutex

#include "/opt/aolserver/include/ns.h"
extern Ns_Mutex freelistMutex;
extern Ns_Mutex stackPoolMutex;
extern Ns_Mutex functionTableMutex;
extern Ns_Mutex codeCacheMutex;
#define LOCK_LOCK(name) Ns_LockMutex(&name)
#define LOCK_UNLOCK(name) Ns_UnlockMutex(&name)

#elif PTHREADS  // AOLSERVER

#define CODECACHEMUTEX     0
#define FREELISTMUTEX      1
#define STACKPOOLMUTEX     2
#define FUNCTIONTABLEMUTEX 3

#define LOCK_LOCK(name) ;
#define LOCK_UNLOCK(name) ;
#endif // PTHREADS

#else // THREADS

#define CODECACHEMUTEX     0
#define FREELISTMUTEX      1
#define STACKPOOLMUTEX     2
#define FUNCTIONTABLEMUTEX 3

#define LOCK_LOCK(name) ;
#define LOCK_UNLOCK(name) ;
#endif // THREADS

#endif // LOCKS_H
