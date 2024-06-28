#version 330 core

layout (location = 0) out vec3 fragColor;

in vec2 uv_0;
in vec3 normal;
in vec3 fragPos;

struct Light {
    vec3 direction;
    vec3 color;
};

uniform Light light;
uniform vec3 camPos;

uniform sampler2DArray u_texture_0;

const float PI = 3.14159265359;

// ----------------------------------------------------------------------------
float DistributionGGX(vec3 N, vec3 H, float roughness)
{
    float a = roughness * roughness;
    float a2 = a * a;
    float NdotH = max(dot(N, H), 0.0);
    float NdotH2 = NdotH * NdotH;

    float nom   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return nom / denom;
}
// ----------------------------------------------------------------------------
float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r * r) / 8.0;

    float nom   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}
// ----------------------------------------------------------------------------
float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2 = GeometrySchlickGGX(NdotV, roughness);
    float ggx1 = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}
// ----------------------------------------------------------------------------
vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}
// ----------------------------------------------------------------------------
vec3 fresnelSchlickRoughness(float cosTheta, vec3 F0, float roughness)
{
    return F0 + (max(vec3(1.0 - roughness), F0) - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
} 
// ----------------------------------------------------------------------------
vec3 CalcLight(vec3 albedo, vec4 arms, vec3 Normal, float shadow)
{		
    vec3 N = normalize(Normal);
    vec3 V = normalize(camPos - fragPos);
   
    vec3 F0 = vec3(arms.a); 
    F0 = mix(F0, albedo, arms.b);

    // calculate per-light radiance
    vec3 L = normalize(-light.direction);
    vec3 H = normalize(V + L);
    vec3 radiance = light.color;

    // Cook-Torrance BRDF
    float NDF = DistributionGGX(N, H, arms.g);   
    float G   = GeometrySmith(N, V, L, arms.g);      
    vec3 F    = fresnelSchlick(clamp(dot(H, V), 0.0, 1.0), F0);
        
    float cosTheta = max(dot(N, V), 0.0);
    float NdotL = dot(N, L);

    vec3 numerator    = NDF * G * F; 
    float denominator = 4.0 * cosTheta * max(NdotL, 0.0) + 0.0001; // + 0.0001 to prevent divide by zero
    vec3 specular = numerator / denominator;
    
    // kS is equal to Fresnel
    vec3 kS = F;
    vec3 kD = vec3(1.0) - kS;
    kD *= 1.0 - arms.b;

    // add to outgoing radiance Lo
    return (kD * albedo / PI + specular) * radiance * NdotL;  // note that we already multiplied the BRDF by the Fresnel (kS) so we won't multiply by kS again
}



void main() {
    float gamma = 2.2;
    vec3 color  = texture2D(u_texture_0, uv_0).rgb;
	if (color == vec3(0, 0, 0)) {
		discard;
	}
    color       = pow(color, vec3(gamma));

    color       = CalcLight(color, vec4(1, 0.96, 0, 0), normal);

    fragColor   = vec3(color);
}