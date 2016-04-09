const arch = switch (@compile_var("arch")) {
    x86_64 => @import("linux_x86_64.zig"),
    i386 => @import("linux_i386.zig"),
    else => unreachable{},
};

pub const MMAP_PROT_NONE =  0;
pub const MMAP_PROT_READ =  1;
pub const MMAP_PROT_WRITE = 2;
pub const MMAP_PROT_EXEC =  4;

pub const MMAP_MAP_FILE =    0;
pub const MMAP_MAP_SHARED =  1;
pub const MMAP_MAP_PRIVATE = 2;
pub const MMAP_MAP_FIXED =   16;
pub const MMAP_MAP_ANON =    32;

pub const SIGHUP    = 1;
pub const SIGINT    = 2;
pub const SIGQUIT   = 3;
pub const SIGILL    = 4;
pub const SIGTRAP   = 5;
pub const SIGABRT   = 6;
pub const SIGIOT    = SIGABRT;
pub const SIGBUS    = 7;
pub const SIGFPE    = 8;
pub const SIGKILL   = 9;
pub const SIGUSR1   = 10;
pub const SIGSEGV   = 11;
pub const SIGUSR2   = 12;
pub const SIGPIPE   = 13;
pub const SIGALRM   = 14;
pub const SIGTERM   = 15;
pub const SIGSTKFLT = 16;
pub const SIGCHLD   = 17;
pub const SIGCONT   = 18;
pub const SIGSTOP   = 19;
pub const SIGTSTP   = 20;
pub const SIGTTIN   = 21;
pub const SIGTTOU   = 22;
pub const SIGURG    = 23;
pub const SIGXCPU   = 24;
pub const SIGXFSZ   = 25;
pub const SIGVTALRM = 26;
pub const SIGPROF   = 27;
pub const SIGWINCH  = 28;
pub const SIGIO     = 29;
pub const SIGPOLL   = 29;
pub const SIGPWR    = 30;
pub const SIGSYS    = 31;
pub const SIGUNUSED = SIGSYS;

pub const O_RDONLY = 0o0;
pub const O_WRONLY = 0o1;
pub const O_RDWR   = 0o2;

pub const O_CREAT = arch.O_CREAT;
pub const O_EXCL = arch.O_EXCL;
pub const O_NOCTTY = arch.O_NOCTTY;
pub const O_TRUNC = arch.O_TRUNC;
pub const O_APPEND = arch.O_APPEND;
pub const O_NONBLOCK = arch.O_NONBLOCK;
pub const O_DSYNC = arch.O_DSYNC;
pub const O_SYNC = arch.O_SYNC;
pub const O_RSYNC = arch.O_RSYNC;
pub const O_DIRECTORY = arch.O_DIRECTORY;
pub const O_NOFOLLOW = arch.O_NOFOLLOW;
pub const O_CLOEXEC = arch.O_CLOEXEC;

pub const O_ASYNC = arch.O_ASYNC;
pub const O_DIRECT = arch.O_DIRECT;
pub const O_LARGEFILE = arch.O_LARGEFILE;
pub const O_NOATIME = arch.O_NOATIME;
pub const O_PATH = arch.O_PATH;
pub const O_TMPFILE = arch.O_TMPFILE;
pub const O_NDELAY = arch.O_NDELAY;

const SIG_BLOCK   = 0;
const SIG_UNBLOCK = 1;
const SIG_SETMASK = 2;

pub fn mmap(address: ?&u8, length: isize, prot: isize, flags: isize, fd: isize, offset: isize) -> isize {
    // TODO ability to cast maybe pointer to isize
    const addr = if (const unwrapped ?= address) isize(unwrapped) else 0;
    arch.syscall6(arch.SYS_mmap, addr, length, prot, flags, fd, offset)
}

pub fn munmap(address: &u8, length: isize) -> isize {
    arch.syscall2(arch.SYS_munmap, isize(address), length)
}

pub fn read(fd: isize, buf: &u8, count: isize) -> isize {
    arch.syscall3(arch.SYS_read, isize(fd), isize(buf), count)
}

pub fn write(fd: isize, buf: &const u8, count: isize) -> isize {
    arch.syscall3(arch.SYS_write, isize(fd), isize(buf), count)
}

pub fn open(path: []u8, flags: isize, perm: isize) -> isize {
    var buf: [path.len + 1]u8 = undefined;
    @memcpy(&buf[0], &path[0], path.len);
    buf[path.len] = 0;
    arch.syscall3(arch.SYS_open, isize(&buf[0]), flags, perm)
}

pub fn create(path: []u8, perm: isize) -> isize {
    var buf: [path.len + 1]u8 = undefined;
    @memcpy(&buf[0], &path[0], path.len);
    buf[path.len] = 0;
    arch.syscall2(arch.SYS_creat, isize(&buf[0]), perm)
}

pub fn openat(dirfd: isize, path: []u8, flags: isize, mode: isize) -> isize {
    var buf: [path.len + 1]u8 = undefined;
    @memcpy(&buf[0], &path[0], path.len);
    buf[path.len] = 0;
    arch.syscall4(arch.SYS_openat, dirfd, isize(&buf[0]), flags, mode)
}

pub fn close(fd: isize) -> isize {
    arch.syscall1(arch.SYS_close, fd)
}

pub fn lseek(fd: isize, offset: isize, ref_pos: isize) -> isize {
    arch.syscall3(arch.SYS_lseek, fd, offset, ref_pos)
}

pub fn exit(status: i32) -> unreachable {
    arch.syscall1(arch.SYS_exit, isize(status));
    unreachable{}
}

pub fn getrandom(buf: &u8, count: isize, flags: u32) -> isize {
    arch.syscall3(arch.SYS_getrandom, isize(buf), count, isize(flags))
}

pub fn kill(pid: i32, sig: i32) -> i32 {
    i32(arch.syscall2(arch.SYS_kill, pid, sig))
}

const NSIG = 65;
const sigset_t = [128]u8;
const all_mask = []u8 { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, };
const app_mask = []u8 { 0xff, 0xff, 0xff, 0xfc, 0x7f, 0xff, 0xff, 0xff, };

pub fn raise(sig: i32) -> i32 {
    var set: sigset_t = undefined;
    block_app_signals(&set);
    const tid = i32(arch.syscall0(arch.SYS_gettid));
    const ret = i32(arch.syscall2(arch.SYS_tkill, tid, sig));
    restore_signals(&set);
    return ret;
}

fn block_all_signals(set: &sigset_t) {
    arch.syscall4(arch.SYS_rt_sigprocmask, SIG_BLOCK, isize(&all_mask), isize(set), NSIG/8);
}

fn block_app_signals(set: &sigset_t) {
    arch.syscall4(arch.SYS_rt_sigprocmask, SIG_BLOCK, isize(&app_mask), isize(set), NSIG/8);
}

fn restore_signals(set: &sigset_t) {
    arch.syscall4(arch.SYS_rt_sigprocmask, SIG_SETMASK, isize(set), 0, NSIG/8);
}