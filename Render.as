
const string texture_name = "stoneblock.png";

u16[] v_i;
Vertex[] v_raw = {
Vertex( 1, -1, -2.5,  0, 0,  SColor(0xff4d4d4d)),//fbr
Vertex( 1, -1, -1.5,    1, 0,  SColor(0xff4d4d4d)),//bbr
Vertex(-1, -1, -1.5,    1, 1,  SColor(0xff4d4d4d)),//bbl
Vertex(-1, -1, -2.5,  0, 1,  SColor(0xff4d4d4d)),//fbl
Vertex( 1,  1, -2.5,  0, 1,  SColor(0xffffffff)),//ftr
Vertex( 1,  1, -1.5,    1, 1,  SColor(0xffffffff)),
Vertex(-1,  1, -1.5,    1, 0,  SColor(0xffffffff)),
Vertex(-1,  1, -2.5,  0, 0,  SColor(0xffffffff)),
};

float[] quad_faces = {
	0, 1, 2, 3,   //bottom
	4, 7, 6, 5,   //top
	0, 4, 5, 1,   //right
	//1, 5, 6, 2, //back
	2, 6, 7, 3,   //left
	//4, 0, 3, 7, //front
};

float[] view;
float[] model;
float[] proj;
float ratio = f32(getDriver().getScreenWidth()) / f32(getDriver().getScreenHeight());

void onInit(CRules@ this)
{
	int cb_id = Render::addScript(Render::layer_postworld, "Render.as", "RenderFunction", 0.0f);
	
	Matrix::MakeIdentity(model);
	Matrix::MakeIdentity(view);	
	Matrix::SetTranslation(view, 0, 0, 50 );
	Matrix::MakePerspective(proj, Maths::Pi / 2.0f, ratio, 0.1, 100 );
	Render::SetBackfaceCull(true);
}

void RenderFunction(int id)
{
	CMap@ map = getMap();

	const u16 mapheight =	(map.tilemapheight);
	const u16 mapwidth =	(map.tilemapwidth);	

	CCamera@ camera = getCamera();
	Driver@  driver = getDriver();

	const f32 scalex = driver.getResolutionScaleFactor();
	const f32 zoom = camera.targetDistance * scalex;

	v_i.clear();
	
	Matrix::SetScale(model, zoom, zoom, 2*scalex);
	

	for (u16 x = 0; x < mapwidth; ++x)
	{
		for (u16 y = 0; y < mapheight; ++y)
		{
			Vec2f tp = Vec2f( (x * 8.0f)+4.0f , (y * 8.0f)+4.0f);
			TileType tile = map.getTile(tp).type;

			if (tile != 48) continue;

			Vec2f sp = driver.getScreenPosFromWorldPos(tp);

			Matrix::SetTranslation(model, (sp.x/8)-(driver.getScreenWidth()/16), -(sp.y/8)+(driver.getScreenHeight()/16) , 0);			
			Render::SetTransform(model, view, proj);
			
			//Render::SetTransformScreenspace();
			
			for(int i = 0; i < quad_faces.length; i += 4)
			{
				int id_0 = quad_faces[i+0];
				int id_1 = quad_faces[i+1];
				int id_2 = quad_faces[i+2];
				int id_3 = quad_faces[i+3];

				v_i.push_back(id_0); v_i.push_back(id_1); v_i.push_back(id_3);
				v_i.push_back(id_1); v_i.push_back(id_2); v_i.push_back(id_3);
			}
	
			Render::RawTrianglesIndexed(texture_name, v_raw, v_i);
		}
	}
}
