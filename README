# HeMem Boost

## Implementation

1. **Interception of `mmap` Calls**  
   - We use a custom interposer that hooks into the standard `mmap` system call.  
   - The interposer checks any developer-specified hint flags 
	(for example, `tier = 0` for DRAM or `1` for NVM) and  `priority = 1` (hot) or `0` (cold).  
   - If a hint is provided, the allocator immediately places those pages in the designated tier, bypassing 
     HeMem’s default “fill DRAM first” policy.

2. **API and Data Structures**  
   - A lightweight API exposes functions like `set_memory_tier_hint(int tier, int priority)`.  
   - Internally, these store hint values in global or thread-local variables so the interposer can pick them up 
     on the next `mmap` call.  
   - If no hints are set, HeMem reverts to its default behavior, maintaining full backward compatibility.

3. **Modified GUPS Benchmark**  
   - We modified the GUPS microbenchmark (originally used by HeMem) to separate the allocated memory into 
     two distinct regions:
     - **Hot region** (accessed ~90% of the time), allocated with `tier=0` (DRAM) and `priority=1` (hot).
     - **Cold region** (accessed ~10% of the time), allocated with default or NVM flags.  
   - This separation demonstrates how the user hints steer hot data into DRAM from the outset, 
     minimizing the need for migration later in execution.

4. **Reduced Migration Overhead**  
   - By using developer insights to place data in the correct tier initially, the system avoids repeated 
     “guess and check” migrations.  
   - Hot data stays in DRAM longer, while cold data is put in NVM by default or migrated there with minimal 
     overhead once DRAM is full.
