////				
//			基础光照shader（）
//
bool VertexColor
<
	string UIGroup = "diffuse";
	//string UIGroup = "Diffuse";
	string UIName = "VertexColor";
	int UIOrder = 1;
> = false;
float3 lumin_Color//光照着色
<
	string UIGroup = "diffuse";//
	string UIName = " lumin_Color";
	string UIwidget = "ColorPiaker";
> ;
float3 shadow_Color//非光照着色
<
	//string Object = "diffuse";//
	string UIGroup = "diffuse";
	string UIName = " shadow_Color";
	string UIwidget = "ColorPiaker";
> ;
float StepMin
<
	//string UIGroup = "Lighting";//子菜单栏
	string UIGroup = "diffuse";
	string UIWidget = "Slider";
	float UIMin = 0.0;
	float UIMax = 1.0;
	float UIStep = 0.001;//每次进给
	string UIName = "Cel Step Min";
	int UIOrder = 60;
> = 0.5;
float StepMax
<
	//string UIGroup = "Lighting";//子菜单栏
	string UIGroup = "diffuse";
	string UIWidget = "Slider";
	float UIMin = 0.0;
	float UIMax = 1.0;
	float UIStep = 0.001;//每次进给
	string UIName = "Cel Step Max";
	int UIOrder = 60;
> = 1.0;
float3 line_Color
<
	string UIGroup = "diffuse";//
	string UIName = " line Color";
	string UIwidget = "ColorPiaker";
	int UIOrder = 61;
> ;
float line_width
<
	//string UIGroup = "Lighting";
	string UIGroup = "diffuse";
	string UIWidget = "Slider";
	float UIMin = 0.0;
	float UIMax = 1.0;
	float UIStep = 0.001;
	string UIName = "line width";
	int UIOrder = 62;
> = 0.8;

float3 SpecularColor
<
	//string Object = "diffuse";//
	string UIGroup = "Specular";
	string UIName = " Specular Color";
	string UIwidget = "ColorPiaker";
> ;
float Gloss
<
	//string UIGroup = "Lighting";
	string UIGroup = "Specular";
	string UIWidget = "Slider";
	float UIMin = 1.0;
	float UIMax = 500.0;
	float UIStep = 0.001;
	string UIName = "Gloss";
	int UIOrder = 60;
> = 50;

bool TextureSwitch
<
	string UIGroup = "Texture";
	//string UIGroup = "Diffuse";
	string UIName = "Texture On";
	int UIOrder = 1;
> = false;
//float3 step//光照阈值
//<
//	//string Object = "diffuse";//
//	string UIName = " step";
//	//string UIwidget = "ColorPiaker";
//> ;
texture Texture_1 <
	string UIGroup = "Texture";
	string ResourceName = "Numbers.dds";
	string UIName = "Texture_1";
	string ResourceType = "2D";//图片类型
> ;
float3 gLight0Dir : DIRECTION <
	string Object = "DirectionalLight1";
	string UIName = "Lamp 0 Direction";
	//string Space = (LIGHT_COORDS);
> = { 0.7f,-0.7f,-0.7f };
float4x4 worldMatrix:World;
float4x4 wvp:worldViewProjection;
float4x4 wvp_vector : WorldInverseTranspose;
float4x4 ViewMatrix : ViewInverse;

struct a2v
{

	float4 pos:POSITION;
	float3 Normal:NORMAL;
	float3 Tangent:TANGENT;
	float3 BiTangent:BINORMAL;
	float2 texcoord:TEXCOORD0;
	float4 V_color:COLOR;
};

struct v2f
{
	float4 pos_c:SV_Position;
	float3 wNormal:TEXCOORD0;
	float3 wLightDir:TEXCOORD1;
	float3 wViewDir:TEXCOORD2;
	float2 uv:TEXCOORD3;
	float3 vertexColor:TEXCOORD4;
};

v2f Line_vertex(a2v input_Line)
{
	v2f out_Line;
	//TangentSpaceToObjectSpaceMatrix
	float3 T2O_X = float3 (input_Line.Tangent.x, input_Line.BiTangent.x, input_Line.Normal.x);
	float3 T2O_Y = float3 (input_Line.Tangent.y, input_Line.BiTangent.y, input_Line.Normal.y);
	float3 T2O_Z = float3 (input_Line.Tangent.z, input_Line.BiTangent.z, input_Line.Normal.z);
	float3 nor = normalize(input_Line.V_color.xyz*2-1);
	float x = (dot(T2O_X,nor));
	float y = (dot(T2O_Y,nor ));
	float z = (dot(T2O_Z,nor ));
	float3 outLineNormal = normalize(float3(x, y, z));
	out_Line.pos_c = mul( float4(input_Line.pos.xyz + outLineNormal * (line_width),1)     , wvp);
	out_Line.vertexColor= outLineNormal;
	return out_Line;

}
float4 Line_pixel(v2f i) :SV_Target
{
	return float4(line_Color,1);

}








v2f vertex(a2v v)
{
	v2f o;
	o.pos_c = mul(v.pos, wvp);
	o.wNormal = mul(float4(v.Normal, 0.0f), wvp_vector).xyz;
	o.wLightDir = -normalize(gLight0Dir).xyz;
	float4 worldPos = mul(float4(v.pos.xyz, 1), worldMatrix);
	worldPos /= worldPos.w;
	o.wViewDir = normalize(ViewMatrix[3].xyz - worldPos.xyz);
	o.uv = v.texcoord;
	o.vertexColor = v.V_color.xyz;
	return o;

}

sampler2D gImageSampler = sampler_state {
	Texture = <Texture_1>;
#if DIRECT3D_VERSION >= 0xa00 
	Filter = MIN_MAG_MIP_LINEAR;
#else /* DIRECT3D_VERSION < 0xa00 */
	MinFilter = Linear;
	MipFilter = Linear;
	MagFilter = Linear;
#endif /* DIRECT3D_VERSION */
	AddressU = Wrap;
	AddressV = Wrap;
};
float4 pixel(v2f i) :SV_Target
{


	float3 LightVec = normalize(i.wLightDir);
	float3 Nor = normalize(i.wNormal);
	float3 view = normalize(i.wViewDir);
	float3 dif = dot(LightVec, Nor) * 0.5 + 0.5;
	float3 col = tex2D(gImageSampler,float2(i.uv.x, 1 - i.uv.y)).rgb;
	float3 aa = smoothstep(StepMin, StepMax, dif);

	float3 H = normalize(view + LightVec);
	float3 specular = pow(max(dot(H, Nor), 0), Gloss * 10) * SpecularColor.rgb;


	float3 outColor = (lerp(shadow_Color, lumin_Color,aa) + specular);

	if (TextureSwitch)
		outColor *= col;
	if (VertexColor)
		outColor = i.vertexColor.xyz;
	return float4 (outColor,1);
}

RasterizerState Rasterizer_Outline
{
#ifdef _MAYA_

	CullMode = BACK;
#else 
	CullMode = FRONT;
#endif
};
RasterizerState Rasterizer_Base
{
#ifdef _MAYA_

	CullMode = FRONT;
#else 
	CullMode = BACK;
#endif 
};
technique11 bese_color
< string Script = "Pass=p0;Pass=p1;"; >
{
	pass p0 <
		string Script = "Draw=geometry;";
	>
	{
		SetVertexShader(CompileShader(vs_5_0, Line_vertex()));
		SetGeometryShader(NULL);
		SetPixelShader(CompileShader(ps_5_0, Line_pixel()));
		SetRasterizerState(Rasterizer_Outline);
	}
	pass p1 <
		string Script = "Draw=geometry;";
	>
	{
		SetVertexShader(CompileShader(vs_5_0, vertex()));
		SetGeometryShader(NULL);
		SetPixelShader(CompileShader(ps_5_0, pixel()));
		SetRasterizerState(Rasterizer_Base);
	}


}

