struct VertexInput {
  @location(0) vertexPosition : vec4f,
  @location(1) vertexTexCoord : vec4f,
}

struct VertexOutput {
  @builtin(position) position : vec4f,
  @location(0) texCoord : vec4f,
  @location(1) rayDir : vec4f,
}

@vertex
fn vsMain(input : VertexInput) -> VertexOutput {
  var output : VertexOutput;
  output.texCoord = input.vertexTexCoord;
  output.position = input.vertexPosition;
  output.position.z = 0.99999;
  output.rayDir = camera.rayDirMatrix * input.vertexPosition;
  return output;
}
