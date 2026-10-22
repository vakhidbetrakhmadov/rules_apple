#include <metal_stdlib>

using namespace metal;

kernel void foo(device float *output [[buffer(0)]], uint index [[thread_position_in_grid]]) {
    output[index] = 0.0f;
}
