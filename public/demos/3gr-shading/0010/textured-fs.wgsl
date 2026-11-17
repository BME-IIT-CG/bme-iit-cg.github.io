struct FragmentInput {
  @location(0) tex : vec4f,
}

@group(1) @binding(0) var material_colorTexture : texture_2d<f32>;
@group(1) @binding(1) var material_colorTextureSampler : sampler;

@fragment
fn fsMain(input : FragmentInput) -> @location(0) vec4f {
  return textureSample(material_colorTexture, material_colorTextureSampler, input.tex.xy / input.tex.w);
}
