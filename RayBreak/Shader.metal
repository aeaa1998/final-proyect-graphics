#include <metal_stdlib>
using namespace metal;

constant float3 kSpecularColor= { 1, 1, 1 };
constant float kSpecularPower = 80;

struct VertexInput {
    float4 position  [[attribute(0)]];
    float4 normal    [[attribute(1)]];
    float2 texCoords [[attribute(2)]];
};

struct Uniforms {
    float4x4 modelViewProjectionMatrix;
    float4x4 modelViewMatrix;
    float3x3 normalMatrix;
    int grayShader;
    int invertedShader;
    int invertedShader2;
    float timeEllapsed;
};

struct LightShades {
    float redShade;
    float greenShade;
    float blueShade;
};

struct ShadesOn {
    float lightsShade;
};

struct VertexProjected {
    float4 position [[position]];
    float3 eyePosition;
    float3 normal;
    float2 texCoords;
    int grayShader;
    int invertedShader;
    float redShade;
    float greenShade;
    float blueShade;
    float lightsShade;
};

vertex VertexProjected main_vertex(const    VertexInput v   [[stage_in]],
                                   constant Uniforms&   u   [[buffer(1)]],
                                   constant LightShades&   l   [[buffer(2)]],
                                    constant ShadesOn&   sh   [[buffer(3)]]
                                   ) {
    return VertexProjected {
        .position = u.modelViewProjectionMatrix * v.position,
        .eyePosition = -(u.modelViewMatrix * v.position).xyz,
        .normal = u.normalMatrix * v.normal.xyz,
        .texCoords = v.texCoords,
        .grayShader = u.grayShader,
        .invertedShader = u.invertedShader2,
        .blueShade = l.blueShade,
        .redShade = l.redShade,
        .greenShade = l.greenShade,
        .lightsShade = sh.lightsShade
    };
}

struct Light {
    float3 direction;
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
};

constant Light light = {
    .direction     = { 0.13, 0.72, 0.68 },
    .ambientColor  = { 0.05, 0.05, 0.05 },
    .diffuseColor  = { 1, 1, 1 },
    .specularColor = { 0.2, 0.2, 0.2 }
};

constant float3 kRec709Luma = float3(0.2126, 0.7152, 0.0722);

kernel void grayscale(texture2d<float,access::read>  in  [[texture(0)]],
                      texture2d<float,access::write> out [[texture(1)]],
                      uint2                          gid [[thread_position_in_grid]]) {
    if (gid.x < in.get_width() && gid.y < in.get_height()) {
        float4 const inColor = in.read(gid);
        float const gray = dot(inColor.rgb, kRec709Luma);
        float4 const outColor = float4(gray, gray, gray, inColor.a);
        out.write(outColor, gid);
    }
}


fragment float4 main_fragment(
                              VertexProjected  v              [[stage_in]],
                              texture2d<float> diffuseTexture [[texture(0)]],
                              sampler          samplr         [[sampler(0)]]) {
    float3 diffuseColor = diffuseTexture.sample(samplr, v.texCoords).rgb;
    //Check if grayscale is on
    if(v.lightsShade != 0){
        int removeTime = 5;
//        float i = 10;
        float red = v.redShade ;
        float green = v.greenShade;
        float blue = v.blueShade;
        float newRed = diffuseColor[0] * red + (1 - red);
        float newGreen = diffuseColor[1] * green + (1 - green);
        float newBlue = diffuseColor[2] * blue + (1 - blue);
        diffuseColor = float3(newRed, newGreen, newBlue);
    }
    if(v.grayShader == 1){
        float const gray = dot(diffuseColor, kRec709Luma);
        diffuseColor = float3(gray, gray, gray);
        
    }
    if(v.invertedShader == 1){
        diffuseColor = float3(1 - diffuseColor[0], 1 - diffuseColor[1], 1 - diffuseColor[2]);
    }

//    float const diffuseColor = dot(inColor, kRec709Luma);
    float3 const ambientTerm = light.ambientColor * diffuseColor;
    
    float3 const normal = normalize(v.normal);
    float const diffuseIntensity = saturate(dot(normal, light.direction));
    float3 const diffuseTerm = light.diffuseColor * diffuseColor * diffuseIntensity;
    
    float3 specularTerm(0);
    if (diffuseIntensity > 0) {
        float3 const eyeDirection = normalize(v.eyePosition);
        float3 const halfway = normalize(light.direction + eyeDirection);
        float specularFactor = pow(saturate(dot(normal, halfway)), kSpecularPower);
        specularTerm = light.specularColor * kSpecularColor * specularFactor;
    }
    
    return float4(ambientTerm + diffuseTerm + specularTerm, 1);
}
