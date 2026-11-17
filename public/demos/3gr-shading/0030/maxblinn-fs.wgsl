struct FragmentInput {
  @location(0) tex : vec4f,
  @location(2) worldPosition : vec4f,
  @location(3) worldNormal : vec4f,
}

struct Material {
  specularColor : vec3f,
  shininess : f32,
}
@group(1) @binding(0) var<uniform> material : Material;
@group(1) @binding(1) var material_colorTexture : texture_2d<f32>;
@group(1) @binding(2) var material_colorTextureSampler : sampler;

fn shade(
  normal : vec3f, lightDir : vec3f, viewDir : vec3f,
  powerDensity : vec3f, materialColor : vec3f, specularColor : vec3f, shininess : f32) -> vec3f {
  let cosa = clamp(dot(lightDir, normal), 0.0, 1.0);
  let cosb = clamp(dot(viewDir, normal), 0.0, 1.0);
  let halfway = normalize(viewDir + lightDir);
  let cosDelta = clamp(dot(halfway, normal), 0.0, 1.0);
  return
    powerDensity * materialColor * cosa
  + powerDensity * specularColor * pow(cosDelta, shininess)
       * cosa / max(cosb, cosa);
}

@fragment
fn fsMain(input : FragmentInput) -> @location(0) vec4f {
  let normal = normalize(input.worldNormal.xyz);
  let x = input.worldPosition.xyz / input.worldPosition.w;
  let viewDir = normalize(camera.position - x);
  let materialColor = textureSample(material_colorTexture, material_colorTextureSampler, input.tex.xy / input.tex.w).rgb;

  var fragmentColor = vec4f(0, 0, 0, 1);
  for(var i = 0; i < 8; i++) {
    if(dot(lights[i].powerDensity, vec3f(1, 1, 1)) <= 0.0) { continue; } // unused light slot
    // w=1: point light at position, w=0: directional light from direction
    let lightDiff = lights[i].position.xyz - x * lights[i].position.w;
    let lightDir = normalize(lightDiff);
    let powerDensity = lights[i].powerDensity / dot(lightDiff, lightDiff);
    fragmentColor = vec4f(fragmentColor.rgb + shade(normal, lightDir, viewDir,
      powerDensity, materialColor,
      material.specularColor, material.shininess), 1);
  }
  return fragmentColor;
}
