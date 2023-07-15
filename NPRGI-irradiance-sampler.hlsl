// 一个适用于 s&box 或 Source 2 非真实感渲染 (这里是卡通渲染) 着色器的间接光照采样器

static LightResult Indirect(PixelInput i, Material m) //间接光照信息
        {
            LightResult result = LightResult::Init();

            Light light = AmbientLight::From(i, m);
            float3 vAmbientCube[6];
            SampleLightProbeVolume(vAmbientCube, light.Position); //采样 Light Probe Volume
          
// 注意起源 2 还不是球谐函数，V 社是个懒狗，用了尼玛二十几年的技术
          
            float3 secondaryGI = 0.5 * (SampleIrradiance(vAmbientCube, float3(0, 1, 0)) + SampleIrradiance(vAmbientCube, float3(0, -1, 0))); // 采样辐照度
            indirectLighting = lerp(secondaryGI, SampleIrradiance(vAmbientCube, normalWs), IndirectLightIntensity);
            indirectLighting = lerp(indirectLighting, max(EPS_COL, max(indirectLighting.x, max(indirectLighting.y, indirectLighting.z))), LightColorAttenuation); // 衰减
            result.Diffuse = indirectLighting * lit.rgb;

            result.Diffuse = min(result.Diffuse, lit.rgb); // 这是一个取最小值函数，如果只要默认 Complex / Simple Shader (PBR) 那就把它注释掉

            // 无 Specular (高光反射项)
            result.Specular = 0.0f;

            return result;
        }
