package main

import (
	"io"
	"os"
)

func main() {
	// patch the context-path of fonts.css and 404.html for typo theme
	copyFile("patches/typo/fonts.css", "themes/typo/assets/css/fonts.css")
	copyFile("patches/typo/404.html", "themes/typo/layouts/404.html")
}

func copyFile(src, target string) error {
	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	targetFile, err := os.Create(target)
	if err != nil {
		return err
	}
	defer targetFile.Close()

	_, err = io.Copy(targetFile, srcFile)
	return err
}
