struct FragmentInput {
  @location(1) modelPosition : vec4f,
  @location(2) worldPosition : vec4f,
  @location(3) worldNormal : vec4f,
}

@group(1) @binding(0) var material_envmapTexture : texture_cube<f32>;
@group(1) @binding(1) var material_envmapTextureSampler : sampler;

// iMSc: procedural normal mapping
fn noiseGrad(r : vec3f) -> vec3f {
  var s = vec3u(
    0x1D4E1D4Eu,
    0x58F958F9u,
    0x129F129Fu);
  var f = vec3f(0, 0, 0);
  for(var i = 0; i < 16; i++) {
    let sf = vec3f(s & vec3u(0xFFFFu)) / 65536.0 - vec3f(0.5, 0.5, 0.5);
    f += cos(dot(sf, r)) * sf;
    s = s >> vec3u(1u);
  }
  return f;
}

const noiseFreq = 10.0;
const noiseAmplitude = 0.05;

@fragment
fn fsMain(input : FragmentInput) -> @location(0) vec4f {
  var normal = normalize(input.worldNormal.xyz);
  // gradient of (implicit surface + noise), noise taken in model space so that it sticks to the object
  normal = normalize(normal + noiseAmplitude * noiseFreq * noiseGrad(input.modelPosition.xyz * noiseFreq));

  let x = input.worldPosition.xyz / input.worldPosition.w;
  let viewDir = normalize(camera.position - x);
  return textureSample(material_envmapTexture, material_envmapTextureSampler, reflect(-viewDir, normal));
}
