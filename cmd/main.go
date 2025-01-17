package main

import (
	"io"
	"os"
)

func main() {
	copyFile("cmd/res/fonts.css", "themes/typo/assets/css/fonts.css")
	copyFile("cmd/res/404.html", "themes/typo/layouts/404.html")
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
