struct VertexInput {
  @location(0) vertexPosition : vec4f,
  @location(1) vertexNormal : vec3f,
  @location(2) vertexTexCoord : vec4f,
  @builtin(instance_index) instance : u32,
}

// Fragment shaders used with this vertex shader declare the outputs they need
// as inputs, with the same locations.
struct VertexOutput {
  @builtin(position) position : vec4f,
  @location(0) tex : vec4f,
  @location(1) modelPosition : vec4f,
  @location(2) worldPosition : vec4f,
  @location(3) worldNormal : vec4f,
}

@vertex
fn vsMain(input : VertexInput) -> VertexOutput {
  let modelMatrix = gameObjects[input.instance].modelMatrix;
  let modelMatrixInverse = gameObjects[input.instance].modelMatrixInverse;

  var output : VertexOutput;
  output.modelPosition = input.vertexPosition;
  output.worldPosition = modelMatrix * input.vertexPosition;
  output.position = camera.viewProjMatrix * output.worldPosition;
  // normals transform with the inverse transpose
  output.worldNormal = transpose(modelMatrixInverse) * vec4f(input.vertexNormal, 0);
  output.tex = input.vertexTexCoord;
  return output;
}
