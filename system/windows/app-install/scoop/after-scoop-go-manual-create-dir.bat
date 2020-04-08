md golang.org
cd golang.org
md x
cd x
cd ..\..
md github.com
cd github.com

git clone https://gitee.com/jqkdudu/gotests.git
md cweill
mv gotests cweill\gotests

git clone https://gitee.com/jqkdudu/goreturns.git
md sqs
mv goreturns sqs\goreturns

git clone https://gitee.com/jqkdudu/godef.git
md rogpeppe
mv godef rogpeppe\godef

git clone https://gitee.com/jqkdudu/gocode.git
md stamblerre
mv gocode stamblerre\gocode

git clone https://gitee.com/jqkdudu/delve.git
md go-delve
mv delve go-delve\delve

git clone https://gitee.com/jqkdudu/godoctor.git
mv godoctor godoctor2
md godoctor
mv godoctor2 godoctor\godoctor

git clone https://gitee.com/jqkdudu/goplay.git
md haya14busa
mv goplay haya14busa\goplay

git clone https://gitee.com/jqkdudu/reftools.git
md davidrjenni
mv reftools davidrjenni\reftools

git clone https://gitee.com/jqkdudu/go_impl.git
md josharian
mv go_impl josharian\impl

git clone https://gitee.com/jqkdudu/go_gomodifytags.git
md fatih
mv go_gomodifytags fatih\gomodifytags

git clone https://gitee.com/jqkdudu/go_go-symbols.git
md acroca
mv go_go-symbols acroca\go-symbols

git clone https://gitee.com/jqkdudu/go_go-outline.git
md ramya-rao-a
mv go_go-outline ramya-rao-a\go-outline

git clone https://gitee.com/jqkdudu/go_gopkgs.git
md uudashr
mv go_gopkgs uudashr\gopkgs

git clone https://gitee.com/jqkdudu/go_mdempsky_gocode.git
md mdempsky
mv go_mdempsky_gocode mdempsky\gocode


cd ..\golang.org\x

git clone https://gitee.com/jqkdudu/go_lint.git
git clone https://gitee.com/jqkdudu/go_mod.git
git clone https://gitee.com/jqkdudu/go_xerrors.git
git clone https://gitee.com/jqkdudu/go_tools.git

mv go_mod mod
mv go_lint lint
mv go_tools tools
mv go_xerrors xerrors