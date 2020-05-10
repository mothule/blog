;$(function(){
    var windowWidth = $(window).width();
    if(windowWidth > 991) {
        buildTableOfContentsOnSide()
        buildShareButtonsOnSide()
    }

    // Table of Contents作成
    function buildTableOfContentsOnSide() {
      var toc = $('.post-content-toc');
      var sidebar = $('.sidebar');
      var article = $('article');
      sidebar.height(article.height());
      $('#side-toc-id').append('<p>目次</p>')
      toc.clone(false).appendTo($('#side-toc-id'));
    }

    // シェアボタン群作成
    function buildShareButtonsOnSide() {
      var hatena_bookmark_button = `
      <li><a href="https://b.hatena.ne.jp/entry/" class="hatena-bookmark-button" data-hatena-bookmark-layout="basic-label-counter" data-hatena-bookmark-lang="ja" title="このエントリーをはてなブックマークに追加"><img src="https://b.st-hatena.com/images/v4/public/entry-button/button-only@2x.png" alt="このエントリーをはてなブックマークに追加" width="20" height="20" style="border: none;" /></a>
</li>
      <li><span style="display: inline-block;"><a data-pocket-label="pocket" data-pocket-count="horizontal" class="pocket-btn" data-lang="en"></a></span>
</li>
      `;
      $('#side-share-id>ul').append(hatena_bookmark_button);
    }
});
