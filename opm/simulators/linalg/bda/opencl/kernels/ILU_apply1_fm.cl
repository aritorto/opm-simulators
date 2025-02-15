/// ILU apply part 1: forward substitution.
/// Solves L*x=y where L is a lower triangular sparse blocked matrix.
/// Here, L is inside a normal, square matrix.
/// In this case, diagIndex indicates where the rows of L end.
__kernel void ILU_apply1(
    __global const double *LUvals,
    __global const unsigned int *LUcols,
    __global const unsigned int *LUrows,
    __global const int *diagIndex,
    __global const double *y,
    __global double *x,
    __global const unsigned int *nodesPerColorPrefix,
    const unsigned int color,
    const unsigned int block_size,
    __local double *tmp)
{
    const unsigned int warpsize = get_local_size(0);
    const unsigned int bs = block_size;
    const unsigned int idx_t = get_local_id(0);
    const unsigned int num_active_threads = (warpsize/bs/bs)*bs*bs;
    const unsigned int num_blocks_per_warp = warpsize/bs/bs;
    const unsigned int NUM_THREADS = get_global_size(0);
    const unsigned int num_warps_in_grid = NUM_THREADS / warpsize;
    unsigned int idx = get_global_id(0);
    unsigned int target_block_row = idx / warpsize;
    target_block_row += nodesPerColorPrefix[color];
    const unsigned int lane = idx_t % warpsize;
    const unsigned int c = (lane / bs) % bs;
    const unsigned int r = lane % bs;

    while(target_block_row < nodesPerColorPrefix[color+1]){
        const unsigned int first_block = LUrows[target_block_row];
        const unsigned int last_block = diagIndex[target_block_row];
        unsigned int block = first_block + lane / (bs*bs);
        double local_out = 0.0;

        if(lane < num_active_threads){
            if(lane < bs){
                local_out = y[target_block_row*bs+lane];
            }
            for(; block < last_block; block += num_blocks_per_warp){
                const double x_elem = x[LUcols[block]*bs + c];
                const double A_elem = LUvals[block*bs*bs + c + r*bs];
                local_out -= x_elem * A_elem;
            }
        }

        // do reduction in shared mem
        tmp[lane] = local_out;
        barrier(CLK_LOCAL_MEM_FENCE);

        for(unsigned int offset = 3; offset <= 24; offset <<= 1)
        {
            if (lane + offset < warpsize)
            {
                tmp[lane] += tmp[lane + offset];
            }
            barrier(CLK_LOCAL_MEM_FENCE);
        }

        if(lane < bs){
            const unsigned int row = target_block_row*bs + lane;
            x[row] = tmp[lane];
        }

        target_block_row += num_warps_in_grid;
    }
}
