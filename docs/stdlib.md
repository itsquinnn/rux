# Rux Standard Library

The Rux standard library is organized into domain-specific modules under `lib/`.

## Core

| Module | Description |
|--------|-------------|
| `lib/core/types.rx` | Fundamental types and type aliases |
| `lib/core/option.rx` | `Option<T>` type |
| `lib/core/result.rx` | `Result<T, E>` type |
| `lib/core/vec.rx` | Growable vector |
| `lib/core/vec_u8.rx` | Byte vector |
| `lib/core/vecdeque.rx` | Double-ended queue |
| `lib/core/slice.rx` | Slice type |
| `lib/core/iter.rx` | Iterator traits |
| `lib/core/hashmap.rx` | Hash map |
| `lib/core/hashset.rx` | Hash set |
| `lib/core/btreemap.rx` | B-tree map |
| `lib/core/heap.rx` | Binary heap |
| `lib/core/memory.rx` | Memory primitives |
| `lib/core/gc.rx` | Garbage collector |
| `lib/core/panic.rx` | Panic handling |
| `lib/core/debug.rx` | Debug utilities |
| `lib/core/raii.rx` | RAII guards |
| `lib/core/closure.rx` | Closure support |
| `lib/core/utf8.rx` | UTF-8 string handling |
| `lib/core/alor.rx` | Affine lexical ownership |
| `lib/core/tuple.rx` | Tuple types |

## Memory Management

| Module | Description |
|--------|-------------|
| `lib/arch/paging.rx` | 4-level PML4 virtual memory |
| `lib/arch/allocator_phys.rx` | Binary buddy + slab allocator |
| `lib/arch/mmio.rx` | Memory-mapped I/O |

## Boot & Firmware

| Module | Description |
|--------|-------------|
| `lib/boot/multiboot.rx` | Multiboot header |
| `lib/boot/uefi.rx` | UEFI services |
| `lib/boot/acpi_smbios.rx` | ACPI/SMBIOS tables |
| `lib/boot/opensbi.rx` | OpenSBI for RISC-V |

## Hardware

| Module | Description |
|--------|-------------|
| `lib/hw/pci.rx` | PCI bus enumerator |
| `lib/hw/uart.rx` | Serial UART |
| `lib/hw/console_fb.rx` | Framebuffer console |
| `lib/hw/hid.rx` | Human input devices |
| `lib/hw/timer_rtc.rx` | Timer and RTC |
| `lib/hw/nvme.rx` | NVMe storage |
| `lib/hw/ahci.rx` | AHCI SATA |
| `lib/hw/nic_ring.rx` | Network ring NIC |
| `lib/hw/usb_xhci.rx` | USB XHCI controller |
| `lib/hw/bluetooth_hci.rx` | Bluetooth HCI |
| `lib/hw/audio_pcm.rx` | PCM audio |
| `lib/hw/power_mgmt.rx` | Power management |

## System

| Module | Description |
|--------|-------------|
| `lib/sys/syscall.rx` | System call interface |
| `lib/sys/process.rx` | Process management |
| `lib/sys/vfs.rx` | Virtual file system |
| `lib/sys/block_cache.rx` | Block device cache |
| `lib/sys/fs_ext4_fat.rx` | ext4/FAT filesystems |
| `lib/sys/init_service.rx` | Init system |
| `lib/sys/shell_coreutils.rx` | Shell and core utilities |

## Networking

| Module | Description |
|--------|-------------|
| `lib/net/tcp.rx` | TCP protocol |
| `lib/net/http.rx` | HTTP client |
| `lib/net/tls.rx` | TLS 1.3 client |
| `lib/net/ethernet_arp.rx` | Ethernet/ARP |
| `lib/net/ipv4_icmp.rx` | IPv4/ICMP |
| `lib/net/udp_dhcp.rx` | UDP/DHCP |
| `lib/net/dns.rx` | DNS resolver |
| `lib/net/socket_poll.rx` | Socket polling |

## Graphics & UI

| Module | Description |
|--------|-------------|
| `lib/gfx/framebuffer.rx` | Framebuffer |
| `lib/gfx/compositor.rx` | Window compositor |
| `lib/gfx/gpu_cmd.rx` | GPU command buffer |
| `lib/gfx/ui_toolkit.rx` | UI toolkit |

## Web

| Module | Description |
|--------|-------------|
| `lib/web/dom_bom.rx` | DOM/BOM API |
| `lib/web/bom_events.rx` | Browser events |
| `lib/web/fetch.rx` | Fetch API |
| `lib/web/canvas.rx` | Canvas2D |

## Mobile

| Module | Description |
|--------|-------------|
| `lib/mobile/android_ios_abi.rx` | Android/iOS ABI |
| `lib/mobile/packaging.rx` | APK/IPA packaging |
| `lib/mobile/sensors_radio.rx` | Sensors and radio |

## Concurrency

| Module | Description |
|--------|-------------|
| `lib/sync/executor.rx` | Async executor |
| `lib/sync/channel.rx` | Typed channels |
| `lib/sync/spinlock.rx` | Spinlocks |
| `lib/sync/fiber.rx` | Fibers |
| `lib/sync/goroutine.rx` | M:N goroutine scheduler |
| `lib/sync/atomic.rx` | Atomic operations |
| `lib/sync/priority_sched.rx` | Preemptive priority scheduler |

## Time

| Module | Description |
|--------|-------------|
| `lib/time/duration.rx` | Duration type |
| `lib/time/sleep.rx` | Sleep functions |
| `lib/time/bench.rx` | Benchmarking |
| `lib/time/clock.rx` | Clock |

## Cryptography

| Module | Description |
|--------|-------------|
| `lib/crypto/blake3.rx` | BLAKE3 hash |
| `lib/crypto/ed25519.rx` | Ed25519 signatures |
| `lib/crypto/merkle.rx` | Merkle trees |
| `lib/crypto/x509.rx` | X.509 certificates |
| `lib/crypto/codesign_tpm.rx` | Code signing / TPM |

## Debugging & Profiling

| Module | Description |
|--------|-------------|
| `lib/debug/dwarf_gdb.rx` | DWARF / GDB support |
| `lib/debug/sanitizer.rx` | Memory sanitizers |
| `lib/debug/profiler_fuzz.rx` | Profiler / fuzzer |

## Containers & Cloud

| Module | Description |
|--------|-------------|
| `lib/container/oci_runtime.rx` | OCI container runtime |
| `lib/container/vmm_kvm.rx` | KVM virtual machine monitor |
| `lib/container/k8s_cloud.rx` | Kubernetes integration |

## Internationalization

| Module | Description |
|--------|-------------|
| `lib/i18n/unicode_bidi.rx` | Unicode bidirectional text |
| `lib/i18n/locale_tz_ime.rx` | Locale, timezone, IME |

## Build System

| Module | Description |
|--------|-------------|
| `lib/build/build_system.rx` | Declarative build graph |
| `lib/build/dep_graph.rx` | Dependency graph |
| `lib/build/cache.rx` | Build cache |
| `lib/build/linker_layout.rx` | Linker layout |

## JIT

| Module | Description |
|--------|-------------|
| `lib/jit/jit_engine.rx` | Multi-arch JIT engine |
| `lib/jit/jit_arm64.rx` | ARM64 JIT backend |
| `lib/jit/jit_riscv.rx` | RISC-V JIT backend |

## RXD Data Format

| Module | Description |
|--------|-------------|
| `lib/rxd/rxd.rx` | RXD parser |
| `lib/rxd/types.rx` | RXD types |
| `lib/rxd/query.rx` | RXD query |
| `lib/rxd/units.rx` | RXD units |
| `lib/rxd/vitrify.rx` | RXD vitrification |
| `lib/rxd/materialize.rx` | RXD materialization |

## Format

| Module | Description |
|--------|-------------|
| `lib/format/shape_bind.rx` | Shape binding |
| `lib/format/rxd.rx` | RXD format |
| `lib/format/rxdb.rx` | RXDB binary format |
| `lib/format/json.rx` | JSON encoder/decoder |
| `lib/format/regex.rx` | Regular expressions |

## C Compatibility

| Module | Description |
|--------|-------------|
| `lib/c/stdarg.rx` | C variadic arguments |
