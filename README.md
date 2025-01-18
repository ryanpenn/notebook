# How to Create Notes on GitHub
> Create notes on GitHub and use `GitHub Actions` to automatically publish a `Hugo` site to `GitHub Pages`.

### 1. Create a GitHub Repository
Create a new repository on GitHub, for example, `notebook`.

### 2. Initialize a Hugo Site
Initialize a new Hugo([Install](https://gohugo.io/installation/)) site on your local machine and push it to GitHub:

```sh
hugo new site notebook
cd notebook
git init
git remote add origin https://github.com/ryanpenn/notebook.git
```

### 3. Add a Theme
Choose a Hugo theme and add it to your site. For example, use the [hyde](https://github.com/spf13/hyde) theme:

```sh
git submodule add https://github.com/spf13/hyde.git themes/hyde
echo 'theme = "hyde"' >> hugo.toml
```

### 4. Create a GitHub Actions Workflow
Create a `.github/workflows` directory in the root of your Hugo project and create a `deploy.yml` file in it:

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

### 5. Configure GitHub Pages
In the settings of your GitHub repository, enable GitHub Pages and select the `gh-pages` branch as the publishing source.

### 6. Commit and Push Changes
Commit and push all changes to GitHub:

```sh
git add .
git commit -m "Initial commit"
git push -u origin master
```

### 7. Automatic Deployment
Every time you push to the `master` branch, GitHub Actions will automatically build and deploy your Hugo site to the `gh-pages` branch, updating your GitHub Pages site.

### 8. Add Content
You can use Hugo commands to add new content, for example:

```sh
hugo new posts/my-first-post.md
```

Then edit the generated Markdown file to add your blog content.

### 9. Commit and Push Changes
Every time you add or modify content, remember to commit and push the changes:

```sh
git add .
git commit -m "Add new post"
git push origin master
```

GitHub Actions will automatically build and deploy your site.

This way, you can use GitHub Actions to automatically publish a Hugo site to GitHub Pages.
