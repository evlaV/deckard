// pidbridge.c
//
// Tells a containerized process its host-side PID. A process in a Lepton container
// (rootless podman, own PID namespace) connects; we read SO_PEERCRED on the accepted fd,
// which the kernel translates into our host init namespace, and send that pid back.

#define _GNU_SOURCE

#include <sys/socket.h>
#include <sys/un.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// write() the whole buffer, retrying short writes and EINTR. 0 on success, -1 if it breaks.
static int write_all( int dFd, const void *pBuf, size_t nLen )
{
    const char *pCursor = ( const char * )pBuf;

    while ( nLen > 0 )
    {
        ssize_t nWritten = write( dFd, pCursor, nLen );
        if ( nWritten < 0 )
        {
            if ( errno == EINTR )
                continue;
            return -1;
        }
        if ( nWritten == 0 )
            return -1;

        pCursor += nWritten;
        nLen -= ( size_t )nWritten;
    }

    return 0;
}

// Default bind path: ${XDG_RUNTIME_DIR}/pidbridge/pidbridge.sock (set for the --user
// service). Override with argv[1]; NULL if neither is available.
static const char *default_socket_path( void )
{
    static char pchBuf[ sizeof( ( ( struct sockaddr_un * )0 )->sun_path ) ];
    const char *pchXdg = getenv( "XDG_RUNTIME_DIR" );

    if ( !pchXdg || !*pchXdg )
    {
        fprintf( stderr, "pidbridge: XDG_RUNTIME_DIR not set; pass a socket path as argv[1]\n" );
        return NULL;
    }

    snprintf( pchBuf, sizeof pchBuf, "%s/pidbridge/pidbridge.sock", pchXdg );
    return pchBuf;
}

// Best-effort mkdir of the socket's parent dir (RuntimeDirectory= covers the service;
// this covers running by hand). EEXIST is fine.
static void ensure_parent_dir( const char *pchPath )
{
    char pchTmp[ sizeof( ( ( struct sockaddr_un * )0 )->sun_path ) ];
    char *pSlash;

    snprintf( pchTmp, sizeof pchTmp, "%s", pchPath );
    pSlash = strrchr( pchTmp, '/' );
    if ( pSlash && pSlash != pchTmp )
    {
        *pSlash = '\0';
        mkdir( pchTmp, 0755 );
    }
}

// Set by SIGTERM/SIGINT so the accept loop can break and shut down cleanly.
static volatile sig_atomic_t g_dStop = 0;

static void on_stop( int dSig )
{
    ( void )dSig;
    g_dStop = 1;
}

int main( int argc, char **argv )
{
    const char *pchSocketPath = ( argc > 1 ) ? argv[ 1 ] : default_socket_path();
    int dListenFd = -1;

    if ( pchSocketPath == NULL )
        return 1;

    // Don't die on SIGPIPE if a client hangs up mid-write; write() returns EPIPE instead.
    signal( SIGPIPE, SIG_IGN );

    // SIGTERM/SIGINT -> graceful stop. No SA_RESTART, so a blocked accept4() returns
    // EINTR and the loop notices g_dStop instead of restarting.
    struct sigaction sStop;
    memset( &sStop, 0, sizeof( sStop ) );
    sStop.sa_handler = on_stop;
    sigaction( SIGTERM, &sStop, NULL );
    sigaction( SIGINT, &sStop, NULL );

    ensure_parent_dir( pchSocketPath );
    unlink( pchSocketPath );   // drop any stale socket from an unclean exit

    dListenFd = socket( AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0 );
    if ( dListenFd < 0 )
    {
        perror( "socket" );
        return 1;
    }

    struct sockaddr_un sAddr;
    memset( &sAddr, 0, sizeof( sAddr ) );
    sAddr.sun_family = AF_UNIX;

    if ( strlen( pchSocketPath ) >= sizeof( sAddr.sun_path ) )
    {
        fprintf( stderr, "socket path too long\n" );
        close( dListenFd );
        return 1;
    }
    strcpy( sAddr.sun_path, pchSocketPath );

    if ( bind( dListenFd, ( struct sockaddr * )&sAddr, sizeof( sAddr ) ) < 0 )
    {
        perror( "bind" );
        close( dListenFd );
        return 1;
    }

    // World-connectable so a different-uid caller can reach it; the dir perms gate access.
    if ( chmod( pchSocketPath, 0666 ) < 0 )
    {
        perror( "chmod" );
        close( dListenFd );
        unlink( pchSocketPath );
        return 1;
    }

    if ( listen( dListenFd, 64 ) < 0 )
    {
        perror( "listen" );
        close( dListenFd );
        unlink( pchSocketPath );
        return 1;
    }

    printf( "pidbridge listening on %s\n", pchSocketPath );
    fflush( stdout );   // stdout is piped to journald, so flush

    while ( !g_dStop )
    {
        int dClientFd = accept4( dListenFd, NULL, NULL, SOCK_CLOEXEC );
        if ( dClientFd < 0 )
        {
            if ( errno == EINTR )
                continue;   // signal (maybe shutdown) — let the while-test decide
            perror( "accept4" );
            continue;
        }

        struct ucred sCred;
        socklen_t nCredLen = sizeof( sCred );

        // Read peer creds; kernel translates into our ns, so sCred.pid is the host-side PID.
        if ( getsockopt( dClientFd, SOL_SOCKET, SO_PEERCRED, &sCred, &nCredLen ) == -1 )
        {
            perror( "getsockopt(SO_PEERCRED)" );
            close( dClientFd );
            continue;
        }

        printf( "peer host pid=%d uid=%u gid=%u\n", sCred.pid, sCred.uid, sCred.gid );
        fflush( stdout );

        // Reply with the host PID as a 4-byte int, host byte order (same arch both ends).
        int32_t dHostPid = ( int32_t )sCred.pid;
        if ( write_all( dClientFd, &dHostPid, sizeof( dHostPid ) ) < 0 )
            perror( "write" );

        close( dClientFd );
    }

    close( dListenFd );
    unlink( pchSocketPath );
    return 0;
}
