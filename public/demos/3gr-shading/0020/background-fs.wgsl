struct FragmentInput {
  @location(1) rayDir : vec4f,
}

@group(1) @binding(0) var material_envTexture : texture_cube<f32>;
@group(1) @binding(1) var material_envTextureSampler : sampler;

@fragment
fn fsMain(input : FragmentInput) -> @location(0) vec4f {
  return textureSample(material_envTexture, material_envTextureSampler, input.rayDir.xyz);
}
