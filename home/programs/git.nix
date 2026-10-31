{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    
    lfs.enable = true;
    # 你刚刚修改的新写法
    settings= {
      user = {
        name = "EiYuC";
        email = "caizhiheng0111@icloud.com";
      };

    };

    # ... 其他配置
  };
}
