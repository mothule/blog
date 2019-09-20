# Gitでリモートのみファイル削除する方法

```sh
$ git rm --cached [file_name]
```

フォルダを削除する場合は、 `-r` をつける。

```sh
$ git rm --cached -r [directory_name]
```

あとは変更をリモートにプッシュして完了です。

```sh
$ git add .
$ git commit -m "Delete files"
$ git push
```

最新のみclone
$ git clone --depth 1 https://github.com/opencv/opencv.git
