using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libgdbm"], Symbol("")),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/BenLauwens/GDBMBuilder/releases/download/v1.18.0"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/GDBM.v1.18.0.aarch64-linux-gnu.tar.gz", "91e60865cf9b4d7909833728ad7beefad92362a3a530854a01947664e5181ed8"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/GDBM.v1.18.0.aarch64-linux-musl.tar.gz", "36e35901bcc429b5d3027685ca57852c0bdd81006b2af1aeab8064a7c931a8b9"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/GDBM.v1.18.0.arm-linux-gnueabihf.tar.gz", "81801d2811f36028333945a97fb1593ec80b763f892ef852b4341b83aed845c6"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/GDBM.v1.18.0.arm-linux-musleabihf.tar.gz", "72fd75960d1ba9e1d67bd2a2d6169cf229e38033519404dbd32f4d205b194060"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/GDBM.v1.18.0.i686-linux-gnu.tar.gz", "9d1d3a2975fe7a67b9d7582f9f7b3ae823ef22788e01e46e947a39013e12c1f7"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/GDBM.v1.18.0.i686-linux-musl.tar.gz", "d4db5b440d0cc3cd78c205b6811cc3ce02d772aa90a9c2c292905043c36c0271"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/GDBM.v1.18.0.powerpc64le-linux-gnu.tar.gz", "7a7d78ca1281d7e1ead46b12edcdde0b592f555ddb1950dce524230830af92d4"),
    MacOS(:x86_64) => ("$bin_prefix/GDBM.v1.18.0.x86_64-apple-darwin14.tar.gz", "8957aff8f2a2bce35fc2f81c8ef64ac86f7e6c5be45cc68e32d5aa32c3281759"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/GDBM.v1.18.0.x86_64-linux-gnu.tar.gz", "b8d218ec5610a67d37e08e788549bef5629b84702a8d5d657d8e3fe375cf3696"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/GDBM.v1.18.0.x86_64-linux-musl.tar.gz", "8ba65d4db98747e393251db99086984a714b457a7cf0d46db82b461b8fb38d50"),
    FreeBSD(:x86_64) => ("$bin_prefix/GDBM.v1.18.0.x86_64-unknown-freebsd11.1.tar.gz", "421c4e775504bea05c909e26fb25f78babdf44429f4735b4fd2647f22f2cbe4b"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
