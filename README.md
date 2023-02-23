# Maya-plug-in-SmoothNormalToVertexColor
此插件可以在不改变当前法线数据的情况下，将模型的平滑法线（切线空间）写入到顶点色中；

插件编写于maya2022版本，低版本未经测试 如果使用过程有什么bug，或者建议请留言作者

#使用说明：

    *下载压缩包---》解压到文件夹里（注意不要有中文路径）
    
    *打开maya，依次点击---》窗口----》设置/首选项---》插件管理器---》点击下面的 浏览
        ---》找到文件夹中的 SmoothNormalToVertexColor/Pulg-in/下面的.mll文件
        在插件管理器拉到最下面--》注册的其他插件  中显示有此插件，即注册成功；
        
    *注册成功后，选中网格物体，在时间轴下面的MEL输入框中输入《smoothNormal》（注意大小写，和下面的shader的colorSetName不同），即可执行脚本；
    
! 一些注意事项：

    * 请注意顶点色的顺序，如果你的项目中有不止一个颜色集，请统一顺序，不要给自己和程序找麻烦;
    * 如果你网格的顶点颜色集为空，或者没有名为：SmoothNormal的颜色集，那么插件会为你创建一个；
    * 如果你的maya的颜色集调整顺序不可用（我的就有这个问题）那么请创建正确顺序的颜色集，并将需要执行这个插件的颜色集改名为SmoothNormal；

#查看结果：

      * 在解压出的文件夹中，除了存放插件本体的pulg-in 文件夹，还有个Shader文件夹，我在里面写了个用来测试最终效果的DX11shader；
      * 如果要使用这个shader，需要将Viewport2.0的显示模式改成DirectX11,并且重新启动maya，打开材质页面就可以创建DX11Shader了；
      * 创建材质后，将着色器文件改成解压出来的Shader文件，然后把  曲面数据下的Color0选项，从color:colorSet改成color:SmoothNormal；
      * ！！注意，TestShader中的OutLineWidth是在ObjectSpace计算的，并不正确，如果需要，请根据需要自行更改（啊对对对~我就是个懒狗~欸嘿~！）；
