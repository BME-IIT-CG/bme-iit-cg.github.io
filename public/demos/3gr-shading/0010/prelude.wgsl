// Declarations shared by all shaders. This file is appended to every shader.
//
// Each variable is supplied by the Kotlin object that claims its name:
// UniformProvider("camera"), InstanceGroup("lights"), InstanceGroup("gameObjects").
// The members of a struct are the uniforms of that object.

struct Camera {
  viewProjMatrix : mat4x4f,
  rayDirMatrix : mat4x4f,
  position : vec3f,
}

struct Light {
  position : vec4f,      // w=1: point light at position, w=0: directional light from direction
  powerDensity : vec3f,
}

struct GameObject {
  modelMatrix : mat4x4f,
  modelMatrixInverse : mat4x4f,
}

// group 0: per frame
@group(0) @binding(0) var<uniform> camera : Camera;
@group(0) @binding(1) var<uniform> lights : array<Light, 8>;

// group 1: per material, declared in the shaders

// group 2: per object, indexed by the instance index
@group(2) @binding(0) var<storage, read> gameObjects : array<GameObject>;
