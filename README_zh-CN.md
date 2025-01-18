# 如何在 GitHub 上创建笔记

> 在 GitHub 上创建笔记，并利用 `GitHub Actions` 实现自动发布 `Hugo` 站点到 `GitHub Pages`

### 1. 创建 GitHub 仓库
在 GitHub 上创建一个新的仓库，例如 `notebook`。

### 2. 初始化 Hugo 站点
在本地机器上[安装Hugo](https://gohugo.io/installation/)，然后初始化一个新的 Hugo 站点，并将其推送到 GitHub：

```sh
hugo new site notebook
cd notebook
git init
git remote add origin https://github.com/ryanpenn/notebook.git
```

### 3. 添加主题
选择一个 Hugo 主题并添加到你的站点。例如，使用 [hyde](https://github.com/spf13/hyde) 主题：

```sh
git submodule add https://github.com/spf13/hyde.git themes/hyde
echo 'theme = "hyde"' >> hugo.toml
```

### 4. 创建 GitHub Actions 工作流
在你的 Hugo 项目根目录下创建一个 `.github/workflows` 目录，并在其中创建一个 `deploy.yml` 文件：

```yaml
name: Deploy Hugo site to GitHub Pages

on:
  push:
    branches:
      - master

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Setup Hugo
      uses: peaceiris/actions-hugo@v3
      with:
        hugo-version: 'latest'

    - name: Install theme
      run: git submodule update --init --recursive

    - name: Build site
      run: hugo --minify

    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./public
```

### 5. 配置 GitHub Pages
在 GitHub 仓库的设置中，启用 GitHub Pages，并选择 `gh-pages` 分支作为发布源。`gh-pages` 分支可以由 GitHub Actions 自动创建

### 6. 提交和推送更改
将所有更改提交并推送到 GitHub：

```sh
git add .
git commit -m "Initial commit"
git push -u origin master
```

### 7. 自动发布
每次你推送到 `master` 分支时，GitHub Actions 将自动构建并部署你的 Hugo 站点到 `gh-pages` 分支，从而更新你的 GitHub Pages 站点。

### 8. 添加内容
你可以使用 Hugo 命令添加新内容，例如：

```sh
hugo new posts/my-first-post.md
```

然后编辑生成的 Markdown 文件，添加你的博客内容。

### 9. 提交和推送更改
每次你添加或修改内容后，记得提交并推送更改：

```sh
git add .
git commit -m "Add new post"
git push origin master
```

GitHub Actions 将自动构建并部署你的站点。

这样，你就可以利用 GitHub Actions 实现自动发布 Hugo 站点到 GitHub Pages。