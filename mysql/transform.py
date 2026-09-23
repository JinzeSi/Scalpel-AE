import os

if __name__ == "__main__":
    # 创建一个空的assets目录，如果assets已存在要强行清空，打开summary.md文件，找到其中所有的图片路径，将这些图片拷贝到assets目录下，然后替换summary.md中的图片路径
    if os.path.exists("assets"):
        os.system("rm -rf assets")
    os.mkdir("assets")
    with open("summary.md", "r") as file:
        lines = file.readlines()
    for line in lines:
        if line.startswith("!["):
            image_path = line.split("(")[1].split(")")[0]
            if image_path.startswith("./"):
                image_path = image_path[2:]
            image_name = "_".join(image_path.split("/"))
            os.system(f"cp {image_path} assets/{image_name}")
    with open("summary-win.md", "w") as file:
        for line in lines:
            if line.startswith("!["):
                image_path = line.split("(")[1].split(")")[0]
                if image_path.startswith("./"):
                    image_path = image_path[2:]
                image_name = "_".join(image_path.split("/"))
                file.write(f"![{image_name}](assets/{image_name})\n")
            else:
                file.write(line)
                
    # 将assets目录和summary-win.md文件打包为一个压缩包
    os.system("zip -r output.zip assets summary-win.md")